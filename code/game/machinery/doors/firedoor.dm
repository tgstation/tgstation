/var/const/OPEN = 1
/var/const/CLOSED = 2

/obj/machinery/door/firedoor
	name = "firelock"
	desc = "Apply crowbar."
	icon = 'icons/obj/doors/Doorfireglass.dmi'
	icon_state = "door_open"
	opacity = 0
	density = 0
	heat_proof = 1
	glass = 1
	var/blocked = 0
	var/nextstate = null
	sub_door = 1
	closingLayer = 3.11

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)
		return
	if(!density)
		return ..()
	return 0


/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	return


/obj/machinery/door/firedoor/attackby(obj/item/weapon/C as obj, mob/user as mob, params)
	add_fingerprint(user)
	if(operating)	return//Already doing something.
	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user << text("<span class='danger'>You [blocked?"welded":"unwelded"] \the [src]</span>")
			update_icon()
			return

	if(istype(C, /obj/item/weapon/crowbar) || (istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1))
		if(blocked || operating)	return
		if(density)
			open()
			return
		else	//close it up again	//fucking 10/10 commenting here einstein
			close()
			return
	return

/obj/machinery/door/firedoor/attack_ai(mob/user as mob)
	add_fingerprint(user)
	if(blocked || operating || stat & NOPOWER)
		return
	if(density)
		open()
	else
		close()
	return

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	return


/obj/machinery/door/firedoor/update_icon()
	overlays.Cut()
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += "welded"
	else
		icon_state = "door_open"
		if(blocked)
			overlays += "welded_open"
	return

/obj/machinery/door/firedoor/open()
	..()
	latetoggle()
	return

/obj/machinery/door/firedoor/close()
	..()
	if(locate(/mob/living) in get_turf(src))
		open()
		return
	latetoggle()
	return

/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(OPEN)
			nextstate = null
			open()
		if(CLOSED)
			nextstate = null
			close()
	return


/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags = ON_BORDER

/obj/machinery/door/firedoor/border_only/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CanAtmosPass(var/turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1


/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/Doorfire.dmi'
	glass = 0


