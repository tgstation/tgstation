/// Max number of atoms a broom can sweep at once
#define BROOM_PUSH_LIMIT 20

/obj/item/pushbroom
	name = "push broom"
	desc = "This is my BROOMSTICK! It can be used manually or braced with two hands to sweep items as you move. It has a telescopic handle for compact storage."
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "broom0"
	base_icon_state = "broom"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("sweeps", "brushes off", "bludgeons", "whacks")
	attack_verb_simple = list("sweep", "brush off", "bludgeon", "whack")
	resistance_flags = FLAMMABLE

/obj/item/pushbroom/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting, damage_boost_per_tile = 1)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 8, \
		force_wielded = 12, \
		icon_wielded = "[base_icon_state]1", \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)

/obj/item/pushbroom/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/**
 * Handles registering the sweep proc when the broom is wielded
 *
 * Arguments:
 * * source - The source of the on_wield proc call
 * * user - The user which is wielding the broom
 */
/obj/item/pushbroom/proc/on_wield(obj/item/source, mob/user)
	to_chat(user, span_notice("You brace the [src] against the ground in a firm sweeping stance."))
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(sweep))

/**
 * Handles unregistering the sweep proc when the broom is unwielded
 *
 * Arguments:
 * * source - The source of the on_unwield proc call
 * * user - The user which is unwielding the broom
 */
/obj/item/pushbroom/proc/on_unwield(obj/item/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)

/obj/item/pushbroom/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	sweep(user, interacting_with)
	return NONE // I guess

/**
 * Attempts to push up to BROOM_PUSH_LIMIT atoms from a given location the user's faced direction
 *
 * Arguments:
 * * user - The user of the pushbroom
 * * A - The atom which is located at the location to push atoms from
 */
/obj/item/pushbroom/proc/sweep(mob/user, atom/atom)
	SIGNAL_HANDLER

	do_sweep(src, user, atom, user.dir)

/**
* Sweep objects in the direction we're facing towards our direction
* Arguments
* * broomer - The object being used for brooming
* * user - The person who is brooming
* * target - The object or tile that's target of a broom click or being moved into
* * sweep_dir - The directions in which we sweep objects
*/
/proc/do_sweep(obj/broomer, mob/user, atom/target, sweep_dir)
	var/turf/current_item_loc = isturf(target) ? target : target.loc
	if (!isturf(current_item_loc))
		return
	var/turf/new_item_loc = get_step(current_item_loc, sweep_dir)

	var/list/items_to_sweep = list()
	var/i = 1
	for (var/obj/item/garbage in current_item_loc.contents)
		if(garbage.anchored)
			continue
		items_to_sweep += garbage
		i++
		if(i > BROOM_PUSH_LIMIT)
			break

	SEND_SIGNAL(new_item_loc, COMSIG_TURF_RECEIVE_SWEEPED_ITEMS, broomer, user, items_to_sweep)

	if(!length(items_to_sweep))
		return

	for (var/obj/item/garbage in items_to_sweep)
		garbage.Move(new_item_loc, sweep_dir)

	playsound(current_item_loc, 'sound/weapons/thudswoosh.ogg', 30, TRUE, -1)

/obj/item/pushbroom/cyborg
	name = "cyborg push broom"

/obj/item/pushbroom/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

#undef BROOM_PUSH_LIMIT
