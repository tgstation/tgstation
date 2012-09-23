//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	m_amt = 1000
	g_amt = 500
	w_amt = 100
	origin_tech = "magnets=2"

	secured = 0

	var/on = 0
	var/visible = 0
	var/obj/effect/beam/i_beam/first = null

	proc
		trigger_beam()


	activate()
		if(!..())	return 0//Cooldown check
		on = !on
		update_icon()
		return 1


	toggle_secure()
		secured = !secured
		if(secured)
			processing_objects.Add(src)
		else
			on = 0
			if(first)	del(first)
			processing_objects.Remove(src)
		update_icon()
		return secured


	update_icon()
		overlays = null
		attached_overlays = list()
		if(on)
			overlays += "infrared_on"
			attached_overlays += "infrared_on"

		if(holder)
			holder.update_icon()
		return


	process()//Old code
		if(!on)
			if(first)
				del(first)
				return

		if((!(first) && (secured && (istype(loc, /turf) || (holder && istype(holder.loc, /turf))))))
			var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam((holder ? holder.loc : loc) )
			I.master = src
			I.density = 1
			I.dir = dir
			step(I, I.dir)
			if(I)
				I.density = 0
				first = I
				I.vis_spread(visible)
				spawn(0)
					if(I)
						//world << "infra: setting limit"
						I.limit = 8
						//world << "infra: processing beam \ref[I]"
						I.process()
					return
		return


	attack_hand()
		del(first)
		..()
		return


	Move()
		var/t = dir
		..()
		dir = t
		del(first)
		return


	holder_movement()
		if(!holder)	return 0
//		dir = holder.dir
		del(first)
		return 1


	trigger_beam()
		if((!secured)||(!on)||(cooldown > 0))	return 0
		pulse(0)
		visible_message("\icon[src] *beep* *beep*")
		cooldown = 2
		spawn(10)
			process_cooldown()
		return


	interact(mob/user as mob)//TODO: change this this to the wire control panel
		if(!secured)	return
		user.machine = src
		var/dat = text("<TT><B>Infrared Laser</B>\n<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>\n</TT>", (on ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))
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

		if(href_list["state"])
			on = !(on)
			update_icon()

		if(href_list["visible"])
			visible = !(visible)
			spawn(0)
				if(first)
					first.vis_spread(visible)

		if(href_list["close"])
			usr << browse(null, "window=infra")
			return

		if(usr)
			attack_self(usr)

		return


	verb/rotate()//This could likely be better
		set name = "Rotate Infrared Laser"
		set category = "Object"
		set src in usr

		dir = turn(dir, 90)
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
	if(master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		master.trigger_beam()
	del(src)
	return

/obj/effect/beam/i_beam/proc/vis_spread(v)
	//world << "i_beam \ref[src] : vis_spread"
	visible = v
	spawn(0)
		if(next)
			//world << "i_beam \ref[src] : is next [next.type] \ref[next], calling spread"
			next.vis_spread(v)
		return
	return

/obj/effect/beam/i_beam/process()
	//world << "i_beam \ref[src] : process"

	if((loc.density || !(master)))
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if(left > 0)
		left--
	if(left < 1)
		if(!(visible))
			invisibility = 101
		else
			invisibility = 0
	else
		invisibility = 0


	//world << "now [src.left] left"
	var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(loc)
	I.master = master
	I.density = 1
	I.dir = dir
	//world << "created new beam \ref[I] at [I.x] [I.y] [I.z]"
	step(I, I.dir)

	if(I)
		//world << "step worked, now at [I.x] [I.y] [I.z]"
		if(!(next))
			//world << "no next"
			I.density = 0
			//world << "spreading"
			I.vis_spread(visible)
			next = I
			spawn(0)
				//world << "limit = [limit] "
				if((I && limit > 0))
					I.limit = limit - 1
					//world << "calling next process"
					I.process()
				return
		else
			//world << "is a next: \ref[next], deleting beam \ref[I]"
			del(I)
	else
		//world << "step failed, deleting \ref[next]"
		del(next)
	spawn(10)
		process()
		return
	return

/obj/effect/beam/i_beam/Bump()
	del(src)
	return

/obj/effect/beam/i_beam/Bumped()
	hit()
	return

/obj/effect/beam/i_beam/HasEntered(atom/movable/AM as mob|obj)
	if(istype(AM, /obj/effect/beam))
		return
	spawn(0)
		hit()
		return
	return

/obj/effect/beam/i_beam/Del()
	del(next)
	..()
	return
