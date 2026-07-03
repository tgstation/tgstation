/datum/quirk/item_quirk/deafness
	name = "Deaf"
	desc = "Вы неизлечимо глухой."
	icon = FA_ICON_DEAF
	value = -8
	mob_trait = TRAIT_DEAF
	gain_text = span_danger("Вы ничего не слышите.")
	lose_text = span_notice("Вы снова можете слышать!")
	medical_record_text = "У пациента неизлечимо поврежден слуховой нерв."
	hardcore_value = 12
	mail_goodies = list(/obj/item/clothing/mask/whistle)

/datum/quirk/item_quirk/deafness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/clothing/accessory/deaf_pin, list(LOCATION_BACKPACK, LOCATION_HANDS))
