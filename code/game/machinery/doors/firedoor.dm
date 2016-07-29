<<<<<<< HEAD
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
	var/nextstate = null
	sub_door = 1
	closingLayer = CLOSED_FIREDOOR_LAYER
	assemblytype = /obj/structure/firelock_frame

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
		return//Already doing something.

	if(istype(C, /obj/item/weapon/wrench) && panel_open)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
							 "<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
		if(!do_after(user, 50/C.toolspeed, target = src))
			return
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
							 "<span class='notice'>You undo [src]'s floor bolts.</span>")
		var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
		F.constructionStep = CONSTRUCTION_PANEL_OPEN
		F.update_icon()
		qdel(src)
		return

	if(istype(C, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user, icon_state, icon_state, C)
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
	assemblytype = /obj/structure/firelock_frame/heavy

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
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
									 "<span class='notice'>You begin prying out the wire cover...</span>")
				if(!do_after(user, 50/C.toolspeed, target = src))
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
					user << "<span class='warning'>There's already a firlock there.</span>"
					return
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
									 "<span class='notice'>You begin bolting [src]...</span>")
				if(!do_after(user, 30/C.toolspeed, target = src))
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
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
									 "<span class='notice'>You begin removing [src]'s wires...</span>")
				if(!do_after(user, 60/C.toolspeed, target = src))
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
					playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] starts welding a metal plate into [src]...</span>", \
										 "<span class='notice'>You begin welding the cover plate back onto [src]...</span>")
					if(!do_after(user, 80/C.toolspeed, target = src))
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
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(!do_after(user, 50/C.toolspeed, target = src))
					return
				if(constructionStep != CONSTRUCTION_GUTTED)
					return
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
									 "<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/weapon/electronics/firelock(get_turf(src))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
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
					playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
										 "<span class='notice'>You begin slicing [src] apart...</span>")
					if(!do_after(user, 80/C.toolspeed, target = src))
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
=======
/var/const/OPEN = 1
/var/const/CLOSED = 2

var/global/list/alert_overlays_global = list()

/proc/convert_k2c(var/temp)
	return ((temp - T0C)) // * 1.8) + 32

/proc/convert_c2k(var/temp)
	return ((temp + T0C)) // * 1.8) + 32

/proc/getCardinalAirInfo(var/atom/source, var/turf/loc, var/list/stats=list("temperature"))
	var/list/temps = new/list(4)
	for(var/dir in cardinal)
		var/direction
		switch(dir)
			if(NORTH)
				direction = 1
			if(SOUTH)
				direction = 2
			if(EAST)
				direction = 3
			if(WEST)
				direction = 4

		var/turf/simulated/T=get_turf(get_step(loc,dir))

		if(dir == turn(source.dir, 180) && source.flags & ON_BORDER) //[   ][  |][   ] imagine the | is the source (with dir EAST -> facing right), and the brackets are floors. When we try to get the turf to the left's air info, use the middle's turf instead
			if(!(locate(/obj/machinery/door/airlock) in get_turf(source))) //If we're on a door, however, DON'T DO THIS -> doors are airtight, so the result will be innacurate! This is a bad snowflake, but as long as it makes the feature freeze go away...
				T = get_turf(source)

		var/list/rstats = new /list(stats.len)
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i=1;i<=stats.len;i++)
				rstats[i] = environment.vars[stats[i]]
		else if(istype(T, /turf/simulated))
			rstats = null // Exclude zone (wall, door, etc).
		else if(istype(T, /turf))
			// Should still work.  (/turf/return_air())
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i=1;i<=stats.len;i++)
				rstats[i] = environment.vars[stats[i]]
		temps[direction] = rstats
	return temps

#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
#define FIREDOOR_MAX_TEMP 50 // �C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT      1
#define FIREDOOR_ALERT_COLD     2
// Not used #define FIREDOOR_ALERT_LOWPRESS 4

#define FIREDOOR_CLOSED_MOD	0.8

/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip)
	opacity = 0
	density = 0
	layer = DOOR_LAYER - 0.2
	base_layer = DOOR_LAYER - 0.2

	dir = 2

	var/list/alert_overlays_local

	var/blocked = 0
	var/lockdown = 0 // When the door has detected a problem, it locks.
	var/pdiff_alert = 0
	var/pdiff = 0
	var/nextstate = null
	var/net_id
	var/list/areas_added
	var/list/users_to_open
	var/list/tile_info[4]
	var/list/dir_alerts[4] // 4 dirs, bitflags

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

/obj/machinery/door/firedoor/New()
	. = ..()

	if(!("[src.type]" in alert_overlays_global))
		alert_overlays_global += list("[src.type]" = list("alert_hot" = list(),
														"alert_cold" = list())
									)

		var/list/type_states = alert_overlays_global["[src.type]"]

		for(var/alert_state in type_states)
			var/list/starting = list()
			for(var/cdir in cardinal)
				starting["[cdir]"] = icon(src.icon, alert_state, dir = cdir)
			type_states[alert_state] = starting
		alert_overlays_global["[src.type]"] = type_states
		alert_overlays_local = type_states
	else
		alert_overlays_local = alert_overlays_global["[src.type]"]

	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			if(F.flags & ON_BORDER && src.flags & ON_BORDER && F.dir != src.dir) //two border doors on the same tile don't collide
				continue
			spawn(1)
				qdel(src)
			return .
	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		var/turf/T = get_step(src,direction)
		if(istype(T,/turf/simulated/floor))
			A = get_area(get_step(src,direction))
			if(A)
				A.all_doors |= src
				areas_added |= A


/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	. = ..()


/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		to_chat(user, "<span class='danger'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>")

	to_chat(user, "<b>Sensor readings:</b>")
	for(var/index = 1; index <= tile_info.len; index++)
		var/o = "&nbsp;&nbsp;"
		switch(index)
			if(1)
				o += "NORTH: "
			if(2)
				o += "SOUTH: "
			if(3)
				o += "EAST: "
			if(4)
				o += "WEST: "
		if(tile_info[index] == null)
			o += "<span class='warning'>DATA UNAVAILABLE</span>"
			to_chat(usr, o)
			continue
		var/celsius = convert_k2c(tile_info[index][1])
		var/pressure = tile_info[index][2]
		if(dir_alerts[index] & (FIREDOOR_ALERT_HOT|FIREDOOR_ALERT_COLD))
			o += "<span class='warning'>"
		else
			o += "<span style='color:blue'>"
		o += "[celsius]�C</span> "
		o += "<span style='color:blue'>"
		o += "[pressure]kPa</span></li>"
		to_chat(user, o)

	if( islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		to_chat(user, "These people have opened \the [src] during an alert: [users_to_open_string].")


/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if (mecha.occupant)
			var/mob/M = mecha.occupant
			attack_hand(M)
	return 0


/obj/machinery/door/firedoor/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_ai(mob/user)
	if(isobserver(user) || user.stat)
		return
	spawn()
		var/area/A = get_area_master(src)
		ASSERT(istype(A)) // This worries me.
		var/alarmed = A.doors_down || A.fire
		var/old_density = src.density
		if(old_density && alert("Override the [alarmed ? "alarming " : ""]firelock's safeties and open \the [src]?" ,,"Yes", "No") == "Yes")
			open()
		else if(!old_density)
			close()
		else
			return
		investigation_log(I_ATMOS, "[density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	return attackby(null, user)

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.
	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message("<span class='attack'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].</span>",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			update_icon()
			return

	if( iscrowbar(C) || ( istype(C,/obj/item/weapon/fireaxe) && C.wielded ) )
		force_open(user, C)
		return

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire

	var/access_granted = 0
	var/users_name
	if(!istype(C, /obj)) //If someone hit it with their hand.  We need to see if they are allowed.
		if(allowed(user))
			access_granted = 1
		if(ishuman(user))
			users_name = FindNameFromID(user)
		else
			users_name = "Unknown"

	if( ishuman(user) &&  !stat && ( istype(C, /obj/item/weapon/card/id) || istype(C, /obj/item/device/pda) ) )
		var/obj/item/weapon/card/id/ID = C

		if( istype(C, /obj/item/device/pda) )
			var/obj/item/device/pda/pda = C
			ID = pda.id
		if(!istype(ID))
			ID = null

		if(ID)
			users_name = ID.registered_name

		if(check_access(ID))
			access_granted = 1

	var/answer = "Yes"
	if(answer == "No")
		return
	if(user.locked_to)
		if(!istype(user.locked_to, /obj/structure/bed/chair/vehicle))
			to_chat(user, "Sorry, you must remain able bodied and close to \the [src] in order to use it.")
			return
	if(user.incapacitated() || get_dist(src, user) > 1)
		to_chat(user, "Sorry, you must remain able bodied and close to \the [src] in order to use it.")
		return

	if(alarmed && density && lockdown && !access_granted/* && !( users_name in users_to_open ) */)
		// Too many shitters on /vg/ for the honor system to work.
		to_chat(user, "<span class='warning'>Access denied. Please wait for authorities to arrive, or for the alert to clear.</span>")
		return
		// End anti-shitter system
		/*
		user.visible_message("<span class='warning'>\The [src] opens for \the [user]</span>",\
		"\The [src] opens after you acknowledge the consequences.",\
		"You hear a beep, and a door opening.")
		*/
	else
		user.visible_message("<span class='notice'>\The [src] [density ? "open" : "close"]s for \the [user].</span>",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")
		// Accountability!
		if(!users_to_open)
			users_to_open = list()
		users_to_open += users_name
	var/needs_to_close = 0
	if(density)
		if(alarmed)
			needs_to_close = 1
		spawn()
			open()
	else
		spawn()
			close()
	investigation_log(I_ATMOS, "has been [density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")

	if(needs_to_close)
		spawn(50)
			if(alarmed && !density)
				close()
/obj/machinery/door/firedoor/open()
	if(!loc || blocked)
		return
	..()
	latetoggle()
	layer = base_layer
	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire
	if(alarmed)
		spawn(50)
			close()
/obj/machinery/door/firedoor/proc/force_open(mob/user, var/obj/C) //used in mecha/equipment/tools/tools.dm
	var/area/A = get_area_master(src)
	ASSERT(istype(A)) // This worries me.
	var/alarmed = A.doors_down || A.fire

	if( blocked )
		user.visible_message("<span class='attack'>\The [istype(user.loc,/obj/mecha) ? "[user.loc.name]" : "[user]"] pries at \the [src] with \a [C], but \the [src] is welded in place!</span>",\
		"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
		"You hear someone struggle and metal straining.")
		return

	//thank you Tigercat2000
	user.visible_message("<span class='attack'>\The [istype(user.loc,/obj/mecha) ? "[user.loc.name]" : "[user]"] forces \the [src] [density ? "open" : "closed"] with \a [C]!</span>",\
		"You force \the [src] [density ? "open" : "closed"] with \the [C]!",\
		"You hear metal strain, and a door [density ? "open" : "close"].")

	if(density)
		spawn(0)
			open()
	else
		spawn(0)
			close()
	investigation_log(I_ATMOS, "has been [density ? "closed" : "opened"] [alarmed ? "while alarming" : ""] by [user.real_name] ([formatPlayerPanel(user, user.ckey)]) at [formatJumpTo(get_turf(src))]")
	return

/obj/machinery/door/firedoor/close()
	if(blocked || !loc)
		return
	..()
	latetoggle()
	layer = base_layer + FIREDOOR_CLOSED_MOD

/obj/machinery/door/firedoor/door_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	return


/obj/machinery/door/firedoor/update_icon()
	overlays.len = 0
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += image(icon = icon, icon_state = "welded")
		if(pdiff_alert)
			overlays += image(icon = icon, icon_state = "palert")
		if(dir_alerts)
			for(var/d=1;d<=4;d++)
				var/cdir = cardinal[d]
				// Loop while i = [1, 3], incrementing each loop
				for(var/i=1;i<=ALERT_STATES.len;i++) //
					if(dir_alerts[d] & (1<<(i-1)))// Check to see if dir_alerts[d] has the i-1th bit set.

						var/list/state_list = alert_overlays_local["alert_[ALERT_STATES[i]]"]
						if(flags & ON_BORDER)
							overlays += turn(state_list["[turn(cdir, dir2angle(src.dir))]"], dir2angle(src.dir))
						else
							overlays += state_list["[cdir]"]
	else
		icon_state = "door_open"
		if(blocked)
			overlays += image(icon = icon, icon_state = "welded_open")
	return

// CHECK PRESSURE
/obj/machinery/door/firedoor/process()
	..()

	if(density)
		var/changed = 0
		lockdown=0
		// Pressure alerts
		pdiff = getOPressureDifferential(src.loc)
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			lockdown = 1
			if(!pdiff_alert)
				pdiff_alert = 1
				changed = 1 // update_icon()
		else
			if(pdiff_alert)
				pdiff_alert = 0
				changed = 1 // update_icon()

		tile_info = getCardinalAirInfo(src,src.loc,list("temperature","pressure"))
		var/old_alerts = dir_alerts
		for(var/index = 1; index <= 4; index++)
			var/list/tileinfo=tile_info[index]
			if(tileinfo==null)
				continue // Bad data.
			var/celsius = convert_k2c(tileinfo[1])

			var/alerts=0

			// Temperatures
			if(celsius >= FIREDOOR_MAX_TEMP)
				alerts |= FIREDOOR_ALERT_HOT
				lockdown = 1
			else if(celsius <= FIREDOOR_MIN_TEMP)
				alerts |= FIREDOOR_ALERT_COLD
				lockdown = 1

			dir_alerts[index]=alerts

		if(dir_alerts != old_alerts)
			changed = 1
		if(changed)
			update_icon()

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
//These are playing merry hell on ZAS.  Sorry fellas :(
//Or they were, until you disable their inherent air-blocking

	icon = 'icons/obj/doors/edge_DoorHazard.dmi'
	glass = 1 //There is a glass window so you can see through the door
			  //This is needed due to BYOND limitations in controlling visibility
	heat_proof = 1
	air_properties_vary_with_direction = 1
	flags = ON_BORDER

/obj/machinery/door/firedoor/border_only/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir || get_dir(loc, mover) == dir)
		return !density
	return 1

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/firedoor/CanAStarPass()
	return !density


/obj/machinery/door/firedoor/border_only/Uncross(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(flags & ON_BORDER)
		if(target) //Are we doing a manual check to see
			if(get_dir(loc, target) == dir)
				return !density
		else if(mover.dir == dir) //Or are we using move code
			if(density)	mover.Bump(src)
			return !density
	return 1


/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
