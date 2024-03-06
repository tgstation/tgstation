/// Hyperlattice

/datum/xenoflora_plant/hyperlattice
	name = "Chronolized-Crystal Hyperlattice"
	desc = "A Nonbluetonian, Crystaline lattice formed out of... time. The initial sample of this Hyperlattice was located in the equipment of a REDACTED sent by REDACTED Nanotrasen" //something something time crystals

	icon_state = "hyperlattice"
	ground_icon_state = "water"
	seeds_icon_state = "xenoseeds-hyperlattice"

	required_gases = list(/datum/gas/plasma = 0.2)
	produced_gases = list()
	min_safe_temp = T0C
	max_safe_temp = T0C + 60

	min_produce = 2
	max_produce = 3
	produce_type = /obj/item/food/xenoflora/hyperlattice

/obj/item/food/xenoflora/hyperlattice   //You might ask, how the fuck can a spaceman eat literal time crystals? The answer is that I have no fucking idea.
	name = "Chrono-Crystaline Hyperlattice"
	desc = "Like anyone with hazardous material training, you know what happens when attempting to teleport a nonbluetonian object... right?" //in the future this will spawn a mob to fuck you up.
	icon_state = "hyperlattice"
	tastes = list("Crushed Crytal" = 3, "A Hyperposition of the Past and Future" = 1)
	bite_consumption = 3
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/drug/saturnx= 3)
	foodtypes = GROSS | VEGETABLES
	grind_results = list(/datum/reagent/drug/saturnx = 4, /datum/reagent/consumable/nutriment = 5)
	seed_type = /obj/item/xeno_seeds/hyperlattice
