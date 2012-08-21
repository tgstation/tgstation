//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/assembly/infra
	name = "Infrared Beam"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared_old"
	m_amt = 1000
	g_amt = 500
	w_amt = 100
	origin_tech = "magnets=2"

	secured = 0
	small_icon_state_left = "infrared_left"
	small_icon_state_right = "infrared_right"

	var/scanning = 0
	var/visible = 0
	var/obj/effect/beam/i_beam/first = null

	proc
		trigger_beam()


	activate()
		if(!..())	return 0//Cooldown check
		src.scanning = !src.scanning
		update_icon()
		return 1


	toggle_secure()
		secured = !secured
		if(secured)
			processing_objects.Add(src)
		else
			scanning = 0
			if(src.first)	del(src.first)
			processing_objects.Remove(src)
		update_icon()
		return secured


	update_icon()
		src.overlays = null
		src.small_icon_state_overlays = list()
		if(scanning)
			src.overlays += text("infrared_old2")
			src.small_icon_state_overlays += text("infrared_on")

		if(holder)
			holder.update_icon()
		return


	process()//Old code
		if(!scanning)
			if(src.first)
				del(src.first)
				return

		if((!( src.first ) && (src.secured && (istype(src.loc, /turf) || (src.holder && istype(src.holder.loc, /turf))))))
			var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam( (src.holder ? src.holder.loc : src.loc) )
			I.master = src
			I.density = 1
			I.dir = src.dir
			step(I, I.dir)
			if (I)
				I.density = 0
				src.first = I
				I.vis_spread(src.visible)
				spawn( 0 )
					if (I)
						//world << "infra: setting limit"
						I.limit = 8
						//world << "infra: processing beam \ref[I]"
						I.process()
					return
		return


	attack_hand()
		del(src.first)
		..()
		return


	Move()
		var/t = src.dir
		..()
		src.dir = t
		del(src.first)
		return


	holder_movement()
		if(!holder)	return 0
//		src.dir = holder.dir
		del(src.first)
		return 1


	trigger_beam()
		if((!secured)||(!scanning)||(cooldown > 0))	return 0
		pulse(0)
		for(var/mob/O in hearers(null, null))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	interact(mob/user as mob)//TODO: change this this to the wire control panel
		if(!secured)	return
		user.machine = src
		var/dat = text("<TT><B>Infrared Laser</B>\n<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>\n</TT>", (src.scanning ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=infra")
		onclose(user, "infra")
		return


	Topic(href, href_list)
		..()
		if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr << browse(null, "window=infra")
			onclose(usr, "infra")
			return

		if (href_list["state"])
			src.scanning = !(src.scanning)
			update_icon()

		if (href_list["visible"])
			src.visible = !(src.visible)
			spawn( 0 )
				if(src.first)
					src.first.vis_spread(src.visible)

		if (href_list["close"])
			usr << browse(null, "window=infra")
			return

		if(usr)
			src.attack_self(usr)

		return


	verb/rotate()//This could likely be better
		set name = "Rotate Infrared Laser"
		set category = "Object"
		set src in usr

		src.dir = turn(src.dir, 90)
		return



/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "i beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/item/device/assembly/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags = TABLEPASS


/obj/effect/beam/i_beam/proc/hit()
	//world << "beam \ref[src]: hit"
	if(src.master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		src.master.trigger_beam()
	del(src)
	return

/obj/effect/beam/i_beam/proc/vis_spread(v)
	//world << "i_beam \ref[src] : vis_spread"
	src.visible = v
	spawn(0)
		if(src.next)
			//world << "i_beam \ref[src] : is next [next.type] \ref[next], calling spread"
			src.next.vis_spread(v)
		return
	return

/obj/effect/beam/i_beam/process()
	//world << "i_beam \ref[src] : process"

	if((src.loc.density || !( src.master )))
		//SN src = null
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if(src.left > 0)
		src.left--
	if(src.left < 1)
		if(!( src.visible ))
			src.invisibility = 101
		else
			src.invisibility = 0
	else
		src.invisibility = 0


	//world << "now [src.left] left"
	var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam( src.loc )
	I.master = src.master
	I.density = 1
	I.dir = src.dir
	//world << "created new beam \ref[I] at [I.x] [I.y] [I.z]"
	step(I, I.dir)

	if(I)
		//world << "step worked, now at [I.x] [I.y] [I.z]"
		if (!( src.next ))
			//world << "no src.next"
			I.density = 0
			//world << "spreading"
			I.vis_spread(src.visible)
			src.next = I
			spawn( 0 )
				//world << "limit = [src.limit] "
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					//world << "calling next process"
					I.process()
				return
		else
			//world << "is a next: \ref[next], deleting beam \ref[I]"
			del(I)
	else
		//world << "step failed, deleting \ref[src.next]"
		del(src.next)
	spawn(10)
		src.process()
		return
	return

/obj/effect/beam/i_beam/Bump()
	del(src)
	return

/obj/effect/beam/i_beam/Bumped()
	src.hit()
	return

/obj/effect/beam/i_beam/HasEntered(atom/movable/AM as mob|obj)
	if(istype(AM, /obj/effect/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/effect/beam/i_beam/Del()
	del(src.next)
	..()
	return
