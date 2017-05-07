/obj/item/clothing/mask/cursed_language
	name = "cursed language mask"
	desc = "It looks like a mask, but closer inspection reveals it's melded onto this persons face!"
	icon = 'icons/mob/mask.dmi'
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	var/status_effect

/obj/item/clothing/mask/cursed_language/equipped(mob/user, slot)
	. = ..()
	if(slot == slot_wear_mask && status_effect && isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(status_effect)

/obj/item/clothing/mask/cursed_language/pig
	name = "pig face"
	icon_state = "pig"
	item_state = "pig"
	status_effect = /datum/status_effect/cursed_language_mask/pig

/obj/item/clothing/mask/cursed_language/cow
	name = "cow face"
	icon_state = "cowmask"
	item_state = "cowmask"
	status_effect = /datum/status_effect/cursed_language_mask/cow

/obj/item/clothing/mask/cursed_language/horse
	name = "horse face"
	icon_state = "horsehead"
	item_state = "horsehead"
	status_effect = /datum/status_effect/cursed_language_mask/horse

// Status effect.

/datum/status_effect/cursed_language_mask
	id = "cursed_language_mask"
	duration = -1
	alert_type = null
	var/datum/language/forced_language

/datum/status_effect/cursed_language_mask/pig
	forced_language = /datum/language/animal/pig

/datum/status_effect/cursed_language_mask/horse
	forced_language = /datum/language/animal/horse

/datum/status_effect/cursed_language_mask/cow
	forced_language = /datum/language/animal/cow

/datum/status_effect/cursed_language_mask/tick()
	if(!iscarbon(owner))
		qdel(src)
		return

	var/mob/living/carbon/C = owner
	if(!istype(C.wear_mask, /obj/item/clothing/mask/cursed_language))
		qdel(src)
		return

	var/datum/language_holder/H = owner.get_language_holder()
	H.grant_language(forced_language)
	H.only_speaks_language = forced_language

/datum/status_effect/cursed_language_mask/on_remove()
	if(!QDELETED(owner))
		var/datum/language_holder/H = owner.get_language_holder()
		H.remove_language(forced_language)
		H.only_speaks_language = initial(H.only_speaks_language)
