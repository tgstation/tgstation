/datum/gas_reaction/water_vapor/init_factors()
	factor = list(
		/datum/gas/water_vapor = "Condensation will consume [MOLES_GAS_VISIBLE] moles, freezing will not consume any. Both needs a minimum of [MOLES_GAS_VISIBLE] moles to occur.",
		"Temperature" = "Freezes a turf at [WATER_VAPOR_DEPOSITION_POINT] Kelvins or below, wets it at [WATER_VAPOR_CONDENSATION_POINT] Kelvins or below.",
		"Location" = "Can only happen on turfs.",
	)

/datum/gas_reaction/miaster/init_factors()
	factor = list(
		/datum/gas/miasma = "Miasma is sterilized at a rate that scales with the difference between the temperature and [MIASTER_STERILIZATION_TEMP]K.",
		/datum/gas/oxygen = "One mole of oxygen is released per mole of miasma consumed.",
		"Temperature" = "Higher temperature increases the speed of miasma sterilization.",
		"Energy" = "[MIASTER_STERILIZATION_ENERGY] joules of energy is released per mole of miasma sterilized.",
	)

/datum/gas_reaction/plasmafire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen consumption is determined by the temperature, ranging from [OXYGEN_BURN_RATIO_BASE] moles per mole of plasma consumed at [PLASMA_MINIMUM_BURN_TEMPERATURE] Kelvins to [OXYGEN_BURN_RATIO_BASE-1] moles per mole of plasma consumed at [PLASMA_UPPER_TEMPERATURE] Kelvins. Higher oxygen concentration up to [PLASMA_OXYGEN_FULLBURN] times the plasma increases the speed of plasma consumption.",
		/datum/gas/plasma = "Plasma is consumed at a rate that scales with the difference between the temperature and [PLASMA_MINIMUM_BURN_TEMPERATURE]K, with maximum scaling at [PLASMA_UPPER_TEMPERATURE]K.",
		/datum/gas/tritium = "Tritium is formed at 1 mole per mole of plasma consumed if there are at least 97 times more oxygen than plasma.",
		/datum/gas/water_vapor = "Water vapor is formed at 0.25 moles per mole of plasma consumed if tritium isn't being formed.",
		/datum/gas/carbon_dioxide = "Carbon Dioxide is formed at 0.75 moles per mole of plasma consumed if tritium isn't being formed.",
		"Temperature" = "Minimum temperature of [PLASMA_MINIMUM_BURN_TEMPERATURE] kelvin to occur. Higher temperature up to [PLASMA_UPPER_TEMPERATURE]K increases the oxygen efficiency and also the plasma consumption rate.",
		"Energy" = "[FIRE_PLASMA_ENERGY_RELEASED] joules of energy is released per mole of plasma consumed.",
	)

/datum/gas_reaction/h2fire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen is consumed at 0.5 moles per mole of hydrogen consumed. Higher oxygen concentration up to [HYDROGEN_OXYGEN_FULLBURN] times the hydrogen increases the hydrogen consumption rate.",
		/datum/gas/hydrogen = "Hydrogen is consumed rapidly fast as long as there's enough oxygen to allow combustion.",
		/datum/gas/water_vapor = "Water vapor is produced at 1 mole per mole of hydrogen combusted.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin to occur",
		"Energy" = "[FIRE_HYDROGEN_ENERGY_RELEASED] joules of energy is released per mol of hydrogen consumed.",
	)

/datum/gas_reaction/tritfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen is consumed at 0.5 moles per mole of tritium consumed. Higher oxygen concentration up to [TRITIUM_OXYGEN_FULLBURN] times the tritium increases the tritium consumption rate.",
		/datum/gas/tritium = "Tritium is consumed at rapidly fast as long as there's enough oxygen to allow combustion.",
		/datum/gas/water_vapor = "Water vapor is produced at 1 mole per mole of tritium combusted.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin to occur",
		"Energy" = "[FIRE_TRITIUM_ENERGY_RELEASED] joules of energy is released per mol of tritium consumed.",
		"Radiation" = "This reaction emits radiation proportional to the amount of energy released.",
	)

/datum/gas_reaction/freonfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen consumption is determined by the temperature, ranging from [OXYGEN_BURN_RATIO_BASE] moles per mole of freon consumed at [FREON_LOWER_TEMPERATURE] Kelvins to [OXYGEN_BURN_RATIO_BASE-1] moles per mole of freon consumed at [FREON_MAXIMUM_BURN_TEMPERATURE] Kelvins. Higher oxygen concentration up to [FREON_OXYGEN_FULLBURN] times the freon increases freon consumption rate.",
		/datum/gas/freon = "Freon is consumed at a rate that scales with the distance of the temperature from [FREON_MAXIMUM_BURN_TEMPERATURE]K. Its relationship with oxygen also determines consumption rate.",
		/datum/gas/carbon_dioxide = "Carbon Dioxide is formed at 1 mole per mole of freon consumed.",
		"Temperature" = "Can only occur between [FREON_LOWER_TEMPERATURE] - [FREON_MAXIMUM_BURN_TEMPERATURE] Kelvin",
		"Energy" = "[FIRE_FREON_ENERGY_CONSUMED] joules of energy is absorbed per mole of freon consumed.",
		"Hot Ice" = "This reaction produces hot ice when occurring between [HOT_ICE_FORMATION_MINIMUM_TEMPERATURE]-[HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE] kelvins",
	)


/datum/gas_reaction/nitrousformation/init_factors()
	factor = list(
		/datum/gas/oxygen = "10 moles of Oxygen needs to be present for the reaction to occur. Oxygen is consumed at 0.5 moles per mole of nitrous oxide formed.",
		/datum/gas/nitrogen = " 20 moles of Nitrogen needs to be present for the reaction to occur. Nitrogen is consumed at 1 mole per mole of nitrous oxide formed.",
		/datum/gas/bz = "5 moles of BZ needs to be present for the reaction to occur. Not consumed.",
		/datum/gas/nitrous_oxide = "Nitrous oxide gets produced rapidly.",
		"Temperature" = "Can only occur between [N2O_FORMATION_MIN_TEMPERATURE] - [N2O_FORMATION_MAX_TEMPERATURE] Kelvin",
		"Energy" = "[N2O_FORMATION_ENERGY] joules of energy is released per mole of nitrous oxide formed.",
	)

/datum/gas_reaction/nitrous_decomp/init_factors()
	factor = list(
		/datum/gas/nitrous_oxide = "Nitrous Oxide is decomposed at a rate that scales negatively with the distance between the temperature and average of the minimum and maximum temperature of the reaction. Minimum of [MINIMUM_MOLE_COUNT * 2] to occur.", //okay this one isn't made into a define yet.
		/datum/gas/oxygen = "Oxygen is formed at 0.5 moles per mole of nitrous oxide decomposed.",
		/datum/gas/nitrogen = "Nitrogen is formed at 1 mole per mole of nitrous oxide decomposed.",
		"Temperature" = "The decomposition rate scales with the product of the distances between temperature and minimum and maximum temperature. Can only happen between [N2O_DECOMPOSITION_MIN_TEMPERATURE] - [N2O_DECOMPOSITION_MAX_TEMPERATURE] kelvin.",
		"Energy" = "[N2O_DECOMPOSITION_ENERGY] joules of energy is released per mole of nitrous oxide decomposed.",
	)

/datum/gas_reaction/bzformation/init_factors()
	factor = list(
		/datum/gas/plasma = "Each mole of BZ made consumes 0.8 moles of plasma. If there is more plasma than nitrous oxide, bz formation rate gets slowed down.",
		/datum/gas/nitrous_oxide = "Each mole of bz made consumes 0.4 moles of Nitrous oxide. If there is less nitrous oxide than plasma the reaction rate is slowed down. At three times the amount of plasma to Nitrous oxide it will start breaking down into Nitrogen and Oxygen, the lower the ratio the more Nitrous oxide decomposes.",
		/datum/gas/bz = "The lower the pressure and larger the volume the more bz gets made. Less nitrous oxide than plasma will slow down the reaction.",
		/datum/gas/nitrogen = "Each mole Nitrous oxide decomposed makes 1 mol Nitrogen. Lower ratio of Nitrous oxide to Plasma means a higher ratio of decomposition to BZ production.",
		/datum/gas/oxygen = "Each mole Nitrous oxide decomposed makes 0.5 moles Oxygen. Lower ratio of Nitrous oxide to Plasma means a higher ratio of decomposition to BZ production.",
		"Energy" = "[BZ_FORMATION_ENERGY] joules of energy is released per mol of BZ made. Nitrous oxide decomposition releases [N2O_DECOMPOSITION_ENERGY] per mol decomposed",
	)

/datum/gas_reaction/pluox_formation/init_factors()
	factor = list(
		/datum/gas/carbon_dioxide = "1 mole of carbon dioxide gets consumed per mole of pluoxium formed.",
		/datum/gas/oxygen = "Oxygen is consumed at 0.5 moles per mole of pluoxium formed.",
		/datum/gas/tritium = "Tritium is converted into hydrogen at 0.01 moles per mole of pluoxium formed.",
		/datum/gas/pluoxium = "Pluoxium is produced at a constant rate in any given mixture.",
		/datum/gas/hydrogen = "Hydrogen is formed from the tritium losing their neutrons.",
		"Energy" = "[PLUOXIUM_FORMATION_ENERGY] joules of energy is released per mole of pluoxium formed.",
		"Temperature" = "Can only occur between [PLUOXIUM_FORMATION_MIN_TEMP] - [PLUOXIUM_FORMATION_MAX_TEMP] Kelvin",
	)

/datum/gas_reaction/nitrium_formation/init_factors()
	factor = list(
		/datum/gas/bz = "5 moles of BZ needs to be present for the reaction to occur. BZ is consumed at 0.05 moles per mole of nitrium formed.",
		/datum/gas/tritium = "20 moles of tritium needs to be present for the reaction to occur. Tritium is consumed at 1 mole per mole of nitroum formed.",
		/datum/gas/nitrogen = "10 moles of nitrogen needs to be present for the reaction to occur. Nitrogen is consumed at 1 mole per mole of nitrium formed.",
		/datum/gas/nitrium = "Nitrium is produced at a rate that scales with the temperature.",
		"Temperature" = "Can only occur above [NITRIUM_FORMATION_MIN_TEMP] kelvins",
		"Energy" = "[NITRIUM_FORMATION_ENERGY] joules of energy is absorbed per mole of nitrium formed.",
	)

/datum/gas_reaction/nitrium_decomposition/init_factors()
	factor = list(
		/datum/gas/oxygen = "[MINIMUM_MOLE_COUNT] moles of oxygen need to be present for the reaction to occur. Not consumed.",
		/datum/gas/nitrium = "Nitrium is consumed at a rate that scales with the temperature.",
		/datum/gas/hydrogen = "Hydrogen is produced at 1 mole per mole of nitrium decomposed.",
		/datum/gas/nitrogen = "Nitrogen is produced at 1 mole per mole of nitrium decomposed.",
		"Temperature" = "Can only occur below [NITRIUM_DECOMPOSITION_MAX_TEMP]. Higher temperature increases the nitrium decomposition rate.",
		"Energy" = "[NITRIUM_DECOMPOSITION_ENERGY] joules of energy is released per mole of nitrium decomposed.",
	)

/datum/gas_reaction/freonformation/init_factors()
	factor = list(
		/datum/gas/plasma = "At least 0.06 moles of plasma needs to be present. Plasma is consumed at 0.6 moles per mole of freon formed.",
		/datum/gas/carbon_dioxide = "At least 0.03 moles of CO2 needs to be present. CO2 is consumed at 0.3 moles per mole of freon formed.",
		/datum/gas/bz = "At least 0.01 moles of BZ needs to be present. BZ is consumed at 0.1 moles per mole of freon formed.",
		/datum/gas/freon = "Freon is produced at a rate that scales with the sum of a quadratic exponential and sigmoidal function, with the quadratic exponential peaking at 800 Kelvin, but the sigmoidal function takes dominance at over 5,500K being up to 3 times more efficient.",
		"Energy" = "Between 100 and 800 joules of energy is absorbed per mole of freon produced", // I don't know why the energy release is also a sigmoidal function, but it should really just be constant to be honest.
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100] Kelvin to occur, with production peak at 800 K. However at temperatures above 5500 K higher rates are possible maxing out at three times the low temperature rate at over 8500 K.",
	)

/datum/gas_reaction/nobliumformation/init_factors()
	factor = list(
		/datum/gas/nitrogen = "10 moles of nitrogen needs to be present for the reaction to occur. Nitrogen is consumed at 10 moles per mole of hypernoblium formed.",
		/datum/gas/tritium = "5 moles of tritium needs to be present for the reaction to occur. Tritium is consumed at 5 moles per mole of hypernoblium formed. The relative consumption rate of tritium decreases in the exposure of BZ.",
		/datum/gas/hypernoblium = "Hyper-Noblium production scales based on the sum of the nitrogen and tritium moles.",
		"Energy" = "[NOBLIUM_FORMATION_ENERGY] joules of energy is released per mole of hypernoblium produced.",
		/datum/gas/bz = "BZ is not consumed in the reaction but will lower the amount of energy released. It also reduces amount of tritium consumed by a ratio between tritium and bz, greater bz than tritium will reduce more.",
		"Temperature" = "Can only occur between [NOBLIUM_FORMATION_MIN_TEMP] - [NOBLIUM_FORMATION_MAX_TEMP] kelvin",
	)

/datum/gas_reaction/halon_o2removal/init_factors()
	factor = list(
		/datum/gas/halon = "Halon is consumed at a rate that scales with temperature.",
		/datum/gas/oxygen = "20 moles of oxygen is consumed per mole of halon combusted.",
		/datum/gas/carbon_dioxide = "Carbon dioxide is produced at 5 moles per mole of halon consumed.",
		"Energy" = "[HALON_COMBUSTION_ENERGY] joules of energy is absorbed per mole of halon consumed.",
		"Temperature" = "Can only occur above [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin. Higher temperature increases halon consumption rate.",
	)

/datum/gas_reaction/healium_formation/init_factors()
	factor = list(
		/datum/gas/bz = "BZ is consumed at 1/12th of a mole per mole of healium formed.",
		/datum/gas/freon = "Freon is consumed at 11/12th of a mole per mole of healium formed.",
		/datum/gas/healium = "Healium is formed at a rate that scales with the temperature.",
		"Temperature" = "Can only occur between [HEALIUM_FORMATION_MIN_TEMP] - [HEALIUM_FORMATION_MAX_TEMP]. Higher temperature increases healium formation rate.",
		"Energy" = "[HEALIUM_FORMATION_ENERGY/3] joules of energy is released per mole of healium formed.",
	)

/datum/gas_reaction/zauker_formation/init_factors()
	factor = list(
		/datum/gas/hypernoblium = "Hyper-Noblium is consumed at 0.02 moles per mole of zauker formed.",
		/datum/gas/nitrium = "Nitrium is consumed at 1 mole per mole of zauker formed.",
		/datum/gas/zauker = "Zauker is produced at a rate that scales with the temperature.",
		"Temperature" = "Can only occur between [ZAUKER_FORMATION_MIN_TEMPERATURE] - [ZAUKER_FORMATION_MAX_TEMPERATURE] kelvin. Zauker formation rate is proportional to the temperature.",
		"Energy" = "[2 * ZAUKER_FORMATION_ENERGY] joules of energy is absorbed per mole of zauker formed.",
	)

/datum/gas_reaction/zauker_decomp/init_factors() //Fixed reaction rate
	factor = list(
		/datum/gas/zauker = "Zauker is consumed at [ZAUKER_DECOMPOSITION_MAX_RATE SECONDS / SSair.wait] moles per second in any unique gas mixture.",
		/datum/gas/nitrogen = "At least [MINIMUM_MOLE_COUNT] moles of Nitrogen needs to be present for this reaction to occur. Nitrogen is produced at 0.7 moles per mole of Zauker decomposed.",
		/datum/gas/oxygen = "Oxygen is produced at 0.3 moles per mole of zauker decomposed.",
		"Energy" = "[ZAUKER_DECOMPOSITION_ENERGY] joules of energy is released per mole of zauker decomposed.",
	)

/datum/gas_reaction/proto_nitrate_formation/init_factors()
	factor = list(
		/datum/gas/pluoxium = "Pluoxium is consumed at 1/11th of a mole per mole of proto-nitrate formed.",
		/datum/gas/hydrogen = "Hydrogen is consumed at 10/11th of a mole per mole of proto-nitrate formed.",
		/datum/gas/proto_nitrate = "Proto-Nitrate is produced at a rate that scales with the temperature.",
		"Energy" = "[PN_FORMATION_ENERGY / 2.2] joules of energy is released per mole of proto-nitrate formed.",
		"Temperature" = "Can only occur between [PN_FORMATION_MIN_TEMPERATURE] - [PN_FORMATION_MAX_TEMPERATURE] kelvin. Higher temperature increases proto-nitrate formation rate.",
	)

/datum/gas_reaction/proto_nitrate_hydrogen_response/init_factors() // Fixed reaction rate
	factor = list(
		/datum/gas/hydrogen = "[PN_HYDROGEN_CONVERSION_THRESHOLD] moles of hydrogen needs to be present for the reaction to occur. Hydrogen is consumed at 2 moles per mole of proto-nitrate formed.",
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of proto-nitrate needs to be present for the reaction to occur. Proto nitrate is produced a rate that scales with its mole count, up to a max of [PN_HYDROGEN_CONVERSION_MAX_RATE * 0.5 SECONDS / SSair.wait] moles per second.",
		"Energy" = "[PN_HYDROGEN_CONVERSION_ENERGY * 2] joules of energy is absorbed per mole of proto-nitrate formed.",
	)

/datum/gas_reaction/proto_nitrate_tritium_response/init_factors()
	factor = list(
		/datum/gas/tritium = "Tritium radiates its neutrons at a rate that scales with the temperature and proto-nitrate mole count.",
		/datum/gas/proto_nitrate = "Proto nitrate is consumed at 0.005 moles per mole of neutrons released.",
		/datum/gas/hydrogen = "Hydrogen remains after the neutrons escape.",
		"Energy" = "[PN_TRITIUM_CONVERSION_ENERGY / 2] joules of energy is released per mole of neutron released.",
		"Radiation" = "Neutrons get released as ionising radiation.",
	)

/datum/gas_reaction/proto_nitrate_bz_response/init_factors()
	factor = list(
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of proto-nitrate needs to be present for the reaction to occur. Proto-nitrate accelerates the BZ decomposition.",
		/datum/gas/bz = "BZ gets decomposed into plasma and nitrous oxide. The nitrous oxide then decomposes into nitrogen and oxygen, with the oxygen then decaying into helium.",
		/datum/gas/nitrogen = "Nitrogen is produced at 0.4 moles per mole of BZ decomposed.",
		/datum/gas/helium = "Helium is produced at 1.6 moles per mole of BZ decomposed.",
		/datum/gas/plasma = "Plasma is produced at 0.8 moles per mole of BZ decomposed.",
		"Energy" = "[PN_BZASE_ENERGY] joules of energy is released per mole of BZ decomposed.",
		"Radiation" = "Radiation gets released during this decomposition process.",
		"Hallucinations" = "This reaction can cause various carbon based lifeforms in the vicinity to hallucinate.",
		"Nuclear Particles" = "This reaction emits extremely high energy nuclear particles, up to [2 * PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM] per second per unique gas mixture.",
		"Temperature" = "Can only occur between [PN_BZASE_MIN_TEMP] - [PN_BZASE_MAX_TEMP] kelvin.",
	)
