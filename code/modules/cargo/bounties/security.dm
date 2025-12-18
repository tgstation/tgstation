///Bounties that require you to perform documentation and inspection of your department to send to centcom.
/datum/bounty/patrol
	name = "Patrol Station"
	description = "Perform a routine patrol of %AREA_NAME%. \
		You must travel at least %AREA_COVERAGE% meters within the area. \
		Your ID card will update you as you progress."
	reward = CARGO_CRATE_VALUE * 5

	/// Ref to the component applied to the ID card to track movement.
	VAR_PRIVATE/datum/tracker

	/// Typepath of what area we want patrolled.
	VAR_FINAL/area/demanded_area
	/// How much area coverage is needed to complete the patrol.
	VAR_FINAL/needed_coverage = -1
	/// List of turf IDs that have been walked on during the patrol.
	VAR_FINAL/list/walked_turfs
	/// Number 0-5 tracking which progress alerts have been sent.
	VAR_FINAL/alerted = 0

/datum/bounty/patrol/New()
	var/static/list/possible_areas
	if(!possible_areas)
		possible_areas = typecacheof(list(
			/area/station/commons,
			/area/station/hallway,
			/area/station/maintenance,
			/area/station/security/checkpoint,
			/area/station/security/prison,
			/area/station/service,
		))
		// filter out only areas that actually exist on the current station
		possible_areas &= GLOB.areas_by_type

	// maybe allow for certain jobs to get specific areas?
	demanded_area = pick(possible_areas)

	var/area/actual_area = GLOB.areas_by_type[demanded_area]

	var/total_coverage = 0
	for(var/turf/open/floor/walkable in actual_area.get_turfs_from_all_zlevels())
		total_coverage += 1

	needed_coverage = round(total_coverage * rand(4, 8) * 0.1, 1)

	name += ": [initial(demanded_area.name)]"
	description = replacetext(description, "%AREA_NAME%", initial(demanded_area.name))
	description = replacetext(description, "%AREA_COVERAGE%", needed_coverage)

	// scale the reward based on how big the area is, so you don't feel like you're wasting time
	// central primary hallway can have somewhere in the ballpark of 500 turfs
	// but something like the bar only sits around 100-200
	reward = max(reward * (needed_coverage / 100), CARGO_CRATE_VALUE)

/datum/bounty/patrol/print_required()
	return "[LAZYLEN(walked_turfs)]/[needed_coverage] meters"

/datum/bounty/patrol/can_claim()
	return LAZYLEN(walked_turfs) >= needed_coverage

/datum/bounty/patrol/on_selected(obj/item/card/id/id_card)
	tracker = AddComponent(/datum/component/connect_containers, id_card, list(COMSIG_MOVABLE_MOVED = PROC_REF(on_card_moved)))
	RegisterSignal(id_card, COMSIG_MOVABLE_MOVED, PROC_REF(on_card_moved))

/datum/bounty/patrol/on_reset(obj/item/card/id/id_card)
	stop_tracking(id_card)

/datum/bounty/patrol/proc/stop_tracking(obj/item/card/id/id_card)
	QDEL_NULL(tracker)
	UnregisterSignal(id_card, COMSIG_MOVABLE_MOVED)

/datum/bounty/patrol/proc/on_card_moved(atom/movable/moving, atom/old_loc, ...)
	SIGNAL_HANDLER

	var/turf/new_turf = get_turf(moving)
	if(!isfloorturf(new_turf) || new_turf == get_turf(old_loc) || new_turf.loc.type != demanded_area)
		return

	var/turf_id = "[new_turf.x],[new_turf.y],[new_turf.z]"
	// especially large rooms will allow you to retread the same turf multiple times
	// but particularly small rooms limit you to two counts - one going in, one going out
	if(LAZYACCESS(walked_turfs, turf_id) >= min(round(max_coverage / 25, 1), 2))
		return

	var/obj/item/card/id/id_card
	if(isliving(moving))
		var/mob/living/living_mover = moving
		id_card = living_mover.get_idcard()
	else if(isidcard(moving))
		id_card = moving
	if(isnull(id_card))
		id_card = locate() in moving.get_all_contents()

	if(id_card?.registered_account?.civilian_bounty != src)
		return

	LAZYADDASSOC(walked_turfs, turf_id, 1)
	var/progress = round(LAZYLEN(walked_turfs) / needed_coverage, 0.05)
	if(alerted == 0)
		alerted = 1
		id_card.registered_account.bank_card_talk("Patrol started. \
			Travel [needed_coverage] meters in the area to complete your patrol.", force = TRUE)
		return

	if(progress >= 0.25 && alerted != 2)
		alerted = 2
		id_card.registered_account.bank_card_talk("Patrol 25% complete.", force = TRUE)
		return

	if(progress >= 0.5 && alerted != 3)
		alerted = 3
		id_card.registered_account.bank_card_talk("Patrol 50% complete.", force = TRUE)
		return

	if(progress >= 0.75 && alerted != 4)
		alerted = 4
		id_card.registered_account.bank_card_talk("Patrol 75% complete.", force = TRUE)
		return

	if(progress >= 1.0 && alerted != 5)
		alerted = 5
		id_card.registered_account.bank_card_talk("Patrol complete. \
			Return to the bounty terminal to claim your reward.", force = TRUE)
		stop_tracking(id_card) // don't need this anymore
		return

/datum/bounty/item/contraband
	name = "Confiscated Contraband"
	description = "The Syndicate is constantly acting to subvert crewmates of Nanotrasen-affiliated stations. Ship us your latest batch of confiscated contraband."
	reward = CARGO_CRATE_VALUE * 4
	required_count = 5
	wanted_types = list(/obj/item = TRUE)

/datum/bounty/item/contraband/applies_to(obj/O)
	return HAS_TRAIT(O, TRAIT_CONTRABAND)
