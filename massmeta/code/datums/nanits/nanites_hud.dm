/mob/living/proc/hud_set_nanite_indicator()
	var/image/holder = hud_list[NANITE_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(HAS_TRAIT(src, TRAIT_NANITE_MONITORING))
		holder.icon_state = "nanite_ping"
