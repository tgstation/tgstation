/obj/item/seeds/thaadra
	name = "thaadra seed pack"
	desc = "These seeds grow into thaadra plants. A strange flower full of unique medicines and silver."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "thaadra"
	species = "thaadra"
	plantname = "Thaadra Plant"
	product = /obj/item/food/grown/thaadra
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "thaadra-stage"
	growthstages = 4
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/preserved)
	reagents_add = list(/datum/reagent/silver = 0.1, /datum/reagent/medicine/sansufentanyl = 0.1, /datum/reagent/medicine/cordiolis_hepatico = 0.1)

/obj/item/food/grown/thaadra
	seed = /obj/item/seeds/thaadra
	name = "thaadra"
	desc = "A cluster of thaadra petals, full of niche medicinal chemicals."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "thaadra"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/silver
	tastes = list("silver" = 1)
