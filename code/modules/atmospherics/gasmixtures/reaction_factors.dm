/datum/gas_reaction/standard/water_vapor/init_factors()
	factor = list(
		/datum/gas/water_vapor = "Condensation will consume [MOLES_GAS_VISIBLE] moles. \
			Freezing will not consume any. Both requires a minimum of [MOLES_GAS_VISIBLE] moles to occur.",
		"Temperature" = "Freezes a tile at [WATER_VAPOR_DEPOSITION_POINT]K or below, \
			wets it at [WATER_VAPOR_CONDENSATION_POINT]K or below.",
		"Location" = "Can only happen on tiles.",
	)

/datum/gas_reaction/standard/miaster/init_factors()
	factor = list(
		/datum/gas/miasma = "[/datum/gas/miasma::name] is sterilized at a rate that scales \
			with the difference between the temperature and [MIASTER_STERILIZATION_TEMP]K.",
		/datum/gas/oxygen = "One mole of [/datum/gas/oxygen::name] is released per mole of [/datum/gas/miasma::name] consumed.",
		"Temperature" = "Higher temperature increases the speed of [/datum/gas/miasma::name] sterilization.",
		"Energy" = "[MIASTER_STERILIZATION_ENERGY] joules of energy is released per mole of [/datum/gas/miasma::name] sterilized.",
	)

/datum/gas_reaction/standard/plasmafire/init_factors()
	factor = list(
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] consumption is determined by the temperature, \
			ranging from [OXYGEN_BURN_RATIO_BASE] moles per mole of [/datum/gas/plasma::name] consumed at [PLASMA_MINIMUM_BURN_TEMPERATURE]K \
			to [OXYGEN_BURN_RATIO_BASE-1] moles per mole of [/datum/gas/plasma::name] consumed at [PLASMA_UPPER_TEMPERATURE]K. \
			Higher [/datum/gas/oxygen::name] concentration up to [PLASMA_OXYGEN_FULLBURN] times the [/datum/gas/plasma::name] \
			increases the speed of [/datum/gas/plasma::name] consumption.",
		/datum/gas/plasma = "[/datum/gas/plasma::name] is consumed at a rate that scales with the difference between the temperature \
			and [PLASMA_MINIMUM_BURN_TEMPERATURE]K, with maximum scaling at [PLASMA_UPPER_TEMPERATURE]K.",
		/datum/gas/tritium = "[/datum/gas/tritium::name] is formed at 1 mole per mole of [/datum/gas/plasma::name] consumed \
			if there are at least 97 times more [/datum/gas/oxygen::name] than [/datum/gas/plasma::name].",
		/datum/gas/water_vapor = "[/datum/gas/water_vapor::name] is formed at 0.25 moles per mole of [/datum/gas/plasma::name] consumed \
			if [/datum/gas/tritium::name] isn't being formed.",
		/datum/gas/carbon_dioxide = "[/datum/gas/carbon_dioxide::name] is formed at 0.75 moles per mole of [/datum/gas/plasma::name] consumed \
			if [/datum/gas/tritium::name] isn't being formed.",
		"Temperature" = "Minimum temperature of [PLASMA_MINIMUM_BURN_TEMPERATURE]K to occur. \
			Higher temperature up to [PLASMA_UPPER_TEMPERATURE]K increases the [/datum/gas/oxygen::name] efficiency \
			and also the [/datum/gas/plasma::name] consumption rate.",
		"Energy" = "[FIRE_PLASMA_ENERGY_RELEASED] joules of energy is released per mole of [/datum/gas/plasma::name] consumed.",
	)

/datum/gas_reaction/standard/h2fire/init_factors()
	factor = list(
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] is consumed at 0.5 moles per mole of [/datum/gas/hydrogen::name] consumed. \
			Higher [/datum/gas/oxygen::name] concentration up to [HYDROGEN_OXYGEN_FULLBURN] times \
			the [/datum/gas/hydrogen::name] increases the [/datum/gas/hydrogen::name] consumption rate.",
		/datum/gas/hydrogen = "[/datum/gas/hydrogen::name] is consumed rapidly fast as long as there's enough [/datum/gas/oxygen::name] to allow combustion.",
		/datum/gas/water_vapor = "[/datum/gas/water_vapor::name] is produced at 1 mole per mole of [/datum/gas/hydrogen::name] combusted.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST]K to occur",
		"Energy" = "[FIRE_HYDROGEN_ENERGY_RELEASED] joules of energy is released per mol of [/datum/gas/hydrogen::name] consumed.",
	)

/datum/gas_reaction/standard/tritfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] is consumed at 0.5 moles per mole of [/datum/gas/tritium::name] consumed. \
			Higher [/datum/gas/oxygen::name] concentration up to [TRITIUM_OXYGEN_FULLBURN] times \
			the [/datum/gas/tritium::name] increases the [/datum/gas/tritium::name] consumption rate.",
		/datum/gas/tritium = "[/datum/gas/tritium::name] is consumed at rapidly fast as long as there's enough [/datum/gas/oxygen::name] to allow combustion.",
		/datum/gas/water_vapor = "[/datum/gas/water_vapor::name] is produced at 1 mole per mole of [/datum/gas/tritium::name] combusted.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST]K to occur",
		"Energy" = "[FIRE_TRITIUM_ENERGY_RELEASED] joules of energy is released per mol of [/datum/gas/tritium::name] consumed.",
		"Radiation" = "This reaction emits radiation proportional to the amount of energy released.",
	)

/datum/gas_reaction/standard/freonfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] consumption is determined by the temperature, \
			ranging from [OXYGEN_BURN_RATIO_BASE] moles per mole of [/datum/gas/freon::name] consumed at [FREON_LOWER_TEMPERATURE]K \
			to [OXYGEN_BURN_RATIO_BASE - 1] moles per mole of [/datum/gas/freon::name] consumed at [FREON_MAXIMUM_BURN_TEMPERATURE]K. \
			Higher [/datum/gas/oxygen::name] concentration up to [FREON_OXYGEN_FULLBURN] times \
			the [/datum/gas/freon::name] increases [/datum/gas/freon::name] consumption rate.",
		/datum/gas/freon = "[/datum/gas/freon::name] is consumed at a rate that scales with the distance of the temperature \
			from [FREON_MAXIMUM_BURN_TEMPERATURE]K. Its relationship with [/datum/gas/oxygen::name] also determines consumption rate.",
		/datum/gas/carbon_dioxide = "[/datum/gas/carbon_dioxide::name] is formed at 1 mole per mole of [/datum/gas/freon::name] consumed.",
		"Temperature" = "Can only occur between [FREON_LOWER_TEMPERATURE] - [FREON_MAXIMUM_BURN_TEMPERATURE]K.",
		"Energy" = "[FIRE_FREON_ENERGY_CONSUMED] joules of energy is absorbed per mole of [/datum/gas/freon::name] consumed.",
		"Hot Ice" = "This reaction produces \"hot ice\" when occurring between [HOT_ICE_FORMATION_MINIMUM_TEMPERATURE]-[HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE]K.",
	)


/datum/gas_reaction/standard/nitrousformation/init_factors()
	factor = list(
		/datum/gas/oxygen = "10 moles of [/datum/gas/oxygen::name] needs to be present for the reaction to occur. \
			[/datum/gas/oxygen::name] is consumed at 0.5 moles per mole of [/datum/gas/nitrous_oxide::name] formed.",
		/datum/gas/nitrogen = " 20 moles of [/datum/gas/nitrogen::name] needs to be present for the reaction to occur. \
			[/datum/gas/nitrogen::name] is consumed at 1 mole per mole of [/datum/gas/nitrous_oxide::name] formed.",
		/datum/gas/bz = "5 moles of [/datum/gas/bz::name] needs to be present for the reaction to occur. Not consumed.",
		/datum/gas/nitrous_oxide = "[/datum/gas/nitrous_oxide::name] gets produced rapidly.",
		"Temperature" = "Can only occur between [N2O_FORMATION_MIN_TEMPERATURE] - [N2O_FORMATION_MAX_TEMPERATURE]K",
		"Energy" = "[N2O_FORMATION_ENERGY] joules of energy is released per mole of [/datum/gas/nitrous_oxide::name] formed.",
	)

/datum/gas_reaction/standard/nitrous_decomp/init_factors()
	factor = list(
		/datum/gas/nitrous_oxide = "[/datum/gas/nitrous_oxide::name] is decomposed at a rate that scales negatively with the distance between \
			the temperature and average of the minimum and maximum temperature of the reaction. \
			Minimum of [MINIMUM_MOLE_COUNT * 2] to occur.", //okay this one isn't made into a define yet.
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] is formed at 0.5 moles per mole of [/datum/gas/nitrous_oxide::name] decomposed.",
		/datum/gas/nitrogen = "[/datum/gas/nitrogen::name] is formed at 1 mole per mole of [/datum/gas/nitrous_oxide::name] decomposed.",
		"Temperature" = "The decomposition rate scales with the product of the distances between temperature and minimum and maximum temperature. Can only happen between [N2O_DECOMPOSITION_MIN_TEMPERATURE] - [N2O_DECOMPOSITION_MAX_TEMPERATURE]K.",
		"Energy" = "[N2O_DECOMPOSITION_ENERGY] joules of energy is released per mole of [/datum/gas/nitrous_oxide::name] decomposed.",
	)

/datum/gas_reaction/standard/bzformation/init_factors()
	factor = list(
		/datum/gas/plasma = "Each mole of [/datum/gas/bz::name] made consumes 0.8 moles of [/datum/gas/plasma::name]. \
			If there is more [/datum/gas/plasma::name] than [/datum/gas/nitrous_oxide::name], [/datum/gas/bz::name] formation rate gets slowed down.",
		/datum/gas/nitrous_oxide = "Each mole of [/datum/gas/bz::name] made consumes 0.4 moles of [/datum/gas/nitrous_oxide::name]. \
			If there is less [/datum/gas/nitrous_oxide::name] than [/datum/gas/plasma::name] the reaction rate is slowed down. \
			At three times the amount of [/datum/gas/plasma::name] to [/datum/gas/nitrous_oxide::name], \
			it will start breaking down into [/datum/gas/nitrogen::name] and [/datum/gas/oxygen::name] - \
			the lower the ratio, the more [/datum/gas/nitrous_oxide::name] decomposes.",
		/datum/gas/bz = "The lower the pressure and larger the volume the more [/datum/gas/bz::name] gets made. \
			Less [/datum/gas/nitrous_oxide::name] than [/datum/gas/plasma::name] will slow down the reaction.",
		/datum/gas/nitrogen = "Each mole [/datum/gas/nitrous_oxide::name] decomposed makes 1 mol [/datum/gas/nitrogen::name]. \
			Lower ratio of [/datum/gas/nitrous_oxide::name] to [/datum/gas/plasma::name] means a higher ratio of decomposition to [/datum/gas/bz::name] production.",
		/datum/gas/oxygen = "Each mole [/datum/gas/nitrous_oxide::name] decomposed makes 0.5 moles [/datum/gas/oxygen::name]. \
			Lower ratio of [/datum/gas/nitrous_oxide::name] to [/datum/gas/plasma::name] means a higher ratio of decomposition to [/datum/gas/bz::name] production.",
		"Energy" = "[BZ_FORMATION_ENERGY] joules of energy is released per mol of [/datum/gas/bz::name] made. \
			[/datum/gas/nitrous_oxide::name] decomposition releases [N2O_DECOMPOSITION_ENERGY] per mol decomposed.",
	)

/datum/gas_reaction/standard/pluox_formation/init_factors()
	factor = list(
		/datum/gas/carbon_dioxide = "1 mole of [/datum/gas/carbon_dioxide::name] gets consumed per mole of [/datum/gas/pluoxium::name] formed.",
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] is consumed at 0.5 moles per mole of [/datum/gas/pluoxium::name] formed.",
		/datum/gas/tritium = "[/datum/gas/tritium::name] is converted into [/datum/gas/hydrogen::name] at 0.01 moles per mole of [/datum/gas/pluoxium::name] formed.",
		/datum/gas/pluoxium = "[/datum/gas/pluoxium::name] is produced at a constant rate in any given mixture.",
		/datum/gas/hydrogen = "[/datum/gas/hydrogen::name] is formed from the [/datum/gas/tritium::name] losing their neutrons.",
		"Energy" = "[PLUOXIUM_FORMATION_ENERGY] joules of energy is released per mole of [/datum/gas/pluoxium::name] formed.",
		"Temperature" = "Can only occur between [PLUOXIUM_FORMATION_MIN_TEMP] - [PLUOXIUM_FORMATION_MAX_TEMP]K",
	)

/datum/gas_reaction/standard/nitrium_formation/init_factors()
	factor = list(
		/datum/gas/bz = "5 moles of [/datum/gas/bz::name] needs to be present for the reaction to occur. \
			[/datum/gas/bz::name] is consumed at 0.05 moles per mole of [/datum/gas/nitrium::name] formed.",
		/datum/gas/tritium = "20 moles of [/datum/gas/tritium::name] needs to be present for the reaction to occur. \
			[/datum/gas/tritium::name] is consumed at 1 mole per mole of [/datum/gas/nitrium::name] formed.",
		/datum/gas/nitrogen = "10 moles of [/datum/gas/nitrogen::name] needs to be present for the reaction to occur. \
			[/datum/gas/nitrogen::name] is consumed at 1 mole per mole of [/datum/gas/nitrium::name] formed.",
		/datum/gas/nitrium = "[/datum/gas/nitrium::name] is produced at a rate that scales with the temperature.",
		"Temperature" = "Can only occur above [NITRIUM_FORMATION_MIN_TEMP]K",
		"Energy" = "[NITRIUM_FORMATION_ENERGY] joules of energy is absorbed per mole of [/datum/gas/nitrium::name] formed.",
	)

/datum/gas_reaction/standard/nitrium_decomposition/init_factors()
	factor = list(
		/datum/gas/oxygen = "[MINIMUM_MOLE_COUNT] moles of [/datum/gas/oxygen::name] need to be present for the reaction to occur. Not consumed.",
		/datum/gas/nitrium = "[/datum/gas/nitrium::name] is consumed at a rate that scales with the temperature.",
		/datum/gas/hydrogen = "[/datum/gas/hydrogen::name] is produced at 1 mole per mole of [/datum/gas/nitrium::name] decomposed.",
		/datum/gas/nitrogen = "[/datum/gas/nitrogen::name] is produced at 1 mole per mole of [/datum/gas/nitrium::name] decomposed.",
		"Temperature" = "Can only occur below [NITRIUM_DECOMPOSITION_MAX_TEMP]. Higher temperature increases the [/datum/gas/nitrium::name] decomposition rate.",
		"Energy" = "[NITRIUM_DECOMPOSITION_ENERGY] joules of energy is released per mole of [/datum/gas/nitrium::name] decomposed.",
	)

/datum/gas_reaction/standard/freonformation/init_factors()
	factor = list(
		/datum/gas/plasma = "At least 0.06 moles of [/datum/gas/plasma::name] needs to be present. \
			[/datum/gas/plasma::name] is consumed at 0.6 moles per mole of [/datum/gas/freon::name] formed.",
		/datum/gas/carbon_dioxide = "At least 0.03 moles of [/datum/gas/carbon_dioxide::name] needs to be present. \
			[/datum/gas/carbon_dioxide::name] is consumed at 0.3 moles per mole of [/datum/gas/freon::name] formed.",
		/datum/gas/bz = "At least 0.01 moles of [/datum/gas/bz::name] needs to be present. \
			[/datum/gas/bz::name] is consumed at 0.1 moles per mole of [/datum/gas/freon::name] formed.",
		/datum/gas/freon = "[/datum/gas/freon::name] is produced at a rate that scales with temperature. \
			See temperature factor for more information.",
		"Energy" = "Between 100 and 800 joules of energy is absorbed per mole of [/datum/gas/freon::name] produced", // I don't know why the energy release is also a sigmoidal function, but it should really just be constant to be honest.
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100]K to occur. \
			Production speed peaks at 800K - However, at temperatures above 5500K, \
			production speed can exceed the low temperature peak (reaching up to three times fast at 8500K).",
	)

/datum/gas_reaction/standard/nobliumformation/init_factors()
	factor = list(
		/datum/gas/nitrogen = "10 moles of [/datum/gas/nitrogen::name] needs to be present for the reaction to occur. \
			[/datum/gas/nitrogen::name] is consumed at 10 moles per mole of [/datum/gas/hypernoblium::name] formed.",
		/datum/gas/tritium = "5 moles of [/datum/gas/tritium::name] needs to be present for the reaction to occur. \
			[/datum/gas/tritium::name] is consumed at 5 moles per mole of [/datum/gas/hypernoblium::name] formed. \
				The relative consumption rate of [/datum/gas/tritium::name] decreases in the exposure of [/datum/gas/bz::name].",
		/datum/gas/hypernoblium = "[/datum/gas/hypernoblium::name] production scales based on the sum \
			of the [/datum/gas/nitrogen::name] and [/datum/gas/tritium::name] moles.",
		"Energy" = "[NOBLIUM_FORMATION_ENERGY] joules of energy is released per mole of [/datum/gas/hypernoblium::name] produced.",
		/datum/gas/bz = "[/datum/gas/bz::name] is not consumed in the reaction but will lower the amount of energy released. \
			It also reduces amount of [/datum/gas/tritium::name] consumed by a ratio \
			between [/datum/gas/tritium::name] and [/datum/gas/bz::name], greater [/datum/gas/bz::name] than [/datum/gas/tritium::name] will reduce more.",
		"Temperature" = "Can only occur between [NOBLIUM_FORMATION_MIN_TEMP] - [NOBLIUM_FORMATION_MAX_TEMP]K",
	)

/datum/gas_reaction/standard/halon_o2removal/init_factors()
	factor = list(
		/datum/gas/halon = "[/datum/gas/halon::name] is consumed at a rate that scales with temperature.",
		/datum/gas/oxygen = "20 moles of [/datum/gas/oxygen::name] is consumed per mole of [/datum/gas/halon::name] combusted.",
		/datum/gas/carbon_dioxide = "[/datum/gas/carbon_dioxide::name] is produced at 5 moles per mole of [/datum/gas/halon::name] consumed.",
		"Energy" = "[HALON_COMBUSTION_ENERGY] joules of energy is absorbed per mole of [/datum/gas/halon::name] consumed.",
		"Temperature" = "Can only occur above [FIRE_MINIMUM_TEMPERATURE_TO_EXIST]K. Higher temperature increases [/datum/gas/halon::name] consumption rate.",
	)

/datum/gas_reaction/standard/healium_formation/init_factors()
	factor = list(
		/datum/gas/bz = "[/datum/gas/bz::name] is consumed at 1/12th of a mole per mole of [/datum/gas/healium::name] formed.",
		/datum/gas/freon = "[/datum/gas/freon::name] is consumed at 11/12th of a mole per mole of [/datum/gas/healium::name] formed.",
		/datum/gas/healium = "[/datum/gas/healium::name] is formed at a rate that scales with the temperature.",
		"Temperature" = "Can only occur between [HEALIUM_FORMATION_MIN_TEMP] - [HEALIUM_FORMATION_MAX_TEMP]. \
			Higher temperature increases [/datum/gas/healium::name] formation rate.",
		"Energy" = "[HEALIUM_FORMATION_ENERGY/3] joules of energy is released per mole of [/datum/gas/healium::name] formed.",
	)

/datum/gas_reaction/standard/zauker_formation/init_factors()
	factor = list(
		/datum/gas/hypernoblium = "[/datum/gas/hypernoblium::name] is consumed at 0.02 moles per mole of [/datum/gas/zauker::name] formed.",
		/datum/gas/nitrium = "[/datum/gas/nitrium::name] is consumed at 1 mole per mole of [/datum/gas/zauker::name] formed.",
		/datum/gas/zauker = "[/datum/gas/zauker::name] is produced at a rate that scales with the temperature.",
		"Temperature" = "Can only occur between [ZAUKER_FORMATION_MIN_TEMPERATURE] - [ZAUKER_FORMATION_MAX_TEMPERATURE]K. [/datum/gas/zauker::name] formation rate is proportional to the temperature.",
		"Energy" = "[2 * ZAUKER_FORMATION_ENERGY] joules of energy is absorbed per mole of [/datum/gas/zauker::name] formed.",
	)

/datum/gas_reaction/standard/zauker_decomp/init_factors() //Fixed reaction rate
	factor = list(
		/datum/gas/zauker = "[/datum/gas/zauker::name] is consumed at [ZAUKER_DECOMPOSITION_MAX_RATE SECONDS / SSair.wait] moles per second in any unique gas mixture.",
		/datum/gas/nitrogen = "At least [MINIMUM_MOLE_COUNT] moles of [/datum/gas/nitrogen::name] needs to be present for this reaction to occur. \
			[/datum/gas/nitrogen::name] is produced at 0.7 moles per mole of [/datum/gas/zauker::name] decomposed.",
		/datum/gas/oxygen = "[/datum/gas/oxygen::name] is produced at 0.3 moles per mole of [/datum/gas/zauker::name] decomposed.",
		"Energy" = "[ZAUKER_DECOMPOSITION_ENERGY] joules of energy is released per mole of [/datum/gas/zauker::name] decomposed.",
	)

/datum/gas_reaction/standard/proto_nitrate_formation/init_factors()
	factor = list(
		/datum/gas/pluoxium = "[/datum/gas/pluoxium::name] is consumed at 1/11th of a mole per mole of [/datum/gas/proto_nitrate::name] formed.",
		/datum/gas/hydrogen = "[/datum/gas/hydrogen::name] is consumed at 10/11th of a mole per mole of [/datum/gas/proto_nitrate::name] formed.",
		/datum/gas/proto_nitrate = "[/datum/gas/proto_nitrate::name] is produced at a rate that scales with the temperature.",
		"Energy" = "[PN_FORMATION_ENERGY / 2.2] joules of energy is released per mole of [/datum/gas/proto_nitrate::name] formed.",
		"Temperature" = "Can only occur between [PN_FORMATION_MIN_TEMPERATURE] - [PN_FORMATION_MAX_TEMPERATURE]K. \
			Higher temperature increases [/datum/gas/proto_nitrate::name] formation rate.",
	)

/datum/gas_reaction/standard/proto_nitrate_hydrogen_response/init_factors() // Fixed reaction rate
	factor = list(
		/datum/gas/hydrogen = "[PN_HYDROGEN_CONVERSION_THRESHOLD] moles of [/datum/gas/hydrogen::name] needs to be present for the reaction to occur. \
			[/datum/gas/hydrogen::name] is consumed at 2 moles per mole of [/datum/gas/proto_nitrate::name] formed.",
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of [/datum/gas/proto_nitrate::name] needs to be present for the reaction to occur. \
			[/datum/gas/proto_nitrate::name] is produced a rate that scales with its mole count, \
			up to a max of [PN_HYDROGEN_CONVERSION_MAX_RATE * 0.5 SECONDS / SSair.wait] moles per second.",
		"Energy" = "[PN_HYDROGEN_CONVERSION_ENERGY * 2] joules of energy is absorbed per mole of [/datum/gas/proto_nitrate::name] formed.",
	)

/datum/gas_reaction/standard/proto_nitrate_tritium_response/init_factors()
	factor = list(
		/datum/gas/tritium = "[/datum/gas/tritium::name] radiates its neutrons at a rate that scales with the temperature and [/datum/gas/proto_nitrate::name] mole count.",
		/datum/gas/proto_nitrate = "[/datum/gas/proto_nitrate::name] is consumed at 0.005 moles per mole of neutrons released.",
		/datum/gas/hydrogen = "[/datum/gas/hydrogen::name] remains after the neutrons escape.",
		"Energy" = "[PN_TRITIUM_CONVERSION_ENERGY / 2] joules of energy is released per mole of neutron released.",
		"Radiation" = "Neutrons are released as ionising radiation.",
	)

/datum/gas_reaction/standard/proto_nitrate_bz_response/init_factors()
	factor = list(
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of [/datum/gas/proto_nitrate::name] needs to be present for the reaction to occur. \
			[/datum/gas/proto_nitrate::name] accelerates the [/datum/gas/bz::name] decomposition.",
		/datum/gas/bz = "[/datum/gas/bz::name] gets decomposed into [/datum/gas/plasma::name] and [/datum/gas/nitrous_oxide::name]. \
			The [/datum/gas/nitrous_oxide::name] then decomposes into [/datum/gas/nitrogen::name] and [/datum/gas/oxygen::name], \
			with the [/datum/gas/oxygen::name] then decaying into [/datum/gas/helium::name].",
		/datum/gas/nitrogen = "[/datum/gas/nitrogen::name] is produced at 0.4 moles per mole of [/datum/gas/bz::name] decomposed.",
		/datum/gas/helium = "[/datum/gas/helium::name] is produced at 1.6 moles per mole of [/datum/gas/bz::name] decomposed.",
		/datum/gas/plasma = "[/datum/gas/plasma::name] is produced at 0.8 moles per mole of [/datum/gas/bz::name] decomposed.",
		"Energy" = "[PN_BZASE_ENERGY] joules of energy is released per mole of [/datum/gas/bz::name] decomposed.",
		"Radiation" = "Radiation is released during this decomposition process.",
		"Hallucinations" = "This reaction can cause various carbon based lifeforms in the vicinity to hallucinate.",
		"Nuclear Particles" = "This reaction emits extremely high energy nuclear particles, \
			up to [2 * PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM] per second per unique gas mixture.",
		"Temperature" = "Can only occur between [PN_BZASE_MIN_TEMP] - [PN_BZASE_MAX_TEMP]K.",
	)

/datum/gas_reaction/standard/antinoblium_replication/init_factors()
	factor = list(
		/datum/gas/antinoblium = "[MOLES_GAS_VISIBLE] moles of [/datum/gas/antinoblium::name] is needed to replicate itself. \
			Requires other gases to be converted to [/datum/gas/antinoblium::name].",
		"Temperature" = "Can only occur above [REACTION_OPPRESSION_MIN_TEMP]K."
	)
