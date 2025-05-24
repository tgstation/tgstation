///////////////////////////PRECURSOR////////////////////////////
/datum/chemical_reaction/catalyst_precursor_temp
	results = list(/datum/reagent/catalyst_precursor_temp = 5)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/toxin/mutagen = 3, /datum/reagent/toxin/plasma = 1)
	mix_message = "The solution steams and froths."
	is_cold_recipe = TRUE
	required_temp = 800
	optimal_temp = 300
	overheat_temp = -1
	optimal_ph_min = 0.1
	optimal_ph_max = 13.9
	determin_ph_range = 5
	temp_exponent_factor = 1
	ph_exponent_factor = 0
	thermic_constant = -400
	H_ion_release = 0
	rate_up_lim = 4
	purity_min = 0.25
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/catalyst_precursor_ph
	results = list(/datum/reagent/catalyst_precursor_ph = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_temp = 5)
	mix_message = "The solution congeals."
	required_temp = 50
	optimal_temp = 500
	overheat_temp = 500
	optimal_ph_min = 6.5
	optimal_ph_max = 7.5
	determin_ph_range = 1
	temp_exponent_factor = 1
	ph_exponent_factor = 3
	thermic_constant = -800
	H_ion_release = -0.02
	rate_up_lim = 6
	purity_min = 0.35
	reaction_flags = REACTION_COMPETITIVE
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_DANGEROUS | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/catalyst_precursor_ph/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	. = ..()
	if(holder.has_reagent(/datum/reagent/gold))
		holder.remove_reagent(/datum/reagent/gold, 1)
		reaction.delta_t *= 5

/datum/chemical_reaction/catalyst_precursor_temp/competitive
	results = list(/datum/reagent/catalyst_precursor_temp = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_ph = 5)
	rate_up_lim = 3
	reaction_flags = REACTION_COMPETITIVE //Competes with /datum/chemical_reaction/catalyst_precursor_ph
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

///////////////////////////CATALYSTS////////////////////////////


/datum/chemical_reaction/thermic_modulator
	results = list(/datum/reagent/catalyst_agent/temperature/generic = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_temp = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = 0
	thermic_constant = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE

/datum/chemical_reaction/ionic_modulator
	results = list(/datum/reagent/catalyst_agent/ph/generic = 5)
	required_reagents = list(/datum/reagent/catalyst_precursor_ph = 5, /datum/reagent/stable_plasma = 5)
	H_ion_release = 0
	thermic_constant = 0
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_CHEMICAL | REACTION_TAG_COMPETITIVE




///////////////////////////MEDICINES////////////////////////////

/datum/chemical_reaction/medical_speed_catalyst
	results = list(/datum/reagent/catalyst_agent/speed/medicine = 2)
	required_reagents = list(/datum/reagent/medicine/c2/libital = 3, /datum/reagent/medicine/c2/probital = 4, /datum/reagent/toxin/plasma = 2)
	mix_message = "The reaction evaporates slightly as the mixture solidifies"
	mix_sound = 'sound/effects/chemistry/catalyst.ogg'
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_UNIQUE | REACTION_TAG_CHEMICAL
	required_temp = 200
	optimal_temp = 500
	overheat_temp = 800
	optimal_ph_min = 5
	optimal_ph_max = 6
	determin_ph_range = 5
	temp_exponent_factor = 0.5
	ph_exponent_factor = 4
	thermic_constant = 1000
	H_ion_release = -0.25
	rate_up_lim = 1
	purity_min = 0

/datum/chemical_reaction/medical_speed_catalyst/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	explode_invert_smoke(holder, equilibrium) //Will be better when the inputs have proper invert chems

/datum/chemical_reaction/medical_speed_catalyst/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	explode_invert_smoke(holder, equilibrium)
