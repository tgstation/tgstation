

/**
 * The objects that ore vents produce, which is refined into minerals.
 */
/obj/item/boulder
	name = "boulder"
	desc = "This rocks."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
	item_flags = NO_MAT_REDEMPTION
	throw_range = 2
	throw_speed = 0.5
	drag_slowdown = 1.5 // It's still a big rock.
	///When a refinery machine is working on this boulder, we'll set this. Re reset when the process is finished, but the boulder may still be refined/operated on further.
	var/obj/machinery/bouldertech/processed_by = null
	/// How many steps of refinement this boulder has gone through. Starts at 5-8, goes down one each machine process.
	var/durability = 5
	/// What was the size of the boulder when it was spawned? This is used for inheiriting the icon_state.
	var/boulder_size = BOULDER_SIZE_SMALL
	/// Used in inheriting the icon_state from our parent vent in update_icon.
	var/boulder_string = "boulder"
	/// Cooldown used to prevents boulders from getting processed back into a machine immediately after being processed.
	COOLDOWN_DECLARE(processing_cooldown)

	/// Static list of all minerals to populate gulag boulders with.
	var/list/static/gulag_minerals = list(
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 95,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)
	/// Static list of all minerals to populate gulag boulders with, but with bluespace added where safe.
	var/list/static/expanded_gulag_minerals = list(
		/datum/material/bluespace = 1,
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 94,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)

/obj/item/boulder/Initialize(mapload)
	. = ..()
	register_context()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 0, force_wielded = 5) //Heavy as all hell, it's a boulder, dude.

/obj/item/boulder/Destroy(force)
	SSore_generation.available_boulders -= src
	processed_by = null
	return ..()

/obj/item/boulder/examine(mob/user)
	. = ..()
	. += span_notice("This boulder would take [durability] more steps to refine or break.")

/obj/item/boulder/examine_more(mob/user)
	. = ..()
	. += span_notice("[span_bold("Boulders")] can either be cracked open by [span_bold("mining tools")], or processed into sheets with [span_bold("refineries or smelters")]. Undisturbed boulders can be collected by the [span_bold("BRM")].")

/obj/item/boulder/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item?.tool_behaviour == TOOL_MINING || HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		context[SCREENTIP_CONTEXT_RMB] = "Crush boulder into ore"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/boulder/attack_self(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		manual_process(null, user, INATE_BOULDER_SPEED_MULTIPLIER)
		return

/obj/item/boulder/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		manual_process(null, user, INATE_BOULDER_SPEED_MULTIPLIER)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/boulder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/item/boulder)) //This way, boulders can only go one at a time on conveyor belts, but everyone else can go through.
		return FALSE

/obj/item/boulder/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER) || HAS_TRAIT(weapon, TRAIT_BOULDER_BREAKER))
		manual_process(weapon, user, INATE_BOULDER_SPEED_MULTIPLIER)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(weapon.tool_behaviour == TOOL_MINING)
		manual_process(weapon, user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/boulder/attack_basic_mob(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		manual_process(null, user, INATE_BOULDER_SPEED_MULTIPLIER) //A little hacky but it works around the speed of the blackboard task selection process for now.
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/boulder/update_icon_state()
	. = ..()
	switch(boulder_size)
		if(BOULDER_SIZE_SMALL)
			icon_state = "[boulder_string]_small"
		if(BOULDER_SIZE_MEDIUM)
			icon_state = "[boulder_string]_medium"
		if(BOULDER_SIZE_LARGE)
			icon_state = "[boulder_string]_large"
		else
			icon_state = "[boulder_string]_small"

/**
 * This is called when a boulder is processed by a mob or tool, and reduces the durability of the boulder.
 * @param obj/item/weapon The weapon that is being used to process the boulder, that we pull toolspeed from. If null, we use the override_speed_multiplier instead.
 * @param mob/living/user The mob that is processing the boulder.
 * @param override_speed_multiplier The speed multiplier to use if weapon is null. The do_after will take 2 * this value seconds to complete.
 * @param continued Whether or not this is a continued process, or the first one. If true, we don't play the "You swing at the boulder" message.
 */
/obj/item/boulder/proc/manual_process(obj/item/weapon, mob/living/user, override_speed_multiplier, continued = FALSE)
	var/process_speed = 0
	//Handle weapon conditions.
	if(weapon)
		if(HAS_TRAIT(weapon, TRAIT_INSTANTLY_PROCESSES_BOULDERS))
			durability = 0
		process_speed = weapon.toolspeed
		weapon.play_tool_sound(src, 50)
		if(!continued)
			to_chat(user, span_notice("You swing at \the [src]..."))

	// Handle user conditions/override conditions.
	else if (override_speed_multiplier || HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		if(user)
			if(HAS_TRAIT(user, TRAIT_INSTANTLY_PROCESSES_BOULDERS))
				durability = 0
		else if(override_speed_multiplier)
			process_speed = override_speed_multiplier
		else
			process_speed = INATE_BOULDER_SPEED_MULTIPLIER
		playsound(src, 'sound/effects/rocktap1.ogg', 50)
		if(!continued)
			to_chat(user, span_notice("You scrape away at \the [src]... speed is [process_speed]."))
	else
		CRASH("No weapon, acceptable user, or override speed multiplier passed to manual_process()")
	if(durability > 0)
		if(!do_after(user, (2 * process_speed SECONDS), target = src))
			return
		if(!user.Adjacent(src))
			return
		durability--
		user.apply_damage(4, STAMINA)
	if(durability <= 0)
		convert_to_ore()
		to_chat(user, span_notice("You finish working on \the [src], and it crumbles into ore."))
		playsound(src, 'sound/effects/rock_break.ogg', 50)
		user.mind?.adjust_experience(/datum/skill/mining, MINING_SKILL_BOULDER_SIZE_XP * 0.2)
		qdel(src)
		return
	var/msg = (durability == 1 ? "is crumbling!" : "looks weaker!")
	to_chat(user, span_notice("\The [src] [msg]"))
	manual_process(weapon, user, override_speed_multiplier, continued = TRUE)

/**
 * This function is called while breaking boulders manually, and drops ore based on the boulder's mineral content.
 * Quantity of ore spawned here is 1 less than if the boulder was processed by a machine, but clamped at 10 maximum, 1 minimum.
 */
/obj/item/boulder/proc/convert_to_ore()
	for(var/datum/material/picked in custom_materials)
		var/obj/item/stack/ore/cracked_ore // Take the associated value and convert it into ore stacks...
		var/quantity = clamp(round((custom_materials[picked] - SHEET_MATERIAL_AMOUNT)/SHEET_MATERIAL_AMOUNT), 1, 10) //but less resources than if they processed it by hand.

		var/cracked_ore_type = picked.ore_type
		if(isnull(cracked_ore_type))
			stack_trace("boulder found containing material type [picked.type] with no set ore_type")
			continue
		cracked_ore = new cracked_ore_type (drop_location(), quantity)
		SSblackbox.record_feedback("tally", "ore_mined", quantity, cracked_ore)

/**
 * Handles the boulder's processing cooldown to check if it's ready to be processed again.
 */
/obj/item/boulder/proc/can_get_processed()
	return COOLDOWN_FINISHED(src, processing_cooldown)

/**
 * Starts the boulder's processing cooldown.
 */
/obj/item/boulder/proc/restart_processing_cooldown()
	COOLDOWN_START(src, processing_cooldown, 2 SECONDS)

/**
 * Moves boulder contents to the drop location, and then deletes the boulder.
 */
/obj/item/boulder/proc/break_apart()
	var/list/quips = list("Clang!", "Crack!", "Bang!", "Clunk!", "Clank!")
	if(length(contents))
		visible_message(span_notice("[pick(quips)] Something falls out of \the [src]!"))
		playsound(loc, 'sound/effects/picaxe1.ogg', 60, FALSE)
		for(var/obj/item/content as anything in contents)
			content.forceMove(get_turf(src))
	qdel(src)

/**
 * This is called when a boulder is spawned from a vent, and is used to set the boulder's icon as well as durability.
 * We also set our boulder_size variable, which is used for inheiriting the icon_state later on if processed.
 * @param obj/structure/ore_vent/parent_vent The vent that spawned this boulder to generate consistent boulder icons. If null, we use the default size.
 * @param size The size of the boulder to spawn. If parent_vent is defined, this is ignored.
 * @param is_artifact Whether or not this boulder is an artifact boulder. If true, we use the artifact boulder icon state regardless of size.
 */
/obj/item/boulder/proc/flavor_boulder(obj/structure/ore_vent/parent_vent, size = BOULDER_SIZE_SMALL, is_artifact = FALSE)
	var/durability_min = size
	var/durability_max = size + BOULDER_SIZE_SMALL
	if(parent_vent)
		durability_min = parent_vent.boulder_size
		durability_max = parent_vent.boulder_size + BOULDER_SIZE_SMALL
	durability = rand(durability_min, durability_max) //randomize durability a bit for some flavor.
	boulder_size = size
	if(parent_vent)
		boulder_size = parent_vent.boulder_size
		boulder_string = parent_vent.boulder_icon_state
	update_appearance(UPDATE_ICON_STATE)

/**
 * Unique proc for gulag-style boulders, which adds a random amount of minerals to the boulder.
 */
/obj/item/boulder/proc/add_gulag_minerals()
	var/datum/material/new_material = pick_weight(gulag_minerals)
	var/list/new_mats = list()
	new_mats[new_material] = SHEET_MATERIAL_AMOUNT * rand(1,3) //We only want a few sheets of material in the gulag boulders
	set_custom_materials(new_mats)

/obj/item/boulder/artifact
	name = "artifact boulder"
	desc = "This boulder is brimming with strange energy. Cracking it open could contain something unusual for science."
	icon_state = "boulder_artifact"
	/// This is the type of item that will be inside the boulder. Default is a strange object.
	var/artifact_type = /obj/item/relic
	/// References to the relic inside the boulder, if any.
	var/obj/item/artifact_inside

/obj/item/boulder/artifact/Initialize(mapload)
	. = ..()
	artifact_inside = new artifact_type(src) /// This could be poggers for archaeology in the future.

/obj/item/boulder/artifact/Destroy(force)
	QDEL_NULL(artifact_inside)
	return ..()

/obj/item/boulder/artifact/convert_to_ore()
	. = ..()
	artifact_inside.forceMove(drop_location())
	artifact_inside = null

/obj/item/boulder/artifact/break_apart()
	artifact_inside = null
	return ..()


/obj/item/boulder/gulag
	name = "low-quality boulder"
	desc = "This rocks. It's a low quality boulder, so it's probably not worth as much."

/obj/item/boulder/gulag/Initialize(mapload)
	. = ..()
	add_gulag_minerals(gulag_minerals)

/obj/item/boulder/gulag_expanded
	name = "low-density boulder"
	desc = "This rocks. It's not very well packed, and can't contain as many minerals."

/obj/item/boulder/gulag_expanded/Initialize(mapload)
	. = ..()
	add_gulag_minerals(expanded_gulag_minerals)

/obj/item/boulder/shabby
	name = "shabby boulder"
	desc = "A bizzare, twisted boulder. Wait, wait no, it's just a rock."
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.1, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.1)
	durability = 1
