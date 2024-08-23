/datum/quirk/item_quirk/blindness
	name = "Blind"
	desc = "You are completely blind, nothing can counteract this."
	icon = FA_ICON_EYE_SLASH
	value = -16
	gain_text = span_danger("You can't see anything.")
	lose_text = span_notice("You miraculously gain back your vision.")
	medical_record_text = "Patient has permanent blindness."
	hardcore_value = 15
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/sunglasses, /obj/item/cane/white)

/datum/quirk_constant_data/blindfoldcolor
	associated_typepath = /datum/quirk/item_quirk/blindness
	customization_options = list(/datum/preference/color/blindfold_color)

/datum/quirk/item_quirk/blindness/add_unique(client/client_source)
	var/obj/item/clothing/glasses/blindfold/white/blindfold = new
	blindfold.add_atom_colour(client_source?.prefs.read_preference(/datum/preference/color/blindfold_color), FIXED_COLOUR_PRIORITY)
	blindfold.colored_before = TRUE
	give_item_to_holder(blindfold, list(LOCATION_EYES = ITEM_SLOT_EYES, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/item_quirk/blindness/add(client/client_source)
	quirk_holder.become_blind(QUIRK_TRAIT)

/datum/quirk/item_quirk/blindness/remove()
	quirk_holder.cure_blind(QUIRK_TRAIT)
