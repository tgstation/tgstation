/datum/quirk/snob
	name = "Snob"
	desc = "You care about the finer things, if a room doesn't look nice it's just not really worth it, is it?"
	icon = FA_ICON_USER_TIE
	value = 0
	gain_text = span_notice("You feel like you understand what things should look like.")
	lose_text = span_notice("Well who cares about deco anyways?")
	medical_record_text = "Patient seems to be rather stuck up."
	mob_trait = TRAIT_SNOB
	mail_goodies = list(/obj/item/chisel, /obj/item/paint_palette)
