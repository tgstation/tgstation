/datum/chemical_reaction/drink/drunken_espatier
	results = list(/datum/reagent/consumable/ethanol/drunken_espatier = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/mushi_kombucha = 2, /datum/reagent/consumable/ethanol/moonshine = 2, /datum/reagent/consumable/berryjuice = 1)
	mix_message = "The drink seems to let out a grim sigh..."

/datum/chemical_reaction/drink/mushi_kombucha
	results = list(/datum/reagent/consumable/ethanol/mushi_kombucha = 5)
	required_reagents = list(/datum/reagent/consumable/mushroom_tea = 3, /datum/reagent/consumable/korta_nectar = 2)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 1)

/datum/chemical_reaction/drink/mushroom_tea
	results = list(/datum/reagent/consumable/mushroom_tea = 5)
	required_reagents = list(/datum/reagent/toxin/mushroom_powder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/drink/protein_blend
	results = list(/datum/reagent/consumable/ethanol/protein_blend = 5)
	required_reagents = list(/datum/reagent/yuck = 1, /datum/reagent/consumable/korta_flour = 1, /datum/reagent/blood = 1, /datum/reagent/consumable/ethanol = 2)

/datum/chemical_reaction/drink/sea_breeze
	results = list(/datum/reagent/consumable/ethanol/sea_breeze = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/kortara = 3, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/ethanol/creme_de_cacao = 1)

/datum/chemical_reaction/drink/triumphal_arch
	results = list(/datum/reagent/consumable/ethanol/triumphal_arch = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/mushi_kombucha = 5, /datum/reagent/consumable/ethanol/grappa = 2, /datum/reagent/consumable/lemonjuice = 2, /datum/reagent/gold = 1)
	mix_message = "The mixture turns a deep golden hue."

/datum/chemical_reaction/drink/white_tiziran
	results = list(/datum/reagent/consumable/ethanol/white_tiziran = 8)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 5, /datum/reagent/consumable/ethanol/kortara = 3)
