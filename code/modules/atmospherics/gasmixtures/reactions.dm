#define NO_REACTION	0
#define REACTING	1

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

//agent b: converts hot co2 and agent b to oxygen. requires plasma as a catalyst. endothermic
/datum/gas_reaction/agent_b
	priority = 2
	name = "Agent B"
	id = "agent_b"

/datum/gas_reaction/agent_b/init_reqs()
	min_requirements = list(
		"TEMP" = 900,
		"agent_b" = MINIMUM_HEAT_CAPACITY,
		"plasma" = MINIMUM_HEAT_CAPACITY,
		"co2" = MINIMUM_HEAT_CAPACITY
	)


/datum/gas_reaction/agent_b/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/reaction_rate = min(cached_gases["co2"][MOLES]*0.75, cached_gases["plasma"][MOLES]*0.25, cached_gases["agent_b"][MOLES]*0.05)

	cached_gases["co2"][MOLES] -= reaction_rate
	cached_gases["agent_b"][MOLES] -= reaction_rate*0.05

	air.assert_gas("o2") //only need to assert oxygen, as this reaction doesn't occur without the other gases existing
	cached_gases["o2"][MOLES] += reaction_rate

	air.temperature -= (reaction_rate*20000)/air.heat_capacity()

	return REACTING

//freon: does a freezy thing?
/datum/gas_reaction/freon
	priority = 1
	name = "Freon"
	id = "freon"

/datum/gas_reaction/freon/init_reqs()
	min_requirements = list("freon" = MOLES_PLASMA_VISIBLE)

/datum/gas_reaction/freon/react(datum/gas_mixture/air, turf/open/location)
	. = NO_REACTION
	if(location && location.freon_gas_act())
		. = REACTING

//water vapor: puts out fires?
/datum/gas_reaction/water_vapor
	priority = 1
	name = "Water Vapor"
	id = "vapor"

/datum/gas_reaction/water_vapor/init_reqs()
	min_requirements = list("water_vapor" = MOLES_PLASMA_VISIBLE)

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, turf/open/location)
	. = NO_REACTION
	if(location && location.water_vapor_gas_act())
		air.gases["water_vapor"][MOLES] -= MOLES_PLASMA_VISIBLE
		. = REACTING

//fire: combustion of plasma and volatile fuel (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/fire
	priority = -1 //fire should ALWAYS be last
	name = "Hydrocarbon Combustion"
	id = "fire"

/datum/gas_reaction/fire/init_reqs()
	min_requirements = list("TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST) //doesn't include plasma reqs b/c of volatile fuel stuff - consider finally axing volatile fuel

/datum/gas_reaction/fire/react(datum/gas_mixture/air, turf/open/location)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results

	//to_chat(world, "pre [temperature], [cached_gases["o2"][MOLES]], [cached_gases["plasma"][MOLES]]")
	cached_results[id] = 0

	//General volatile gas burn
	if(cached_gases["v_fuel"] && cached_gases["v_fuel"][MOLES])
		var/burned_fuel
		if(!cached_gases["o2"])
			burned_fuel = 0
		else if(cached_gases["o2"][MOLES] < cached_gases["v_fuel"][MOLES])
			burned_fuel = cached_gases["o2"][MOLES]
			cached_gases["v_fuel"][MOLES] -= burned_fuel
			cached_gases["o2"][MOLES] = 0
		else
			burned_fuel = cached_gases["v_fuel"][MOLES]
			cached_gases["o2"][MOLES] -= cached_gases["v_fuel"][MOLES]

		if(burned_fuel)
			energy_released += FIRE_CARBON_ENERGY_RELEASED * burned_fuel

			air.assert_gas("co2")
			cached_gases["co2"][MOLES] += burned_fuel

			cached_results[id] += burned_fuel

	//Handle plasma burning
	if(cached_gases["plasma"] && cached_gases["plasma"][MOLES] > MINIMUM_HEAT_CAPACITY)
		var/plasma_burn_rate = 0
		var/oxygen_burn_rate = 0
		//more plasma released at higher temperatures
		var/temperature_scale
		if(temperature > PLASMA_UPPER_TEMPERATURE)
			temperature_scale = 1
		else
			temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
		if(temperature_scale > 0)
			air.assert_gas("o2")
			oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
			if(cached_gases["o2"][MOLES] > cached_gases["plasma"][MOLES]*PLASMA_OXYGEN_FULLBURN)
				plasma_burn_rate = (cached_gases["plasma"][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
			else
				plasma_burn_rate = (temperature_scale*(cached_gases["o2"][MOLES]/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA
			if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
				air.assert_gas("co2")
				cached_gases["plasma"][MOLES] = QUANTIZE(cached_gases["plasma"][MOLES] - plasma_burn_rate)
				cached_gases["o2"][MOLES] = QUANTIZE(cached_gases["o2"][MOLES] - (plasma_burn_rate * oxygen_burn_rate))
				cached_gases["co2"][MOLES] += plasma_burn_rate

				energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

				cached_results[id] += (plasma_burn_rate)*(1+oxygen_burn_rate)

	if(energy_released > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = (temperature*old_heat_capacity + energy_released)/new_heat_capacity

	//to_chat(world, "post [temperature], [cached_gases["o2"][MOLES]], [cached_gases["plasma"][MOLES]]")

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

//fusion: a terrible idea that was fun to try. turns co2 and plasma into REALLY HOT oxygen and nitrogen. super exothermic lol
/datum/gas_reaction/fusion
	exclude = TRUE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"ENER" = PLASMA_BINDING_ENERGY * 10,
		"plasma" = MINIMUM_HEAT_CAPACITY,
		"co2" = MINIMUM_HEAT_CAPACITY
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature

	if((cached_gases["plasma"][MOLES]+cached_gases["co2"][MOLES])/air.total_moles() < FUSION_PURITY_THRESHOLD)
		//Fusion wont occur if the level of impurities is too high.
		return NO_REACTION

	//to_chat(world, "pre [temperature, [cached_gases["plasma"][MOLES]], [cached_gases["co2"][MOLES]])
	var/old_heat_capacity = air.heat_capacity()
	var/carbon_efficency = min(cached_gases["plasma"][MOLES]/cached_gases["co2"][MOLES],MAX_CARBON_EFFICENCY)
	var/reaction_energy = air.thermal_energy()
	var/moles_impurities = air.total_moles()-(cached_gases["plasma"][MOLES]+cached_gases["co2"][MOLES])

	var/plasma_fused = (PLASMA_FUSED_COEFFICENT*carbon_efficency)*(temperature/PLASMA_BINDING_ENERGY)
	var/carbon_catalyzed = (CARBON_CATALYST_COEFFICENT*carbon_efficency)*(temperature/PLASMA_BINDING_ENERGY)
	var/oxygen_added = carbon_catalyzed
	var/nitrogen_added = (plasma_fused-oxygen_added)-(air.thermal_energy()/PLASMA_BINDING_ENERGY)

	reaction_energy = max(reaction_energy+((carbon_efficency*cached_gases["plasma"][MOLES])/((moles_impurities/carbon_efficency)+2)*10)+((plasma_fused/(moles_impurities/carbon_efficency))*PLASMA_BINDING_ENERGY),0)

	air.assert_gases("o2", "n2")

	cached_gases["plasma"][MOLES] -= plasma_fused
	cached_gases["co2"][MOLES] -= carbon_catalyzed
	cached_gases["o2"][MOLES] += oxygen_added
	cached_gases["n2"][MOLES] += nitrogen_added

	if(reaction_energy > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB)
			//Prevents whatever mechanism is causing it to hit negative temperatures.
		//to_chat(world, "post [temperature], [cached_gases["plasma"][MOLES]], [cached_gases["co2"][MOLES]])
		return REACTING

#undef REACTING
#undef NO_REACTION
