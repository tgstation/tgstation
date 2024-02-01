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
 * Called when the bounty is completed, to handle how the stolen item is "stolen".
 *
 * By default, stolen items are simply deleted.
 *
 * * stealing - The item that was stolen.
 * * spy - The spy that stole the item.
 */
/datum/spy_bounty/proc/clean_up_stolen_item(atom/movable/stealing, mob/living/spy)
	do_sparks(3, FALSE, stealing)

	// Don't mess with it while it's going away
	stealing.interaction_flags_atom &= ~INTERACT_ATOM_ATTACK_HAND
	stealing.anchored = TRUE
	// Add some pizzazz
	animate(stealing, time = 0.5 SECONDS, transform = matrix(stealing.transform).Scale(0.01), easing = CUBIC_EASING)

	if((stealing.resistance_flags & INDESTRUCTIBLE) || prob(black_market_prob))
		addtimer(CALLBACK(src, PROC_REF(send_to_black_market), stealing), 0.5 SECONDS)
	else
		QDEL_IN(stealing, 0.5 SECONDS)

/**
 * Handles putting the passed movable up on the black market.
 *
 * By the end of this proc, the item should either be deleted (if failure) or in nullspace (on the black market).
 *
 * * thing - The item to put up on the black market.
 */
/datum/spy_bounty/proc/send_to_black_market(atom/movable/thing)
	if(QDELETED(thing)) // Just in case anything does anything weird
		return FALSE

	thing.interaction_flags_atom = initial(thing.interaction_flags_atom)
	thing.anchored = initial(thing.anchored)
	thing.moveToNullspace()

	var/datum/market_item/new_item = new()
	new_item.item = thing
	new_item.name = "Stolen [thing.name]"
	new_item.desc = "A [thing.name], stolen from somewhere on the station. Whoever owned it probably wouldn't be happy to see it here."
	new_item.category = "Fenced Goods"
	new_item.stock = 1
	new_item.availability_prob = 100

	switch(difficulty)
		if(SPY_DIFFICULTY_EASY)
			new_item.price = PAYCHECK_COMMAND * 2.5
		if(SPY_DIFFICULTY_MEDIUM)
			new_item.price = PAYCHECK_COMMAND * 5
		if(SPY_DIFFICULTY_HARD)
			new_item.price = PAYCHECK_COMMAND * 10

	new_item.price += rand(0, PAYCHECK_COMMAND * 5)
	if(thing.resistance_flags & INDESTRUCTIBLE)
		new_item.price *= 2

	return SSblackmarket.markets[/datum/market/blackmarket].add_item(new_item)

/// Steal an item
/datum/spy_bounty/item

	/// Reference to an objective item datum that we want stolen.
	VAR_FINAL/datum/objective_item/desired_item
	/// Typecache of objective items that should not be selected.
	var/static/list/blacklisted_item_types = typecacheof(list(
		/datum/objective_item/steal/functionalai,
		/datum/objective_item/steal/nukedisc,
	))

/datum/spy_bounty/item/can_claim(mob/user)
	return !(user.mind?.assigned_role.title in desired_item.excludefromjob)

/datum/spy_bounty/item/init_bounty(datum/spy_bounty_handler/handler)
	var/list/valid_possible_items = list()
	for(var/datum/objective_item/item as anything in GLOB.possible_items)
		if(length(item.special_equipment) || item.difficulty <= 0 || item.difficulty >= 6)
			continue
		if(is_type_in_typecache(item, blacklisted_item_types))
			continue
		if(!item.target_exists())
			continue
		// Has some overlap, which is fine
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
	name = "[capitalize(format_text(desired_item.name))] [difficulty == SPY_DIFFICULTY_HARD ? "Grand ":""]Theft"
	help = "Steal any [desired_item][desired_item.steal_hint ? ": [desired_item.steal_hint]" : "."]"
	return TRUE

/datum/spy_bounty/item/is_stealable(atom/movable/stealing)
	return istype(stealing, desired_item.targetitem) && desired_item.check_special_completion(stealing)

/datum/spy_bounty/item/random_easy
	difficulty = SPY_DIFFICULTY_EASY
	weight = 4 // Increased due to there being many easy options

/datum/spy_bounty/item/random_medium
	difficulty = SPY_DIFFICULTY_MEDIUM
	weight = 2 // Increased due to there being many medium options

/datum/spy_bounty/item/random_hard
	difficulty = SPY_DIFFICULTY_HARD

/datum/spy_bounty/machine
	theft_time = 10 SECONDS

	/// What machine (typepath) we want to steal.
	var/obj/machinery/target_type
	/// What area (typepath) the desired machine is in.
	/// Can be pre-set for subtypes. If set, requires the machine to be in the location_type.
	/// If not set, picks a random machine from all areas it can currently be found in.
	var/area/location_type

/datum/spy_bounty/machine/send_to_black_market(obj/machinery/thing)
	if(!istype(thing.circuit, /obj/item/circuitboard))
		qdel(thing)
		return FALSE

	var/obj/item/circuitboard/selling = thing.circuit
	var/turf/machine_turf = get_turf(thing)

	// Sell the circuitboard, take the rest apart
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

/datum/spy_bounty/machine/init_bounty(datum/spy_bounty_handler/handler)
	if(isnull(target_type))
		return FALSE

	// Blacklisting maintenance in general, as well as any areas that already have a bounty in them.
	var/list/blacklisted_areas = typecacheof(/area/station/maintenance)
	for(var/datum/spy_bounty/machine/existing_bounty in handler.get_all_bounties())
		blacklisted_areas[existing_bounty.location_type] = TRUE

	var/list/obj/machinery/all_possible = list()
	for(var/obj/machinery/found_machine as anything in SSmachines.get_machines_by_type_and_subtypes(target_type))
		if(!is_station_level(found_machine.z))
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

	var/obj/machinery/machine = pick(all_possible)
	var/area/machine_area = get_area(machine)
	location_type = machine_area.type
	name ||= "[machine.name] Burglary"
	help ||= "Steal \a [machine] found in [machine_area]."
	return TRUE

/datum/spy_bounty/machine/is_stealable(atom/movable/stealing)
	if(!istype(stealing, target_type))
		return FALSE
	if(!istype(get_area(stealing), location_type))
		return FALSE
	return TRUE

/datum/spy_bounty/machine/random_easy
	difficulty = SPY_DIFFICULTY_EASY
	weight = 2 // Increased due to there being many easy options

/datum/spy_bounty/machine/random_easy/init_bounty(datum/spy_bounty_handler/handler)
	target_type = pick(
		/obj/machinery/computer/operating,
		/obj/machinery/fax, // Completely random wild card
		/obj/machinery/recharge_station,
		/obj/machinery/microwave,
	)
	return ..()

/datum/spy_bounty/machine/random_medium
	difficulty = SPY_DIFFICULTY_MEDIUM
	weight = 4 // Increased due to there being many medium options

/datum/spy_bounty/machine/random_medium/init_bounty(datum/spy_bounty_handler/handler)
	target_type = pick(
		/obj/machinery/chem_dispenser,
		/obj/machinery/computer/bank_machine,
		/obj/machinery/computer/crew,
		/obj/machinery/computer/prisoner/management,
		/obj/machinery/computer/rdconsole,
		/obj/machinery/computer/security, // Requires breaking into a sec checkpoint, but not too hard, many are never visited
		/obj/machinery/dna_scannernew,
		/obj/machinery/mecha_part_fabricator,
	)
	return ..()

/datum/spy_bounty/machine/random_hard
	difficulty = SPY_DIFFICULTY_HARD

/datum/spy_bounty/machine/random_hard/init_bounty(datum/spy_bounty_handler/handler)
	target_type = pick(
		/obj/machinery/computer/accounting,
		/obj/machinery/computer/communications,
		/obj/machinery/computer/upload,
		/obj/machinery/modular_computer/preset/id,
	)
	return ..()

/datum/spy_bounty/machine/random_hard/can_claim(mob/user) // These would all be too easy with command level access
	return !(user.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)

/// Subtype for a bounty that targets a specific crew member
/datum/spy_bounty/targets_person
	difficulty = SPY_DIFFICULTY_HARD
	theft_time = 12 SECONDS
	/// Weakref to the mob target of the bounty
	VAR_FINAL/datum/weakref/target_ref

/datum/spy_bounty/targets_person/can_claim(mob/user)
	return !IS_WEAKREF_OF(user, target_ref)

/datum/spy_bounty/targets_person/init_bounty(datum/spy_bounty_handler/handler)
	var/list/mob/possible_targets = list()
	for(var/datum/mind/crew_mind as anything in get_crewmember_minds())
		// Ideally we want it to be a player, but we don't care if they DC after being selected
		if(isnull(crew_mind.current?.client))
			continue
		if(!is_valid_crewmember(crew_mind.current))
			continue
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

	ASSERT(ishuman(stealing), "steal some item bounty called clean_up_stolen_item with something that isn't a human and isn't the original item.")

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

/datum/spy_bounty/targets_person/some_item/heirloom/find_desired_thing(mob/living/crewmember)
	var/datum/quirk/item_quirk/family_heirloom/quirk = crewmember.get_quirk(/datum/quirk/item_quirk/family_heirloom)
	return quirk?.heirloom?.resolve()

/datum/spy_bounty/targets_person/some_item/heirloom/target_found(mob/crewmember)
	. = ..()
	name = "[crewmember.real_name]'s heirloom"

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

/datum/spy_bounty/some_bot
	theft_time = 10 SECONDS
	black_market_prob = 0
	/// What typepath of bot we want to steal.
	var/mob/living/simple_animal/bot/bot_type
	/// Weakref to the bot we want to steal.
	VAR_FINAL/datum/weakref/target_bot_ref

/datum/spy_bounty/some_bot/init_bounty(datum/spy_bounty_handler/handler)
	for(var/datum/spy_bounty/some_bot/existing_bounty in handler.get_all_bounties())
		if(ispath(bot_type, initial(existing_bounty.bot_type.parent_type))) // ensures we don't get two similar bounties.
			return FALSE

	var/list/mob/living/possible_bots = list()
	for(var/mob/living/bot as anything in GLOB.bots_list)
		if(!is_station_level(bot.z))
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
	help = "Abduct Officer Beepsky, commonly found patrolling the station."

/datum/spy_bounty/some_bot/ofitser
	difficulty = SPY_DIFFICULTY_EASY
	bot_type = /mob/living/simple_animal/bot/secbot/beepsky/ofitser
	help = "Abduct Prison Ofitser, commonly found guarding the Gulag."

/datum/spy_bounty/some_bot/armsky
	difficulty = SPY_DIFFICULTY_HARD
	bot_type = /mob/living/simple_animal/bot/secbot/beepsky/armsky
	help = "Abduct Sergeant-At-Armsky, commonly found guarding the station's Armory."

/datum/spy_bounty/some_bot/pingsky
	difficulty = SPY_DIFFICULTY_HARD
	bot_type = /mob/living/simple_animal/bot/secbot/pingsky
	help = "Abduct Officer Pingsky, commonly found protecting the station's AI."


/datum/spy_bounty/some_bot/scrubbs
	difficulty = SPY_DIFFICULTY_EASY
	bot_type = /mob/living/basic/bot/cleanbot/medbay
	help = "Abduct Scrubbs MD, commonly found mopping up blood in Medbay."

/datum/spy_bounty/some_bot/scrubbs/can_claim(mob/user)
	return !(user.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_MEDICAL)
