/obj/machinery/sec_lock//P'sure this was part of the tunnel
	name = "Security Pad"
	desc = "A lock, for doors. Used by security."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "sec_lock"
	var/obj/item/weapon/card/id/scan = null
	var/a_type = 0.0
	var/obj/machinery/door/d1 = null
	var/obj/machinery/door/d2 = null
	anchored = 1.0
	req_access = list(access_brig)
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/move/airtunnel/process()
	if (!( src.deployed ))
		return null
	else
		..()
	return

/obj/move/airtunnel/connector/create()
	src.current = src
	src.next = new /obj/move/airtunnel( null )
	src.next.master = src.master
	src.next.previous = src
	spawn( 0 )
		src.next.create(airtunnel_start - airtunnel_stop, src.y)
		return
	return

/obj/move/airtunnel/connector/wall/create()
	src.current = src
	src.next = new /obj/move/airtunnel/wall( null )
	src.next.master = src.master
	src.next.previous = src
	spawn( 0 )
		src.next.create(airtunnel_start - airtunnel_stop, src.y)
		return
	return

/obj/move/airtunnel/connector/wall/process()
	return

/obj/move/airtunnel/wall/create(num, y_coord)
	if (((num < 7 || (num > 16 && num < 23)) && y_coord == airtunnel_bottom))
		src.next = new /obj/move/airtunnel( null )
	else
		src.next = new /obj/move/airtunnel/wall( null )
	src.next.master = src.master
	src.next.previous = src
	if (num > 1)
		spawn( 0 )
			src.next.create(num - 1, y_coord)
			return
	return

/obj/move/airtunnel/wall/move_right()
	flick("wall-m", src)
	return ..()

/obj/move/airtunnel/wall/move_left()
	flick("wall-m", src)
	return ..()

/obj/move/airtunnel/wall/process()
	return

/obj/move/airtunnel/proc/move_left()
	src.relocate(get_step(src, WEST))
	if ((src.next && src.next.deployed))
		return src.next.move_left()
	else
		return src.next
	return

/obj/move/airtunnel/proc/move_right()
	src.relocate(get_step(src, EAST))
	if ((src.previous && src.previous.deployed))
		src.previous.move_right()
	return src.previous

/obj/move/airtunnel/proc/create(num, y_coord)
	if (y_coord == airtunnel_bottom)
		if ((num < 7 || (num > 16 && num < 23)))
			src.next = new /obj/move/airtunnel( null )
		else
			src.next = new /obj/move/airtunnel/wall( null )
	else
		src.next = new /obj/move/airtunnel( null )
	src.next.master = src.master
	src.next.previous = src
	if (num > 1)
		spawn( 0 )
			src.next.create(num - 1, y_coord)
			return
	return

/obj/machinery/at_indicator/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/x in src.verbs)
					src.verbs -= x
				src.icon_state = "reader_broken"
				stat |= BROKEN
		if(3.0)
			if (prob(25))
				for(var/x in src.verbs)
					src.verbs -= x
				src.icon_state = "reader_broken"
				stat |= BROKEN
		else
	return

/obj/machinery/at_indicator/blob_act()
	if (prob(75))
		for(var/x in src.verbs)
			src.verbs -= x
		src.icon_state = "reader_broken"
		stat |= BROKEN

/obj/machinery/at_indicator/proc/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "reader_broken"
		return

	var/status = 0
	if (SS13_airtunnel.operating == 1)
		status = "r"
	else
		if (SS13_airtunnel.operating == 2)
			status = "e"
		else
			if(!SS13_airtunnel.connectors)
				return
			var/obj/move/airtunnel/connector/C = pick(SS13_airtunnel.connectors)
			if (C.current == C)
				status = 0
			else
				if (!( C.current.next ))
					status = 2
				else
					status = 1
	src.icon_state = text("reader[][]", (SS13_airtunnel.siphon_status == 2 ? "1" : "0"), status)
	return

/obj/machinery/at_indicator/process()
	if(stat & (NOPOWER|BROKEN))
		src.update_icon()
		return
	use_power(5, ENVIRON)
	src.update_icon()
	return

/obj/machinery/computer/airtunnel/attack_paw(user as mob)
	return src.attack_hand(user)

obj/machinery/computer/airtunnel/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/airtunnel/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Air Tunnel Controls</B><BR>"
	user.machine = src
	if (SS13_airtunnel.operating == 1)
		dat += "<B>Status:</B> RETRACTING<BR>"
	else
		if (SS13_airtunnel.operating == 2)
			dat += "<B>Status:</B> EXPANDING<BR>"
		else
			var/obj/move/airtunnel/connector/C = pick(SS13_airtunnel.connectors)
			if (C.current == C)
				dat += "<B>Status:</B> Fully Retracted<BR>"
			else
				if (!( C.current.next ))
					dat += "<B>Status:</B> Fully Extended<BR>"
				else
					dat += "<B>Status:</B> Stopped Midway<BR>"
	dat += text("<A href='?src=\ref[];retract=1'>Retract</A> <A href='?src=\ref[];stop=1'>Stop</A> <A href='?src=\ref[];extend=1'>Extend</A><BR>", src, src, src)
	dat += text("<BR><B>Air Level:</B> []<BR>", (SS13_airtunnel.air_stat ? "Acceptable" : "DANGEROUS"))
	dat += "<B>Air System Status:</B> "
	switch(SS13_airtunnel.siphon_status)
		if(0.0)
			dat += "Stopped "
		if(1.0)
			dat += "Siphoning (Siphons only) "
		if(2.0)
			dat += "Regulating (BOTH) "
		if(3.0)
			dat += "RELEASING MAX (Siphons only) "
		else
	dat += text("<A href='?src=\ref[];refresh=1'>(Refresh)</A><BR>", src)
	dat += text("<A href='?src=\ref[];release=1'>RELEASE (Siphons only)</A> <A href='?src=\ref[];siphon=1'>Siphon (Siphons only)</A> <A href='?src=\ref[];stop_siph=1'>Stop</A> <A href='?src=\ref[];auto=1'>Regulate</A><BR>", src, src, src, src)
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/airtunnel/proc/update_icon()
	if(stat & BROKEN)
		icon_state = "broken"
		return

	if(stat & NOPOWER)
		icon_state = "c_unpowered"
		return

	var/status = 0
	if (SS13_airtunnel.operating == 1)
		status = "r"
	else
		if (SS13_airtunnel.operating == 2)
			status = "e"
		else
			var/obj/move/airtunnel/connector/C = pick(SS13_airtunnel.connectors)
			if (C.current == C)
				status = 0
			else
				if (!( C.current.next ))
					status = 2
				else
					status = 1
	src.icon_state = text("console[][]", (SS13_airtunnel.siphon_status >= 2 ? "1" : "0"), status)
	return

/obj/machinery/computer/airtunnel/process()
	src.update_icon()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250)
	src.updateUsrDialog()
	return

/obj/machinery/computer/airtunnel/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon))))
		usr.machine = src
		if (href_list["retract"])
			SS13_airtunnel.retract()
		else if (href_list["stop"])
			SS13_airtunnel.operating = 0
		else if (href_list["extend"])
			SS13_airtunnel.extend()
		else if (href_list["release"])
			SS13_airtunnel.siphon_status = 3
			SS13_airtunnel.siphons()
		else if (href_list["siphon"])
			SS13_airtunnel.siphon_status = 1
			SS13_airtunnel.siphons()
		else if (href_list["stop_siph"])
			SS13_airtunnel.siphon_status = 0
			SS13_airtunnel.siphons()
		else if (href_list["auto"])
			SS13_airtunnel.siphon_status = 2
			SS13_airtunnel.siphons()
		else if (href_list["refresh"])
			SS13_airtunnel.siphons()

		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return


/obj/machinery/sec_lock/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/sec_lock/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/sec_lock/attack_hand(var/mob/user as mob)
	if(..())
		return
	use_power(10)

	if (src.loc == user.loc)
		var/dat = text("<B>Security Pad:</B><BR>\nKeycard: []<BR>\n<A href='?src=\ref[];door1=1'>Toggle Outer Door</A><BR>\n<A href='?src=\ref[];door2=1'>Toggle Inner Door</A><BR>\n<BR>\n<A href='?src=\ref[];em_cl=1'>Emergency Close</A><BR>\n<A href='?src=\ref[];em_op=1'>Emergency Open</A><BR>", (src.scan ? text("<A href='?src=\ref[];card=1'>[]</A>", src, src.scan.name) : text("<A href='?src=\ref[];card=1'>-----</A>", src)), src, src, src, src)
		user << browse(dat, "window=sec_lock")
		onclose(user, "sec_lock")
	return

/obj/machinery/sec_lock/attackby(nothing, user as mob)
	return src.attack_hand(user)

/obj/machinery/sec_lock/New()
	..()
	spawn( 2 )
		if (src.a_type == 1)
			src.d2 = locate(/obj/machinery/door, locate(src.x - 2, src.y - 1, src.z))
			src.d1 = locate(/obj/machinery/door, get_step(src, SOUTHWEST))
		else
			if (src.a_type == 2)
				src.d2 = locate(/obj/machinery/door, locate(src.x - 2, src.y + 1, src.z))
				src.d1 = locate(/obj/machinery/door, get_step(src, NORTHWEST))
			else
				src.d1 = locate(/obj/machinery/door, get_step(src, SOUTH))
				src.d2 = locate(/obj/machinery/door, get_step(src, SOUTHEAST))
		return
	return

/obj/machinery/sec_lock/Topic(href, href_list)
	if(..())
		return
	if ((!( src.d1 ) || !( src.d2 )))
		usr << "\red Error: Cannot interface with door security!"
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon))))
		usr.machine = src
		if (href_list["card"])
			if (src.scan)
				src.scan.loc = src.loc
				src.scan = null
			else
				var/obj/item/weapon/card/id/I = usr.equipped()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_item()
					I.loc = src
					src.scan = I
		if (href_list["door1"])
			if (src.scan)
				if (src.check_access(src.scan))
					if (src.d1.density)
						spawn( 0 )
							src.d1.open()
							return
					else
						spawn( 0 )
							src.d1.close()
							return
		if (href_list["door2"])
			if (src.scan)
				if (src.check_access(src.scan))
					if (src.d2.density)
						spawn( 0 )
							src.d2.open()
							return
					else
						spawn( 0 )
							src.d2.close()
							return
		if (href_list["em_cl"])
			if (src.scan)
				if (src.check_access(src.scan))
					if (!( src.d1.density ))
						src.d1.close()
						return
					sleep(1)
					spawn( 0 )
						if (!( src.d2.density ))
							src.d2.close()
						return
		if (href_list["em_op"])
			if (src.scan)
				if (src.check_access(src.scan))
					spawn( 0 )
						if (src.d1.density)
							src.d1.open()
						return
					sleep(1)
					spawn( 0 )
						if (src.d2.density)
							src.d2.open()
						return
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return

/datum/air_tunnel/air_tunnel1/New()
	..()
	for(var/obj/move/airtunnel/A in locate(/area/airtunnel1))
		A.master = src
		A.create()
		src.connectors += A
		//Foreach goto(21)
	return

/datum/air_tunnel/proc/siphons()
	switch(src.siphon_status)
		if(0.0)
			for(var/obj/machinery/atmoalter/siphs/S in locate(/area/airtunnel1))
				S.t_status = 3
		if(1.0)
			for(var/obj/machinery/atmoalter/siphs/fullairsiphon/S in locate(/area/airtunnel1))
				S.t_status = 2
				S.t_per = 1000000.0
			for(var/obj/machinery/atmoalter/siphs/scrubbers/S in locate(/area/airtunnel1))
				S.t_status = 3
		if(2.0)
			for(var/obj/machinery/atmoalter/siphs/S in locate(/area/airtunnel1))
				S.t_status = 4
		if(3.0)
			for(var/obj/machinery/atmoalter/siphs/fullairsiphon/S in locate(/area/airtunnel1))
				S.t_status = 1
				S.t_per = 1000000.0
			for(var/obj/machinery/atmoalter/siphs/scrubbers/S in locate(/area/airtunnel1))
				S.t_status = 3
		else
	return

/datum/air_tunnel/proc/stop()
	src.operating = 0
	return

/datum/air_tunnel/proc/extend()
	if (src.operating)
		return

	spawn(0)
		src.operating = 2
		while(src.operating == 2)
			var/ok = 1
			for(var/obj/move/airtunnel/connector/A in src.connectors)
				if (!( A.current.next ))
					src.operating = 0
					return
				if (!( A.move_left() ))
					ok = 0
			if (!( ok ))
				src.operating = 0
			else
				for(var/obj/move/airtunnel/connector/A in src.connectors)
					if (A.current)
						A.current.next.loc = get_step(A.current.loc, EAST)
						A.current = A.current.next
						A.current.deployed = 1
					else
						src.operating = 0
			sleep(20)
		return

/datum/air_tunnel/proc/retract()
	if (src.operating)
		return
	spawn(0)
		src.operating = 1
		while(src.operating == 1)
			var/ok = 1
			for(var/obj/move/airtunnel/connector/A in src.connectors)
				if (A.current == A)
					src.operating = 0
					return
				if (A.current)
					A.current.loc = null
					A.current.deployed = 0
					A.current = A.current.previous
				else
					ok = 0
			if (!( ok ))
				src.operating = 0
			else
				for(var/obj/move/airtunnel/connector/A in src.connectors)
					if (!( A.current.move_right() ))
						src.operating = 0
			sleep(20)
		return