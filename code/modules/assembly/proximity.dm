/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	materials = list(MAT_METAL=800, MAT_GLASS=200)
	origin_tech = "magnets=1;engineering=1"
	attachable = 1

	var/scanning = 0
	var/timing = 0
	var/time = 10
	var/sensitivity = 1
	var/atom/oldloc
	var/list/turfs_around = list()

/obj/item/device/assembly/prox_sensor/proc/toggle_scan()


/obj/item/device/assembly/prox_sensor/proc/sense()


/obj/item/device/assembly/prox_sensor/New()
	..()
	START_PROCESSING(SSobj, src)
	oldloc = loc

/obj/item/device/assembly/prox_sensor/describe()
	if(timing)
		return "<span class='notice'>The proximity sensor is arming.</span>"
	return "The proximity sensor is [scanning?"armed":"disarmed"]."

/obj/item/device/assembly/prox_sensor/on_attach(datum/wires/w)
	handle_move(w.holder)

/obj/item/device/assembly/prox_sensor/on_detach(datum/wires/w)
	handle_move(w.holder.loc)

/obj/item/device/assembly/prox_sensor/activate()
	if(!..())
		return 0//Cooldown check
	timing = !timing
	update_icon()
	return 1


/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(!secured)
		scanning = 0
		timing = 0
	update_icon()
	return secured


/obj/item/device/assembly/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/effect/beam))
		return
	sense()


/obj/item/device/assembly/prox_sensor/sense()
	if(!secured || next_activate > world.time)
		return 0
	pulse(0)
	audible_message("\icon[src] *beep* *beep*", null, 3)
	next_activate = world.time + 30


/obj/item/device/assembly/prox_sensor/process()
	if(timing)
		time--
		if(time <= 0)
			timing = 0
			toggle_scan(1)
			time = initial(time)
	handle_move(loc)

/obj/item/device/assembly/prox_sensor/dropped()
	..()
	if(scanning)
		addtimer(CALLBACK(src, .proc/sense), 0)

/obj/item/device/assembly/prox_sensor/Destroy()
	if(scanning)
		remove_from_proximity_list(src, sensitivity, oldloc)
	return ..()

/obj/item/device/assembly/prox_sensor/toggle_scan(scan)
	if(!secured)
		return 0
	scanning = scan
	if(scanning)
		add_to_proximity_list(src, sensitivity)
	else
		remove_from_proximity_list(src, sensitivity)
	oldloc = get_turf(loc)
	update_icon()

/obj/item/device/assembly/prox_sensor/proc/sensitivity_change(value)
	var/sense = min(max(sensitivity + value, 0), 5)
	if(scanning)
		if(shift_proximity(src, oldloc, sensitivity, loc, sense))
			sense()
			oldloc = loc
	sensitivity = sense

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

/obj/item/device/assembly/prox_sensor/proc/handle_move(atom/newloc)
	if(scanning)
		if(shift_proximity(src, oldloc, sensitivity, newloc, sensitivity) ||  newloc != oldloc)
			sense()
			oldloc = newloc

/obj/item/device/assembly/prox_sensor/Moved()
	..()
	handle_move(loc)


/obj/item/device/assembly/prox_sensor/interact(mob/user)//TODO: Change this to the wires thingy
	if(is_secured(user))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = "<TT><B>Proximity Sensor</B>\n[(timing ? "<A href='?src=\ref[src];time=0'>Arming</A>" : "<A href='?src=\ref[src];time=1'>Not Arming</A>")] [minute]:[second]\n<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT>"
		dat += "<BR><A href='?src=\ref[src];scanning=[scanning?"0'>Armed":"1'>Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR>Detection range: <A href='?src=\ref[src];sense=down'>-</A> [sensitivity] <A href='?src=\ref[src];sense=up'>+</A>"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
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
		timing = text2num(href_list["time"])
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

