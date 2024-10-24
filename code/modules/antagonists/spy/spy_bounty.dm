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
	var/name
	/// Help text for the bounty.
	/// Should include additional information about the bounty to assist the spy in figuring out what to do.
	/// Should be punctuated.
	/// IE: "Steal the captain's ID. It was last seen in the captain's office."
	var/help
	/// Difficult of the bounty, one of [SPY_DIFFICULTY_EASY], [SPY_DIFFICULTY_MEDIUM], [SPY_DIFFICULTY_HARD].
	/// Must be set to one of the possible bounties to be picked.
	var/difficulty = "unset"
	/// How long of a do-after must be completed by the Spy to turn in the bounty.
	var/theft_time = 2 SECONDS
	/// Probability that the stolen item will be sent to the black market instead of destroyed.
	/// Guaranteed if the item is indestructible.
	var/black_market_prob = 50
	/// Weight that the bounty will be selected.
	var/weight = 1

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
/datum/spy_bounty/proc/to_ui_data(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	return list(
		"name" = name,
		"help" = help,
		"difficulty" = difficulty,
		"reward" = reward_item.name,
		"claimed" = claimed,
		"can_claim" = can_claim(user),
	)

/// Check if the passed mob can claim this bounty.
/datum/spy_bounty/proc/can_claim(mob/user)
	SHOULD_BE_PURE(TRUE)
	return TRUE

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
		return // future todo : add some junk items for when we run out of items

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
	// SHOULD_BE_PURE(TRUE)
	return FALSE

/**
 * What is this bounty's "dupe protection key"?
 * This is used to determine if a duplicate of this bounty has been rolled before / in the last refresh.
 * You can check if a bounty has been duped by accessing the handler's claimed_bounties_from_last_pool or all_claimed_bounty_types list.
 *
 * * stealing - The item that was stolen.
 * * handler - The handler that is handling the bounty.
 *
 * Return a string key, what this uses for dupe protection.
 */
/datum/spy_bounty/proc/get_dupe_protection_key(atom/movable/stealing)
	return stealing.type

/**
 * Checks if the passed dupe key is a duplicate of an previously claimed bounty.
 *
 * * handler - The handler that is handling the bounty.
 * * dupe_key - The key to check for dupes
 * * dupe_prob - The probability of a dupe being allowed when checking all_claimed_bounty_types.
 * This allows you to have a chance that distant dupes allowed depending on how many times they've been done.
 *
 * Returns TRUE if the bounty is a dupe, FALSE if it is not.
 */
/datum/spy_bounty/proc/check_dupe(datum/spy_bounty_handler/handler, dupe_key, dupe_prob = 0)
	if(handler.claimed_bounties_from_last_pool[dupe_key])
		return TRUE
	if(prob(dupe_prob * handler.all_claimed_bounty_types[dupe_key]))
		return TRUE
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

	if(isitem(stealing) && stealing.loc == spy)
		// get it out of our inventory before we mess with it to prevent any weirdness.
		// bypasses nodrop - if you want, add a bespoke check for that higher up the chain
		spy.temporarilyRemoveItemFromInventory(stealing, force = TRUE)
		// also check for DROPDEL
		if(QDELETED(stealing))
			return

	// Don't mess with it while it's going away
	var/had_attack_hand_interaction = stealing.interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND
	stealing.interaction_flags_atom &= ~INTERACT_ATOM_ATTACK_HAND
	var/was_anchored = stealing.anchored
	stealing.anchored = TRUE
	// Add some pizzazz
	animate(stealing, time = 0.5 SECONDS, transform = stealing.transform.Scale(0.01), easing = CUBIC_EASING)

	if(isitem(stealing) && ((stealing.resistance_flags & INDESTRUCTIBLE) || prob(black_market_prob)))
		addtimer(CALLBACK(src, PROC_REF(send_to_black_market), stealing, had_attack_hand_interaction, was_anchored), 0.5 SECONDS)
	else
		addtimer(CALLBACK(src, PROC_REF(finish_cleanup), stealing), 0.5 SECONDS)

/**
 * Called when cleaning up a stolen atom that was NOT sent to the black market.
 *
 * * stealing - The item that was stolen.
 */
/datum/spy_bounty/proc/finish_cleanup(atom/movable/stealing)
	qdel(stealing)

/**
 * Handles putting the passed movable up on the black market.
 *
 * By the end of this proc, the item should either be deleted (if failure) or in nullspace (on the black market).
 *
 * * thing - The item to put up on the black market.
 */
/datum/spy_bounty/proc/send_to_black_market(atom/movable/thing, had_attack_hand_interaction, was_anchored)
	if(QDELETED(thing)) // Just in case anything does anything weird
		return FALSE

	///reset the appearance and all.
	if(had_attack_hand_interaction)
		thing.interaction_flags_atom |= INTERACT_ATOM_ATTACK_HAND
	thing.anchored = was_anchored
	thing.transform = thing.transform.Scale(10)
	thing.moveToNullspace()

	var/item_price
	switch(difficulty)
		if(SPY_DIFFICULTY_EASY)
			item_price = PAYCHECK_COMMAND * 2.5
		if(SPY_DIFFICULTY_MEDIUM)
			item_price = PAYCHECK_COMMAND * 5
		if(SPY_DIFFICULTY_HARD)
			item_price = PAYCHECK_COMMAND * 10

	item_price += rand(0, PAYCHECK_COMMAND * 5)
	if(thing.resistance_flags & INDESTRUCTIBLE)
		item_price *= 2

	var/datum/market_item/stolen_good/new_item = new(thing, item_price)

	return SSmarket.markets[/datum/market/blackmarket].add_item(new_item)

/// Steal an item
/datum/spy_bounty/objective_item
	/// Reference to an objective item datum that we want stolen.
	VAR_FINAL/datum/objective_item/desired_item
	/// Typecache of objective items that should not be selected.
	var/static/list/blacklisted_item_types = typecacheof(list(
		/datum/objective_item/steal/functionalai,
		/datum/objective_item/steal/nukedisc,
	))

/datum/spy_bounty/objective_item/can_claim(mob/user)
	return !(user.mind?.assigned_role.title in desired_item.excludefromjob)

/datum/spy_bounty/objective_item/get_dupe_protection_key(atom/movable/stealing)
	return desired_item.targetitem

/// Determines if the passed objective item is a reasonable, valid theft target.
/datum/spy_bounty/objective_item/proc/is_valid_objective_item(datum/objective_item/item)
	if(length(item.special_equipment) || item.difficulty <= 0 || item.difficulty >= 6)
		return FALSE
	if(is_type_in_typecache(item, blacklisted_item_types))
		return FALSE
	if(!item.exists_on_map)
		return TRUE
	var/list/all_valid_existing_things = list()
	for(var/obj/item/existing_thing as anything in GLOB.steal_item_handler.objectives_by_path[item.targetitem])
		var/turf/thing_turf = get_turf(existing_thing)
		if(isnull(thing_turf)) // nullspaced likely means it was stolen and is in the black market.
			continue
		if(!is_station_level(thing_turf.z) && !is_mining_level(thing_turf.z))
			continue
		if(HAS_TRAIT(existing_thing, TRAIT_ITEM_OBJECTIVE_BLOCKED))
			continue
		all_valid_existing_things += existing_thing

	if(!length(all_valid_existing_things))
		return FALSE
	return TRUE

/datum/spy_bounty/objective_item/init_bounty(datum/spy_bounty_handler/handler)
	var/list/valid_possible_items = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(check_dupe(handler, item.targetitem, 33))
			continue
		if(!is_valid_objective_item(item))
			continue
		// Determine difficulty. Has some overlap between the categories, which is OK
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

	for(var/datum/spy_bounty/objective_item/existing_bounty in handler.get_all_bounties())
		valid_possible_items -= existing_bounty.desired_item

	if(!length(valid_possible_items))
		return FALSE

	desired_item = pick(valid_possible_items)
	name = "[desired_item.name] [difficulty == SPY_DIFFICULTY_HARD ? "Grand ":""]Theft"
	help = "Steal [desired_item.name][desired_item.steal_hint ? ": [desired_item.steal_hint]" : "."]"
	return TRUE

/datum/spy_bounty/objective_item/is_stealable(atom/movable/stealing)
	return istype(stealing, desired_item.targetitem) \
		&& !HAS_TRAIT(stealing, TRAIT_ITEM_OBJECTIVE_BLOCKED) \
		&& desired_item.check_special_completion(stealing)

/datum/spy_bounty/objective_item/random_easy
	difficulty = SPY_DIFFICULTY_EASY
	weight = 4 // Increased due to there being many easy options

/datum/spy_bounty/objective_item/random_medium
	difficulty = SPY_DIFFICULTY_MEDIUM
	weight = 2 // Increased due to there being many medium options

/datum/spy_bounty/objective_item/random_hard
	difficulty = SPY_DIFFICULTY_HARD

/datum/spy_bounty/machine
	theft_time = 10 SECONDS

	/// What machine (typepath) we want to steal.
	var/obj/machinery/target_type
	/// What area (typepath) the desired machine is in.
	/// Can be pre-set for subtypes. If set, requires the machine to be in the location_type.
	/// If not set, picks a random machine from all areas it can currently be found in.
	var/area/location_type
	/// List of weakrefs to all machines of the target type when the bounty was initialized.
	var/list/original_options_weakrefs = list()

/datum/spy_bounty/machine/Destroy()
	original_options_weakrefs.Cut() // Just in case
	return ..()

/datum/spy_bounty/machine/get_dupe_protection_key(atom/movable/stealing)
	return target_type

/datum/spy_bounty/machine/send_to_black_market(obj/machinery/thing)
	if(!istype(thing.circuit, /obj/item/circuitboard))
		qdel(thing)
		return FALSE

	var/obj/item/circuitboard/selling = thing.circuit
	var/turf/machine_turf = get_turf(thing)

	// Sell the circuitboard, take the rest apart
	// This (should) handle any mobs inside as well
	thing.deconstruct(FALSE)
	if(!..(selling))
		return FALSE

	// Clean up leftover parts from deconstruction
	for(var/obj/structure/frame/leftover in machine_turf)
		qdel(leftover)
		break
	for(var/obj/item/stock_parts/part in machine_turf)
		if(prob(part.rating * 20))
			continue
		qdel(part)

	return TRUE

/datum/spy_bounty/machine/finish_cleanup(obj/machinery/stealing)
	stealing.dump_inventory_contents()
	return ..()

/datum/spy_bounty/machine/init_bounty(datum/spy_bounty_handler/handler)
	if(isnull(target_type))
		return FALSE

	// Blacklisting maintenance in general, as well as any areas that already have a bounty in them.
	var/list/blacklisted_areas = typecacheof(/area/station/maintenance)
	for(var/datum/spy_bounty/machine/existing_bounty in handler.get_all_bounties())
		blacklisted_areas[existing_bounty.location_type] = TRUE

	var/list/obj/machinery/all_possible = list()
	for(var/obj/machinery/found_machine as anything in SSmachines.get_machines_by_type_and_subtypes(target_type))
		if(!is_station_level(found_machine.z) && !is_mining_level(found_machine.z))
			continue
		var/area/found_machine_area = get_area(found_machine)
		if(is_type_in_typecache(found_machine_area, blacklisted_areas))
			continue
		if(!isnull(location_type) && !istype(found_machine_area, location_type))
			continue
		if(!(found_machine_area.area_flags & VALID_TERRITORY)) // only steal from valid station areas
			continue
		all_possible += found_machine

	if(!length(all_possible))
		return FALSE

	var/obj/machinery/machine = pick_n_take(all_possible)
	var/area/machine_area = get_area(machine)
	// Tracks the picked machine, as well as any other machines in the same area
	// (So they can be removed from the room but still count, for clever Spies)
	original_options_weakrefs += WEAKREF(machine)
	for(var/obj/machinery/other_machine as anything in all_possible)
		if(get_area(other_machine) == machine_area)
			original_options_weakrefs += WEAKREF(other_machine)

	location_type = machine_area.type
	name ||= "[machine.name] Burglary"
	help ||= "Steal \a [machine] found in [machine_area]."
	return TRUE

/datum/spy_bounty/machine/is_stealable(atom/movable/stealing)
	if(!istype(stealing, target_type))
		return FALSE
	if(WEAKREF(stealing) in original_options_weakrefs)
		return TRUE
	if(istype(get_area(stealing), location_type))
		return TRUE
	return FALSE

/datum/spy_bounty/machine/random
	/// List of all machines we can randomly draw from
	var/list/random_options = list()

/datum/spy_bounty/machine/random/init_bounty(datum/spy_bounty_handler/handler)
	var/list/options = random_options.Copy()
	for(var/datum/spy_bounty/machine/existing_bounty in handler.get_all_bounties())
		options -= existing_bounty.target_type

	for(var/remaining_option in options)
		if(check_dupe(handler, remaining_option, 33))
			options -= remaining_option

	if(!length(options))
		return FALSE

	target_type = pick(options)
	return ..()

/datum/spy_bounty/machine/random/easy
	difficulty = SPY_DIFFICULTY_EASY
	weight = 4 // Increased due to there being many easy options
	random_options = list(
		/obj/machinery/computer/operating,
		/obj/machinery/computer/order_console/mining,
		/obj/machinery/computer/records/medical,
		/obj/machinery/cryo_cell,
		/obj/machinery/fax, // Completely random, wild card
		/obj/machinery/hydroponics/constructable,
		/obj/machinery/medical_kiosk,
		/obj/machinery/microwave,
		/obj/machinery/oven,
		/obj/machinery/recharge_station,
		/obj/machinery/vending/boozeomat,
		/obj/machinery/vending/medical,
		/obj/machinery/vending/wardrobe,
	)

/datum/spy_bounty/machine/random/medium
	difficulty = SPY_DIFFICULTY_MEDIUM
	weight = 4 // Increased due to there being many medium options
	random_options = list(
		/obj/machinery/chem_dispenser,
		/obj/machinery/computer/bank_machine,
		/obj/machinery/computer/camera_advanced/xenobio,
		/obj/machinery/computer/cargo, // This includes request-only ones in the public lobby
		/obj/machinery/computer/crew,
		/obj/machinery/computer/prisoner/management,
		/obj/machinery/computer/rdconsole,
		/obj/machinery/computer/records/security,
		/obj/machinery/computer/scan_consolenew,
		/obj/machinery/computer/security, // Requires breaking into a sec checkpoint, but not too hard, many are never visited
		/obj/machinery/dna_scannernew,
		/obj/machinery/mecha_part_fabricator,
	)

/datum/spy_bounty/machine/engineering_emitter
	difficulty = SPY_DIFFICULTY_MEDIUM
	target_type = /obj/machinery/power/emitter
	location_type = /area/station/engineering/supermatter/

/datum/spy_bounty/machine/engineering_emitter/can_claim(mob/user)
	return !(user.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_ENGINEERING)

/datum/spy_bounty/machine/random/hard
	difficulty = SPY_DIFFICULTY_HARD
	random_options = list(
		/obj/machinery/computer/accounting,
		/obj/machinery/computer/communications,
		/obj/machinery/computer/upload,
		/obj/machinery/modular_computer/preset/id,
	)

/datum/spy_bounty/machine/random/hard/can_claim(mob/user) // These would all be too easy with command level access
	return !(user.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)

/datum/spy_bounty/machine/random/hard/ai_sat_teleporter
	random_options = list(
		/obj/machinery/teleport,
		/obj/machinery/computer/teleporter,
	)
	location_type = /area/station/ai_monitored/aisat

/// Subtype for a bounty that targets a specific crew member
/datum/spy_bounty/targets_person
	difficulty = SPY_DIFFICULTY_HARD
	theft_time = 12 SECONDS
	/// Weakref to the mob target of the bounty
	VAR_FINAL/datum/weakref/target_ref

/datum/spy_bounty/targets_person/get_dupe_protection_key(atom/movable/stealing)
	// Prevents the same player from being selected twice, but if they're straight up gone, whatever
	return REF(target_ref.resolve() || stealing)

/datum/spy_bounty/targets_person/can_claim(mob/user)
	return !IS_WEAKREF_OF(user, target_ref)

/datum/spy_bounty/targets_person/init_bounty(datum/spy_bounty_handler/handler)
	var/list/mob/possible_targets = list()
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		var/mob/living/real_target = crew_mind.current
		// Ideally we want it to be a player, but we don't care if they DC after being selected
		if(!istype(real_target) || isnull(GET_CLIENT(real_target)))
			continue
		if(check_dupe(handler, REF(real_target), 50))
			continue
		if(!is_valid_crewmember(real_target))
			continue
		possible_targets += real_target

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
		if(!INCAPACITATED_IGNORING(target, INCAPABLE_RESTRAINTS|INCAPABLE_STASIS))
			return FALSE
		if(find_desired_thing(target))
			return TRUE
	return FALSE

/datum/spy_bounty/targets_person/some_item/clean_up_stolen_item(atom/movable/stealing, mob/living/spy)
	if(IS_WEAKREF_OF(stealing, target_original_desired_ref))
		return ..()

	ASSERT(ishuman(stealing), "[type] called clean_up_stolen_item with something that isn't a human and isn't the original item.")

	do_sparks(2, FALSE, stealing)
	var/mob/living/carbon/human/stolen_from = stealing
	var/obj/item/real_stolen_item = find_desired_thing(stealing)
	stolen_from.Unconscious(10 SECONDS)
	to_chat(stolen_from, span_warning("You feel something missing where your [real_stolen_item.name] once was."))
	return ..(real_stolen_item, spy)

/datum/spy_bounty/targets_person/some_item/target_found(mob/crewmember)
	var/obj/item/desired_thing = find_desired_thing(crewmember)
	target_original_desired_ref = WEAKREF(desired_thing)
	name = "[crewmember.real_name]'s [desired_thing.name]"
	help = "Steal [desired_thing] from [crewmember.real_name]. \
		You can accomplish this via brute force, or by scanning them with your uplink while they are incapacitated."
	return TRUE

/// Finds the desired item type in the target crewmember.
/datum/spy_bounty/targets_person/some_item/proc/find_desired_thing(mob/living/carbon/human/crewmember)
	return locate(desired_type) in crewmember.get_all_gear()

// Steal someone's ID card
/datum/spy_bounty/targets_person/some_item/id
	desired_type = /obj/item/card/id/advanced

/datum/spy_bounty/targets_person/some_item/id/find_desired_thing(mob/living/carbon/human/crewmember)
	for(var/obj/item/card/id/advanced/id in crewmember.get_all_gear())
		if(id.registered_account?.account_id == crewmember.account_id)
			return id

	return null

/datum/spy_bounty/targets_person/some_item/id/target_found(mob/crewmember)
	. = ..()
	name = "[crewmember.real_name]'s ID Card"

// Steal someone's PDA
/datum/spy_bounty/targets_person/some_item/pda
	desired_type = /obj/item/modular_computer/pda

/datum/spy_bounty/targets_person/some_item/pda/find_desired_thing(mob/living/carbon/human/crewmember)
	for(var/obj/item/modular_computer/pda/pda in crewmember.get_all_gear())
		if(pda.saved_identification == crewmember.real_name)
			return pda

	return null

/datum/spy_bounty/targets_person/some_item/pda/target_found(mob/crewmember)
	. = ..()
	name = "[crewmember.real_name]'s PDA"

// Steal someone's heirloom
/datum/spy_bounty/targets_person/some_item/heirloom
	desired_type = /obj/item
	black_market_prob = 100

/datum/spy_bounty/targets_person/some_item/heirloom/find_desired_thing(mob/living/crewmember)
	var/datum/quirk/item_quirk/family_heirloom/quirk = crewmember.get_quirk(/datum/quirk/item_quirk/family_heirloom)
	return quirk?.heirloom?.resolve()

/datum/spy_bounty/targets_person/some_item/heirloom/target_found(mob/crewmember)
	. = ..()
	name = "[crewmember.real_name]'s heirloom"

// Steal a limb or organ off someone
/datum/spy_bounty/targets_person/some_item/limb_or_organ
	weight = 4 // lots to pick from here

/datum/spy_bounty/targets_person/some_item/limb_or_organ/init_bounty(datum/spy_bounty_handler/handler)
	desired_type = pick(
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right,
		/obj/item/organ/stomach,
		/obj/item/organ/appendix,
		/obj/item/organ/liver,
		/obj/item/organ/eyes,
	)
	return ..()

/datum/spy_bounty/targets_person/some_item/limb_or_organ/find_desired_thing(mob/living/carbon/human/crewmember)
	if(ispath(desired_type, /obj/item/bodypart))
		return locate(desired_type) in crewmember.bodyparts
	if(ispath(desired_type, /obj/item/organ))
		return locate(desired_type) in crewmember.organs
	return null

/datum/spy_bounty/some_bot
	theft_time = 10 SECONDS
	black_market_prob = 0
	/// What typepath of bot we want to steal.
	var/mob/living/simple_animal/bot/bot_type
	/// Weakref to the bot we want to steal.
	VAR_FINAL/datum/weakref/target_bot_ref

/datum/spy_bounty/some_bot/get_dupe_protection_key(atom/movable/stealing)
	return bot_type

/datum/spy_bounty/some_bot/finish_cleanup(mob/living/simple_animal/bot/stealing)
	if(stealing.client)
		to_chat(stealing, span_deadsay("You've been stolen! You are shipped off to the black market and taken apart for spare parts..."))
		stealing.investigate_log("stole by a spy (and deleted)", INVESTIGATE_DEATHS)
		stealing.ghostize()
	return ..()

/datum/spy_bounty/some_bot/init_bounty(datum/spy_bounty_handler/handler)
	for(var/datum/spy_bounty/some_bot/existing_bounty in handler.get_all_bounties())
		var/mob/living/simple_animal/bot/existing_bot_type = existing_bounty.bot_type
		// ensures we don't get two similar bounties.
		// may occasionally cast a wider net than we'd desire, but it's not that bad.
		if(ispath(bot_type, initial(existing_bot_type.parent_type)))
			return FALSE

	var/list/mob/living/possible_bots = list()
	for(var/mob/living/bot as anything in GLOB.bots_list)
		if(!is_station_level(bot.z) && !is_mining_level(bot.z))
			continue
		if(!istype(bot, bot_type))
			continue
		possible_bots += bot

	if(!length(possible_bots))
		return FALSE

	var/mob/living/picked = pick(possible_bots)
	target_bot_ref = WEAKREF(picked)
	name ||= "[picked.name] Abduction"
	help ||= "Abduct the station's robot assistant [picked.name]."
	return TRUE

/datum/spy_bounty/some_bot/is_stealable(atom/movable/stealing)
	return IS_WEAKREF_OF(stealing, target_bot_ref)

/datum/spy_bounty/some_bot/beepsky
	difficulty = SPY_DIFFICULTY_MEDIUM // gotta get him to stand still
	bot_type = /mob/living/simple_animal/bot/secbot/beepsky/officer
	help = "Abduct Officer Beepsky - commonly found patrolling the station. \
		Watch out, they may not take kindly to being scanned."

/datum/spy_bounty/some_bot/ofitser
	difficulty = SPY_DIFFICULTY_EASY
	bot_type = /mob/living/simple_animal/bot/secbot/beepsky/ofitser
	help = "Abduct Prison Ofitser - commonly found guarding the Gulag."

/datum/spy_bounty/some_bot/armsky
	difficulty = SPY_DIFFICULTY_HARD
	bot_type = /mob/living/simple_animal/bot/secbot/beepsky/armsky
	help = "Abduct Sergeant-At-Armsky - commonly found guarding the station's Armory."

/datum/spy_bounty/some_bot/pingsky
	difficulty = SPY_DIFFICULTY_HARD
	bot_type = /mob/living/simple_animal/bot/secbot/pingsky
	help = "Abduct Officer Pingsky - commonly found protecting the station's AI."

/datum/spy_bounty/some_bot/scrubbs
	difficulty = SPY_DIFFICULTY_EASY
	bot_type = /mob/living/basic/bot/cleanbot/medbay
	help = "Abduct Scrubbs, MD - commonly found mopping up blood in Medbay."

/datum/spy_bounty/some_bot/scrubbs/can_claim(mob/user)
	return !(user.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
