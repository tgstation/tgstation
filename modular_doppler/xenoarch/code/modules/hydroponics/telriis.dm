/obj/item/seeds/telriis
	name = "telriis seed pack"
	desc = "These seeds grow into telriis plants. A distant relative of milkweed, this grass can actually be juiced into milk."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "telriis"
	species = "telriis"
	plantname = "Telriis Plant"
	product = /obj/item/food/grown/telriis
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "telriis-stage"
	growthstages = 4
	plant_icon_offset = 7
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/invasive)
	reagents_add = list(/datum/reagent/consumable/milk = 0.1, /datum/reagent/consumable/soymilk = 0.1, /datum/reagent/consumable/korta_milk)

/obj/item/food/grown/telriis
	seed = /obj/item/seeds/telriis
	name = "telriis"
	desc = "A sheaf of telris, it can be ground or juiced into a milky liquid."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "telriis"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/coconut_milk
	tastes = list("milk" = 1)
