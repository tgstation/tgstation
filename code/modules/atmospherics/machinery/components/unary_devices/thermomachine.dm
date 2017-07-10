/obj/machinery/atmospherics/components/unary/thermomachine
	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer"
	var/icon_state_on = "cold_on"
	var/icon_state_open = "cold_off"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 80, acid = 30)
	layer = OBJ_LAYER

	var/on = FALSE
	var/min_temperature = 0
	var/max_temperature = 0
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.

/obj/machinery/atmospherics/components/unary/thermomachine/New()
	..()
	initialize_directions = dir
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/thermomachine(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/thermomachine
	name = "Thermomachine (Machine Board)"
	desc = "You can use a screwdriver to switch between heater and freezer."
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/thermomachine/Initialize()
	. = ..()
	if(prob(50))
		name = "Freezer (Machine Board)"
		build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer
	else
		name = "Heater (Machine Board)"
		build_path = /obj/machinery/atmospherics/components/unary/thermomachine/heater

/obj/item/weapon/circuitboard/machine/thermomachine/attackby(obj/item/I, mob/user, params)
	var/obj/item/weapon/circuitboard/machine/freezer = /obj/item/weapon/circuitboard/machine/thermomachine/freezer
	var/obj/item/weapon/circuitboard/machine/heater = /obj/item/weapon/circuitboard/machine/thermomachine/heater
	var/obj/item/weapon/circuitboard/machine/newtype

	if(istype(I, /obj/item/weapon/screwdriver))
		var/new_setting = "Heater"
		playsound(src.loc, I.usesound, 50, 1)
		if(build_path == initial(heater.build_path))
			newtype = freezer
			new_setting = "Freezer"
		else
			newtype = heater
		name = initial(newtype.name)
		build_path = initial(newtype.build_path)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
	else
		return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	var/B
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		B += M.rating
	heat_capacity = 5000 * ((B - 1) ** 2)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon()
	if(panel_open)
		icon_state = icon_state_open
	else if(on && is_operational())
		icon_state = icon_state_on
	else
		icon_state = initial(icon_state)
	return

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos()
	..()
	if(!on || !NODE1)
		return
	var/datum/gas_mixture/air_contents = AIR1

	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = heat_capacity + air_heat_capacity
	var/old_temperature = air_contents.temperature

	if(combined_heat_capacity > 0)
		var/combined_energy = heat_capacity * target_temperature + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

	var/temperature_delta= abs(old_temperature - air_contents.temperature)
	if(temperature_delta > 1)
		active_power_usage = (heat_capacity * temperature_delta) / 10 + idle_power_usage
		update_parents()
	else
		active_power_usage = idle_power_usage
	return 1

/obj/machinery/atmospherics/components/unary/thermomachine/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/thermomachine/attackby(obj/item/I, mob/user, params)
	if(!(on || state_open))
		if(default_deconstruction_screwdriver(user, icon_state_open, initial(icon_state), I))
			return
		if(exchange_parts(user, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(!..())
		return 0
	SetInitDirections()
	var/obj/machinery/atmospherics/node = NODE1
	if(node)
		node.disconnect(src)
		NODE1 = null
	nullifyPipenet(PARENT1)

	atmosinit()
	node = NODE1
	if(node)
		node.atmosinit()
		node.addMember(src)
	build_network()
	return 1

/obj/machinery/atmospherics/components/unary/thermomachine/ui_status(mob/user)
	if(interactive)
		return ..()
	return UI_CLOSE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																	datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "thermomachine", name, 400, 240, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/components/unary/thermomachine/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on

	data["min"] = min_temperature
	data["max"] = max_temperature
	data["target"] = target_temperature
	data["initial"] = initial(target_temperature)

	var/datum/gas_mixture/air1 = AIR1
	data["temperature"] = air1.temperature
	data["pressure"] = air1.return_pressure()
	return data

/obj/machinery/atmospherics/components/unary/thermomachine/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("target")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("Set new target ([min_temperature]-[max_temperature] K):", name, target_temperature) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(adjust)
				target = target_temperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = Clamp(target, min_temperature, max_temperature)
				investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	name = "freezer"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"
	max_temperature = T20C
	min_temperature = 170

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/thermomachine/freezer(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/thermomachine/freezer
	name = "Freezer (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/RefreshParts()
	..()
	var/L
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	min_temperature = max(T0C - (initial(min_temperature) + L * 15), TCMB)

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	name = "heater"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"
	max_temperature = 140
	min_temperature = T20C

/obj/machinery/atmospherics/components/unary/thermomachine/heater/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/thermomachine/heater(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/thermomachine/heater
	name = "Heater (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/heater

/obj/machinery/atmospherics/components/unary/thermomachine/heater/RefreshParts()
	..()
	var/L
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	max_temperature = T20C + (initial(max_temperature) * L)
