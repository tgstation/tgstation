/obj/machinery/computer/area_atmos
	name = "Area Air Control"
	desc = "A computer used to control the stationary scrubbers and pumps in the area."
	icon_state = "computer_generic"
	var/scrubber_state = 0 //0 = off; 1 = on


	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return

	attack_hand(var/mob/user as mob)
		src.add_fingerprint(usr)
		var/dat = text("<center>Area Air Control:<br> <b><A href='?src=\ref[src];scrubbers=[1]'>Turn area scrubbers [scrubber_state?"off":"on"]</A></b></center>")
		user << browse("[dat]", "window=miningshuttle;size=200x100")

	Topic(href, href_list)
		if(..())
			return
		usr.machine = src
		src.add_fingerprint(usr)
		if(href_list["scrubbers"])
			toggle_scrubbers()
			usr << "\blue Area scrubbers turned [scrubber_state?"on":"off"]"

	proc/toggle_scrubbers()
		if( (ishuman(usr)||issilicon(usr)) && !usr.stat && !usr.restrained() )
			scrubber_state = !scrubber_state
			var/turf/T = get_turf(src)
			if(!T.loc) return
			var/area/A = T.loc
			if (A.master)
				A = A.master
			for( var/obj/machinery/portable_atmospherics/scrubber/stationary/SCRUBBER in world )
				var/turf/T2 = get_turf(SCRUBBER)
				if ( T2 && T2.loc)
					var/area/A2 = T2.loc
					if ( istype(A2) && A2.master && A2.master == A )
						SCRUBBER.on = scrubber_state
						SCRUBBER.update_icon()




/obj/machinery/computer/mining_shuttle/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat
	dat = text("<center>Mining shuttle:<br> <b><A href='?src=\ref[src];move=[1]'>Send</A></b></center>")
	user << browse("[dat]", "window=miningshuttle;size=200x100")

/obj/machinery/computer/mining_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(ticker.mode.name == "blob")
			if(ticker.mode:declared)
				usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
				return

		if (!mining_shuttle_moving)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			move_mining_shuttle()
		else
			usr << "\blue Shuttle is already moving."

