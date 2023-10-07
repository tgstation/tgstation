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
	slowdown = 1.5 // It's a big rock.
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
	if(held_item?.tool_behaviour == TOOL_MINING || isgolem(user))
		context[SCREENTIP_CONTEXT_RMB] = "Crush boulder into ore"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/boulder/attack_self(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(isgolem(user))
		manual_process(null, user, 1.5)
		return

/obj/item/boulder/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(isgolem(user))
		manual_process(null, user, 1.5)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/boulder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/item/boulder)) //This way, boulders can only go one at a time on conveyor belts, but everyone else can go through.
		return FALSE

/obj/item/boulder/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(!isliving(user))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	if(weapon.tool_behaviour == TOOL_MINING)
		manual_process(weapon, user)
		return TRUE
	if(isgolem(user))
		manual_process(weapon, user, 3)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(.)
		return

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

/obj/item/boulder/proc/manual_process(obj/item/weapon, mob/living/user, override_speed, mech_override = FALSE, continued = FALSE)
	var/process_speed = 0
	if(weapon)
		process_speed = weapon.toolspeed
		weapon.play_tool_sound(src, 50)
		if(!continued)
			to_chat(user, span_notice("You swing at \the [src]..."))
	else if (override_speed)
		process_speed = override_speed
		playsound(src, 'sound/effects/rocktap1.ogg', 50)
		if(!continued)
			to_chat(user, span_notice("You scrape away at \the [src]..."))
	else
		return

	if(!mech_override)
		if(!do_after(user, (2 * process_speed SECONDS), target = src))
			return FALSE
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
                var/msg = durability == 1 ? "is crumbling" : "looks weaker"
		to_chat(user, span_notice("\The [src] [msg]"))
		manual_process(weapon, user, override_speed, continued = TRUE)

/obj/item/boulder/proc/convert_to_ore(weak)
	for(var/datum/material/picked in custom_materials)
		var/obj/item/stack/ore/cracked_ore // Take the associated value and convert it into ore stacks...
		var/quantity = clamp(round((custom_materials[picked] - SHEET_MATERIAL_AMOUNT)/SHEET_MATERIAL_AMOUNT), 1, 10) //but less resources than if they processed it by hand.
		switch(picked.type)
			if(/datum/material/iron)
				cracked_ore = new /obj/item/stack/ore/iron(drop_location(), quantity)
			if(/datum/material/gold)
				cracked_ore = new /obj/item/stack/ore/gold(drop_location(), quantity)
			if(/datum/material/silver)
				cracked_ore = new /obj/item/stack/ore/silver(drop_location(), quantity)
			if(/datum/material/plasma)
				cracked_ore = new /obj/item/stack/ore/plasma(drop_location(), quantity)
			if(/datum/material/diamond)
				cracked_ore = new /obj/item/stack/ore/diamond(drop_location(), quantity)
			if(/datum/material/glass)
				cracked_ore = new /obj/item/stack/ore/glass/basalt(drop_location(), quantity)
			if(/datum/material/bluespace)
				cracked_ore = new /obj/item/stack/ore/bluespace_crystal(drop_location(), quantity)
			if(/datum/material/titanium)
				cracked_ore = new /obj/item/stack/ore/titanium(drop_location(), quantity)
			if(/datum/material/uranium)
				cracked_ore = new /obj/item/stack/ore/uranium(drop_location(), quantity)
		SSblackbox.record_feedback("tally", "ore_mined", quantity, cracked_ore)

/obj/item/boulder/proc/can_get_processed()
	if(COOLDOWN_FINISHED(src, processing_cooldown))
		return TRUE
	return FALSE

/obj/item/boulder/proc/reset_processing_cooldown()
	COOLDOWN_START(src, processing_cooldown, 2 SECONDS)

/**
 * Moves boulder contents to the drop location, and then deletes the boulder.
 */
/obj/item/boulder/proc/break_apart()
	var/list/quips = list("Clang!", "Crack!", "Bang!", "Clunk!", "Clank!")
	for(var/obj/item/content as anything in contents)
		content.forceMove(get_turf(src))
		visible_message(span_notice("[pick(quips)] Something falls out of \the [src]!"))
		playsound(loc, 'sound/effects/picaxe1.ogg', 60, FALSE)
	qdel(src)

/**
 * This is called when a boulder is spawned from a vent, and is used to set the boulder's icon as well as durability.
 * We also set our boulder_size variable, which is used for inheiriting the icon_state later on if processed.
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
	artifact_inside = null
	return ..()

/obj/item/boulder/artifact/convert_to_ore()
	. = ..()
	artifact_inside.forceMove(drop_location())
	artifact_inside = null

/obj/item/boulder/artifact/break_apart()
	artifact_inside = null
	return ..()

/obj/item/boulder/artifact/update_icon_state()
	. = ..()
	icon_state = "boulder_artifact" //We're always going to use the artifact state for clarity.
	return

/obj/item/boulder/gulag
	name = "boulder"
	desc = "This rocks. It's also a gulag boulder, so it's probably not worth as much."
	var/list/pick_minerals = list(
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 95,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)

/obj/item/boulder/gulag/Initialize(mapload)
	. = ..()
	add_gulag_minerals()

/**
 * Unique proc for gulag boulders, which adds a random amount of minerals to the boulder.
 */
/obj/item/boulder/gulag/proc/add_gulag_minerals()
	var/datum/material/new_material = pick_weight(pick_minerals)
	var/list/new_mats = list()
	new_mats += new_material
	new_mats[new_material] = SHEET_MATERIAL_AMOUNT * rand(1,3) //We only want a few sheets of material in the gulag boulders
	set_custom_materials(new_mats)

/obj/item/boulder/gulag/volcanic
	pick_minerals = list(
		/datum/material/bluespace = 1,
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 95,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3,
	)
