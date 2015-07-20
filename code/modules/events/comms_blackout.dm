
/proc/communications_blackout(var/silent = 1)

	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/communications_blackout() called tick#: [world.time]")

	if(!silent)
		command_alert("Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT")
	else // AIs will always know if there's a comm blackout, rogue AIs could then lie about comm blackouts in the future while they shutdown comms
		for(var/mob/living/silicon/ai/A in player_list)
			A << "<br>"
			A << "<span class='danger'><b>Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT</span>"
			A << "<br>"
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)
