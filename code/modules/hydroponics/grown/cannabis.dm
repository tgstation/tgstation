// Cannabis
/obj/item/seeds/cannabis
	name = "cannabis seed pack"
	desc = "Taxable."
	icon_state = "seed-cannabis"
	plant_icon_offset = 6
	species = "cannabis"
	plantname = "Cannabis Plant"
	product = /obj/item/food/grown/cannabis
	maturation = 8
	potency = 20
	growthstages = 1
	instability = 40
	growing_icon = 'icons/obj/service/hydroponics/growing.dmi'
	icon_grow = "cannabis-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "cannabis-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cannabis/rainbow,
		/obj/item/seeds/cannabis/death,
		/obj/item/seeds/cannabis/white,
		/obj/item/seeds/cannabis/ultimate,
	)
	reagents_add = list(/datum/reagent/drug/cannabis = 0.15)


/obj/item/seeds/cannabis/rainbow
	name = "rainbow weed seed pack"
	desc = "These seeds grow into rainbow weed. Groovy... and also highly addictive."
	icon_state = "seed-megacannabis"
	icon_grow = "megacannabis-grow"
	species = "megacannabis"
	plantname = "Rainbow Weed"
	product = /obj/item/food/grown/cannabis/rainbow
	mutatelist = null
	reagents_add = list(/datum/reagent/colorful_reagent = 0.05, /datum/reagent/medicine/psicodine = 0.03, /datum/reagent/drug/happiness = 0.1, /datum/reagent/toxin/mindbreaker = 0.1, /datum/reagent/toxin/lipolicide = 0.15, /datum/reagent/drug/space_drugs = 0.15)
	rarity = 40

/obj/item/seeds/cannabis/death
	name = "deathweed seed pack"
	desc = "These seeds grow into deathweed. Not groovy."
	icon_state = "seed-blackcannabis"
	icon_grow = "blackcannabis-grow"
	species = "blackcannabis"
	plantname = "Deathweed"
	product = /obj/item/food/grown/cannabis/death
	mutatelist = null
	reagents_add = list(/datum/reagent/toxin/cyanide = 0.35, /datum/reagent/drug/cannabis = 0.15)
	rarity = 40

/obj/item/seeds/cannabis/white
	name = "lifeweed seed pack"
	desc = "I will give unto him that is munchies of the fountain of the cravings of life, freely."
	icon_state = "seed-whitecannabis"
	icon_grow = "whitecannabis-grow"
	species = "whitecannabis"
	plantname = "Lifeweed"
	instability = 30
	product = /obj/item/food/grown/cannabis/white
	mutatelist = null
	reagents_add = list(/datum/reagent/medicine/omnizine = 0.35, /datum/reagent/drug/cannabis = 0.15)
	rarity = 40


/obj/item/seeds/cannabis/ultimate
	name = "omega weed seed pack"
	desc = "These seeds grow into omega weed."
	icon_state = "seed-ocannabis"
	plant_icon_offset = 0
	icon_grow = "ocannabis-grow"
	species = "ocannabis"
	plantname = "Omega Weed"
	product = /obj/item/food/grown/cannabis/ultimate
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/green, /datum/plant_gene/trait/modified_volume/omega_weed)
	mutatelist = null
	reagents_add = list(/datum/reagent/drug/cannabis = 0.3,
		/datum/reagent/toxin/mindbreaker = 0.3,
		/datum/reagent/mercury = 0.15,
		/datum/reagent/lithium = 0.15,
		/datum/reagent/medicine/atropine = 0.15,
		/datum/reagent/drug/methamphetamine = 0.15,
		/datum/reagent/drug/bath_salts = 0.15,
		/datum/reagent/drug/krokodil = 0.15,
		/datum/reagent/toxin/lipolicide = 0.15,
		/datum/reagent/drug/nicotine = 0.1,
	)
	rarity = 69
	graft_gene = /datum/plant_gene/trait/glow/green


// ---------------------------------------------------------------

/obj/item/food/grown/cannabis
	seed = /obj/item/seeds/cannabis
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	name = "cannabis leaf"
	desc = "Recently legalized in most galaxies."
	icon_state = "cannabis"
	bite_consumption_mod = 4
	foodtypes = VEGETABLES //i dont really know what else weed could be to be honest
	tastes = list("cannabis" = 1)
	wine_power = 20

/obj/item/food/grown/cannabis/rainbow
	seed = /obj/item/seeds/cannabis/rainbow
	name = "rainbow cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megacannabis"
	wine_power = 60

/obj/item/food/grown/cannabis/death
	seed = /obj/item/seeds/cannabis/death
	name = "death cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackcannabis"
	wine_power = 40

/obj/item/food/grown/cannabis/white
	seed = /obj/item/seeds/cannabis/white
	name = "white cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whitecannabis"
	wine_power = 10

/obj/item/food/grown/cannabis/ultimate
	seed = /obj/item/seeds/cannabis/ultimate
	name = "omega cannabis leaf"
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "ocannabis"
	bite_consumption_mod = 2 // Ingesting like 40 units of drugs in 1 bite at 100 potency
	wine_power = 90
