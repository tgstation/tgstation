#define DOOM_SINGULARITY "singularity"
#define DOOM_TESLA "tesla"
#define DOOM_METEORS "meteors"

/**
 * A big final event to run when you complete seven rituals
 */
/datum/grand_finale
	/// Friendly name for selection menu
	var/name
	/// Tooltip description for selection menu
	var/desc
	/// An icon to display to represent the choice
	var/icon/icon
	/// Icon state to use to represent the choice
	var/icon_state
	/// Prevent especially dangerous options from being chosen until we're fine with the round ending
	var/minimum_time = 0
	/// Override the rune invocation time
	var/ritual_invoke_time = 30 SECONDS
	/// Provide an extremely loud radio message when this one starts
	var/dire_warning = FALSE
	/// Overrides the default colour you glow while channeling the rune, optional
	var/glow_colour

/**
 * Returns an entry for a radial menu for this choice.
 * Returns null if entry is abstract or invalid for current circumstances.
 */
/datum/grand_finale/proc/get_radial_choice()
	if (!name || !desc || !icon || !icon_state)
		return
	if (minimum_time >= world.time - SSticker.round_start_time)
		return
	var/datum/radial_menu_choice/choice = new()
	choice.name = name
	choice.image = image(icon = icon, icon_state = icon_state)
	choice.info = desc
	return choice

/**
 * Actually do the thing.
 * Arguments
 * * invoker - The wizard casting this.
 */
/datum/grand_finale/proc/trigger(mob/living/invoker)
	// Do something cool.

/// Tries to equip something into an inventory slot, then hands, then the floor.
/datum/grand_finale/proc/equip_to_slot_then_hands(mob/living/carbon/human/invoker, slot, obj/item/item)
	if(!item)
		return
	if(!invoker.equip_to_slot_if_possible(item, slot, disable_warning = TRUE))
		invoker.put_in_hands(item)

/// They are not going to take this lying down.
/datum/grand_finale/proc/create_vendetta(datum/mind/aggrieved_crewmate, datum/mind/wizard)
	aggrieved_crewmate.add_antag_datum(/datum/antagonist/wizard_prank_vendetta)
	var/datum/antagonist/wizard_prank_vendetta/antag_datum = aggrieved_crewmate.has_antag_datum(/datum/antagonist/wizard_prank_vendetta)
	var/datum/objective/assassinate/wizard_murder = new
	wizard_murder.owner = aggrieved_crewmate
	wizard_murder.target = wizard
	wizard_murder.explanation_text = "Kill [wizard.current.name], the one who did this."
	antag_datum.objectives += wizard_murder

	to_chat(aggrieved_crewmate.current, span_warning("No! This isn't right!"))
	aggrieved_crewmate.announce_objectives()

/**
 * Antag datum to give to people who want to kill the wizard.
 * This doesn't preclude other people choosing to want to kill the wizard, just these people are rewarded for it.
 */
/datum/antagonist/wizard_prank_vendetta
	name = "\improper Wizard Prank Victim"
	roundend_category = "wizard prank victims"
	show_in_antagpanel = FALSE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE
	silent = TRUE

/// Become the official Captain of the station
/datum/grand_finale/usurp
	name = "Usurpation"
	desc = "The ultimate use of your gathered power! Rewrite time such that you have been Captain of this station the whole time."
	icon = 'icons/obj/card.dmi'
	icon_state = "card_gold"

/datum/grand_finale/usurp/trigger(mob/living/carbon/human/invoker)
	message_admins("[key_name(invoker)] has replaced the Captain")
	var/list/former_captains = list()
	var/list/other_crew = list()
	SEND_SOUND(world, sound('sound/magic/timeparadox2.ogg'))

	for (var/mob/living/carbon/human/crewmate as anything in GLOB.human_list)
		if (!crewmate.mind)
			continue
		crewmate.Unconscious(3 SECONDS) // Everyone falls unconscious but not everyone gets told about a new captain
		if (crewmate == invoker || IS_HUMAN_INVADER(crewmate))
			continue
		to_chat(crewmate, span_notice("The world spins and dissolves. Your past flashes before your eyes, backwards.\n\
			Life strolls back into the ocean and shrinks into nothingness, planets explode into storms of solar dust, \
			the stars rush back to greet each other at the beginning of things and then... you snap back to the present. \n\
			Everything is just as it was and always has been. \n\n\
			A stray thought sticks in the forefront of your mind. \n\
			[span_hypnophrase("I'm so glad that [invoker.real_name] is our legally appointed Captain!")] \n\
			Is... that right?"))
		if (is_captain_job(crewmate.mind.assigned_role))
			former_captains += crewmate
			demote_to_assistant(crewmate)
			continue
		if (crewmate.stat != DEAD)
			other_crew += crewmate

	dress_candidate(invoker)
	GLOB.manifest.modify(invoker.real_name, JOB_CAPTAIN, JOB_CAPTAIN)
	minor_announce("Captain [invoker.real_name] on deck!")

	// Enlist some crew to try and restore the natural order
	for (var/mob/living/carbon/human/former_captain as anything in former_captains)
		create_vendetta(former_captain.mind, invoker.mind)
	for (var/mob/living/carbon/human/random_crewmate as anything in other_crew)
		if (prob(10))
			create_vendetta(random_crewmate.mind, invoker.mind)

/**
 * Anyone who thought they were Captain is in for a nasty surprise, and won't be very happy about it
 */
/datum/grand_finale/usurp/proc/demote_to_assistant(mob/living/carbon/human/former_captain)
	var/obj/effect/particle_effect/fluid/smoke/exit_poof = new(get_turf(former_captain))
	exit_poof.lifetime = 2 SECONDS

	former_captain.unequip_everything()
	if(isplasmaman(former_captain))
		former_captain.equipOutfit(/datum/outfit/plasmaman)
		former_captain.internal = former_captain.get_item_for_held_index(2)
	else
		former_captain.equipOutfit(/datum/outfit/job/assistant)

	GLOB.manifest.modify(former_captain.real_name, JOB_ASSISTANT, JOB_ASSISTANT)
	var/list/valid_turfs = list()
	// Used to be into prison but that felt a bit too mean
	for (var/turf/exile_turf as anything in get_area_turfs(/area/station/maintenance, subtypes = TRUE))
		if (isspaceturf(exile_turf) || exile_turf.is_blocked_turf())
			continue
		valid_turfs += exile_turf
	do_teleport(former_captain, pick(valid_turfs), no_effects = TRUE)
	var/obj/effect/particle_effect/fluid/smoke/enter_poof = new(get_turf(former_captain))
	enter_poof.lifetime = 2 SECONDS

/**
 * Does some item juggling to try to dress you as both a Wizard and Captain without deleting any items you have bought.
 * ID, headset, and uniform are forcibly replaced. Other slots are only filled if unoccupied.
 * We could forcibly replace shoes and gloves too but people might miss their insuls or... meown shoes?
 */
/datum/grand_finale/usurp/proc/dress_candidate(mob/living/carbon/human/invoker)
	// Won't be needing these
	var/obj/id = invoker.get_item_by_slot(ITEM_SLOT_ID)
	QDEL_NULL(id)
	var/obj/headset = invoker.get_item_by_slot(ITEM_SLOT_EARS)
	QDEL_NULL(headset)
	// We're about to take off your pants so those are going to fall out
	var/obj/item/pocket_L = invoker.get_item_by_slot(ITEM_SLOT_LPOCKET)
	var/obj/item/pocket_R = invoker.get_item_by_slot(ITEM_SLOT_RPOCKET)
	// In case we try to put a PDA there
	var/obj/item/belt = invoker.get_item_by_slot(ITEM_SLOT_BELT)
	belt?.moveToNullspace()

	var/obj/pants = invoker.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	QDEL_NULL(pants)
	invoker.equipOutfit(/datum/outfit/job/wizard_captain)
	// And put everything back!
	equip_to_slot_then_hands(invoker, ITEM_SLOT_BELT, belt)
	equip_to_slot_then_hands(invoker, ITEM_SLOT_LPOCKET, pocket_L)
	equip_to_slot_then_hands(invoker, ITEM_SLOT_RPOCKET, pocket_R)

/// An outfit which replaces parts of a wizard's clothes with captain's clothes but keeps the robes
/datum/outfit/job/wizard_captain
	name = "Captain (Wizard Transformation)"
	jobtype = /datum/job/captain
	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/job/captain
	uniform = /obj/item/clothing/under/rank/captain/parade
	belt = /obj/item/modular_computer/pda/heads/captain
	ears = /obj/item/radio/headset/heads/captain/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/captain
	shoes = /obj/item/clothing/shoes/laceup
	accessory = /obj/item/clothing/accessory/medal/gold/captain
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/station_charter = 1,
	)
	box = null

/// Dress the crew as magical clowns
/datum/grand_finale/clown
	name = "Jubilation"
	desc = "The ultimate use of your gathered power! Rewrite time so that everyone went to clown college! Now they'll prank each other for you!"
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "clown"
	glow_colour = "#ffff0048"

/datum/grand_finale/clown/trigger(mob/living/carbon/human/invoker)
	for(var/mob/living/carbon/human/victim as anything in GLOB.human_list)
		victim.Unconscious(3 SECONDS)
		if (!victim.mind || IS_HUMAN_INVADER(victim) || victim == invoker)
			continue
		if (HAS_TRAIT(victim, TRAIT_CLOWN_ENJOYER))
			victim.add_mood_event("clown_world", /datum/mood_event/clown_world)
		to_chat(victim, span_notice("The world spins and dissolves. Your past flashes before your eyes, backwards.\n\
			Life strolls back into the ocean and shrinks into nothingness, planets explode into storms of solar dust, \
			the stars rush back to greet each other at the beginning of things and then... you snap back to the present. \n\
			Everything is just as it was and always has been. \n\n\
			A stray thought sticks in the forefront of your mind. \n\
			[span_hypnophrase("I'm so glad that I work at Clown Research Station [station_name()]!")] \n\
			Is... that right?"))
		if (is_clown_job(victim.mind.assigned_role))
			var/datum/action/cooldown/spell/conjure_item/clown_pockets/new_spell = new(victim)
			new_spell.Grant(victim)
			continue
		if (!ismonkey(victim)) // Monkeys cannot yet wear clothes
			dress_as_magic_clown(victim)
		if (prob(15))
			create_vendetta(victim.mind, invoker.mind)

/**
 * Clown enjoyers who are effected by this become ecstatic, they have achieved their life's dream.
 * This moodlet is equivalent to the one for simply being a traitor.
 */
/datum/mood_event/clown_world
	mood_change = 4

/datum/mood_event/clown_world/add_effects(param)
	description = "I LOVE working at Clown Research Station [station_name()]!!"

/// Dress the passed mob as a magical clown, self-explanatory
/datum/grand_finale/clown/proc/dress_as_magic_clown(mob/living/carbon/human/victim)
	var/obj/effect/particle_effect/fluid/smoke/poof = new(get_turf(victim))
	poof.lifetime = 2 SECONDS

	var/obj/item/tank/internal = victim.internal
	// We're about to take off your pants so those are going to fall out
	var/obj/item/pocket_L = victim.get_item_by_slot(ITEM_SLOT_LPOCKET)
	var/obj/item/pocket_R = victim.get_item_by_slot(ITEM_SLOT_RPOCKET)
	var/obj/item/id = victim.get_item_by_slot(ITEM_SLOT_ID)
	var/obj/item/belt = victim.get_item_by_slot(ITEM_SLOT_BELT)

	var/obj/pants = victim.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	var/obj/mask = victim.get_item_by_slot(ITEM_SLOT_MASK)
	QDEL_NULL(pants)
	QDEL_NULL(mask)
	if(isplasmaman(victim))
		victim.equip_to_slot_if_possible(new /obj/item/clothing/under/plasmaman/clown/magic(), ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
		victim.equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat/plasmaman(), ITEM_SLOT_MASK, disable_warning = TRUE)
	else
		victim.equip_to_slot_if_possible(new /obj/item/clothing/under/rank/civilian/clown/magic(), ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
		victim.equip_to_slot_if_possible(new /obj/item/clothing/mask/gas/clown_hat(), ITEM_SLOT_MASK, disable_warning = TRUE)

	var/obj/item/clothing/mask/gas/clown_hat/clown_mask = victim.get_item_by_slot(ITEM_SLOT_MASK)
	if (clown_mask)
		var/list/options = GLOB.clown_mask_options
		clown_mask.icon_state = options[pick(clown_mask.clownmask_designs)]
		victim.update_worn_mask()
		clown_mask.update_item_action_buttons()

	equip_to_slot_then_hands(victim, ITEM_SLOT_LPOCKET, pocket_L)
	equip_to_slot_then_hands(victim, ITEM_SLOT_RPOCKET, pocket_R)
	equip_to_slot_then_hands(victim, ITEM_SLOT_ID, id)
	equip_to_slot_then_hands(victim, ITEM_SLOT_BELT, belt)
	victim.internal = internal

/// Give everyone magic items
/datum/grand_finale/magic
	name = "Evolution"
	desc = "The ultimate use of your gathered power! Give the crew their own magic, they'll surely realise that right and wrong have no meaning when you hold ultimate power!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/datum/grand_finale/magic/trigger(mob/living/carbon/human/invoker)
	message_admins("[key_name(invoker)] summoned magic")
	summon_magic(survivor_probability = 20) // Wow, this one was easy!

/// Open all of the doors
/datum/grand_finale/all_access
	name = "Connection"
	desc = "The ultimate use of your gathered power! Unlock every single door that they have! Nobody will be able to keep you out now, or anyone else for that matter!"
	icon = 'icons/mob/actions/actions_spells.dmi'
	icon_state = "knock"

/datum/grand_finale/all_access/trigger(mob/living/carbon/human/invoker)
	message_admins("[key_name(invoker)] removed all door access requirements")
	for(var/obj/machinery/door/target_door as anything in GLOB.airlocks)
		if(is_station_level(target_door.z))
			target_door.unlock()
			target_door.req_access = list()
			target_door.req_one_access = list()
			INVOKE_ASYNC(target_door, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
			CHECK_TICK
	priority_announce("AULIE OXIN FIERA!!", null, 'sound/magic/knock.ogg', sender_override = "[invoker.real_name]")

/// Completely transform the station
/datum/grand_finale/midas
	name = "Transformation"
	desc = "The ultimate use of your gathered power! Turn their precious station into something much MORE precious, materially speaking!"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "sheet-gold_2"
	glow_colour = "#dbdd4c48"
	var/static/list/permitted_transforms = list( // Non-dangerous only
		/datum/dimension_theme/gold,
		/datum/dimension_theme/meat,
		/datum/dimension_theme/pizza,
		/datum/dimension_theme/natural,
	)
	var/datum/dimension_theme/chosen_theme

// I sure hope this doesn't have performance implications
/datum/grand_finale/midas/trigger(mob/living/carbon/human/invoker)
	var/theme_path = pick(permitted_transforms)
	chosen_theme = new theme_path()
	var/turf/start_turf = get_turf(invoker)
	var/greatest_dist = 0
	var/list/turfs_to_transform = list()
	for (var/turf/transform_turf as anything in GLOB.station_turfs)
		if (!chosen_theme.can_convert(transform_turf))
			continue
		var/dist = get_dist(start_turf, transform_turf)
		if (dist > greatest_dist)
			greatest_dist = dist
		if (!turfs_to_transform["[dist]"])
			turfs_to_transform["[dist]"] = list()
		turfs_to_transform["[dist]"] += transform_turf

	if (chosen_theme.can_convert(start_turf))
		chosen_theme.apply_theme(start_turf)

	for (var/iterator in 1 to greatest_dist)
		if(!turfs_to_transform["[iterator]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(transform_area), turfs_to_transform["[iterator]"]), (5 SECONDS) * iterator)

/datum/grand_finale/midas/proc/transform_area(list/turfs)
	for (var/turf/transform_turf as anything in turfs)
		if (!chosen_theme.can_convert(transform_turf))
			continue
		chosen_theme.apply_theme(transform_turf)
		CHECK_TICK

/// Kill yourself and probably a bunch of other people
/datum/grand_finale/armageddon
	name = "Annihilation"
	desc = "This crew have offended you beyond the realm of pranks. Make the ultimate sacrifice to teach them a lesson your elders can really respect. \
		YOU WILL NOT SURVIVE THIS."
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "wounded"
	minimum_time = 90 MINUTES // This will probably immediately end the round if it gets finished.
	ritual_invoke_time = 60 SECONDS // Really give the crew some time to interfere with this one.
	dire_warning = TRUE
	glow_colour = "#be000048"
	/// Things to yell before you die
	var/static/list/possible_last_words = list(
		"Flames and ruin!",
		"Dooooooooom!!",
		"HAHAHAHAHAHA!! AHAHAHAHAHAHAHAHAA!!",
		"Hee hee hee!! Hoo hoo hoo!! Ha ha haaa!!",
		"Ohohohohohoho!!",
		"Cower in fear, puny mortals!",
		"Tremble before my glory!",
		"Pick a god and pray!",
		"It's no use!",
		"If the gods wanted you to live, they would not have created me!",
		"God stays in heaven out of fear of what I have created!",
		"Ruination is come!",
		"All of creation, bend to my will!",
	)

/datum/grand_finale/armageddon/trigger(mob/living/carbon/human/invoker)
	priority_announce(pick(possible_last_words), null, 'sound/magic/voidblink.ogg', sender_override = "[invoker.real_name]")
	var/turf/current_location = get_turf(invoker)
	invoker.gib()

	var/static/list/doom_options = list()
	if (!length(doom_options))
		doom_options = list(DOOM_SINGULARITY, DOOM_TESLA)
		if (!SSmapping.config.planetary)
			doom_options += DOOM_METEORS

	switch(pick(doom_options))
		if (DOOM_SINGULARITY)
			var/obj/singularity/singulo = new(current_location)
			singulo.energy = 300
		if (DOOM_TESLA)
			var/obj/energy_ball/tesla = new (current_location)
			tesla.energy = 200
		if (DOOM_METEORS)
			var/datum/dynamic_ruleset/roundstart/meteor/meteors = new()
			meteors.meteordelay = 0
			var/datum/game_mode/dynamic/mode = SSticker.mode
			mode.execute_roundstart_rule(meteors) // Meteors will continue until morale is crushed.
			priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS)

#undef DOOM_SINGULARITY
#undef DOOM_TESLA
#undef DOOM_METEORS
