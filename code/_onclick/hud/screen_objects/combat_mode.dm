/obj/screen/combat_mode
	name = "combat_mode"
	icon_state = "combat_off"
	screen_loc = ui_combat_mode
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/combat_mode/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/L = usr
		L.toggle_combat_mode()

/obj/screen/combat_mode/update_icon(mob/living/carbon/user)
	if(user.combat_mode)
		icon_state = "combat"
	else
		icon_state = "combat_off"
