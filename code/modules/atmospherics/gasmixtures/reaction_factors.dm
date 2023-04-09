/datum/gas_reaction/water_vapor/init_factors()
	factor = list(
		/datum/gas/water_vapor = "Condensation will consume [MOLES_GAS_VISIBLE] moles, freezing will not consume any. Both needs a minimum of [MOLES_GAS_VISIBLE] moles to occur.",
		"Temperature" = "Freezes a turf at [WATER_VAPOR_DEPOSITION_POINT] Kelvins or below, wets it at [WATER_VAPOR_CONDENSATION_POINT] Kelvins or below.",
		"Location" = "Can only happen on turfs.",
	)

/datum/gas_reaction/miaster/init_factors()
	factor = list(
		/datum/gas/miasma = "Miasma is consumed at 1 reaction rate.",
		/datum/gas/oxygen = "Oxygen is produced at 1 reaction rate.",
		"Temperature" = "Higher temperature increases the reaction rate.",
		"Energy" = "[MIASTER_STERILIZATION_ENERGY] joules of energy is released per rate.",
	)

/datum/gas_reaction/plasmafire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen consumption is determined by the temperature, ranging from [OXYGEN_BURN_RATIO_BASE] of the reaction rate at [PLASMA_MINIMUM_BURN_TEMPERATURE] Kelvins to [OXYGEN_BURN_RATIO_BASE-1] at [PLASMA_UPPER_TEMPERATURE] Kelvins. Higher oxygen concentration up to [PLASMA_OXYGEN_FULLBURN]x times the plasma increases the reaction rate.",
		/datum/gas/plasma = "Plasma is consumed at 1 reaction rate. It's relationship with oxygen also determines reaction speed",
		/datum/gas/tritium = "Tritium is formed at 1 reaction rate if there are 97 times more oxygen than plasma.",
		/datum/gas/water_vapor = "Water vapor is formed at 0.25 reaction rate if tritium isn't being formed.",
		/datum/gas/carbon_dioxide = "Carbon Dioxide is formed at 0.75 reaction rate if tritium isn't being formed.",
		"Temperature" = "Minimum temperature of [PLASMA_MINIMUM_BURN_TEMPERATURE] kelvin to occur. Higher temperature up to [PLASMA_UPPER_TEMPERATURE] increases the oxygen efficiency and also the reaction rate.",
		"Energy" = "[FIRE_PLASMA_ENERGY_RELEASED] joules of energy is released per reaction rate",
	)

/datum/gas_reaction/h2fire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen is consumed at 0.5 reaction rate. Higher oxygen concentration up to [HYDROGEN_OXYGEN_FULLBURN] times the hydrogen increases the reaction rate.",
		/datum/gas/hydrogen = "Hydrogen is consumed at 1 reaction rate. Its relationship with oxygen also determines the reaction speed.",
		/datum/gas/water_vapor = "Water vapor is formed at 1 reaction rate.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin to occur",
		"Energy" = "[FIRE_HYDROGEN_ENERGY_RELEASED] joules of energy is released per mol of hydrogen consumed.",
	)

/datum/gas_reaction/tritfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen is consumed at 0.5 reaction rate. Higher oxygen concentration up to [TRITIUM_OXYGEN_FULLBURN] times the tritium increases the reaction rate.",
		/datum/gas/tritium = "Tritium is consumed at 1 reaction rate. Its relationship with oxygen also determines the reaction speed.",
		/datum/gas/water_vapor = "Water vapor is formed at 1 reaction rate.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin to occur",
		"Energy" = "[FIRE_TRITIUM_ENERGY_RELEASED] joules of energy is released per mol of tritium consumed.",
		"Radiation" = "This reaction emits radiation proportional to the amount of energy released.",
	)

/datum/gas_reaction/freonfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen consumption is determined by the temperature, ranging from [OXYGEN_BURN_RATIO_BASE] of the reaction rate at [FREON_LOWER_TEMPERATURE] Kelvins to [OXYGEN_BURN_RATIO_BASE-1] at [FREON_MAXIMUM_BURN_TEMPERATURE] Kelvins. Higher oxygen concentration up to [FREON_OXYGEN_FULLBURN] times the freon increases the reaction rate.",
		/datum/gas/freon = "Freon is consumed at 1 reaction rate. It's relationship with oxygen also determines reaction speed",
		/datum/gas/carbon_dioxide = "Carbon Dioxide is formed at 1 reaction rate.",
		"Temperature" = "Can only occur between [FREON_LOWER_TEMPERATURE] - [FREON_MAXIMUM_BURN_TEMPERATURE] Kelvin",
		"Energy" = "[FIRE_FREON_ENERGY_CONSUMED] joules of energy is absorbed per reaction rate",
		"Hot Ice" = "This reaction has a small chance to produce hot ice when occuring between [HOT_ICE_FORMATION_MINIMUM_TEMPERATURE]-[HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE] kelvins",
	)


/datum/gas_reaction/nitrousformation/init_factors()
	factor = list(
		/datum/gas/oxygen = "10 moles of Oxygen needs to be present for the reaction to occur. Oxygen is consumed at 1 reaction rate",
		/datum/gas/nitrogen = " 20 moles of Nitrogen needs to be present for the reaction to occur. Nitrogen is consumed at 2 reaction rate",
		/datum/gas/bz = "5 moles of BZ needs to be present for the reaction to occur. Not consumed.",
		/datum/gas/nitrous_oxide = "Nitrous oxide is produced at 1 reaction rate",
		"Temperature" = "Can only occur between [N2O_FORMATION_MIN_TEMPERATURE] - [N2O_FORMATION_MAX_TEMPERATURE] Kelvin",
		"Energy" = "[N2O_FORMATION_ENERGY] joules of energy is released per reaction rate",
	)

/datum/gas_reaction/nitrous_decomp/init_factors()
	factor = list(
		/datum/gas/nitrous_oxide = "Nitrous Oxide is consumed at 1 reaction rate. Minimum of [MINIMUM_MOLE_COUNT * 2] to occur.", //okay this one isn't made into a define yet.
		/datum/gas/oxygen = "Oxygen is formed at 0.5 reaction rate",
		/datum/gas/nitrogen = "Nitrogen is formed at 1 reaction rate",
		"Temperature" = "Higher temperature increases the reaction rate. Can only happen between [N2O_DECOMPOSITION_MIN_TEMPERATURE] - [N2O_DECOMPOSITION_MAX_TEMPERATURE] kelvin.",
		"Energy" = "[N2O_DECOMPOSITION_ENERGY] joules of energy is released per reaction rate",
	)

/datum/gas_reaction/bzformation/init_factors()
	factor = list(
		/datum/gas/plasma = "Each mole of BZ made consumes 0.8 moles of plasma. If there is more plasma than nitrous oxide reaction rate is slowed down.",
		/datum/gas/nitrous_oxide = "Each mole of bz made consumes 0.4 moles of Nitrous oxide. If there is less nitrous oxide than plasma the reaction rate is slowed down. At three times the amount of plasma to Nitrous oxide it will start breaking down into Nitrogen and Oxygen, the lower the ratio the more Nitrous oxide decomposes.",
		/datum/gas/bz = "The lower the pressure and larger the volume the more bz gets made. Less nitrous oxide than plasma will slow down the reaction.",
		/datum/gas/nitrogen = "Each mole Nitrous oxide decomposed makes 1 mol Nitrogen. Lower ratio of Nitrous oxide to Plasma means a higher ratio of decomposition to BZ production.",
		/datum/gas/oxygen = "Each mole Nitrous oxide decomposed makes 0.5 moles Oxygen. Lower ratio of Nitrous oxide to Plasma means a higher ratio of decomposition to BZ production.",
		"Energy" = "[BZ_FORMATION_ENERGY] joules of energy is released per mol of BZ made. Nitrous oxide decomposition releases [N2O_DECOMPOSITION_ENERGY] per mol decomposed",
	)

/datum/gas_reaction/pluox_formation/init_factors()
	factor = list(
		/datum/gas/carbon_dioxide = "Carbon dioxide is consumed at 1 reaction rate",
		/datum/gas/oxygen = "Oxygen is consumed at 0.5 reaction rate",
		/datum/gas/tritium = "Tritium is consumed at 0.01 reaction rate",
		/datum/gas/pluoxium = "Pluoxium is produced at 1 reaction rate",
		/datum/gas/hydrogen = "Hydrogen is produced at 0.01 reaction rate",
		"Energy" = "[PLUOXIUM_FORMATION_ENERGY] joules of energy is released per reaction rate",
		"Temperature" = "Can only occur between [PLUOXIUM_FORMATION_MIN_TEMP] - [PLUOXIUM_FORMATION_MAX_TEMP] Kelvin",
	)

/datum/gas_reaction/nitrium_formation/init_factors()
	factor = list(
		/datum/gas/bz = "5 moles of BZ needs to be present for the reaction to occur. BZ is consumed at 0.05 reaction rate.",
		/datum/gas/tritium = "20 moles of tritium needs to be present for the reaction to occur. Tritium is consumed at 1 reaction rate",
		/datum/gas/nitrogen = "10 moles of tritium needs to be present for the reaction to occur. Nitrogen is consumed at 1 reaction rate",
		/datum/gas/nitrium = "Nitrium is produced at 1 reaction rate",
		"Temperature" = "Can only occur above [NITRIUM_FORMATION_MIN_TEMP] kelvins",
		"Energy" = "[NITRIUM_FORMATION_ENERGY] joules of energy is absorbed per reaction rate",
	)

/datum/gas_reaction/nitrium_decomposition/init_factors()
	factor = list(
		/datum/gas/oxygen = "[MINIMUM_MOLE_COUNT] moles of oxygen need to be present for the reaction to occur. Not consumed.",
		/datum/gas/nitrium = "Nitrium is consumed at 1 reaction rate",
		/datum/gas/hydrogen = "Hydrogen is produced at 1 reaction rate",
		/datum/gas/nitrogen = "Nitrogen is produced at 1 reaction rate",
		"Temperature" = " Can only occur below [NITRIUM_DECOMPOSITION_MAX_TEMP]. Higher temperature increases the reaction rate.",
		"Energy" = "[NITRIUM_DECOMPOSITION_ENERGY] joules of energy is released per reaction rate",
	)

/datum/gas_reaction/freonformation/init_factors()
	factor = list(
		/datum/gas/plasma = "At least 0.06 moles of plasma needs to be present. Plasma is consumed at 0.6 moles per tile/pipenet",
		/datum/gas/carbon_dioxide = "At least 0.03 moles of CO2 needs to be present. CO2 is consumed at 0.3 moles per tile/pipenet",
		/datum/gas/bz = "At least 0.01 moles of BZ needs to be present. BZ is consumed at 0.1 moles per tile/pipenet",
		/datum/gas/freon = "Freon is produced at 1 mole per tile/pipenet",
		"Energy" = "Between 100 and 800 joules of energy is absorbed per mole of freon produced",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100] Kelvin to occur, with production peak at 800 K. However at temperatures above 5500 K higher rates are possible maxing out at three times the low temperature rate at over 8500 K.",
	)

/datum/gas_reaction/nobliumformation/init_factors()
	factor = list(
		/datum/gas/nitrogen = "10 moles of nitrogen needs to be present for the reaction to occur. Nitrogen is consumed at 10 reaction rate",
		/datum/gas/tritium = "5 moles of tritium needs to be present for the reaction to occur. Tritium is consumed at 5 reaction rate",
		/datum/gas/hypernoblium = "Hyper-Noblium is produced at 1 reaction rate",
		"Energy" = "[NOBLIUM_FORMATION_ENERGY] joules of energy is released per reaction rate.",
		/datum/gas/bz = "BZ is not consumed in the reaction but will lower the amount of energy released. It also reduces amount of trit consumed by a ratio between trit and bz, greater bz than trit will reduce more.",
		"Temperature" = "Can only occur between [NOBLIUM_FORMATION_MIN_TEMP] - [NOBLIUM_FORMATION_MAX_TEMP] kelvin",
	)

/datum/gas_reaction/halon_o2removal/init_factors()
	factor = list(
		/datum/gas/halon = "Halon is consumed at 1 reaction rate",
		/datum/gas/oxygen = "Oxygen is consumed at 20 reaction rate",
		/datum/gas/carbon_dioxide = "Carbon dioxide is produced at 5 reaction rate.",
		"Energy" = "[HALON_COMBUSTION_ENERGY] joules of energy is absorbed per reaction rate",
		"Temperature" = "Can only occur above [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin. Higher temperature increases the reaction rate.",
	)

/datum/gas_reaction/healium_formation/init_factors()
	factor = list(
		/datum/gas/bz = "BZ is consumed at 0.25 reaction rate",
		/datum/gas/freon = "Freon is consumed at 2.75 reaction rate",
		/datum/gas/healium = "Healium is produced at 3 reaction rate",
		"Temperature" = "Can only occur between [HEALIUM_FORMATION_MIN_TEMP] - [HEALIUM_FORMATION_MAX_TEMP]. Higher temperature increases the reaction rate.",
		"Energy" = "[HEALIUM_FORMATION_ENERGY] joules of energy is released per reaction rate.",
	)

/datum/gas_reaction/zauker_formation/init_factors()
	factor = list(
		/datum/gas/hypernoblium = "Hyper-Noblium is consumed at 0.01 reaction rate",
		/datum/gas/nitrium = "Nitrium is consumed at 0.5 reaction rate",
		/datum/gas/zauker = "Zauker is produced at 0.5 reaction rate",
		"Temperature" = "Can only occur between [ZAUKER_FORMATION_MIN_TEMPERATURE] - [ZAUKER_FORMATION_MAX_TEMPERATURE] kelvin",
		"Energy" = "[ZAUKER_FORMATION_ENERGY] joules of energy is absorbed per reaction rate",
	)

/datum/gas_reaction/zauker_decomp/init_factors() //Fixed reaction rate
	factor = list(
		/datum/gas/zauker = "Zauker is consumed at 1 reaction rate",
		/datum/gas/nitrogen = "At least [MINIMUM_MOLE_COUNT] moles of Nitrogen needs to be present for this reaction to occur. Nitrogen is produced at 0.7 reaction rate",
		/datum/gas/oxygen = "Oxygen is produced at 0.3 reaction rate",
		"Energy" = "[ZAUKER_DECOMPOSITION_ENERGY] joules of energy is released per reaction rate",
	)

/datum/gas_reaction/proto_nitrate_formation/init_factors()
	factor = list(
		/datum/gas/pluoxium = "Pluoxium is consumed at 0.2 reaction rate",
		/datum/gas/hydrogen = "Hydrogen is consumed at 2 reaction rate",
		/datum/gas/proto_nitrate = "Proto-Nitrate is produced at 2.2 reaction rate",
		"Energy" = "[PN_FORMATION_ENERGY] joules of energy is released per reaction rate",
		"Temperature" = "Can only occur between [PN_FORMATION_MIN_TEMPERATURE] - [PN_FORMATION_MAX_TEMPERATURE] kelvin. Higher temperature increases the reaction rate.",
	)

/datum/gas_reaction/proto_nitrate_hydrogen_response/init_factors() // Fixed reaction rate
	factor = list(
		/datum/gas/hydrogen = "[PN_HYDROGEN_CONVERSION_THRESHOLD] moles of hydrogen needs to be present for the reaction to occur. Hydrogen is consumed at 1 reaction rate.",
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of proto-nitrate needs to be present for the reaction to occur. Proto nitrate is produced at 0.5 reaction rate.",
		"Energy" = "[PN_HYDROGEN_CONVERSION_ENERGY] joules of energy is absorbed per reaction rate",
	)

/datum/gas_reaction/proto_nitrate_tritium_response/init_factors()
	factor = list(
		/datum/gas/tritium = "Tritium is consumed at 1 reaction rate.",
		/datum/gas/proto_nitrate = "Proto nitrate is consumed at 0.01 reaction rate.",
		/datum/gas/hydrogen = "Hydrogen is produced at 1 reaction rate.",
		"Energy" = "[PN_TRITIUM_CONVERSION_ENERGY] joules of energy is released per reaction rate",
		"Radiation" = "This reaction emits radiation proportional to the reaction rate.",
	)

/datum/gas_reaction/proto_nitrate_bz_response/init_factors()
	factor = list(
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of proto-nitrate needs to be present for the reaction to occur",
		/datum/gas/bz = "BZ is consumed at 1 reaction rate.",
		/datum/gas/nitrogen = "Nitrogen is produced at 0.4 reaction rate.",
		/datum/gas/helium = "Helium is produced at 1.6 reaction rate.",
		/datum/gas/plasma = "Plasma is produced at 0.8 reaction rate.",
		"Energy" = "[PN_BZASE_ENERGY] joules of energy is released per reaction rate",
		"Radiation" = "This reaction emits radiation proportional to the reaction rate.",
		"Hallucinations" = "This reaction can cause various carbon based lifeforms in the vicinity to hallucinate.",
		"Nuclear Particles" = "This reaction emits extremely high energy nuclear particles, up to [PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM] per reaction rate.",
	)
