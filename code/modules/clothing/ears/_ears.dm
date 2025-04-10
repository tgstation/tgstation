
//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	lefthand_file = 'icons/mob/inhands/clothing/ears_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/ears_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_EARS
	resistance_flags = NONE

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon = 'icons/obj/clothing/ears.dmi'
	icon_state = "earmuffs"
	inhand_icon_state = "earmuffs"
	clothing_traits = list(TRAIT_DEAF)
	strip_delay = 15
	equip_delay_other = 25
	resistance_flags = FLAMMABLE
	custom_price = PAYCHECK_COMMAND * 1.5
	flags_cover = EARS_COVERED

/obj/item/clothing/ears/earmuffs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/earhealing)
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))
	AddComponent(/datum/component/adjust_fishing_difficulty, -2)

/obj/item/clothing/ears/earmuffs/debug
	name = "debug earmuffs"
	desc = "Wearing these sends a chat message for every sound played. Walking to ignore footsteps is highly recommended."
	clothing_traits = list(TRAIT_SOUND_DEBUGGED)
