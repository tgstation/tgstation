/datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = /datum/reagent/drug/space_drugs
	results = list(/datum/reagent/drug/space_drugs = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/lithium = 1)

/datum/chemical_reaction/crank
	name = "Crank"
	id = /datum/reagent/drug/crank
	results = list(/datum/reagent/drug/crank = 5)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/ammonia = 1, /datum/reagent/lithium = 1, /datum/reagent/toxin/acid = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	required_temp = 390


/datum/chemical_reaction/krokodil
	name = "Krokodil"
	id = /datum/reagent/drug/krokodil
	results = list(/datum/reagent/drug/krokodil = 6)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/drug/opioid/morphine = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/potassium = 1, /datum/reagent/phosphorus = 1, /datum/reagent/fuel = 1)
	mix_message = "The mixture dries into a pale blue powder."
	required_temp = 380

/datum/chemical_reaction/methamphetamine
	name = /datum/reagent/drug/amphetamine/methamphetamine
	id = /datum/reagent/drug/amphetamine/methamphetamine
	results = list(/datum/reagent/drug/amphetamine/methamphetamine = 4)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/iodine = 1, /datum/reagent/phosphorus = 1, /datum/reagent/hydrogen = 1)
	required_temp = 374

/datum/chemical_reaction/adderal
	name = /datum/reagent/drug/amphetamine/adderal
	id = /datum/reagent/drug/amphetamine/adderal
	results = list(/datum/reagent/drug/amphetamine/adderal = 4)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/iodine = 1, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/medicine/neurine = 1)
	required_temp = 574

/datum/chemical_reaction/gojuice
	name = /datum/reagent/drug/amphetamine/gojuice
	id = /datum/reagent/drug/amphetamine/gojuice
	results = list(/datum/reagent/drug/amphetamine/gojuice = 2)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 1, /datum/reagent/drug/crank = 1, /datum/reagent/drug/amphetamine/methamphetamine = 1,)
	required_temp = 574

/datum/chemical_reaction/diamorphine
	name = "DImorphine"
	id = /datum/reagent/drug/opioid/diamorphine
	results = list(/datum/reagent/drug/opioid/diamorphine = 2)
	required_reagents = list(/datum/reagent/carbon = 2, /datum/reagent/hydrogen = 2, /datum/reagent/consumable/ethanol = 1, /datum/reagent/oxygen = 1)
	required_temp = 480

/datum/chemical_reaction/morphine
	name = "Morphine"
	id = /datum/reagent/drug/opioid/morphine
	results = list(/datum/reagent/drug/opioid/morphine = 2)
	required_reagents = list(/datum/reagent/drug/opioid = 2)
	required_catalysts = list(/datum/reagent/acetone = 5 , /datum/reagent/water = 15 , /datum/reagent/consumable/ethanol = 5)

/datum/chemical_reaction/fentanyl
	name = "Fentanyl"
	id = /datum/reagent/drug/opioid/fentanyl
	results = list(/datum/reagent/drug/opioid/fentanyl = 4)
	required_reagents = list(/datum/reagent/drug/opioid/diamorphine = 1 , /datum/reagent/drug/space_drugs = 2)
	required_temp = 675

/datum/chemical_reaction/codeine
	name = "Codeine"
	id = /datum/reagent/drug/opioid/codeine
	results = list(/datum/reagent/drug/opioid/codeine = 2)
	required_reagents = list(/datum/reagent/drug/opioid = 1 , /datum/reagent/medicine/mannitol = 2)
	required_catalysts = list(/datum/reagent/water = 25)
	required_temp = 775


/datum/chemical_reaction/bath_salts
	name = /datum/reagent/drug/bath_salts
	id = /datum/reagent/drug/bath_salts
	results = list(/datum/reagent/drug/bath_salts = 7)
	required_reagents = list(/datum/reagent/toxin/bad_food = 1, /datum/reagent/saltpetre = 1, /datum/reagent/consumable/nutriment = 1, /datum/reagent/space_cleaner = 1, /datum/reagent/consumable/enzyme = 1, /datum/reagent/consumable/tea = 1, /datum/reagent/mercury = 1)
	required_temp = 374

/datum/chemical_reaction/aranesp
	name = /datum/reagent/drug/aranesp
	id = /datum/reagent/drug/aranesp
	results = list(/datum/reagent/drug/aranesp = 3)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 1, /datum/reagent/medicine/atropine = 1, /datum/reagent/drug/opioid/diamorphine = 1)

/datum/chemical_reaction/ecstasy
	name = "Ecstasy"
	id = /datum/reagent/drug/ecstasy
	results = list(/datum/reagent/drug/ecstasy= 4)
	required_reagents = list(/datum/reagent/nitrous_oxide = 2, /datum/reagent/medicine/epinephrine = 1, /datum/reagent/consumable/ethanol = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

/datum/chemical_reaction/pumpup
	name = "Pump-Up"
	id = /datum/reagent/drug/pumpup
	results = list(/datum/reagent/drug/pumpup = 5)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 2, /datum/reagent/consumable/coffee = 5)
