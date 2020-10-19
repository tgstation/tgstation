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
#define MAX_MODERATOR_USAGE 20
///Mole count required (tritium/hydrogen) to start a fusion reaction
#define FUSION_MOLE_THRESHOLD				25
///Used to reduce the gas_power to a more useful amount
#define INSTABILITY_GAS_POWER_FACTOR 		0.003
///Used to calculate the toroidal_size for the instability
#define TOROID_VOLUME_BREAKEVEN			1000
///Constant used when calculating the chance of emitting a radioactive particle
#define PARTICLE_CHANCE_CONSTANT 			(-20000000)
///Conduction of heat
#define METALLIC_VOID_CONDUCTIVITY	0.05
///Sets the range of the hallucinations
#define HALLUCINATION_RANGE(P) (min(7, round(P ** 0.25)))

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

/obj/machinery/hypertorus/proc/activate()
	return

/obj/machinery/hypertorus/proc/deactivate()
	return

/obj/machinery/atmospherics/components/binary/hypertorus

/obj/machinery/atmospherics/components/binary/hypertorus/proc/check_part_connectivity()
	return TRUE

/obj/machinery/atmospherics/components/binary/hypertorus/core
	name = "hypertorus_core"
	desc = "hypertorus_core"
	icon = 'icons/obj/atmospherics/components/hypertorus.dmi'
	icon_state = "core"
	circuit = /obj/item/circuitboard/machine/hypertorus/core
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	density = TRUE

	///Checks if the machine state is active (all parts are connected)
	var/active = FALSE
	///Checks if the user has started the machine
	var/fusion_started = FALSE
	var/next_slowprocess = 0
	///Stores the informations of the interface machine
	var/obj/machinery/hypertorus/interface/linked_interface
	///Stores the information of the moderator input
	var/obj/machinery/atmospherics/components/unary/hypertorus/moderator_input/linked_moderator
	///Stores the information of the fuel input
	var/obj/machinery/atmospherics/components/unary/hypertorus/fuel_input/linked_input
	///Stores the information of the waste output
	var/obj/machinery/atmospherics/components/unary/hypertorus/waste_output/linked_output
	///Stores the information of the corners of the machine
	var/list/corners = list()
	///Stores the information of the fusion gasmix
	var/datum/gas_mixture/internal_fusion
	///Stores the information of the buffer gasmix (used to move gases around, may be removed)
	var/datum/gas_mixture/buffer
	///Stores the information of the output gasmix (used to move gases around, may be removed)
	var/datum/gas_mixture/internal_output
	///Stores the information of the moderators gasmix
	var/datum/gas_mixture/moderator_internal
	///Used to define the gas transfer between mixes
	var/gas_efficiency = 0.015
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
	///Instability effects how chaotic the behavior of the reaction is
	var/instability = 0
	///Amount of radiation that the machine can output
	var/rad_power = 0
	///Difference between the gases temperature and the internal temperature of the reaction
	var/delta_temperature = 0
	///Energy from the reaction lost from the molecule colliding between themselves.
	var/conduction = 0
	///The remaining wavelength that actually can do damage to mobs.
	var/radiation = 0
	///Efficiency of the reaction, it increases with the amount of plasma
	var/efficiency = 0
	///Hotter air is easier to heat up and cool down
	var/heat_limiter_modifier = 0
	///The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	var/heat_output = 0

	///Stores the moles of the gases (the ones with m_ are of the moderator mix)
	var/tritium = 0
	var/hydrogen = 0
	var/helium = 0

	var/m_plasma = 0
	var/m_nitrogen = 0
	var/m_co2 = 0
	var/m_h2o = 0
	var/m_freon = 0
	var/m_bz = 0
	var/m_proto_nitrate = 0
	var/m_antinoblium = 0
	var/m_hypernoblium = 0

	///Check if the user want to remove the waste gases
	var/waste_remove = FALSE
	///User controlled variable to control the flow of the fusion by changing the contact of the material
	var/heating_conductor = 1
	///User controlled variable to control the flow of the fusion by changing the volume of the gasmix by controlling the power of the magnetic fields
	var/magnetic_constrictor  = 1
	///User controlled variable to control the flow of the fusion by changing the instability of the reaction
	var/current_damper = 0
	///Stores the current fusion mix power level
	var/power_level = 0
	///Stores the iron content produced by the fusion
	var/iron_content = 0
	///User controlled variable to control the flow of the fusion by changing the amount of fuel injected
	var/fuel_injection_rate = 25
	///User controlled variable to control the flow of the fusion by changing the amount of moderators injected
	var/moderator_injection_rate = 25

/obj/machinery/atmospherics/components/binary/hypertorus/core/Initialize()
	. = ..()
	internal_fusion = new
	internal_fusion.assert_gases(/datum/gas/hydrogen, /datum/gas/tritium)
	buffer = new
	internal_output = new
	moderator_internal = new

/obj/machinery/atmospherics/components/binary/hypertorus/core/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/machinery/atmospherics/components/binary/hypertorus/core/SetInitDirections()
	switch(dir)
		if(SOUTH)
			initialize_directions = WEST|EAST
		if(NORTH)
			initialize_directions = EAST|WEST
		if(EAST)
			initialize_directions = SOUTH|NORTH
		if(WEST)
			initialize_directions = NORTH|SOUTH

/obj/machinery/atmospherics/components/binary/hypertorus/core/getNodeConnects()
	return list(turn(dir, 90), turn(dir, 270))

/obj/machinery/atmospherics/components/binary/hypertorus/core/can_be_node(obj/machinery/atmospherics/target)
	if(anchored)
		return ..(target)
	return FALSE

/obj/machinery/atmospherics/components/binary/hypertorus/core/wrench_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return
	set_anchored(!anchored)
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [anchored?"secure":"unsecure"] [src].</span>")


	var/obj/machinery/atmospherics/node1 = nodes[1]
	var/obj/machinery/atmospherics/node2 = nodes[2]

	if(node1)
		node1.disconnect(src)
		nodes[1] = null
		nullifyPipenet(parents[1])
	if(node2)
		node2.disconnect(src)
		nodes[2] = null
		nullifyPipenet(parents[2])

	if(anchored)
		SetInitDirections()
		atmosinit()
		node1 = nodes[1]
		if(node1)
			node1.atmosinit()
			node1.addMember(src)
		node2 = nodes[2]
		if(node2)
			node2.atmosinit()
			node2.addMember(src)
		SSair.add_to_rebuild_queue(src)

	return TRUE

/obj/machinery/atmospherics/components/binary/hypertorus/core/screwdriver_act(mob/user, obj/item/I)
	if(..())
		return TRUE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [panel_open?"open":"close"] the panel on [src].</span>")
	return TRUE

/obj/machinery/atmospherics/components/binary/hypertorus/core/check_part_connectivity()
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

/obj/machinery/atmospherics/components/binary/hypertorus/core/proc/activate()
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

/obj/machinery/atmospherics/components/binary/hypertorus/core/proc/deactivate()
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

/obj/machinery/atmospherics/components/binary/hypertorus/core/proc/check_fuel()
	if(internal_fusion.gases[/datum/gas/tritium][MOLES] > FUSION_MOLE_THRESHOLD && internal_fusion.gases[/datum/gas/hydrogen][MOLES] > FUSION_MOLE_THRESHOLD)
		return TRUE
	return FALSE

/obj/machinery/atmospherics/components/binary/hypertorus/core/process()
	if(next_slowprocess < world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS //Set to wait for another second before processing again, we don't need to process more than once a second

/obj/machinery/atmospherics/components/binary/hypertorus/core/proc/slowprocess()
//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again! Again but with machine!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//7 reworks
	/*
	 *Pre-checks
	 */
	//first check if the machine is active
	if(!active)
		return

	//then check if the other machines are still there
	if(!check_part_connectivity())
		deactivate()
		return

	//now check if the machine has been turned on by the user
	if(!fusion_started)
		return

	/*
	 *Storing variables such as gas mixes, temperature, volume, moles
	 */
	//Start by storing the gasmix of the inputs inside the internal_fusion and moderator_internal
	buffer = linked_input.airs[1].remove(fuel_injection_rate)
	internal_fusion.merge(buffer)
	buffer = linked_moderator.airs[1].remove(moderator_injection_rate)
	moderator_internal.merge(buffer)

	//Store the temperature of the gases after one cicle of the fusion reaction
	var/archived_heat = internal_fusion.temperature
	//Store the volume of the fusion reaction multiplied by the force of the magnets that controls how big it will be
	var/volume = internal_fusion.volume * magnetic_constrictor

	//Assert the gases that will be used/created during the process
	internal_fusion.assert_gases(/datum/gas/helium)
	moderator_internal.assert_gases(/datum/gas/plasma, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/water_vapor, /datum/gas/freon, /datum/gas/bz, /datum/gas/proto_nitrate, /datum/gas/hypernoblium, /datum/gas/antinoblium)

	//Store the fuel gases and the product gas moles
	tritium = internal_fusion.gases[/datum/gas/tritium][MOLES]
	hydrogen = internal_fusion.gases[/datum/gas/hydrogen][MOLES]
	helium = internal_fusion.gases[/datum/gas/helium][MOLES]

	//Store the moderators gases moles
	m_plasma = moderator_internal.gases[/datum/gas/plasma][MOLES]
	m_nitrogen = moderator_internal.gases[/datum/gas/nitrogen][MOLES]
	m_co2 = moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES]
	m_h2o = moderator_internal.gases[/datum/gas/water_vapor][MOLES]
	m_freon = moderator_internal.gases[/datum/gas/freon][MOLES]
	m_bz = moderator_internal.gases[/datum/gas/bz][MOLES]
	m_proto_nitrate = moderator_internal.gases[/datum/gas/proto_nitrate][MOLES]
	m_antinoblium = moderator_internal.gases[/datum/gas/antinoblium][MOLES]
	m_hypernoblium = moderator_internal.gases[/datum/gas/hypernoblium][MOLES]

	//We scale it down by volume/2 because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/scale_factor = volume * 0.5

	//Scaled down moles of gases, no less than 0
	var/scaled_tritium = max((tritium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_hydrogen = max((hydrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_helium = max((helium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	var/scaled_m_plasma = max((m_plasma - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_nitrogen = max((m_nitrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_co2 = max((m_co2 - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_h2o = max((m_h2o - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_freon = max((m_freon - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_bz = max((m_bz - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_proto_nitrate = max((m_proto_nitrate - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_antinoblium = max((m_antinoblium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_hypernoblium = max((m_hypernoblium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	/*
	 *FUSION MAIN PROCESS
	 */
	//This section is used for the instability calculation for the fusion reaction
	//The size of the phase space hypertorus
	var/toroidal_size = (2 * PI) + TORADIANS(arctan((volume - TOROID_VOLUME_BREAKEVEN) / TOROID_VOLUME_BREAKEVEN))
	//Calculation of the gas power, only for theoretical instability calculations
	var/gas_power = 0
	for (var/gas_id in internal_fusion.gases)
		gas_power += (internal_fusion.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * internal_fusion.gases[gas_id][MOLES])
	for (var/gas_id in moderator_internal.gases)
		gas_power += (moderator_internal.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * moderator_internal.gases[gas_id][MOLES] * 0.75)

	instability = MODULUS((gas_power * INSTABILITY_GAS_POWER_FACTOR)**2, toroidal_size) + current_damper + iron_content
	//Effective reaction instability (determines if the energy is used/released)
	var/internal_instability = 0
	if(instability * 0.5 < FUSION_INSTABILITY_ENDOTHERMALITY)
		internal_instability = 1
	else
		internal_instability = -1

	/*
	 *Modifiers
	 */
	///Those are the scaled gases that gets consumed and releases energy or help increase that energy
	var/positive_modifiers = scaled_hydrogen + scaled_tritium + scaled_m_nitrogen * 0.35 + scaled_m_co2 * 0.55 + scaled_m_antinoblium * 10 - scaled_m_hypernoblium * 10
	///Those are the scaled gases that gets produced and consumes energy or help decrease that energy
	var/negative_modifiers = scaled_helium + scaled_m_h2o * 0.75 + scaled_m_freon * 1.15 - scaled_m_antinoblium * 10
	///Between 0.25 and 100, this value is used to modify the behaviour of the internal energy and the core temperature based on the gases present in the mix
	var/power_modifier = clamp(scaled_tritium * 1.05 + scaled_m_co2 * 0.95 + scaled_m_plasma * 0.05 - scaled_helium * 0.55 - scaled_m_freon * 0.75, 0.25, 100)
	///Minimum 0.25, this value is used to modify the behaviour of the energy emission based on the gases present in the mix
	var/heat_modifier = max(scaled_hydrogen * 1.15 + scaled_helium * 1.05 + scaled_m_plasma * 1.25 - scaled_m_nitrogen * 0.75 - scaled_m_freon * 0.95, 0.25)
	///Between 0.005 and 1000, this value modify the radiation emission of the reaction, higher values increase the emission
	var/radiation_modifier = clamp(scaled_helium * 0.55 - scaled_m_freon * 1.15 - scaled_m_nitrogen * 0.45 - scaled_m_plasma * 0.95 + scaled_m_bz * 1.9 + scaled_m_proto_nitrate * 0.1 + scaled_m_antinoblium * 10, 0.005, 1000)

	/*
	 *Main calculations (energy, internal power, core temperature, delta temperature,
	 *conduction, radiation, efficiency, power output, heat limiter modifier and heat output)
	 */
	//Can go either positive or negative depending on the instability and the negative_modifiers
	//E=mc^2 with some changes for gameplay purposes
	energy += internal_instability * ((positive_modifiers - negative_modifiers) * LIGHT_SPEED ** 2) * max(internal_fusion.temperature / (max(100 / heat_modifier, 1)), 1)
	//Power of the gas mixture
	internal_power = (scaled_hydrogen / max((100 / power_modifier), 1)) * (scaled_tritium / max((100 / power_modifier), 1)) * (PI * (2 * (scaled_hydrogen * CALCULATED_H2RADIUS) * (scaled_tritium * CALCULATED_TRITRADIUS))**2) * energy
	//Temperature inside the center of the gas mixture
	core_temperature = internal_power / max((1000 / power_modifier), 1)
	core_temperature = max(TCMB, core_temperature)
	//Difference between the gases temperature and the internal temperature of the reaction
	delta_temperature = archived_heat - core_temperature
	//Energy from the reaction lost from the molecule colliding between themselves.
	conduction = - delta_temperature
	//The remaining wavelength that actually can do damage to mobs.
	radiation = max(- (PLANK_LIGHT_CONSTANT / (((0.0005) * 1e-14) / radiation_modifier)) * delta_temperature, 0)
	//Efficiency of the reaction, it increases with the amount of helium
	efficiency = VOID_CONDUCTION * clamp(scaled_helium, 1, 100)
	power_output = efficiency * (internal_power - conduction - radiation)
	//Hotter air is easier to heat up and cool down
	heat_limiter_modifier = internal_fusion.temperature / (internal_fusion.heat_capacity() / internal_fusion.total_moles()) * heating_conductor
	//The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	heat_output = clamp(power_output / (max(100 / heat_modifier, 1)), MIN_HEAT_VARIATION - heat_limiter_modifier, MAX_HEAT_VARIATION + heat_limiter_modifier)

	//Modifies the internal_fusion temperature with the amount of heat output
	if(internal_fusion.temperature <= FUSION_MAXIMUM_TEMPERATURE)
		internal_fusion.temperature = clamp(internal_fusion.temperature + heat_output,TCMB,INFINITY)

	//Modifies the moderator_internal temperature based on energy conduction (could be made better)
	var/internal_heat_capacity = internal_fusion.heat_capacity() ? internal_fusion.heat_capacity() : 1
	moderator_internal.temperature += METALLIC_VOID_CONDUCTIVITY * ((internal_fusion.temperature / internal_heat_capacity) * moderator_internal.heat_capacity())

	//Set the power level of the fusion process
	var/fusion_temperature = internal_fusion.temperature
	switch(fusion_temperature) //need to find a better way
		if(-INFINITY to 100000)
			power_level = 0
		if(100000 to 1e6)
			power_level = 1
		if(1e6 to 1e8)
			power_level = 2
		if(1e8 to 1e10)
			power_level = 3
		if(1e10 to 1e13)
			power_level = 4
		if(1e13 to 1e16)
			power_level = 5
		else
			power_level = 6

	//better gas usage and consumption
	//To do
	if(check_fuel())
		internal_fusion.gases[/datum/gas/tritium][MOLES] -= min(tritium, clamp(5 * power_level, 5, max(5, fuel_injection_rate - MAX_MODERATOR_USAGE)) * 0.5)
		internal_fusion.gases[/datum/gas/hydrogen][MOLES] -= min(hydrogen, clamp(10 * power_level, 10, max(5, fuel_injection_rate - MAX_MODERATOR_USAGE)) * 0.75)
		internal_fusion.gases[/datum/gas/helium][MOLES] += clamp(5 * power_level, 0, (fuel_injection_rate - MAX_MODERATOR_USAGE) / 2)
		//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
		//Also dependant on what is the power level and what moderator gases are present
		if(power_output)
			switch(power_level)
				if(1)
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(heat_output / 1e5, 0, MAX_MODERATOR_USAGE) * 0.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += clamp(heat_output / 4e5, 0, MAX_MODERATOR_USAGE)
				if(2)
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(heat_output / 1e7, 0, MAX_MODERATOR_USAGE) * 0.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += clamp(heat_output / 4e7, 0, MAX_MODERATOR_USAGE)
					if(m_plasma)
						internal_output.assert_gases(/datum/gas/bz)
						internal_output.gases[/datum/gas/bz][MOLES] += clamp(heat_output / 2e7, 0, MAX_MODERATOR_USAGE)
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], clamp(heat_output / 5e7, 0, MAX_MODERATOR_USAGE) * 0.45)
					if(m_proto_nitrate)
						radiation *= 1.55
						heat_output *= 1.025
						moderator_internal.gases[/datum/gas/plasma][MOLES] += clamp(heat_output / 5e7, 0, MAX_MODERATOR_USAGE) * 0.45
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], clamp(heat_output / 5e7, 0, MAX_MODERATOR_USAGE) * 0.35)
				if(3, 4)
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(heat_output / 1e10, 0, MAX_MODERATOR_USAGE) * 0.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += clamp(heat_output / 4e10, 0, MAX_MODERATOR_USAGE)
					if(m_plasma)
						moderator_internal.gases[/datum/gas/bz][MOLES] += clamp(heat_output / 2e10, 0, MAX_MODERATOR_USAGE)
						internal_output.assert_gases(/datum/gas/freon)
						internal_output.gases[/datum/gas/freon][MOLES] += clamp(heat_output / 5e10, 0, MAX_MODERATOR_USAGE)
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], clamp(heat_output / 5e10, 0, MAX_MODERATOR_USAGE) * 0.45)
					if(m_freon > 50)
						heat_output *= 0.9
						radiation *= 0.8
					if(m_proto_nitrate)
						internal_output.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
						internal_output.gases[/datum/gas/oxygen][MOLES] += clamp(heat_output / 4e10, 0, MAX_MODERATOR_USAGE) * 0.5
						internal_output.gases[/datum/gas/nitrogen][MOLES] += clamp(heat_output / 5e10, 0, MAX_MODERATOR_USAGE)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], clamp(heat_output / 6e10, 0, MAX_MODERATOR_USAGE) * 0.35)
						radiation *= 1.95
						heat_output *= 1.25
					if(m_bz > 100)
						internal_output.assert_gases(/datum/gas/healium, /datum/gas/proto_nitrate)
						internal_output.gases[/datum/gas/proto_nitrate][MOLES] += clamp(heat_output / 4e10, 0, MAX_MODERATOR_USAGE) * 0.5
						internal_output.gases[/datum/gas/healium][MOLES] += clamp(heat_output / 3e10, 0, MAX_MODERATOR_USAGE)
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_RANGE(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 50 * D
								l.hallucination = clamp(l.hallucination, 0, 200)
				if(5)
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(heat_output / 1e15, 0, MAX_MODERATOR_USAGE) * 0.65
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += clamp(heat_output / 4e15, 0, MAX_MODERATOR_USAGE)
					if(m_plasma)
						moderator_internal.gases[/datum/gas/bz][MOLES] += clamp(heat_output / 5e15, 0, MAX_MODERATOR_USAGE)
						internal_output.assert_gases(/datum/gas/freon)
						internal_output.gases[/datum/gas/freon][MOLES] += clamp(heat_output / 1e15, 0, MAX_MODERATOR_USAGE)
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], clamp(heat_output / 5e15, 0, MAX_MODERATOR_USAGE) * 0.45)
					if(m_freon > 500)
						heat_output *= 0.5
						radiation *= 0.2
					if(m_proto_nitrate)
						internal_output.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
						internal_output.gases[/datum/gas/oxygen][MOLES] += clamp(heat_output / 7e15, 0, MAX_MODERATOR_USAGE) * 0.5
						internal_output.gases[/datum/gas/nitrogen][MOLES] += clamp(heat_output / 2e15, 0, MAX_MODERATOR_USAGE)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], clamp(heat_output / 5e15, 0, MAX_MODERATOR_USAGE) * 0.35)
						radiation *= 1.95
						heat_output *= 1.25
					if(m_bz)
						internal_output.assert_gases(/datum/gas/healium)
						internal_output.gases[/datum/gas/healium][MOLES] += clamp(heat_output / 1e15, 0, MAX_MODERATOR_USAGE)
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_RANGE(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 100 * D
								l.hallucination = clamp(l.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] += clamp(heat_output / 3e15, 0, MAX_MODERATOR_USAGE) * 0.25
						moderator_internal.gases[/datum/gas/freon][MOLES] += clamp(heat_output / 1e15, 0, MAX_MODERATOR_USAGE) * 0.15
					if(moderator_internal.temperature < 10000)
						internal_output.assert_gases(/datum/gas/antinoblium)
						internal_output.gases[/datum/gas/antinoblium][MOLES] += 0.01 * (scaled_helium / (fuel_injection_rate / 15))
				if(6)
					if(m_plasma > 30)
						moderator_internal.gases[/datum/gas/bz][MOLES] += clamp(heat_output / 5e19, 0, MAX_MODERATOR_USAGE) * 0.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], clamp(heat_output / 5e19, 0, MAX_MODERATOR_USAGE) * 0.45)
					if(m_proto_nitrate)
						internal_output.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
						internal_output.gases[/datum/gas/oxygen][MOLES] += clamp(heat_output / 4e19, 0, MAX_MODERATOR_USAGE) * 0.5
						internal_output.gases[/datum/gas/nitrogen][MOLES] += clamp(heat_output / 3e19, 0, MAX_MODERATOR_USAGE)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], clamp(heat_output / 5e19, 0, MAX_MODERATOR_USAGE) * 0.35)
						radiation *= 2
						heat_output *= 2.25
					if(m_bz)
						internal_output.assert_gases(/datum/gas/healium)
						internal_output.gases[/datum/gas/healium][MOLES] += clamp(heat_output / 1e19, 0, MAX_MODERATOR_USAGE)
						for(var/mob/living/carbon/human/human in view(src, HALLUCINATION_RANGE(heat_output)))
							var/distance_root = sqrt(1 / max(1, get_dist(human, src)))
							human.hallucination += power_level * 150 * distance_root
							human.hallucination = clamp(human.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] += clamp(heat_output / 6e19, 0, MAX_MODERATOR_USAGE) * 0.25
						moderator_internal.gases[/datum/gas/freon][MOLES] += clamp(heat_output / 1e21, 0, MAX_MODERATOR_USAGE) * 0.15
						moderator_internal.gases[/datum/gas/antinoblium][MOLES] += clamp(0.01 * (scaled_helium / (fuel_injection_rate / 15)), 0, 5)
					if(moderator_internal.temperature < 1e6)
						moderator_internal.gases[/datum/gas/antinoblium][MOLES] += 0.01 * (scaled_helium / (fuel_injection_rate / 15))

	//Output what's in the internal_output into the linked_output port
	linked_output.airs[1].merge(internal_output)

	//High power fusion might create other matter other than helium, iron is dangerous inside the machine, damage can be seen (to do)
	if(moderator_internal.total_moles())
		moderator_internal.remove(moderator_internal.total_moles() * 0.015)
		if(power_level > 5 && prob(17 * power_level))//at power level 6 is 100%
			iron_content += 0.05

	//Waste gas can be remove by the interface, can spill if temperature is too high (to do)
	if(waste_remove)
		var/datum/gas_mixture/internal_remove
		internal_remove = internal_fusion.remove_specific(/datum/gas/helium, internal_fusion.gases[/datum/gas/helium][MOLES] * 0.5)
		internal_fusion.garbage_collect()
		linked_output.airs[1].merge(internal_remove)

	//Cooling of the moderator gases with the cooling loop in and out the core (should make it cool the internal fusion mix too)
	if(airs[1].total_moles() > 0)
		var/datum/gas_mixture/cooling_in = airs[1]
		var/datum/gas_mixture/cooling_out = airs[2]
		var/datum/gas_mixture/cooling_remove = cooling_in.remove(0.5 * cooling_in.total_moles())
		var/cooling_heat_capacity = cooling_remove.heat_capacity()
		var/moderator_heat_capacity = moderator_internal.heat_capacity()
		var/combined_heat_capacity = cooling_heat_capacity + moderator_heat_capacity
		var/old_cooling_temperature = cooling_remove.temperature
		var/old_moderator_temperature = moderator_internal.temperature
		if(combined_heat_capacity > 0)
			var/combined_energy = old_cooling_temperature * cooling_heat_capacity + moderator_heat_capacity * old_moderator_temperature
			var/new_temperature = combined_energy/combined_heat_capacity
			cooling_remove.temperature = new_temperature
			moderator_internal.temperature = new_temperature

		cooling_out.merge(cooling_remove) //AHHHH WHY YOU DON'T WORK

	//Update pipenets
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

	//better heat and rads emission
	//To do
	if(power_output)
		var/particle_chance = max(((PARTICLE_CHANCE_CONSTANT)/(power_output-PARTICLE_CHANCE_CONSTANT)) + 1, 0)//Asymptopically approaches 100% as the energy of the reaction goes up.
		if(prob(PERCENT(particle_chance)))
			loc.fire_nuclear_particle()
		rad_power = clamp((radiation / 1e5), FUSION_RAD_MAX,0)
		radiation_pulse(loc, rad_power)

/obj/machinery/hypertorus/interface
	name = "hypertorus_interface"
	desc = "hypertorus_interface"
	icon_state = "interface"
	circuit = /obj/item/circuitboard/machine/hypertorus/interface
	var/obj/machinery/atmospherics/components/binary/hypertorus/core/connected_core

/obj/machinery/hypertorus/interface/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/turf/T = get_step(src,turn(dir,180))
	var/obj/machinery/atmospherics/components/binary/hypertorus/core/centre = locate() in T

	if(!centre || !centre.check_part_connectivity())
		message_admins("NOPE")
		return FALSE

	connected_core = centre

	connected_core.activate()
	return TRUE

/obj/machinery/hypertorus/interface/attack_hand(mob/living/user)
	. = ..()
	message_admins("energy [connected_core.energy]")
	message_admins("core_temperature [connected_core.core_temperature]")
	message_admins("internal_power [connected_core.internal_power]")
	message_admins("power_output [connected_core.power_output]")
	message_admins("instability [connected_core.instability]")
	message_admins("rad_power [connected_core.rad_power]")
	message_admins("delta_temperature [connected_core.delta_temperature]")
	message_admins("conduction [connected_core.conduction]")
	message_admins("radiation [connected_core.radiation]")
	message_admins("efficiency [connected_core.efficiency]")
	message_admins("heat_limiter_modifier [connected_core.heat_limiter_modifier]")
	message_admins("heat_output [connected_core.heat_output]")

/obj/machinery/hypertorus/interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Hypertorus", name)
		ui.open()

/obj/machinery/hypertorus/interface/ui_data()
	var/data = list()
	//Internal Fusion gases
	var/list/fusion_gasdata = list()
	if(connected_core.internal_fusion.total_moles())
		for(var/gasid in connected_core.internal_fusion.gases)
			fusion_gasdata.Add(list(list(
			"name"= connected_core.internal_fusion.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(connected_core.internal_fusion.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in connected_core.internal_fusion.gases)
			fusion_gasdata.Add(list(list(
				"name"= connected_core.internal_fusion.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0,
				)))
	//Moderator gases
	var/list/moderator_gasdata = list()
	if(connected_core.moderator_internal.total_moles())
		for(var/gasid in connected_core.moderator_internal.gases)
			moderator_gasdata.Add(list(list(
			"name"= connected_core.moderator_internal.gases[gasid][GAS_META][META_GAS_NAME],
			"amount" = round(connected_core.moderator_internal.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in connected_core.moderator_internal.gases)
			moderator_gasdata.Add(list(list(
				"name"= connected_core.moderator_internal.gases[gasid][GAS_META][META_GAS_NAME],
				"amount" = 0,
				)))

	data["fusion_gases"] = fusion_gasdata
	data["moderator_gases"] = moderator_gasdata

	data["energy_level"] = connected_core.energy
	data["core_temperature"] = connected_core.core_temperature
	data["internal_power"] = connected_core.internal_power
	data["power_output"] = connected_core.power_output
	data["heat_limiter_modifier"] = connected_core.heat_limiter_modifier
	data["heat_output"] = connected_core.heat_output

	data["heating_conductor"] = connected_core.heating_conductor
	data["magnetic_constrictor"] = connected_core.magnetic_constrictor
	data["fuel_injection_rate"] = connected_core.fuel_injection_rate
	data["moderator_injection_rate"] = connected_core.moderator_injection_rate
	data["current_damper"] = connected_core.current_damper
	data["fusion_started"] = connected_core.fusion_started

	return data

/obj/machinery/hypertorus/interface/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("fusion_started")
			connected_core.fusion_started = !connected_core.fusion_started
			. = TRUE
		if("heating_conductor")
			var/heating_conductor = params["heating_conductor"]
			if(text2num(heating_conductor) != null)
				heating_conductor = text2num(heating_conductor)
				. = TRUE
			if(.)
				connected_core.heating_conductor = clamp(0.5, heating_conductor, 10)
		if("magnetic_constrictor")
			var/magnetic_constrictor = params["magnetic_constrictor"]
			if(text2num(magnetic_constrictor) != null)
				magnetic_constrictor = text2num(magnetic_constrictor)
				. = TRUE
			if(.)
				connected_core.magnetic_constrictor = clamp(0.5, magnetic_constrictor, 10)
		if("fuel_injection_rate")
			var/fuel_injection_rate = params["fuel_injection_rate"]
			if(text2num(fuel_injection_rate) != null)
				fuel_injection_rate = text2num(fuel_injection_rate)
				. = TRUE
			if(.)
				connected_core.fuel_injection_rate = clamp(0.5, fuel_injection_rate, 150)
		if("moderator_injection_rate")
			var/moderator_injection_rate = params["moderator_injection_rate"]
			if(text2num(moderator_injection_rate) != null)
				moderator_injection_rate = text2num(moderator_injection_rate)
				. = TRUE
			if(.)
				connected_core.moderator_injection_rate = clamp(0.5, moderator_injection_rate, 150)
		if("current_damper")
			var/current_damper = params["current_damper"]
			if(text2num(current_damper) != null)
				current_damper = text2num(current_damper)
				. = TRUE
			if(.)
				connected_core.current_damper = clamp(0, current_damper, 10)

/obj/machinery/hypertorus/corner
	name = "hypertorus_corner"
	desc = "hypertorus_corner"
	icon_state = "corner"
	circuit = /obj/item/circuitboard/machine/hypertorus/corner

#undef HALLUCINATION_RANGE
