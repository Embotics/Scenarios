import rivermeadow
import argparse
import sys

ap = argparse.ArgumentParser()
ap.add_argument("-u", "--api-user")
ap.add_argument("-p", "--api-pass")
ap.add_argument("-a", "--address")
ap.add_argument("-e", "--entitlement", default="b1a018b5-5a55-480f-8c3c-f62311ca018e")
args = ap.parse_args()

rm = rivermeadow.RiverMeadow(args.api_user, args.api_pass)

def get_source_id():
    for source in rm.get_sources():
        if args.address == source['host']:
            return source['id']
    raise KeyError()

source_id = get_source_id()
print(f"Found source_id {source_id} for host {args.address}")

profile_id = rm.create_migration_profile()

migration_id = rm.start_migration(profile_id)
result = rm.wait_migration(migration_id)
