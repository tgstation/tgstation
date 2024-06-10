#define MAX_DISTANCE 4 // How far crates can spawn from the server

/// Resets the cooldown state and updates icons
/obj/machinery/quantum_server/proc/cool_off()
	is_ready = TRUE
	update_appearance()
	radio.talk_into(src, "Thermal systems within operational parameters. Proceeding to domain configuration.", RADIO_CHANNEL_SUPPLY)

/// If there are hosted minds, attempts to get a list of their current virtual bodies w/ vitals
/obj/machinery/quantum_server/proc/get_avatar_data()
	var/list/hosted_avatars = list()

	for(var/datum/weakref/avatar_ref in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = avatar_ref.resolve()
		if(isnull(connection))
			avatar_connection_refs.Remove(connection)
			continue

		var/mob/living/creature = connection.parent
		var/mob/living/pilot = connection.old_body_ref?.resolve()

		hosted_avatars += list(list(
			"health" = creature.health,
			"name" = creature.name,
			"pilot" = pilot,
			"brute" = creature.getBruteLoss(),
			"burn" = creature.getFireLoss(),
			"tox" = creature.getToxLoss(),
			"oxy" = creature.getOxyLoss(),
		))

	return hosted_avatars

/// Locates any turfs with forges on them, returns a random one
/obj/machinery/quantum_server/proc/get_random_nearby_forge()
	var/list/nearby_forges = list()

	for(var/obj/machinery/byteforge/forge in oview(MAX_DISTANCE, src))
		nearby_forges += forge

	return pick(nearby_forges)

/// Gets a random available domain given the current points.
/obj/machinery/quantum_server/proc/get_random_domain_id()
	if(points < 1)
		return

	var/list/random_domains = list()

	for(var/datum/lazy_template/virtual_domain/available as anything in subtypesof(/datum/lazy_template/virtual_domain))
		var/init_cost = initial(available.cost)

		if(!initial(available.test_only) && \
			init_cost <= points && \
			init_cost > BITRUNNER_COST_NONE && \
			init_cost < BITRUNNER_COST_EXTREME \
		)
			random_domains.Add(available)

	shuffle_inplace(random_domains)
	var/datum/lazy_template/virtual_domain/selected = pick(random_domains)
	domain_randomized = TRUE

	return initial(selected.key)


/// Removes all blacklisted items from a mob and returns them to base state
/obj/machinery/quantum_server/proc/reset_equipment(mob/living/carbon/human/person)
	for(var/obj/item in person.get_equipped_items(INCLUDE_POCKETS | INCLUDE_ACCESSORIES))
		qdel(item)

	var/datum/antagonist/bitrunning_glitch/antag_datum = locate() in person.mind?.antag_datums
	if(isnull(antag_datum?.preview_outfit))
		return

	person.equipOutfit(antag_datum.preview_outfit)

	antag_datum.fix_agent_id()


/// Severs any connected users
/obj/machinery/quantum_server/proc/sever_connections()
	if(isnull(generated_domain) || !length(avatar_connection_refs))
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_QSRV_SEVER)

/// Do some magic teleport sparks
/obj/machinery/quantum_server/proc/spark_at_location(obj/cache)
	playsound(cache, 'sound/magic/blink.ogg', 50, vary = TRUE)
	var/datum/effect_system/spark_spread/quantum/sparks = new()
	sparks.set_up(5, location = get_turf(cache))
	sparks.start()

/// Returns a turf if it's not dense, else will find a neighbor.
/obj/machinery/quantum_server/proc/validate_turf(turf/chosen_turf)
	if(!chosen_turf.is_blocked_turf())
		return chosen_turf

	for(var/turf/tile in get_adjacent_open_turfs(chosen_turf))
		if(!tile.is_blocked_turf())
			return chosen_turf

#undef MAX_DISTANCE

/// Toggles broadcast on and off
/obj/machinery/quantum_server/proc/toggle_broadcast()
	if(!COOLDOWN_FINISHED(src, broadcast_toggle_cd))
		return FALSE

	broadcasting = !broadcasting

	if(generated_domain)
		// The cooldown only really matter is we're flipping TVs
		COOLDOWN_START(src, broadcast_toggle_cd, 5 SECONDS)
		// And we only flip TVs when there's a domain, because otherwise there's no cams to watch
		set_network_broadcast_status(BITRUNNER_CAMERA_NET, broadcasting)
	return TRUE
