/// If broken via signal, disconnects all users
/obj/machinery/quantum_server/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	if(isnull(generated_domain))
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

/// Whenever a corpse spawner makes a new corpse, add it to the list of potential mutations
/obj/machinery/quantum_server/proc/on_corpse_spawned(datum/source, mob/living/corpse)
	SIGNAL_HANDLER

	mutation_candidate_refs.Add(WEAKREF(corpse))

/// Being qdeleted - make sure the circuit and connected mobs go with it
/obj/machinery/quantum_server/proc/on_delete(datum/source)
	SIGNAL_HANDLER

	if(generated_domain)
		SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)
		scrub_vdom()

	if(is_ready)
		return
	// in case they're trying to cheese cooldown
	var/obj/item/circuitboard/machine/quantum_server/circuit = locate(/obj/item/circuitboard/machine/quantum_server) in contents
	if(circuit)
		qdel(circuit)

/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_infoplain("Can be resource intensive to run. Ensure adequate power supply.")

	if(capacitor_coefficient < 1)
		examine_text += span_infoplain("Its coolant capacity reduces cooldown time by [(1 - capacitor_coefficient) * 100]%.")

	if(servo_bonus > 0.2)
		examine_text += span_infoplain("Its manipulation potential is increasing rewards by [servo_bonus]x.")
		examine_text += span_infoplain("Injury from unsafe ejection reduced [servo_bonus * 100]%.")

	if(!is_ready)
		examine_text += span_notice("It is currently cooling down. Give it a few moments.")
		return

/// Whenever something enters the send tiles, check if it's a loot crate. If so, alert players.
/obj/machinery/quantum_server/proc/on_goal_turf_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!istype(arrived, /obj/structure/closet/crate/secure/bitrunning/encrypted))
		return

	var/obj/structure/closet/crate/secure/bitrunning/encrypted/loot_crate = arrived
	if(!istype(loot_crate))
		return

	for(var/mob/person in loot_crate.contents)
		if(isnull(person.mind))
			person.forceMove(get_turf(loot_crate))

		var/datum/component/avatar_connection/connection = person.GetComponent(/datum/component/avatar_connection)
		connection?.full_avatar_disconnect()

	spark_at_location(loot_crate)
	qdel(loot_crate)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_COMPLETE, arrived, generated_domain.reward_points)
	generate_loot()

/// Handles examining the server. Shows cooldown time and efficiency.
/obj/machinery/quantum_server/proc/on_goal_turf_examined(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_info("Beneath your gaze, the floor pulses subtly with streams of encoded data.")
	examine_text += span_info("It seems to be part of the location designated for retrieving encrypted payloads.")

/// Scans over the inbound created_atoms from lazy templates
/obj/machinery/quantum_server/proc/on_template_loaded(datum/lazy_template/source, list/created_atoms)
	SIGNAL_HANDLER

	for(var/thing in created_atoms)
		if(isliving(thing)) // so we can mutate them
			var/mob/living/creature = thing

			if(ismegafauna(creature))
				creature.AddElement(/datum/element/virtual_elite_mob)
				continue

			mutation_candidate_refs.Add(WEAKREF(creature))
			continue

		if(istype(thing, /obj/effect/mob_spawn/ghost_role)) // so we get threat alerts
			RegisterSignal(thing, COMSIG_GHOSTROLE_SPAWNED, PROC_REF(on_threat_created))
			continue

		if(istype(thing, /obj/effect/mob_spawn/corpse)) // corpses are valid targets too
			var/obj/effect/mob_spawn/corpse/spawner = thing

			mutation_candidate_refs.Add(spawner.spawned_mob_ref)

	UnregisterSignal(source, COMSIG_LAZY_TEMPLATE_LOADED)

/// Handles when cybercops are summoned into the area or ghosts click a ghost role spawner
/obj/machinery/quantum_server/proc/on_threat_created(datum/source, mob/living/threat)
	SIGNAL_HANDLER

	domain_threats += 1
	spawned_threat_refs.Add(WEAKREF(threat))
	SEND_SIGNAL(src, COMSIG_BITRUNNER_THREAT_CREATED) // notify players
