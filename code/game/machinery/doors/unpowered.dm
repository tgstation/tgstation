<<<<<<< HEAD
/obj/machinery/door/unpowered

/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(src.locked)
		return
	..()
	return


/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user, params)
	if(locked)
		return
	else
		return ..()

/obj/machinery/door/unpowered/emag_act()
	return

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1
	explosion_block = 1
=======
/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0


/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(locked)
		return

	..(AM)
	return

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	// TODO: is energy blade only attack circuity like emag?
	if (istype(I, /obj/item/weapon/card/emag))
		return

	if (locked)
		return

	..()
	return

/obj/machinery/door/unpowered/attack_hand(mob/user as mob)
	if(istype(user,/mob/dead/observer))
		return
	..()

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/obj/doors/shuttle.dmi'
	icon_state = "door_closed"
	animation_delay = 5

	explosion_block = 1

/obj/machinery/door/unpowered/shuttle/cultify()
	new /obj/machinery/door/mineral/wood(loc)
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
