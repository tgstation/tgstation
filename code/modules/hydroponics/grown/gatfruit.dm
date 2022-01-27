
// Gatfruit
/obj/item/seeds/gatfruit
	name = "pack of gatfruit seeds"
	desc = "These seeds grow into .357 revolvers."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "Gatfruit Tree"
	product = /obj/item/food/grown/shell/gatfruit
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	rarity = 60 // Obtainable only with xenobio+superluck.
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list(/datum/reagent/sulfur = 0.1, /datum/reagent/carbon = 0.1, /datum/reagent/nitrogen = 0.07, /datum/reagent/potassium = 0.05)

/obj/item/food/grown/shell/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	trash_type = /obj/item/gun/ballistic/revolver
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("gunpowder" = 1)
	wine_power = 90 //It burns going down, too.
