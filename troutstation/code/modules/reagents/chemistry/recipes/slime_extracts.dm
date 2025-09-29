/datum/chemical_reaction/slime/slimeanteater						//	Troutstation specific: Adds Anteater Mutation Toxin to Green Slime Extract reactions
    results = list(/datum/reagent/mutationtoxin/anteater = 1)		//		Produces Anteater Mutation Toxin.
    required_reagents = list(/datum/reagent/ants = 1)				//		Uses Ants to do so.
    required_container = /obj/item/slime_extract/green				// 		Like other reactions, uses the Green Slime Extract container to synthesize it.
