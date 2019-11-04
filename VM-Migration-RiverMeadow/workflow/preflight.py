import rivermeadow
import argparse
import sys

ap = argparse.ArgumentParser()
ap.add_argument("-u", "--api-user")
ap.add_argument("-p", "--api-pass")
ap.add_argument("-a", "--address")
args = ap.parse_args()

rm = rivermeadow.RiverMeadow(args.api_user, args.api_pass)

def get_source_id():
    for source in rm.get_sources():
        if args.address == source['host']:
            return source['id']
    raise KeyError()

source_id = get_source_id()
print(f"Found source_id {source_id} for host {args.address}")

preflight = rm.start_source_preflight(source_id)
preflight_id = preflight['preflights'][0]['id']
print(f"started preflight {preflight_id}. waiting...")

result = rm.wait_preflight(preflight_id)

print("got result")

if result['state'] == 'error':
    for check in result['content']:
        if check['state'] not in ('success', 'pending'):
            print(f"* {check['label']}:")
            print(f"\t{check['description']}")
            print(f"\tState: {check['state']}")
            for error in check['errors']:
                print(f"\t* {error['message']}")
    sys.exit(1)

print("Success")
