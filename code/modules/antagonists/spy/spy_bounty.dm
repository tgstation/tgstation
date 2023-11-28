/datum/spy_bounty
	var/name = "Do something"
	var/help = "Do something to someone in somewhere."
	var/difficulty = "unset"
	var/theft_time = 2 SECONDS
	VAR_FINAL/initalized = FALSE
	VAR_FINAL/claimed = FALSE
	VAR_FINAL/datum/uplink_item/reward_item

/datum/spy_bounty/New(datum/spy_bounty_handler/handler)
	. = ..()
	if(init_bounty(handler))
		initalized = TRUE
		select_reward(handler)

/datum/spy_bounty/proc/to_ui_data()
	return list(
		"name" = name,
		"help" = help,
		"difficulty" = difficulty,
		"reward" = reward_item.name,
		"claimed" = claimed,
	)

/datum/spy_bounty/proc/init_bounty(datum/spy_bounty_handler/handler)
	return FALSE

/datum/spy_bounty/proc/select_reward(datum/spy_bounty_handler/handler)
	return

/datum/spy_bounty/proc/is_stealable(atom/movable/stealing)
	return FALSE

/datum/spy_bounty/proc/clean_up_stolen_item(atom/stealing, mob/living/spy)
	qdel(stealing)

/// Steal an item
/datum/spy_bounty/item
	difficulty = SPY_DIFFICULTY_EASY
	VAR_FINAL/datum/objective_item/desired_item

/datum/spy_bounty/item/init_bounty(datum/spy_bounty_handler/handler)
	var/list/valid_possible_items = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(length(item.special_equipment))
			continue
		if(!item.target_exists())
			continue
		valid_possible_items += item

	if(!length(valid_possible_items))
		return FALSE
	desired_item = pick(valid_possible_items)
	name = "Steal [desired_item]"
	help = "Steal [desired_item]."
	return TRUE

/datum/spy_bounty/item/is_stealable(atom/movable/stealing)
	return istype(stealing, desired_item.targetitem) && desired_item.check_special_completion(stealing)

/datum/spy_bounty/machine
	difficulty = SPY_DIFFICULTY_MEDIUM
	theft_time = 10 SECONDS
	VAR_FINAL/area/location_type
	VAR_FINAL/obj/machinery/target_type

	var/static/list/possible_machines = list(
		/obj/machinery/computer/communications,
		/obj/machinery/computer/security,
	)

/datum/spy_bounty/machine/init_bounty(datum/spy_bounty_handler/handler)
	target_type = pick(possible_machines)

	var/list/obj/machinery/all_possible = list()
	for(var/obj/machinery/found_machine as anything in SSmachines.get_machines_by_type_and_subtypes(target_type))
		if(!is_station_level(found_machine.z))
			continue
		all_possible += found_machine

	if(!length(all_possible))
		return FALSE

	var/obj/machinery/machine = pick(all_possible)
	var/area/machine_area = get_area(machine)
	location_type = machine_area.type
	name = "Steal \the [machine_area]'s [machine.name]"
	help = "Steal [machine], found in [machine_area]."
	return TRUE

/datum/spy_bounty/machine/is_stealable(atom/movable/stealing)
	if(!istype(stealing, target_type))
		return FALSE

	if(!istype(get_area(stealing), location_type))
		return FALSE

	return TRUE

/// Subtype for a bounty that targets a specific crew member
/datum/spy_bounty/targets_person
	difficulty = SPY_DIFFICULTY_HARD
	VAR_FINAL/datum/weakref/target_ref

/datum/spy_bounty/targets_person/init_bounty(datum/spy_bounty_handler/handler)
	var/list/mob/possible_targets = list()
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		if(is_valid_crewmember(crew_mind.current))
			possible_targets += crew_mind.current

	if(!length(possible_targets))
		return FALSE

	var/mob/picked = pick(possible_targets)
	if(target_found(picked))
		target_ref = WEAKREF(picked)
		return TRUE

	return FALSE

/datum/spy_bounty/targets_person/proc/is_valid_crewmember(mob/crewmember)
	return FALSE

/datum/spy_bounty/targets_person/proc/target_found(mob/crewmember)
	return FALSE

/datum/spy_bounty/targets_person/limb_or_organ
	/// Typepath of the item we want from the target
	VAR_FINAL/obj/item/desired_type
	/// Weakref to the item that matches our desired type within the target at the time of bounty creation
	VAR_FINAL/datum/weakref/target_original_desired_ref

/datum/spy_bounty/targets_person/limb_or_organ/init_bounty(datum/spy_bounty_handler/handler)
	desired_type = pick(
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/eyes,
	)
	return ..()

/datum/spy_bounty/targets_person/limb_or_organ/is_valid_crewmember(mob/living/carbon/human/crewmember)
	return istype(crewmember) && find_desired_thing(crewmember)

/datum/spy_bounty/targets_person/limb_or_organ/target_found(mob/living/carbon/human/crewmember)
	var/obj/item/desired_part = find_desired_thing(crewmember)
	target_original_desired_ref = WEAKREF(desired_part)

	name = "Steal [crewmember.real_name]'s [desired_part]"
	help = "Steal [desired_part] from [crewmember.real_name]. \
		You can do accomplish this via brute force, or simply by hitting them with your uplink while they are incapacitated."
	return TRUE

/datum/spy_bounty/targets_person/limb_or_organ/is_stealable(atom/movable/stealing)
	if(IS_WEAKREF_OF(stealing, target_original_desired_ref))
		return TRUE
	if(IS_WEAKREF_OF(stealing, target_ref))
		var/mob/living/carbon/human/target = stealing
		if(!target.incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
			return FALSE
		if(find_desired_thing(target))
			return TRUE
	return FALSE

/datum/spy_bounty/targets_person/limb_or_organ/clean_up_stolen_item(atom/stealing, mob/living/spy)
	if(IS_WEAKREF_OF(stealing, target_original_desired_ref))
		qdel(stealing)

	else
		var/obj/item/real_stolen_item = find_desired_thing(stealing)
		qdel(real_stolen_item)

/datum/spy_bounty/targets_person/limb_or_organ/proc/find_desired_thing(mob/living/carbon/human/crewmember)
	if(ispath(desired_type, /obj/item/bodypart))
		return locate(desired_type) in crewmember.bodyparts
	if(ispath(desired_type, /obj/item/organ))
		return locate(desired_type) in crewmember.organs
