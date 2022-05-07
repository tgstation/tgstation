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
		/datum/gas/oxygen = "Oxygen is consumed equal to the amount of hydrogen available on the fast burn. Not consumed on the slow burn. Needs to be more than the hydrogen amount to trigger fast burn. Acts as the reaction rate on slow burn.",
		/datum/gas/hydrogen = "[(1/HYDROGEN_BURN_H2_FACTOR)*100]% of the hydrogen is always consumed on the fast burn. [(1/HYDROGEN_BURN_OXY_FACTOR)*100]% of the oxygen amount is consumed on the slow burn. Need to be less than the oxygen amount to trigger fast burn. Acts as the reaction rate on fast burn.",
		/datum/gas/water_vapor = "Water vapor is formed at [1/HYDROGEN_BURN_H2_FACTOR] reaction rate for the fast burn, [1/HYDROGEN_BURN_OXY_FACTOR]% reaction rate for the slow burn.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin to occur",
		"Energy" = "[FIRE_HYDROGEN_ENERGY_RELEASED*HYDROGEN_OXYBURN_MULTIPLIER] joules of energy is released per rate for the fast burn, [FIRE_HYDROGEN_ENERGY_RELEASED] joules for the slow burn. Needs [MINIMUM_TRITIUM_OXYBURN_ENERGY] joules to start the fast burn.",
	)

/datum/gas_reaction/tritfire/init_factors()
	factor = list(
		/datum/gas/oxygen = "Oxygen is consumed equal to the amount of tritium available on the fast burn. Not consumed on the slow burn. Need to be more than the tritium amount to trigger fast burn. Acts as the reaction rate on slow burn.",
		/datum/gas/tritium = "[(1/TRITIUM_BURN_TRIT_FACTOR)*100]% of the tritium is always consumed on the fast burn. [(1/TRITIUM_BURN_OXY_FACTOR)*100]% of the oxygen amount is consumed on the slow burn. Need to be less than the oxygen amount to trigger fast burn. Acts as the reaction rate on fast burn.",
		/datum/gas/water_vapor = "Water vapor is formed at [1/TRITIUM_BURN_TRIT_FACTOR]% reaction rate for the fast burn, [1/TRITIUM_BURN_OXY_FACTOR]% reaction rate for the slow burn.",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST] kelvin to occur",
		"Energy" = "[FIRE_TRITIUM_ENERGY_RELEASED*TRITIUM_OXYBURN_MULTIPLIER] joules of energy is released per rate for the fast burn, [FIRE_TRITIUM_ENERGY_RELEASED] joules for the slow burn. Needs [MINIMUM_TRITIUM_OXYBURN_ENERGY] joules to start the fast burn.",
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
		/datum/gas/plasma = "Plasma is consumed at 2 reaction rate. If there is more plasma than nitrous oxide reaction rate is slowed down.",
		/datum/gas/nitrous_oxide = "Nitrous oxide is consumed at 1 reaction rate. If there is less nitrous oxide than plasma the reaction rate is slowed down.",
		/datum/gas/bz = "BZ is formed at 2.5 reaction rate. A small malus up to half a mole per tick is applied if the reaction rate is constricted by nitrous oxide.",
		/datum/gas/oxygen = "Oxygen is produced from the BZ malus. This only happens when the reaction rate is being constricted by the amount of nitrous oxide present. I.E. amount of nitrous oxide is less than the reaction rate.", // Less than the reaction rate AND half the plasma, but suppose that's not necessary to mention.
		"Pressure" = "The lower the pressure the faster the reaction rate goes.",
		"Energy" = "[FIRE_CARBON_ENERGY_RELEASED] joules of energy is released per reaction rate",
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
		/datum/gas/plasma = "40 moles of plasma needs to be present for the reaction to occur. Plasma is consumed at 1.5 reaction rate.",
		/datum/gas/carbon_dioxide = "20 moles of carbon dioxide needs to be present for the reaction to occur. Carbon dioxide is consumed at 0.75 reaction rate.",
		/datum/gas/bz = "20 moles of BZ needs to be present for the reaction to occur. BZ is consumed at 0.25 reaction rate.",
		/datum/gas/freon = "Freon is produced at 2.5 reaction rate",
		"Energy" = "[FREON_FORMATION_ENERGY] joules of energy is absorbed per reaction rate",
		"Temperature" = "Minimum temperature of [FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100] Kelvin to occur",
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

/datum/gas_reaction/proto_nitrate_tritium_response/init_factors() // Fixed reaction rate
	factor = list(
		/datum/gas/tritium = "Tritium is consumed at 1 reaction rate.",
		/datum/gas/proto_nitrate = "Proto nitrate is consumed at 0.01 reaction rate.",
		/datum/gas/hydrogen = "Hydrogen is produced at 1 reaction rate.",
		"Energy" = "[PN_TRITIUM_CONVERSION_ENERGY] joules of energy is released per reaction rate",
		"Radiation" = "This reaction emits radiation proportional to the reaction rate.",
	)

/datum/gas_reaction/proto_nitrate_bz_response/init_factors() // Fixed reaction rate
	factor = list(
		/datum/gas/proto_nitrate = "[MINIMUM_MOLE_COUNT] moles of proto-nitrate needs to be present for the reaction to occur",
		/datum/gas/bz = "BZ is consumed at 1 reaction rate.",
		/datum/gas/nitrogen = "Nitrogen is produced at 0.4 reaction rate.",
		/datum/gas/helium = "Helium is produced at 1.6 reaction rate.",
		/datum/gas/plasma = "Plasma is produced at 0.8 reaction rate.",
		"Energy" = "[PN_BZASE_ENERGY] joules of energy is released per reaction rate",
		"Radiation" = "This reaction emits radiation proportional to the reaction rate.",
		"Hallucinations" = "This reaction can cause various carbon based lifeforms in the vicinity to hallucinate.",
	)
