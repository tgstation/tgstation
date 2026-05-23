/datum/quirk/item_quirk/limper
	name = "Limper"
	desc = "You have a pronounced limp when you walk. This will slow you down considerably. Good thing you brought your cane."
	icon = FA_ICON_PERSON_CANE
	gain_text = span_danger("Your leg feels a bit weak.")
	lose_text = span_notice("Your legs feel normal again.")
	medical_record_text = "Patient appears to suffer from a weakness in the leg."
	value = -6
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY

	mail_goodies = list(
		/obj/item/cane,
		/obj/item/cane/crutch,
		/obj/item/cane/white,
	)

/datum/quirk/item_quirk/limper/add_unique(client/client_source)
	give_item_to_holder(new /obj/item/cane(get_turf(quirk_holder)), list(
			LOCATION_HANDS,
			LOCATION_BACKPACK,
		))
	return

/datum/quirk/item_quirk/limper/add(client/client_source)
	quirk_holder.apply_status_effect(/datum/status_effect/limp/quirk)

/datum/quirk/item_quirk/limper/remove(client/client_source)
	quirk_holder.remove_status_effect(/datum/status_effect/limp/quirk)

