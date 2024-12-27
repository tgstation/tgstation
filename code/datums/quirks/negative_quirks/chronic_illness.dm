/datum/quirk/item_quirk/chronic_illness
	name = "Eradicative Chronic Illness"
	desc = "You have an anomalous chronic illness that requires constant medication to keep under control, or else causes timestream correction."
	icon = FA_ICON_DISEASE
	value = -12
	gain_text = span_danger("You feel like you are fading away...")
	lose_text = span_notice("You suddenly feel more substantial.")
	medical_record_text = "Patient has an anomalous chronic illness that requires constant medication to keep under control."
	hardcore_value = 12
	mail_goodies = list(/obj/item/storage/pill_bottle/sansufentanyl)

/datum/quirk/item_quirk/chronic_illness/add(client/client_source)
	var/datum/disease/chronic_illness/hms = new /datum/disease/chronic_illness()
	quirk_holder.ForceContractDisease(hms)

/datum/quirk/item_quirk/chronic_illness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/storage/pill_bottle/sansufentanyl, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK),flavour_text = "You've been provided with medication to help manage your condition. Take it regularly to avoid complications.")
	give_item_to_holder(/obj/item/healthanalyzer/simple/disease, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK))
