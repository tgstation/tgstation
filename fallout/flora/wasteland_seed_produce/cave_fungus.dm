/obj/item/seeds/fungus
	name = "pack of cave fungus mycelium"
	desc = "This mycelium grows into cave fungi, an edible variety of mushroom with anti-toxic properties."
	icon = 'fallout/icons/hydroponics/seeds.dmi'
	icon_state = "seed-fungus"
	species = "cave fungus"
	plantname = "cave fungi"
	product = /obj/item/reagent_containers/food/snacks/grown/fungus
	growing_icon = 'fallout/icons/hydroponics/wasteland_plants.dmi'
	icon_grow = "cave_fungus-grow"
	icon_dead = "cave_fungus-dead"
	icon_harvest = "cave_fungus-harvest"
	lifespan = 50
	endurance = 10
	maturation = 8
	production = 3
	yield = 6
	potency = 20
	growthstages = 2

/obj/item/reagent_containers/food/snacks/grown/fungus
	seed = /obj/item/seeds/fungus
	name = "cave fungus"
	desc = "Cave fungus is an edible mushroom which has the ability to purge bodily toxins."
	icon_state = "fungus"
	filling_color = "#FF6347"
