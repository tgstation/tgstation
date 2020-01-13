
#define GASMINER_POWER_NONE 0
#define GASMINER_POWER_STATIC 1
#define GASMINER_POWER_MOLES 2	//Scaled from here on down.
#define GASMINER_POWER_KPA 3
#define GASMINER_POWER_FULLSCALE 4

/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "A high-tech bluespace manifold which generates a constant flow of gas."
	icon = 'icons/obj/atmospherics/components/miners.dmi'
	icon_state = "miner"
	density = FALSE
	circuit = /obj/item/circuitboard/machine/gas_miner

	var/spawn_id = null
	var/spawn_temp = T20C
	var/spawn_mol_max = MOLES_CELLSTANDARD * 10
	var/spawn_mol = 0
	var/max_ext_mol = INFINITY
	var/max_ext_kpa = 6500
	var/set_ext_kpa = 2500 // This is the old var-edited limit set by maps that had gas miners before they became standard.
	var/list/permitted_gases = list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma, /datum/gas/nitrous_oxide)
	var/overlay_color = "#FFFFFF"

	var/active = FALSE
	var/power_draw = GASMINER_POWER_FULLSCALE
	var/power_draw_static = 2000
	var/power_draw_dynamic_mol_coeff = 5
	var/power_draw_dynamic_kpa_coeff = 0.5
	var/broken = FALSE
	var/status_message = "ERROR"
	idle_power_usage = 150
	active_power_usage = 2000
	ui_x = 390
	ui_y = 187

	var/id_tag
	var/frequency = FREQ_ATMOS_STORAGE
	var/datum/radio_frequency/radio_connection
	

/obj/machinery/atmospherics/miner/Initialize()
	. = ..()
	set_active(active)				//Force overlay update.
	if(!isnull(spawn_id)) // Pre-configured gas miners should start on by default, because they started on a map instead of being built.
		active = TRUE
		spawn_mol = spawn_mol_max
		change_color(spawn_id)
	SSair.atmos_machinery += src
	set_frequency(frequency)

/obj/machinery/atmospherics/miner/RefreshParts()
	var/bin
	var/manip
	var/cap
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		bin += M.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		manip += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		cap += M.rating

	spawn_mol_max = initial(spawn_mol_max) * bin/2
	max_ext_kpa = initial(max_ext_kpa) * manip/2
	power_draw_dynamic_mol_coeff = initial(power_draw_dynamic_mol_coeff) * (bin**2) / (cap*2) // Increases power draw, mitigated by capacitors
	power_draw_dynamic_kpa_coeff = initial(power_draw_dynamic_kpa_coeff) * (manip**2) / (cap*2) // Also increases draw. Atmos techs beware.

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(active)
		. += {"Its status output is printing "[status_message]"."}

/obj/machinery/atmospherics/miner/proc/check_operation()
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	if(!T.get_Cable_node())
		status_message = "<span class='boldwarning'>CABLE NODE NOT FOUND</span>"
		set_broken(TRUE)
		return FALSE
	if(!isopenturf(T))
		status_message = "<span class='boldnotice'>VENT BLOCKED</span>"
		set_broken(TRUE)
		return FALSE
	var/turf/open/OT = T
	if(OT.planetary_atmos)
		status_message = "<span class='boldwarning'>DEVICE NOT ENCLOSED IN A PRESSURIZED ENVIRONMENT</span>"
		set_broken(TRUE)
		return FALSE
	if(isspaceturf(T))
		status_message = "<span class='boldnotice'>AIR VENTING TO SPACE</span>"
		set_broken(TRUE)
		return FALSE
	var/datum/gas_mixture/G = OT.return_air()
	if(G.return_pressure() > (set_ext_kpa - ((spawn_mol*spawn_temp*R_IDEAL_GAS_EQUATION)/(CELL_VOLUME))))
		status_message = "<span class='boldwarning'>EXTERNAL PRESSURE OVER THRESHOLD</span>"
		set_broken(TRUE)
		return FALSE
	if(G.total_moles() > max_ext_mol)
		status_message = "<span class='boldwarning'>EXTERNAL AIR CONCENTRATION OVER THRESHOLD</span>"
		set_broken(TRUE)
		return FALSE
	if(broken)
		set_broken(FALSE)
		status_message = "<span class='boldnotice'>OPERATION NOMINAL</span>"
	return TRUE

/obj/machinery/atmospherics/miner/proc/set_active(setting)
	if(active != setting)
		active = setting
		update_icon()

/obj/machinery/atmospherics/miner/proc/set_broken(setting)
	if(broken != setting)
		broken = setting
		update_icon()

/obj/machinery/atmospherics/miner/proc/update_power()
	if(!active)
		active_power_usage = idle_power_usage
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	var/P = G.return_pressure()
	switch(power_draw)
		if(GASMINER_POWER_NONE)
			active_power_usage = 0
		if(GASMINER_POWER_STATIC)
			active_power_usage = power_draw_static
		if(GASMINER_POWER_MOLES)
			active_power_usage = spawn_mol * power_draw_dynamic_mol_coeff
		if(GASMINER_POWER_KPA)
			active_power_usage = P * power_draw_dynamic_kpa_coeff
		if(GASMINER_POWER_FULLSCALE)
			active_power_usage = (spawn_mol * power_draw_dynamic_mol_coeff) + (P * power_draw_dynamic_kpa_coeff)

/obj/machinery/atmospherics/miner/proc/do_use_power(amount)
	var/turf/T = get_turf(src)
	if(T && istype(T))
		var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
		if(C && C.powernet && (C.powernet.avail > amount))
			C.powernet.load += amount
			return TRUE
	return FALSE

/obj/machinery/atmospherics/miner/update_icon()
	cut_overlays()
	if(broken)
		add_overlay("broken")
	else if(active)
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "on")
		on_overlay.color = overlay_color
		add_overlay(on_overlay)

/obj/machinery/atmospherics/miner/process()
	update_power()
	check_operation()
	if(active)
		var/datum/signal/signal = new(list(
			"sigtype" = "status",
			"id_tag" = id_tag,
			"timestamp" = world.time,
			"gas_type" = (spawn_id ? GLOB.meta_gas_info[spawn_id][META_GAS_NAME] : "nothing"),
			"mole_out" = spawn_mol,
			"status" = status_message
		))

		radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)
		if(!broken)
			if(isnull(spawn_id))
				return FALSE
			if(do_use_power(active_power_usage))
				mine_gas()

/obj/machinery/atmospherics/miner/proc/mine_gas()
	var/turf/open/O = get_turf(src)
	if(!isopenturf(O))
		return FALSE
	var/datum/gas_mixture/merger = new
	merger.assert_gas(spawn_id)
	merger.gases[spawn_id][MOLES] = (spawn_mol)
	merger.temperature = spawn_temp
	O.assume_air(merger)
	O.air_update_turf(TRUE)

/obj/machinery/atmospherics/miner/attack_ai(mob/living/silicon/user)
	to_chat(user, "[src] seems to be [active ? "online" : "offline"]. Its status interface outputs: [status_message]")
	..()

/obj/machinery/atmospherics/miner/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																	datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_miner", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/miner/ui_data()
	var/data = list()
	data["on"] = active
	data["broken"] = broken
	data["state"] = status_message

	data["rate"] = round(spawn_mol)
	data["max_rate"] = round(spawn_mol_max)
	data["kpa_limit"] = round(set_ext_kpa)
	data["max_kpa"] = round(max_ext_kpa)

	var/datum/gas_mixture/air = return_air()
	data["pressure"] = air.return_pressure()
	data["moles"] = air.total_moles()

	data["mine_types"] = list()
	data["mine_types"] += list(list("name" = "Nothing", "path" = "", "selected" = !spawn_id))
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		if(length(permitted_gases) && (gas_id2path(gas[META_GAS_ID]) in permitted_gases))
			data["mine_types"] += list(list("name" = gas[META_GAS_NAME], "id" = gas[META_GAS_ID], "selected" = (path == gas_id2path(spawn_id))))

	return data

/obj/machinery/atmospherics/miner/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			active = !active
			investigate_log("was turned [active ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = spawn_mol_max
				. = TRUE
			else if(rate == "input")
				rate = input("New generation rate (0-[spawn_mol_max] mol/s):", name, spawn_mol) as num|null
				if(!isnull(rate) && !..())
					. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				spawn_mol = CLAMP(rate, 0, spawn_mol_max)
				investigate_log("was set to [spawn_mol] mol/s by [key_name(usr)]", INVESTIGATE_ATMOS)
		if("limit")
			var/limit = params["limit"]
			if(limit == "max")
				limit = max_ext_kpa
				. = TRUE
			else if(limit == "input")
				limit = input("New output kpa limit (0-[max_ext_kpa] mol/s):", name, set_ext_kpa) as num|null
				if(!isnull(limit) && !..())
					. = TRUE
			else if(text2num(limit) != null)
				limit = text2num(limit)
				. = TRUE
			if(.)
				set_ext_kpa = CLAMP(limit, 0, max_ext_kpa)
				investigate_log("was set to [set_ext_kpa] kpa limit by [key_name(usr)]", INVESTIGATE_ATMOS)
		if("mine")
			spawn_id = null
			var/mine_name = "nothing"
			var/gas = gas_id2path(params["mode"])
			if(gas in GLOB.meta_gas_info)
				spawn_id = gas
				mine_name = GLOB.meta_gas_info[gas][META_GAS_NAME]
			change_color(gas)
			investigate_log("was set to generate [mine_name] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
	update_icon()

/obj/machinery/atmospherics/miner/proc/change_color(var/gas) // If gases has a color associated with them or the css colors matched the defined colors this wouldn't be necessary. But they don't and they don't. Enjoy.
	if(gas == /datum/gas/oxygen) // Where a gas miner subtype had a pre-defined overlay color already, we use that.
		overlay_color = "#007FFF"
	else if(gas == /datum/gas/nitrogen)
		overlay_color = "#CCFFCC"
	else if(gas == /datum/gas/carbon_dioxide)
		overlay_color = "#CDCDCD"
	else if(gas == /datum/gas/plasma)
		overlay_color = "#FF0000"
	else if(gas == /datum/gas/water_vapor)
		overlay_color = "#99928E"
	else if(gas == /datum/gas/nitrous_oxide)
		overlay_color = "#FFCCCC"
	else if(gas == /datum/gas/bz)
		overlay_color = "#FAFF00"

	else if(gas == /datum/gas/hypernoblium) // Otherwise, we use the TGUI colors defined in constants.js and colors.scss
		overlay_color = "#00B5AS" 
	else if(gas == /datum/gas/nitryl)
		overlay_color = "#A5673F"
	else if(gas == /datum/gas/tritium)
		overlay_color = "#20B142"
	else if(gas == /datum/gas/stimulum)
		overlay_color = "#A333C8"
	else if(gas == /datum/gas/pluoxium)
		overlay_color = "#2185D0"
	else if(gas == /datum/gas/miasma)
		overlay_color = "#B5CC18"

/obj/machinery/atmospherics/miner/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/miner/Destroy()
	SSair.atmos_machinery -= src
	SSradio.remove_object(src, frequency)
	return ..()

/obj/machinery/atmospherics/miner/all
	name = "\improper Universal Gas Miner"
	desc = "A high-tech bluespace manifold which generates a constant flow of gas. This model is capable of generating any known form of gas."
	circuit = /obj/item/circuitboard/machine/gasminer/all

/obj/machinery/atmospherics/miner/all/Initialize()
	. = ..()
	var/list/all_gases = list()
	for(var/path in GLOB.meta_gas_info)
		all_gases += path
	permitted_gases = all_gases

/obj/machinery/atmospherics/miner/n2o
	name = "\improper N2O Gas Miner"
	spawn_id = /datum/gas/nitrous_oxide
	id_tag = ATMOS_GAS_MONITOR_MINER_N2O

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	spawn_id = /datum/gas/nitrogen
	id_tag = ATMOS_GAS_MONITOR_MINER_N2

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	spawn_id = /datum/gas/oxygen
	id_tag = ATMOS_GAS_MONITOR_MINER_O2

/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	spawn_id = /datum/gas/plasma
	id_tag = ATMOS_GAS_MONITOR_MINER_TOX

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	spawn_id = /datum/gas/carbon_dioxide
	id_tag = ATMOS_GAS_MONITOR_MINER_CO2

/obj/machinery/atmospherics/miner/bz
	name = "\improper BZ Gas Miner"
	spawn_id = /datum/gas/bz

/obj/machinery/atmospherics/miner/water_vapor
	name = "\improper Water Vapor Gas Miner"
	spawn_id = /datum/gas/water_vapor
