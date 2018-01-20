/obj/screen/adv_health
	name = "YOU SHOULD NOT SEE THIS!"
	icon = 'goon/icons/mob/mhealth.dmi'
	var/dmg_type = BRUTE

/obj/screen/adv_health/brute
	name = "brute health"
	icon_state = "mbrute0"
	screen_loc = ui_health

/obj/screen/adv_health/burn
	name = "burn health"
	icon_state = "mburn0"
	screen_loc = ui_health
	dmg_type = BURN

/obj/screen/adv_health/tox
	name = "toxin health"
	icon_state = "mtox0"
	screen_loc = ui_health
	dmg_type = TOX

/obj/screen/adv_health/oxy
	name = "oxygen health"
	icon_state = "moxy0"
	screen_loc = ui_health
	dmg_type = OXY