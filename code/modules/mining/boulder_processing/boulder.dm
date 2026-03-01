
#define PLATFORM_WARNING_MODIFIER 5 SECONDS

/**
 * The objects that ore vents produce, which is refined into minerals.
 */
/obj/item/boulder
	name = "boulder"
	desc = "This rocks."
	icon_state = "ore"
	icon = 'icons/obj/ore.dmi'
	item_flags = NO_MAT_REDEMPTION | SLOWS_WHILE_IN_HAND
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 30 // Under normal circumstances, pretty much nobody can throw this.
	throw_range = 0
	tk_throw_range = 1 // Sorry, this is too cheesy, but maybe you can smash down doors with it.
	throw_speed = 0.5
	slowdown = 1.5
	drag_slowdown = 1.5 // It's still a big rock.

	///When a refinery machine is working on this boulder, we'll set this. Re reset when the process is finished, but the boulder may still be refined/operated on further.
	var/obj/machinery/processed_by = null
	/// How many steps of refinement this boulder has gone through. Starts at 5-8, goes down one each machine process.
	var/durability = 5
	/// What was the size of the boulder when it was spawned? This is used for inheiriting the icon_state.
	var/boulder_size = BOULDER_SIZE_SMALL
	/// Used in inheriting the icon_state from our parent vent in update_icon.
	var/boulder_string = "boulder"
	/// If the boulder is converted into a platform, how long will it last? Default is 10 seconds unless overwritten by a vent.
	var/platform_lifespan = PLATFORM_LIFE_DEFAULT

/obj/item/boulder/Initialize(mapload)
	. = ..()
	register_context()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 0, force_wielded = 5) //Heavy as all hell, it's a boulder, dude.
	AddComponent(/datum/component/sisyphus_awarder)
	AddElement(/datum/element/bane, mob_biotypes = MOB_SPECIAL, added_damage = 20, requires_combat_mode = FALSE)

/obj/item/boulder/Destroy(force)
	SSore_generation.available_boulders -= src
	processed_by = null
	return ..()

/obj/item/boulder/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(held_item && (held_item.tool_behaviour == TOOL_MINING || HAS_TRAIT(held_item, TRAIT_BOULDER_BREAKER)))
		context[SCREENTIP_CONTEXT_LMB] = "Crush boulder into ore"
		return CONTEXTUAL_SCREENTIP_SET
	else if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		if(isbasicmob(user))
			context[SCREENTIP_CONTEXT_LMB] = "Crush boulder into ore"
		else
			context[SCREENTIP_CONTEXT_RMB] = "Crush boulder into ore"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/boulder/examine(mob/user)
	. = ..()
	. += span_notice("This boulder would take [durability] more steps to refine or break.")
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		. += span_notice("You can crush this boulder with your bare hands.")

/obj/item/boulder/examine_more(mob/user)
	. = ..()
	. += span_notice("[span_bold("Boulders")] can either be cracked open by [span_bold("mining tools")], or processed into sheets with [span_bold("refineries or smelters")]. Undisturbed boulders can be collected by the [span_bold("BRM")].")

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

/obj/item/boulder/CanAllowThrough(atom/movable/mover, border_dir)
	if(istype(mover, /obj/item/boulder)) //This way, boulders can only go one at a time on conveyor belts, but everyone else can go through.
		return FALSE
	return ..()

/obj/item/boulder/attack_self(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		manual_process(null, user, INATE_BOULDER_SPEED_MULTIPLIER)
		return

/obj/item/boulder/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		manual_process(null, user, INATE_BOULDER_SPEED_MULTIPLIER)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/boulder/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (HAS_TRAIT(tool, TRAIT_BOULDER_BREAKER))
		manual_process(tool, user, INATE_BOULDER_SPEED_MULTIPLIER)
		return ITEM_INTERACT_SUCCESS
	if (tool.tool_behaviour == TOOL_MINING)
		manual_process(tool, user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/boulder/attack_basic_mob(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		manual_process(null, user, INATE_BOULDER_SPEED_MULTIPLIER) //A little hacky but it works around the speed of the blackboard task selection process for now.

/obj/item/boulder/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(istype(interacting_with, /turf/open/lava))
		if(!create_platform(interacting_with, user, null))
			return ITEM_INTERACT_BLOCKING
		return ITEM_INTERACT_SUCCESS

/obj/item/boulder/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, gentle, quickstart, throw_type_path)
	. = ..()
	if(istype(target, /turf/open/lava))
		if(!create_platform(target, thrower))
			return FALSE

/obj/item/boulder/proc/create_platform(atom/interacting_with, mob/living/user, timer_override = null)
	if(locate(/obj/structure/lattice/catwalk/boulder, interacting_with))
		if(user)
			to_chat(user, span_warning("There is already a boulder platform here!"))
		return null

	var/active_platform_lifespan = platform_lifespan //Default to the assigned value.
	if(timer_override)
		active_platform_lifespan = timer_override

	var/obj/structure/lattice/catwalk/boulder/platform = new(interacting_with)
	addtimer(CALLBACK(platform, TYPE_PROC_REF(/obj/structure/lattice/catwalk/boulder, pre_self_destruct)), active_platform_lifespan)
	// See Lattice.dm for more info
	visible_message(span_notice("\The [src] floats on \the [interacting_with], forming a temporary platform!"))
	qdel(src)
	return platform

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
	var/skill_modifier = user.mind?.get_skill_modifier(/datum/skill/mining, SKILL_SPEED_MODIFIER) || 1
	if(weapon)
		if(HAS_TRAIT(weapon, TRAIT_INSTANTLY_PROCESSES_BOULDERS))
			durability = 0
		process_speed = weapon.toolspeed
		weapon.play_tool_sound(src, 50)
		if(!continued)
			to_chat(user, span_notice("You swing at \the [src]..."))

	// Handle user conditions/override conditions.
	else if (override_speed_multiplier || HAS_TRAIT(user, TRAIT_BOULDER_BREAKER))
		if(HAS_TRAIT(user, TRAIT_INSTANTLY_PROCESSES_BOULDERS))
			durability = 0
		else if(override_speed_multiplier)
			process_speed = override_speed_multiplier
		else
			process_speed = INATE_BOULDER_SPEED_MULTIPLIER
		playsound(src, 'sound/effects/rock/rocktap1.ogg', 50)
		if(!continued)
			to_chat(user, span_notice("You scrape away at \the [src]..."))
	else
		CRASH("No weapon, acceptable user, or override speed multiplier passed to manual_process()")
	if(durability > 0)
		if(!do_after(user, (2 * process_speed * skill_modifier SECONDS), target = src))
			return
		if(!user.Adjacent(src))
			return
		durability--
		user.apply_damage(4 * skill_modifier, STAMINA)
	if(durability <= 0)
		convert_to_ore()
		to_chat(user, span_notice("You finish working on \the [src], and it crumbles into ore."))
		playsound(src, 'sound/effects/rock/rock_break.ogg', 50)
		user.mind?.adjust_experience(/datum/skill/mining, MINING_SKILL_BOULDER_SIZE_XP * 0.2)
		user.mind?.adjust_experience(/datum/skill/athletics, MINING_SKILL_BOULDER_SIZE_XP * 0.2)
		qdel(src)
		return
	var/msg = (durability == 1 ? "is crumbling!" : "looks weaker!")
	to_chat(user, span_notice("\The [src] [msg]"))
	manual_process(weapon, user, override_speed_multiplier, continued = TRUE)

/**
 * This function is called while breaking boulders manually, and drops ore based on the boulder's mineral content.
 * Quantity of ore spawned here is 1 less than if the boulder was processed by a machine, but clamped at 10 maximum, 1 minimum.
 *
 * target_destination: Optional - Sets the location directly instead of dropping it
 */
/obj/item/boulder/proc/convert_to_ore(atom/target_destination)
	for(var/datum/material/picked in custom_materials)
		var/obj/item/stack/ore/cracked_ore // Take the associated value and convert it into ore stacks...
		var/quantity = clamp(round((custom_materials[picked] - SHEET_MATERIAL_AMOUNT)/SHEET_MATERIAL_AMOUNT), 1, 10) //but less resources than if they processed it by hand.

		var/cracked_ore_type = picked.ore_type
		if(isnull(cracked_ore_type))
			stack_trace("boulder found containing material type [picked.type] with no set ore_type")
			continue
		var/atom/ore_destination = drop_location()
		if(target_destination)
			ore_destination = target_destination
		cracked_ore = new cracked_ore_type (ore_destination, quantity)
		SSblackbox.record_feedback("tally", "ore_mined", quantity, cracked_ore.type)

///Moves boulder contents to the drop location, and then deletes the boulder.
/obj/item/boulder/proc/break_apart()
	if(length(contents))
		var/list/quips = list("Clang!", "Crack!", "Bang!", "Clunk!", "Clank!")
		visible_message(span_notice("[pick(quips)] Something falls out of \the [src]!"))
		playsound(loc, 'sound/effects/pickaxe/picaxe1.ogg', 60, FALSE)
		for(var/obj/item/content as anything in contents)
			content.forceMove(get_turf(src))
	qdel(src)

#undef PLATFORM_WARNING_MODIFIER
