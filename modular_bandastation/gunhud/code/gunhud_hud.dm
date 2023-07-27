/datum/hud
	var/atom/movable/screen/gunhud_screen

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	gunhud_screen = new /atom/movable/screen/gunhud_screen(null, src)
	infodisplay += gunhud_screen
