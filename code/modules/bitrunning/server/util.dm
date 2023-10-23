#define REDACTED "???"
#define MAX_DISTANCE 4 // How far crates can spawn from the server

/// Resets the cooldown state and updates icons
/obj/machinery/quantum_server/proc/cool_off()
	is_ready = TRUE
	update_appearance()
	radio.talk_into(src, "Thermal systems within operational parameters. Proceeding to domain configuration.", RADIO_CHANNEL_SUPPLY)

/// Compiles a list of available domains.
/obj/machinery/quantum_server/proc/get_available_domains()
	var/list/levels = list()

	for(var/datum/lazy_template/virtual_domain/domain as anything in available_domains)
		if(initial(domain.test_only))
			continue
		var/can_view = initial(domain.difficulty) < scanner_tier && initial(domain.cost) <= points + 5
		var/can_view_reward = initial(domain.difficulty) < (scanner_tier + 1) && initial(domain.cost) <= points + 3

		levels += list(list(
			"cost" = initial(domain.cost),
			"desc" = can_view ? initial(domain.desc) : "Limited scanning capabilities. Cannot infer domain details.",
			"difficulty" = initial(domain.difficulty),
			"id" = initial(domain.key),
			"is_modular" = initial(domain.is_modular),
			"name" = can_view ? initial(domain.name) : REDACTED,
			"reward" = can_view_reward ? initial(domain.reward_points) : REDACTED,
		))

	return levels

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
			"brute" = creature.get_current_damage_of_type(BRUTE),
			"burn" = creature.get_current_damage_of_type(BURN),
			"tox" = creature.get_current_damage_of_type(TOX),
			"oxy" = creature.get_current_damage_of_type(OXY),
		))

	return hosted_avatars

/// Locates any turfs with forges on them, returns a random one
/obj/machinery/quantum_server/proc/get_random_nearby_forge()
	var/list/nearby_forges = list()

	for(var/obj/machinery/byteforge/forge in oview(MAX_DISTANCE, src))
		nearby_forges += forge

	return pick(nearby_forges)

/// Gets a random available domain given the current points. Weighted towards higher cost domains.
/obj/machinery/quantum_server/proc/get_random_domain_id()
	if(points < 1)
		return

	var/list/random_domains = list()
	var/total_cost = 0

	for(var/datum/lazy_template/virtual_domain/available as anything in subtypesof(/datum/lazy_template/virtual_domain))
		var/init_cost = initial(available.cost)
		if(!initial(available.test_only) && init_cost > 0 && init_cost < 4 && init_cost <= points)
			random_domains += list(list(
				cost = init_cost,
				id = initial(available.key),
			))

	var/random_value = rand(0, total_cost)
	var/accumulated_cost = 0

	for(var/available as anything in random_domains)
		accumulated_cost += available["cost"]
		if(accumulated_cost >= random_value)
			domain_randomized = TRUE
			return available["id"]


/// Removes all blacklisted items from a mob and returns them to base state
/obj/machinery/quantum_server/proc/reset_equipment(mob/living/carbon/human/person)
	for(var/item in person.get_contents())
		qdel(item)

	var/datum/antagonist/bitrunning_glitch/antag_datum = locate() in person.mind?.antag_datums
	if(isnull(antag_datum?.preview_outfit))
		return

	person.equipOutfit(antag_datum.preview_outfit)

/// Do some magic teleport sparks
/obj/machinery/quantum_server/proc/spark_at_location(obj/cache)
	playsound(cache, 'sound/magic/blink.ogg', 50, TRUE)
	var/datum/effect_system/spark_spread/quantum/sparks = new()
	sparks.set_up(5, 1, get_turf(cache))
	sparks.start()

/// Returns a turf if it's not dense, else will find a neighbor.
/obj/machinery/quantum_server/proc/validate_turf(turf/chosen_turf)
	if(!chosen_turf.is_blocked_turf())
		return chosen_turf

	for(var/turf/tile in get_adjacent_open_turfs(chosen_turf))
		if(!tile.is_blocked_turf())
			return chosen_turf

#undef REDACTED
#undef MAX_DISTANCE
