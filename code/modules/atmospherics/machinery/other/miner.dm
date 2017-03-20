/obj/machinery/atmospherics/miner
	name = "gas miner"
	desc = "Gasses mined from the gas giant below (above?) flow out through this massive vent."
	icon = 'icons/obj/atmospherics/components/miners.dmi'
	icon_state = "miner"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE|ACID_PROOF|FIRE_PROOF
	var/spawn_id = null
	var/spawn_temp = T20C
	var/spawn_mol = MOLES_CELLSTANDARD * 5
	var/max_ext_mol = INFINITY
	var/max_ext_kpa = 6500
	var/overlay_color = "#FFFFFF"
	var/active = FALSE
	var/power_draw = 4	//0 = none, 1 = static, 2 = scaled to mols, 3 = scaled to kpa, 4 = scaled to kpa+mol
	var/power_draw_static = 2000
	var/power_draw_dynamic_mol_coeff = 5
	var/power_draw_dynamic_kpa_coeff = 0.5
	var/broken = FALSE
	idle_power_usage = 150
	active_power_usage = 2000

/obj/machinery/atmospherics/miner/proc/check_operation()
	if(!active)
		return FALSE
	var/turf/T = get_turf(src)
	if(!isopen(T))
		return FALSE
	var/turf/open/OT = T
	if(OT.planetary_atmos)
		return FALSE
	var/datum/gas_mixture/G = OT.return_air()
	if(G.return_pressure() > (max_ext_kpa - ((spawn_mol*spawn_temp*R_IDEAL_GAS_EQUATION)/(CELL_VOLUME))))
		return FALSE
	if(G.total_moles() > max_ext_mol)
		return FALSE
	return TRUE

/obj/machinery/atmospherics/miner/proc/update_power()
	if(!check_operation())
		active_power_usage = idle_power_usage
		if(active)
			active = FALSE
		return FALSE
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/G = T.return_air()
	var/P = G.return_pressure()
	switch(power_draw)
		if(0)
			active_power_usage = 0
		if(1)
			active_power_usage = power_draw_static
		if(2)
			active_power_usage = spawn_mol * power_draw_dynamic_mol_coeff
		if(3)
			active_power_usage = P * power_draw_dynamic_kpa_coeff
		if(4)
			active_power_usage = (spawn_mol * power_draw_dynamic_mol_coeff) + (P * power_draw_dynamic_kpa_coeff)

/obj/machinery/atmospherics/miner/proc/do_use_power(amount)
	var/needed = amount
	var/turf/T = get_turf(src)
	if(T && istype(T))
		var/obj/structure/cable/C = T.get_cable_node() //check if we have a node cable on the machine turf, the first found is picked
		if(C && C.powernet)
			var/possible_draw = C.powernet.avail
			var/use = Clamp(possible_draw, 0, needed)
			C.powernet.load += use
			needed -= use
	if(!needed)
		return amount
	if(powered())
		use_power(needed)
		needed = 0
	return amount - needed

/obj/machinery/atmospherics/miner/update_icon()
	overlays.Cut()
	if(broken)
		var/image/A = image(icon, "broken")
		add_overlay(A)
	else if(active)
		var/image/A = image(icon, "on")
		A.color = overlay_color
		add_overlay(A)

/obj/machinery/atmospherics/miner/process()
	update_power()
	update_icon()
	if(active)
		if(isnull(spawn_id))
			return FALSE
		var/used = do_use_power(active_power_usage)
		var/coeff = used/active_power_usage
		mine_gas(coeff)

/obj/machinery/atmospherics/miner/proc/mine_gas(coeff)
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/ext_gas = T.return_air()
	var/datum/gas_mixture/merger = new
	merger.assert_gas(spawn_id)
	merger.gases[spawn_id][MOLES] = (spawn_mol * coeff)
	merger.temperature = spawn_temp
	ext_gas.merge(merger)

/obj/machinery/atmospherics/miner/n2o
	name = "\improper N2O Gas Miner"
	overlay_color = "#FFCCCC"
	spawn_id = "n2o"

/obj/machinery/atmospherics/miner/nitrogen
	name = "\improper N2 Gas Miner"
	overlay_color = "#CCFFCC"
	spawn_id = "n2"

/obj/machinery/atmospherics/miner/oxygen
	name = "\improper O2 Gas Miner"
	overlay_color = "#007FFF"
	spawn_id = "o2"

/obj/machinery/atmospherics/miner/toxins
	name = "\improper Plasma Gas Miner"
	overlay_color = "#FF0000"
	spawn_id = "plasma"

/obj/machinery/atmospherics/miner/carbon_dioxide
	name = "\improper CO2 Gas Miner"
	overlay_color = "#CDCDCD"
	spawn_id = "co2"

/obj/machinery/atmospherics/miner/bz
	name = "\improper BZ Gas Miner"
	overlay_color = "#FAFF00"
	spawn_id = "bz"

/obj/machinery/atmospherics/miner/freon
	name = "\improper Freon Gas Miner"
	overlay_color = "#00FFE5"
	spawn_id = "freon"

/obj/machinery/atmospherics/miner/volatile_fuel
	name = "\improper Volatile Fuel Gas Miner"
	overlay_color = "#564040"
	spawn_id = "v_fuel"

/obj/machinery/atmospherics/miner/agent_b
	name = "\improper Agent B Gas Miner"
	overlay_color = "#E81E24"
	spawn_id = "agent_b"

/obj/machinery/atmospherics/miner/water_vapor
	name = "\improper Water Vapor Gas Miner"
	overlay_color = "#99928E"
	spawn_id = "water_vapor"
