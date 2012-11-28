/var/const/OPEN = 1
/var/const/CLOSED = 2
/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'DoorHazard.dmi'
	icon_state = "door_open"
	req_access = list(access_atmospherics, access_engine_equip)
	opacity = 0
	density = 0

	var/blocked = 0
	var/nextstate = null
	var/net_id
	var/list/areas_added
	var/list/users_to_open

	New()
		. = ..()
		var/area/A = get_area(src)
		ASSERT(istype(A))

		A.all_doors.Add(src)
		areas_added = list(A)

		for(var/direction in cardinal)
			A = get_area(get_step(src,direction))
			if(istype(A) && !(A in areas_added))
				A.all_doors.Add(src)
				areas_added += A


	Del()
		for(var/area/A in areas_added)
			A.all_doors.Remove(src)
		. = ..()


	examine()
		set src in view()
		. = ..()
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
		return 0


	power_change()
		if(powered(ENVIRON))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER
		return


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

		var/area/A = get_area(src)
		ASSERT(istype(A))
		if(A.master)
			A = A.master
		var/alarmed = A.air_doors_activated || A.fire

		if( istype(C, /obj/item/weapon/crowbar) || ( istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1 ) )
			if(operating)
				return
			if( blocked && istype(C, /obj/item/weapon/crowbar) )
				user.visible_message("\red \The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!",\
				"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
				"You hear someone struggle and metal straining.")
				return
			if( istype(C, /obj/item/weapon/crowbar) )
				if( stat & (BROKEN|NOPOWER) || !density || !alarmed )
					user.visible_message("\red \The [user] forces \the [src] [density ? "open" : "closed"] with \a [C]!",\
					"You force \the [src] [density ? "open" : "closed"] with \the [C]!",\
					"You hear metal strain, and a door [density ? "open" : "close"].")
				else if( allowed(user) )
					user.visible_message("\blue \The [user] lifts \the [src] with \a [C].",\
					"\The [src] scans your ID, and obediently opens as you apply your [C].",\
					"You hear metal move, and a door [density ? "open" : "close"].")
				else
					user.visible_message("\blue \The [user] pries at \the [src] with \a [C], but \the [src] resists being opened.",\
					"\red You pry at \the [src], but it actively resists your efforts.  Maybe use your ID, perhaps?",\
					"You hear someone struggling and metal straining")
					return
			else
				user.visible_message("\red \The [user] forces \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \a [C]!",\
					"You force \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \the [C]!",\
					"You hear metal strain and groan, and a door [density ? "open" : "close"].")
			if(density)
				spawn(0)
					open()
			else
				spawn(0)
					close()

		if( !stat && ( istype(C, /obj/item/weapon/card/id) || istype(C, /obj/item/device/pda) ) )
			var/obj/item/weapon/card/id/ID = C

			if( istype(C, /obj/item/device/pda) )
				var/obj/item/device/pda/pda = C
				ID = pda.id
			if(!istype(ID))
				ID = null

			var/answer = alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density && !check_access(ID) ? "\nNote that by doing this, you acknowledge any damages from opening this [src.name]\nas being your own fault, and you will be held accountable under the law." : ""]",\
			"\The [src]", "Yes, [density ? "open" : "close"]", "No")
			if(answer == "No")
				return
			if(user.stat || !user.canmove || user.stunned || user.weakened || user.paralysis || get_dist(src, user) > 1)
				user << "Sorry, you must remain able bodied and close to \the [src] in order to use it."
				return

			if(alarmed && density && !check_access(ID) && ( ID && !( ID.registered_name in users_to_open ) ) )
				user.visible_message("\red \The [src] opens for \the [user], but only after they acknowledged responsibility for the consequences.",\
				"\The [src] opens after you acknowledge the consequences.",\
				"You hear a beep, and a door opening.")
				if(ID && ID.registered_name)
					if(!users_to_open)
						users_to_open = list()
					users_to_open += ID.registered_name
			else
				user.visible_message("\blue \The [src] [density ? "open" : "close"]s for \the [user].",\
				"\The [src] [density ? "open" : "close"]s.",\
				"You hear a beep, and a door opening.")

			if(density)
				open()
			else
				close()

			if(alarmed && !density)
				spawn(100)
				nextstate = CLOSED


	process()
		if(operating || stat & NOPOWER || !nextstate)
			return
		switch(nextstate)
			if(OPEN)
				spawn()
					open()
			if(CLOSED)
				spawn()
					close()
		nextstate = null
		return


	animate(animation)
		switch(animation)
			if("opening")
				flick("door_opening", src)
			if("closing")
				flick("door_closing", src)
		return


	update_icon()
		overlays = null
		if(density)
			icon_state = "door_closed"
			if(blocked)
				overlays += "welded"
		else
			icon_state = "door_open"
			if(blocked)
				overlays += "welded_open"
		return


/obj/machinery/door/firedoor/border_only