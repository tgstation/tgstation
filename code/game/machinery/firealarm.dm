#define FIREALARM_COOLDOWN 67 // Chosen fairly arbitrarily, it is the length of the audio in FireAlarm.ogg. The actual track length is 7 seconds 8ms but but the audio stops at 6s 700ms

/obj/item/electronics/firealarm
	name = "fire alarm electronics"
	desc = "A fire alarm circuit. Can handle heat levels up to 40 degrees celsius."

/obj/item/wallframe/firealarm
	name = "fire alarm frame"
	desc = "Used for building fire alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	result_path = /obj/machinery/firealarm

/obj/machinery/firealarm
	name = "fire alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	max_integrity = 250
	integrity_failure = 100
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 30)
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON
	resistance_flags = FIRE_PROOF

	light_power = 0
	light_range = 7
	light_color = "#ff3232"

	var/detecting = 1
	var/buildstage = 2 // 2 = complete, 1 = no wires, 0 = circuit gone
	var/last_alarm = 0
	var/area/myarea = null

/obj/machinery/firealarm/Initialize(mapload, dir, building)
	. = ..()
	if(dir)
		src.setDir(dir)
	if(building)
		buildstage = 0
		panel_open = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
	update_icon()
	myarea = get_area(src)
	LAZYADD(myarea.firealarms, src)

/obj/machinery/firealarm/Destroy()
	LAZYREMOVE(myarea.firealarms, src)
	return ..()

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

		if(is_station_level(z))
			add_overlay("overlay_[GLOB.security_level]")
		else
			add_overlay("overlay_[SEC_LEVEL_GREEN]")

		if(detecting)
			add_overlay("overlay_[A.fire ? "fire" : "clear"]")
		else
			add_overlay("overlay_fire")

/obj/machinery/firealarm/emp_act(severity)
	. = ..()

	if (. & EMP_PROTECT_SELF)
		return

	if(prob(50 / severity))
		alarm()

/obj/machinery/firealarm/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	if(user)
		user.visible_message("<span class='warning'>Sparks fly out of [src]!</span>",
							"<span class='notice'>You emag [src], disabling its thermal sensors.</span>")
	playsound(src, "sparks", 50, 1)

/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if((temperature > T0C + 200 || temperature < BODYTEMP_COLD_DAMAGE_LIMIT) && (last_alarm+FIREALARM_COOLDOWN < world.time) && !(obj_flags & EMAGGED) && detecting && !stat)
		alarm()
	..()

/obj/machinery/firealarm/proc/alarm()
	if(!is_operational() && (last_alarm+FIREALARM_COOLDOWN < world.time))
		return
	last_alarm = world.time
	var/area/A = get_area(src)
	A.firealert(src)
	playsound(src.loc, 'goon/sound/machinery/FireAlarm.ogg', 75)

/obj/machinery/firealarm/proc/reset()
	if(!is_operational())
		return
	var/area/A = get_area(src)
	A.firereset(src)

/obj/machinery/firealarm/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "firealarm", name, 300, 150, master_ui, state)
		ui.open()

/obj/machinery/firealarm/ui_data(mob/user)
	var/list/data = list()
	data["emagged"] = obj_flags & EMAGGED ? 1 : 0

	if(is_station_level(z))
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

	if(istype(W, /obj/item/screwdriver) && buildstage == 2)
		W.play_tool_sound(src)
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>")
		update_icon()
		return

	if(panel_open)

		if(istype(W, /obj/item/weldingtool) && user.a_intent == INTENT_HELP)
			if(obj_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=0))
					return

				to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
				if(W.use_tool(src, user, 40, volume=50))
					obj_integrity = max_integrity
					to_chat(user, "<span class='notice'>You repair [src].</span>")
			else
				to_chat(user, "<span class='warning'>[src] is already in good condition!</span>")
			return

		switch(buildstage)
			if(2)
				if(istype(W, /obj/item/multitool))
					detecting = !detecting
					if (src.detecting)
						user.visible_message("[user] has reconnected [src]'s detecting unit!", "<span class='notice'>You reconnect [src]'s detecting unit.</span>")
					else
						user.visible_message("[user] has disconnected [src]'s detecting unit!", "<span class='notice'>You disconnect [src]'s detecting unit.</span>")
					return

				else if (istype(W, /obj/item/wirecutters))
					buildstage = 1
					W.play_tool_sound(src)
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

				else if(istype(W, /obj/item/crowbar))
					user.visible_message("[user.name] removes the electronics from [src.name].", \
										"<span class='notice'>You start prying out the circuit...</span>")
					if(W.use_tool(src, user, 20, volume=50))
						if(buildstage == 1)
							if(stat & BROKEN)
								to_chat(user, "<span class='notice'>You remove the destroyed circuit.</span>")
								stat &= ~BROKEN
							else
								to_chat(user, "<span class='notice'>You pry out the circuit.</span>")
								new /obj/item/electronics/firealarm(user.loc)
							buildstage = 0
							update_icon()
					return
			if(0)
				if(istype(W, /obj/item/electronics/firealarm))
					to_chat(user, "<span class='notice'>You insert the circuit.</span>")
					qdel(W)
					buildstage = 1
					update_icon()
					return

				else if(istype(W, /obj/item/electroadaptive_pseudocircuit))
					var/obj/item/electroadaptive_pseudocircuit/P = W
					if(!P.adapt_circuit(user, 15))
						return
					user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
					"<span class='notice'>You adapt a fire alarm circuit and slot it into the assembly.</span>")
					buildstage = 1
					update_icon()
					return

				else if(istype(W, /obj/item/wrench))
					user.visible_message("[user] removes the fire alarm assembly from the wall.", \
										 "<span class='notice'>You remove the fire alarm assembly from the wall.</span>")
					var/obj/item/wallframe/firealarm/frame = new /obj/item/wallframe/firealarm()
					frame.forceMove(user.drop_location())
					W.play_tool_sound(src)
					qdel(src)
					return
	return ..()


/obj/machinery/firealarm/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage received
		if(obj_integrity > 0 && !(stat & BROKEN) && buildstage != 0)
			if(prob(33))
				alarm()

/obj/machinery/firealarm/singularity_pull(S, current_size)
	if (current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects, the fire alarm experiences integrity failure
		deconstruct()
	..()

/obj/machinery/firealarm/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1) && buildstage != 0) //can't break the electronics if there isn't any inside.
		LAZYREMOVE(myarea.firealarms, src)
		stat |= BROKEN
		update_icon()

/obj/machinery/firealarm/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 1)
		if(!(stat & BROKEN))
			var/obj/item/I = new /obj/item/electronics/firealarm(loc)
			if(!disassembled)
				I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/firealarm/proc/update_fire_light(fire)
	if(fire == !!light_power)
		return  // do nothing if we're already active
	if(fire)
		set_light(l_power = 0.8)
	else
		set_light(l_power = 0)

/*
 * Return of Party button
 */

/area
	var/party = FALSE

/obj/machinery/firealarm/partyalarm
	name = "\improper PARTY BUTTON"
	desc = "Cuban Pete is in the house!"
	var/static/party_overlay

/obj/machinery/firealarm/partyalarm/reset()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = get_area(src)
	if (!A || !A.party)
		return
	A.party = FALSE
	A.cut_overlay(party_overlay)

/obj/machinery/firealarm/partyalarm/alarm()
	if (stat & (NOPOWER|BROKEN))
		return
	var/area/A = get_area(src)
	if (!A || A.party || A.name == "Space")
		return
	A.party = TRUE
	if (!party_overlay)
		party_overlay = iconstate2appearance('icons/turf/areas.dmi', "party")
	A.add_overlay(party_overlay)

/obj/machinery/firealarm/partyalarm/ui_data(mob/user)
	. = ..()
	var/area/A = get_area(src)
	.["alarm"] = A && A.party
