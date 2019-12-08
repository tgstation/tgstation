/datum/chemical_reaction/sterilizine
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/charcoal = 1, /datum/reagent/chlorine = 1)

/datum/chemical_reaction/life
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/blood = 1)

/datum/chemical_reaction/life_friendly
	required_reagents = list(/datum/reagent/medicine/strange_reagent = 1, /datum/reagent/medicine/synthflesh = 1, /datum/reagent/consumable/sugar = 1)

// AuStation Reagents
/datum/chemical_reaction/australium
	name = "Australium"
	id = /datum/reagent/australium
	results = list(/datum/reagent/australium = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer = 1, /datum/reagent/gold = 1, /datum/reagent/pyrosium = 1)

/datum/chemical_reaction/luminol
	name = "Luminol"
	id = /datum/reagent/luminol
	results = list(/datum/reagent/luminol = 3)
	required_reagents = list(/datum/reagent/oxygen = 1, /datum/reagent/chlorine = 1, /datum/reagent/lye = 1)

/datum/chemical_reaction/energized_luminol
	name = "Energized Luminol"
	id = /datum/reagent/luminol/energized
	results = list(/datum/reagent/luminol/energized = 2)
	required_reagents = list(/datum/reagent/luminol = 2, /datum/reagent/toxin/plasma = 1, /datum/reagent/uranium = 1)
	required_temp = 400
