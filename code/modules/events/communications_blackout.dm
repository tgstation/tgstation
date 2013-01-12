/datum/event/communications_blackout
	var/silent = 1	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.

/datum/event/communications_blackout/announce()
	if(!silent)
		command_alert("Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT")


/datum/event/communications_blackout/start()
	//if(prob(25))
	//	silent = 0
	for(var/mob/living/silicon/ai/A in player_list)	//AIs are always aware of communication blackouts.
		A << "<br>"
		A << "<span class='warning'><b>Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you-BZZT<b></span>"
		A << "<br>"
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)