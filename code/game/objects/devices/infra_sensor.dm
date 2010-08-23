/obj/item/device/infra_sensor/process()
	if (src.passive)
		for(var/obj/beam/i_beam/I in range(2, src.loc))
			I.left = 2
		return 1

	else
		processing_items.Remove(src)
		return null

/obj/item/device/infra_sensor/proc/burst()
	for(var/obj/beam/i_beam/I in range(src.loc))
		I.left = 10
	for(var/obj/item/device/infra/I in range(src.loc))
		I.visible = 1
		spawn( 0 )
			if ((I && I.first))
				I.first.vis_spread(1)
			return
	for(var/obj/item/assembly/rad_infra/I in range(src.loc))
		I.part2.visible = 1
		spawn( 0 )
			if ((I.part2 && I.part2.first))
				I.part2.first.vis_spread(1)
			return
	return

/obj/item/device/infra_sensor/attack_self(mob/user as mob)
	user.machine = src
	var/dat = text("<TT><B>Infrared Sensor</B><BR>\n<B>Passive Emitter</B>: []<BR>\n<B>Active Emitter</B>: <A href='?src=\ref[];active=0'>Burst Fire</A>\n</TT>", (src.passive ? text("<A href='?src=\ref[];passive=0'>On</A>", src) : text("<A href='?src=\ref[];passive=1'>Off</A>", src)), src)
	user << browse(dat, "window=infra_sensor")
	onclose(user, "infra_sensor")
	return

/obj/item/device/infra_sensor/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || (usr.contents.Find(src.master) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))))
		usr.machine = src
		if (href_list["passive"])
			src.passive = !( src.passive )
			if(passive)
				processing_items.Add(src)
		if (href_list["active"])
			spawn( 0 )
				src.burst()
				return
		if (!( src.master ))
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=infra_sensor")
		onclose(usr, "infra_sensor")
		return
	return

/obj/item/device/infra/proc/hit()
	if (src.master)
		spawn()
			var/datum/signal/signal = new
			signal.data["message"] = "ACTIVATE"
			src.master.receive_signal(signal)
			del(signal)
			return
	else
		for(var/mob/O in hearers(null, null))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	return

/obj/item/device/infra/process()
	if(!state)
		processing_items.Remove(src)
		return null

	if ((!( src.first ) && (src.state && (istype(src.loc, /turf) || (src.master && istype(src.master.loc, /turf))))))
		var/obj/beam/i_beam/I = new /obj/beam/i_beam( (src.master ? src.master.loc : src.loc) )
		//world << "infra spawning beam : \ref[I]"
		I.master = src
		I.density = 1
		I.dir = src.dir
		step(I, I.dir)
		if (I)
			//world << "infra: beam at [I.x] [I.y] [I.z]"
			I.density = 0
			src.first = I
			//world << "infra : vis_spread"
			I.vis_spread(src.visible)
			spawn( 0 )
				if (I)
					//world << "infra: setting limit"
					I.limit = 20
					//world << "infra: processing beam \ref[I]"
					I.process()
				return
	if (!( src.state ))
		//src.first = null
		del(src.first)
	return

/obj/item/device/infra/attackby(obj/item/device/radio/signaler/S as obj, mob/user as mob)
	if ((!( istype(S, /obj/item/device/radio/signaler) ) || !( S.b_stat )))
		return
	var/obj/item/assembly/rad_infra/R = new /obj/item/assembly/rad_infra( user )
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

/obj/item/device/infra/attack_self(mob/user as mob)
	user.machine = src
	var/dat = text("<TT><B>Infrared Laser</B>\n<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>\n</TT>", (src.state ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))
	user << browse(dat, "window=infra")
	onclose(user, "infra")
	return

/obj/item/device/infra/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if ((usr.contents.Find(src) || usr.contents.Find(src.master) || in_range(src, usr) && istype(src.loc, /turf)))
		usr.machine = src
		if (href_list["state"])
			src.state = !( src.state )
			src.icon_state = text("infrared[]", src.state)
			if (src.master)
				src.master:c_state(src.state, src)
			if(state)
				processing_items.Add(src)
		if (href_list["visible"])
			src.visible = !( src.visible )
			spawn( 0 )
				if (src.first)
					src.first.vis_spread(src.visible)
				return
		if (!( src.master ))
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(211)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(287)
	else
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return
	return

/obj/item/device/infra/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/device/infra/attack_hand()
	//src.first = null
	del(src.first)
	..()
	return

/obj/item/device/infra/Move()
	var/t = src.dir
	..()
	src.dir = t
	//src.first = null
	del(src.first)
	return

/obj/item/device/infra/verb/rotate()
	set src in usr

	src.dir = turn(src.dir, 90)
	return