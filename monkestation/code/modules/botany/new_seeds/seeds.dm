/obj/item/seeds/tree
	name = "pack of tree seeds"
	desc = "These seeds grow into a tree."
	plant_icon_offset = 0
	icon = 'monkestation/icons/obj/hydroponics/fruit.dmi'
	icon_state = "coconut_seed" //CHANGE THIS

	species = "tree"
	plantname = "Tree"

	lifespan = 80
	endurance = 50
	maturation = 15
	production = 5
	yield = 5

	plant_icon_offset = 0
	growing_icon = 'goon/icons/obj/hydroponics/plants_crop.dmi'
	growthstages = 3
	icon_harvest = "Tree-G4"
	icon_dead = "Tree-G0"
	icon_grow = "Tree-G"

	product = /obj/item/grown/log
	possible_mutations = list(/datum/hydroponics/plant_mutation/paper, /datum/hydroponics/plant_mutation/steel)


/obj/item/seeds/tree/paper
	name = "pack of paper tree seeds"
	desc = "These seeds grow into a paper tree."

	species = "papertree"
	plantname = "Paper Tree"

	icon_harvest = "TreePaper-G4"
	icon_dead = "TreePaper-G0"
	icon_grow = "TreePaper-G"

	product = /obj/item/paper
	possible_mutations = list(/datum/hydroponics/plant_mutation/money)
	genes = list(/datum/plant_gene/trait/repeated_harvest)

/obj/item/seeds/tree/money
	name = "pack of money tree seeds"
	desc = "These seeds grow into a money tree."

	species = "cashtree"
	plantname = "Cash Tree"

	icon_harvest = "TreeCash-G4"
	icon_dead = "TreeCash-G0"
	icon_grow = "TreeCash-G"

	possible_mutations = list()
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	product = /obj/item/stack/spacecash/c10

/obj/item/seeds/tree/steel
	name = "pack of steel tree seeds"
	desc = "These seeds grow into a steel tree."
	species = "steel"
	plantname = "Steel Tree"

	icon_harvest = "TreeSteel-G4"
	icon_dead = "TreeSteel-G0"
	icon_grow = "TreeSteel-G"

	product = /obj/item/grown/log/steel
	possible_mutations = list()
	reagents_add = list(/datum/reagent/cellulose = 0.05, /datum/reagent/iron = 0.05)
	rarity = 20
