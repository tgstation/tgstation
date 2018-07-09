#Python 3+ Script for populating the key of all ckeys in player table made by Jordie0608
#
#Before starting ensure you have installed the mysqlclient package https://github.com/PyMySQL/mysqlclient-python
#It can be downloaded from command line with pip:
#pip install mysqlclient
#And that you have run the most recent commands listed in database_changelog.txt
#
#To view the parameters for this script, execute it with the argument --help
#All the positional arguments are required, remember to include a prefixe in your table name if you use one
#--useckey and --onlynull are optional arguments, see --help for their function
#An example of the command used to execute this script from powershell:
#python populate_key_2018-07-09.py "localhost" "root" "password" "feedback" "SS13_player" --onlynull --useckey
#
#This script requires an internet connection to function
#Sometimes byond.com fails to return the page for a valid ckey, this can be a temporary problem and may be resolved by rerunning the script
#To make the script only iterate on ckeys that failed to parse, use the --onlynull optional argument
#You can also instead have the script replace a missing key with ckey the --useckey optional argument
#
#It's safe to run this script with your game server(s) active.

import MySQLdb
import argparse
import re
import sys
from urllib.request import urlopen
from datetime import datetime

if sys.version_info[0] < 3:
    raise Exception("Python must be at least version 3 for this script.")
query_values = ""
current_round = 0
parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")
parser.add_argument("playertable", help="Name of the player table (remember a prefix if you use one)")
parser.add_argument("--useckey", help="Use the player's ckey for their key if unable to contact or parse their member page", action="store_true")
parser.add_argument("--onlynull", help="Only try to update rows if their byond_key column is null", action="store_true")
args = parser.parse_args()
only_null = ""
if args.onlynull:
    only_null = " WHERE byond_key IS NULL"
db=MySQLdb.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor=db.cursor()
player_table = args.playertable
cursor.execute("SELECT ckey FROM {0}{1}".format(player_table, only_null))
ckey_list = cursor.fetchall()
failed_ckeys = []
start_time = datetime.now()
print("Beginning script at {0}".format(start_time.strftime("%Y-%m-%d %H:%M:%S")))
if not ckey_list:
    print("Query returned no rows")
for current_ckey in ckey_list:
    link = urlopen("https://secure.byond.com/members/{0}/?format=text".format(current_ckey[0]))
    data = link.read()
    data = data.decode("ISO-8859-1")
    match = re.search("\tkey = \"(.+)\"", data)
    if match:
        key = match.group(1)
    else:
        failed_ckeys.append(current_ckey[0])
        msg = "Failed to parse a key for {0}".format(current_ckey[0])
        if args.useckey:
            msg += ", using their ckey instead"
            print(msg)
            key = current_ckey[0]
        else:
            print(msg)
            continue
    cursor.execute("UPDATE {0} SET byond_key = \'{1}\' WHERE ckey = \'{2}\'".format(player_table, key, current_ckey[0]))
    db.commit()
end_time = datetime.now()
print("Script completed at {0} with duration {1}".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S"), end_time - start_time))
if failed_ckeys:
    if args.useckey:
        print("The following ckeys failed to parse a key so their ckey was used instead:")
    else:
        print("The following ckeys failed to parse a key and were skipped:")
    print("\n".join(failed_ckeys))
cursor.close()
