/datum/quirk/item_quirk/borg_ready
	name = "Cyborg Pre-screened dogtag"
	desc = "Get pre-approved for NT's experimental Cyborg program, with a dog tag that lets medical staff know."
	icon = FA_ICON_TAG
	value = 0
	gain_text = span_notice("You hear a distant echo of beeps and buzzes.")
	lose_text = span_danger("The distant beeping halts.")
	medical_record_text = "Patient is a registered brain donor for Robotics research."

/datum/quirk/item_quirk/borg_ready/add_unique(client/client_source)
	if(is_banned_from(client_source.ckey, JOB_CYBORG))
		return FALSE
	var/obj/item/clothing/accessory/dogtag/borg_ready/borgtag = new(get_turf(quirk_holder))
	give_item_to_holder(borgtag, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
