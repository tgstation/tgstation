// Olive
/obj/item/seeds/olive
	name = "pack of olive seeds"
	desc = "These seeds grow into olive trees."
	icon_state = "seed-olive"
	species = "olive"
	plantname = "Olive Tree"
	product = /obj/item/food/grown/olive
	lifespan = 150
	endurance = 35
	yield = 5
	maturation = 10
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "olive-grow"
	icon_dead = "olive-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/one_bite)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/olive
	seed = /obj/item/seeds/olive
	name = "olive"
	desc = "A small cylindrical salty fruit closely related to mangoes. Can be ground into a paste and mixed with water to make quality oil."
	icon_state = "olive"
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/olivepaste = 0)
	tastes = list("olive" = 1)
	
