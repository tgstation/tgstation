/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	m_amt = 500
	g_amt = 50
	origin_tech = "magnets=1"

	secured = 0

	var/timing = 0
	var/time = 5


/obj/item/device/assembly/timer/describe()
	if(timing)
		return "The timer is counting down from [time]!"
	return "The timer is set for [time] seconds."


/obj/item/device/assembly/timer/activate()
	if(!..())	return 0//Cooldown check
	timing = !timing
	update_icon()
	return 0


/obj/item/device/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		processing_objects.Add(src)
	else
		timing = 0
		processing_objects.Remove(src)
	update_icon()
	return secured


/obj/item/device/assembly/timer/proc/timer_end()
	if((!secured)||(cooldown > 0))	return 0
	pulse(0)
	visible_message("\icon[src] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()
	return


/obj/item/device/assembly/timer/process()
	if(timing && (time > 0))
		time--
	if(timing && time <= 0)
		timing = 0
		timer_end()
		time = initial(time)
	return


/obj/item/device/assembly/timer/update_icon()
	overlays.Cut()
	attached_overlays = list()
	if(timing)
		overlays += "timer_timing"
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/timer/interact(mob/user as mob)//TODO: Have this use the wires
	if(!secured)
		user.show_message("<span class='danger'>The [name] is unsecured!</span>")
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = text("<TT><B>Timing Unit</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)
	dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
	dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
	var/datum/browser/popup = new(user, "timer", name)
	popup.set_content(dat)
	popup.open()
	return


/obj/item/device/assembly/timer/Topic(href, href_list)
	..()
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=timer")
		onclose(usr, "timer")
		return

	if(href_list["time"])
		timing = text2num(href_list["time"])
		if(timing && istype(holder, /obj/item/device/transfer_valve))
			var/timer_message = "[key_name_admin(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) activated [src] attachment on [holder]."
			message_admins(timer_message)
			bombers += timer_message
			log_game("[key_name(usr)] activated [src] attachment for [loc]")
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 1), 600)

	if(href_list["close"])
		usr << browse(null, "window=timer")
		return

	if(usr)
		attack_self(usr)

	return
