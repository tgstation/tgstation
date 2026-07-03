//Corporate Judo Belt
/datum/storage/security_belt/judo
	max_slots = 3
	max_total_storage = 7

/obj/item/storage/belt/judobelt
	name = "Corporate Judo Belt"
	desc = "Обучает носителя корпоративному дзюдо НТ."
	icon = 'modular_bandastation/martial_arts/icons/belts.dmi'
	icon_state = "judobelt"
	worn_icon = 'modular_bandastation/martial_arts/icons/mob/belt.dmi'
	worn_icon_state = "judo"
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/security_belt/judo

/obj/item/storage/belt/judobelt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/judo)
