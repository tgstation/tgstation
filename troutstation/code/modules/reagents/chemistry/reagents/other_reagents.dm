/datum/reagent/mutationtoxin/anteater										//  Troutstation specific: Anteater Mutation Toxin
	name = "Anteater Mutation Toxin"										//  First implemented for use in green slime reactions
	description = "A snout-lengthening toxin."								//  Feel free to change the descriptions as desired!
	color = "#5EFF3B" //RGB: 94, 255, 59									   Uses same color as other mutation toxins
	race = /datum/species/anteater											//     Specifies Anteater race.
	taste_description = "ants"												//     Tastes like ants.
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE	//  Copies the setup of other nonstandard mutation toxins
