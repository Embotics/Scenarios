import rivermeadow
import argparse

ap = argparse.ArgumentParser()
ap.add_argument("-u", "--api-user")
ap.add_argument("-p", "--api-pass")
ap.add_argument("-a", "--address")
ap.add_argument("--source-user")
ap.add_argument("--source-pass")
ap.add_argument("-n", "--name")
ap.add_argument("-c", "--cloud")
ap.add_argument("tags", nargs="*")
args = ap.parse_args()

rm = rivermeadow.RiverMeadow(args.api_user, args.api_pass)

source = rivermeadow.Source(args.name, args.address, args.source_user, args.source_pass, args.tags)

source_id = rm.create_source(source)
appliance_id = rm.get_appliance_id(args.cloud)

rm.link_source(source_id, appliance_id)

