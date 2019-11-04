import rivermeadow
import json
import os
import uuid

API_USER      = os.environ['SELECTED_CREDENTIALS_USERNAME']
API_PASS      = os.environ['SELECTED_CREDENTIALS_PASSWORD']
ENTITLEMENT   = "#{inputVariable['entitlement']}"
CLOUD_ACCOUNT = "#{inputVariable['cloud']}"
SOURCE_ADDR   = "#{inputVariable['address']}"
TARGET_NAME   = "#{inputVariable['name']}_" + str(uuid.uuid4())[:8]
TARGET_FLAVOR = "#{inputVariable['flavor']}"
DEST          = json.loads("""#{inputVariable['destination']}""")

TARGET_REGION = DEST['region']
TARGET_AZ     = DEST['az']
TARGET_SG     = DEST['sg']
TARGET_VPC    = DEST['vpc']
TARGET_SUBNET = DEST['subnet']

rm = rivermeadow.RiverMeadow(API_USER, API_PASS)

def get_source_id():
    for source in rm.get_sources():
        if SOURCE_ADDR == source['host']:
            return source['id']
    raise KeyError()

source_id = get_source_id()
print(f"Found source_id {source_id} for host {SOURCE_ADDR}")

cloud_account_id = rm.get_cloud_id(CLOUD_ACCOUNT)
print(f"Found cloud account id {cloud_account_id} for '{CLOUD_ACCOUNT}'")

if not ENTITLEMENT:
    ENTITLEMENT = next(rm.get_my_entitlements(only_active=True))['id']
    print(f"Using first available entitlement: {ENTITLEMENT}")
else:
    print(f"Using provided entitlement: {ENTITLEMENT}")

migration_source = rivermeadow.AWSMigrationSource(source_id, TARGET_NAME,
                                            TARGET_FLAVOR, TARGET_VPC,
                                            TARGET_SG, TARGET_SUBNET,
                                            TARGET_REGION, TARGET_AZ)

migration_profile = rivermeadow.MigrationProfile(TARGET_NAME, ENTITLEMENT,
                                                    cloud_account_id, migration_source)


profile_id = rm.create_migration_profile(migration_profile)
print(f"Created migration profile {profile_id}")

rm.start_migration(profile_id)
print(f"Migration started. Waiting...")
migrations = rm.get_profile_migrations(profile_id)
print("Migrations asociated with this profile: ")
for m in migrations['content']:
    print(f"* {m['id']}")

result = rm.wait_profile_migrations(profile_id)

print("Result: ")
print(result)
