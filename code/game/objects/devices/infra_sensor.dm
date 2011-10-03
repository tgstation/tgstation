/obj/item/device/infra_sensor/process()
	if (src.passive)
		for(var/obj/effect/beam/i_beam/I in range(2, src.loc))
			I.left = 2
		return 1

	else
		processing_objects.Remove(src)
		return null

/obj/item/device/infra_sensor/proc/burst()
	for(var/obj/effect/beam/i_beam/I in range(src.loc))
		I.left = 8
/*	for(var/obj/item/device/infra/I in range(src.loc))ugh will have to fix this
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
			return*/
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
				processing_objects.Add(src)
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


