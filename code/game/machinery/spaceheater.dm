#define HEATER_MODE_STANDBY	"standby"
#define HEATER_MODE_HEAT	"heat"
#define HEATER_MODE_COOL	"cool"

/obj/machinery/space_heater
	anchored = FALSE
	density = TRUE
	interact_open = TRUE
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater-off"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater/cooler is guaranteed not to set the station on fire."
	max_integrity = 250
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 100, fire = 80, acid = 10)
	var/obj/item/weapon/stock_parts/cell/cell
	var/on = FALSE
	var/mode = HEATER_MODE_STANDBY
	var/setMode = "auto" // Anything other than "heat" or "cool" is considered auto.
	var/targetTemperature = T20C
	var/heatingPower = 40000
	var/efficiency = 20000
	var/temperatureTolerance = 1
	var/settableTemperatureMedian = 30 + T0C
	var/settableTemperatureRange = 30

/obj/machinery/space_heater/get_cell()
	return cell

/obj/machinery/space_heater/New()
	..()
	cell = new(src)
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/space_heater(null)
	B.apply_default_parts(src)
	update_icon()

/obj/item/weapon/circuitboard/machine/space_heater
	name = "Space Heater (Machine Board)"
	build_path = /obj/machinery/space_heater
	origin_tech = "programming=2;engineering=2;plasmatech=2"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/stack/cable_coil = 3)

/obj/machinery/space_heater/on_construction()
	qdel(cell)
	cell = null
	panel_open = TRUE
	update_icon()
	return ..()

/obj/machinery/space_heater/on_deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	return ..()

/obj/machinery/space_heater/examine(mob/user)
	..()
	to_chat(user, "\The [src] is [on ? "on" : "off"], and the hatch is [panel_open ? "open" : "closed"].")
	if(cell)
		to_chat(user, "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%.")
	else
		to_chat(user, "There is no power cell installed.")

/obj/machinery/space_heater/update_icon()
	if(on)
		icon_state = "sheater-[mode]"
	else
		icon_state = "sheater-off"

	cut_overlays()
	if(panel_open)
		add_overlay("sheater-open")

/obj/machinery/space_heater/process()
	if(!on || !is_operational())
		return

	if(cell && cell.charge > 0)
		var/turf/L = loc
		if(!istype(L))
			if(mode != HEATER_MODE_STANDBY)
				mode = HEATER_MODE_STANDBY
				update_icon()
			return

		var/datum/gas_mixture/env = L.return_air()

		var/newMode = HEATER_MODE_STANDBY
		if(setMode != HEATER_MODE_COOL && env.temperature < targetTemperature - temperatureTolerance)
			newMode = HEATER_MODE_HEAT
		else if(setMode != HEATER_MODE_HEAT && env.temperature > targetTemperature + temperatureTolerance)
			newMode = HEATER_MODE_COOL

		if(mode != newMode)
			mode = newMode
			update_icon()

		if(mode == HEATER_MODE_STANDBY)
			return

		var/heat_capacity = env.heat_capacity()
		var/requiredPower = abs(env.temperature - targetTemperature) * heat_capacity
		requiredPower = min(requiredPower, heatingPower)

		if(requiredPower < 1)
			return

		var/deltaTemperature = requiredPower / heat_capacity
		if(mode == HEATER_MODE_COOL)
			deltaTemperature *= -1
		if(deltaTemperature)
			env.temperature += deltaTemperature
			air_update_turf()
		cell.use(requiredPower / efficiency)
	else
		on = FALSE
		update_icon()

/obj/machinery/space_heater/RefreshParts()
	var/laser = 0
	var/cap = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		laser += M.rating
	for(var/obj/item/weapon/stock_parts/capacitor/M in component_parts)
		cap += M.rating

	heatingPower = laser * 40000

	settableTemperatureRange = cap * 30
	efficiency = (cap + 1) * 10000

	targetTemperature = Clamp(targetTemperature,
		max(settableTemperatureMedian - settableTemperatureRange, TCMB),
		settableTemperatureMedian + settableTemperatureRange)

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(panel_open)
			if(cell)
				to_chat(user, "<span class='warning'>There is already a power cell inside!</span>")
				return
			else
				// insert cell
				var/obj/item/weapon/stock_parts/cell/C = usr.get_active_held_item()
				if(istype(C))
					if(!user.drop_item())
						return
					cell = C
					C.loc = src
					C.add_fingerprint(usr)

					user.visible_message("\The [user] inserts a power cell into \the [src].", "<span class='notice'>You insert the power cell into \the [src].</span>")
					SStgui.update_uis(src)
		else
			to_chat(user, "<span class='warning'>The hatch must be open to insert a power cell!</span>")
			return
	else if(istype(I, /obj/item/weapon/screwdriver))
		panel_open = !panel_open
		user.visible_message("\The [user] [panel_open ? "opens" : "closes"] the hatch on \the [src].", "<span class='notice'>You [panel_open ? "open" : "close"] the hatch on \the [src].</span>")
		update_icon()
		if(panel_open)
			interact(user)
	else if(exchange_parts(user, I) || default_deconstruction_crowbar(I))
		return
	else
		return ..()

/obj/machinery/space_heater/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "space_heater", name, 400, 305, master_ui, state)
		ui.open()

/obj/machinery/space_heater/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["mode"] = setMode
	data["hasPowercell"] = !!cell
	if(cell)
		data["powerLevel"] = round(cell.percent(), 1)
	data["targetTemp"] = round(targetTemperature - T0C, 1)
	data["minTemp"] = max(settableTemperatureMedian - settableTemperatureRange - T0C, TCMB)
	data["maxTemp"] = settableTemperatureMedian + settableTemperatureRange - T0C

	var/turf/L = get_turf(loc)
	var/curTemp
	if(istype(L))
		var/datum/gas_mixture/env = L.return_air()
		curTemp = env.temperature
	else if(isturf(L))
		curTemp = L.temperature
	if(isnull(curTemp))
		data["currentTemp"] = "N/A"
	else
		data["currentTemp"] = round(curTemp - T0C, 1)
	return data

/obj/machinery/space_heater/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			mode = HEATER_MODE_STANDBY
			usr.visible_message("[usr] switches [on ? "on" : "off"] \the [src].", "<span class='notice'>You switch [on ? "on" : "off"] \the [src].</span>")
			update_icon()
			. = TRUE
		if("mode")
			setMode = params["mode"]
			. = TRUE
		if("target")
			if(!panel_open)
				return
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New target temperature:", name, round(targetTemperature - T0C, 1)) as num|null
				if(!isnull(target) && !..())
					target += T0C
					. = TRUE
			else if(adjust)
				target = targetTemperature + adjust
				. = TRUE
			else if(text2num(target) != null)
				target= text2num(target) + T0C
				. = TRUE
			if(.)
				targetTemperature = Clamp(round(target),
					max(settableTemperatureMedian - settableTemperatureRange, TCMB),
					settableTemperatureMedian + settableTemperatureRange)
		if("eject")
			if(panel_open && cell)
				cell.loc = get_turf(src)
				cell = null
				. = TRUE

#undef HEATER_MODE_STANDBY
#undef HEATER_MODE_HEAT
#undef HEATER_MODE_COOL
