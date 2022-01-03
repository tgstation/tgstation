// Cocoa Pod
/obj/item/seeds/cocoapod
	name = "pack of cocoa pod seeds"
	desc = "These seeds grow into cacao trees. They look fattening." //SIC: cocoa is the seeds. The trees are spelled cacao.
	icon_state = "seed-cocoapod"
	species = "cocoapod"
	plantname = "Cocao Tree"
	product = /obj/item/food/grown/cocoapod
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	instability = 20
	growthstages = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "cocoapod-grow"
	icon_dead = "cocoapod-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cocoapod/vanillapod, /obj/item/seeds/cocoapod/bungotree)
	reagents_add = list(/datum/reagent/consumable/coco = 0.25, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/cocoapod
	seed = /obj/item/seeds/cocoapod
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("cocoa" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_cacao
	filling_color = "#FFD700"

// Vanilla Pod
/obj/item/seeds/cocoapod/vanillapod
	name = "pack of vanilla pod seeds"
	desc = "These seeds grow into vanilla trees. They look fattening."
	icon_state = "seed-vanillapod"
	species = "vanillapod"
	plantname = "Vanilla Tree"
	product = /obj/item/food/grown/vanillapod
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/vanilla = 0.25, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/vanillapod
	seed = /obj/item/seeds/cocoapod/vanillapod
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... vanilla."
	icon_state = "vanillapod"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("vanilla" = 1)
	distill_reagent = /datum/reagent/consumable/vanilla //Takes longer, but you can get even more vanilla from it.
	filling_color = "#FFD700"

/obj/item/seeds/cocoapod/bungotree
	name = "pack of bungo tree seeds"
	desc = "These seeds grow into bungo trees. They appear to be heavy and almost perfectly spherical."
	icon_state = "seed-bungotree"
	species = "bungotree"
	plantname = "Bungo Tree"
	product = /obj/item/food/grown/bungofruit
	lifespan = 30
	maturation = 4
	yield = 3
	production = 7
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/enzyme = 0.1, /datum/reagent/consumable/nutriment = 0.1)
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "bungotree-grow"
	icon_dead = "bungotree-dead"
	rarity = 15

/obj/item/food/grown/bungofruit
	seed = /obj/item/seeds/cocoapod/bungotree
	name = "bungo fruit"
	desc = "A strange fruit, tough leathery skin protects its juicy flesh and large poisonous seed."
	icon_state = "bungo"
	bite_consumption_mod = 2
	trash_type = /obj/item/food/grown/bungopit
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/consumable/bungojuice = 0)
	tastes = list("bungo" = 2, "tropical fruitiness" = 1)
	distill_reagent = null

/obj/item/food/grown/bungopit
	seed = /obj/item/seeds/cocoapod/bungotree
	name = "bungo pit"
	icon_state = "bungopit"
	bite_consumption_mod = 5
	desc = "A large seed, it is said to be potent enough to be able to stop a mans heart."
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	foodtypes = TOXIC
	tastes = list("acrid bitterness" = 1)
	filling_color = "#E8C22F"

/obj/item/food/grown/bungopit/Initialize(mapload)
	. =..()
	reagents.clear_reagents()
	reagents.add_reagent(/datum/reagent/toxin/bungotoxin, seed.potency * 0.10) //More than this will kill at too low potency
	reagents.add_reagent(/datum/reagent/consumable/nutriment, seed.potency * 0.04)
