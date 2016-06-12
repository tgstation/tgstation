/obj/item/weapon/electronics/firealarm
	name = "fire alarm electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""

/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	var/detecting = 1
	var/buildstage = 2 // 2 = complete, 1 = no wires, 0 = circuit gone
	var/health = 50

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
	src.overlays = list()

	var/area/A = src.loc
	A = A.loc

	if(panel_open)
		icon_state = "fire_b[buildstage]"
		return
	else
		icon_state = "fire0"

		if(stat & NOPOWER)
			return
		if(stat & BROKEN)
			icon_state = "firex"
			return

		overlays += "overlay_[security_level]"
		if(detecting)
			overlays += "overlay_[A.fire ? "fire" : "clear"]"
		else
			overlays += "overlay_fire"

/obj/machinery/firealarm/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50 / severity))
		alarm()

/obj/machinery/firealarm/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of the [src]!</span>",
								"<span class='notice'>You emag [src], disabling its thermal sensors.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(!emagged && detecting && !stat && temperature > T0C + 200)
		alarm()

/obj/machinery/firealarm/proc/alarm()
	if(!is_operational())
		return
	var/area/A = get_area(src)
	A.firealert(src)
	playsound(src.loc, 'sound/ambience/signal.ogg', 75, 0)

/obj/machinery/firealarm/proc/alarm_in(time)
	addtimer(src, "alarm", time, FALSE)

/obj/machinery/firealarm/proc/reset()
	if(!is_operational())
		return
	var/area/A = get_area(src)
	A.firereset(src)

/obj/machinery/firealarm/proc/reset_in(time)
	addtimer(src, "reset", time, FALSE)

/obj/machinery/firealarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "firealarm", name, 300, 150, master_ui, state)
		ui.open()

/obj/machinery/firealarm/ui_data(mob/user)
	var/list/data = list()
	data["emagged"] = emagged
	data["seclevel"] = get_security_level()

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
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		panel_open = !panel_open
		user << "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>"
		update_icon()
		return

	if(panel_open)
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

/obj/machinery/firealarm/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		else
			return
	if(!(stat & BROKEN) && buildstage != 0) //can't break the electronics if there isn't any inside.
		health -= damage
		if(health <= 0)
			stat |= BROKEN
			update_icon()
		else if(prob(33))
			alarm()
