#define THERMOMACHINE_SAFE_TEMPERATURE 500000
#define THERMOMACHINE_POWER_CONVERSION 0.01

/obj/machinery/atmospherics/components/binary/thermomachine
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "thermo_base"

	name = "Temperature control unit"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/thermomachine

	hide = TRUE

	move_resist = MOVE_RESIST_DEFAULT
	vent_movement = NONE
	pipe_flags = PIPING_ONE_PER_TURF

	greyscale_config = /datum/greyscale_config/thermomachine
	greyscale_colors = COLOR_VIBRANT_LIME

	set_dir_on_move = FALSE

	var/min_temperature = T20C //actual temperature will be defined by RefreshParts() and by the cooling var
	var/max_temperature = T20C //actual temperature will be defined by RefreshParts() and by the cooling var
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.
	var/cooling = TRUE
	var/base_heating = 140
	var/base_cooling = 170
	var/use_enviroment_heat = FALSE
	var/skipping_work = FALSE
	var/safeties = TRUE
	var/lastwarning
	var/color_index = 1

	// Efficiency dictates how much we throttle the heat exchange process.
	var/efficiency = 1
	///Efficiency minimum amount, min 0.25, max 1 (works best on higher laser tiers)
	var/parts_efficiency = 1

/obj/machinery/atmospherics/components/binary/thermomachine/Initialize(mapload)
	. = ..()
	RefreshParts()
	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/is_connectable()
	if(!anchored || panel_open)
		return FALSE
	. = ..()

/obj/machinery/atmospherics/components/binary/thermomachine/on_construction(obj_color, set_layer)
	var/obj/item/circuitboard/machine/thermomachine/board = circuit
	if(board)
		piping_layer = board.pipe_layer
		set_layer = piping_layer

	if(check_pipe_on_turf())
		deconstruct(TRUE)
		return
	return..()

/obj/machinery/atmospherics/components/binary/thermomachine/RefreshParts()
	var/calculated_bin_rating
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		calculated_bin_rating += bin.rating
	heat_capacity = 7500 * ((calculated_bin_rating - 1) ** 2)
	min_temperature = T20C
	max_temperature = T20C
	var/calculated_laser_rating
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		calculated_laser_rating += laser.rating
	min_temperature = max(T0C - (base_cooling + calculated_laser_rating * 15), TCMB) //73.15K with T1 stock parts
	max_temperature = T20C + (base_heating * calculated_laser_rating) //573.15K with T1 stock parts
	parts_efficiency = min(calculated_laser_rating * 0.125, 1)

/obj/machinery/atmospherics/components/binary/thermomachine/update_icon_state()
	switch(target_temperature)
		if(BODYTEMP_HEAT_WARNING_3 to INFINITY)
			greyscale_colors = COLOR_RED
		if(BODYTEMP_HEAT_WARNING_2 to BODYTEMP_HEAT_WARNING_3)
			greyscale_colors = COLOR_ORANGE
		if(BODYTEMP_HEAT_WARNING_1 to BODYTEMP_HEAT_WARNING_2)
			greyscale_colors = COLOR_YELLOW
		if(BODYTEMP_COLD_WARNING_1 to BODYTEMP_HEAT_WARNING_1)
			greyscale_colors = COLOR_VIBRANT_LIME
		if(BODYTEMP_COLD_WARNING_2 to BODYTEMP_COLD_WARNING_1)
			greyscale_colors = COLOR_CYAN
		if(BODYTEMP_COLD_WARNING_3 to BODYTEMP_COLD_WARNING_2)
			greyscale_colors = COLOR_BLUE
		else
			greyscale_colors = COLOR_VIOLET

	set_greyscale(colors=greyscale_colors)

	if(panel_open)
		icon_state = "thermo-open"
		return ..()
	if(on && is_operational)
		if(skipping_work)
			icon_state = "thermo_1_blinking"
		else
			icon_state = "thermo_1"
		return ..()
	icon_state = "thermo_base"
	return ..()

/obj/machinery/atmospherics/components/binary/thermomachine/update_overlays()
	. = ..()
	if(!initial(icon))
		return
	var/mutable_appearance/thermo_overlay = new(initial(icon))
	. += get_pipe_image(thermo_overlay, "pipe", dir, COLOR_LIME, piping_layer)
	. += get_pipe_image(thermo_overlay, "pipe", turn(dir, 180), COLOR_MOSTLY_PURE_RED, piping_layer)

/obj/machinery/atmospherics/components/binary/thermomachine/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_notice("Something seems wrong with [src]'s thermal safeties.")
	. += span_notice("With the panel open:")
	. += span_notice("-use a wrench with left-click to rotate [src] and right-click to unanchor it.")
	. += span_notice("-use a multitool with left-click to change the piping layer and right-click to change the piping color.")
	. += span_notice("The thermostat is set to [target_temperature]K ([(T0C-target_temperature)*-1]C).")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("Heat capacity at <b>[heat_capacity] Joules per Kelvin</b>.")
		. += span_notice("Temperature range <b>[min_temperature]K - [max_temperature]K ([(T0C-min_temperature)*-1]C - [(T0C-max_temperature)*-1]C)</b>.")

/obj/machinery/atmospherics/components/binary/thermomachine/AltClick(mob/living/user)
	if(!can_interact(user))
		return
	target_temperature = T20C
	investigate_log("was set to [target_temperature] K by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, "temperature reset to [target_temperature] K")

/** Performs heat calculation for the freezer. The full equation for this whole process is:
 * T3 = (C1*T1  +  (C1*C2)/(C1+C2)*(T2-T1)*E) / C1.
 * T4 = (C1*T1  -  (C1*C2)/(C1+C2)*(T2-T1)*E  +  M) / C1.
 * C1 is main port heat capacity, T1 is the temp.
 * C2 and T2 is for the heat capacity of the freezer and temperature that we desire respectively.
 * T3 is the temperature we get, T4 is the exchange target (heat reservoir).
 * M is the motor heat.
 * E is the efficiency variable. At E=1 and M=0 it works out to be ((C1*T1)+(C2*T2))/(C1+C2).
 */
/obj/machinery/atmospherics/components/binary/thermomachine/process_atmos()
	if(!on)
		return

	var/turf/local_turf = get_turf(src)

	if(!is_operational || !local_turf)
		on = FALSE
		update_appearance()
		return

	// The gas we want to cool/heat
	var/datum/gas_mixture/main_port = airs[2]
	var/datum/gas_mixture/exchange_target = airs[1]

	// The difference between target and what we need to heat/cool. Positive if heating, negative if cooling.
	var/temperature_target_delta = target_temperature - main_port.temperature

	// This variable holds the (C1*C2)/(C1+C2)*(T2-T1) part of the equation.
	var/heat_amount = temperature_target_delta * (main_port.heat_capacity() * heat_capacity / (main_port.heat_capacity() + heat_capacity))

	// Motor heat is the heat added to both ports of the thermomachine at every tick.
	var/motor_heat = 5000
	if(abs(temperature_target_delta) < 5) //Allow the machine to work more finely on lower temperature differences.
		motor_heat = 0

	// Automatic Switching. Longer if check to prevent unecessary update_appearances.
	if ((cooling && temperature_target_delta > 0) || (!cooling && temperature_target_delta < 0))
		cooling = temperature_target_delta <= 0 // Thermomachines that reached the target will default to cooling.
		update_appearance()

	skipping_work = FALSE

	if (main_port.total_moles() < 0.01)
		skipping_work = TRUE
		return

	// Efficiency should be a proc level variable, but we need it for the ui.
	// This is to reset the value when we are heating.
	efficiency = 1

	var/mole_efficiency = 1
	var/mole_eff_main_port = 1
	var/mole_eff_thermal_port = 1
	if(cooling)
		// Exchange target is the thing we are paired with, be it enviroment or the red port.
		if(use_enviroment_heat)
			exchange_target = local_turf.return_air()
		else
			exchange_target = airs[1]

		if(exchange_target.total_moles() < 5)
			mole_eff_thermal_port = 0.1
		else
			mole_eff_thermal_port = max(1 - (1 / (exchange_target.total_moles() + 1)) * 5, 0.1)

	if(main_port.total_moles() < 5)
		mole_eff_main_port = 0.1
	else
		mole_eff_main_port = max(1 - (1 / (main_port.total_moles() + 1)) * 5, 0.1)

	mole_efficiency = min(mole_eff_main_port, mole_eff_thermal_port)

	if(cooling)
		if (exchange_target.total_moles() < 0.01)
			skipping_work = TRUE
			return

		// The hotter the heat reservoir is, the larger the malus.
		var/temperature_exchange_delta = exchange_target.temperature - main_port.temperature
		// Log 1 is already 0, going any lower will result in a negative number.
		efficiency = clamp(1 - log(10, max(1, temperature_exchange_delta)) * 0.08, 0.65, 1)
		// We take an extra efficiency malus for enviroments where the mol is too low.
		// Cases of log(0) will be caught by the early return above.
		if (use_enviroment_heat)
			efficiency *= clamp(log(1.55, exchange_target.total_moles()) * 0.15, 0.65, 1)

		efficiency *= mole_efficiency
		efficiency = max(efficiency, parts_efficiency)

		if (exchange_target.temperature > THERMOMACHINE_SAFE_TEMPERATURE && safeties)
			on = FALSE
			visible_message(span_warning("The heat reservoir has reached critical levels, shutting down..."))
			update_appearance()
			return

		else if(exchange_target.temperature > THERMOMACHINE_SAFE_TEMPERATURE && !safeties)
			if((REALTIMEOFDAY - lastwarning) / 5 >= WARNING_DELAY)
				lastwarning = REALTIMEOFDAY
				visible_message(span_warning("The heat reservoir has reached critical levels!"))
				if(check_explosion(exchange_target.temperature))
					explode()
					return PROCESS_KILL //We're dying anyway, so let's stop processing

		exchange_target.temperature = max((THERMAL_ENERGY(exchange_target) - (heat_amount * efficiency) + motor_heat) / exchange_target.heat_capacity(), TCMB)

	if(!cooling)
		efficiency *= mole_efficiency
		efficiency = max(efficiency, parts_efficiency)

	main_port.temperature = max((THERMAL_ENERGY(main_port) + (heat_amount * efficiency)) / main_port.heat_capacity(), TCMB)

	heat_amount = min(abs(heat_amount), 1e8) * THERMOMACHINE_POWER_CONVERSION
	var/power_usage = 0
	var/power_efficiency = max(efficiency, 0.4)
	if(abs(temperature_target_delta)  > 1)
		power_usage = (heat_amount * 0.05 + idle_power_usage) ** (1.05 - (5e7 * power_efficiency) / (max(5e7, heat_amount)))
	else
		power_usage = idle_power_usage

	use_power(power_usage)
	update_parents()

/obj/machinery/atmospherics/components/binary/thermomachine/screwdriver_act(mob/living/user, obj/item/tool)
	if(on)
		to_chat("You can't open [src] while it's on!")
		return FALSE
	if(!anchored)
		to_chat(user, span_notice("Anchor [src] first!"))
		return FALSE
	if(default_deconstruction_screwdriver(user, "thermo-open", "thermo-0", tool))
		change_pipe_connection(panel_open)
		return TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/wrench_act(mob/living/user, obj/item/tool)
	return default_change_direction_wrench(user, tool)

/obj/machinery/atmospherics/components/binary/thermomachine/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/atmospherics/components/binary/thermomachine/multitool_act(mob/living/user, obj/item/multitool/multitool)
	piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
	to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	set_init_directions()
	update_appearance()
	return TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/proc/change_pipe_connection(disconnect)
	if(disconnect)
		disconnect_pipes()
		return
	connect_pipes()

/obj/machinery/atmospherics/components/binary/thermomachine/proc/connect_pipes()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]
	atmos_init()
	node1 = nodes[1]
	if(node1)
		node1.atmos_init()
		node1.add_member(src)
	node2 = nodes[2]
	if(node2)
		node2.atmos_init()
		node2.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/binary/thermomachine/proc/disconnect_pipes()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null
	if(node2)
		if(src in node2.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node2.disconnect(src)
		nodes[2] = null
	if(parents[1])
		nullify_pipenet(parents[1])
	if(parents[2])
		nullify_pipenet(parents[2])

/obj/machinery/atmospherics/components/binary/thermomachine/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(panel_open && !check_pipe_on_turf())
		if(default_unfasten_wrench(user, tool))
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(panel_open)
		color_index = (color_index >= GLOB.pipe_paint_colors.len) ? (color_index = 1) : (color_index = 1 + color_index)
		pipe_color = GLOB.pipe_paint_colors[GLOB.pipe_paint_colors[color_index]]
		visible_message("<span class='notice'>You set [src] pipe color to [GLOB.pipe_color_name[pipe_color]].")
		update_appearance()
		return TRUE
	return FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/proc/check_pipe_on_turf()
	for(var/obj/machinery/atmospherics/device in get_turf(src))
		if(device == src)
			continue
		if(device.piping_layer == piping_layer)
			visible_message(span_warning("A pipe is hogging the ports, remove the obstruction or change the machine piping layer."))
			return TRUE
	return FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(!istype(multitool))
		return
	if(panel_open && !anchored)
		piping_layer = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
		to_chat(user, span_notice("You change the circuitboard to layer [piping_layer]."))
		update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/emag_act(mob/user)
	. = ..()
	if(!(obj_flags & EMAGGED))
		if(!do_after(user, 1 SECONDS, src))
			return
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 0, src)
		sparks.attach(src)
		sparks.start()
		obj_flags |= EMAGGED
		user.visible_message(span_warning("You emag [src], overwriting thermal safety restrictions."))
		log_game("[key_name(user)] emagged [src] at [AREACOORD(src)], overwriting thermal safety restrictions.")

/obj/machinery/atmospherics/components/binary/thermomachine/emp_act()
	. = ..()
	if(!(obj_flags & EMAGGED))
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(5, 0, src)
		sparks.attach(src)
		sparks.start()
		obj_flags |= EMAGGED
		safeties = FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/proc/check_explosion(temperature)
	if(temperature < THERMOMACHINE_SAFE_TEMPERATURE + 2000)
		return FALSE
	if(prob(log(6, temperature) * 10)) //75% at 500000, 100% at 1e8
		return TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/proc/explode()
	explosion(loc, 0, 0, 3, 3, TRUE, explosion_cause = src)
	var/datum/gas_mixture/main_port = airs[2]
	var/datum/gas_mixture/exchange_target = airs[1]
	if(main_port)
		loc.assume_air(main_port.remove_ratio(1))
	if(exchange_target)
		loc.assume_air(exchange_target.remove_ratio(1))
	qdel(src)

/obj/machinery/atmospherics/components/binary/thermomachine/ui_status(mob/user)
	if(interactive)
		return ..()
	return UI_CLOSE

/obj/machinery/atmospherics/components/binary/thermomachine/ui_interact(mob/user, datum/tgui/ui)
	if(panel_open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermoMachine", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["cooling"] = cooling

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	var/datum/gas_mixture/main_port = airs[2]
	data["temperature"] = main_port.temperature
	data["pressure"] = main_port.return_pressure()
	data["efficiency"] = efficiency

	data["use_env_heat"] = use_enviroment_heat
	data["skipping_work"] = skipping_work
	data["safeties"] = safeties
	var/hacked = (obj_flags & EMAGGED) ? TRUE : FALSE
	data["hacked"] = hacked
	return data

/obj/machinery/atmospherics/components/binary/thermomachine/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			update_use_power(on ? ACTIVE_POWER_USE : IDLE_POWER_USE)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("cooling")
			cooling = !cooling
			investigate_log("was changed to [cooling ? "cooling" : "heating"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature]-[max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target))
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)
		if("use_env_heat")
			use_enviroment_heat = !use_enviroment_heat
			. = TRUE
		if("safeties")
			safeties = !safeties
			investigate_log("[key_name(usr)] turned off the [src] safeties", INVESTIGATE_ATMOS)
			. = TRUE

	update_appearance()

/obj/machinery/atmospherics/components/binary/thermomachine/CtrlClick(mob/living/user)
	if(!panel_open)
		if(!can_interact(user))
			return
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_appearance()
		return
	. = ..()

/obj/machinery/atmospherics/components/binary/thermomachine/freezer
	cooling = TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on
	on = TRUE
	icon_state = "thermo_base_1"

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on/Initialize(mapload)
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on/coldroom
	name = "Cold room temperature control unit"
	icon_state = "thermo_base_1"
	greyscale_colors = COLOR_CYAN
	cooling = TRUE

/obj/machinery/atmospherics/components/binary/thermomachine/freezer/on/coldroom/Initialize(mapload)
	. = ..()
	target_temperature = COLD_ROOM_TEMP

/obj/machinery/atmospherics/components/binary/thermomachine/heater
	cooling = FALSE

/obj/machinery/atmospherics/components/binary/thermomachine/heater/on
	on = TRUE
	icon_state = "thermo_base_1"

#undef THERMOMACHINE_SAFE_TEMPERATURE
#undef THERMOMACHINE_POWER_CONVERSION
