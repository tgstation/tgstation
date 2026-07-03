/datum/quirk/item_quirk/blindness
	name = "Blind"
	desc = "Вы полностью слепой, и это необратимо."
	icon = FA_ICON_BLIND
	value = -16
	gain_text = span_danger("Вы ослепли и ничего не видите.")
	lose_text = span_notice("Чудесным образом к вам вернулось зрение.")
	medical_record_text = "У пациента необратимая слепота."
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
	give_item_to_holder(blindfold, list(LOCATION_EYES, LOCATION_HANDS))

/datum/quirk/item_quirk/blindness/is_species_appropriate(datum/species/mob_species)
	if(ispath(mob_species, /datum/species/dullahan))
		return FALSE
	return ..()

/datum/quirk/item_quirk/blindness/add(client/client_source)
	quirk_holder.become_blind(QUIRK_TRAIT)

/datum/quirk/item_quirk/blindness/remove()
	quirk_holder.cure_blind(QUIRK_TRAIT)
