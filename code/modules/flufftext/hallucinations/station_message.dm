/datum/hallucination/station_message
	abstract_hallucination_parent = /datum/hallucination/station_message
	random_hallucination_weight = 1

/datum/hallucination/station_message/start()
	qdel(src)
	return TRUE

/datum/hallucination/station_message/blob_alert

/datum/hallucination/station_message/blob_alert/start()
	to_chat(hallucinator, "<h1 class='alert'>Biohazard Alert</h1>")
	to_chat(hallucinator, "<br><br>[span_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.")]<br><br>")
	SEND_SOUND(hallucinator,  SSstation.announcer.event_sounds[ANNOUNCER_OUTBREAK5])
	return ..()

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/start()
	to_chat(hallucinator, "<h1 class='alert'>Priority Announcement</h1>")
	to_chat(hallucinator, "<br><br>[span_alert("The Emergency Shuttle has docked with the station. You have 3 minutes to board the Emergency Shuttle.")]<br><br>")
	SEND_SOUND(hallucinator, SSstation.announcer.event_sounds[ANNOUNCER_SHUTTLEDOCK])
	return ..()

/datum/hallucination/station_message/malf_ai

/datum/hallucination/station_message/malf_ai/start()
	to_chat(hallucinator, "<h1 class='alert'>Anomaly Alert</h1>")
	to_chat(hallucinator, "<br><br>[span_alert("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.")]<br><br>")
	SEND_SOUND(hallucinator, SSstation.announcer.event_sounds[ANNOUNCER_AIMALF])
	return ..()

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2

/datum/hallucination/station_message/meteors/start()
	to_chat(hallucinator, "<h1 class='alert'>Meteor Alert</h1>")
	to_chat(hallucinator, "<br><br>[span_alert("Meteors have been detected on collision course with the station.")]<br><br>")
	SEND_SOUND(hallucinator, SSstation.announcer.event_sounds[ANNOUNCER_METEORS])
	return ..()

/datum/hallucination/station_message/supermatter_delam

/datum/hallucination/station_message/supermatter_delam/start()
	SEND_SOUND(hallucinator, 'sound/magic/charge.ogg')
	to_chat(hallucinator, span_boldannounce("You feel reality distort for a moment..."))
	return ..()

/datum/hallucination/station_message/ratvar
	// Clock cult's long gone, but this stays for posterity.
	random_hallucination_weight = 0

/datum/hallucination/station_message/ratvar/start()
	hallucinator.playsound_local(hallucinator, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
	hallucinator.playsound_local(hallucinator, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, .proc/play_distant_explosion_sound), 2.7 SECONDS)
	return ..()

/datum/hallucination/station_message/ratvar/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/explosion_distant.ogg', 50, FALSE, pressure_affected = FALSE)
