/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which has to count down. Tick tock."
	icon_state = "timer"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1;engineering=1"
	attachable = 1

	var/timing = 0
	var/time = 5
	var/saved_time = 5
	var/loop = 0


/obj/item/device/assembly/timer/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/device/assembly/timer/describe()
	if(timing)
		return "The timer is counting down from [time]!"
	return "The timer is set for [time] seconds."


/obj/item/device/assembly/timer/activate()
	if(!..())
		return 0//Cooldown check
	timing = !timing
	update_icon()
	return 1


/obj/item/device/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		timing = 0
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured


/obj/item/device/assembly/timer/proc/timer_end()
	if(!secured || next_activate > world.time)
		return FALSE
	pulse(0)
	audible_message("\icon[src] *beep* *beep*", null, 3)
	if(loop)
		timing = 1
	update_icon()


/obj/item/device/assembly/timer/process()
	if(timing)
		time--
		if(time <= 0)
			timing = 0
			timer_end()
			time = saved_time


/obj/item/device/assembly/timer/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(timing)
		add_overlay("timer_timing")
		attached_overlays += "timer_timing"
	if(holder)
		holder.update_icon()


/obj/item/device/assembly/timer/interact(mob/user)//TODO: Have this use the wires
	if(is_secured(user))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = "<TT><B>Timing Unit</B>\n[(timing ? "<A href='?src=\ref[src];time=0'>Timing</A>" : "<A href='?src=\ref[src];time=1'>Not Timing</A>")] [minute]:[second]\n<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT>"
		dat += "<BR><BR><A href='?src=\ref[src];repeat=[(loop ? "0'>Stop repeating" : "1'>Set to repeat")]</A>"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		var/datum/browser/popup = new(user, "timer", name)
		popup.set_content(dat)
		popup.open()


/obj/item/device/assembly/timer/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=timer")
		onclose(usr, "timer")
		return

	if(href_list["time"])
		timing = text2num(href_list["time"])
		if(timing && istype(holder, /obj/item/device/transfer_valve))
			var/timer_message = "[ADMIN_LOOKUPFLW(usr)] activated [src] attachment on [holder]."
			message_admins(timer_message)
			GLOB.bombers += timer_message
			log_game("[key_name(usr)] activated [src] attachment on [holder]")
		update_icon()
	if(href_list["repeat"])
		loop = text2num(href_list["repeat"])

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 1), 600)
		saved_time = time

	if(href_list["close"])
		usr << browse(null, "window=timer")
		return

	if(usr)
		attack_self(usr)
