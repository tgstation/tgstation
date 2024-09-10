// Modular plants

// Catnip
/obj/item/seeds/tea/catnip
	name = "catnip seed pack"
	icon = 'modular_doppler/modular_hydroponics/icons/seeds.dmi'
	icon_state = "seed-catnip"
	growing_icon = 'modular_doppler/modular_hydroponics/icons/growing.dmi'
	desc = "Long stalks with flowering tips, they contain a chemical that attracts felines."
	species = "catnip"
	plantname = "Catnip Plant"
	icon_dead = null
	growthstages = 3
	product = /obj/item/food/grown/tea/catnip
	reagents_add = list(/datum/reagent/pax/catnip = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.06, /datum/reagent/toxin/teapowder = 0.1)
	rarity = 50

/obj/item/food/grown/tea/catnip
	seed = /obj/item/seeds/tea/catnip
	name = "catnip buds"
	icon = 'modular_doppler/modular_hydroponics/icons/harvest.dmi'
	icon_state = "catnip"
	filling_color = "#4582B4"
	grind_results = list(/datum/reagent/pax/catnip = 2, /datum/reagent/water = 1)
	distill_reagent = /datum/reagent/consumable/pinkmilk //Don't ask, cats speak in poptart
	can_distill = TRUE //override for tea's FALSE

