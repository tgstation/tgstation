// Reagent used as blood by Insect- or Snail-people.
// Precursor chems and recipes listed here for ease of use/reference.
/datum/reagent/bug_blood
	name = "Hemolymph"
	description = "A blood analog found in invertebrate species. Transports oxygen by binding it to copper, as opposed to the more common iron."
	taste_description = "viscous copper"
	taste_mult = 5
	color = "#82fac6" //rgb 130,250,198

/datum/chemical_reaction/bug_blood
	results = list(/datum/reagent/bug_blood = 2)
	required_reagents = list(/datum/reagent/imidazole = 6, /datum/reagent/copper = 2, /datum/reagent/oxygen = 1)
	mix_message = "The solution thickens and turns a buggy-blue"
	//fermichem
	is_cold_recipe = FALSE
	required_temp = 293
	optimal_temp = 300
	overheat_temp = 365
	optimal_ph_min = 6.5
	optimal_ph_max = 7.4
	determin_ph_range = 1
	temp_exponent_factor = 2
	ph_exponent_factor = 1
	thermic_constant = 1
	H_ion_release = 0.1
	rate_up_lim = 10
	purity_min = 0
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_UNIQUE


/datum/reagent/imidazole
	name = "Imidazole"
	description = "A white water-soluble organic compound."
	taste_description = "mildly alkaline"
	taste_mult = 2.5
	color = "#FFFFFF"
	ph = 14


/datum/chemical_reaction/imidazole
	results = list(/datum/reagent/imidazole = 0.5)
	required_reagents = list(/datum/reagent/toxin/formaldehyde = 1, /datum/reagent/ammonia = 5, /datum/reagent/glyoxal = 1)
	mix_message = "The solution clouds and becomes white"
	//fermichem
	is_cold_recipe = FALSE
	required_temp = 362
	optimal_temp = 420
	overheat_temp = 529
	optimal_ph_min = 10
	optimal_ph_max = 14
	determin_ph_range = 2
	temp_exponent_factor = 1
	ph_exponent_factor = 1.5
	thermic_constant = 0.8
	H_ion_release = 2
	rate_up_lim = 10
	purity_min = 0
	reaction_tags = REACTION_TAG_CHEMICAL

/datum/reagent/glyoxal
	name = "Glyoxal"
	description = "A yellow organic compound."
	taste_description = "acidic salt"
	taste_mult = 4
	color = "#FFFF00"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/chemical_reaction/glyoxal
	results = list(/datum/reagent/glyoxal = 2)
	required_reagents = list(/datum/reagent/acetaldehyde = 1, /datum/reagent/toxin/acid/nitracid = 1)
	required_catalysts = list(/datum/reagent/oxygen = 10)
	//fermichem
	is_cold_recipe = FALSE
	required_temp = 270
	optimal_temp = 324
	overheat_temp = 558
	optimal_ph_min = 3
	optimal_ph_max = 8
	determin_ph_range = 2
	temp_exponent_factor = 1.4
	thermic_constant = 50
	rate_up_lim = 30
	reaction_tags = REACTION_TAG_CHEMICAL
