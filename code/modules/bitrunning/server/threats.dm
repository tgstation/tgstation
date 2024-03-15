/// Adds threats to the list and notifies players
/obj/machinery/quantum_server/proc/add_threats(mob/living/threat)
	spawned_threat_refs.Add(WEAKREF(threat))
	SEND_SIGNAL(src, COMSIG_BITRUNNER_THREAT_CREATED)

/// Finds any mobs with minds in the zones and gives them the bad news
/obj/machinery/quantum_server/proc/notify_spawned_threats()
	for(var/datum/weakref/baddie_ref as anything in spawned_threat_refs)
		var/mob/living/baddie = baddie_ref.resolve()
		if(isnull(baddie?.mind) || baddie.stat >= UNCONSCIOUS)
			continue

		var/atom/movable/screen/alert/bitrunning/alert = baddie.throw_alert(
			ALERT_BITRUNNER_RESET,
			/atom/movable/screen/alert/bitrunning,
			new_master = src,
		)
		alert.name = "Queue Deletion"
		alert.desc = "The server is resetting. Oblivion awaits."

		to_chat(baddie, span_userdanger("You have been flagged for deletion! Thank you for your service."))
