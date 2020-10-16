/obj/machinery/airalarm
	name = "air alarm"
	desc = "A machine that monitors atmosphere levels. Goes off if the area is dangerous."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = AREA_USAGE_ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS)
	max_integrity = 250
	integrity_failure = 0.33
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 90, ACID = 30)
	resistance_flags = FIRE_PROOF

	var/locked = TRUE
	var/aidisabled = FALSE
	var/shorted = FALSE
	var/buildstage = AALARM_BUILD_STAGE_COMPLETE

	/// Path to the /datum/airalarm_control used if we're the first created
	var/initial_control_type = /datum/airalarm_control
	var/datum/airalarm_control/control

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	wires = new /datum/wires/airalarm(src)
	if(ndir)
		setDir(ndir)

	if(nbuild)
		buildstage = AALARM_BUILD_STAGE_NO_CIRCUIT
		panel_open = TRUE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir == 1 ? -24 : 24) : 0

	if(name == initial(name))
		name = "[get_area_name(src)] Air Alarm"

	update_icon()

	register_with_area_control()

	RegisterSignal(src, COMSIG_AREA_ENTERED, .proc/on_area_change)

/obj/machinery/airalarm/Destroy()
	control?.unregister_alarm(src)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/airalarm/proc/on_area_change()
	control?.unregister_alarm(src)
	register_with_area_control()

/obj/machinery/airalarm/proc/register_with_area_control()
	if(buildstage != AALARM_BUILD_STAGE_COMPLETE)
		return

	var/area/current_area = get_area(src)
	current_area.ensure_air_control(initial_control_type)
	current_area.air_control.register_alarm(src)

/obj/machinery/airalarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(AALARM_BUILD_STAGE_NO_CIRCUIT)
			. += "<span class='notice'>It is missing air alarm electronics.</span>"
		if(AALARM_BUILD_STAGE_NO_WIRES)
			. += "<span class='notice'>It is missing wiring.</span>"
		if(AALARM_BUILD_STAGE_COMPLETE)
			. += "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"] the interface.</span>"

/obj/machinery/airalarm/ui_status(mob/user)
	if(user.has_unlimited_silicon_privilege && aidisabled)
		to_chat(user, "AI control has been disabled.")
	else if(!shorted)
		return ..()
	return UI_CLOSE

/obj/machinery/airalarm/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirAlarm", name)
		ui.open()

/obj/machinery/airalarm/proc/get_environment_data(datum/gas_mixture/environment)
	. = list()
	if(!environment)
		return
	var/pressure = environment.return_pressure()
	var/list/TLV = control.breathable_gas_ranges
	var/datum/gas_range/cur_tlv = TLV[AALARM_PRESSURE]
	. += list(list(
							"name" = "Pressure",
							"value" = pressure,
							"unit" = "kPa",
							"danger_level" = cur_tlv.get_danger_level(pressure)
	))
	var/temperature = environment.temperature
	cur_tlv = TLV[AALARM_TEMPERATURE]
	. += list(list(
							"name" = "Temperature",
							"value" = temperature,
							"unit" = "K ([round(temperature - T0C, 0.1)]C)",
							"danger_level" = cur_tlv.get_danger_level(temperature)
	))
	var/total_moles = environment.total_moles()
	var/partial_pressure = R_IDEAL_GAS_EQUATION * environment.temperature / environment.volume
	for(var/gas_id in environment.gases)
		if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
			continue
		cur_tlv = TLV[gas_id]
		. += list(list(
			"name" = environment.gases[gas_id][GAS_META][META_GAS_NAME],
			"value" = environment.gases[gas_id][MOLES] / total_moles * 100,
			"unit" = "%",
			"danger_level" = cur_tlv.get_danger_level(environment.gases[gas_id][MOLES] * partial_pressure)
		))

/obj/machinery/airalarm/ui_data(mob/user)
	var/data = list(
		"locked" = locked,
		"siliconUser" = user.has_unlimited_silicon_privilege,
		"emagged" = (obj_flags & EMAGGED ? 1 : 0),
		"danger_level" = control.danger_level,
	)

	data["atmos_alarm"] = control.danger_level

	// fire control is still part of the area (for now)
	data["fire_alarm"] = control.area.fire

	data["environment_data"] = get_environment_data(control.return_air())

	if(!locked || user.has_unlimited_silicon_privilege)
		data["vents"] = list()
		for(var/I in control.vents)
			var/obj/machinery/atmospherics/components/unary/vent_pump/vent = I
			data["vents"] += list(list(
					"id_tag"	= vent.id_tag,
					"long_name" = vent.name,
					"power"		= vent.on,
					"checks"	= vent.pressure_checks,
					"excheck"	= vent.pressure_checks & 1,
					"incheck"	= vent.pressure_checks & 2,
					"direction"	= vent.pump_direction,
					"external"	= vent.external_pressure_bound,
					"internal"	= vent.internal_pressure_bound,
					"extdefault"= (vent.external_pressure_bound == ONE_ATMOSPHERE),
					"intdefault"= (vent.internal_pressure_bound == 0)
				))
		data["scrubbers"] = list()
		for(var/I in control.scrubbers)
			var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = I
			data["scrubbers"] += list(list(
					"id_tag"				= scrubber.id_tag,
					"long_name" 			= scrubber.name,
					"power"					= scrubber.on,
					"scrubbing"				= scrubber.scrubbing,
					"widenet"				= scrubber.widenet,
					"filter_types"			= scrubber.filter_types
				))
		data["sensors"] = list()
		for(var/I in control.sensors)
			var/obj/machinery/air_sensor/sensor = I
			data["sensors"] += list(list(
				"long_name" = sensor.name,
				"environment_data" = get_environment_data(sensor.last_read)
			))
		data["mode"] = control.mode
		data["modes"] = list()
		data["modes"] += list(list("name" = "Filtering - Scrubs out contaminants", 				"mode" = AALARM_MODE_SCRUBBING,		"selected" = control.mode == AALARM_MODE_SCRUBBING, 	"danger" = 0))
		data["modes"] += list(list("name" = "Contaminated - Scrubs out ALL contaminants quickly","mode" = AALARM_MODE_CONTAMINATED,	"selected" = control.mode == AALARM_MODE_CONTAMINATED,	"danger" = 0))
		data["modes"] += list(list("name" = "Draught - Siphons out air while replacing",		"mode" = AALARM_MODE_VENTING,		"selected" = control.mode == AALARM_MODE_VENTING,		"danger" = 0))
		data["modes"] += list(list("name" = "Refill - Triple vent output",						"mode" = AALARM_MODE_REFILL,		"selected" = control.mode == AALARM_MODE_REFILL,		"danger" = 1))
		data["modes"] += list(list("name" = "Cycle - Siphons air before replacing", 			"mode" = AALARM_MODE_REPLACEMENT,	"selected" = control.mode == AALARM_MODE_REPLACEMENT, 	"danger" = 1))
		data["modes"] += list(list("name" = "Siphon - Siphons air out of the room", 			"mode" = AALARM_MODE_SIPHON,		"selected" = control.mode == AALARM_MODE_SIPHON, 		"danger" = 1))
		data["modes"] += list(list("name" = "Panic Siphon - Siphons air out of the room quickly","mode" = AALARM_MODE_PANIC,		"selected" = control.mode == AALARM_MODE_PANIC, 		"danger" = 1))
		data["modes"] += list(list("name" = "Off - Shuts off vents and scrubbers", 				"mode" = AALARM_MODE_OFF,			"selected" = control.mode == AALARM_MODE_OFF, 			"danger" = 0))
		if(obj_flags & EMAGGED)
			data["modes"] += list(list("name" = "Flood - Shuts off scrubbers and opens vents",	"mode" = AALARM_MODE_FLOOD,			"selected" = control.mode == AALARM_MODE_FLOOD, 		"danger" = 1))

		var/datum/gas_range/selected
		var/list/thresholds = list()

		var/list/TLV = control.breathable_gas_ranges
		selected = TLV[AALARM_PRESSURE]
		thresholds += list(list("name" = "Pressure", "settings" = list()))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min_danger", "selected" = selected.min_danger))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "min_warning", "selected" = selected.min_warning))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max_warning", "selected" = selected.max_warning))
		thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = "max_danger", "selected" = selected.max_danger))

		selected = TLV[AALARM_TEMPERATURE]
		thresholds += list(list("name" = "Temperature", "settings" = list()))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min_danger", "selected" = selected.min_danger))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "min_warning", "selected" = selected.min_warning))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max_warning", "selected" = selected.max_warning))
		thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = "max_danger", "selected" = selected.max_danger))

		for(var/gas_id in GLOB.meta_gas_info)
			if(!(gas_id in TLV)) // We're not interested in this gas, it seems.
				continue
			selected = TLV[gas_id]
			thresholds += list(list("name" = GLOB.meta_gas_info[gas_id][META_GAS_NAME], "settings" = list()))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "min_danger", "selected" = selected.min_danger))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "min_warning", "selected" = selected.min_warning))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "max_warning", "selected" = selected.max_warning))
			thresholds[thresholds.len]["settings"] += list(list("env" = gas_id, "val" = "max_danger", "selected" = selected.max_danger))

		data["thresholds"] = thresholds
	return data

/obj/machinery/airalarm/ui_act(action, params)
	. = ..()

	if(. || buildstage != 2)
		return
	if((locked && !usr.has_unlimited_silicon_privilege) || (usr.has_unlimited_silicon_privilege && aidisabled))
		return
	var/device_id = params["id_tag"]
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege && !wires.is_cut(WIRE_IDSCAN))
				locked = !locked
				. = TRUE
		if("power", "toggle_filter", "widenet", "scrubbing", "direction")
			control.send_signal(device_id, list("[action]" = params["val"]), usr)
			. = TRUE
		if("excheck")
			control.send_signal(device_id, list("checks" = text2num(params["val"])^1), usr)
			. = TRUE
		if("incheck")
			control.send_signal(device_id, list("checks" = text2num(params["val"])^2), usr)
			. = TRUE
		if("set_external_pressure", "set_internal_pressure")
			var/target = params["value"]
			if(!isnull(target))
				control.send_signal(device_id, list("[action]" = target), usr)
				. = TRUE
		if("reset_external_pressure")
			control.send_signal(device_id, list("reset_external_pressure"), usr)
			. = TRUE
		if("reset_internal_pressure")
			control.send_signal(device_id, list("reset_internal_pressure"), usr)
			. = TRUE
		if("threshold")
			var/env = params["env"]
			if(text2path(env))
				env = text2path(env)

			var/name = params["var"]
			var/datum/gas_range/tlv = control.breathable_gas_ranges[env]
			if(isnull(tlv))
				return
			var/value = input("New [name] for [env]:", name, tlv.vars[name]) as num|null
			if(!isnull(value) && !..())
				if(value < 0)
					tlv.vars[name] = -1
				else
					tlv.vars[name] = round(value, 0.01)
				investigate_log(" treshold value for [env]:[name] was set to [value] by [key_name(usr)]",INVESTIGATE_ATMOS)
				. = TRUE
		if("mode")
			control.apply_mode(text2num(params["mode"]), usr)
			investigate_log("was turned to [control.get_mode_name()] mode by [key_name(usr)]",INVESTIGATE_ATMOS)
			. = TRUE
		if("alarm")
			control.atmosalert(AALARM_ALERT_SEVERE, src)
			. = TRUE
		if("reset")
			control.atmosalert(AALARM_ALERT_CLEAR, src)
			. = TRUE
	update_icon()


/obj/machinery/airalarm/proc/reset(wire)
	switch(wire)
		if(WIRE_POWER)
			if(!wires.is_cut(WIRE_POWER))
				shorted = FALSE
				update_icon()
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE


/obj/machinery/airalarm/proc/shock(mob/user, prb)
	if((machine_stat & (NOPOWER)))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	do_sparks(5, TRUE, src)
	if (electrocute_mob(user, get_area(src), src, 1, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/airalarm/update_icon_state()
	if(panel_open)
		switch(buildstage)
			if(AALARM_BUILD_STAGE_COMPLETE)
				icon_state = "alarmx"
			if(AALARM_BUILD_STAGE_NO_WIRES)
				icon_state = "alarm_b2"
			if(AALARM_BUILD_STAGE_NO_CIRCUIT)
				icon_state = "alarm_b1"
		return

	if((machine_stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	switch(control?.danger_level)
		if(AALARM_ALERT_CLEAR)
			icon_state = "alarm0"
		if(AALARM_ALERT_MINOR)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if(AALARM_ALERT_SEVERE)
			icon_state = "alarm1"

/obj/machinery/airalarm/process()
	if(!is_operational|| shorted)
		return

	var/turf/location = get_turf(src)
	if(!location)
		return

	control.process_devices(src)

/obj/machinery/airalarm/attackby(obj/item/W, mob/user, params)
	switch(buildstage)
		if(AALARM_BUILD_STAGE_COMPLETE)
			if(W.tool_behaviour == TOOL_WIRECUTTER && panel_open && wires.is_all_cut())
				W.play_tool_sound(src)
				to_chat(user, "<span class='notice'>You cut the final wires.</span>")
				new /obj/item/stack/cable_coil(drop_location(), 5)
				buildstage = AALARM_BUILD_STAGE_NO_WIRES
				control?.unregister_alarm(src)
				update_icon()
				return
			else if(W.tool_behaviour == TOOL_SCREWDRIVER)  // Opening that Air Alarm up.
				W.play_tool_sound(src)
				panel_open = !panel_open
				to_chat(user, "<span class='notice'>The wires have been [panel_open ? "exposed" : "unexposed"].</span>")
				update_icon()
				return
			else if(W.GetID())// trying to unlock the interface with an ID card
				togglelock(user)
				return
			else if(panel_open && is_wire_tool(W))
				wires.interact(user)
				return
		if(AALARM_BUILD_STAGE_NO_WIRES)
			if(W.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("<span class='notice'>[user.name] removes the electronics from [src.name].</span>", \
									"<span class='notice'>You start prying out the circuit...</span>")
				W.play_tool_sound(src)
				if (W.use_tool(src, user, 20))
					if (buildstage == AALARM_BUILD_STAGE_NO_WIRES)
						to_chat(user, "<span class='notice'>You remove the air alarm electronics.</span>")
						new /obj/item/electronics/airalarm(drop_location())
						playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
						buildstage = AALARM_BUILD_STAGE_NO_CIRCUIT
						update_icon()
				return

			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/cable = W
				if(cable.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the air alarm!</span>")
					return
				user.visible_message("<span class='notice'>[user.name] wires the air alarm.</span>", \
									"<span class='notice'>You start wiring the air alarm...</span>")
				if (do_after(user, 20, target = src))
					if (cable.get_amount() >= 5 && buildstage == 1)
						cable.use(5)
						to_chat(user, "<span class='notice'>You wire the air alarm.</span>")
						wires.repair()
						aidisabled = FALSE
						locked = FALSE
						shorted = FALSE
						buildstage = AALARM_BUILD_STAGE_COMPLETE
						register_with_area_control()
						update_icon()
				return
		if(AALARM_BUILD_STAGE_NO_CIRCUIT)
			if(istype(W, /obj/item/electronics/airalarm))
				if(user.temporarilyRemoveItemFromInventory(W))
					to_chat(user, "<span class='notice'>You insert the circuit.</span>")
					buildstage = AALARM_BUILD_STAGE_NO_WIRES
					update_icon()
					qdel(W)
				return

			if(istype(W, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = W
				if(!P.adapt_circuit(user, 25))
					return
				user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
				"<span class='notice'>You adapt an air alarm circuit and slot it into the assembly.</span>")
				buildstage = AALARM_BUILD_STAGE_NO_WIRES
				update_icon()
				return

			if(W.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>You detach \the [src] from the wall.</span>")
				W.play_tool_sound(src)
				new /obj/item/wallframe/airalarm(user.drop_location())
				qdel(src)
				return

	return ..()

/obj/machinery/airalarm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if((buildstage == AALARM_BUILD_STAGE_NO_CIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/machinery/airalarm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt an air alarm circuit and slot it into the assembly.</span>")
			buildstage = AALARM_BUILD_STAGE_NO_WIRES
			update_icon()
			return TRUE
	return FALSE

/obj/machinery/airalarm/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)) || !isturf(loc))
		return
	else
		togglelock(user)

/obj/machinery/airalarm/proc/togglelock(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>It does nothing!</span>")
	else
		if(src.allowed(usr) && !wires.is_cut(WIRE_IDSCAN))
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the air alarm interface.</span>")
			updateUsrDialog()
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
	return

/obj/machinery/airalarm/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	visible_message("<span class='warning'>Sparks fly out of [src]!</span>", "<span class='notice'>You emag [src], disabling its safeties.</span>")
	do_sparks(5, TRUE, src)

/obj/machinery/airalarm/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(drop_location(), 2)
		var/obj/item/I = new /obj/item/electronics/airalarm(drop_location())
		if(!disassembled)
			I.obj_integrity = I.max_integrity * 0.5
		new /obj/item/stack/cable_coil(drop_location(), 3)
	qdel(src)

/obj/machinery/airalarm/server
	initial_control_type = /datum/airalarm_control/server

/obj/machinery/airalarm/kitchen_cold_room
	initial_control_type = /datum/airalarm_control/kitchen_cold_room

/obj/machinery/airalarm/unlocked
	locked = FALSE

/obj/machinery/airalarm/engine
	name = "engine air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE)

/obj/machinery/airalarm/mixingchamber
	name = "chamber air alarm"
	locked = FALSE
	req_access = null
	req_one_access = list(ACCESS_ATMOSPHERICS, ACCESS_TOXINS)

/obj/machinery/airalarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null
	req_one_access = null

/obj/machinery/airalarm/syndicate //general syndicate access
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/airalarm/away //general away mission access
	req_access = list(ACCESS_AWAY_GENERAL)

/obj/machinery/airalarm/directional/north //Pixel offsets get overwritten on New()
	dir = SOUTH
	pixel_y = 24

/obj/machinery/airalarm/directional/south
	dir = NORTH
	pixel_y = -24

/obj/machinery/airalarm/directional/east
	dir = WEST
	pixel_x = 24

/obj/machinery/airalarm/directional/west
	dir = EAST
	pixel_x = -24
