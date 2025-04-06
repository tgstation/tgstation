/obj/item/clothing/head/mothcap
	name = "mothic softcap"
	desc = "A padded leather cap with goggles, standard issue aboard the moth fleet. Keeps your head warm and debris away from those big eyes."
	icon_state = "mothcap"
	icon = 'icons/obj/clothing/head/moth.dmi'
	worn_icon = 'icons/mob/clothing/head/moth.dmi'
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR

/obj/item/clothing/head/mothcap/original
	desc = "An authentic, padded leather cap with magnifying goggles, standard issue aboard the moth fleet. Keeps your head warm and debris away from those big eyes."

/obj/item/clothing/head/mothcap/original/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.2, zoom_method = ZOOM_METHOD_ITEM_ACTION, item_action_type = /datum/action/item_action/hands_free/moth_googles)
	AddComponent(/datum/component/adjust_fishing_difficulty, -4)

/obj/item/clothing/head/mothcap/original/item_action_slot_check(slot, mob/user, datum/action/action)
	return (slot & ITEM_SLOT_HEAD)
