/datum/quirk/item_quirk/nearsighted
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	icon = FA_ICON_GLASSES
	value = -4
	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("You start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/clothing/glasses/regular) // extra pair if orginal one gets broken by somebody mean

/datum/quirk_constant_data/nearsighted
	associated_typepath = /datum/quirk/item_quirk/nearsighted
	customization_options = list(/datum/preference/choiced/glasses)

/datum/quirk/item_quirk/nearsighted/add_unique(client/client_source)
	var/glasses_name = client_source?.prefs.read_preference(/datum/preference/choiced/glasses) || "Regular"
	var/obj/item/clothing/glasses/glasses_type

	glasses_name = glasses_name == "Random" ? pick(GLOB.nearsighted_glasses) : glasses_name
	glasses_type = GLOB.nearsighted_glasses[glasses_name]

	give_item_to_holder(glasses_type, list(
		LOCATION_EYES = ITEM_SLOT_EYES,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS,
	))

/datum/quirk/item_quirk/nearsighted/add(client/client_source)
	quirk_holder.become_nearsighted(QUIRK_TRAIT)

/datum/quirk/item_quirk/nearsighted/remove()
	quirk_holder.cure_nearsighted(QUIRK_TRAIT)
