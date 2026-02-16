/obj/item/swapper
	name = "quantum spin inverter"
	desc = "An experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "swapper"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	interaction_flags_click = NEED_DEXTERITY|ALLOW_RESTING
	/// Cooldown for usage
	var/cooldown = 30 SECONDS
	/// Next available time
	var/next_use = 0
	/// Swapper linked to this obj
	var/obj/item/swapper/linked_swapper

/obj/item/swapper/Destroy()
	if(linked_swapper)
		linked_swapper.linked_swapper = null //*inception music*
		linked_swapper.update_appearance()
		linked_swapper = null
	return ..()

/obj/item/swapper/update_icon_state()
	icon_state = "swapper[linked_swapper ? "-linked" : null]"
	return ..()

/obj/item/swapper/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(I, /obj/item/swapper))
		var/obj/item/swapper/other_swapper = I
		if(other_swapper.linked_swapper)
			to_chat(user, span_warning("[other_swapper] is already linked. Break the current link to establish a new one."))
			return
		if(linked_swapper)
			to_chat(user, span_warning("[src] is already linked. Break the current link to establish a new one."))
			return
		to_chat(user, span_notice("You establish a quantum link between the two devices."))
		linked_swapper = other_swapper
		other_swapper.linked_swapper = src
		update_appearance()
		linked_swapper.update_appearance()
	else
		return ..()

/obj/item/swapper/attack_self(mob/living/user)
	if(world.time < next_use)
		to_chat(user, span_warning("[src] is still recharging."))
		return
	if(QDELETED(linked_swapper))
		to_chat(user, span_warning("[src] is not linked with another swapper."))
		return
	playsound(src, 'sound/items/weapons/flash.ogg', 25, TRUE)
	to_chat(user, span_notice("You activate [src]."))
	playsound(linked_swapper, 'sound/items/weapons/flash.ogg', 25, TRUE)
	if(ismob(linked_swapper.loc))
		var/mob/holder = linked_swapper.loc
		to_chat(holder, span_notice("[linked_swapper] starts buzzing."))
	next_use = world.time + cooldown //only the one used goes on cooldown
	addtimer(CALLBACK(src, PROC_REF(swap), user), 2.5 SECONDS)

/obj/item/swapper/examine(mob/user)
	. = ..()
	if(world.time < next_use)
		. += span_warning("Time left to recharge: [DisplayTimeText(next_use - world.time)].")
	if(linked_swapper)
		. += span_notice("<b>Linked.</b> Alt-Click to break the quantum link.")
	else
		. += span_notice("<b>Not Linked.</b> Use on another quantum spin inverter to establish a quantum link.")

/obj/item/swapper/click_alt(mob/living/user)
	to_chat(user, span_notice("You break the current quantum link."))
	if(!QDELETED(linked_swapper))
		linked_swapper.linked_swapper = null
		linked_swapper.update_appearance()
		linked_swapper = null
	update_appearance()
	return CLICK_ACTION_SUCCESS

/**
 * Swaps two atoms following the activation of a swapper item.
 * If a mob is holding a swapper, it will carry the mob as-per the rules of do_teleport().
 */
/obj/item/swapper/proc/swap(mob/user)
	if(QDELETED(linked_swapper) || isnull(linked_swapper.loc) || world.time < linked_swapper.cooldown)
		return

	var/atom/movable/container_A = get_teleportable_container(src)
	var/atom/movable/container_B = get_teleportable_container(linked_swapper)
	var/target_A = container_A.drop_location()
	var/target_B = container_B.drop_location()

	playsound(target_A, 'sound/effects/swapper/swap_a.ogg', 30, TRUE)
	playsound(target_B, 'sound/effects/swapper/swap_b.ogg', 30, TRUE)
	if(do_teleport(container_A, target_B, channel = TELEPORT_CHANNEL_QUANTUM))
		do_teleport(container_B, target_A, channel = TELEPORT_CHANNEL_QUANTUM)
		if(ismob(container_B))
			var/mob/swapped_mob = container_B
			to_chat(swapped_mob, span_warning("[linked_swapper] activates, and you find yourself somewhere else."))
