
// aloe
/obj/item/seeds/aloe
	name = "pack of aloe seeds"
	desc = "These seeds grow into aloe."
	icon_state = "seed-aloe"
	species = "aloe"
	plantname = "Aloe"
	product = /obj/item/food/grown/aloe
	lifespan = 60
	endurance = 25
	maturation = 4
	production = 4
	yield = 6
	growthstages = 5
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/aloe
	seed = /obj/item/seeds/aloe
	name = "aloe"
	desc = "Cut leaves from the aloe plant."
	icon_state = "aloe"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	juice_results = list(/datum/reagent/consumable/aloejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/tequila

/obj/item/food/grown/aloe/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/stack/medical/aloe/fresh, rand(15 SECONDS, 20 SECONDS), TRUE, TRUE)

/obj/item/food/grown/aloe/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/stack/medical/aloe/fresh)
