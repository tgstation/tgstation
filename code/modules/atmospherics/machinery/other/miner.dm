
#define GASMINER_POWER_NONE 0
#define GASMINER_POWER_STATIC 1
#define GASMINER_POWER_MOLES 2 //Scaled from here on down.
#define GASMINER_POWER_KPA 3
#define GASMINER_POWER_FULLSCALE 4

/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/components/miners.dmi'
	icon_state = "miner"
	density = FALSE
	resistance_flags = INDESTRUCTIBLE|ACID_PROOF|FIRE_PROOF
	var/spawn_id = null
	var/spawn_temp = T20C
	/// Moles of gas to spawn per second
	var/spawn_mol = MOLES_CELLSTANDARD * 5
	var/max_ext_mol = INFINITY
	var/max_ext_kpa = 6500
	var/overlay_color = "#FFFFFF"
	var/active = TRUE
	var/power_draw = 0
	var/power_draw_static = 2000
	var/power_draw_dynamic_mol_coeff = 5 //DO NOT USE DYNAMIC SETTINGS UNTIL SOMEONE MAKES A USER INTERFACE/CONTROLLER FOR THIS!
	var/power_draw_dynamic_kpa_coeff = 0.5
	var/broken = FALSE
	var/broken_message = "ERROR"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.5
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2

/obj/machinery/atmospherics/miner/Initialize(mapload)
	. = ..()
	set_active(active) //Force overlay update.

/obj/machinery/atmospherics/miner/examine(mob/user)
	. = ..()
	if(broken)
		. += {"Its debug output is printing "[broken_message]"."}

/obj/machinery/atmospherics/miner/proc/check_operation()
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	if(!isopenturf(T))
		broken_message = span_boldnotice("VENT BLOCKED")
		set_broken(TRUE)
		return FALSE
	var/turf/open/OT = T
	if(OT.planetary_atmos)
		broken_message = span_boldwarning("DEVICE NOT ENCLOSED IN A PRESSURIZED ENVIRONMENT")
		set_broken(TRUE)
		return FALSE
	if(isspaceturf(T))
		broken_message = span_boldnotice("AIR VENTING TO SPACE")
		set_broken(TRUE)
		return FALSE
	var/datum/gas_mixture/G = OT.return_air()
	if(G.return_pressure() > (max_ext_kpa - ((spawn_mol*spawn_temp*R_IDEAL_GAS_EQUATION)/(CELL_VOLUME))))
		broken_message = span_boldwarning("EXTERNAL PRESSURE OVER THRESHOLD")
		set_broken(TRUE)
		return FALSE
	if(G.total_moles() > max_ext_mol)
		broken_message = span_boldwarning("EXTERNAL AIR CONCENTRATION OVER THRESHOLD")
		set_broken(TRUE)
		return FALSE
	if(broken)
		set_broken(FALSE)
		broken_message = ""
	return TRUE

/obj/machinery/atmospherics/miner/proc/set_active(setting)
	if(active != setting)
		active = setting
		update_appearance()

/obj/machinery/atmospherics/miner/proc/set_broken(setting)
	if(broken != setting)
		broken = setting
		update_appearance()

/obj/machinery/atmospherics/miner/proc/update_power()
	if(!active)
		active_power_usage = idle_power_usage
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	var/P = G.return_pressure()
	switch(power_draw)
		if(GASMINER_POWER_NONE)
			update_use_power(ACTIVE_POWER_USE, 0)
		if(GASMINER_POWER_STATIC)
			update_use_power(ACTIVE_POWER_USE, power_draw_static)
		if(GASMINER_POWER_MOLES)
			update_use_power(ACTIVE_POWER_USE, spawn_mol * power_draw_dynamic_mol_coeff)
		if(GASMINER_POWER_KPA)
			update_use_power(ACTIVE_POWER_USE, P * power_draw_dynamic_kpa_coeff)
		if(GASMINER_POWER_FULLSCALE)
			update_use_power(ACTIVE_POWER_USE, (spawn_mol * power_draw_dynamic_mol_coeff) + (P * power_draw_dynamic_kpa_coeff))

/obj/machinery/atmospherics/miner/proc/do_use_power(amount)
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

/obj/machinery/atmospherics/miner/update_overlays()
	. = ..()
	if(broken)
		. += "broken"
		return

	if(active)
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "on")
		on_overlay.color = overlay_color
		. += on_overlay

/obj/machinery/atmospherics/miner/process(delta_time)
	update_power()
	check_operation()
	if(active && !broken)
		if(isnull(spawn_id))
			return FALSE
		if(do_use_power(active_power_usage))
			mine_gas(delta_time)

/obj/machinery/atmospherics/miner/proc/mine_gas(delta_time = 2)
	var/turf/open/O = get_turf(src)
	if(!isopenturf(O))
		return FALSE
	var/datum/gas_mixture/merger = new
	merger.assert_gas(spawn_id)
	merger.gases[spawn_id][MOLES] = spawn_mol * delta_time
	merger.temperature = spawn_temp
	O.assume_air(merger)

/obj/machinery/atmospherics/miner/attack_ai(mob/living/silicon/user)
	if(broken)
		to_chat(user, "[src] seems to be broken. Its debug interface outputs: [broken_message]")
	..()

/obj/machinery/atmospherics/miner/n2o
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"
	spawn_id = /datum/gas/nitrous_oxide

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"
	spawn_id = /datum/gas/nitrogen

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"
	spawn_id = /datum/gas/oxygen

/obj/machinery/atmospherics/miner/plasma
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"
	spawn_id = /datum/gas/plasma

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"
	spawn_id = /datum/gas/carbon_dioxide

/obj/machinery/atmospherics/miner/bz
	name = "\improper BZ Gas Miner"
	overlay_color = "#FAFF00"
	spawn_id = /datum/gas/bz

/obj/machinery/atmospherics/miner/water_vapor
	name = "\improper Water Vapor Gas Miner"
	overlay_color = "#99928E"
	spawn_id = /datum/gas/water_vapor

/obj/machinery/atmospherics/miner/freon
	name = "\improper Freon Gas Miner"
	overlay_color = "#61edff"
	spawn_id = /datum/gas/freon

/obj/machinery/atmospherics/miner/halon
	name = "\improper Halon Gas Miner"
	overlay_color = "#5f0085"
	spawn_id = /datum/gas/halon

/obj/machinery/atmospherics/miner/healium
	name = "\improper Healium Gas Miner"
	overlay_color = "#da4646"
	spawn_id = /datum/gas/healium

/obj/machinery/atmospherics/miner/hydrogen
	name = "\improper Hydrogen Gas Miner"
	overlay_color = "#ffffff"
	spawn_id = /datum/gas/hydrogen

/obj/machinery/atmospherics/miner/hypernoblium
	name = "\improper Hypernoblium Gas Miner"
	overlay_color = "#00f7ff"
	spawn_id = /datum/gas/hypernoblium

/obj/machinery/atmospherics/miner/miasma
	name = "\improper Miasma Gas Miner"
	overlay_color = "#395806"
	spawn_id = /datum/gas/miasma

/obj/machinery/atmospherics/miner/nitrium
	name = "\improper Nitrium Gas Miner"
	overlay_color = "#752b00"
	spawn_id = /datum/gas/nitrium

/obj/machinery/atmospherics/miner/pluoxium
	name = "\improper Pluoxium Gas Miner"
	overlay_color = "#4b54a3"
	spawn_id = /datum/gas/pluoxium

/obj/machinery/atmospherics/miner/proto_nitrate
	name = "\improper Proto-Nitrate Gas Miner"
	overlay_color = "#00571d"
	spawn_id = /datum/gas/proto_nitrate

/obj/machinery/atmospherics/miner/tritium
	name = "\improper Tritium Gas Miner"
	overlay_color = "#15ff00"
	spawn_id = /datum/gas/tritium

/obj/machinery/atmospherics/miner/zauker
	name = "\improper Zauker Gas Miner"
	overlay_color = "#022e00"
	spawn_id = /datum/gas/zauker

/obj/machinery/atmospherics/miner/helium
	name = "\improper Helium Gas Miner"
	overlay_color = "#022e00"
	spawn_id = /datum/gas/helium

/obj/machinery/atmospherics/miner/antinoblium
	name = "\improper Antinoblium Gas Miner"
	overlay_color = "#022e00"
	spawn_id = /datum/gas/antinoblium
