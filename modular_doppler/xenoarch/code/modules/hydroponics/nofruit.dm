/obj/item/seeds/nofruit
	name = "nofruit seed pack"
	desc = "These seeds grow into nofruit plants. A strange plant often cultivated by silent performers."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "nofruit"
	species = "nofruit"
	plantname = "Nofruit Plant"
	product = /obj/item/food/grown/nofruit
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "nofruit-stage"
	growthstages = 4
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nothing = 0.1, /datum/reagent/toxin/mimesbane = 0.1, /datum/reagent/toxin/mutetoxin = 0.1)

/obj/item/food/grown/nofruit
	seed = /obj/item/seeds/nofruit
	name = "nofruit"
	desc = "A cubic nofruit, the leaf on top of the nofruit gesticulates wildly."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "nofruit"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/nothing
	tastes = list("nothing" = 1)
