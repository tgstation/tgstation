

/*****BRUTE*****/

/datum/chemical_reaction/helbital
	results = list(/datum/reagent/medicine/C2/helbital = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/fluorine = 1, /datum/reagent/carbon = 1)
	mix_message = "The mixture turns into a thick, yellow powder."

/datum/chemical_reaction/libital
	results = list(/datum/reagent/medicine/C2/libital = 3)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 1)

/datum/chemical_reaction/probital
	results = list(/datum/reagent/medicine/C2/probital = 4)
	required_reagents = list(/datum/reagent/copper = 1, /datum/reagent/acetone = 2,  /datum/reagent/phosphorus = 1)

/*****BURN*****/

/datum/chemical_reaction/lenturi
	results = list(/datum/reagent/medicine/C2/lenturi = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/aiuri
	results = list(/datum/reagent/medicine/C2/aiuri = 4)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/hydrogen = 2)

/datum/chemical_reaction/hercuri
	results = list(/datum/reagent/medicine/C2/hercuri = 5)
	required_reagents = list(/datum/reagent/cryostylane = 3, /datum/reagent/bromine = 1, /datum/reagent/lye = 1)
	required_temp = 47
	is_cold_recipe = TRUE

/*****OXY*****/

/datum/chemical_reaction/convermol
	results = list(/datum/reagent/medicine/C2/convermol = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/fuel/oil = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

/datum/chemical_reaction/tirimol
	results = list(/datum/reagent/medicine/C2/tirimol = 5)
	required_reagents = list(/datum/reagent/nitrogen = 3, /datum/reagent/acetone = 2)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)

/*****TOX*****/

/datum/chemical_reaction/seiver
	results = list(/datum/reagent/medicine/C2/seiver = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/potassium = 1, /datum/reagent/aluminium = 1)

/datum/chemical_reaction/multiver
	results = list(/datum/reagent/medicine/C2/multiver = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/sodiumchloride = 1)
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380

/datum/chemical_reaction/syriniver
	results = list(/datum/reagent/medicine/C2/syriniver = 5)
	required_reagents = list(/datum/reagent/sulfur = 1, /datum/reagent/fluorine = 1, /datum/reagent/toxin = 1, /datum/reagent/nitrous_oxide = 2)

/datum/chemical_reaction/penthrite
	results = list(/datum/reagent/medicine/C2/penthrite = 4)
	required_reagents = list(/datum/reagent/pentaerythritol = 4, /datum/reagent/acetone = 1,  /datum/reagent/toxin/acid/nitracid = 1)
