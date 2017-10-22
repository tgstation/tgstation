/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	staminas = new()
	infodisplay += staminas
	combo_object = new()
	infodisplay += combo_object
