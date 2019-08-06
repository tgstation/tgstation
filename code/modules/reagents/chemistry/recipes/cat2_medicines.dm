

/*****BRUTE*****/

/datum/chemical_reaction/arnica
	name = "Arnica"
	id = /datum/reagent/medicine/C2/arnica
	results = list(/datum/reagent/medicine/C2/arnica = 3)
	required_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/fluorine = 1, /datum/reagent/carbon = 1)
	mix_message = "The mixture turns into a thick, yellow powder."

/datum/chemical_reaction/acetaminophen
	name = "Acetaminophen"
	id = /datum/reagent/medicine/C2/acetaminophen
	results = list(/datum/reagent/medicine/C2/acetaminophen = 3)
	required_reagents = list(/datum/reagent/phenol = 1, /datum/reagent/oxygen = 1, /datum/reagent/nitrogen = 1)

/*****BURN*****/

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = /datum/reagent/medicine/C2/silver_sulfadiazine
	results = list(/datum/reagent/medicine/C2/silver_sulfadiazine = 5)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/silver = 1, /datum/reagent/sulfur = 1, /datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/neomycin_sulfate
	name = "Neomycin Sulfate"
	id = /datum/reagent/medicine/C2/neomycin_sulfate
	results = list(/datum/reagent/medicine/C2/neomycin_sulfate = 4)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/hydrogen = 2)

/*****OXY*****/

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = /datum/reagent/medicine/C2/perfluorodecalin
	results = list(/datum/reagent/medicine/C2/perfluorodecalin = 3)
	required_reagents = list(/datum/reagent/hydrogen = 1, /datum/reagent/fluorine = 1, /datum/reagent/oil = 1)
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

/datum/chemical_reaction/theophylline
	name = "Theophylline"
	id = /datum/reagent/medicine/C2/theophylline
	results = list(/datum/reagent/medicine/C2/theophylline = 5)
	required_reagents = list(/datum/reagent/nitrogen = 3, /datum/reagent/acetone = 2)
	required_catalysts = list(/datum/reagent/toxin/acid = 1)

/*****TOX*****/

/datum/chemical_reaction/corticoline
	name = "Corticoline"
	id = /datum/reagent/medicine/C2/corticoline
	results = list(/datum/reagent/medicine/C2/corticoline = 3)
	required_reagents = list(/datum/reagent/nitrogen = 1, /datum/reagent/potassium = 1, /datum/reagent/aluminium = 1)

/datum/chemical_reaction/palletta
	name = "Palletta"
	id = /datum/reagent/medicine/C2/palletta
	results = list(/datum/reagent/medicine/C2/palletta = 2)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/sodiumchloride = 1)
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380
