import os
import rivermeadow

API_USER = os.environ['SELECTED_CREDENTIALS_USERNAME']
API_PASS = os.environ['SELECTED_CREDENTIALS_PASSWORD']
SOURCE_ADDR = "#{inputVariable['address']}"
SOURCE_NAME = "#{inputVariable['name']}"
SOURCE_USER = "#{inputVariable['username']}"
SOURCE_PASS = "#{inputVariable['password']}"
CLOUD_ACCT = "#{inputVariable['cloud']}"


rm = rivermeadow.RiverMeadow(API_USER, API_PASS)

source = rivermeadow.Source(SOURCE_NAME,
                            SOURCE_ADDR,
                            SOURCE_USER,
                            SOURCE_PASS)

print(f"Creating source {source}")

source_id = rm.create_source(source)
print(f"Source {source_id} created, linking to cloud account '{CLOUD_ACCT}' ")
appliance_id = rm.get_appliance_id(CLOUD_ACCT)

rm.link_source(source_id, appliance_id)
print(f"Linked to appliance {appliance_id}")
print("Done")
print("")
print(source_id)

