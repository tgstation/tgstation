/obj/item/device/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon = 'new_assemblies.dmi'
	icon_state = "prox"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 300
	origin_tech = "magnets=1"

	var
		secured = 0
		small_icon_state_left = "prox_left"
		small_icon_state_right = "prox_right"
		list/small_icon_state_overlays = null
		obj/holder = null
		scanning = 0
		cooldown = 0//To prevent spam
		timing = 0
		time = 0

	proc
		Activate()//Called when this assembly is pulsed by another one
		Secure()//Code that has to happen when the assembly is ready goes here
		Unsecure()//Code that has to happen when the assembly is taken off of the ready state goes here
		Attach_Assembly(var/obj/A, var/mob/user)//Called when an assembly is attacked by another
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var
		toggle_scan()
		sense()


	IsAssembly()
		return 1


	Process_cooldown()
		src.cooldown--
		if(src.cooldown <= 0)	return 0
		spawn(10)
			src.Process_cooldown()
		return 1


	Activate()
		if((!secured) || (cooldown > 0))
			return 0
		cooldown = 2
		src.timing = !src.timing
		update_icon()
		spawn(10)
			Process_cooldown()
		return 0


	Secure()
		if(secured)	return 0
		secured = 1
		processing_items.Add(src)//removal is taken care of it process()
		return 1


	Unsecure()
		if(!secured)	return 0
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


	HasProximity(atom/movable/AM as mob|obj)
		if (istype(AM, /obj/beam))
			return
		if (AM.move_speed < 12)
			src.sense()
		return


	sense()
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


	process()
		if((src.timing) && (src.time >= 0))
			src.time--
			if(src.time <= 0)
				src.timing = 0
				src.time = 0
				toggle_scan()

		if(!secured)
			if(scanning)
				scanning = 0
				src.timing = 0
			processing_items.Remove(src)
			update_icon()
		return


	dropped()
		spawn(0)
			src.sense()
			return
		return


	toggle_scan()
		if(!secured)	return 0
		scanning = !scanning
		update_icon()


	update_icon()
		src.overlays = null
		src.small_icon_state_overlays = list()
		if(timing)
			src.overlays += text("prox_timing")
			src.small_icon_state_overlays += text("prox_timing")
		if(scanning)
			src.overlays += text("prox_scanning")
			src.small_icon_state_overlays += text("prox_scanning")
		if(holder)
			holder.update_icon()
		return


	Move()
		..()
		src.sense()
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


	attack_self(mob/user as mob)
		if(!secured)
			user.show_message("\red The [src.name] is unsecured!")
			return 0
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Arming</A>", src) : text("<A href='?src=\ref[];time=1'>Not Arming</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><A href='?src=\ref[src];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=prox")
		onclose(user, "prox")
		return


	Topic(href, href_list)
		..()
		if(get_dist(src, usr) <= 1)
			if (href_list["scanning"])
				toggle_scan()

			if (href_list["time"])
				src.timing = text2num(href_list["time"])
				update_icon()

			if (href_list["tp"])
				var/tp = text2num(href_list["tp"])
				src.time += tp
				src.time = min(max(round(src.time), 0), 600)

			if (href_list["close"])
				usr << browse(null, "window=prox")
				return

			if(usr)
				src.attack_self(usr)

		else
			usr << browse(null, "window=prox")
		return