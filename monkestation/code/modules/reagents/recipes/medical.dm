/datum/chemical_reaction/liquid_solder
	name = "Liquid Solder"
	id = /datum/reagent/medicine/liquid_solder
	results = list(/datum/reagent/medicine/liquid_solder = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/copper = 1, /datum/reagent/silver = 1)
	required_temp = 370
	mix_message = "The mixture becomes a metallic slurry."
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER

/datum/chemical_reaction/system_cleaner
	name = "System Cleaner"
	id = /datum/reagent/medicine/system_cleaner
	results = list(/datum/reagent/medicine/system_cleaner = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/chlorine = 1, /datum/reagent/phenol = 2, /datum/reagent/potassium = 1)
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_OTHER
