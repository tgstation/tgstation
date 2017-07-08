/obj/item/weapon/electronics/firealarm
	name = "fire alarm electronics"
	desc = "A fire alarm circuit. Can handle heat levels up to 40 degrees celsius."

/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	anchored = 1
	obj_integrity = 250
	max_integrity = 250
	integrity_failure = 100
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 100, fire = 90, acid = 30)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/detecting = 1
	var/buildstage = 2 // 2 = complete, 1 = no wires, 0 = circuit gone
	resistance_flags = FIRE_PROOF


/obj/machinery/firealarm/New(loc, dir, building)
	..()
	if(dir)
		src.setDir(dir)
	if(building)
		buildstage = 0
		panel_open = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
	update_icon()

/obj/machinery/firealarm/power_change()
	..()
	update_icon()

/obj/machinery/firealarm/update_icon()
	cut_overlays()

	var/area/A = src.loc
	A = A.loc

	if(panel_open)
		icon_state = "fire_b[buildstage]"
		return
	else
		icon_state = "fire0"

		if(stat & BROKEN)
			icon_state = "firex"
			return

		if(stat & NOPOWER)
			return

		if(src.z == ZLEVEL_STATION)
			add_overlay("overlay_[GLOB.security_level]")
		else
			//var/green = SEC_LEVEL_GREEN
			add_overlay("overlay_[SEC_LEVEL_GREEN]")

		if(detecting)
			add_overlay("overlay_[A.fire ? "fire" : "clear"]")
		else
			add_overlay("overlay_fire")

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50 / severity))
		alarm()
	..()

/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>",
								"<span class='notice'>You emag [src], disabling its thermal sensors.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(!emagged && detecting && !stat && (temperature > T0C + 200 || temperature < BODYTEMP_COLD_DAMAGE_LIMIT))
		alarm()
	..()

/obj/machinery/firealarm/proc/alarm()
	if(!is_operational())
		return
	var/area/A = get_area(src)
	A.firealert(src)
	playsound(src.loc, 'goon/sound/machinery/FireAlarm.ogg', 75)

/obj/machinery/firealarm/proc/alarm_in(time)
	addtimer(CALLBACK(src, .proc/alarm), time)

/obj/machinery/firealarm/proc/reset()
	if(!is_operational())
		return
	var/area/A = get_area(src)
	A.firereset(src)

/obj/machinery/firealarm/proc/reset_in(time)
	addtimer(CALLBACK(src, .proc/reset), time)

/obj/machinery/firealarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "firealarm", name, 300, 150, master_ui, state)
		ui.open()

/obj/machinery/firealarm/ui_data(mob/user)
	var/list/data = list()
	data["emagged"] = emagged

	if(src.z == ZLEVEL_STATION)
		data["seclevel"] = get_security_level()
	else
		data["seclevel"] = "green"

	var/area/A = get_area(src)
	data["alarm"] = A.fire

	return data

/obj/machinery/firealarm/ui_act(action, params)
	if(..() || buildstage != 2)
		return
	switch(action)
		if("reset")
			reset()
			. = TRUE
		if("alarm")
			alarm()
			. = TRUE

/obj/machinery/firealarm/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/weapon/screwdriver) && buildstage == 2)
		playsound(src.loc, W.usesound, 50, 1)
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>")
		update_icon()
		return

	if(panel_open)

		if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent == INTENT_HELP)
			var/obj/item/weapon/weldingtool/WT = W
			if(obj_integrity < max_integrity)
				if(WT.remove_fuel(0,user))
					to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
					playsound(loc, WT.usesound, 40, 1)
					if(do_after(user, 40*WT.toolspeed, target = src))
						obj_integrity = max_integrity
						playsound(loc, 'sound/items/welder2.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You repair [src].</span>")
			else
				to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
			return

		switch(buildstage)
			if(2)
				if(istype(W, /obj/item/device/multitool))
					detecting = !detecting
					if (src.detecting)
						user.visible_message("[user] has reconnected [src]'s detecting unit!", "<span class='notice'>You reconnect [src]'s detecting unit.</span>")
					else
						user.visible_message("[user] has disconnected [src]'s detecting unit!", "<span class='notice'>You disconnect [src]'s detecting unit.</span>")
					return

				else if (istype(W, /obj/item/weapon/wirecutters))
					buildstage = 1
					playsound(src.loc, W.usesound, 50, 1)
					new /obj/item/stack/cable_coil(user.loc, 5)
					to_chat(user, "<span class='notice'>You cut the wires from \the [src].</span>")
					update_icon()
					return
			if(1)
				if(istype(W, /obj/item/stack/cable_coil))
					var/obj/item/stack/cable_coil/coil = W
					if(coil.get_amount() < 5)
						to_chat(user, "<span class='warning'>You need more cable for this!</span>")
					else
						coil.use(5)
						buildstage = 2
						to_chat(user, "<span class='notice'>You wire \the [src].</span>")
						update_icon()
					return

				else if(istype(W, /obj/item/weapon/crowbar))
					playsound(src.loc, W.usesound, 50, 1)
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										"<span class='notice'>You start prying out the circuit...</span>")
					if(do_after(user, 20*W.toolspeed, target = src))
						if(buildstage == 1)
							if(stat & BROKEN)
								to_chat(user, "<span class='notice'>You remove the destroyed circuit.</span>")
								stat &= ~BROKEN
							else
								to_chat(user, "<span class='notice'>You pry out the circuit.</span>")
								new /obj/item/weapon/electronics/firealarm(user.loc)
							buildstage = 0
							update_icon()
					return
			if(0)
				if(istype(W, /obj/item/weapon/electronics/firealarm))
					to_chat(user, "<span class='notice'>You insert the circuit.</span>")
					qdel(W)
					buildstage = 1
					update_icon()
					return

				else if(istype(W, /obj/item/weapon/wrench))
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										 "<span class='notice'>You remove the fire alarm assembly from the wall.</span>")
					var/obj/item/wallframe/firealarm/frame = new /obj/item/wallframe/firealarm()
					frame.loc = user.loc
					playsound(src.loc, W.usesound, 50, 1)
					qdel(src)
					return
	return ..()


/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage received
		if(obj_integrity > 0 && !(stat & BROKEN) && buildstage != 0)
			if(prob(33))
				alarm()

/obj/machinery/firealarm/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT) && buildstage != 0) //can't break the electronics if there isn't any inside.
		stat |= BROKEN
		update_icon()

/obj/machinery/firealarm/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 1)
		if(!(stat & BROKEN))
			var/obj/item/I = new /obj/item/weapon/electronics/firealarm(loc)
			if(!disassembled)
				I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)


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
	if(ishuman(user) || user.has_unlimited_silicon_privilege)
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
