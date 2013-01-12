/datum/event/communications_blackout/announce()
	var/list/alerts = list(	"Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00)`5vc-BZZT", \
							"Ionospheric anomalies detected. Temporary telecommunication failu*3mga;b4;'1v¬-BZZZT", \
							"Ionospheric anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT", \
							"Ionospheric anomalies dete'fZ\\kg5_0-BZZZZZT", \
							"Ionospheri:%£ MCayj^j<.3-BZZZZZZT", \
							"#4nd%;f4y6,>£%-BZZZZZZZT")

	var/alert = pick(alerts)

	for(var/mob/living/silicon/ai/A in player_list)	//AIs are always aware of communication blackouts.
		A << "<br>"
		A << "<span class='warning'><b>[alert]</b></span>"
		A << "<br>"

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		command_alert(alert)


/datum/event/communications_blackout/start()
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emp_act(1)