//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
//the procs are cause you can't put the comments in the GLOB var define
GLOBAL_PROTECT(admin_verbs_default)
GLOBAL_LIST_INIT(admin_verbs_default, world.AVerbsDefault())
/world/proc/AVerbsDefault()
	return list(
	/datum/client_base/proc/deadmin,				/*destroys our own admin datum so we can play as a regular player*/
	/datum/client_base/proc/cmd_admin_say,			/*admin-only ooc chat*/
	/datum/client_base/proc/hide_verbs,			/*hides all our adminverbs*/
	/datum/client_base/proc/hide_most_verbs,		/*hides all our hideable adminverbs*/
	/datum/client_base/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/datum/client_base/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/datum/client_base/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/datum/client_base/proc/secrets,
	/datum/client_base/proc/toggle_hear_radio,		/*allows admins to hide all radio output*/
	/datum/client_base/proc/reload_admins,
	/datum/client_base/proc/reestablish_db_connection, /*reattempt a connection to the database*/
	/datum/client_base/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/datum/client_base/proc/cmd_admin_pm_panel,		/*admin-pm list*/
	/datum/client_base/proc/cmd_admin_ticket_panel,
	/datum/client_base/proc/stop_sounds
	)
GLOBAL_PROTECT(admin_verbs_admin)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVerbsAdmin())
/world/proc/AVerbsAdmin()
	return list(
	/datum/client_base/proc/invisimin,				/*allows our mob to go invisible/visible*/
//	/datum/admins/proc/show_traitor_panel,	/*interface which shows a mob's mind*/ -Removed due to rare practical use. Moved to debug verbs ~Errorage
	/datum/admins/proc/show_player_panel,	/*shows an interface for individual players, with various links (links require additional flags*/
	/datum/client_base/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/datum/client_base/proc/check_ai_laws,			/*shows AI and borg laws*/
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/datum/admins/proc/set_admin_notice, /*announcement all clients see when joining the server.*/
	/datum/client_base/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/datum/client_base/proc/toggle_view_range,		/*changes how far we can see*/
	/datum/admins/proc/view_txt_log,	/*shows the server log (world_game_log) for today*/
	/datum/admins/proc/view_atk_log,	/*shows the server combat-log, doesn't do anything presently*/
	/datum/client_base/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/datum/client_base/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/datum/client_base/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/datum/client_base/proc/check_antagonists,		/*shows all antags*/
	/datum/admins/proc/access_news_network,	/*allows access of newscasters*/
	/datum/client_base/proc/getserverlog,			/*allows us to fetch server logs (world_game_log) for other days*/
	/datum/client_base/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/datum/client_base/proc/Getmob,				/*teleports a mob to our location*/
	/datum/client_base/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
//	/datum/client_base/proc/sendmob,				/*sends a mob somewhere*/ -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/datum/client_base/proc/jumptoarea,
	/datum/client_base/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/datum/client_base/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/datum/client_base/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/datum/client_base/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/datum/client_base/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcom*/
	/datum/client_base/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/datum/client_base/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/datum/client_base/proc/cmd_admin_local_narrate,	/*sends text to all mobs within view of atom*/
	/datum/client_base/proc/cmd_admin_create_centcom_report,
	/datum/client_base/proc/cmd_change_command_name,
	/datum/client_base/proc/cmd_admin_check_player_exp, /* shows players by playtime */
	/datum/client_base/proc/toggle_antag_hud, 	/*toggle display of the admin antag hud*/
	/datum/client_base/proc/toggle_AI_interact, /*toggle admin ability to interact with machines as an AI*/
	/datum/client_base/proc/customiseSNPC, /* Customise any interactive crewmembers in the world */
	/datum/client_base/proc/resetSNPC, /* Resets any interactive crewmembers in the world */
	/datum/client_base/proc/open_shuttle_manipulator, /* Opens shuttle manipulator UI */
	/datum/client_base/proc/deadchat,
	/datum/client_base/proc/toggleprayers,
	/datum/client_base/proc/toggleadminhelpsound,
	/datum/client_base/proc/respawn_character
	)
GLOBAL_PROTECT(admin_verbs_ban)
GLOBAL_LIST_INIT(admin_verbs_ban, list(/datum/client_base/proc/unban_panel, /datum/client_base/proc/DB_ban_panel, /datum/client_base/proc/stickybanpanel))
GLOBAL_PROTECT(admin_verbs_sounds)
GLOBAL_LIST_INIT(admin_verbs_sounds, list(/datum/client_base/proc/play_local_sound, /datum/client_base/proc/play_sound, /datum/client_base/proc/set_round_end_sound))
GLOBAL_PROTECT(admin_verbs_fun)
GLOBAL_LIST_INIT(admin_verbs_fun, list(
	/datum/client_base/proc/cmd_admin_dress,
	/datum/client_base/proc/cmd_admin_gib_self,
	/datum/client_base/proc/drop_bomb,
	/datum/client_base/proc/set_dynex_scale,
	/datum/client_base/proc/drop_dynex_bomb,
	/datum/client_base/proc/cinematic,
	/datum/client_base/proc/one_click_antag,
	/datum/client_base/proc/cmd_admin_add_freeform_ai_law,
	/datum/client_base/proc/object_say,
	/datum/client_base/proc/toggle_random_events,
	/datum/client_base/proc/set_ooc,
	/datum/client_base/proc/reset_ooc,
	/datum/client_base/proc/forceEvent,
	/datum/client_base/proc/admin_change_sec_level,
	/datum/client_base/proc/toggle_nuke,
	/datum/client_base/proc/mass_zombie_infection,
	/datum/client_base/proc/mass_zombie_cure,
	/datum/client_base/proc/polymorph_all,
	/datum/client_base/proc/show_tip,
	/datum/client_base/proc/smite
	))
GLOBAL_PROTECT(admin_verbs_spawn)
GLOBAL_LIST_INIT(admin_verbs_spawn, list(/datum/admins/proc/spawn_atom, /datum/client_base/proc/respawn_character))
GLOBAL_PROTECT(admin_verbs_server)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVerbsServer())
/world/proc/AVerbsServer()
	return list(
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/client_base/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/datum/client_base/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/datum/client_base/proc/cmd_debug_del_all,
	/datum/client_base/proc/toggle_random_events,
	/datum/client_base/proc/forcerandomrotate,
	/datum/client_base/proc/adminchangemap,
	/datum/client_base/proc/panicbunker,
	/datum/client_base/proc/toggle_hub
	)
GLOBAL_PROTECT(admin_verbs_debug)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVerbsDebug())
/world/proc/AVerbsDebug()
	return list(
	/datum/client_base/proc/restart_controller,
	/datum/client_base/proc/cmd_admin_list_open_jobs,
	/datum/client_base/proc/Debug2,
	/datum/client_base/proc/cmd_debug_make_powernets,
	/datum/client_base/proc/cmd_debug_mob_lists,
	/datum/client_base/proc/cmd_admin_delete,
	/datum/client_base/proc/cmd_debug_del_all,
	/datum/client_base/proc/restart_controller,
	/datum/client_base/proc/enable_debug_verbs,
	/datum/client_base/proc/callproc,
	/datum/client_base/proc/callproc_datum,
	/datum/client_base/proc/SDQL2_query,
	/datum/client_base/proc/test_movable_UI,
	/datum/client_base/proc/test_snap_UI,
	/datum/client_base/proc/debugNatureMapGenerator,
	/datum/client_base/proc/check_bomb_impacts,
	/proc/machine_upgrade,
	/datum/client_base/proc/populate_world,
	/datum/client_base/proc/get_dynex_power,		//*debug verbs for dynex explosions.
	/datum/client_base/proc/get_dynex_range,		//*debug verbs for dynex explosions.
	/datum/client_base/proc/set_dynex_scale,
	/datum/client_base/proc/cmd_display_del_log,
	/datum/client_base/proc/create_outfits,
	/datum/client_base/proc/modify_goals,
	/datum/client_base/proc/debug_huds,
	/datum/client_base/proc/map_template_load,
	/datum/client_base/proc/map_template_upload,
	/datum/client_base/proc/jump_to_ruin,
	/datum/client_base/proc/clear_dynamic_transit,
	/datum/client_base/proc/toggle_medal_disable,
	/datum/client_base/proc/view_runtimes,
	/datum/client_base/proc/pump_random_event,
	/datum/client_base/proc/cmd_display_init_log
	)
GLOBAL_PROTECT(admin_verbs_possess)
GLOBAL_LIST_INIT(admin_verbs_possess, list(/proc/possess, /proc/release))
GLOBAL_PROTECT(admin_verbs_permissions)
GLOBAL_LIST_INIT(admin_verbs_permissions, list(/datum/client_base/proc/edit_admin_permissions))
GLOBAL_PROTECT(admin_verbs_poll)
GLOBAL_LIST_INIT(admin_verbs_poll, list(/datum/client_base/proc/create_poll))

//verbs which can be hidden - needs work
GLOBAL_PROTECT(admin_verbs_hideable)
GLOBAL_LIST_INIT(admin_verbs_hideable, list(
	/datum/client_base/proc/set_ooc,
	/datum/client_base/proc/reset_ooc,
	/datum/client_base/proc/deadmin,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/datum/admins/proc/set_admin_notice,
	/datum/client_base/proc/admin_ghost,
	/datum/client_base/proc/toggle_view_range,
	/datum/admins/proc/view_txt_log,
	/datum/admins/proc/view_atk_log,
	/datum/client_base/proc/cmd_admin_subtle_message,
	/datum/client_base/proc/cmd_admin_check_contents,
	/datum/admins/proc/access_news_network,
	/datum/client_base/proc/admin_call_shuttle,
	/datum/client_base/proc/admin_cancel_shuttle,
	/datum/client_base/proc/cmd_admin_direct_narrate,
	/datum/client_base/proc/cmd_admin_world_narrate,
	/datum/client_base/proc/cmd_admin_local_narrate,
	/datum/client_base/proc/play_local_sound,
	/datum/client_base/proc/play_sound,
	/datum/client_base/proc/set_round_end_sound,
	/datum/client_base/proc/cmd_admin_dress,
	/datum/client_base/proc/cmd_admin_gib_self,
	/datum/client_base/proc/drop_bomb,
	/datum/client_base/proc/drop_dynex_bomb,
	/datum/client_base/proc/get_dynex_range,
	/datum/client_base/proc/get_dynex_power,
	/datum/client_base/proc/set_dynex_scale,
	/datum/client_base/proc/cinematic,
	/datum/client_base/proc/cmd_admin_add_freeform_ai_law,
	/datum/client_base/proc/cmd_admin_create_centcom_report,
	/datum/client_base/proc/cmd_change_command_name,
	/datum/client_base/proc/object_say,
	/datum/client_base/proc/toggle_random_events,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/datum/client_base/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/datum/client_base/proc/restart_controller,
	/datum/client_base/proc/cmd_admin_list_open_jobs,
	/datum/client_base/proc/callproc,
	/datum/client_base/proc/callproc_datum,
	/datum/client_base/proc/Debug2,
	/datum/client_base/proc/reload_admins,
	/datum/client_base/proc/cmd_debug_make_powernets,
	/datum/client_base/proc/startSinglo,
	/datum/client_base/proc/cmd_debug_mob_lists,
	/datum/client_base/proc/cmd_debug_del_all,
	/datum/client_base/proc/enable_debug_verbs,
	/proc/possess,
	/proc/release,
	/datum/client_base/proc/reload_admins,
	/datum/client_base/proc/panicbunker,
	/datum/client_base/proc/admin_change_sec_level,
	/datum/client_base/proc/toggle_nuke,
	/datum/client_base/proc/cmd_display_del_log,
	/datum/client_base/proc/toggle_antag_hud,
	/datum/client_base/proc/debug_huds,
	/datum/client_base/proc/customiseSNPC,
	/datum/client_base/proc/resetSNPC,
	))

/client/add_admin_verbs()
	if(holder)
		control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS
	return ..()

/datum/client_base/proc/add_admin_verbs()
	if(holder)
		var/rights = holder.rank.rights
		verbs += GLOB.admin_verbs_default
		if(rights & R_BUILDMODE)
			verbs += /datum/client_base/proc/togglebuildmodeself
		if(rights & R_ADMIN)
			verbs += GLOB.admin_verbs_admin
		if(rights & R_BAN)
			verbs += GLOB.admin_verbs_ban
		if(rights & R_FUN)
			verbs += GLOB.admin_verbs_fun
		if(rights & R_SERVER)
			verbs += GLOB.admin_verbs_server
		if(rights & R_DEBUG)
			verbs += GLOB.admin_verbs_debug
		if(rights & R_POSSESS)
			verbs += GLOB.admin_verbs_possess
		if(rights & R_PERMISSIONS)
			verbs += GLOB.admin_verbs_permissions
		if(rights & R_STEALTH)
			verbs += /datum/client_base/proc/stealth
		if(rights & R_ADMIN)
			verbs += GLOB.admin_verbs_poll
		if(rights & R_SOUNDS)
			verbs += GLOB.admin_verbs_sounds
		if(rights & R_SPAWN)
			verbs += GLOB.admin_verbs_spawn

		for(var/path in holder.rank.adds)
			verbs += path
		for(var/path in holder.rank.subs)
			verbs -= path

/datum/client_base/proc/remove_admin_verbs()
	verbs.Remove(
		GLOB.admin_verbs_default,
		/datum/client_base/proc/togglebuildmodeself,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_fun,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		/datum/client_base/proc/stealth,
		GLOB.admin_verbs_poll,
		GLOB.admin_verbs_sounds,
		GLOB.admin_verbs_spawn,
		/*Debug verbs added by "show debug verbs"*/
		/datum/client_base/proc/Cell,
		/datum/client_base/proc/camera_view,
		/datum/client_base/proc/sec_camera_report,
		/datum/client_base/proc/intercom_view,
		/datum/client_base/proc/air_status,
		/datum/client_base/proc/atmosscan,
		/datum/client_base/proc/powerdebug,
		/datum/client_base/proc/count_objects_on_z_level,
		/datum/client_base/proc/count_objects_all,
		/datum/client_base/proc/cmd_assume_direct_control,
		/datum/client_base/proc/startSinglo,
		/datum/client_base/proc/set_server_fps,
		/datum/client_base/proc/cmd_admin_grantfullaccess,
		/datum/client_base/proc/cmd_admin_areatest_all,
		/datum/client_base/proc/cmd_admin_areatest_station,
		/datum/client_base/proc/readmin
		)
	if(holder)
		verbs.Remove(holder.rank.adds)

/datum/client_base/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"

	verbs.Remove(/datum/client_base/proc/hide_most_verbs, GLOB.admin_verbs_hideable)
	verbs += /datum/client_base/proc/show_verbs

	to_chat(src, "<span class='interface'>Most of your adminverbs have been hidden.</span>")
	SSblackbox.add_details("admin_verb","Hide Most Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/datum/client_base/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	verbs += /datum/client_base/proc/show_verbs

	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	SSblackbox.add_details("admin_verb","Hide All Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/datum/client_base/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	verbs -= /datum/client_base/proc/show_verbs
	add_admin_verbs()

	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	SSblackbox.add_details("admin_verb","Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!




/datum/client_base/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	if(!holder)
		return
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		if(!ghost.mind || !ghost.mind.current) //won't do anything if there is no body
			return
		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(usr)] re-entered corpse")
			message_admins("[key_name_admin(usr)] re-entered corpse")
		ghost.can_reenter_corpse = 1 //force re-entering even when otherwise not possible
		ghost.reenter_corpse()
		SSblackbox.add_details("admin_verb","Admin Reenter") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>")
	else
		//ghostize
		log_admin("[key_name(usr)] admin ghosted.")
		message_admins("[key_name_admin(usr)] admin ghosted.")
		var/mob/body = mob
		body.ghostize(1)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		SSblackbox.add_details("admin_verb","Admin Ghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/client_base/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(holder && mob)
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, "<span class='boldannounce'>Invisimin off. Invisibility reset.</span>")
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			to_chat(mob, "<span class='adminnotice'><b>Invisimin on. You are now as invisible as a ghost.</b></span>")

/datum/client_base/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
		if(!isobserver(usr))
			message_admins("[key_name_admin(usr)] checked antagonists.")
	SSblackbox.add_details("admin_verb","Check Antagonists") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if(holder)
		if(config.ban_legacy_system)
			holder.unbanpanel()
		else
			holder.DB_ban_panel()
	SSblackbox.add_details("admin_verb","Unban Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if(holder)
		holder.Game()
	SSblackbox.add_details("admin_verb","Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	SSblackbox.add_details("admin_verb","Secrets Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/client_base/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt

/datum/client_base/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

/datum/client_base/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			if(isobserver(mob))
				mob.invisibility = initial(mob.invisibility)
				mob.alpha = initial(mob.alpha)
				mob.name = initial(mob.name)
				mob.mouse_opacity = initial(mob.mouse_opacity)
		else
			var/new_key = ckeyEx(input("Enter your desired display name.", "Fake Key", key) as text|null)
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			createStealthKey()
			if(isobserver(mob))
				mob.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
				mob.alpha = 0 //JUUUUST IN CASE
				mob.name = " "
				mob.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
	SSblackbox.add_details("admin_verb","Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/drop_bomb()
	set category = "Special Verbs"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce? WARNING: These ignore the maxcap") as null|anything in choices
	var/turf/epicenter = mob.loc

	switch(choice)
		if(null)
			return 0
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, 1, 2, 3, 3, TRUE, TRUE)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, 2, 3, 4, 4, TRUE, TRUE)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, 3, 5, 7, 5, TRUE, TRUE)
		if("Maxcap")
			explosion(epicenter, GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as null|num
			if(devastation_range == null)
				return
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as null|num
			if(heavy_impact_range == null)
				return
			var/light_impact_range = input("Light impact range (in tiles):") as null|num
			if(light_impact_range == null)
				return
			var/flash_range = input("Flash range (in tiles):") as null|num
			if(flash_range == null)
				return
			if(devastation_range > GLOB.MAX_EX_DEVESTATION_RANGE || heavy_impact_range > GLOB.MAX_EX_HEAVY_RANGE || light_impact_range > GLOB.MAX_EX_LIGHT_RANGE || flash_range > GLOB.MAX_EX_FLASH_RANGE)
				if(alert("Bomb is bigger than the maxcap. Continue?",,"Yes","No") != "Yes")
					return
			epicenter = mob.loc //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, TRUE, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
	SSblackbox.add_details("admin_verb","Drop Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/drop_dynex_bomb()
	set category = "Special Verbs"
	set name = "Drop DynEx Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/ex_power = input("Explosive Power:") as null|num
	var/turf/epicenter = mob.loc
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
		log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
		SSblackbox.add_details("admin_verb","Drop Dynamic Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/get_dynex_range()
	set category = "Debug"
	set name = "Get DynEx Range"
	set desc = "Get the estimated range of a bomb, using explosive power."

	var/ex_power = input("Explosive Power:") as null|num
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Range: (Devestation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])")

/datum/client_base/proc/get_dynex_power()
	set category = "Debug"
	set name = "Get DynEx Power"
	set desc = "Get the estimated required power of a bomb, to reach a specific range."

	var/ex_range = input("Light Explosion Range:") as null|num
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Power: [power]")

/datum/client_base/proc/set_dynex_scale()
	set category = "Debug"
	set name = "Set DynEx Scale"
	set desc = "Set the scale multiplier of dynex explosions. The default is 0.5."

	var/ex_scale = input("New DynEx Scale:") as null|num
	if(!ex_scale)
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] has  modified Dynamic Explosion Scale: [ex_scale]")

/datum/client_base/proc/give_spell(mob/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	var/list/spell_list = list()
	var/type_length = length("/obj/effect/proc_holder/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext("[A]", type_length)] = A
	var/obj/effect/proc_holder/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_list
	if(!S)
		return

	SSblackbox.add_details("admin_verb","Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] gave [key_name(T)] the spell [S].</span>")

	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)
		message_admins("<span class='danger'>Spells given to mindless mobs will not be transferred in mindswap or cloning!</span>")

/datum/client_base/proc/remove_spell(mob/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Remove Spell"
	set desc = "Remove a spell from the selected mob."

	if(T && T.mind)
		var/obj/effect/proc_holder/spell/S = input("Choose the spell to remove", "NO ABRAKADABRA") as null|anything in T.mind.spell_list
		if(S)
			T.mind.RemoveSpell(S)
			log_admin("[key_name(usr)] removed the spell [S] from [key_name(T)].")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] removed the spell [S] from [key_name(T)].</span>")
			SSblackbox.add_details("admin_verb","Remove Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/give_disease(mob/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in SSdisease.diseases
	if(!D) return
	T.ForceContractDisease(new D)
	SSblackbox.add_details("admin_verb","Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] gave [key_name(T)] the disease [D].</span>")

/datum/client_base/proc/object_say(obj/O in world)
	set category = "Special Verbs"
	set name = "OSay"
	set desc = "Makes an object say something."
	var/message = input(usr, "What do you want the message to be?", "Make Sound") as text | null
	if(!message)
		return
	O.say(message)
	log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z] say \"[message]\"")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z]. say \"[message]\"</span>")
	SSblackbox.add_details("admin_verb","Object Say") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/datum/client_base/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Special Verbs"
	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.add_details("admin_verb","Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/client_base/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"
	if(holder)
		src.holder.output_ai_laws()

/datum/client_base/proc/deadmin()
	set name = "Deadmin"
	set category = "Admin"
	set desc = "Shed your admin powers."

	if(!holder)
		return

	if(has_antag_hud())
		toggle_antag_hud()

	holder.disassociate()
	qdel(holder)

	GLOB.deadmins += ckey
	GLOB.admin_datums -= ckey
	verbs += /datum/client_base/proc/readmin

	to_chat(src, "<span class='interface'>You are now a normal player.</span>")
	log_admin("[src] deadmined themself.")
	message_admins("[src] deadmined themself.")
	SSblackbox.add_details("admin_verb","Deadmin")

/datum/client_base/proc/readmin()
	set name = "Readmin"
	set category = "Admin"
	set desc = "Regain your admin powers."

	load_admins(ckey)

	if(!holder) // Something went wrong...
		return

	GLOB.deadmins -= ckey
	verbs -= /datum/client_base/proc/readmin

	to_chat(src, "<span class='interface'>You are now an admin.</span>")
	message_admins("[src] re-adminned themselves.")
	log_admin("[src] re-adminned themselves.")
	SSblackbox.add_details("admin_verb","Readmin")

/datum/client_base/proc/populate_world(amount = 50 as num)
	set name = "Populate World"
	set category = "Debug"
	set desc = "(\"Amount of mobs to create\") Populate the world with test mobs."

	if (amount > 0)
		var/area/area
		var/list/candidates
		var/turf/open/floor/tile
		var/j,k

		for (var/i = 1 to amount)
			j = 100

			do
				area = pick(GLOB.the_station_areas)

				if (area)

					candidates = get_area_turfs(area)

					if (candidates.len)
						k = 100

						do
							tile = pick(candidates)
						while ((!tile || !istype(tile)) && --k > 0)

						if (tile)
							new/mob/living/carbon/human/interactive(tile)
							testing("Spawned test mob at [tile.x],[tile.y],[tile.z]")
			while (!area && --j > 0)

/datum/client_base/proc/toggle_AI_interact()
	set name = "Toggle Admin AI Interact"
	set category = "Admin"
	set desc = "Allows you to interact with most machines as an AI would as a ghost"

	AI_Interact = !AI_Interact
	if(mob && IsAdminGhost(mob))
		mob.has_unlimited_silicon_privilege = AI_Interact

	log_admin("[key_name(usr)] has [AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] has [AI_Interact ? "activated" : "deactivated"] their AI interaction")
