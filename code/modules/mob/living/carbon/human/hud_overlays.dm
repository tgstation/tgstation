mob/var/image/antag_img
mob/living/carbon/human
	var/image/med_img
	var/image/sec_img
	var/image/sec2_img
	var/image/imp_img
	var/image/health_img

mob/New()
	. = ..()
	antag_img = image('icons/mob/hud.dmi',src)

mob/living/carbon/human/New()
	. = ..()
	med_img = image('icons/mob/hud.dmi',src)
	sec_img = image('icons/mob/hud.dmi',src)
	sec2_img = image('icons/mob/hud.dmi',src)
	imp_img = image('icons/mob/hud.dmi',src)
	health_img = image('icons/mob/hud.dmi',src)