/obj/screen/adv_health
	name = "YOU SHOULD NOT SEE THIS!"
	icon = 'goon/icons/mob/mhealth.dmi'
	invisibility = INVISIBILITY_ABSTRACT
	var/mutable_appearance/color_overlay
	var/dmg_type = BRUTE

/obj/screen/adv_health/Initialize()
	. = ..()
	color_overlay = mutable_appearance(icon, "[dmg_type]_overlay")
	add_overlay(color_overlay)

/obj/screen/adv_health/Destroy()
	QDEL_NULL(color_overlay)

/obj/screen/adv_health/brute
	name = "brute health"
	icon_state = "brute"
	screen_loc = ui_health

/obj/screen/adv_health/burn
	name = "burn health"
	icon_state = "fire"
	screen_loc = ui_health
	dmg_type = BURN

/obj/screen/adv_health/tox
	name = "toxin health"
	icon_state = "tox"
	screen_loc = ui_health
	dmg_type = TOX

/obj/screen/adv_health/oxy
	name = "oxygen health"
	icon_state = "oxy"
	screen_loc = ui_health
	dmg_type = OXY