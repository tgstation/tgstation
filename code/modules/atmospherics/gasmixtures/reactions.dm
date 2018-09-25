//All defines used in reactions are located in ..\__DEFINES\reactions.dm

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
	//when in doubt, use MINIMUM_MOLE_COUNT.
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
	name = "Hyper-Noblium Reaction Suppression"
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

/datum/gas_reaction/water_vapor/react(datum/gas_mixture/air, datum/holder)
	var/turf/open/location = isturf(holder) ? holder : null
	. = NO_REACTION
	if (air.temperature <= WATER_VAPOR_FREEZE)
		if(location && location.freon_gas_act())
			. = REACTING
	else if(location && location.water_vapor_gas_act())
		air.gases[/datum/gas/water_vapor][MOLES] -= MOLES_GAS_VISIBLE
		. = REACTING

//tritium combustion: combustion of oxygen and tritium (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/tritfire
	priority = -1 //fire should ALWAYS be last, but tritium fires happen before plasma fires
	name = "Tritium Combustion"
	id = "tritfire"

/datum/gas_reaction/tritfire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/tritium = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/tritfire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null

	var/burned_fuel = 0
	if(cached_gases[/datum/gas/oxygen][MOLES] < cached_gases[/datum/gas/tritium][MOLES])
		burned_fuel = cached_gases[/datum/gas/oxygen][MOLES]/TRITIUM_BURN_OXY_FACTOR
		cached_gases[/datum/gas/tritium][MOLES] -= burned_fuel
	else
		burned_fuel = cached_gases[/datum/gas/tritium][MOLES]*TRITIUM_BURN_TRIT_FACTOR
		cached_gases[/datum/gas/tritium][MOLES] -= cached_gases[/datum/gas/tritium][MOLES]/TRITIUM_BURN_TRIT_FACTOR
		cached_gases[/datum/gas/oxygen][MOLES] -= cached_gases[/datum/gas/tritium][MOLES]

	if(burned_fuel)
		energy_released += FIRE_HYDROGEN_ENERGY_RELEASED * burned_fuel
		if(location && prob(10) && burned_fuel > TRITIUM_MINIMUM_RADIATION_ENERGY) //woah there let's not crash the server
			radiation_pulse(location, energy_released/TRITIUM_BURN_RADIOACTIVITY_FACTOR)

		ASSERT_GAS(/datum/gas/water_vapor, air) //oxygen+more-or-less hydrogen=H2O
		cached_gases[/datum/gas/water_vapor][MOLES] += burned_fuel/TRITIUM_BURN_OXY_FACTOR

		cached_results["fire"] += burned_fuel

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

	return cached_results["fire"] ? REACTING : NO_REACTION

//plasma combustion: combustion of oxygen and plasma (treated as hydrocarbons). creates hotspots. exothermic
/datum/gas_reaction/plasmafire
	priority = -2 //fire should ALWAYS be last, but plasma fires happen after tritium fires
	name = "Plasma Combustion"
	id = "plasmafire"

/datum/gas_reaction/plasmafire/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST,
		/datum/gas/plasma = MINIMUM_MOLE_COUNT,
		/datum/gas/oxygen = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/plasmafire/react(datum/gas_mixture/air, datum/holder)
	var/energy_released = 0
	var/old_heat_capacity = air.heat_capacity()
	var/list/cached_gases = air.gases //this speeds things up because accessing datum vars is slow
	var/temperature = air.temperature
	var/list/cached_results = air.reaction_results
	cached_results["fire"] = 0
	var/turf/open/location = isturf(holder) ? holder : null

	//Handle plasma burning
	var/plasma_burn_rate = 0
	var/oxygen_burn_rate = 0
	//more plasma released at higher temperatures
	var/temperature_scale = 0
	//to make tritium
	var/super_saturation = FALSE

	if(temperature > PLASMA_UPPER_TEMPERATURE)
		temperature_scale = 1
	else
		temperature_scale = (temperature-PLASMA_MINIMUM_BURN_TEMPERATURE)/(PLASMA_UPPER_TEMPERATURE-PLASMA_MINIMUM_BURN_TEMPERATURE)
	if(temperature_scale > 0)
		oxygen_burn_rate = OXYGEN_BURN_RATE_BASE - temperature_scale
		if(cached_gases[/datum/gas/oxygen][MOLES] / cached_gases[/datum/gas/plasma][MOLES] > SUPER_SATURATION_THRESHOLD) //supersaturation. Form Tritium.
			super_saturation = TRUE
		if(cached_gases[/datum/gas/oxygen][MOLES] > cached_gases[/datum/gas/plasma][MOLES]*PLASMA_OXYGEN_FULLBURN)
			plasma_burn_rate = (cached_gases[/datum/gas/plasma][MOLES]*temperature_scale)/PLASMA_BURN_RATE_DELTA
		else
			plasma_burn_rate = (temperature_scale*(cached_gases[/datum/gas/oxygen][MOLES]/PLASMA_OXYGEN_FULLBURN))/PLASMA_BURN_RATE_DELTA

		if(plasma_burn_rate > MINIMUM_HEAT_CAPACITY)
			plasma_burn_rate = min(plasma_burn_rate,cached_gases[/datum/gas/plasma][MOLES],cached_gases[/datum/gas/oxygen][MOLES]/oxygen_burn_rate) //Ensures matter is conserved properly
			cached_gases[/datum/gas/plasma][MOLES] = QUANTIZE(cached_gases[/datum/gas/plasma][MOLES] - plasma_burn_rate)
			cached_gases[/datum/gas/oxygen][MOLES] = QUANTIZE(cached_gases[/datum/gas/oxygen][MOLES] - (plasma_burn_rate * oxygen_burn_rate))
			if (super_saturation)
				ASSERT_GAS(/datum/gas/tritium,air)
				cached_gases[/datum/gas/tritium][MOLES] += plasma_burn_rate
			else
				ASSERT_GAS(/datum/gas/carbon_dioxide,air)
				cached_gases[/datum/gas/carbon_dioxide][MOLES] += plasma_burn_rate

			energy_released += FIRE_PLASMA_ENERGY_RELEASED * (plasma_burn_rate)

			cached_results["fire"] += (plasma_burn_rate)*(1+oxygen_burn_rate)

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

	return cached_results["fire"] ? REACTING : NO_REACTION

//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again)
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//5 reworks

/datum/gas_reaction/fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "fusion"

//Since fusion isn't really intended to happen in successive chains, the requirements are very high
/datum/gas_reaction/fusion/init_reqs()
	min_requirements = list(
		"TEMP" = FUSION_TEMPERATURE_THRESHOLD,
		"ENER" = FUSION_ENERGY_THRESHOLD,
		/datum/gas/plasma = FUSION_MOLE_THRESHOLD,
		/datum/gas/tritium = FUSION_MOLE_THRESHOLD
	)

/datum/gas_reaction/fusion/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	if(!air.analyzer_results)
		air.analyzer_results = new
	var/list/cached_scan_results = air.analyzer_results
	var/turf/open/location
	if (istype(holder,/datum/pipeline)) //Find the tile the reaction is occuring on, or a random part of the network if it's a pipenet.
		var/datum/pipeline/fusion_pipenet = holder
		location = get_turf(pick(fusion_pipenet.members))
	else
		location = get_turf(holder)

	var/old_heat_capacity = air.heat_capacity()
	var/reaction_energy = 0

	var/mediation = FUSION_MEDIATION_FACTOR*(air.heat_capacity()-(cached_gases[/datum/gas/plasma][MOLES]*cached_gases[/datum/gas/plasma][GAS_META][META_GAS_SPECIFIC_HEAT]))/(air.total_moles()-cached_gases[/datum/gas/plasma][MOLES]) //This is the average specific heat of the mixture,not including plasma.

	var/gases_fused = air.total_moles() - cached_gases[/datum/gas/plasma][MOLES]
	var/plasma_differential = (cached_gases[/datum/gas/plasma][MOLES] - gases_fused) / air.total_moles()
	var/reaction_efficiency = FUSION_EFFICIENCY_BASE ** -((plasma_differential ** 2) / FUSION_EFFICIENCY_DIVISOR) //https://www.desmos.com/calculator/6jjx3vdrvx

	var/gas_power = 0
	for (var/gas_id in cached_gases)
		gas_power += reaction_efficiency * (cached_gases[gas_id][GAS_META][META_GAS_FUSION_POWER]*cached_gases[gas_id][MOLES])

	var/power_ratio = gas_power/mediation
	cached_scan_results[id] = power_ratio //used for analyzer feedback

	for (var/gas_id in cached_gases) //and now we fuse
		cached_gases[gas_id][MOLES] = 0

	var/radiation_power = (FUSION_RADIATION_FACTOR * power_ratio) / (power_ratio + FUSION_RADIATION_CONSTANT) //https://www.desmos.com/calculator/4i1f296phl
	var/zap_power = ((FUSION_ZAP_POWER_ASYMPTOTE * power_ratio) / (power_ratio + FUSION_ZAP_POWER_CONSTANT)) + FUSION_ZAP_POWER_BASE //https://www.desmos.com/calculator/n0zkdpxnrr
	var/do_explosion = FALSE
	var/zap_range //these ones are set later
	var/fusion_prepare_to_die_edition_rng

	if (power_ratio > FUSION_SUPER_TIER_THRESHOLD) //power ratio 50+: SUPER TIER. The gases become so energized that they fuse into a ton of tritium, which is pretty nice! Until you consider the fact that everything just exploded, the canister is probably going to break and you're irradiated.
		reaction_energy += gases_fused * FUSION_RELEASE_ENERGY_SUPER * (power_ratio / FUSION_ENERGY_DIVISOR_SUPER)
		cached_gases[/datum/gas/tritium][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_TRITIUM //60% of the gas is converted to energy, 40% to trit
		fusion_prepare_to_die_edition_rng = 100 //Wait a minute..
		do_explosion = TRUE			
		zap_range = FUSION_ZAP_RANGE_SUPER

	else if (power_ratio > FUSION_HIGH_TIER_THRESHOLD) //power ratio 20-50; High tier. The reaction is so energized that it fuses into a small amount of stimulum, and some pluoxium. Very dangerous, but super cool and super useful.
		reaction_energy += gases_fused * FUSION_RELEASE_ENERGY_HIGH * (power_ratio / FUSION_ENERGY_DIVISOR_HIGH)
		air.assert_gases(/datum/gas/stimulum, /datum/gas/pluoxium)
		cached_gases[/datum/gas/stimulum][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_STIM //40% of the gas is converted to energy, 60% to stim and pluox
		cached_gases[/datum/gas/pluoxium][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_PLUOX
		fusion_prepare_to_die_edition_rng = power_ratio //Now we're getting into dangerous territory
		do_explosion = TRUE
		zap_range = FUSION_ZAP_RANGE_HIGH

	else if (power_ratio > FUSION_MID_TIER_THRESHOLD) //power_ratio 5 to 20; Mediation is overpowered, fusion reaction starts to break down.
		reaction_energy += gases_fused * FUSION_RELEASE_ENERGY_MID * (power_ratio / FUSION_ENERGY_DIVISOR_MID)
		air.assert_gases(/datum/gas/nitryl,/datum/gas/nitrous_oxide)
		cached_gases[/datum/gas/nitryl][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_NITRYL //20% of the gas is converted to energy, 80% to nitryl and N2O
		cached_gases[/datum/gas/nitrous_oxide][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_N2O
		fusion_prepare_to_die_edition_rng = power_ratio * FUSION_MID_TIER_RAD_PROB_FACTOR //Still unlikely, but don't stand next to the reaction unprotected
		zap_range = FUSION_ZAP_RANGE_MID

	else //power ratio 0 to 5; Gas power is overpowered. Fusion isn't nearly as powerful.
		reaction_energy += gases_fused * FUSION_RELEASE_ENERGY_LOW * (power_ratio / FUSION_ENERGY_DIVISOR_LOW)
		air.assert_gases(/datum/gas/bz, /datum/gas/carbon_dioxide)
		cached_gases[/datum/gas/bz][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_BZ //10% of the gas is converted to energy, 90% to BZ and CO2
		cached_gases[/datum/gas/carbon_dioxide][MOLES] += gases_fused * FUSION_GAS_CREATION_FACTOR_CO2
		fusion_prepare_to_die_edition_rng = power_ratio * FUSION_LOW_TIER_RAD_PROB_FACTOR //Low, but still something to look out for
		zap_range = FUSION_ZAP_RANGE_LOW

	//All the deadly consequences of fusion, consolidated for your viewing pleasure
	if (location)
		if(prob(fusion_prepare_to_die_edition_rng)) //Some.. permanent effects
			if(do_explosion)
				explosion(location, 0, 0, 5, power_ratio, TRUE, TRUE) //large shockwave, the actual radius is quite small - people will recognize that you're doing fusion
			radiation_pulse(location, radiation_power) //You mean causing a super-tier fusion reaction in the halls is a bad idea?
			playsound(location, 'sound/effects/supermatter.ogg', 100, 0)
		else
			playsound(location, 'sound/effects/phasein.ogg', 75, 0)
		//These will always happen, so be prepared
		tesla_zap(location, zap_range, zap_power, TESLA_FUSION_FLAGS) //larpers beware
		location.fire_nuclear_particles(power_ratio) //see code/modules/projectile/energy/nuclear_particle.dm

	if(reaction_energy > 0)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((temperature*old_heat_capacity + reaction_energy)/new_heat_capacity),TCMB)
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
	var/heat_efficency = min(temperature/(FIRE_MINIMUM_TEMPERATURE_TO_EXIST*100),cached_gases[/datum/gas/oxygen][MOLES],cached_gases[/datum/gas/nitrogen][MOLES])
	var/energy_used = heat_efficency*NITRYL_FORMATION_ENERGY
	ASSERT_GAS(/datum/gas/nitryl,air)
	if ((cached_gases[/datum/gas/oxygen][MOLES] - heat_efficency < 0 )|| (cached_gases[/datum/gas/nitrogen][MOLES] - heat_efficency < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
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
		/datum/gas/nitrous_oxide = 10,
		/datum/gas/plasma = 10
	)


/datum/gas_reaction/bzformation/react(datum/gas_mixture/air)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/pressure = air.return_pressure()

	var/old_heat_capacity = air.heat_capacity()
	var/reaction_efficency = min(1/((pressure/(0.1*ONE_ATMOSPHERE))*(max(cached_gases[/datum/gas/plasma][MOLES]/cached_gases[/datum/gas/nitrous_oxide][MOLES],1))),cached_gases[/datum/gas/nitrous_oxide][MOLES],cached_gases[/datum/gas/plasma][MOLES]/2)
	var/energy_released = 2*reaction_efficency*FIRE_CARBON_ENERGY_RELEASED
	if ((cached_gases[/datum/gas/nitrous_oxide][MOLES] - reaction_efficency < 0 )|| (cached_gases[/datum/gas/plasma][MOLES] - (2*reaction_efficency) < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	ASSERT_GAS(/datum/gas/bz,air)
	cached_gases[/datum/gas/bz][MOLES] += reaction_efficency
	cached_gases[/datum/gas/nitrous_oxide][MOLES] -= reaction_efficency
	cached_gases[/datum/gas/plasma][MOLES]  -= 2*reaction_efficency


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
	var/heat_scale = min(air.temperature/STIMULUM_HEAT_SCALE,cached_gases[/datum/gas/tritium][MOLES],cached_gases[/datum/gas/plasma][MOLES],cached_gases[/datum/gas/nitryl][MOLES])
	var/stim_energy_change = heat_scale + STIMULUM_FIRST_RISE*(heat_scale**2) - STIMULUM_FIRST_DROP*(heat_scale**3) + STIMULUM_SECOND_RISE*(heat_scale**4) - STIMULUM_ABSOLUTE_DROP*(heat_scale**5)

	ASSERT_GAS(/datum/gas/stimulum,air)
	if ((cached_gases[/datum/gas/tritium][MOLES] - heat_scale < 0 )|| (cached_gases[/datum/gas/plasma][MOLES] - heat_scale < 0) || (cached_gases[/datum/gas/nitryl][MOLES] - heat_scale < 0)) //Shouldn't produce gas from nothing.
		return NO_REACTION
	cached_gases[/datum/gas/stimulum][MOLES]+= heat_scale/10
	cached_gases[/datum/gas/tritium][MOLES] -= heat_scale
	cached_gases[/datum/gas/plasma][MOLES] -= heat_scale
	cached_gases[/datum/gas/nitryl][MOLES] -= heat_scale

	if(stim_energy_change)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature*old_heat_capacity + stim_energy_change)/new_heat_capacity),TCMB)
		return REACTING

/datum/gas_reaction/nobliumformation //Hyper-Noblium formation is extrememly endothermic, but requires high temperatures to start. Due to its high mass, hyper-nobelium uses large amounts of nitrogen and tritium. BZ can be used as a catalyst to make it less endothermic.
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
	var/nob_formed = min((cached_gases[/datum/gas/nitrogen][MOLES]+cached_gases[/datum/gas/tritium][MOLES])/100,cached_gases[/datum/gas/tritium][MOLES]/10,cached_gases[/datum/gas/nitrogen][MOLES]/20)
	var/energy_taken = nob_formed*(NOBLIUM_FORMATION_ENERGY/(max(cached_gases[/datum/gas/bz][MOLES],1)))
	if ((cached_gases[/datum/gas/tritium][MOLES] - 10*nob_formed < 0) || (cached_gases[/datum/gas/nitrogen][MOLES] - 20*nob_formed < 0))
		return NO_REACTION
	cached_gases[/datum/gas/tritium][MOLES] -= 10*nob_formed
	cached_gases[/datum/gas/nitrogen][MOLES] -= 20*nob_formed
	cached_gases[/datum/gas/hypernoblium][MOLES]+= nob_formed


	if (nob_formed)
		var/new_heat_capacity = air.heat_capacity()
		if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
			air.temperature = max(((air.temperature*old_heat_capacity - energy_taken)/new_heat_capacity),TCMB)
	

/datum/gas_reaction/miaster	//dry heat sterilization: clears out pathogens in the air
	priority = -10 //after all the heating from fires etc. is done
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST+70,
		/datum/gas/miasma = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	var/list/cached_gases = air.gases
	// As the name says it, it needs to be dry
	if(/datum/gas/water_vapor in cached_gases)
		if(cached_gases[/datum/gas/water_vapor]/air.total_moles() > 0.1)
			return

	//Replace miasma with oxygen
	var/cleaned_air = min(cached_gases[/datum/gas/miasma][MOLES], 20 + (air.temperature - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	cached_gases[/datum/gas/miasma][MOLES] -= cleaned_air
	cached_gases[/datum/gas/oxygen][MOLES] += cleaned_air

	//Possibly burning a bit of organic matter through maillard reaction, so a *tiny* bit more heat would be understandable
	air.temperature += cleaned_air * 0.002
