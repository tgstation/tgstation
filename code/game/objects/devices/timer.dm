/obj/item/device/timer/proc/time()
	src.c_state(0)

	if (src.master)
		spawn( 0 )
			var/datum/signal/signal = new
			signal.source = src
			signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(signal)
			del(signal)
			return
	else
		for(var/mob/O in hearers(null, null))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	return

//*****RM


/obj/item/device/timer/proc/c_state(n)
	src.icon_state = text("timer[]", n)

	if(src.master)
		src.master:c_state(n)

	return

//*****

/obj/item/device/timer/process()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
			if(time<5)
				src.c_state(2)
			else
				// they might increase the time while it is timing
				src.c_state(1)
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
		// If it's not timing, reset the icon so it doesn't look like it's still about to go off.
		src.c_state(0)
		processing_items.Remove(src)

	return

/obj/item/device/timer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/device/radio/signaler) )
		var/obj/item/device/radio/signaler/S = W
		if(!S.b_stat)
			return

		var/obj/item/assembly/rad_time/R = new /obj/item/assembly/rad_time( user )
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
		R.add_fingerprint(user)
		return

/obj/item/device/timer/attack_self(mob/user as mob)
	..()
	if (user.stat || user.restrained() || user.lying)
		return
	if ((user.contents.Find(src) || user.contents.Find(src.master) || get_dist(src, user) <= 1 && istype(src.loc, /turf)))
		user.machine = src
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<TT><B>Timing Unit</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=timer")
		onclose(user, "timer")
	else
		user << browse(null, "window=timer")
		user.machine = null

	return

/obj/item/device/timer/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || usr.lying)
		return
	if ((usr.contents.Find(src) || usr.contents.Find(src.master) || in_range(src, usr) && istype(src.loc, /turf)))
		usr.machine = src
		if (href_list["time"])
			src.timing = text2num(href_list["time"])
			if(timing)
				src.c_state(1)
				processing_items.Add(src)

		if (href_list["tp"])
			var/tp = text2num(href_list["tp"])
			src.time += tp
			src.time = min(max(round(src.time), 0), 600)

		if (href_list["close"])
			usr << browse(null, "window=timer")
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
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=timer")
		return
	return