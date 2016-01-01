#define HEATER_MODE_STANDBY	"standby"
#define HEATER_MODE_HEAT	"heat"
#define HEATER_MODE_COOL	"cool"

/obj/machinery/space_heater
	anchored = 0
	density = 1
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater-off"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater/cooler is guaranteed not to set the station on fire."
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


/obj/machinery/space_heater/New()
	..()
	cell = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/space_heater(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 3)
	RefreshParts()
	update_icon()

/obj/machinery/space_heater/construction()
	qdel(cell)
	cell = null
	panel_open = TRUE
	update_icon()
	return ..()

/obj/machinery/space_heater/deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	return ..()

/obj/machinery/space_heater/update_icon()
	if(on)
		icon_state = "sheater-[mode]"
	else
		icon_state = "sheater-off"

	overlays.Cut()
	if(panel_open)
		overlays += "sheater-open"

/obj/machinery/space_heater/examine(mob/user)
	..()
	user << "\The [src] is [on ? "on" : "off"], and the hatch is [panel_open ? "open" : "closed"]."
	if(cell)
		user << "The charge meter reads [cell ? round(cell.percent(), 1) : 0]%."
	else
		user << "There is no power cell installed."

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

	var/minTemp = max(settableTemperatureMedian - settableTemperatureRange, TCMB)
	var/maxTemp = settableTemperatureMedian + settableTemperatureRange
	targetTemperature = dd_range(minTemp, maxTemp, targetTemperature)

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/get_ui_data()
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

	var/turf/simulated/L = get_turf(loc)
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

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(panel_open)
			if(cell)
				user << "<span class='warning'>There is already a power cell inside!</span>"
				return
			else
				// insert cell
				var/obj/item/weapon/stock_parts/cell/C = usr.get_active_hand()
				if(istype(C))
					if(!user.drop_item())
						return
					cell = C
					C.loc = src
					C.add_fingerprint(usr)

					user.visible_message("\The [user] inserts a power cell into \the [src].", "<span class='notice'>You insert the power cell into \the [src].</span>")
					SSnano.update_uis(src)
		else
			user << "<span class='warning'>The hatch must be open to insert a power cell!</span>"
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
		..()

/obj/machinery/space_heater/attack_hand(mob/user)
	interact(user)

/obj/machinery/space_heater/attack_paw(mob/user)
	interact(user)

/obj/machinery/space_heater/interact(mob/user)
	ui_interact(user)

/obj/machinery/space_heater/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, force_open = force_open)
	if (!ui)
		ui = new(user, src, ui_key, "space_heater", name, 490, 340, state = physical_state)
		ui.open()

/obj/machinery/space_heater/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
			mode = HEATER_MODE_STANDBY
			usr.visible_message("[usr] switches [on ? "on" : "off"] \the [src].", "<span class='notice'>You switch [on ? "on" : "off"] \the [src].</span>")
			update_icon()
		if("mode")
			setMode = params["mode"]
		if("temp")
			if(panel_open)
				var/value
				if(params["set"] == "custom")
					value = input("Please input the target temperature", name) as num|null
					if(isnull(value))
						return
					value += T0C
				else
					value = targetTemperature + text2num(params["set"])

				var/minTemp = max(settableTemperatureMedian - settableTemperatureRange, TCMB)
				var/maxTemp = settableTemperatureMedian + settableTemperatureRange
				targetTemperature = dd_range(minTemp, maxTemp, round(value, 1))
		if("ejectcell")
			if(panel_open && cell)
				if(usr.get_active_hand())
					usr << "<span class='warning'>You need an empty hand to remove \the [cell]!</span>"
					return
				cell.updateicon()
				usr.put_in_hands(cell)
				cell.add_fingerprint(usr)
				usr.visible_message("\The [usr] removes \the [cell] from \the [src].", "<span class='notice'>You remove \the [cell] from \the [src].</span>")
				cell = null
		if("installcell")
			if(panel_open && !cell)
				var/obj/item/weapon/stock_parts/cell/C = usr.get_active_hand()
				if(istype(C))
					if(!usr.drop_item())
						return
					cell = C
					C.loc = src
					C.add_fingerprint(usr)
					usr.visible_message("\The [usr] inserts \a [C] into \the [src].", "<span class='notice'>You insert \the [C] into \the [src].</span>")
	add_fingerprint(usr)
	return 1

/obj/machinery/space_heater/process()
	if(!on || (stat & BROKEN))
		return

	if(cell && cell.charge > 0)
		var/turf/simulated/L = loc
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

#undef HEATER_MODE_STANDBY
#undef HEATER_MODE_HEAT
#undef HEATER_MODE_COOL
