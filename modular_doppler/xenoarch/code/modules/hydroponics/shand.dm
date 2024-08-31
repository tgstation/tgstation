/obj/item/seeds/shand
	name = "shand seed pack"
	desc = "These seeds grow into shand plants. While not very useful on its own, it is full of chemicals that no other plant can produce. A good candidate for crossbreeding."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "shand"
	species = "shand"
	plantname = "Shand Plant"
	product = /obj/item/food/grown/shand
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "shand-stage"
	growthstages = 3
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/maxchem)
	reagents_add = list(/datum/reagent/bromine = 0.1, /datum/reagent/sodium = 0.1, /datum/reagent/copper = 0.1)

/obj/item/food/grown/shand
	seed = /obj/item/seeds/shand
	name = "shand"
	desc = "A handful of shand leaves, the leaves are oily and smell like a laboratory."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "shand"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/bromine
	tastes = list("chemicals" = 1)
