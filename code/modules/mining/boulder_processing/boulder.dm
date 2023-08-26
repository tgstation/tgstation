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
	///When a refinery machine is working on this boulder, we'll set this. Re reset when the process is finished, but the boulder may still be refined/operated on further.
	var/obj/machinery/bouldertech/processed_by = null
	/// How many steps of refinement this boulder has gone through. Starts at 5-8, goes down one each machine process.
	var/durability = 5
	COOLDOWN_DECLARE(processing_cooldown)

/obj/item/boulder/Initialize(mapload)
	. = ..()
	register_context()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 0, force_wielded = 5) //Heavy as all hell, it's a boulder, dude.

/obj/item/boulder/Destroy(force)
	. = ..()
	SSore_generation.available_boulders -= src
	processed_by = null

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
	if(isgolem(user))
		return manual_process(null, user, 1.5)

/obj/item/boulder/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(isgolem(user))
		return manual_process(null, user, 1.5)


/obj/item/boulder/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(weapon.tool_behaviour == TOOL_MINING)
		manual_process(weapon, user)
	if(isgolem(user))
		manual_process(weapon, user, 3)
		return

/obj/item/boulder/proc/manual_process(obj/item/weapon, mob/user, golem_speed)
	var/process_speed = 0
	if(weapon)
		process_speed = weapon.toolspeed
		weapon.play_tool_sound(src, 50)
		to_chat(user, span_notice("You swing at \the [src]..."))
	else if (golem_speed)
		process_speed = golem_speed
		playsound(src, 'sound/effects/rocktap1.ogg', 50)
		to_chat(user, span_notice("You scrape away at \the [src]..."))
	else
		return

	if(!do_after(user, (2 * process_speed SECONDS), target = src))
		return FALSE
	if(!user.Adjacent(src))
		return
	durability--
	if(durability <= 0)
		to_chat(user, span_notice("You finish working on \the [src], and it crumbles into ore."))
		playsound(src, 'sound/effects/rock_break.ogg', 50)
		convert_to_ore()
		qdel(src)
		return
	else if(durability == 1)
		to_chat(user, span_notice("\The [src] has been weakened, and is close to crumbling!"))
		manual_process(weapon, user, golem_speed)
		return
	else
		to_chat(user, span_notice("You finish working on \the [src], and it looks a bit weaker."))
		manual_process(weapon, user, golem_speed)
		return

/obj/item/boulder/proc/convert_to_ore()
	for(var/datum/material/picked in custom_materials)
		/// Take the associated value and convert it into ore stacks, but less resources than if they processed it.
		say("[picked?.name] is inside!")
		switch(picked.type)
			if(/datum/material/iron)
				new /obj/item/stack/ore/iron(drop_location(), 1)
				continue
			if(/datum/material/gold)
				new /obj/item/stack/ore/gold(drop_location(), 1)
				continue
			if(/datum/material/silver)
				new /obj/item/stack/ore/silver(drop_location(), 1)
				continue
			if(/datum/material/plasma)
				new /obj/item/stack/ore/plasma(drop_location(), 1)
				continue
			if(/datum/material/diamond)
				new /obj/item/stack/ore/diamond(drop_location(), 1)
				continue
			if(/datum/material/glass)
				new /obj/item/stack/ore/glass/basalt(drop_location(), 1)
				continue
			if(/datum/material/bluespace)
				new /obj/item/stack/ore/bluespace_crystal(drop_location(), 1)
				continue
			if(/datum/material/titanium)
				new /obj/item/stack/ore/titanium(drop_location(), 1)
				continue
			if(/datum/material/uranium)
				new /obj/item/stack/ore/uranium(drop_location(), 1)
				continue

/obj/item/boulder/proc/can_get_processed()
	if(COOLDOWN_FINISHED(src, processing_cooldown))
		return TRUE
	return FALSE

/obj/item/boulder/proc/reset_processing_cooldown()
	COOLDOWN_START(src, processing_cooldown, 2 SECONDS)

/**
 * This is called when a boulder is spawned from a vent, and is used to set the boulder's icon as well as durability.
 */
/obj/item/boulder/proc/flavor_based_on_vent(obj/structure/ore_vent/parent_vent)
	var/durability_min = parent_vent.boulder_size
	var/durability_max = parent_vent.boulder_size + BOULDER_SIZE_SMALL
	if(!parent_vent)
		durability_min = BOULDER_SIZE_SMALL
		durability_max = BOULDER_SIZE_MEDIUM
	durability = rand(durability_min, durability_max) //randomize durability a bit for some flavor.
	switch(parent_vent?.boulder_size)
		if(BOULDER_SIZE_SMALL)
			icon_state = "boulder_small"
		if(BOULDER_SIZE_MEDIUM)
			icon_state = "boulder_medium"
		if(BOULDER_SIZE_LARGE)
			icon_state = "boulder_large"
		else
			icon_state = "boulder_small"
	update_appearance(UPDATE_ICON_STATE)

/obj/item/boulder/artifact
	name = "artifact boulder"
	desc = "This boulder is brimming with strange energy. Cracking it open could contain something unusual for science."
	var/artifact_type = /obj/item/relic

/obj/item/boulder/artifact/Initialize(mapload)
	. = ..()
	new artifact_type(src) /// This could be poggers for archaeology

/obj/item/boulder/artifact/convert_to_ore()
	. = ..()
	visible_message(src, "The boulder crumbles into ore, but something else is inside... \a [artifact_type]?")
	new artifact_type(drop_location())

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
		/datum/material/uranium = 3
	)

/obj/item/boulder/gulag/Initialize(mapload)
	. = ..()
	add_gulag_minerals()

/obj/item/boulder/gulag/proc/add_gulag_minerals()
	var/datum/material/materials = pick_weight(pick_minerals)
	custom_materials[materials] = SHEET_MATERIAL_AMOUNT

/obj/item/boulder/gulag/volcanic
	pick_minerals = list(
		/datum/material/bluespace = 1,
		/datum/material/diamond = 1,
		/datum/material/gold = 8,
		/datum/material/iron = 95,
		/datum/material/plasma = 30,
		/datum/material/silver = 20,
		/datum/material/titanium = 8,
		/datum/material/uranium = 3
	)



