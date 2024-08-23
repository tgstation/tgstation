
// Sugarcane
/obj/item/seeds/sugarcane
	name = "sugarcane seed pack"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product = /obj/item/food/grown/sugarcane
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 60
	endurance = 50
	maturation = 3
	yield = 4
	instability = 15
	growthstages = 2
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/sugar = 0.25)
	mutatelist = list(/obj/item/seeds/bamboo, /obj/item/seeds/sugarcane/saltcane)

/obj/item/food/grown/sugarcane
	seed = /obj/item/seeds/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES | SUGAR
	distill_reagent = /datum/reagent/consumable/ethanol/rum

///and bamboo!
/obj/item/seeds/bamboo
	name = "bamboo seed pack"
	desc = "A plant known for its flexible and resistant logs."
	icon_state = "seed-bamboo"
	species = "bamboo"
	plantname = "Bamboo"
	product = /obj/item/grown/log/bamboo
	lifespan = 80
	endurance = 70
	maturation = 15
	production = 2
	yield = 5
	potency = 50
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing.dmi'
	icon_dead = "bamboo-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null

/obj/item/grown/log/bamboo
	seed = /obj/item/seeds/bamboo
	name = "bamboo log"
	desc = "A long and resistant bamboo log."
	icon_state = "bamboo"
	plank_type = /obj/item/stack/sheet/mineral/bamboo
	plank_name = "bamboo sticks"

/obj/item/grown/log/bamboo/CheckAccepted(obj/item/I)
	return FALSE

//Saltcane - Gross, salty shafts!
/obj/item/seeds/sugarcane/saltcane
	name = "saltcane seed pack"
	desc = "These seeds grow into saltcane."
	icon_state = "seed-saltcane"
	species = "saltcane"
	plantname = "Saltcane"
	product = /obj/item/food/grown/sugarcane/saltcane
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/salt = 0.25)
	mutatelist = null

/obj/item/food/grown/sugarcane/saltcane
	seed = /obj/item/seeds/sugarcane/saltcane
	name = "saltcane"
	desc = "Ungodly salty, bane of slugs, treasure of horses."
	icon_state = "saltcane"
	foodtypes = VEGETABLES | GROSS

/obj/item/food/grown/sugarcane/saltcane/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/seaweedsheet/saltcane) //soooshi
