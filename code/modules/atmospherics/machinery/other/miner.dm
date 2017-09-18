#define GASMINER_POWER_NONE 0
#define GASMINER_POWER_STATIC 1
#define GASMINER_POWER_MOLES 2	//Scaled from here on down.
#define GASMINER_POWER_KPA 3
#define GASMINER_POWER_FULLSCALE 4

/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/components/miners.dmi'
	icon_state = "miner"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE|ACID_PROOF|FIRE_PROOF
	var/list/gas_mixture = list()// An associative list of gasses to the relative concentrations of the gas mixture it outputs.  Make sure the values add up to 1.
	var/spawn_temp = T20C
	var/spawn_mol = MOLES_CELLSTANDARD * 10
	var/max_ext_mol = INFINITY
	var/max_ext_kpa = 6500
	var/overlay_color = "#FFFFFF"
	var/active = TRUE
	var/power_draw = GASMINER_POWER_NONE
	var/power_draw_static = 2000
	var/power_draw_dynamic_mol_coeff = 5	//DO NOT USE DYNAMIC SETTINGS UNTIL SOMEONE MAKES A USER INTERFACE/CONTROLLER FOR THIS!
	var/power_draw_dynamic_kpa_coeff = 0.5
	var/broken = FALSE
	var/broken_message = "ERROR"
	idle_power_usage = 150
	active_power_usage = 2000
	var/has_display = TRUE
	var/can_overpressure = TRUE

/obj/machinery/atmospherics/miner/Initialize()
	. = ..()
	set_active(active)				//Force overlay update.

/obj/machinery/atmospherics/miner/examine(mob/user)
	..()
	if(broken && has_display)
		to_chat(user, "Its debug output is printing \"[broken_message]\"")

/obj/machinery/atmospherics/miner/proc/check_operation()
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	if(!isopenturf(T))
		broken_message = "<span class='boldnotice'>VENT BLOCKED</span>"
		set_broken(TRUE)
		return FALSE
	var/turf/open/OT = T
	if(OT.planetary_atmos)
		broken_message = "<span class='boldwarning'>DEVICE NOT ENCLOSED IN A PRESSURIZED ENVIRONMENT</span>"
		set_broken(TRUE)
		return FALSE
	if(isspaceturf(T))
		broken_message = "<span class='boldnotice'>AIR VENTING TO SPACE</span>"
		set_broken(TRUE)
		return FALSE
	var/datum/gas_mixture/G = OT.return_air()
	if(can_overpressure && G.return_pressure() > (max_ext_kpa - ((spawn_mol*spawn_temp*R_IDEAL_GAS_EQUATION)/(CELL_VOLUME))))
		broken_message = "<span class='boldwarning'>EXTERNAL PRESSURE OVER THRESHOLD</span>"
		set_broken(TRUE)
		return FALSE
	if(G.total_moles() > max_ext_mol)
		broken_message = "<span class='boldwarning'>EXTERNAL AIR CONCENTRATION OVER THRESHOLD</span>"
		set_broken(TRUE)
		return FALSE
	if(broken)
		set_broken(FALSE)
		broken_message = ""
	return TRUE

/obj/machinery/atmospherics/miner/proc/moles_to_spawn(var/turf/open/turf)
	return spawn_mol

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
	if(!active_power_usage)
		return TRUE
	var/turf/T = get_turf(src)
	if(T && istype(T))
		var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
		if(C && C.powernet && (C.powernet.avail > amount))
			C.powernet.load += amount
			return TRUE
	if(powered())
		use_power(amount)
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
	if(active && !broken)
		if(LAZYLEN(gas_mixture))
			return FALSE
		if(do_use_power(active_power_usage))
			mine_gas()

/obj/machinery/atmospherics/miner/proc/mine_gas()
	var/turf/open/O = get_turf(src)
	if(!isopenturf(O))
		return FALSE
	var/datum/gas_mixture/merger = new
	var/moles_spawned = moles_to_spawn(O)
	for(var/gas in gas_mixture) // Iterates over the KEYS of the associative list.
		merger.add_gas(gas)
		merger.gases[gas][MOLES] = moles_spawned * gas_mixture[gas] //The VALUE of the associative list is the relative concentrations of each gas.
	merger.temperature = spawn_temp
	O.assume_air(merger)
	SSair.add_to_active(O)

/obj/machinery/atmospherics/miner/attack_ai(mob/living/silicon/user)
	if(broken && has_display)
		to_chat(user, "[src] seems to be broken. Its debug interface outputs: [broken_message]")
	..()

/obj/machinery/atmospherics/miner/n2o
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"
	gas_mixture = list("n2o" = 1)

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"
	gas_mixture = list("n2" = 1)

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"
	gas_mixture = list("o2" = 1)

/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"
	gas_mixture = list("plasma" = 1)

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"
	gas_mixture = list("co2" = 1)

/obj/machinery/atmospherics/miner/bz
	name = "\improper BZ Gas Miner"
	overlay_color = "#FAFF00"
	gas_mixture = list("bz" = 1)

/obj/machinery/atmospherics/miner/freon
	name = "\improper Freon Gas Miner"
	overlay_color = "#00FFE5"
	gas_mixture = list("freon" = 1)

/obj/machinery/atmospherics/miner/volatile_fuel
	name = "\improper Volatile Fuel Gas Miner"
	overlay_color = "#564040"
	gas_mixture = list("v_fuel" = 1)

/obj/machinery/atmospherics/miner/agent_b
	name = "\improper Agent B Gas Miner"
	overlay_color = "#E81E24"
	gas_mixture = list("agent_b" = 1)

/obj/machinery/atmospherics/miner/water_vapor
	name = "\improper Water Vapor Gas Miner"
	overlay_color = "#99928E"
	gas_mixture = list("water_vapor" = 1)

/obj/machinery/atmospherics/miner/air_mix
	name = "\improper Atmospheric Gas Miner"
	gas_mixture = list("n2" = N2STANDARD, "o2" = O2STANDARD)

/obj/machinery/atmospherics/miner/gas_portal
	name = "Unspecified Gas Portal"
	desc = "You shouldn't see this text.  Contact a coder or admin."
	max_ext_kpa = ONE_ATMOSPHERE
	icon_state = "air_portal"
	has_display = FALSE
	can_overpressure = FALSE
	var/lifetime = 600

/obj/machinery/atmospherics/miner/gas_portal/Initialize()
	. = ..()
	QDEL_IN(src, lifetime)

/obj/machinery/atmospherics/miner/gas_portal/update_icon()
	return //The portals don't have overlays.

/obj/machinery/atmospherics/miner/gas_portal/moles_to_spawn(var/turf/open/target_turf)
	//Releases exactly enough gas to reach the target pressure.
	var/datum/gas_mixture/G = target_turf.return_air()
	return max(0,(1-G.return_pressure()/max_ext_kpa)*spawn_mol)
	

/obj/machinery/atmospherics/miner/gas_portal/repressurizer
	name = "Bluespace atmosphere restorer"
	desc = "A miniature bluespace portal used to siphon the atmosphere from a backwater planet so that you may refill a depresurized area. This portal will dissipate one minute after creation."
	icon_state = "air_portal"
	gas_mixture = list("n2" = N2STANDARD, "o2" = O2STANDARD)
	spawn_mol = MOLES_CELLSTANDARD
