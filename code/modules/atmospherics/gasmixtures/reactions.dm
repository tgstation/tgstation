#define NO_REACTION	0
#define REACTING	1
//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_BURN_RATE_DELTA				9
#define PLASMA_UPPER_TEMPERATURE			1370+T0C
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10
#define FIRE_CARBON_ENERGY_RELEASED			100000	//Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED			3000000	//Amount of heat released per mole of burnt plasma into the tile
//General assmos defines.
#define WATER_VAPOR_FREEZE					200
#define NITRYL_FORMATION_ENERGY				100000
#define TRITIUM_BURN_OXY_FACTOR				100
#define TRITIUM_BURN_TRIT_FACTOR			10
#define SUPER_SATURATION_THRESHOLD			96
#define STIMULUM_HEAT_SCALE					100000
#define STIMULUM_FIRST_RISE					0.65
#define STIMULUM_FIRST_DROP					0.065
#define STIMULUM_SECOND_RISE				0.0009
#define STIMULUM_ABSOLUTE_DROP				0.00000335
#define REACTION_OPPRESSION_THRESHOLD		5
	//Plasma fusion properties
#define PLASMA_BINDING_ENERGY				3000000
#define MAX_CATALYST_EFFICENCY				9
#define PLASMA_FUSED_COEFFICENT				0.08
#define CATALYST_COEFFICENT					0.01
#define FUSION_PURITY_THRESHOLD				0.9
#define FUSION_HEAT_DROPOFF					20000+T0C
/datum/controller/subsystem/air/var/list/gas_reactions //this is our singleton of all reactions

/proc/init_gas_reactions()
	var/list/reaction_types = list()
	for(var/r in subtypesof(/datum/gas_reaction))
		var/datum/gas_reaction/reaction = r
		if(!initial(reaction.exclude))
			reaction_types += reaction
	reaction_types = sortList(reaction_types, /proc/cmp_gas_reactions)

	. = list()
	for(var/path in reaction_types)
		. += new path

/proc/cmp_gas_reactions(datum/gas_reaction/a, datum/gas_reaction/b) //sorts in descending order of priority
	return initial(b.priority) - initial(a.priority)

/datum/gas_reaction
	//regarding the requirements lists: the minimum or maximum requirements must be non-zero.
	//when in doubt, use MINIMUM_HEAT_CAPACITY.
	var/list/min_requirements
	var/list/max_requirements
	var/exclude = FALSE //do it this way to allow for addition/removal of reactions midmatch in the future
	var/priority = 100 //lower numbers are checked/react later than higher numbers. if two reactions have the same priority they may happen in either order
	var/name = "reaction"
	var/id = "r"

/datum/gas_reaction/New()
	init_reqs()

/datum/gas_reaction/proc/init_reqs()
/datum/gas_reaction/proc/react(datum/gas_mixture/air, atom/location)
	return NO_REACTION

/datum/gas_reaction/nobliumsupression
	priority = INFINITY
	name = "Hyper-Noblium Reaction Supression"
	id = "nobstop"
/datum/gas_reaction/nobliumsupression/init_reqs()
	min_requirements = list(/datum/gas/hypernoblium = REACTION_OPPRESSION_THRESHOLD)

/datum/gas_reaction/nobliumsupression/react()
	return STOP_REACTIONS

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list(/datum/gas/water_vapor = MOLES_GAS_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, turf/open/location)
	. = NO_REACTION
	if (air.temperature <= WATER_VAPOR_FREEZE)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.gases[/datum/gas/water_vapor][MOLES] -= MOLES_GAS_VISIBLE
		. = REACTING

//fire: combustion of plasma and volatile fuel (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/fire
	priority = -1 //fire should ALWAYS be last
	name = "Hydrocarbon Combustion"
	id = "fire"

/datum/gas_reaction/fire/init_reqs()
	min_requirements = list("TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST) //doesn't include plasma reqs b/c of other, rarer, burning gases.

/datum/gas_reaction/fire/react(datum/gas_mixture/air, turf/open/location)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results[id] = 0

	//General volatile gas burn
	if(cached_gases[/datum/gas/tritium] && cached_gases[/datum/gas/tritium][MOLES])
		var/burned_fuel
		if(!cached_gases[/datum/gas/oxygen])
			burned_fuel = 0
		else if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/tritium][MOLES])
			burned_fuel = cached_gases[/datum/gas/oxygen][MOLES]/TRITIUM_BURN_OXY_FACTOR
			cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel
		else
			burned_fuel = cached_gases[/datum/gas/tritium][MOLES]*TRITIUM_BURN_TRIT_FACTOR
			cached_gases[/datum/gas/tritium][MOLES] -= cached_gases[/datum/gas/tritium][MOLES]/TRITIUM_BURN_TRIT_FACTOR
			cached_gases[/datum/gas/oxygen][MOLES] -= cached_gases[/datum/gas/tritium][MOLES]

		if(burned_fuel)
			energy_released += FIRE_CARBON_ENERGY_RELEASED * burned_fuel

			ASSERT_GAS(/datum/gas/carbon_dioxide, air)
			cached_gases[/datum/gas/carbon_dioxide][MOLES] += burned_fuel/TRITIUM_BURN_OXY_FACTOR

			cached_results[id] += burned_fuel

	//Handle plasma burning
	if(cached_gases[/datum/gas/plasma] && cached_gases[/datum/gas/plasma][MOLES] > MINIMUM_HEAT_CAPACITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/temperature_scale
		var/super_saturation
		if(temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale > 0)
			var/o2 = cached_gases[/datum/gas/oxygen] ? cached_gases[/datum/gas/oxygen][MOLES] : 0
			oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
			if (o2 > cached_gases[/datum/gas/plasma][MOLES]*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
			if(o2 / cached_gases[/datum/gas/plasma][MOLES] > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
				super_saturation = TRUE
			if(o2 > cached_gases[/datum/gas/plasma][MOLES]*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (temperature_scale*(o2/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				ASSERT_GAS(/datum/gas/carbon_dioxide, air) //don't need to assert o2, since if it isn't present we'll never reach this point anyway
				cached_gases[/datum/gas/plasma][MOLES] = QUANTIZE(cached_gases[/datum/gas/plasma][MOLES] - plasma_burn_rate)
				cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (plasma_burn_rate * oxygen_burn_rate))
				if (super_saturation)
					ASSERT_GAS(/datum/gas/tritium,air)
					cached_gases[/datum/gas/tritium][MOLES] += plasma_burn_rate
				else
					ASSERT_GAS(/datum/gas/carbon_dioxide,air)
					cached_gases[/datum/gas/carbon_dioxide][MOLES] += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				cached_results[id] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature*old_heat_capacity + energy_released)/new_heat_capacity

	//let the floor know a fire is happening
	if(istype(location))
		temperature = air.temperature
		if(temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			location.hotspot_expose(temperature, CELL_VOLUME)
			for(var/I in location)
				var/atom/movable/item = I
				item.temperature_expose(air, temperature, CELL_VOLUME)
			location.temperature_expose(air, temperature, CELL_VOLUME)

	return cached_results[id] ? REACTING : NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting.
/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"ENER" = PLASMA_BINDING_ENERGY * 10,
		/datum/gas/plasma = MINIMUM_HEAT_CAPACITY,
		/datum/gas/tritium = MINIMUM_HEAT_CAPACITY
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	if(((cached_gases[/datum/gas/plasma][MOLES]+cached_gases[/datum/gas/tritium][MOLES])/air.total_moles() < FUSION_PURITY_THRESHOLD) || air.return_pressure() < 10*ONE_ATMOSPHERE)
		//Fusion wont occur if the level of impurities is too high or if there is too little pressure.
		return NO_REACTION

	var/old_heat_capacity = air.heat_capacity()
	var/catalyst_efficency = max(min(cached_gases[/datum/gas/plasma][MOLES]/cached_gases[/datum/gas/tritium][MOLES],MAX_CATALYST_EFFICENCY)-(temperature/FUSION_HEAT_DROPOFF),1)
	var/reaction_energy = THERMAL_ENERGY(air)
	var/moles_impurities = air.total_moles()-(cached_gases[/datum/gas/plasma][MOLES]+cached_gases[/datum/gas/tritium][MOLES])

	var/plasma_fused = (PLASMA_FUSED_COEFFICENT*catalyst_efficency)*(temperature/PLASMA_BINDING_ENERGY)*4
	var/tritium_catalyzed = (CATALYST_COEFFICENT*catalyst_efficency)*(temperature/PLASMA_BINDING_ENERGY)
	var/oxygen_added = tritium_catalyzed
	var/waste_added = (plasma_fused-oxygen_added)-((air.total_moles()*air.heat_capacity())/PLASMA_BINDING_ENERGY)
	reaction_energy = max(reaction_energy+((catalyst_efficency*cached_gases[/datum/gas/plasma][MOLES])/((moles_impurities/catalyst_efficency)+2)*10)+((plasma_fused/((moles_impurities/catalyst_efficency)))*PLASMA_BINDING_ENERGY),0)

	air.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/water_vapor, /datum/gas/nitrous_oxide, /datum/gas/nitryl)
	//Fusion produces an absurd amount of waste products now, requiring active filtration.
	cached_gases[/datum/gas/plasma][MOLES] = max(cached_gases[/datum/gas/plasma][MOLES] - plasma_fused,0)
	cached_gases[/datum/gas/tritium][MOLES] = max(cached_gases[/datum/gas/tritium][MOLES] - tritium_catalyzed,0)
	cached_gases[/datum/gas/oxygen][MOLES] += oxygen_added
	cached_gases[/datum/gas/nitrogen][MOLES] += waste_added
	cached_gases[/datum/gas/water_vapor][MOLES] += waste_added
	cached_gases[/datum/gas/nitrous_oxide][MOLES] += waste_added
	cached_gases[/datum/gas/nitryl][MOLES] += waste_added

	if(reaction_energy > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB)
			//Prevents whatever mechanism is causing it to hit negative temperatures.
		return REACTING

/datum/gas_reaction/nitrylformation //The formation of nitryl. Endothermic. Requires N2O as a catalyst.
	priority = 3
	name = "Nitryl formation"
	id = "nitrylformation"

/datum/gas_reaction/nitrylformation/init_reqs()
	min_requirements = list(
		/datum/gas/oxygen = 20,
		/datum/gas/nitrogen = 20,
		/datum/gas/nitrous_oxide = 5,
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST*400
	)

/datum/gas_reaction/nitrylformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	var/old_heat_capacity = air.heat_capacity()
	var/heat_efficency = temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*100)
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	ASSERT_GAS(/datum/gas/nitryl,air)

	cached_gases[/datum/gas/oxygen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitrogen][MOLES] -= heat_efficency
	cached_gases[/datum/gas/nitryl][MOLES] += heat_efficency*2

	if(energy_used > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity - energy_used)/new_heat_capacity),TCMB)
		return REACTING

/datum/gas_reaction/bzformation //Formation of BZ by combining plasma and tritium at low pressures. Exothermic.
	priority = 4
	name = "BZ Gas formation"
	id = "bzformation"

/datum/gas_reaction/bzformation/init_reqs()
	min_requirements = list(
		/datum/gas/tritium = 10,
		/datum/gas/plasma = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/pressure = air.return_pressure()

	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = 1/((pressure/(0.1*ONE_ATMOSPHERE))*(max(cached_gases[/datum/gas/plasma][MOLES]/cached_gases[/datum/gas/tritium][MOLES],1)))
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED

	ASSERT_GAS(/datum/gas/bz,air)
	cached_gases[/datum/gas/bz][MOLES]+= reaction_efficency
	cached_gases[/datum/gas/tritium][MOLES] = max(cached_gases[/datum/gas/tritium][MOLES]- 2*reaction_efficency,0)
	cached_gases[/datum/gas/plasma][MOLES] = max(cached_gases[/datum/gas/plasma][MOLES] - reaction_efficency,0)


	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity + energy_released)/new_heat_capacity),TCMB)
		return REACTING

/datum/gas_reaction/stimformation //Stimulum formation follows a strange pattern of how effective it will be at a given temperature, having some multiple peaks and some large dropoffs. Exo and endo thermic.
	priority = 5
	name = "Stimulum formation"
	id = "stimformation"
/datum/gas_reaction/stimformation/init_reqs()
	min_requirements = list(
		/datum/gas/tritium = 30,
		/datum/gas/plasma = 10,
		/datum/gas/bz = 20,
		/datum/gas/nitryl = 30,
		"TEMP" = STIMULUM_HEAT_SCALE/2)

/datum/gas_reaction/stimformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases

	var/old_heat_capacity = air.heat_capacity()
	var/heat_scale = air.temperature/STIMULUM_HEAT_SCALE
	var/stim_energy_change
	stim_energy_change =heat_scale + (STIMULUM_FIRST_RISE(heat_scale**2)) - (STIMULUM_FIRST_DROP(heat_scale**3)) + (STIMULUM_SECOND_RISE(heat_scale**4)) - (STIMULUM_ABSOLUTE_DROP(heat_scale**5))

	ASSERT_GAS(/datum/gas/stimulum,air)
	cached_gases[/datum/gas/stimulum][MOLES]+= heat_scale/10
	cached_gases[/datum/gas/tritium][MOLES] = max(cached_gases[/datum/gas/tritium][MOLES]- heat_scale,0)
	cached_gases[/datum/gas/plasma][MOLES] = max(cached_gases[/datum/gas/plasma][MOLES]- heat_scale,0)
	cached_gases[/datum/gas/nitryl][MOLES] = max(cached_gases[/datum/gas/nitryl][MOLES]- heat_scale,0)

	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB)
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Nobelium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
	priority = 6
	name = "Hyper-Noblium condensation"
	id = "nobformation"

/datum/gas_reaction/nobliumformation/init_reqs()
	min_requirements = list(
		/datum/gas/nitrogen = 10,
		/datum/gas/tritium = 5,
		"TEMP" = 5000000)

/datum/gas_reaction/nobliumformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	air.assert_gases(/datum/gas/hypernoblium,/datum/gas/bz)
	var/old_heat_capacity = air.heat_capacity()
	var/nob_formed = (cached_gases[/datum/gas/nitrogen][MOLES]*cached_gases[/datum/gas/tritium][MOLES])/100
	var/energy_taken = nob_formed*(10000000/(max(cached_gases[/datum/gas/bz][MOLES],1)))
	cached_gases[/datum/gas/tritium][MOLES] = max(cached_gases[/datum/gas/tritium][MOLES]- 10*nob_formed,0)
	cached_gases[/datum/gas/nitrogen][MOLES] = max(cached_gases[/datum/gas/nitrogen][MOLES]- 20*nob_formed,0)
	cached_gases[/datum/gas/hypernoblium][MOLES]+= nob_formed


	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature*old_heat_capacity - energy_taken)/new_heat_capacity),TCMB)
#undef REACTING
#undef NO_REACTION
#undef OXYGEN_BURN_RATE_BASE
#undef PLASMA_BURN_RATE_DELTA
#undef PLASMA_UPPER_TEMPERATURE
#undef PLASMA_MINIMUM_OXYGEN_NEEDED
#undef PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO
#undef PLASMA_OXYGEN_FULLBURN
#undef FIRE_CARBON_ENERGY_RELEASED
#undef FIRE_PLASMA_ENERGY_RELEASED
#undef WATER_VAPOR_FREEZE
#undef NITRYL_FORMATION_ENERGY
#undef TRITIUM_BURN_OXY_FACTOR
#undef SUPER_SATURATION_THRESHOLD
#undef STIMULUM_HEAT_SCALE
#undef STIMULUM_FIRST_RISE
#undef STIMULUM_FIRST_DROP
#undef STIMULUM_SECOND_RISE
#undef STIMULUM_ABSOLUTE_DROP
#undef REACTION_OPPRESSION_THRESHOLD
#undef PLASMA_BINDING_ENERGY
#undef MAX_CATALYST_EFFICENCY
#undef PLASMA_FUSED_COEFFICENT
#undef CATALYST_COEFFICENT
#undef FUSION_PURITY_THRESHOLD
#undef FUSION_HEAT_DROPOFF