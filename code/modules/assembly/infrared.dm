/obj/item/device/infra
	name = "Infrared Beam"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon = 'new_assemblies.dmi'
	icon_state = "infrared_old"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=2"
	var
		secured = 0
		small_icon_state_left = "infrared_left"
		small_icon_state_right = "infrared_right"
		list/small_icon_state_overlays = null
		obj/holder = null
		cooldown = 0//To prevent spam
		scanning = 0
		visible = 0
		obj/effect/beam/i_beam/first = null

	proc
		Activate()//Called when this assembly is pulsed by another one
		Secure()//Code that has to happen when the assembly is ready goes here
		Unsecure()//Code that has to happen when the assembly is taken off of the ready state goes here
		Attach_Assembly(var/obj/A, var/mob/user)//Called when an assembly is attacked by another
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var
		Holder_Movement()//Called when the holder is moved
		beam_trigger()


	IsAssembly()
		return 1


	Process_cooldown()
		cooldown--
		if(cooldown <= 0)	return 0
		spawn(10)
			Process_cooldown()
		return 1


	Activate()
		if((!secured) || (cooldown > 0))
			return 0
		cooldown = 2
		src.scanning = !src.scanning
		update_icon()
		spawn(10)
			Process_cooldown()
		return 0


	Secure()
		if(secured)
			return 0
		secured = 1
		processing_objects.Add(src)//removal is taken care of it process()
		return 1


	Unsecure()
		if(!secured)
			return 0
		secured = 0
		return 1


	Attach_Assembly(var/obj/A, var/mob/user)
		holder = new/obj/item/device/assembly_holder(get_turf(src))
		if(holder:attach(A,src,user))
			user.show_message("\blue You attach the [A.name] to the [src.name]!")
			return 1
		return 0


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(W.IsAssembly())
			var/obj/item/device/D = W
			if((!D:secured) && (!src.secured))
				Attach_Assembly(D,user)
		if(isscrewdriver(W))
			if(src.secured)
				Unsecure()
				user.show_message("\blue The [src.name] can now be attached!")
			else
				Secure()
				user.show_message("\blue The [src.name] is ready!")
			return
		else
			..()
		return


	update_icon()
		src.overlays = null
		src.small_icon_state_overlays = list()
		if(scanning)
			src.overlays += text("infrared_old2")
			src.small_icon_state_overlays += text("infrared_on")

		if(holder)
			holder.update_icon()
		return


	process()
		if(!scanning)
			if(!src.first)
				del(src.first)

		if ((!( src.first ) && (src.secured && (istype(src.loc, /turf) || (src.holder && istype(src.holder.loc, /turf))))))
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

		if(!secured)
			processing_objects.Remove(src)
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


	Holder_Movement()
		if(!holder)	return 0
		src.dir = holder.dir
		del(src.first)


	beam_trigger()
		if((!secured)||(!scanning)||(cooldown > 0))	return 0
		if((holder)&&(holder.IsAssemblyHolder()))
			spawn(0)
				holder:Process_Activation(src)
				return
		for(var/mob/O in hearers(null, null))
			O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		cooldown = 2
		spawn(10)
			Process_cooldown()
		return


	attack_self(mob/user as mob)
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
		if(get_dist(src, usr) <= 1)
			if (href_list["state"])
				src.scanning = !(src.scanning)
				update_icon()

			if (href_list["visible"])
				src.visible = !(src.visible)
				spawn( 0 )
					if (src.first)
						src.first.vis_spread(src.visible)

			if (href_list["close"])
				usr << browse(null, "window=infra")
				return

			if(usr)
				src.attack_self(usr)

		else
			usr << browse(null, "window=infra")
			onclose(usr, "infra")
			return
		return


	verb/rotate()//This really could be better but I dont want to redo it right now
		set name = "Rotate Infrared Laser"
		set category = "Object"
		set src in usr

		src.dir = turn(src.dir, 90)
		return


	examine()
		set src in view()
		..()
		if ((in_range(src, usr) || src.loc == usr))
			if (src.secured)
				usr.show_message("The [src.name] is ready!")
			else
				usr.show_message("The [src.name] can be attached!")
		return








/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "i beam"
	icon = 'projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/item/device/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
//	var/master = null
	anchored = 1.0
	flags = TABLEPASS


/obj/effect/beam/i_beam/proc/hit()
	//world << "beam \ref[src]: hit"
	if (src.master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		src.master.beam_trigger()
	//SN src = null
	del(src)
	return

/obj/effect/beam/i_beam/proc/vis_spread(v)
	//world << "i_beam \ref[src] : vis_spread"
	src.visible = v
	spawn( 0 )
		if (src.next)
			//world << "i_beam \ref[src] : is next [next.type] \ref[next], calling spread"
			src.next.vis_spread(v)
		return
	return

/obj/effect/beam/i_beam/process()
	//world << "i_beam \ref[src] : process"

	if ((src.loc.density || !( src.master )))
		//SN src = null
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if (src.left > 0)
		src.left--
	if (src.left < 1)
		if (!( src.visible ))
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

	if (I)
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
			//I = null
			del(I)
	else
		//src.next = null
		//world << "step failed, deleting \ref[src.next]"
		del(src.next)
	spawn( 10 )
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
	if (istype(AM, /obj/effect/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/effect/beam/i_beam/Del()
	del(src.next)
	..()
	return