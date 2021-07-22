///this spawner generates a random muscial instrument
/obj/effect/spawner/lootdrop/musical_instrument
	icon = 'icons/obj/musician.dmi'
	icon_state = "random_instrument"
	lootdoubles = FALSE
	loot = list(
			/obj/item/instrument/violin = 3,
			/obj/item/instrument/banjo = 3,
			/obj/item/instrument/guitar = 3,
			/obj/item/instrument/eguitar = 3,
			/obj/item/instrument/glockenspiel = 3,
			/obj/item/instrument/accordion = 3,
			/obj/item/instrument/trumpet = 3,
			/obj/item/instrument/saxophone = 3,
			/obj/item/instrument/trombone = 3,
			/obj/item/instrument/recorder = 3,
			/obj/item/instrument/harmonica = 3,
			// exotic instruments have smaller chance
			/obj/item/instrument/bikehorn = 1,
			/obj/item/instrument/violin/golden = 1
		)
