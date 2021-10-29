/obj/item/seeds/cocaleaf
	name = "pack of coca leaf seeds"
	desc = "These seeds grow into coca shrubs. They make you feel energized just looking at them..."
	icon = 'modular_skyrat/master_files/icons/obj/hydroponics/seeds.dmi'
	growing_icon = 'modular_skyrat/master_files/icons/obj/hydroponics/growing.dmi'
	icon_state = "seed-cocoleaf"
	species = "cocoleaf"
	plantname = "Coca Leaves"
	maturation = 8
	potency = 20
	growthstages = 1
	product = /obj/item/food/grown/cocaleaf
	mutatelist = list()
	reagents_add = list(/datum/reagent/drug/cocaine = 0.3, /datum/reagent/consumable/nutriment = 0.15)

/obj/item/food/grown/cocaleaf
	seed = /obj/item/seeds/cocaleaf
	name = "coca leaf"
	desc = "A leaf of the coca shrub, which contains a potent psychoactive alkaloid known as 'cocaine'."
	icon = 'modular_skyrat/master_files/icons/obj/hydroponics/harvest.dmi'
	icon_state = "cocoleaf"
	foodtypes = FRUIT //i guess? i mean it grows on trees...
	tastes = list("leaves" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/sins_delight //Cocaine is one hell of a sin.
