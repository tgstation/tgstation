/// If broken via signal, disconnects all users
/obj/machinery/quantum_server/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	sever_connections()


/// Whenever a corpse spawner makes a new corpse, add it to the list of potential mutations
/obj/machinery/quantum_server/proc/on_corpse_spawned(datum/source, mob/living/corpse)
	SIGNAL_HANDLER

	mutation_candidate_refs.Add(WEAKREF(corpse))


/// Being qdeleted - make sure the circuit and connected mobs go with it
/obj/machinery/quantum_server/proc/on_delete(datum/source)
	SIGNAL_HANDLER

	sever_connections()

	if(generated_domain)
		scrub_vdom()

	if(is_ready)
		return
	// in case they're trying to cheese cooldown
	var/obj/item/circuitboard/machine/quantum_server/circuit = locate(/obj/item/circuitboard/machine/quantum_server) in contents
	if(circuit)
		qdel(circuit)


/// Whenever something enters the send tiles, check if it's a loot crate. If so, alert players.
/obj/machinery/quantum_server/proc/on_goal_turf_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	var/obj/machinery/byteforge/chosen_forge = get_random_nearby_forge()
	if(isnull(chosen_forge))
		return

	if((obj_flags & EMAGGED) && isliving(arrived))
		var/mob/living/creature = arrived

		if(!creature.mind?.has_antag_datum(/datum/antagonist/bitrunning_glitch, check_subtypes = TRUE))
			return

		INVOKE_ASYNC(src, PROC_REF(station_spawn), arrived, chosen_forge)
		return

	if(istype(arrived, /obj/structure/closet/crate/secure/bitrunning/encrypted))
		var/goal_turf = get_turf(arrived)
		new /obj/effect/bitrunner_exit_portal(goal_turf)
		generate_loot(arrived, chosen_forge)
		return

	if(istype(arrived, /obj/item/storage/lockbox/bitrunning/encrypted))
		generate_secondary_loot(arrived, chosen_forge, generated_domain)
		return


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
				var/mob/living/simple_animal/hostile/megafauna/boss = creature
				boss.make_virtual_megafauna()
				continue

			mutation_candidate_refs.Add(WEAKREF(creature))
			continue

		if(istype(thing, /obj/effect/mob_spawn/ghost_role)) // so we get threat alerts
			RegisterSignal(thing, COMSIG_GHOSTROLE_SPAWNED, PROC_REF(on_threat_created))
			continue

		if(istype(thing, /obj/effect/mob_spawn/corpse)) // corpses are valid targets too
			var/obj/effect/mob_spawn/corpse/spawner = thing

			mutation_candidate_refs.Add(spawner.spawned_mob_ref)
			continue

		if(istype(thing, /obj/machinery/suit_storage_unit))
			var/obj/machinery/suit_storage_unit/storage = thing
			storage.disable_modlink()
			continue

		if(istype(thing, /obj/item/mod/control))
			var/obj/item/mod/control/modsuit = thing
			modsuit.disable_modlink()

		if(istype(thing, /obj/machinery/janitorial_scanner))
			var/obj/machinery/janitorial_scanner/jani_scanner = thing
			jani_scanner.unique_id = REF(src)
			jani_scanner.our_room = detect_room(get_turf(jani_scanner))
			for(var/turf/floor in jani_scanner.our_room) // We fuck up the corpses here because this is our opportunity to do so after they've been spawned.
				for(var/mob/living/carbon/human/corpse in floor)
					for(var/_ in 1 to rand(5, 15))
						corpse.apply_damage(
							damage = rand(25,50),
							damagetype = pick(list(BRUTE, BURN)),
							forced = TRUE,
							spread_damage = FALSE,
							wound_bonus = rand(0, 50),
							bare_wound_bonus = rand(0, 20),
							sharpness = pick(list(null, SHARP_EDGED, SHARP_POINTY)),
							attack_direction = pick(list(NORTH,SOUTH,EAST,WEST,NORTHWEST,NORTHEAST,SOUTHWEST,SOUTHEAST)),
						)

		if(istype(thing, /obj/machinery/janitorial_submit))
			var/obj/machinery/janitorial_submit/jani_plunger = thing
			jani_plunger.unique_id = REF(src)

	UnregisterSignal(source, COMSIG_LAZY_TEMPLATE_LOADED)

	/// Just in case there's any special handling for the domain
	generated_domain.setup_domain(created_atoms)


/// Handles when cybercops are summoned into the area or ghosts click a ghost role spawner
/obj/machinery/quantum_server/proc/on_threat_created(datum/source, mob/living/threat)
	SIGNAL_HANDLER

	add_threats(threat)
