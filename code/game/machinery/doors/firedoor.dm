/var/const/OPEN = 1
/var/const/CLOSED = 2

/proc/convert_k2c(var/temp)
	return ((temp - T0C)) // * 1.8) + 32

/proc/convert_c2k(var/temp)
	return ((temp + T0C)) // * 1.8) + 32

/proc/getCardinalAirInfo(var/turf/loc, var/list/stats=list("temperature"))
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
#define FIREDOOR_MAX_TEMP 50 // °C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT      1
#define FIREDOOR_ALERT_COLD     2
// Not used #define FIREDOOR_ALERT_LOWPRESS 4

/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip)
	opacity = 0
	density = 0
	layer = 2.6

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

	New()
		. = ..()
		for(var/obj/machinery/door/firedoor/F in loc)
			if(F != src)
				spawn(1)
					del src
				return .
		var/area/A = get_area(src)
		ASSERT(istype(A))

		A.all_doors.Add(src)
		areas_added = list(A)

		for(var/direction in cardinal)
			A = get_area(get_step(src,direction))
			if(istype(A) && !(A in areas_added))
				A.all_doors.Add(src)
				areas_added += A


	Destroy()
		for(var/area/A in areas_added)
			A.all_doors.Remove(src)
		. = ..()


	examine()
		set src in view()
		. = ..()
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			usr << "<span class='warning'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>"

		usr << "<b>Sensor readings:</b>"
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
				usr << o
				continue
			var/celsius = convert_k2c(tile_info[index][1])
			var/pressure = tile_info[index][2]
			if(dir_alerts[index] & (FIREDOOR_ALERT_HOT|FIREDOOR_ALERT_COLD))
				o += "<span class='warning'>"
			else
				o += "<span style='color:blue'>"
			o += "[celsius]°C</span> "
			o += "<span style='color:blue'>"
			o += "[pressure]kPa</span></li>"
			usr << o

		if( islist(users_to_open) && users_to_open.len)
			var/users_to_open_string = users_to_open[1]
			if(users_to_open.len >= 2)
				for(var/i = 2 to users_to_open.len)
					users_to_open_string += ", [users_to_open[i]]"
			usr << "These people have opened \the [src] during an alert: [users_to_open_string]."


	Bumped(atom/AM)
		if(p_open || operating)
			return
		if(!density)
			return ..()
		if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if (mecha.occupant)
				var/mob/M = mecha.occupant
				if(world.time - M.last_bumped <= 10) return //Can bump-open one airlock per second. This is to prevent popup message spam.
				M.last_bumped = world.time
				attack_hand(M)
		return 0


	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
			latetoggle()
		else
			stat |= NOPOWER
		return


	attack_hand(mob/user as mob)
		return attackby(null, user)

	attackby(obj/item/weapon/C as obj, mob/user as mob)
		add_fingerprint(user)
		if(operating)
			return//Already doing something.
		if(istype(C, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = C
			if(W.remove_fuel(0, user))
				blocked = !blocked
				user.visible_message("\red \The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].",\
				"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
				"You hear something being welded.")
				update_icon()
				return

		if(blocked)
			user << "\red \The [src] is welded solid!"
			return

		var/area/A = get_area_master(src)
		ASSERT(istype(A)) // This worries me.
		var/alarmed = A.doors_down || A.fire

		if( istype(C, /obj/item/weapon/crowbar) || ( istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1 ) )
			if(operating)
				return
			if( blocked )
				user.visible_message("\red \The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!",\
				"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
				"You hear someone struggle and metal straining.")

			if( stat & (BROKEN|NOPOWER) || !density || !alarmed )
				user.visible_message("\red \The [user] forces \the [src] [density ? "open" : "closed"] with \a [C]!",\
				"You force \the [src] [density ? "open" : "closed"] with \the [C]!",\
				"You hear metal strain, and a door [density ? "open" : "close"].")
			else if( allowed(user) )
				user.visible_message("\blue \The [user] lifts \the [src] with \a [C].",\
				"\The [src] scans your ID, and obediently opens as you apply your [C].",\
				"You hear metal move, and a door [density ? "open" : "close"].")
			else if(lockdown)
				user.visible_message("\blue \The [user] pries at \the [src] with \a [C], but \the [src] resists being opened.",\
				"\red You pry at \the [src], but it actively resists your efforts.  Maybe use your ID, perhaps?",\
				"You hear someone struggling and metal straining")
				return
			if(density)
				spawn(0)
					open()
			else
				spawn(0)
					close()
			return
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
		if(user.buckled)
			if(!istype(user.buckled, /obj/structure/stool/bed/chair/vehicle))
				user << "Sorry, you must remain able bodied and close to \the [src] in order to use it."
				return
		if(user.stat || user.stunned || user.weakened || user.paralysis || get_dist(src, user) > 1)
			user << "Sorry, you must remain able bodied and close to \the [src] in order to use it."
			return

		if(alarmed && density && lockdown && !access_granted/* && !( users_name in users_to_open ) */)
			// Too many shitters on /vg/ for the honor system to work.
			user << "<span class='warning'>Access denied.  Please wait for authorities to arrive, or for the alert to clear.</span>"
			return
			// End anti-shitter system
			/*
			user.visible_message("\red \The [src] opens for \the [user]",\
			"\The [src] opens after you acknowledge the consequences.",\
			"You hear a beep, and a door opening.")
			*/
		else
			user.visible_message("\blue \The [src] [density ? "open" : "close"]s for \the [user].",\
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

		if(needs_to_close)
			spawn(50)
				if(alarmed)
					nextstate = CLOSED

	open()
		..()
		latetoggle()
		layer = 2.6

	close()
		..()
		latetoggle()
		layer = 3.1

	door_animate(animation)
		switch(animation)
			if("opening")
				flick("door_opening", src)
			if("closing")
				flick("door_closing", src)
		return


	update_icon()
		overlays = 0
		if(density)
			icon_state = "door_closed"
			if(blocked)
				overlays += "welded"
			if(pdiff_alert)
				overlays += "palert"
			if(dir_alerts)
				for(var/d=1;d<=4;d++)
					var/cdir = cardinal[d]
					// Loop while i = [1, 3], incrementing each loop
					for(var/i=1;i<=ALERT_STATES.len;i++) //
						if(dir_alerts[d] & (1<<(i-1))) // Check to see if dir_alerts[d] has the i-1th bit set.
							overlays += new /icon(icon,"alert_[ALERT_STATES[i]]",dir=cdir)
		else
			icon_state = "door_open"
			if(blocked)
				overlays += "welded_open"
		return

	// CHECK PRESSURE
	process()
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

			tile_info = getCardinalAirInfo(src.loc,list("temperature","pressure"))
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

	//icon = 'icons/obj/doors/edge_Doorfire.dmi'
	glass = 1 //There is a glass window so you can see through the door
			  //This is needed due to BYOND limitations in controlling visibility
	heat_proof = 1
	air_properties_vary_with_direction = 1

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
		if(istype(mover) && mover.checkpass(PASSGLASS))
			return 1
	/*
		if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
			if(air_group) return 0
			return !density*/
		else
			return !density

/*	CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
		if(istype(mover) && mover.checkpass(PASSGLASS))
			return 1
		/*if(get_dir(loc, target) == dir)
			return !density*/
		else
			return !density*/

/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2