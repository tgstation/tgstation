/**
 * ## Spy Bounty
 *
 * A datum used to track a single spy bounty.
 * Not a singleton - whenever bounties are re-rolled, the entire list is deleted and new bounty datums are instantiated.
 *
 * When bounties are completed, they are also not deleted, but instead marked as claimed.
 */
/datum/spy_bounty
	/// The name of the bounty.
	/// Should be a short description without punctuation.
	/// IE: "Steal the captain's ID"
	var/name = "Do something"
	/// Help text for the bounty.
	/// Should include additional information about the bounty to assist the spy in figuring out what to do.
	/// Should be punctuated.
	/// IE: "Steal the captain's ID. It was last seen in the captain's office."
	var/help = "Do something to someone in somewhere."
	/// Difficult of the bounty, one of [SPY_DIFFICULTY_EASY], [SPY_DIFFICULTY_MEDIUM], [SPY_DIFFICULTY_HARD].
	var/difficulty = "unset"
	/// How long of a do-after must be completed by the Spy to turn in the bounty.
	var/theft_time = 2 SECONDS

	/// Whether the bounty's been fully initialized. If this is not set, the bounty will be rerolled.
	VAR_FINAL/initalized = FALSE
	/// Whether the bounty has been completed.
	VAR_FINAL/claimed = FALSE
	/// What uplink item the bounty will reward on completion.
	VAR_FINAL/datum/uplink_item/reward_item

/datum/spy_bounty/New(datum/spy_bounty_handler/handler)
	if(!init_bounty(handler))
		return

	initalized = TRUE
	select_reward(handler)

/// Helper that translates the bounty into UI data for TGUI
/datum/spy_bounty/proc/to_ui_data()
	return list(
		"name" = name,
		"help" = help,
		"difficulty" = difficulty,
		"reward" = reward_item.name, // melbert todo : description as tooltip?
		"claimed" = claimed,
	)

/**
 * Initializes the bounty, setting up targets and etc.
 *
 * * handler - The bounty handler that is creating this bounty.
 *
 * Returning FALSE will cancel initialization and force it to reroll the bounty.
 */
/datum/spy_bounty/proc/init_bounty(datum/spy_bounty_handler/handler)
	return FALSE

/// Selects what uplink item the bounty will reward on completion.
/datum/spy_bounty/proc/select_reward(datum/spy_bounty_handler/handler)
	var/list/loot_pool = handler.possible_uplink_items[difficulty]

	if(!length(loot_pool))
		reward_item = /datum/uplink_item/bundles_tc/telecrystal
		return // melbert todo : add some junk items for when we run out of items (for campbell)

	reward_item = pick(loot_pool)
	if(prob(80))
		loot_pool -= reward_item

/**
 * Checks if the passed movable is a valid target for this bounty.
 *
 * * stealing - The movable to check.
 *
 * Returning FALSE simply means that the passed movable is not valid for this bounty.
 */
/datum/spy_bounty/proc/is_stealable(atom/movable/stealing)
	SHOULD_BE_PURE(TRUE)
	return FALSE

/**
 * Called when the bounty is completed, to handle how the stolen item is "stolen".
 *
 * By default, stolen items are simply deleted.
 *
 * * stealing - The item that was stolen.
 * * spy - The spy that stole the item.
 */
/datum/spy_bounty/proc/clean_up_stolen_item(atom/movable/stealing, mob/living/spy)
	do_sparks(3, FALSE, stealing)

	if(stealing.resistance_flags & INDESTRUCTIBLE)
		return // melbert todo : how to handle indestructible items (put them on the black market?)

	// Don't mess with it while it's going away
	stealing.interaction_flags_atom &= ~INTERACT_ATOM_ATTACK_HAND
	stealing.anchored = TRUE
	// Add some pizzazz
	animate(stealing, time = 0.5 SECONDS, transform = matrix(stealing.transform).Scale(0.01), easing = CUBIC_EASING)
	QDEL_IN(stealing, 0.5 SECONDS)

/// Steal an item
/datum/spy_bounty/item
	difficulty = SPY_DIFFICULTY_EASY // melbert todo : re-add objective item difficulty

	/// Reference to an objective item datum that we want stolen.
	VAR_FINAL/datum/objective_item/desired_item
	/// List of typepaths disallowed from being selected as the desired item.
	var/static/list/blacklisted_item_types = typecacheof(list(
		/obj/item/aicard,
		/obj/item/disk/nuclear,
	))

/datum/spy_bounty/item/init_bounty(datum/spy_bounty_handler/handler)
	var/list/valid_possible_items = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(length(item.special_equipment) || item.difficulty <= 0)
			continue
		if(!item.target_exists() || is_type_in_typecache(item.targetitem, blacklisted_item_types))
			continue
		switch(difficulty)
			if(SPY_DIFFICULTY_EASY)
				if(item.difficulty >= 3)
					continue
			if(SPY_DIFFICULTY_MEDIUM)
				if(item.difficulty <= 2 || item.difficulty >= 5)
					continue
			if(SPY_DIFFICULTY_HARD)
				if(item.difficulty <= 3)
					continue
		valid_possible_items += item

	for(var/datum/spy_bounty/item/existing_bounty in handler.get_all_bounties())
		valid_possible_items -= existing_bounty.desired_item

	if(!length(valid_possible_items))
		return FALSE

	desired_item = pick(valid_possible_items)
	name = "Steal [desired_item]"
	help = desired_item.steal_hint || "Steal [desired_item]."
	return TRUE

/datum/spy_bounty/item/is_stealable(atom/movable/stealing)
	return istype(stealing, desired_item.targetitem) && desired_item.check_special_completion(stealing)

/datum/spy_bounty/item/medium
	difficulty = SPY_DIFFICULTY_MEDIUM

/datum/spy_bounty/item/hard
	difficulty = SPY_DIFFICULTY_HARD

/datum/spy_bounty/machine
	difficulty = SPY_DIFFICULTY_MEDIUM // melbert todo : change based on location
	theft_time = 10 SECONDS

	/// What area (typepath) the desired machine is in.
	VAR_FINAL/area/location_type
	/// What machine (typepath) we want to steal.
	VAR_FINAL/obj/machinery/target_type

/datum/spy_bounty/machine/init_bounty(datum/spy_bounty_handler/handler)
	target_type = pick(
		/obj/machinery/computer/bank_machine,
		/obj/machinery/computer/communications,
		/obj/machinery/computer/crew,
		/obj/machinery/computer/security,
		/obj/machinery/computer/upload,
	)

	var/list/existing_areas = list()
	for(var/datum/spy_bounty/machine/existing_bounty in handler.get_all_bounties())
		existing_areas[existing_bounty.location_type] = TRUE

	var/list/obj/machinery/all_possible = list()
	for(var/obj/machinery/found_machine as anything in SSmachines.get_machines_by_type_and_subtypes(target_type))
		if(!is_station_level(found_machine.z))
			continue
		var/area/found_machine_area = get_area(found_machine)
		if(existing_areas[found_machine_area.type])
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
	theft_time = 12 SECONDS
	/// Weakref to the mob target of the bounty
	VAR_FINAL/datum/weakref/target_ref

/datum/spy_bounty/targets_person/init_bounty(datum/spy_bounty_handler/handler)
	var/list/mob/possible_targets = list()
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		if(is_valid_crewmember(crew_mind.current))
			possible_targets += crew_mind.current

	for(var/datum/spy_bounty/targets_person/existing_bounty in handler.get_all_bounties())
		possible_targets -= existing_bounty.target_ref.resolve()

	if(!length(possible_targets))
		return FALSE

	var/mob/picked = pick(possible_targets)
	if(target_found(picked))
		target_ref = WEAKREF(picked)
		return TRUE

	return FALSE

/**
 * Ran on every single member of the crew to determine if they are a valid target.
 *
 * * crewmember - The person to check.
 *
 * Returning FALSE will exclude them from the list of possible targets.
 */
/datum/spy_bounty/targets_person/proc/is_valid_crewmember(mob/crewmember)
	return FALSE

/**
 * Ran when a valid target is selected for the bounty.
 *
 * * crewmember - The person that was selected as the target.
 *
 * Returning FALSE will stop the bounty from being finalized, this can be used for last minute checks.
 */
/datum/spy_bounty/targets_person/proc/target_found(mob/crewmember)
	return FALSE

/// Subtype for a bounty that targets a specific crew member and a specific item on them
/datum/spy_bounty/targets_person/some_item
	/// Typepath of the item we want from the target
	var/obj/item/desired_type
	/// Weakref to the item that matches our desired type within the target at the time of bounty creation
	VAR_FINAL/datum/weakref/target_original_desired_ref

/datum/spy_bounty/targets_person/some_item/is_valid_crewmember(mob/living/carbon/human/crewmember)
	return istype(crewmember) && find_desired_thing(crewmember)

/datum/spy_bounty/targets_person/some_item/is_stealable(atom/movable/stealing)
	if(IS_WEAKREF_OF(stealing, target_original_desired_ref))
		return TRUE
	if(IS_WEAKREF_OF(stealing, target_ref))
		var/mob/living/carbon/human/target = stealing
		if(!target.incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
			return FALSE
		if(find_desired_thing(target))
			return TRUE
	return FALSE

/datum/spy_bounty/targets_person/some_item/clean_up_stolen_item(atom/movable/stealing, mob/living/spy)
	if(IS_WEAKREF_OF(stealing, target_original_desired_ref))
		return ..()

	do_sparks(2, FALSE, stealing)
	var/mob/living/carbon/human/stolen_from = stealing
	var/obj/item/real_stolen_item = find_desired_thing(stealing)
	stolen_from.Unconscious(10 SECONDS)
	to_chat(stolen_from, span_warning("You feel something missing where your [real_stolen_item.name] once was."))
	qdel(real_stolen_item)

/datum/spy_bounty/targets_person/some_item/target_found(mob/crewmember)
	var/obj/item/desired_thing = find_desired_thing(crewmember)
	target_original_desired_ref = WEAKREF(desired_thing)
	name = "Steal [crewmember.real_name]'s [desired_thing.name]"
	help = "Steal [desired_thing] from [crewmember.real_name]. \
		You can accomplish this via brute force, or by scanning them with your uplink while they are incapacitated."
	return TRUE

/// Finds the desired item type in the target crewmember.
/datum/spy_bounty/targets_person/some_item/proc/find_desired_thing(mob/living/carbon/human/crewmember)
	return (locate(desired_type) in crewmember) || (locate(desired_type) in crewmember.back)

// Steal someone's ID card
/datum/spy_bounty/targets_person/some_item/id
	desired_type = /obj/item/card/id/advanced // melbert todo : should have logic to ensure it gets their actual ID

// Steal someone's PDA
/datum/spy_bounty/targets_person/some_item/pda
	desired_type = /obj/item/modular_computer/pda // melbert todo : should have logic to ensure it gets their actual PDA

// Steal someone's heirloom
/datum/spy_bounty/targets_person/some_item/heirloom
	desired_type = /obj/item

/datum/spy_bounty/targets_person/some_item/heirloom/is_valid_crewmember(mob/living/carbon/human/crewmember)
	return ..() && crewmember.has_quirk(/datum/quirk/item_quirk/family_heirloom)

/datum/spy_bounty/targets_person/some_item/heirloom/find_desired_thing(mob/living/carbon/human/crewmember)
	var/datum/quirk/item_quirk/family_heirloom/quirk = crewmember.get_quirk(/datum/quirk/item_quirk/family_heirloom)
	return quirk.heirloom?.resolve()

/datum/spy_bounty/targets_person/some_item/heirloom/target_found(mob/crewmember)
	var/obj/item/desired_thing = find_desired_thing(crewmember)
	target_original_desired_ref = WEAKREF(desired_thing)
	name = "Steal [crewmember.real_name]'s heirloom [desired_thing.name]"
	help = "Steal [desired_thing] from [crewmember.real_name]. \
		You can accomplish this via brute force, or by scanning them with your uplink while they are incapacitated."
	return TRUE

// Steal a limb or organ off someone
/datum/spy_bounty/targets_person/some_item/limb_or_organ

/datum/spy_bounty/targets_person/some_item/limb_or_organ/init_bounty(datum/spy_bounty_handler/handler)
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

/datum/spy_bounty/targets_person/some_item/limb_or_organ/find_desired_thing(mob/living/carbon/human/crewmember)
	if(ispath(desired_type, /obj/item/bodypart))
		return locate(desired_type) in crewmember.bodyparts
	if(ispath(desired_type, /obj/item/organ))
		return locate(desired_type) in crewmember.organs
	return null
