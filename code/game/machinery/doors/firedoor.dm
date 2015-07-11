#define CONSTRUCTION_COMPLETE 0 //No construction done - functioning as normal
#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_WIRES_EXPOSED 2 //Cover plate is removed, wires are available
#define CONSTRUCTION_GUTTED 3 //Wires are removed, circuit ready to remove
#define CONSTRUCTION_NOCIRCUIT 4 //Circuit board removed, can safely weld apart

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
	var/constructing = 0
	var/panelOpen = 0
	var/constructionStep = CONSTRUCTION_COMPLETE

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)	return
	if(!density)	return ..()
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

	if(constructing) //Construction steps
		if(!panelOpen)
			return
		switch(constructionStep)
			if(CONSTRUCTION_PANEL_OPEN)
				if(istype(C, /obj/item/weapon/crowbar))
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
										 "<span class='notice'>You begin prying out the wire cover...</span>")
					if(!do_after(user, 50)) return
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] pries out a metal plate from [src], exposing the wires.</span>", \
										 "<span class='notice'>You remove the cover plate from [src], exposing the wires.</span>")
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					return
			if(CONSTRUCTION_WIRES_EXPOSED)
				if(istype(C, /obj/item/weapon/wirecutters))
					playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
										 "<span class='notice'>You begin removing [src]'s wires...</span>")
					if(!do_after(user, 60)) return
					user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", \
										 "<span class='notice'>You remove the wiring from [src], exposing the circuit board.</span>")
					var/obj/item/stack/cable_coil/B = new(get_turf(user))
					B.amount = 5
					constructionStep = CONSTRUCTION_GUTTED
					return
				if(istype(C, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/W = C
					if(W.remove_fuel(1, user))
						playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
						user.visible_message("<span class='notice'>[user] starts welding a metal plate into [src]...</span>", \
											 "<span class='notice'>You begin welding the cover plate back onto [src]...</span>")
						if(!do_after(user, 80)) return
						playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
						user.visible_message("<span class='notice'>[user] welds the metal plate into [src].</span>", \
											 "<span class='notice'>You weld [src]'s cover plate into place, hiding the wires.</span>")
					constructionStep = CONSTRUCTION_PANEL_OPEN
					return
			if(CONSTRUCTION_GUTTED)
				if(istype(C, /obj/item/weapon/crowbar))
					user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
										 "<span class='notice'>You begin prying out the circuit board from [src]...</span>")
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					if(!do_after(user, 50)) return
					user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
										 "<span class='notice'>You remove the circuit board from [src].</span>")
					new /obj/item/weapon/firelock_board(get_turf(user))
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					constructionStep = CONSTRUCTION_NOCIRCUIT
					return
				if(istype(C, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/B = C
					if(B.amount < 5)
						user << "<span class='warning'>You need more wires to add wiring to [src].</span>"
						return
					user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
										 "<span class='notice'>You begin adding wires to [src]...</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					if(!do_after(user, 60)) return
					user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
										 "<span class='notice'>You wire [src].</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					B.use(5)
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					return
			if(CONSTRUCTION_NOCIRCUIT)
				if(istype(C, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/W = C
					if(!W.remove_fuel(1,user))
						playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
						user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame.</span>", \
											 "<span class='notice'>You begin slicing apart [src].</span>")
						if(!do_after(user, 80)) return
						user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
											 "<span class='notice'>You cut apart [src] into metal.</span>")
						playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
						var/obj/item/stack/sheet/metal/M = new(get_turf(user))
						M.amount = 7
					return
				if(istype(C, /obj/item/weapon/firelock_board))
					user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
										 "<span class='notice'>You begin adding a circuit board to [src]...</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					if(!do_after(user, 40)) return
					user.drop_item()
					qdel(C)
					user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
										 "<span class='notice'>You insert and secure [C].</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					constructionStep = CONSTRUCTION_GUTTED
					return


	if(istype(C, /obj/item/weapon/weldingtool) && !constructing)
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

	if(istype(C, /obj/item/weapon/screwdriver))
		panelOpen = !panelOpen
		if(panelOpen)
			user.visible_message("<span class='notice'>[user] opens [src]'s maintenance panel.</span>", \
								 "<span class='notice'>You unscrew [src]'s maintenance panel.</span>")
			constructing = 1
			constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			user.visible_message("<span class='notice'>[user] closes [src]'s maintenance panel.</span>", \
								 "<span class='notice'>You close [src]'s maintenance panel.</span>")
			constructing = 0
			constructionStep = CONSTRUCTION_COMPLETE
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
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
	if(constructing) return
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

/obj/item/weapon/firelock_board
	name = "firelock electronics"
	desc = "A circuit board used in construction of firelocks."
	icon = 'icons/obj/module.dmi'
	icon_state = "airalarm_electronics"
	w_class = 2
