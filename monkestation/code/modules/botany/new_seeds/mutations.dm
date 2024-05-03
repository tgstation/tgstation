/datum/hydroponics/plant_mutation/paper
	mutates_from = list(/obj/item/seeds/tree)
	required_endurance = list(35, INFINITY)
	created_product = /obj/item/paper
	created_seed = /obj/item/seeds/tree/paper


/datum/hydroponics/plant_mutation/money
	mutates_from = list(/obj/item/seeds/tree/paper)
	required_potency = list(30, INFINITY)
	created_product = /obj/item/stack/spacecash/c10
	created_seed = /obj/item/seeds/tree/money

/datum/hydroponics/plant_mutation/steel
	mutates_from = list(/obj/item/seeds/tree)
	required_lifespan = list(150, INFINITY)
	created_product = /obj/item/grown/log/steel
	created_seed = /obj/item/seeds/tree/steel
