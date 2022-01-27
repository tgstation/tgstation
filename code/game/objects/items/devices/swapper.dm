/obj/item/swapper
	name = "quantum spin inverter"
	desc = "An experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	icon = 'icons/obj/device.dmi'
	icon_state = "swapper"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	var/cooldown = 300
	var/next_use = 0
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

/obj/item/swapper/attackby(obj/item/I, mob/user, params)
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
	playsound(src, 'sound/weapons/flash.ogg', 25, TRUE)
	to_chat(user, span_notice("You activate [src]."))
	playsound(linked_swapper, 'sound/weapons/flash.ogg', 25, TRUE)
	if(ismob(linked_swapper.loc))
		var/mob/holder = linked_swapper.loc
		to_chat(holder, span_notice("[linked_swapper] starts buzzing."))
	next_use = world.time + cooldown //only the one used goes on cooldown
	addtimer(CALLBACK(src, .proc/swap, user), 25)

/obj/item/swapper/examine(mob/user)
	. = ..()
	if(world.time < next_use)
		. += span_warning("Time left to recharge: [DisplayTimeText(next_use - world.time)].")
	if(linked_swapper)
		. += span_notice("<b>Linked.</b> Alt-Click to break the quantum link.")
	else
		. += span_notice("<b>Not Linked.</b> Use on another quantum spin inverter to establish a quantum link.")

/obj/item/swapper/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	to_chat(user, span_notice("You break the current quantum link."))
	if(!QDELETED(linked_swapper))
		linked_swapper.linked_swapper = null
		linked_swapper.update_appearance()
		linked_swapper = null
	update_appearance()

//Gets the topmost teleportable container
/obj/item/swapper/proc/get_teleportable_container()
	var/atom/movable/teleportable = src
	while(ismovable(teleportable.loc))
		var/atom/movable/AM = teleportable.loc
		if(AM.anchored)
			break
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.buckled)
				if(L.buckled.anchored)
					break
				else
					var/obj/buckled_obj = L.buckled
					buckled_obj.unbuckle_mob(L)
		teleportable = AM
	return teleportable

/obj/item/swapper/proc/swap(mob/user)
	if(QDELETED(linked_swapper) || world.time < linked_swapper.cooldown)
		return

	var/atom/movable/A = get_teleportable_container()
	var/atom/movable/B = linked_swapper.get_teleportable_container()
	var/target_A = A.drop_location()
	var/target_B = B.drop_location()

	//TODO: add a sound effect or visual effect
	if(do_teleport(A, target_B, channel = TELEPORT_CHANNEL_QUANTUM))
		do_teleport(B, target_A, channel = TELEPORT_CHANNEL_QUANTUM)
		if(ismob(B))
			var/mob/M = B
			to_chat(M, span_warning("[linked_swapper] activates, and you find yourself somewhere else."))
