var/global/datum/watchdog/watchdog = new

/datum/watchdog
	var/waiting=0 // Waiting for the server to end round or empty.
	var/const/update_signal_file="data/UPDATE_READY.txt"
	var/const/server_signal_file="data/SERVER_READY.txt"

/datum/watchdog/proc/check_for_update()
	if(waiting)
		return
	if(fexists(update_signal_file) == 1)
		waiting=1
		world << "\blue \[AUTOMATIC ANNOUNCEMENT\] Update received.  Server will restart automatically after the round ends."

/datum/watchdog/proc/signal_ready()
	var/signal = file(server_signal_file)
	fdel(signal)
	signal << "READY"