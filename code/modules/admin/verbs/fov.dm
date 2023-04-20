ADMIN_VERB(toggle_fov, "Enable/Disable Field of View", "", R_ADMIN|R_DEBUG, VERB_CATEGORY_DEBUG)
	var/on_off = CONFIG_GET(flag/native_fov)

	message_admins("[key_name_admin(user)] has [on_off ? "disabled" : "enabled"] the Native Field of View configuration..")
	log_admin("[key_name(user)] has [on_off ? "disabled" : "enabled"] the Native Field of View configuration.")
	CONFIG_SET(flag/native_fov, !on_off)

	for(var/mob/living/mob in GLOB.player_list)
		mob.update_fov()
