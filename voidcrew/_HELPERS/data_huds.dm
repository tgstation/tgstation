/***********************************************
 Diagnostic HUDs!
************************************************/

/mob/living/proc/hud_set_nanite_indicator()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/nanite_icon = icon(icon, icon_state, dir)
	holder.pixel_y = nanite_icon.Height() - world.icon_size
	holder.icon_state = null
	if(src in SSnanites.nanite_monitored_mobs)
		holder.icon_state = "nanite_ping"
