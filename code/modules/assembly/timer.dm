/obj/item/device/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon = 'new_assemblies.dmi'
	icon_state = "timer"
	item_state = "electronic"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	m_amt = 100
	var
		secured = 0
		small_icon_state_left = "timer_left"
		small_icon_state_right = "timer_right"
		list/small_icon_state_overlays = null
		obj/holder = null
		cooldown = 0//To prevent spam
		timing = 0
		time = 0

	proc
		Activate()//Called when this assembly is pulsed by another one
		Secure()//Code that has to happen when the assembly is ready goes here
		Unsecure()//Code that has to happen when the assembly is taken off of the ready state goes here
		Attach_Assembly(var/obj/A, var/mob/user)//Called when an assembly is attacked by another
		Process_cooldown()//Call this via spawn(10) to have it count down the cooldown var
		timer_end()

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
		src.timing = !src.timing
		update_icon()
		spawn(10)
			Process_cooldown()
		return 0


	Secure()
		if(secured)
			return 0
		processing_items.Add(src)//removal is taken care of it process()
		secured = 1
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


	timer_end()
		if((!secured)||(cooldown > 0))	return 0
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
				timer_end()
				update_icon()

		if(!secured)
			src.timing = 0
			processing_items.Remove(src)
			update_icon()
		return


	update_icon()
		src.overlays = null
		src.small_icon_state_overlays = list()
		if(timing)
			src.overlays += text("timer_timing")
			src.small_icon_state_overlays += text("timer_timing")
		if(holder)
			holder.update_icon()
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
		var/dat = text("<TT><B>Timing Unit</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (src.timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=timer")
		onclose(user, "timer")
		return


	Topic(href, href_list)
		..()
		if(get_dist(src, usr) <= 1)

			if (href_list["time"])
				src.timing = text2num(href_list["time"])
				update_icon()

			if (href_list["tp"])
				var/tp = text2num(href_list["tp"])
				src.time += tp
				src.time = min(max(round(src.time), 0), 600)

			if (href_list["close"])
				usr << browse(null, "window=timer")
				return

			if(usr)
				src.attack_self(usr)

		else
			usr << browse(null, "window=timer")
		return