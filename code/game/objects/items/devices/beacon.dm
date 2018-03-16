/obj/item/device/beacon
	name = "\improper tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	item_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	anchored = FALSE
	var/enabled = TRUE
	var/renamed = FALSE

/obj/item/device/beacon/Initialize()
	. = ..()
	if (enabled)
		GLOB.teleportbeacons += src
	else
		icon_state = "beacon-off"

/obj/item/device/beacon/Destroy()
	GLOB.teleportbeacons.Remove(src)
	return ..()

/obj/item/device/beacon/attack_self(mob/user)
	enabled = !enabled
	if (enabled)
		icon_state = "beacon"
		GLOB.teleportbeacons += src
	else
		icon_state = "beacon-off"
		GLOB.teleportbeacons.Remove(src)
	to_chat(user, "<span class='notice'>You [enabled ? "enable" : "disable"] the beacon.</span>")
	return

/obj/item/device/beacon/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/gun/energy/e_gun/dragnet))
		var/obj/item/gun/energy/e_gun/dragnet/D = W
		D.set_target(src, user)

	if(istype(W, /obj/item/pen)) // needed for things that use custom names like the locator
		var/new_name = stripped_input(user, "What would you like the name to be?")
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(new_name)
			name = new_name
			renamed = TRUE
		return

	return ..()

/obj/item/device/beacon/examine(mob/user)
	..()
	if(!anchored)
		to_chat(user, "<span class='notice'>It is unsecured from the floor.</span>")
	else
		to_chat(user, "<span class='notice'>It is secured to the floor.</span>")

/obj/item/device/beacon/wrench_act(mob/living/user, obj/item/I)
	var/turf/T = get_turf(src)
	if(!(T.intact && isfloorturf(T)))
		to_chat(user, "<span class='notice'>You need a floor to fasten this to!</span>")
		return

	anchored = !anchored
	if(anchored)
		to_chat(user, "<span class='notice'>You fasten [src] to the floor.</span>")
	else
		to_chat(user, "<span class='notice'>You unfasten [src] from the floor.</span>")
	I.play_tool_sound(src, 100)

	return TRUE