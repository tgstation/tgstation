var/global/datum/watchdog/watchdog = new

/datum/watchdog
	var/waiting=0 // Waiting for the server to end round or empty.
	var/const/update_signal_file="data/UPDATE_READY.txt"
	var/const/server_signal_file="data/SERVER_READY.txt"
	var/chosen_map

/datum/watchdog/proc/check_for_update()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/watchdog/proc/check_for_update() called tick#: [world.time]")
	if(waiting)
		return
	if(fexists(update_signal_file) == 1)
		waiting=1
		world << "<span class='notice'>\[AUTOMATIC ANNOUNCEMENT\] Update received.  Server will restart automatically after the round ends.</span>"

/datum/watchdog/proc/signal_ready()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/watchdog/proc/signal_ready() called tick#: [world.time]")
	var/signal = file(server_signal_file)
	fdel(signal)
	signal << chosen_map