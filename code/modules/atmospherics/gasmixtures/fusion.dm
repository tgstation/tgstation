//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//6 reworks

//Plasma fusion properties
#define FUSION_MOLE_THRESHOLD 250 	//Mole count required (tritium/plasma) to start a fusion reaction
#define FUSION_TRITIUM_CONVERSION_COEFFICIENT (1e-10)
#define INSTABILITY_GAS_POWER_FACTOR 0.003
#define FUSION_TRITIUM_MOLES_USED 1
#define PLASMA_BINDING_ENERGY 20000000
#define TOROID_VOLUME_BREAKEVEN 1000
#define FUSION_TEMPERATURE_THRESHOLD 9000
#define PARTICLE_CHANCE_CONSTANT (-20000000)
#define FUSION_INSTABILITY_ENDOTHERMALITY_2 2
#define FUSION_MAXIMUM_TEMPERATURE_2 1e8


/datum/gas_reaction/fusion
	name = "Plasmic Fusion"
	desc = "General fusion outside of the HFR"
	id = "fusion"

/datum/gas_reaction/fusion/init_factors()
	factor = list(
		/datum/gas/tritium = "Minimum of [FUSION_TRITIUM_MOLES_USED] mole to start. Main fuel of the reaction.",
		/datum/gas/plasma = "Minimum of [FUSION_MOLE_THRESHOLD] moles to start.",
		/datum/gas/hydrogen = "Minimum of [FUSION_MOLE_THRESHOLD] moles to start.",
		/datum/gas/bz = "Produced when endothermic.",
		/datum/gas/nitrium = "Produced when endothermic.",
		/datum/gas/water_vapor = "Produced when exothermic.",
		/datum/gas/carbon_dioxide = "Produced when exothermic.",
		"Temperature" = "Minimum temperature of [FUSION_TEMPERATURE_THRESHOLD] kelvin to occur.",
		"Energy" = "I don't fuckin know man this involves chaos theory, something something rotor. Can be exothermic or endothermic.",
		"Radiation" = "Yeah it gives out a lot of rads. Higher instability means higher rads."
	)

/datum/gas_reaction/fusion/init_reqs()
	requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD,
		/datum/gas/tritium = FUSION_TRITIUM_MOLES_USED,
		/datum/gas/plasma = FUSION_MOLE_THRESHOLD,
		/datum/gas/hydrogen = FUSION_MOLE_THRESHOLD
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/turf/open/location
	if (istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)
	var/old_heat_capacity = air.heat_capacity()
	var/reaction_energy = 0 //Reaction energy can be negative or positive, for both exothermic and endothermic reactions.
	var/initial_plasma = cached_gases[/datum/gas/plasma][MOLES]
	var/initial_hydrogen = cached_gases[/datum/gas/hydrogen][MOLES]
	var/scale_factor = (air.volume)/(PI) //We scale it down by volume/Pi because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/toroidal_size = (2 * PI) //The size of the phase space hypertorus
	var/gas_power = 0
	for (var/gas_id in cached_gases)
		gas_power += (cached_gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * cached_gases[gas_id][MOLES])
	var/instability = MODULUS((gas_power * INSTABILITY_GAS_POWER_FACTOR)**2, toroidal_size) //Instability effects how chaotic the behavior of the reaction is

	var/plasma = (initial_plasma-FUSION_MOLE_THRESHOLD)/(scale_factor) //We have to scale the amounts of hydrogen and plasma down a significant amount in order to show the chaotic dynamics we want
	var/hydrogen = (initial_hydrogen-FUSION_MOLE_THRESHOLD)/(scale_factor) //We also subtract out the threshold amount to make it harder for fusion to burn itself out.

	//The reaction is a specific form of the Kicked Rotator system, which displays chaotic behavior and can be used to model particle interactions.
	plasma = MODULUS(plasma - (instability * sin(TODEGREES(hydrogen))), toroidal_size)
	hydrogen = MODULUS(hydrogen - plasma, toroidal_size)


	cached_gases[/datum/gas/plasma][MOLES] = plasma * scale_factor + FUSION_MOLE_THRESHOLD //Scales the gases back up
	cached_gases[/datum/gas/hydrogen][MOLES] = hydrogen * scale_factor + FUSION_MOLE_THRESHOLD
	var/delta_plasma = initial_plasma - cached_gases[/datum/gas/plasma][MOLES]

	reaction_energy += delta_plasma * PLASMA_BINDING_ENERGY //Energy is gained or lost corresponding to the creation or destruction of mass.
	if(instability < FUSION_INSTABILITY_ENDOTHERMALITY_2)
		reaction_energy = max(reaction_energy, 0) //Stable reactions don't end up endothermic.
	else if (reaction_energy < 0)
		reaction_energy *= (instability-FUSION_INSTABILITY_ENDOTHERMALITY_2)**0.5

	if(air.thermal_energy() + reaction_energy < 0) //No using energy that doesn't exist.
		cached_gases[/datum/gas/plasma][MOLES] = initial_plasma
		cached_gases[/datum/gas/hydrogen][MOLES] = initial_hydrogen
		return NO_REACTION
	cached_gases[/datum/gas/tritium][MOLES] -= FUSION_TRITIUM_MOLES_USED
	//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
	if(reaction_energy > 0)
		air.assert_gases(/datum/gas/carbon_dioxide, /datum/gas/water_vapor)
		cached_gases[/datum/gas/carbon_dioxide][MOLES] += FUSION_TRITIUM_MOLES_USED * (reaction_energy * FUSION_TRITIUM_CONVERSION_COEFFICIENT)
		cached_gases[/datum/gas/water_vapor][MOLES] += (FUSION_TRITIUM_MOLES_USED * (reaction_energy * FUSION_TRITIUM_CONVERSION_COEFFICIENT)) * 0.25
	else
		air.assert_gases(/datum/gas/bz, /datum/gas/nitrium)
		cached_gases[/datum/gas/bz][MOLES] += FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT)
		cached_gases[/datum/gas/nitrium][MOLES] += FUSION_TRITIUM_MOLES_USED*(reaction_energy*-FUSION_TRITIUM_CONVERSION_COEFFICIENT)

	air.reaction_results[/datum/gas_reaction/fusion] = instability

	if(reaction_energy)
		if(location)
			var/particle_chance = ((PARTICLE_CHANCE_CONSTANT) / (reaction_energy - PARTICLE_CHANCE_CONSTANT)) + 1//Asymptopically approaches 100% as the energy of the reaction goes up.
			if(prob(PERCENT(particle_chance)))
				location.fire_nuclear_particle()
			var/rad_power = max(100 - (80 / instability), 0)
			radiation_pulse(
				location,
				max_range = rad_power * 15,
				threshold = 0.3,
				chance = rad_power * 100
			)

		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY && (air.temperature <= FUSION_MAXIMUM_TEMPERATURE_2 || reaction_energy <= 0))	//If above FUSION_MAXIMUM_TEMPERATURE, will only adjust temperature for endothermic reactions.
			air.temperature = clamp(((air.temperature * old_heat_capacity + reaction_energy) / new_heat_capacity), TCMB, INFINITY)
		return REACTING


#undef FUSION_MOLE_THRESHOLD
#undef FUSION_TRITIUM_CONVERSION_COEFFICIENT
#undef INSTABILITY_GAS_POWER_FACTOR
#undef FUSION_TRITIUM_MOLES_USED
#undef PLASMA_BINDING_ENERGY
#undef TOROID_VOLUME_BREAKEVEN
#undef FUSION_TEMPERATURE_THRESHOLD
#undef PARTICLE_CHANCE_CONSTANT
#undef FUSION_INSTABILITY_ENDOTHERMALITY_2
#undef FUSION_MAXIMUM_TEMPERATURE_2

/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "fusion test canister"
	desc = "Don't be a badmin."
	temp_limit = 1e12
	pressure_limit = 1e14

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.add_gases(/datum/gas/hydrogen, /datum/gas/tritium, /datum/gas/plasma)
	air_contents.gases[/datum/gas/hydrogen][MOLES] = 300
	air_contents.gases[/datum/gas/tritium][MOLES] = 300
	air_contents.gases[/datum/gas/plasma][MOLES] = 300
	air_contents.temperature = 10000
	SSair.start_processing_machine(src)
