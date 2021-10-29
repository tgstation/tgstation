/datum/chemical_reaction/medicine/lidocaine
	results = list(/datum/reagent/medicine/lidocaine = 4)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/hydrogen = 1, /datum/reagent/oxygen = 1, /datum/reagent/potassium = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER | REACTION_TAG_DRUG
	required_temp = 320 // fermichem stuff, pain in the ass
	optimal_temp = 400
	overheat_temp = 600
	optimal_ph_min = 6
	optimal_ph_max = 9
	determin_ph_range = 2
	temp_exponent_factor = 0.8
	ph_exponent_factor = 2
	thermic_constant = 87
	H_ion_release = -0.05
	rate_up_lim = 15
	purity_min = 0.1

/datum/chemical_reaction/medicine/lidocaine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	if(off_cooldown(holder, equilibrium, 10, "lidocaine"))
		explode_attack_chem(holder, equilibrium, /datum/reagent/inverse/lidocaine, 5)
		explode_invert_smoke(holder, equilibrium)
