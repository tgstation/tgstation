///this spawner generates a random muscial instrument
/obj/effect/musical_instrument_spawner
	icon = 'icons/obj/musician.dmi'
	icon_state = "random_instrument"
	///This is the loot table for the spawner. Try to make sure the weights add up to 1000, so it is easy to understand.
	var/list/instrument_table = list(
		// 88% chance of a regular instrument
		/obj/item/instrument/violin = 80,
		/obj/item/instrument/banjo = 80,
		/obj/item/instrument/guitar = 80,
		/obj/item/instrument/eguitar = 80,
		/obj/item/instrument/glockenspiel = 80,
		/obj/item/instrument/accordion = 80,
		/obj/item/instrument/trumpet = 80,
		/obj/item/instrument/saxophone = 80,
		/obj/item/instrument/trombone = 80,
		/obj/item/instrument/recorder = 80,
		/obj/item/instrument/harmonica = 80,
		// 12% chance of a exotic instrument
		/obj/item/instrument/bikehorn = 60,
		/obj/item/instrument/violin/golden = 60)


/obj/effect/loot_site_spawner/Initialize()
	..()
	if(!length(instrument_table))
		return INITIALIZE_HINT_QDEL

	var/spawned_object = pickweight(instrument_table)
	new spawned_object(get_turf(src))

	return INITIALIZE_HINT_QDEL
