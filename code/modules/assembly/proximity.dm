/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	attachable = TRUE

	var/scanning = FALSE
	var/timing = FALSE
	var/time = 10
	var/sensitivity = 1

/obj/item/device/assembly/prox_sensor/Initialize()
	. = ..()
	proximity_monitor = new(src, 0, FALSE)

/obj/item/device/assembly/prox_sensor/Destroy()
	set_timing(FALSE)  // stops processing if necessary

/obj/item/device/assembly/prox_sensor/describe()
	if(timing)
		return "<span class='notice'>The proximity sensor is arming.</span>"
	return "The proximity sensor is [scanning?"armed":"disarmed"]."

/obj/item/device/assembly/prox_sensor/activate()
	if(!..())
		return FALSE //Cooldown check
	set_timing(!timing)
	update_icon()
	return TRUE

/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(!secured)
		set_timing(FALSE)
		if(scanning)
			toggle_scan(FALSE)
	update_icon()
	return secured

/obj/item/device/assembly/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/effect/beam))
		return
	sense()


/obj/item/device/assembly/prox_sensor/proc/sense()
	if(!scanning || !secured || next_activate > world.time)
		return 0
	pulse(0)
	audible_message("[icon2html(src, hearers(src))] *beep* *beep*", null, 3)
	next_activate = world.time + 30

/obj/item/device/assembly/prox_sensor/process()
	if(timing)
		time -= SSobj.wait / 10
		if(time <= 0)
			set_timing(FALSE)
			toggle_scan(TRUE)
			time = initial(time)

/obj/item/device/assembly/prox_sensor/proc/toggle_scan(scan)
	if(!secured)
		return
	scanning = scan
	proximity_monitor.SetRange(scanning ? sensitivity : 0)
	update_icon()

/obj/item/device/assembly/prox_sensor/proc/sensitivity_change(value)
	var/sense = min(max(sensitivity + value, 0), 5)
	sensitivity = sense
	if(scanning && proximity_monitor.SetRange(sense))
		sense()

/obj/item/device/assembly/prox_sensor/proc/set_timing(new_timing)
	if (new_timing && !timing)
		START_PROCESSING(SSprocessing, src)
	else if (timing && !new_timing)
		STOP_PROCESSING(SSprocessing, src)
	timing = new_timing

/obj/item/device/assembly/prox_sensor/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(timing)
		add_overlay("prox_timing")
		attached_overlays += "prox_timing"
	if(scanning)
		add_overlay("prox_scanning")
		attached_overlays += "prox_scanning"
	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/prox_sensor/ui_interact(mob/user)//TODO: Change this to the wires thingy
	. = ..()
	if(is_secured(user))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = "<TT><B>Proximity Sensor</B>\n[(timing ? "<A href='?src=[REF(src)];time=0'>Arming</A>" : "<A href='?src=[REF(src)];time=1'>Not Arming</A>")] [minute]:[second]\n<A href='?src=[REF(src)];tp=-30'>-</A> <A href='?src=[REF(src)];tp=-1'>-</A> <A href='?src=[REF(src)];tp=1'>+</A> <A href='?src=[REF(src)];tp=30'>+</A>\n</TT>"
		dat += "<BR><A href='?src=[REF(src)];scanning=[scanning?"0'>Armed":"1'>Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR>Detection range: <A href='?src=[REF(src)];sense=down'>-</A> [sensitivity] <A href='?src=[REF(src)];sense=up'>+</A>"
		dat += "<BR><BR><A href='?src=[REF(src)];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=[REF(src)];close=1'>Close</A>"
		user << browse(dat, "window=prox")
		onclose(user, "prox")
		return


/obj/item/device/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=prox")
		onclose(usr, "prox")
		return

	if(href_list["sense"])
		sensitivity_change(((href_list["sense"] == "up") ? 1 : -1))

	if(href_list["scanning"])
		toggle_scan(text2num(href_list["scanning"]))

	if(href_list["time"])
		set_timing(text2num(href_list["time"]))
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["close"])
		usr << browse(null, "window=prox")
		return

	if(usr)
		attack_self(usr)

