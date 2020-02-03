#define MODE_OFF 0
#define MODE_NORMAL 1
#define MODE_OVERPRESSURE 2
#define MODE_VENTING 3

/obj/machinery/portable_atmospherics/ventcap
	icon = 'icons/obj/atmospherics/components/miners.dmi'
	icon_state = "ventcap"

	name = "atmospheric vent cap"
	desc = "Interfaces with a atmospheric vent to collect large quantities of gas rushing up from deep beneath the surface."

	density = TRUE
	max_integrity = 300
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/ventcap
	idle_power_usage = 0
	active_power_usage = 2000
	ui_x = 300
	ui_y = 230

	var/icon_state_off = "ventcap_unanchored"
	var/icon_state_on = "ventcap_anchored"
	var/icon_state_growing = "ventcap-growing"
	var/icon_state_venting = "ventcap-venting"

	var/on = FALSE // Technically doesn't use power while 'on', only while growing.
	var/mode = MODE_OFF
	var/icon_mode = MODE_OFF
	var/gas_type = null
	var/base_rate = 0
	var/current_rate = 0
	var/output_temperature = T0C
	var/power_usage_mult = 1

	var/base_volume = 1000
	var/current_volume = 1000 // Production rate is directly tied to its volume; it fills itself with pressure_limit KPA every atmos tick.
	var/exponential_percentage = 1/100 // This is the percentage of growth per process_atmos().
	var/pressure_limit = MAX_OUTPUT_PRESSURE // The point where we start exponentially decreasing output.
	var/emergency_vent_pressure = MAX_OUTPUT_PRESSURE * 4 // The point where slow exponential decrease is not enough, so we start venting it into the surroundings.
	var/destruction_gas_multiplier = 100 //If you break it, you get this many cycles worth of gas all at once. Does not include exponential growth because that'd be bad.

	var/datum/looping_sound/ventcap/soundloop


/obj/machinery/portable_atmospherics/ventcap/RefreshParts()
	var/list/pinfo = list()
		
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		pinfo[1]++
		pinfo["[pinfo[1]]"] += M.rating
	for(var/obj/item/stock_parts/capacitor/M in component_parts)
		pinfo[1]++
		pinfo["[pinfo[1]]"] += M.rating
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		pinfo[1]++
		pinfo["[pinfo[1]]"] += M.rating
	
	pressure_limit = initial(pressure_limit) * (1 + ((pinfo[1] / pinfo["[pinfo[1]]"]) - 1)/3) // Pressure limit up to doubles with better matter bins.
	emergency_vent_pressure = pressure_limit * 4 // Emergency vent pressure is always 4x the pressure limit.
	power_usage_mult = initial(power_usage_mult) * (pinfo[3] / pinfo["[pinfo[3]]"]) / (pinfo[2] / pinfo["[pinfo[2]]"]) // Power usage increases with better lasers and is mitigated by capacitors.
	exponential_percentage = initial(exponential_percentage) * (pinfo[3] / pinfo["[pinfo[3]]"]) // Growth rate increases up to 4x with better lasers.
	

/obj/machinery/portable_atmospherics/ventcap/process_atmos()
	..()
	if(!gas_type)
		return FALSE
		on = FALSE
	update_power()

	var/pressure = air_contents.return_pressure() // So we don't have to call that proc multiple times.

	if(pressure > pressure_limit)
		if(pressure > emergency_vent_pressure)
			mode = MODE_VENTING
			emergency_vent()
		adjust_volume(exponential_percentage*(emergency_venting ? -2 : -1)) // Loses output faster if venting.
		air_contents.volume = current_volume
	else if(growing && do_powerstuff(active_power_usage)) // Gains output only if power is supplied
		adjust_volume(exponential_percentage)

	harvest() // What, you thought that giant, billowing geyser of gas would stop just because you asked politely?

	return TRUE

/obj/machinery/portable_atmospherics/ventcap/proc/adjust_volume(var/percentage)
	current_volume = max(round(current_volume * base_rate * (1 + percentage), 1), base_volume)
	air_contents.volume = current_volume

/obj/machinery/portable_atmospherics/ventcap/proc/harvest()
	var/datum/gas_mixture/bountiful_harvest = new
	var/harvest_moles = ((pressure_limit)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*output_temperature)) // Exactly enough moles to add pressure_limit KPA to it.

	bountiful_harvest.assert_gas(gas_type)
	bountiful_harvest.gases[gas_type][MOLES] = (harvest_moles)
	bountiful_harvest.temperature = output_temperature
	
	air_contents.merge(bountiful_harvest)

/obj/machinery/portable_atmospherics/ventcap/proc/emergency_vent()
	var/overpressure = max((air_contents.return_pressure() - emergency_vent_pressure), 0) // Just incase var editing goes wrong.
	var/vent_moles = ((overpressure)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)) // Vent just enough to close the (imaginary) emergency release valve.

	var/datum/gas_mixture/vented = air_contents.remove(vent_moles)
	loc.assume_air(vented)
	air_update_turf()

/obj/machinery/portable_atmospherics/ventcap/proc/do_powerstuff(amount)
	var/turf/T = get_turf(src)

	if(T && istype(T))
		var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
		if(C && C.powernet && (C.powernet.avail > amount))
			C.powernet.load += amount
			return TRUE
	if(powered()) //Or, if we don't have a cable node, check if we're in a powered area.
		use_power(amount)
		return TRUE
	return FALSE

/obj/machinery/portable_atmospherics/ventcap/proc/update_power()
	if(!growing)
		active_power_usage = idle_power_usage
	var/power_multiplier = power_usage_mult * round(sqrt(current_volume/base_volume), 0.1) // Power usage increases as you try to get more gas out, but not linearly.
	active_power_usage = initial(active_power_usage)*power_multiplier

/obj/machinery/portable_atmospherics/ventcap/attackby(obj/item/I, mob/user, params)
	if((I.tool_behaviour == TOOL_WRENCH) && on)
		to_chat(user, "<span class='userdanger'>As you begin unwrenching \the [src] a torrent of air begins to escape and \the [src] rumbles ominously... this seems like a really bad idea!</span>")
		if(I.use_tool(src, user, 20, volume=50))
			rupture()
		return
	. = ..()

/obj/machinery/portable_atmospherics/ventcap/Initialize()
	. = ..()
	soundloop = new(list(src), TRUE)


/obj/machinery/portable_atmospherics/ventcap/Destroy()
	. = ..()
	QDEL_NULL(soundloop)
	if(on)
		rupture()

/obj/machinery/portable_atmospherics/ventcap/proc/rupture()
	visible_message("<span class='danger'>[src] violently ruptures!</span>")
	var/datum/gas_mixture/foomf = new
	var/scale_amount = 5*round(sqrt(current_volume/base_volume), 0.1)
	var/boom_moles = destruction_gas_multiplier*((pressure_limit)*(current_volume)/(R_IDEAL_GAS_EQUATION*output_temperature))

	foomf.assert_gas(gas_type)
	foomf.gases[gas_type][MOLES] = (boom_moles) // Quite a bit of overpressure, but it'll dissipate into the atmosphere quickly enough.
	foomf.temperature = output_temperature
	loc.assume_air(foomf)
	for(var/turf/open/tile in orange(2,src))
		if(istype(tile))
			tile.assume_air(foomf)

	for(var/atom/movable/A in range(loc, scale_amount))
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(loc, src)))
		A.safe_throw_at(throwtarget,scale_amount,1, force = MOVE_FORCE_EXTREMELY_STRONG)

	explosion(loc, -1, 0, scale_amount/5, scale_amount, 0, flame_range = scale_amount*2) // Maybe don't break the dangerously high pressure machinery on top of a weird bluespace thingy.
	if(!QDELETED(src))
		qdel(src)

/obj/machinery/portable_atmospherics/ventcap/iconstuff()
	if(on && is_operational())
		switch(icon_mode)
			if(MODE_VENTING)
				if(!mode == MODE_VENTING)
					flick(ventcap_venting_end, src)
					icon_mode = MODE_OVERPRESSURE
			if(MODE_OVERPRESSURE)
				if(mode == MODE_VENTING)
					flick(ventcap_venting_start, src)
					icon_state = icon_state_venting
					icon_mode = MODE_VENTING
				else if(mode == MODE_NORMAL)
					flick(ventcap_venting_start, src)
					icon_state = icon_state_venting
					icon_mode = MODE_VENTING
			if(MODE_NORMAL)
			
			if(MODE_OFF)
				
				
		if(mode == MODE_VENTING && !icon_mode == MODE_VENTING)
			icon_mode = MODE_VENTING
			icon_state = icon_state_venting
			flick(ventcap_venting_start, src)
		else if(icon_mode == MODE_VENTING)
			flick(ventcap_venting_end, src)

/obj/machinery/portable_atmospherics/ventcap/connect(obj/machinery/atmospherics/components/unary/portables_connector/atmosphere_vent/thevent)
	. = ..()
	gas_type = thevent.gastype

/obj/machinery/portable_atmospherics/ventcap/disconnect()
	. = ..()
	gas_type = null



/obj/machinery/portable_atmospherics/ventcap/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
																	datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_ventcap", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/portable_atmospherics/ventcap/ui_data()
	var/data = list()

	if(growing)
		data["status"] = "growing"
		data["pressurecolor"] = "'teal'"
	else if(emergency_venting)
		data["status"] = "emergency pressure release"
		data["pressurecolor"] = "'red'"
	else if(on)
		data["status"] = "online"
		data["pressurecolor"] = "'green'"
	else
		data["status"] = "offline"
		data["pressurecolor"] = "'grey'"

	data["gas"] = gas_type[name]
	data["volume"] = round(current_volume)
	data["max_pressure"] = round(emergency_vent_pressure)

	var/datum/gas_mixture/air = return_air()
	data["pressure"] = air.return_pressure()
	data["temperature"] = air.temperature

/obj/machinery/portable_atmospherics/ventcap/ui_act(action, params)
	if(..())
		return

#undef MODE_NORMAL
#undef MODE_OVERPRESSURE
#undef MODE_VENTING