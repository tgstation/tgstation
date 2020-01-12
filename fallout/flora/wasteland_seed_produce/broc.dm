/obj/item/seeds/poppy/broc
	name = "pack of broc seeds"
	desc = "These seeds grow into broc flowers."
	icon = 'fallout/icons/hydroponics/seeds.dmi'
	icon_state = "seed-broc"
	species = "broc"
	plantname = "broc flowers"
	product = /obj/item/reagent_containers/food/snacks/grown/broc
	lifespan = 25
	endurance = 10
	yield = 4
	growthstages = 3
	production = 4
	maturation = 4
	growing_icon = 'fallout/icons/hydroponics/wasteland_plants.dmi'
	//mutatelist = list(/obj/item/seeds/geraniumseed, /obj/item/seeds/lilyseed)

/obj/item/reagent_containers/food/snacks/grown/broc
	seed = /obj/item/seeds/poppy/broc
	name = "broc flower"
	desc = "This vibrant, orange flower grows on tall stalks in the wasteland and exhibits moderate healing properties, even when unprocessed."
	icon = 'fallout/icons/hydroponics/harvest.dmi'
	icon_state = "broc"
	//slot_flags = SLOT_HEAD
	filling_color = "#FF6347"

/*
/obj/item/reagent_containers/food/snacks/grown/broc/add_juice()
	if(..())
		reagents.add_reagent("dexalin", 1 + round((seed.potency / 5), 1))
		reagents.add_reagent("salglu_solution", 1 + round((seed.potency / 20), 1))
		bitesize = 1 + round(reagents.total_volume / 3, 1)
*/
