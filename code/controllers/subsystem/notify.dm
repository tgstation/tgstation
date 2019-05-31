/* 
NOTES:
There is a DB table to track ckeys and associated discord IDs.
This system REQUIRES TGS, and will auto-disable if TGS is not present.
The SS uses fire() instead of just pure shutdown, so people can be notified if it comes back after a crash, where the SS wasnt properly shutdown
It only writes to the disk every 5 minutes, and it wont write to disk if the file is the same as it was the last time it was written. This is to save on disk writes
The system is kept per-server (EG: Terry will not notify people who pressed notify on Sybil), but the accounts are between servers so you dont have to relink on each server.

##################
# HOW THIS WORKS #
##################

ROUNDSTART:
1] The file is loaded and the discord IDs are extracted
2] A ping is sent to the discord with the IDs of people who wished to be notified
3] The file is emptied

MIDROUND: 
1] Someone usees the notify verb, it adds their discord ID to the list.
2] On fire, it will write that to the disk, as long as conditions above are correct

END ROUND:
1] The file is force-saved, incase it hasnt fired at end round

This is an absolute clusterfuck, but its my clusterfuck -aa07
*/

SUBSYSTEM_DEF(notify)
	name = "Notify"
	wait = 3000
	init_order = INIT_ORDER_NOTIFY

	var/list/notify_members = list() // People to save to notify file
	var/list/notify_members_cache = list() // Copy of previous list, so the SS doesnt have to fire if no new members have been added
	var/list/people_to_notify = list() // People to notify on roundstart
	var/notify_file = file("data/notify.json")
	var/enabled = 0 // Is TGS enabled (If not we wont fire because otherwise this is useless)

/datum/controller/subsystem/notify/Initialize(start_timeofday)
	// Check for if we are using TGS, otherwise return and disabless firing
	if(world.TgsAvailable())
		enabled = 1 // Allows other procs to use this (Account linking, etc)
	else
		can_fire = 0 // We dont want excess firing
		return ..() // Cancel 

	try
		people_to_notify = json_decode(file2text(notify_file))
	catch
		pass() // The list can just stay as its defualt (blank). Pass() exists because it needs a catch
	var/notifymsg = ""
	for(var/id in people_to_notify)
		// I would use jointext here, but I dont think you can two-side glue with it, and I would have to strip characters otherwise
		notifymsg += "<@[id]> " // 22 charaters per notify, 90 notifies per message, so I am not making a failsafe because 90 people arent going to notify at once
	if(notifymsg)
		send2chat("[notifymsg]", CONFIG_GET(string/chat_announce_new_game)) // Sends the message to the discord, using same config option as the roundstart notification
	fdel(notify_file) // Deletes the file
	return ..()
	
/datum/controller/subsystem/notify/fire()
	if(!enabled)
		return // Dont do shit if its disabled
	if(notify_members == notify_members_cache)
		return // Dont re-write the file 
	// If we are all clear
	write_notify_file()
	
/datum/controller/subsystem/notify/Shutdown()
	write_notify_file() // Guaranteed force-write on server close
	
/datum/controller/subsystem/notify/proc/write_notify_file()
	if(!enabled) // Dont do shit if its disabled
		return
	fdel(notify_file) // Deletes the file first to make sure it writes properly
	WRITE_FILE(notify_file, json_encode(notify_members)) // Writes the file
	notify_members_cache = notify_members // Updates the cache list
