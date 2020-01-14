/obj/item/seeds/feracactus
	name = "pack of barrel cactus seeds"
	desc = "These seeds grow into a barrel cactus."
	icon_state = "seed-feracactus"
	growing_icon = 'fallout/icons/hydroponics/wasteland_plants.dmi'
	icon_grow = "feracactus-grow"
	icon_dead = "feracactus-dead"
	icon_harvest = "feracactus-harvest"
	species = "barrel cactus"
	plantname = "barrel cactus"
	product = /obj/item/reagent_containers/food/snacks/grown/feracactus
	lifespan = 60
	endurance = 20
	yield = 2
	growthstages = 2
	production = 5
	maturation = 5


/obj/item/reagent_containers/food/snacks/grown/feracactus
	seed = /obj/item/seeds/feracactus
	name = "barrel cactus fruit"
	desc = "Barrel cactus fruit are found on spherical barrel cacti and are both nutritious and highly toxic."
	icon_state = "feracactus"
	filling_color = "#FF6347"

/*
/obj/item/reagent_containers/food/snacks/grown/feracactus/add_juice()
	if(..())
		reagents.add_reagent("nutriment", 3 + round((seed.potency / 20), 1))
		reagents.add_reagent("calomel", 3 + round((seed.potency / 20), 1))
		reagents.add_reagent("radium", 0 + round((seed.potency / 20), 1))
		bitesize = 3 + round(reagents.total_volume / 3, 1)
*/
