import requests
import time
import json

class APIException(Exception):
    def __init__(self, response, *args, **kwargs):
        super().__init__(*args, **kwargs)
        try:
            self.message = response.json()
        except ValueError as e:
            self.message = "Server provided no error message"
            self.__cause__ = e
        self.raw = response.raw
        self.status_code = response.status_code

    def __str__(self):
        return f"[{self.status_code}]: {self.message}"

class Source:
    def __init__(self, name, address, user, password, tags=None):
        self.name = name
        self.address = address
        self.user = user
        self.password = password
        self.tags = tags if tags else []
        self.storage = "local"
        self.domain = None

    def to_dict(self):
        return {
            "name": self.name,
            "host": self.address,
            "tags": self.tags,
            "credentials": {
                "storage": self.storage,
                "username": self.user,
                "password": self.password,
                "domain": self.domain
            }
        }

    def __str__(self):
        return f"{self.name} ({self.user}@{self.address})"

class MigrationSource:
    def __init__(self, source_id):
        self.source_id = source_id
        self.target_config = None
        self.verify_ssl_certificates = False

    def to_dict(self):
        return {
            "source": self.source_id,
            "target_config": self.target_config,
            "verify_ssl_certificates": self.verify_ssl_certificates
        }

class AWSMigrationSource(MigrationSource):
    def __init__(self, source_id, vapp_name, flavor, vpc_id, security_group,
                        subnet_id, region, az, mount_points=None, power_on=True):
        super().__init__(source_id)
        self.name = vapp_name
        self.flavor = flavor
        self.vpc = vpc_id
        self.sg = security_group
        self.subnet = subnet_id
        self.region = region
        self.az = az
        self.power_on = power_on
        self.mount_points = mount_points if mount_points else ['/']

    def to_dict(self):
        return {
            "source": self.source_id,
            "target_config": {
                "vm_details": {
                    "vapp_name": self.name,
                    "tags": {},
                    "flavor": {
                        "flavor_type": self.flavor,
                        "volume_type": "magnetic",
                        "iops": None
                    },
                    "security": {
                        "vpc_id": self.vpc,
                        "security_group_ids": self.sg
                    },
                    "encrypt_volumes": False,
                    "capture_ami": False
                },
                "properties": {
                    "network": {
                        "interfaces": {
                            "eth0": {
                                "ip_type": "dhcp",
                                "type": "Ethernet",
                                "network_name": self.subnet,
                                "assign_public_ip": True
                            }
                        }
                    },
                    "name": self.name,
                    "selected_mounts": list(
                        {"mount_point": m} for m in self.mount_points
                    )
                },
                "options": {
                    "region": self.region,
                    "az": self.az,
                    "power_on": self.power_on
                }
            },
            "verify_ssl_certificates": self.verify_ssl_certificates
        }


class MigrationProfile:
    def __init__(self, name, entitlement, cloud_account, migration_source, description=""):
        self.name = name
        self.description = description
        self.entitlement = entitlement
        self.cloud_account = cloud_account
        self.source = migration_source
    
    def to_dict(self):
        return {
            "name": self.name,
            "description": self.description,
            "entitlement": self.entitlement,
            "cloud_account": self.cloud_account,
            "sources": [
                self.source.to_dict()
            ]
        }

        
class RiverMeadow:
    def __init__(self, username, password, url="https://migrate.rivermeadow.com/api/v3"):
        self.url = url
        self.username = username
        self.password = password
        self.login()

    def login(self):
        self.token, self.user_id = self._login()

    # users and orgs
    def get_user(self, user_id):
        res = self._get(f"users/{user_id}")
        return res

    def get_organizations(self, user_id):
        res = self._get(f"users/{user_id}/organizations")
        return res['content']

    def get_organization(self, org_id):
        res = self._get(f"organizations/{org_id}")
        return res

    def get_entitlements(self, org_id):
        res = self._get(f"organizations/{org_id}/entitlements")
        return res['content']

    def get_my_entitlements(self, cloud_target=None, only_active=False):
        for org in self.get_organizations(self.user_id):
            for entitlement in self.get_entitlements(org['id']):
                if only_active and entitlement['used'] >= entitlement['total']:
                    continue
                if cloud_target and cloud_target != entitlement['cloud_target']:
                    continue
                yield entitlement

    # clouds and appliances
    def get_cloud_accounts(self):
        return self._get(f"users/{self.user_id}/cloudaccounts")['content']

    def get_cloud_id(self, cloud_name):
        accts = self.get_cloud_accounts()
        for acct in accts:
            if acct['name'] == cloud_name:
                return acct['id']
        raise KeyError()

    def get_appliance_id(self, cloud_name):
        accts = self.get_cloud_accounts()
        for acct in accts:
            if acct['name'] == cloud_name:
                return acct['appliance']['id']
        raise KeyError()

    # sources
    def get_sources(self):
        return self._get(f"users/{self.user_id}/sources")['content']

    def create_source(self, source):
        result = self._post("sources", source.to_dict())
        return result['id']

    def link_source(self, source_id, appliance_id):
        self._put(f"sources/{source_id}", {"appliance_id": appliance_id})

    # preflight
    def start_source_preflight(self, source_id):
        return self._post("preflights", [{"type": "source", "resource_id": source_id}])

    def get_preflight(self, preflight_id):
        return self._get(f"preflights/{preflight_id}")

    def wait_preflight(self, preflight_id, timeout=300, sleep=30):
        started = time.time()
        while (time.time() - started) < timeout:
            preflight = self.get_preflight(preflight_id)
            if preflight['state'] != 'running':
                return preflight
            time.sleep(sleep)
        raise TimeoutError()

    # migration profiles
    def create_migration_profile(self, migration_profile):
        result = self._post("migrationprofiles", migration_profile.to_dict())
        return result.get('id')

    def get_migration_profile(self, profile_id):
        result = self._get(f"migrationprofiles/{profile_id}")

    # migration
    def start_migration(self, profile_id):
        result = self._post(f"migrationprofiles/{profile_id}/migrations")
        return result.get('id')

    def get_migration(self, migration_id):
        return self._get(f"migrations/{migration_id}")

    def wait_migration(self, migration_id, timeout=300, sleep=30):
        started = time.time()
        while (time.time() - started) < timeout:
            migration = self.get_migration(migration_id)
            if migration.get('state') != 'running':
                return migration
            time.sleep(sleep)
        raise TimeoutError()

    def get_profile_migrations(self, profile_id):
        return self._get(f"migrationprofiles/{profile_id}/migrations")

    def wait_profile_migrations(self, profile_id):
        return [self.wait_migration(migration['id']) for migration in self.get_profile_migrations(profile_id)['content']]

    # helpers
    @property
    def headers(self):
        return {"X-Auth-Token": self.token, "Content-Type": "application/json"}

    def _get(self, end):
        resp = requests.get(f"{self.url}/{end}", headers=self.headers)
        if resp.status_code >= 400:
            raise APIException(resp)
        return resp.json()

    def _post(self, end, data=None):
        if data is None:
            resp = requests.post(f"{self.url}/{end}", headers=self.headers)
        else:
            resp = requests.post(f"{self.url}/{end}", json=data, headers=self.headers)
        if resp.status_code >= 400:
            raise APIException(resp)
        return resp.json()

    def _put(self, end, data):
        resp = requests.put(f"{self.url}/{end}", json=data, headers=self.headers)
        if resp.status_code >= 400:
            raise APIException(resp)
        return resp.json()

    def _delete(self, end):
        resp = requests.delete(f"{self.url}/{end}", headers=self.headers)
        if resp.status_code >= 400:
            raise APIException(resp)
        return resp.json()

    def _login(self):
        resp = requests.post(self.url + "/login", json={"email": self.username, "password": self.password})
        resp.raise_for_status()
        result = resp.json()
        return result['token'], result['user_id']
