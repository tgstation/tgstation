<<<<<<< HEAD
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
	if((!secured)||(cooldown > 0))
		return 0
	pulse(0)
	audible_message("\icon[src] *beep* *beep*", null, 3)
	cooldown = 2
	addtimer(src, "process_cooldown", 10)


/obj/item/device/assembly/prox_sensor/process()
	if(timing)
		time--
		if(time <= 0)
			timing = 0
			toggle_scan(1)
			time = initial(time)
	handle_move(get_turf(loc))

/obj/item/device/assembly/prox_sensor/dropped()
	..()
	if(scanning)
		addtimer(src, "sense", 0)


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
		shift_proximity(src, oldloc, sensitivity, loc, sense)
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
		if(shift_proximity(src, oldloc, sensitivity, newloc, sensitivity))
			sense()
			oldloc = newloc

/obj/item/device/assembly/prox_sensor/Move(newloc)
	..()
	handle_move(newloc)


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

=======
/var/global/list/prox_sensor_ignored_types = list \
(
	/obj/effect/beam
)

/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	short_name = "prox sensor"

	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	starting_materials = list(MAT_IRON = 800, MAT_GLASS = 200)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	flags = FPRINT | PROXMOVE

	secured = 0

	var/scanning = 0
	var/timing = 0
	var/time = 10

	var/default_time = 10

	var/range = 2

	accessible_values = list("Scanning" = "scanning;number",\
		"Scan range" = "range;number;1;5",\
		"Remaining time" = "time;number",\
		"Default time" = "default_time;number",\
		"Timing" = "timing;number")

/obj/item/device/assembly/prox_sensor/activate()
	if(!..())	return 0//Cooldown check
	timing = !timing
	update_icon()
	return 0

/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		processing_objects.Add(src)
	else
		scanning = 0
		timing = 0
		processing_objects.Remove(src)
	update_icon()
	return secured

/obj/item/device/assembly/prox_sensor/HasProximity(var/atom/movable/AM)
	if(timestopped || (loc && loc.timestopped))
		return

	if(is_type_in_list(AM, global.prox_sensor_ignored_types))
		return

	if(AM.move_speed < 12)
		sense()

/obj/item/device/assembly/prox_sensor/proc/sense()
	var/turf/mainloc = get_turf(src)
//	if(scanning && cooldown <= 0)
//		mainloc.visible_message("[bicon(src)] *boop* *boop*", "*boop* *boop*")
	if((!holder && !secured)||(!scanning)||(cooldown > 0))	return 0
	pulse(0)
	if(!holder)
		mainloc.visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()
	return

/obj/item/device/assembly/prox_sensor/process()
	if(scanning)
		var/turf/mainloc = get_turf(src)
		for(var/mob/living/A in range(range,mainloc))
			if (A.move_speed < 12)
				sense()

	if(timing && (time >= 0))
		time--
	if(timing && time <= 0)
		timing = 0
		toggle_scan()
		time = default_time
	return

/obj/item/device/assembly/prox_sensor/dropped()
	spawn(0)
		sense()
		return
	return

/obj/item/device/assembly/prox_sensor/proc/toggle_scan()
	if(!secured)	return 0
	scanning = !scanning
	update_icon()
	return

/obj/item/device/assembly/prox_sensor/update_icon()
	overlays.len = 0
	attached_overlays = list()
	if(timing)
		attached_overlays += "prox_timing"
		overlays += image(icon = icon, icon_state = "prox_timing")
	if(scanning)
		attached_overlays += "prox_scanning"
		overlays += image(icon = icon, icon_state = "prox_scanning")
	if(holder)
		holder.update_icon()
	if(holder && istype(holder.loc,/obj/item/weapon/grenade/chem_grenade))
		var/obj/item/weapon/grenade/chem_grenade/grenade = holder.loc
		grenade.primed(scanning)
	return

/obj/item/device/assembly/prox_sensor/Move()
	..()
	sense()
	return

/obj/item/device/assembly/prox_sensor/interact(mob/user as mob)//TODO: Change this to the wires thingy
	if(!secured)
		user.show_message("<span class='warning'>The [name] is unsecured!</span>")
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = text("<TT><B>Proximity Sensor</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Arming</A>", src) : text("<A href='?src=\ref[];time=1'>Not Arming</A>", src)), minute, second, src, src, src, src)
	dat += text("<BR>Range: <A href='?src=\ref[];range=-1'>-</A> [] <A href='?src=\ref[];range=1'>+</A>", src, range, src)

	dat += {"<BR><A href='?src=\ref[src];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)
		<BR><BR><A href='?src=\ref[src];set_default_time=1'>After countdown, reset time to [(default_time - default_time%60)/60]:[(default_time % 60)]</A>
		<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>
		<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"}
	user << browse(dat, "window=prox")
	onclose(user, "prox")
	return


/obj/item/device/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained() || !in_range(loc, usr) || (!usr.canmove && !usr.locked_to))
		//If the user is handcuffed or out of range, or if they're unable to move,
		//but NOT if they're unable to move as a result of being buckled into something, they're unable to use the device.
		usr << browse(null, "window=prox")
		onclose(usr, "prox")
		return

	if(href_list["scanning"])
		toggle_scan()

	if(href_list["time"])
		timing = text2num(href_list["time"])
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["range"])
		var/r = text2num(href_list["range"])
		range += r
		range = Clamp(range, 1, 5)

	if(href_list["set_default_time"])
		default_time = time

	if(href_list["close"])
		usr << browse(null, "window=prox")
		return

	if(usr)
		attack_self(usr)

	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
