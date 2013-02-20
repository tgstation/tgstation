/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	startWhen		= 5

/datum/event/grid_check/setup()
	endWhen = rand(90,600)

/datum/event/grid_check/start()
	power_failure(1)

/datum/event/grid_check/announce()
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Automated Grid Check")
	for(var/mob/M in player_list)
		M << sound('sound/AI/poweroff.ogg')

/datum/event/grid_check/end()
	command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
	for(var/mob/M in player_list)
		M << sound('sound/AI/poweron.ogg')
	power_restore()
