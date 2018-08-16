//supply packs

/datum/supply_pack/misc/kinkmate
	name = "Kinkmate construction kit"
	cost = 2000
	contraband = TRUE
	contains = list(/obj/item/vending_refill/kink, /obj/item/circuitboard/machine/kinkmate)
	crate_name = "Kinkmate construction kit"


//Food and livestocks

/datum/supply_pack/organic/critter/kiwi
	name = "Space kiwi Crate"
	cost = 2000
	contains = list( /mob/living/simple_animal/kiwi)
	crate_name = "space kiwi crate"


//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc/jukebox
	name = "Jukebox"
	cost = 1000000
	contains = list(/obj/machinery/jukebox)
	crate_name = "Jukebox"
