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
	obj_integrity = 300
	max_integrity = 300
	heat_proof = 1
	glass = 1
	var/nextstate = null
	sub_door = 1
	explosion_block = 1
	safe = FALSE
	closingLayer = CLOSED_FIREDOOR_LAYER
	assemblytype = /obj/structure/firelock_frame
	armor = list(melee = 30, bullet = 30, laser = 20, energy = 20, bomb = 10, bio = 100, rad = 100, fire = 95, acid = 70)
	CanAtmosPass = ATMOS_PASS_PROC
	var/boltslocked = TRUE

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(panel_open || operating)
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


/obj/machinery/door/firedoor/attackby(obj/item/weapon/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return
	
	if(welded)
		if(istype(C, /obj/item/weapon/wrench))
			if(boltslocked)
				user << "<span class='notice'>There are screws locking the bolts in place!</span>"
				return
			playsound(get_turf(src), C.usesound, 50, 1)
			user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
								 "<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
			if(!do_after(user, 50*C.toolspeed, target = src))
				return
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
								 "<span class='notice'>You undo [src]'s floor bolts.</span>")
			deconstruct(TRUE)
			return
		if(istype(C, /obj/item/weapon/screwdriver))
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts...</span>", \
								 "<span class='notice'>You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts...</span>")
			playsound(get_turf(src), C.usesound, 50, 1)
			boltslocked = !boltslocked
			return

	return ..()

/obj/machinery/door/firedoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/firedoor/try_to_weld(obj/item/weapon/weldingtool/W, mob/user)
	if(W.remove_fuel(0, user))
		welded = !welded
		user << "<span class='danger'>You [welded?"welded":"unwelded"] \the [src]</span>"
		update_icon()

/obj/machinery/door/firedoor/try_to_crowbar(obj/item/I, mob/user)
	if(welded || operating)
		return

	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || stat & NOPOWER)
		return
	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		user << "<span class='warning'>[src] refuses to budge!</span>"
		return
	open()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon()
	cut_overlays()
	if(density)
		icon_state = "door_closed"
		if(welded)
			add_overlay("welded")
	else
		icon_state = "door_open"
		if(welded)
			add_overlay("welded_open")

/obj/machinery/door/firedoor/open()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/close()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
		if(disassembled)
			F.constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			F.constructionStep = CONSTRUCTION_WIRES_EXPOSED
			F.obj_integrity = F.max_integrity * 0.5
		F.update_icon()
	qdel(src)


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

/obj/machinery/door/firedoor/border_only/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/Doorfire.dmi'
	glass = 0
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	obj_integrity = 550
	max_integrity = 550


/obj/item/weapon/electronics/firelock
	name = "firelock circuitry"
	desc = "A circuit board used in construction of firelocks."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "frame1"
	anchored = 0
	density = 1
	var/constructionStep = CONSTRUCTION_NOCIRCUIT
	var/reinforced = 0

/obj/structure/firelock_frame/examine(mob/user)
	..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			user << "There is a small metal plate covering the wires."
		if(CONSTRUCTION_WIRES_EXPOSED)
			user << "Wires are trailing from the maintenance panel."
		if(CONSTRUCTION_GUTTED)
			user << "The circuit board is visible."
		if(CONSTRUCTION_NOCIRCUIT)
			user << "There are no electronics in the frame."

/obj/structure/firelock_frame/update_icon()
	..()
	icon_state = "frame[constructionStep]"

/obj/structure/firelock_frame/attackby(obj/item/weapon/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(istype(C, /obj/item/weapon/crowbar))
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
									 "<span class='notice'>You begin prying out the wire cover...</span>")
				if(!do_after(user, 50*C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] pries out a metal plate from [src], exposing the wires.</span>", \
									 "<span class='notice'>You remove the cover plate from [src], exposing the wires.</span>")
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
			if(istype(C, /obj/item/weapon/wrench))
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					user << "<span class='warning'>There's already a firelock there.</span>"
					return
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
									 "<span class='notice'>You begin bolting [src]...</span>")
				if(!do_after(user, 30*C.toolspeed, target = src))
					return
				if(locate(/obj/machinery/door/firedoor) in get_turf(src))
					return
				user.visible_message("<span class='notice'>[user] finishes the firelock.</span>", \
									 "<span class='notice'>You finish the firelock.</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(reinforced)
					new /obj/machinery/door/firedoor/heavy(get_turf(src))
				else
					new /obj/machinery/door/firedoor(get_turf(src))
				qdel(src)
				return
			if(istype(C, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = C
				if(reinforced)
					user << "<span class='warning'>[src] is already reinforced.</span>"
					return
				if(P.get_amount() < 2)
					user << "<span class='warning'>You need more plasteel to reinforce [src].</span>"
					return
				user.visible_message("<span class='notice'>[user] begins reinforcing [src]...</span>", \
									 "<span class='notice'>You begin reinforcing [src]...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || P.get_amount() < 2 || !P)
						return
					user.visible_message("<span class='notice'>[user] reinforces [src].</span>", \
										 "<span class='notice'>You reinforce [src].</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					P.use(2)
					reinforced = 1
				return

		if(CONSTRUCTION_WIRES_EXPOSED)
			if(istype(C, /obj/item/weapon/wirecutters))
				playsound(get_turf(src), C.usesound, 50, 1)
				user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
									 "<span class='notice'>You begin removing [src]'s wires...</span>")
				if(!do_after(user, 60*C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", \
									 "<span class='notice'>You remove the wiring from [src], exposing the circuit board.</span>")
				var/obj/item/stack/cable_coil/B = new(get_turf(src))
				B.amount = 5
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(istype(C, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/W = C
				if(W.remove_fuel(1, user))
					playsound(get_turf(src), W.usesound, 50, 1)
					user.visible_message("<span class='notice'>[user] starts welding a metal plate into [src]...</span>", \
										 "<span class='notice'>You begin welding the cover plate back onto [src]...</span>")
					if(!do_after(user, 80*C.toolspeed, target = src))
						return
					if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
						return
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] welds the metal plate into [src].</span>", \
										 "<span class='notice'>You weld [src]'s cover plate into place, hiding the wires.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
		if(CONSTRUCTION_GUTTED)
			if(istype(C, /obj/item/weapon/crowbar))
				user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
									 "<span class='notice'>You begin prying out the circuit board from [src]...</span>")
				playsound(get_turf(src), C.usesound, 50, 1)
				if(!do_after(user, 50*C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_GUTTED)
					return
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
									 "<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/weapon/electronics/firelock(get_turf(src))
				playsound(get_turf(src), C.usesound, 50, 1)
				constructionStep = CONSTRUCTION_NOCIRCUIT
				update_icon()
				return
			if(istype(C, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/B = C
				if(B.get_amount() < 5)
					user << "<span class='warning'>You need more wires to add wiring to [src].</span>"
					return
				user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
									 "<span class='notice'>You begin adding wires to [src]...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_GUTTED || B.get_amount() < 5 || !B)
						return
					user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
										 "<span class='notice'>You wire [src].</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					B.use(5)
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					update_icon()
				return
		if(CONSTRUCTION_NOCIRCUIT)
			if(istype(C, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/W = C
				if(W.remove_fuel(1,user))
					playsound(get_turf(src), W.usesound, 50, 1)
					user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
										 "<span class='notice'>You begin slicing [src] apart...</span>")
					if(!do_after(user, 80*C.toolspeed, target = src))
						return
					if(constructionStep != CONSTRUCTION_NOCIRCUIT)
						return
					user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into metal.</span>")
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
					var/turf/T = get_turf(src)
					new /obj/item/stack/sheet/metal(T, 3)
					if(reinforced)
						new /obj/item/stack/sheet/plasteel(T, 2)
					qdel(src)
				return
			if(istype(C, /obj/item/weapon/electronics/firelock))
				user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
									 "<span class='notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(!do_after(user, 40, target = src))
					return
				if(constructionStep != CONSTRUCTION_NOCIRCUIT)
					return
				user.drop_item()
				qdel(C)
				user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
									 "<span class='notice'>You insert and secure [C].</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
	return ..()

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = 1
