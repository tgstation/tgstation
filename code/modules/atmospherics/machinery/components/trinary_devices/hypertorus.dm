///Max amount of radiation that can be emitted per reaction cycle
#define FUSION_RAD_MAX						5000
///Maximum instability before the reaction goes endothermic
#define FUSION_INSTABILITY_ENDOTHERMALITY   5
///Maximum reachable fusion temperature
#define FUSION_MAXIMUM_TEMPERATURE			1e30
///Speed of light, in m/s
#define LIGHT_SPEED 299792458
///Calculation between the plank constant and the lambda of the lightwave
#define PLANK_LIGHT_CONSTANT 2e-16
///Radius of the h2 calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_H2RADIUS 120e-4
///Radius of the trit calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_TRITRADIUS 230e-3
///Power conduction in the void, used to calculate the efficiency of the reaction
#define VOID_CONDUCTION 1e-2
///Max reaction point per reaction cycle
#define MAX_FUSION_RESEARCH 1000
///Min amount of allowed heat change
#define MIN_HEAT_VARIATION -1e5
///Max amount of allowed heat change
#define MAX_HEAT_VARIATION 1e5
///Max mole consumption per reaction cycle
#define MAX_FUEL_USAGE 5
///Mole count required (tritium/hydrogen) to start a fusion reaction
#define FUSION_MOLE_THRESHOLD				25
///Used to reduce the gas_power to a more useful amount
#define INSTABILITY_GAS_POWER_FACTOR 		0.003
///Used to calculate the toroidal_size for the instability
#define TOROID_VOLUME_BREAKEVEN			1000
///Constant used when calculating the chance of emitting a radioactive particle
#define PARTICLE_CHANCE_CONSTANT 			(-20000000)

/obj/machinery/atmospherics/components/unary/hypertorus
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	var/icon_state_open = "moderator_input"
	var/icon_state_off = "moderator_input"
	var/active = FALSE

/obj/machinery/atmospherics/components/unary/hypertorus/Initialize()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/hypertorus/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_off, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/hypertorus/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	if(!anchored)
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	name = "fuel_input"
	desc = "fuel_input"
	icon_state = "fuel_input"
	icon_state_open = "fuel_input"
	icon_state_off = "fuel_input"
	circuit = /obj/item/circuitboard/machine/hypertorus/fuel_input

/obj/machinery/atmospherics/components/unary/hypertorus/waste_output
	name = "waste_output"
	desc = "waste_output"
	icon_state = "waste_output"
	icon_state_open = "waste_output"
	icon_state_off = "waste_output"
	circuit = /obj/item/circuitboard/machine/hypertorus/waste_output

/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input
	name = "moderator_input"
	desc = "moderator_input"
	icon_state = "moderator_input"
	icon_state_open = "moderator_input"
	icon_state_off = "moderator_input"
	circuit = /obj/item/circuitboard/machine/hypertorus/moderator_input

/obj/machinery/hypertorus
	name = "hypertorus_core"
	desc = "hypertorus_core"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"
	move_resist = INFINITY
	anchored = FALSE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/thermomachine
	var/active = FALSE

/obj/machinery/hypertorus/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/machinery/hypertorus/wrench_act(mob/user, obj/item/I)
	. = ..()
	if(!active)
		anchored = !anchored
	else
		message_admins("Is active")

/obj/machinery/hypertorus/proc/check_part_connectivity()
	return TRUE

/obj/machinery/hypertorus/proc/activate()
	return

/obj/machinery/hypertorus/proc/deactivate()
	return

/obj/machinery/hypertorus/core
	name = "hypertorus_core"
	desc = "hypertorus_core"
	icon_state = "core"
	circuit = /obj/item/circuitboard/machine/hypertorus/core

	var/obj/machinery/hypertorus/interface/linked_interface
	var/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input/linked_moderator
	var/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input/linked_input
	var/obj/machinery/atmospherics/components/unary/hypertorus/waste_output/linked_output
	var/list/corners = list()
	var/datum/gas_mixture/internal_fusion
	var/datum/gas_mixture/internal_buffer
	var/datum/gas_mixture/internal_output
	var/gas_efficiency = 0.015

/obj/machinery/hypertorus/core/Initialize()
	. = ..()
	internal_fusion = new
	internal_buffer = new
	internal_output = new

/obj/machinery/hypertorus/core/check_part_connectivity()
	. = ..()
	if(!anchored)
		return FALSE

	for(var/obj/machinery/hypertorus/object in orange(1,src))
		if(. == FALSE)
			break

		if(!object.anchored)
			. = FALSE

		if(istype(object,/obj/machinery/hypertorus/corner))
			var/dir = get_dir(src,object)
			if(dir in GLOB.cardinals)
				. =  FALSE
			switch(dir)
				if(SOUTHEAST)
					if(object.dir != SOUTH)
						. = FALSE
				if(SOUTHWEST)
					if(object.dir != WEST)
						. =  FALSE
				if(NORTHEAST)
					if(object.dir != EAST)
						. =  FALSE
				if(NORTHWEST)
					if(object.dir != NORTH)
						. =  FALSE
			corners |= object
			continue

		if(get_step(object,turn(object.dir,180)) != loc)
			. =  FALSE

		if(istype(object,/obj/machinery/hypertorus/interface))
			if(linked_interface && linked_interface != object)
				. =  FALSE
			linked_interface = object

	for(var/obj/machinery/atmospherics/components/unary/hypertorus/object in orange(1,src))
		if(. == FALSE)
			break

		if(!object.anchored)
			. = FALSE

		if(get_step(object,turn(object.dir,180)) != loc)
			. =  FALSE

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input))
			if(linked_input && linked_input != object)
				. =  FALSE
			linked_input = object

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/waste_output))
			if(linked_output && linked_output != object)
				. =  FALSE
			linked_output = object

		if(istype(object,/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input))
			if(linked_moderator && linked_moderator != object)
				. =  FALSE
			linked_moderator = object

/obj/machinery/hypertorus/core/activate()
	if(!active)
		message_admins("YES")
		active = TRUE
		linked_interface.active = TRUE
		linked_input.active = TRUE
		linked_output.active = TRUE
		linked_moderator.active = TRUE
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.active = TRUE
	else
		message_admins("Already connected")

/obj/machinery/hypertorus/core/deactivate()
	if(active)
		message_admins("YES")
		active = FALSE
		if(linked_interface)
			linked_interface.active = FALSE
		if(linked_input)
			linked_input.active = FALSE
		if(linked_output)
			linked_output.active = FALSE
		if(linked_moderator)
			linked_moderator.active = FALSE
		if(corners.len)
			for(var/obj/machinery/hypertorus/corner/corner in corners)
				corner.active = FALSE
	else
		message_admins("Already connected")

/obj/machinery/hypertorus/core/process()
	. = ..()
	if(!active)
		return
	if(!check_part_connectivity())
		deactivate()
		return

	//Start by storing the gasmix of the inputs
	internal_buffer = linked_input.airs[1].remove(gas_efficiency * linked_input.airs[1])
	internal_fusion.merge(internal_buffer)
//	var/datum/gas_mixture/removed_buffer = linked_moderator.airs[1].remove(gas_efficiency * linked_moderator.airs[1])

	var/list/cached_scan_results = internal_fusion.analyzer_results

	///Store the temperature of the gases after one cicle of the fusion reaction
	var/archived_heat = internal_fusion.temperature
	///E=mc^2 with some addition to allow it gameplaywise
	var/energy = 0
	///Temperature of the center of the fusion reaction
	var/core_temperature = T20C
	/**Power emitted from the center of the fusion reaction: Internal power = densityH2 * densityTrit(Pi * (2 * rH2 * rTrit)**2) * Energy
	* density is calculated with moles/volume, rH2 and rTrit are values calculated with moles/(radius of the gas)
	both of the density can be varied by the power_modifier
	**/
	var/internal_power = 0
	/**The effective power transmission of the fusion reaction, power_output = efficiency * (internal_power - conduction - radiation)
	* Conduction is the heat value that is transmitted by the molecular interactions and it gets removed from the internal_power lowering the effective output
	* Radiation is the irradiation released by the fusion reaction, it comprehends all wavelenghts in the spectrum, it lowers the effective output of the reaction
	**/
	var/power_output = 0

	internal_fusion.assert_gases(/datum/gas/hydrogen, /datum/gas/tritium, /datum/gas/plasma, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/water_vapor, /datum/gas/bz, /datum/gas/freon)

	var/tritium = internal_fusion.gases[/datum/gas/tritium][MOLES]
	var/hydrogen = internal_fusion.gases[/datum/gas/hydrogen][MOLES]
	var/plasma = internal_fusion.gases[/datum/gas/plasma][MOLES]
	var/nitrogen = internal_fusion.gases[/datum/gas/nitrogen][MOLES]
	var/co2 = internal_fusion.gases[/datum/gas/carbon_dioxide][MOLES]
	var/h2o = internal_fusion.gases[/datum/gas/water_vapor][MOLES]
	var/bz= internal_fusion.gases[/datum/gas/bz][MOLES]
	var/freon = internal_fusion.gases[/datum/gas/freon][MOLES]

	///We scale it down by volume/2 because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/scale_factor = internal_fusion.volume * 0.5

	///Scaled down moles of gases, no less than 0
	var/scaled_tritium = max((tritium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_hydrogen = max((hydrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_plasma = max((plasma - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_nitrogen = max((nitrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_co2 = max((co2 - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_h2o = max((h2o - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_bz = max((bz - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_freon = max((freon - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	//This section is used for the instability calculation for the fusion reaction
	///The size of the phase space hypertorus
	var/toroidal_size = (2 * PI) + TORADIANS(arctan((internal_fusion.volume - TOROID_VOLUME_BREAKEVEN) / TOROID_VOLUME_BREAKEVEN))
	///Calculation of the gas power, only for theoretical instability calculations
	var/gas_power = 0
	for (var/gas_id in internal_fusion.gases)
		gas_power += (internal_fusion.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * internal_fusion.gases[gas_id][MOLES])

	///Instability effects how chaotic the behavior of the reaction is
	var/instability = MODULUS((gas_power * INSTABILITY_GAS_POWER_FACTOR)**2, toroidal_size)
	///Effective reaction instability
	var/internal_instability = 0
	if(instability * 0.5 < FUSION_INSTABILITY_ENDOTHERMALITY)
		internal_instability = 1
	else
		internal_instability = -1

	//here go the other gas interactions
	///Those are the scaled gases that gets consumed and releases energy
	var/positive_modifiers = scaled_hydrogen + scaled_tritium + scaled_nitrogen * 0.35 + scaled_co2 * 0.55 + scaled_bz * 1.15
	///Those are the scaled gases that gets produced and consumes energy
	var/negative_modifiers = scaled_plasma + scaled_h2o * 0.75 + scaled_freon * 1.15
	///Between 0.25 and 100, this value is used to modify the behaviour of the internal energy and the core temperature based on the gases present in the mix
	var/power_modifier = clamp(scaled_tritium * 1.05 + scaled_co2 * 0.95 + scaled_bz * 0.85 - scaled_plasma * 0.55 - scaled_freon * 0.75, 0.25, 100)
	///Minimum 0.25, this value is used to modify the behaviour of the energy emission based on the gases present in the mix
	var/heat_modifier = max(scaled_hydrogen * 1.15 + scaled_plasma * 1.05 - scaled_nitrogen * 0.75 - scaled_freon * 0.95, 0.25)
	///Between 0.005 and 1000, this value modify the radiation emission of the reaction, higher values increase the emission
	var/radiation_modifier = clamp(scaled_bz * 1.25 + scaled_plasma * 0.55 - scaled_freon * 1.15 - scaled_nitrogen * 0.45, 0.005, 1000)

	//upgrades vars are placeholders for gas interactions
	//Can go either positive or negative depending on the instability and the negative_modifiers
	energy += internal_instability * ((positive_modifiers - negative_modifiers) * LIGHT_SPEED ** 2) * max(internal_fusion.temperature / (max(100 / heat_modifier, 1)), 1)
	cached_scan_results["energy"] = energy
	internal_power = (scaled_hydrogen / max((100 / power_modifier), 1)) * (scaled_tritium / max((100 / power_modifier), 1)) * (PI * (2 * (scaled_hydrogen * CALCULATED_H2RADIUS) * (scaled_tritium * CALCULATED_TRITRADIUS))**2) * energy
	cached_scan_results["internal_power"] = internal_power
	core_temperature = internal_power / max((1000 / power_modifier), 1)
	core_temperature = max(TCMB, core_temperature)
	cached_scan_results["core_temperature"] = core_temperature
	///Difference between the gases temperature and the internal temperature of the reaction
	var/delta_temperature = archived_heat - core_temperature
	cached_scan_results["delta_temperature"] = delta_temperature
	///Energy from the reaction lost from the molecule colliding between themselves.
	var/conduction = - delta_temperature
	///The remaining wavelength that actually can do damage to mobs.
	var/radiation = max(- (PLANK_LIGHT_CONSTANT / (((0.0005) * 1e-14) / radiation_modifier)) * delta_temperature, 0)
	cached_scan_results["radiation"] = radiation
	///Efficiency of the reaction, it increases with the amount of plasma
	var/efficiency = VOID_CONDUCTION * clamp(scaled_plasma, 1, 100)
	power_output = efficiency * (internal_power - conduction - radiation)
	cached_scan_results["power_output"] = power_output
	///Hotter air is easier to heat up and cool down
	var/heat_limiter_modifier = internal_fusion.temperature
	///The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	var/heat_output = clamp(power_output / (max(100 / heat_modifier, 1)), MIN_HEAT_VARIATION - heat_limiter_modifier, MAX_HEAT_VARIATION + heat_limiter_modifier)
	cached_scan_results["heat_output"] = heat_output

	//better gas usage and consumption
	//To do
	internal_fusion.gases[/datum/gas/tritium][MOLES] -= clamp(heat_output / 45, 0.15, MAX_FUEL_USAGE) * 0.25
	internal_fusion.gases[/datum/gas/hydrogen][MOLES] -= clamp(heat_output / 50, 0.25, MAX_FUEL_USAGE) * 0.35
	internal_fusion.gases[/datum/gas/plasma][MOLES] += clamp(heat_output / 100, 0, MAX_FUEL_USAGE) * 0.5
	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	//This is an example, will be changed later
	if(power_output > 0)
		internal_fusion.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(heat_output / 10, 0, MAX_FUEL_USAGE) * 0.65
		internal_fusion.gases[/datum/gas/water_vapor][MOLES] += clamp(heat_output / 10, 0, MAX_FUEL_USAGE) * 0.25
	if(power_output < 0)
		internal_fusion.gases[/datum/gas/tritium][MOLES] -= 5
		internal_fusion.gases[/datum/gas/hydrogen][MOLES] -= 5

	//better heat and rads emission
	//To do
	if(power_output)
		var/particle_chance = max(((PARTICLE_CHANCE_CONSTANT)/(power_output-PARTICLE_CHANCE_CONSTANT)) + 1, 0)//Asymptopically approaches 100% as the energy of the reaction goes up.
		if(prob(PERCENT(particle_chance)))
			loc.fire_nuclear_particle()
		var/rad_power = clamp((radiation / 1e5), FUSION_RAD_MAX,0)
		radiation_pulse(loc, rad_power)

		if(internal_fusion.temperature <= FUSION_MAXIMUM_TEMPERATURE)
			internal_fusion.temperature = clamp(internal_fusion.temperature + heat_output,TCMB,INFINITY)
		if(core_temperature < internal_fusion.temperature && power_output < 0)
			internal_fusion.gases[/datum/gas/tritium][MOLES] -= 50
			internal_fusion.gases[/datum/gas/hydrogen][MOLES] -= 50

/obj/machinery/hypertorus/interface
	name = "hypertorus_interface"
	desc = "hypertorus_interface"
	icon_state = "interface"
	circuit = /obj/item/circuitboard/machine/hypertorus/interface
	var/obj/machinery/hypertorus/core/connected_core

/obj/machinery/hypertorus/interface/attack_hand(mob/living/user)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/hypertorus/core/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		message_admins("NOPE")
		return

	connected_core = centre

	connected_core.activate()


/obj/machinery/hypertorus/corner
	name = "hypertorus_corner"
	desc = "hypertorus_corner"
	icon_state = "corner"
	circuit = /obj/item/circuitboard/machine/hypertorus/corner
