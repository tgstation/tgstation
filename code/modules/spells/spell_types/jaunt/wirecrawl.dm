/**
 * ### Wire Crawl
 *
 * Lets the caster enter and exit wires. Most of the code is directly comparable to blood crawl.
 */
/datum/action/cooldown/spell/jaunt/wirecrawl
	name = "Wire Crawl"
	desc = "Allows you to condense into pure electricity and travel along power wires."

	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "wirecrawl"

	spell_requirements = NONE

	/// The time it takes to enter blood
	var/enter_wire_time = 5 SECONDS
	/// The time it takes to exit blood
	var/exit_wire_time = 5 SECONDS
	/// The radius around us that we look for blood in
	var/wire_radius = 1
	/// If TRUE, we equip "blood crawl" hands to the jaunter to prevent using items
	var/equip_wire_hands = TRUE

/datum/action/cooldown/spell/jaunt/wirecrawl/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))

/datum/action/cooldown/spell/jaunt/wirecrawl/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/jaunt/wirecrawl/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(find_nearby_wires(get_turf(owner)))
		return TRUE
	if(feedback)
		to_chat(owner, span_warning("There must be a nearby source of blood!"))
	return FALSE

/datum/action/cooldown/spell/jaunt/wirecrawl/cast(mob/living/cast_on)
	. = ..()
	// Should always return something because we checked that in can_cast_spell before arriving here
	var/obj/effect/decal/cleanable/blood_nearby = find_nearby_wires(get_turf(cast_on))
	do_bloodcrawl(blood_nearby, cast_on)

/// Returns a nearby blood decal, or null if there aren't any
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/find_nearby_wires(turf/origin)
	for(var/obj/structure/cable/wire_nearby in range(wire_radius, origin))
		if(wire_nearby.can_wirecrawl_in())
			return wire_nearby
	return null

/**
 * Attempts to enter or exit the passed blood pool.
 * Returns TRUE if we successfully entered or exited said pool, FALSE otherwise
 */
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/do_bloodcrawl(obj/structure/cable/wire, mob/living/jaunter)
	if(is_jaunting(jaunter))
		. = try_exit_jaunt(wire, jaunter)
	else
		. = try_enter_jaunt(wire, jaunter)

	if(!.)
		reset_spell_cooldown()
		to_chat(jaunter, span_warning("You are unable to wire crawl!"))

/**
 * Attempts to enter the passed blood pool.
 * If forced is TRUE, it will override enter_wire_time.
 */
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/try_enter_jaunt(obj/structure/cable/wire, mob/living/jaunter, forced = FALSE)
	if(!forced)
		if(enter_wire_time > 0 SECONDS)
			wire.visible_message(span_warning("[jaunter] turns into electricity for a split-second as their form sinks into [wire]!"))
			if(!do_after(jaunter, enter_wire_time, target = wire))
				return FALSE

	// The actual turf we enter
	var/turf/jaunt_turf = get_turf(wire)

	// Begin the jaunt
	ADD_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	var/obj/effect/dummy/phased_mob/holder = enter_jaunt(jaunter, jaunt_turf)
	if(!holder)
		REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
		return FALSE

	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_status_on_signal))
	if(equip_wire_hands && iscarbon(jaunter))
		jaunter.drop_all_held_items()
		// Give them some bloody hands to prevent them from doing things
		var/obj/item/wirecrawl/left_hand = new(jaunter)
		var/obj/item/wirecrawl/right_hand = new(jaunter)
		left_hand.icon_state = "electrichand_right" // Icons swapped intentionally..
		right_hand.icon_state = "electrichand_left" // ..because perspective, or something
		jaunter.put_in_hands(left_hand)
		jaunter.put_in_hands(right_hand)

	wire.visible_message(span_warning("[jaunter] turns into electricity for a split-second as their form sinks into [wire]!"))
	playsound(jaunt_turf, 'sound/effects/empulse.ogg', 50, TRUE, -1)
	jaunter.extinguish_mob()

	REMOVE_TRAIT(jaunter, TRAIT_NO_TRANSFORM, REF(src))
	return TRUE

/**
 * Attempts to Exit the passed blood pool.
 * If forced is TRUE, it will override exit_wire_time, and if we're currently consuming someone.
 */
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/try_exit_jaunt(obj/structure/cable/wire, mob/living/jaunter, forced = FALSE)
	if(!forced)
		if(HAS_TRAIT(jaunter, TRAIT_NO_TRANSFORM))
			to_chat(jaunter, span_warning("You cannot exit yet!!"))
			return FALSE

		if(exit_wire_time > 0 SECONDS)
			wire.visible_message(span_warning("[wire] starts to spark..."))
			if(!do_after(jaunter, exit_wire_time, target = wire))
				return FALSE

	if(!exit_jaunt(jaunter, get_turf(wire)))
		return FALSE

	wire.visible_message(span_boldwarning("[jaunter] rises out of [wire]!"))
	return TRUE

/datum/action/cooldown/spell/jaunt/wirecrawl/on_jaunt_exited(obj/effect/dummy/phased_mob/jaunt, mob/living/unjaunter)
	UnregisterSignal(jaunt, COMSIG_MOVABLE_MOVED)
	exit_wire_effect(unjaunter)
	if(equip_wire_hands && iscarbon(unjaunter))
		for(var/obj/item/wirecrawl/wire_hand in unjaunter.held_items)
			unjaunter.temporarilyRemoveItemFromInventory(wire_hand, force = TRUE)
			qdel(wire_hand)
	return ..()

/// Adds an coloring effect to mobs which exit blood crawl.
/datum/action/cooldown/spell/jaunt/wirecrawl/proc/exit_wire_effect(mob/living/exited)
	var/turf/landing_turf = get_turf(exited)
	playsound(landing_turf, 'sound/effects/empulse.ogg', 50, TRUE, -1)

	// Make the mob have the color of the wires it came out of
	var/obj/structure/cable/came_from = locate() in landing_turf
	var/new_color = came_from?.get_wire_color()
	if(!new_color)
		return

	exited.add_atom_colour(new_color, TEMPORARY_COLOUR_PRIORITY)
	// ...but only for a few seconds
	addtimer(CALLBACK(exited, TYPE_PROC_REF(/atom/, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, new_color), 6 SECONDS)

/// Wirecrawl "hands", prevent the user from holding items in wirecrawl
/obj/item/wirecrawl
	name = "wire crawl"
	desc = "You are unable to hold anything while in this form."
	icon = 'icons/effects/blood.dmi' // Also within the same blood.dmi to pay respects to it's sister, bloodcrawl.
	item_flags = ABSTRACT | DROPDEL

/obj/item/wirecrawl/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
