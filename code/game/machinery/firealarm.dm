/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1
	var/time = 10
	var/timing = 0
	var/lockdownbyai = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/last_process = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/update_icon()
	src.overlays = list()

	var/area/A = src.loc
	A = A.loc

	if(panel_open)
		switch(buildstage)
			if(0)
				icon_state="fire_b0"
				return
			if(1)
				icon_state="fire_b1"
				return
			if(2)
				icon_state="fire_b2"

		if((stat & BROKEN) || (stat & NOPOWER))
			return

		overlays += "overlay_[security_level]"
		return

	if(stat & BROKEN)
		icon_state = "firex"
		return

	icon_state = "fire0"

	if(stat & NOPOWER)
		return

	overlays += "overlay_[security_level]"

	if(!src.detecting)
		overlays += "overlay_fire"
	else
		overlays += "overlay_[A.fire ? "fire" : "clear"]"



/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		src.emagged = 1
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>", "<span class='notice'>You emag the [src], disabling its thermal sensors.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		return


/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			if(!emagged) //Doesn't give off alarm when emagged
				src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity)) alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/weapon/screwdriver) && buildstage == 2)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		user << "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>"
		update_icon()
		return

	if(panel_open)
		switch(buildstage)
			if(2)
				if(istype(W, /obj/item/device/multitool))
					src.detecting = !( src.detecting )
					if (src.detecting)
						user.visible_message("[user] has reconnected [src]'s detecting unit!", "<span class='notice'>You reconnect [src]'s detecting unit.</span>")
					else
						user.visible_message("[user] has disconnected [src]'s detecting unit!", "<span class='notice'>You disconnect [src]'s detecting unit.</span>")
					return

				else if (istype(W, /obj/item/weapon/wirecutters))
					buildstage = 1
					playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
					var/obj/item/stack/cable_coil/coil = new /obj/item/stack/cable_coil()
					coil.amount = 5
					coil.loc = user.loc
					user << "<span class='notice'>You cut the wires from \the [src].</span>"
					update_icon()
					return
			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.get_amount() < 5)
						user << "<span class='warning'>You need more cable for this!</span>"
					else
						coil.use(5)
						buildstage = 2
						user << "<span class='notice'>You wire \the [src].</span>"
						update_icon()
					return

				else if(istype(W, /obj/item/weapon/crowbar))
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										"<span class='notice'>You start prying out the circuit...</span>")
					if(do_after(user, 20/W.toolspeed, target = src))
						if(buildstage == 1)
							if(stat & BROKEN)
								user << "<span class='notice'>You remove the destroyed circuit.</span>"
							else
								user << "<span class='notice'>You pry out the circuit.</span>"
								new /obj/item/weapon/electronics/firealarm(user.loc)
							buildstage = 0
							update_icon()
					return
			if(0)
				if(istype(W, /obj/item/weapon/electronics/firealarm))
					user << "<span class='notice'>You insert the circuit.</span>"
					qdel(W)
					buildstage = 1
					update_icon()
					return

				else if(istype(W, /obj/item/weapon/wrench))
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										 "<span class='notice'>You remove the fire alarm assembly from the wall.</span>")
					var/obj/item/wallframe/firealarm/frame = new /obj/item/wallframe/firealarm()
					frame.loc = user.loc
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					qdel(src)
					return
	return ..()

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(src.timing)
		if(src.time > 0)
			src.time = src.time - ((world.timeofday - last_process)/10)
		else
			src.alarm()
			src.time = 0
			src.timing = 0
			SSobj.processing.Remove(src)
		src.updateDialog()
	last_process = world.timeofday
	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		if(loc)
			update_icon()

/obj/machinery/firealarm/attack_hand(mob/user)
	if((user.stat && !IsAdminGhost(user)) || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/A = src.loc
	var/safety_warning
	var/d1
	var/d2
	var/dat = ""
	if (istype(user, /mob/living/carbon/human) || user.has_unlimited_silicon_privilege)
		A = A.loc
		if (src.emagged)
			safety_warning = text("<font color='red'>NOTICE: Thermal sensors nonfunctional. Device will not report or recognize high temperatures.</font>")
		else
			safety_warning = text("Safety measures functioning properly.")
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat = "[safety_warning]<br /><br />[d1]<br /><b>The current alert level is: [get_security_level()]</b><br /><br />Timer System: [d2]<br />Time Left: <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
		//user << browse(dat, "window=firealarm")
		//onclose(user, "firealarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(src.time) % 60
		var/minute = (round(src.time) - second) / 60
		dat = "[d1]<br /><b>The current alert level is: [stars(get_security_level())]</b><br /><br />Timer System: [d2]<br />Time Left: <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>"
		//user << browse(dat, "window=firealarm")
		//onclose(user, "firealarm")
	var/datum/browser/popup = new(user, "firealarm", "Fire Alarm")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/firealarm/Topic(href, href_list)
	if(..())
		return

	if (buildstage != 2)
		return

	usr.set_machine(src)
	if (href_list["reset"])
		src.reset()
	else if (href_list["alarm"])
		src.alarm()
	else if (href_list["time"])
		src.timing = text2num(href_list["time"])
		last_process = world.timeofday
		SSobj.processing |= src
	else if (href_list["tp"])
		var/tp = text2num(href_list["tp"])
		src.time += tp
		src.time = min(max(round(src.time), 0), 120)

	src.updateUsrDialog()

/obj/machinery/firealarm/proc/reset()
	if (stat & (NOPOWER|BROKEN)) // can't reset alarm if it's unpowered or broken.
		return
	var/area/A = get_area(src)
	A.firereset(src)
	return

/obj/machinery/firealarm/proc/alarm()
	if (stat & (NOPOWER|BROKEN))  // can't activate alarm if it's unpowered or broken.
		return
	var/area/A = get_area(src)
	if(!A.fire)
		A.firealert(src)
	//playsound(src.loc, 'sound/ambience/signal.ogg', 75, 0)
	return

/obj/machinery/firealarm/New(loc, ndir, building)
	..()

	if(ndir)
		src.dir = ndir

	if(building)
		buildstage = 0
		panel_open = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(z == 1)
		if(security_level)
			src.overlays += image('icons/obj/monitors.dmi', "overlay_[get_security_level()]")
		else
			src.overlays += image('icons/obj/monitors.dmi', "overlay_green")

	update_icon()

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/weapon/electronics/firealarm
	name = "fire alarm electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""


/*
FIRE ALARM ITEM
Handheld fire alarm frame, for placing on walls
*/
/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm

/*
 * Party button
 */

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"

/obj/machinery/firealarm/partyalarm/attack_hand(mob/user)
	if((user.stat && !IsAdminGhost(user)) || stat & (NOPOWER|BROKEN))
		return

	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/A = src.loc
	var/d1
	var/dat
	if (istype(user, /mob/living/carbon/human) || user.has_unlimited_silicon_privilege)
		A = A.loc

		if (A.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []</BODY></HTML>", d1)

	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []", stars("Party Button"), d1)

	var/datum/browser/popup = new(user, "firealarm", "Party Alarm")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/firealarm/partyalarm/reset()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.partyreset()
	return

/obj/machinery/firealarm/partyalarm/alarm()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.partyalert()
	return
