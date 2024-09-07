/obj/item/seeds/surik
	name = "surik seed pack"
	desc = "These seeds grow into surik plants. Said to contain the very essence of Indecipheres."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "surik"
	species = "surik"
	plantname = "Surik Plant"
	product = /obj/item/food/grown/surik
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "surik-stage"
	growthstages = 4
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/fire_resistance)
	reagents_add = list(/datum/reagent/brimdust = 0.1, /datum/reagent/medicine/omnizine/godblood = 0.1, /datum/reagent/wittel = 0.1)

/obj/item/food/grown/surik
	seed = /obj/item/seeds/surik
	name = "surik"
	desc = "A shimmering surik crystal. The center of the gem thrums with volcanic activity."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "surik"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/brimdust
	tastes = list("crystals" = 1)
