/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	inhand_icon_state = "cone"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	atom_size = ITEM_SIZE_SMALL
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")
	resistance_flags = NONE
	dynamic_hair_suffix = ""

/obj/item/clothing/head/cone/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", alpha = src.alpha)


