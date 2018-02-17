/obj/screen/adv_health
	name = "YOU SHOULD NOT SEE THIS!"
	icon = 'goon/icons/mob/mhealth.dmi'
	invisibility = INVISIBILITY_ABSTRACT
	var/mutable_appearance/color_overlay
	var/dmg_type = BRUTE

/obj/screen/adv_health/Initialize()
	. = ..()
	color_overlay = mutable_appearance(icon, "[dmg_type]_overlay")

/obj/screen/adv_health/Destroy()
	QDEL_NULL(color_overlay)
	return ..()

/obj/screen/adv_health/update_icon()
	cut_overlays()
	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.adv_health_hud)
			invisibility = 0
			var/dmg_amt = C.get_damage_amount(dmg_type)
			var/g = LERP(200, 0, CLAMP(dmg_amt, 0, 75)/75)
			var/r = -g*0.11+95
			if(C.stat == DEAD)
				icon_state = "ded"
			else
				if(dmg_amt >= 76)
					icon_state = "[dmg_type]_crit"
				else
					icon_state = dmg_type
				color_overlay.color = rgb(r, g, 0)
		else
			invisibility = INVISIBILITY_ABSTRACT
	add_overlay(color_overlay)

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