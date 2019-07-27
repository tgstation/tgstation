// Cocoa Pod
/obj/item/seeds/cocoapod
	name = "pack of cocoa pod seeds"
	desc = "These seeds grow into cacao trees. They look fattening." //SIC: cocoa is the seeds. The trees are spelled cacao.
	icon_state = "seed-cocoapod"
	species = "cocoapod"
	plantname = "Cocao Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cocoapod
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	growthstages = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "cocoapod-grow"
	icon_dead = "cocoapod-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cocoapod/vanillapod)
<<<<<<< HEAD
	reagents_add = list(/datum/reagent/consumable/coco = 0.25, /datum/reagent/consumable/nutriment = 0.1)
=======
	reagents_add = list("cocoa" = 0.25, "nutriment" = 0.1)
>>>>>>> Updated this old code to fork

/obj/item/reagent_containers/food/snacks/grown/cocoapod
	seed = /obj/item/seeds/cocoapod
	name = "cocoa pod"
	desc = "Fattening... Mmmmm... chucklate."
	icon_state = "cocoapod"
	filling_color = "#FFD700"
	bitesize_mod = 2
	foodtype = FRUIT
	tastes = list("cocoa" = 1)
<<<<<<< HEAD
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_cacao
=======
	distill_reagent = "creme_de_cacao"
>>>>>>> Updated this old code to fork

// Vanilla Pod
/obj/item/seeds/cocoapod/vanillapod
	name = "pack of vanilla pod seeds"
	desc = "These seeds grow into vanilla trees. They look fattening."
	icon_state = "seed-vanillapod"
	species = "vanillapod"
	plantname = "Vanilla Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/vanillapod
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list()
<<<<<<< HEAD
	reagents_add = list(/datum/reagent/consumable/vanilla = 0.25, /datum/reagent/consumable/nutriment = 0.1)
=======
	reagents_add = list("vanilla" = 0.25, "nutriment" = 0.1)
>>>>>>> Updated this old code to fork

/obj/item/reagent_containers/food/snacks/grown/vanillapod
	seed = /obj/item/seeds/cocoapod/vanillapod
	name = "vanilla pod"
	desc = "Fattening... Mmmmm... vanilla."
	icon_state = "vanillapod"
	filling_color = "#FFD700"
	foodtype = FRUIT
	tastes = list("vanilla" = 1)
<<<<<<< HEAD
	distill_reagent = /datum/reagent/consumable/vanilla //Takes longer, but you can get even more vanilla from it.
=======
	distill_reagent = "vanilla" //Takes longer, but you can get even more vanilla from it.
>>>>>>> Updated this old code to fork
