/obj/item/device/prox_sensor/dropped()
	spawn(0)
		src.sense()
		return
	return

/obj/item/device/prox_sensor/proc/c_state(n)
	src.icon_state = text("motion[]", n)

	if(src.master)
		src.master:c_state(n)

	return

/obj/item/device/prox_sensor/proc/sense()
	if (src.state)
		if (src.master)
			spawn(0)
				src.master.receive_signal()
				return
		else
			for(var/mob/O in hearers(null, null))
				O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	return

/obj/item/device/prox_sensor/process()
	if (src.timing)
		if (src.time > 0)
			if(!src.state)
				src.c_state(2)
			src.time = round(src.time) - 1
		else
			time()
			src.time = 0
			src.timing = 0
		if (!src.master)
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client && (M.machine == src.master || M.machine == src))
						src.attack_self(M)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client && (M.machine == src.master || M.machine == src))
						src.attack_self(M)
	else
		processing_items.Remove(src)
		return
	return

/obj/item/device/prox_sensor/proc/time()
	if (src.state == 0)
		src.state = !( src.state )
		src.icon_state = text("motion[]", src.state)
		if (src.master)
			src.master:c_state(src.state, src)
	return

/obj/item/device/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	if (AM.move_speed < 12)
		src.sense()
	return

/obj/item/device/prox_sensor/attackby(obj/item/device/radio/signaler/S as obj, mob/user as mob)
	if ((!( istype(S, /obj/item/device/radio/signaler) ) || !( S.b_stat )))
		return
	var/obj/item/assembly/rad_prox/R = new /obj/item/assembly/rad_prox( user )
	S.loc = R
	R.part1 = S
	S.layer = initial(S.layer)
	if (user.client)
		user.client.screen -= S
	if (user.r_hand == S)
		user.u_equip(S)
		user.r_hand = R
	else
		user.u_equip(S)
		user.l_hand = R
	S.master = R
	src.master = R
	src.layer = initial(src.layer)
	user.u_equip(src)
	if (user.client)
		user.client.screen -= src
	src.loc = R
	R.part2 = src
	R.layer = 20
	R.loc = user
	R.dir = src.dir
	src.add_fingerprint(user)
	return

/obj/item/device/prox_sensor/attack_self(mob/user as mob)
	if (user.stat || user.restrained() || user.lying)
		return
	if ((user.contents.Find(src) || user.contents.Find(src.master) || get_dist(src, user) <= 1 && istype(src.loc, /turf)))
		user.machine = src
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Arming</A>", src) : text("<A href='?src=\ref[];time=1'>Not Arming</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><A href='?src=\ref[src];state=1'>[state?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=prox")
		onclose(user, "prox")
	else
		user << browse(null, "window=prox")
		user.machine = null
		return

/obj/item/device/prox_sensor/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	if ((usr.contents.Find(src) || usr.contents.Find(src.master) || (get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src
		if (href_list["state"])
			src.state = !( src.state )
			src.icon_state = text("motion[]", src.state)
			if (src.master)
				src.master:c_state(src.state, src)
			if(state)
				processing_items.Add(src)

		if (href_list["time"])
			src.timing = text2num(href_list["time"])
			if(timing)
				src.c_state(1)

		if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 0), 600)

		if (href_list["close"])
			usr << browse(null, "window=prox")
			usr.machine = null
			return

		if (!src.master)
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client && (M.machine == src.master || M.machine == src))
						src.attack_self(M)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client && (M.machine == src.master || M.machine == src))
						src.attack_self(M)
	else
		usr << browse(null, "window=prox")
		return
	return

/obj/item/device/prox_sensor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/device/prox_sensor/Move()
	..()
	src.sense()
	return