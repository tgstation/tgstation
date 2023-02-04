ADMIN_VERB(debug, toggle_field_of_view, "", (R_ADMIN|R_DEBUG))
	var/on_off = CONFIG_GET(flag/native_fov)

	message_admins("[key_name_admin(usr)] has [on_off ? "disabled" : "enabled"] the Native Field of View configuration..")
	log_admin("[key_name(usr)] has [on_off ? "disabled" : "enabled"] the Native Field of View configuration.")
	CONFIG_SET(flag/native_fov, !on_off)

	for(var/mob/living/mob in GLOB.player_list)
		mob.update_fov()
