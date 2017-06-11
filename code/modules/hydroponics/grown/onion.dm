/obj/item/seeds/onion
	name = "pack of onion seeds"
	desc = "These seeds grow into onions."
	icon_state = "seed-berry"
	species = "onion"
	plantname = "Onion Sprout"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/onion
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "berry-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "berry-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/berry/glow, /obj/item/seeds/berry/poison)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed = /obj/item/seeds/berry
	name = "onion"
	desc = "Nothing to cry over."
	icon_state = "berrypile"
	gender = PLURAL
	filling_color = "#FF00FF"
	bitesize_mod = 2