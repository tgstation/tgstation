/obj/item/toy/plush/pig
	name = "pig toy"
	desc = "Экипажу нужны свиньи!"
	icon = 'modular_bandastation/objects/icons/obj/items/pig.dmi'
	icon_state = "pig"
	inhand_icon_state = "pig"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/pig_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/pig_righthand.dmi'
	attack_verb_continuous = list("хрюкает")
	attack_verb_simple = list("хрюкаете")
	squeak_override = list('modular_bandastation/objects/sounds/oink.ogg' = 1)
	use_delay_override = 4 SECONDS
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
