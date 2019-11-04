import rivermeadow
import os

API_USER = os.environ['SELECTED_CREDENTIALS_USERNAME']
API_PASS = os.environ['SELECTED_CREDENTIALS_PASSWORD']
SOURCE_ADDR = "#{inputVariable['address']}"


rm = rivermeadow.RiverMeadow(API_USER, API_PASS)

def get_source_id():
    for source in rm.get_sources():
        if SOURCE_ADDR == source['host']:
            return source['id']
    raise KeyError()

source_id = get_source_id()
print(f"Found source_id {source_id} for host {SOURCE_ADDR}")

preflight = rm.start_source_preflight(source_id)
preflight_id = preflight['preflights'][0]['id']
print(f"started preflight {preflight_id}. waiting...")

result = rm.wait_preflight(preflight_id)

print("got result")

n_errors = 0
if result['state'] == 'error':
    for check in result['content']:
        if check['state'] not in ('success', 'pending'):
            print(f"* {check['label']}:")
            print(f"\t{check['description']}")
            print(f"\tState: {check['state']}")
            n_errors += 1
            for error in check['errors']:
                print(f"\t* {error['message']}")

if n_errors:
    print(f"Preflight returned {n_errors} errors")
else:
    print("No errors detected!")
