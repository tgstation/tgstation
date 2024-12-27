/datum/quirk/item_quirk/musician
	name = "Musician"
	desc = "You can tune handheld musical instruments to play melodies that clear certain negative effects and soothe the soul."
	icon = FA_ICON_GUITAR
	value = 2
	mob_trait = TRAIT_MUSICIAN
	gain_text = span_notice("You know everything about musical instruments.")
	lose_text = span_danger("You forget how musical instruments work.")
	medical_record_text = "Patient brain scans show a highly-developed auditory pathway."
	mail_goodies = list(/obj/effect/spawner/random/entertainment/musical_instrument, /obj/item/instrument/piano_synth/headphones)

/datum/quirk/item_quirk/musician/add_unique(client/client_source)
	give_item_to_holder(/obj/item/choice_beacon/music, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
