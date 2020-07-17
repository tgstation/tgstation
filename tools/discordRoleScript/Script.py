# Script to role discord members who have already associated their BYOND account
# Author: AffectedArc07

# From Discord API:
# Clients are allowed 120 events every 60 seconds, meaning you can send on average at a rate of up to 2 events per second.

# So lets send every 0.6 seconds to ensure we arent rate capped

####### CONFIG ######

# Discord section. Make sure the IDs are strings to avoid issues with IDs that start with a 0
botToken = "Put your discord bot token here"
guildID = "000000000000000000"
roleID = "000000000000000000"

# SS13 Database section
dbHost = "127.0.0.1"
dbUser = "root"
dbPass = "your password here"
dbDatabase = "tg_db"

##### DO NOT TOUCH ANYTHING BELOW HERE UNLESS YOURE FAMILIAR WITH PYTHON #####
import requests, mysql.connector, time

# Connect to DB
dbCon = mysql.connector.connect(
    host = dbHost,
    user = dbUser,
    passwd = dbPass,
    database = dbDatabase
)
cur = dbCon.cursor()

# Grab all users who need to be processed
cur.execute("SELECT byond_key, discord_id FROM player WHERE discord_id IS NOT NULL")
usersToProcess = cur.fetchall()

# We dont need the DB anymore, so close it up
dbCon.close()

# Calculate a total for better monitoring
total = len(usersToProcess)
count = 0
print("Found "+str(total)+" accounts to process.")

# Now the actual processing
for user in usersToProcess:
    count += 1  # Why the fuck does python not have ++
    # user[0] = ckey, user[1] = discord ID
    print("Processing "+str(user[0])+" (Discord ID: " + str(user[1]) + ") | User "+str(count)+"/"+str(total))
    url = "https://discord.com/api/guilds/"+str(guildID)+"/members/"+str(user[1])+"/roles/"+str(roleID)
    response = requests.put(url, headers={"Authorization": "Bot "+str(botToken)})
    # Adding a role returns a code 204, not a code 200. Dont ask
    if response.status_code != 204:
        print("WARNING: Returned non-204 status code. Request used: PUT "+str(url))

    # Sleep for 0.6. This way we stay under discords rate limiting.
    time.sleep(0.6)

