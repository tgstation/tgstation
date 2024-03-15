/datum/chemical_reaction/australium
	results = list(/datum/reagent/australium = 3)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/drug/happiness = 1, /datum/reagent/toxin/acid = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_UNIQUE

/datum/chemical_reaction/shakeium
	results = list(/datum/reagent/shakeium = 5)
	required_reagents = list(/datum/reagent/consumable/vanillashake = 1, /datum/reagent/consumable/corn_syrup = 1, /datum/reagent/consumable/pwr_game = 3)
	reaction_tags = REACTION_TAG_MODERATE | REACTION_TAG_DRINK
/datum/chemical_reaction/drink/sunset_sarsaparilla
	results = list(/datum/reagent/consumable/sunset_sarsaparilla = 5)
	required_reagents =  list(/datum/reagent/ash = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/uranium = 1)
	reaction_tags = REACTION_TAG_HARD | REACTION_TAG_DRINK
