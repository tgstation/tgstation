/mob/living/carbon/human/clean_blood()
	. = ..()
	cut_overlay(mutable_appearance('hippiestation/icons/effects/poo.dmi', "poohands"))

/mob/living/carbon/human/wash_cream()
	. = ..()
	cut_overlay(mutable_appearance('hippiestation/icons/effects/poo.dmi', "maskpoo"))