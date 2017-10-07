/datum/hud
	var/obj/screen/vampire/vamp_blood_display

/datum/hud/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	vamp_blood_display = new /obj/screen/vampire()

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	. = ..()
	vamp_blood_display = new /obj/screen/vampire()
	infodisplay += vamp_blood_display

/datum/hud/Destroy()
	. = ..()
	vamp_blood_display = null