/obj/item/swapper
	name = "quantum spin inverter"
	desc = "An experimental device that is able to swap the locations of two entities by switching their particles' spin values. Must be linked to another device to function."
	icon = 'icons/obj/device.dmi'
	icon_state = "swapper"
	item_state = "electronic"
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
		linked_swapper = null
	return ..()
	
/obj/item/swapper/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/swapper))
		var/obj/item/swapper/other_swapper = I
		if(other_swapper.linked_swapper)
			to_chat(user, "<span class='warning'>[other_swapper] is already linked. Break the current link to establish a new one.</span>")
			return
		if(linked_swapper)
			to_chat(user, "<span class='warning'>[src] is already linked. Break the current link to establish a new one.</span>")
			return
		to_chat(user, "<span class='notice'>You establish a quantum link between the two devices.</span>")
		linked_swapper = other_swapper
		other_swapper.linked_swapper = src
	else
		return ..()
	
/obj/item/swapper/attack_self(mob/living/user)
	if(world.time < next_use)
		to_chat(user, "<span class='warning'>[src] is still recharging.</span>")
		return
	if(!linked_swapper)
		to_chat(user, "<span class='warning'>[src] is not linked with another swapper.</span>")
		return
	if(world.time < linked_swapper.cooldown)
		to_chat(user, "<span class='warning'>[linked_swapper] is still recharging.</span>")
		return
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	addtimer(CALLBACK(src, .proc/swap, user), 25)
	
/obj/item/swapper/examine(mob/user)
	. = ..()
	if(world.time < next_use)
		to_chat(user, "<span class='warning'>Time left to recharge: [DisplayTimeText(next_use - world.time)]</span>")
	if(linked_swapper)
		to_chat(user, "<span class='notice'><b>Linked.</b> Alt-Click to break the quantum link.</span>")
	else
		to_chat(user, "<span class='notice'><b>Not Linked.</b> Use on another quantum spin inverter to establish a quantum link.</span>")

/obj/item/swapper/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	to_chat(user, "<span class='notice'>You break the current quantum link.</span>")
	linked_swapper = null
	
//Gets the topmost teleportable container	
/obj/item/swapper/proc/get_teleportable_container()
	var/atom/movable/teleportable = src
	while(ismovableatom(teleportable.loc))
		var/atom/movable/AM = loc
		if(AM.anchored)
			break
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.buckled && L.buckled.anchored)
				break		
		teleportable = AM
	return teleportable
	
/obj/item/swapper/proc/swap(mob/user)
	if(QDELETED(linked_swapper) || world.time < linked_swapper.cooldown)
		return
		
	var/atom/movable/A = get_teleportable_container()
	var/atom/movable/B = linked_swapper.get_teleportable_container()
	var/turf/turf_A = get_turf(A)
	var/turf/turf_B = get_turf(B)
	
	//TODO: add a sound effect or visual effect
	if(do_teleport(A, turf_B, forced_teleport = TRUE))
		do_teleport(B, turf_A, forced_teleport = TRUE)
		if(ismob(B))
			var/mob/M = B
			to_chat(M, "<span class='warning'>[linked_swapper] suddenly activates, and you find yourself somewhere else.</span>")
		next_use = world.time + cooldown //only the one used goes on cooldown
	