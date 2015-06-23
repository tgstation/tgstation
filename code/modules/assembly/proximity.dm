/obj/item/device/assembly/prox_sensor
	name = "proximity sensor"
	desc = "Used for scanning and alerting when someone enters a certain proximity."
	icon_state = "prox"
	m_amt = 800
	g_amt = 200
	origin_tech = "magnets=1"
	attachable = 1
	flags = PROXMOVE
	var/scanning = 0
	var/timing = 0
	var/time = 10

/obj/item/device/assembly/prox_sensor/proc/toggle_scan()


/obj/item/device/assembly/prox_sensor/proc/sense()

/obj/item/device/assembly/prox_sensor/describe()
	if(timing)
		return "<span class='notice'>The proximity sensor is arming.</span>"
	return "The proximity sensor is [scanning?"armed":"disarmed"]."

/obj/item/device/assembly/prox_sensor/activate()
	if(!..())	return 0//Cooldown check
	timing = !timing
	update_icon()
	return 0


/obj/item/device/assembly/prox_sensor/toggle_secure()
	secured = !secured
	if(secured)
		SSobj.processing |= src
	else
		scanning = 0
		timing = 0
		SSobj.processing.Remove(src)
	update_icon()
	return secured


/obj/item/device/assembly/prox_sensor/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/effect/beam))	return
	sense()


/obj/item/device/assembly/prox_sensor/sense()
	if((!secured)||(!scanning)||(cooldown > 0))	return 0
	pulse(0)
	audible_message("\icon[src] *beep* *beep*", null, 3)
	cooldown = 2
	spawn(10)
		process_cooldown()
	return


/obj/item/device/assembly/prox_sensor/process()
	if(timing && (time >= 0))
		time--
	if(timing && time <= 0)
		timing = 0
		toggle_scan()
		time = 10
	return


/obj/item/device/assembly/prox_sensor/dropped()
	spawn(0)
		sense()
		return
	return


/obj/item/device/assembly/prox_sensor/toggle_scan()
	if(!secured)	return 0
	scanning = !scanning
	update_icon()
	return


/obj/item/device/assembly/prox_sensor/update_icon()
	overlays.Cut()
	attached_overlays = list()
	if(timing)
		overlays += "prox_timing"
		attached_overlays += "prox_timing"
	if(scanning)
		overlays += "prox_scanning"
		attached_overlays += "prox_scanning"
	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/prox_sensor/Move()
	..()
	sense()
	return


/obj/item/device/assembly/prox_sensor/interact(mob/user as mob)//TODO: Change this to the wires thingy
	if(is_secured(user))
		var/second = time % 60
		var/minute = (time - second) / 60
		var/dat = "<TT><B>Proximity Sensor</B>\n[(timing ? "<A href='?src=\ref[src];time=0'>Arming</A>" : "<A href='?src=\ref[src];time=1'>Not Arming</A>")] [minute]:[second]\n<A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n</TT>"
		dat += "<BR><A href='?src=\ref[src];scanning=1'>[scanning?"Armed":"Unarmed"]</A> (Movement sensor active when armed!)"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=prox")
		onclose(user, "prox")
		return


/obj/item/device/assembly/prox_sensor/Topic(href, href_list)
	..()
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
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

	if(href_list["close"])
		usr << browse(null, "window=prox")
		return

	if(usr)
		attack_self(usr)


	return
