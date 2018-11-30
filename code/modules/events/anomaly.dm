/datum/round_event_control/anomaly
	name = "Anomaly: Energetic Flux"
	typepath = /datum/round_event/anomaly

	min_players = 1
	max_occurrences = 0 //This one probably shouldn't occur! It'd work, but it wouldn't be very fun.
	weight = 15

/datum/round_event/anomaly
	var/area/impact_area
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	announceWhen	= 1


/datum/round_event/anomaly/proc/findEventArea()
	var/static/list/allowed_areas
	if(!allowed_areas)
		//Places that shouldn't explode
		var/list/safe_area_types = typecacheof(list(
		/area/ai_monitored/turret_protected/ai,
		/area/ai_monitored/turret_protected/ai_upload,
		/area/engine,
		/area/solar,
		/area/holodeck,
		/area/shuttle)
		)

		//Subtypes from the above that actually should explode.
		var/list/unsafe_area_subtypes = typecacheof(list(/area/engine/break_room))
		
		allowed_areas = make_associative(GLOB.the_station_areas) - safe_area_types + unsafe_area_subtypes

	return safepick(typecache_filter_list(GLOB.sortedAreas,allowed_areas))

/datum/round_event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/round_event/anomaly/announce(fake)
	priority_announce("Localized energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	var/newAnomaly
	if(T)
		newAnomaly = new anomaly_path(T)
	if (newAnomaly)
		announce_to_ghosts(newAnomaly)

/datum/round_event_control/chosen_one
	name = "The Chosen One"
	typepath = /datum/round_event/chosen_one
	weight = 7 //more often than aliens, less often then appendicitis
	max_occurrences = 1
	earliest_start = 15 MINUTES
	min_players = 35

/datum/round_event/chosen_one

/datum/round_event/chosen_one/start()
	for(var/mob/living/L in apply_luck(GLOB.alive_mob_list, POSITIVE_EVENT))//even a sentient slime could be the chosen one
		if(!L.client)
			continue
		if(L.stat == DEAD)
			continue
		if(L.mind.antag_datums.len > 0)
			continue
		
		L.apply_status_effect(/datum/status_effect/chosen_one)
		announce_to_ghosts(L)
		break

/datum/status_effect/chosen_one
	id = "chosen_one"
	var/awakened = FALSE

/datum/status_effect/chosen_one/tick()
	if(owner.health <= maxHealth/5 && awakened == FALSE)
		a_hero_rises()

/datum/status_effect/chosen_one/proc/a_hero_rises()
	awakened = TRUE
	heal_overall_damage(10, 10)
	to_chat(owner, "<span class='green'><b>Your will to live gives you a burst of energy!</b></span>")
	owner.SetStun(0, FALSE)
	owner.SetKnockdown(0, FALSE)
	owner.SetParalyzed(0, FALSE)
	owner.SetImmobilized(0)
	remove_status_effect(/datum/status_effect/chosen_one)
