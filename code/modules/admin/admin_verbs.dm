//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
//the procs are cause you can't put the comments in the GLOB var define
GLOBAL_LIST_INIT(admin_verbs_default, world.AVerbsDefault())
GLOBAL_PROTECT(admin_verbs_default)
/world/proc/AVerbsDefault()
	return list(
	/client/proc/deadmin, /*destroys our own admin datum so we can play as a regular player*/
	/client/proc/cmd_admin_say, /*admin-only ooc chat*/
	/client/proc/hide_verbs, /*hides all our adminverbs*/
	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/dsay, /*talk in deadchat using our ckey/fakekey*/
	/client/proc/investigate_show, /*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,
	/client/proc/reload_admins,
	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
	/client/proc/cmd_admin_pm_context, /*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel, /*admin-pm list*/
	/client/proc/stop_sounds,
	/client/proc/mark_datum_mapview,
	/client/proc/tag_datum_mapview,
	/client/proc/debugstatpanel,
	/client/proc/fix_air, /*resets air in designated radius to its default atmos composition*/
	/client/proc/requests
	)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVerbsAdmin())
GLOBAL_PROTECT(admin_verbs_admin)
/world/proc/AVerbsAdmin()
	return list(
	/client/proc/invisimin, /*allows our mob to go invisible/visible*/
// /datum/admins/proc/show_traitor_panel, /*interface which shows a mob's mind*/ -Removed due to rare practical use. Moved to debug verbs ~Errorage
	/datum/admins/proc/show_lag_switch_panel,
	/datum/admins/proc/show_player_panel, /*shows an interface for individual players, with various links (links require additional flags*/
	/datum/verbs/menu/Admin/verb/playerpanel,
	/client/proc/game_panel, /*game panel, allows to change game-mode etc*/
	/client/proc/check_ai_laws, /*shows AI and borg laws*/
	/client/proc/ghost_pool_protection, /*opens a menu for toggling ghost roles*/
	/datum/admins/proc/toggleooc, /*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead, /*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggleenter, /*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests, /*toggles whether guests can join the current game*/
	/datum/admins/proc/announce, /*priority announce something to all clients.*/
	/datum/admins/proc/set_admin_notice, /*announcement all clients see when joining the server.*/
	/client/proc/admin_ghost, /*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range, /*changes how far we can see*/
	/client/proc/getserverlogs, /*for accessing server logs*/
	/client/proc/getcurrentlogs, /*for accessing server logs for the current round*/
	/client/proc/cmd_admin_subtle_message, /*send a message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_headset_message, /*send a message to somebody through their headset as CentCom*/
	/client/proc/cmd_admin_delete, /*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents, /*displays the contents of an instance*/
	/client/proc/centcom_podlauncher,/*Open a window to launch a Supplypod and configure it or it's contents*/
	/client/proc/check_antagonists, /*shows all antags*/
	/datum/admins/proc/access_news_network, /*allows access of newscasters*/
	/client/proc/jumptocoord, /*we ghost and jump to a coordinate*/
	/client/proc/Getmob, /*teleports a mob to our location*/
	/client/proc/Getkey, /*teleports a mob with a certain ckey to our location*/
// /client/proc/sendmob, /*sends a mob somewhere*/ -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/client/proc/jumptoarea,
	/client/proc/jumptokey, /*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob, /*allows us to jump to a specific mob*/
	/client/proc/jumptoturf, /*allows us to jump to a specific turf*/
	/client/proc/admin_call_shuttle, /*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle, /*allows us to cancel the emergency shuttle, sending it back to centcom*/
	/client/proc/admin_disable_shuttle, /*allows us to disable the emergency shuttle admin-wise so that it cannot be called*/
	/client/proc/admin_enable_shuttle,  /*undoes the above*/
	/client/proc/cmd_admin_direct_narrate, /*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_world_narrate, /*sends text to all players with no padding*/
	/client/proc/cmd_admin_local_narrate, /*sends text to all mobs within view of atom*/
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/cmd_change_command_name,
	/client/proc/cmd_admin_check_player_exp, /* shows players by playtime */
	/client/proc/toggle_combo_hud, // toggle display of the combination pizza antag and taco sci/med/eng hud
	/client/proc/toggle_AI_interact, /*toggle admin ability to interact with machines as an AI*/
	/datum/admins/proc/open_shuttlepanel, /* Opens shuttle manipulator UI */
	/client/proc/respawn_character,
	/datum/admins/proc/open_borgopanel,
	/datum/admins/proc/view_all_circuits,
	/datum/admins/proc/view_all_sdql_spells,
	/datum/admins/proc/known_alts_panel,
	/datum/admins/proc/paintings_manager,
	/datum/admins/proc/display_tags,
	/datum/admins/proc/fishing_calculator,
	)
GLOBAL_LIST_INIT(admin_verbs_ban, list(/client/proc/unban_panel, /client/proc/ban_panel, /client/proc/stickybanpanel))
GLOBAL_PROTECT(admin_verbs_ban)
GLOBAL_LIST_INIT(admin_verbs_sounds, list(/client/proc/play_local_sound, /client/proc/play_direct_mob_sound, /client/proc/play_sound, /client/proc/set_round_end_sound))
GLOBAL_PROTECT(admin_verbs_sounds)
GLOBAL_LIST_INIT(admin_verbs_fun, list(
	/client/proc/cmd_select_equipment,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/set_dynex_scale,
	/client/proc/drop_dynex_bomb,
	/client/proc/cinematic,
	/client/proc/summon_ert,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/object_say,
	/client/proc/toggle_random_events,
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
	/client/proc/forceEvent,
	/client/proc/admin_change_sec_level,
	/client/proc/toggle_nuke,
	/client/proc/run_weather,
	/client/proc/mass_zombie_infection,
	/client/proc/mass_zombie_cure,
	/client/proc/polymorph_all,
	/client/proc/show_tip,
	/client/proc/smite,
	/client/proc/admin_away,
	/client/proc/add_mob_ability,
	/datum/admins/proc/station_traits_panel,
	))
GLOBAL_PROTECT(admin_verbs_fun)
GLOBAL_LIST_INIT(admin_verbs_spawn, list(/datum/admins/proc/spawn_atom, /datum/admins/proc/podspawn_atom, /datum/admins/proc/spawn_cargo, /datum/admins/proc/spawn_objasmob, /client/proc/respawn_character, /datum/admins/proc/beaker_panel))
GLOBAL_PROTECT(admin_verbs_spawn)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVerbsServer())
GLOBAL_PROTECT(admin_verbs_server)
/world/proc/AVerbsServer()
	return list(
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete, /*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_force_del_all,
	/client/proc/cmd_debug_hard_del_all,
	/client/proc/toggle_random_events,
	/client/proc/forcerandomrotate,
	/client/proc/adminchangemap,
	/client/proc/panicbunker,
	/client/proc/toggle_interviews,
	/client/proc/toggle_hub,
	/client/proc/toggle_cdn
	)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVerbsDebug())
GLOBAL_PROTECT(admin_verbs_debug)
/world/proc/AVerbsDebug()
	return list(
	/client/proc/restart_controller,
	/client/proc/debug_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/Debug2,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_force_del_all,
	/client/proc/cmd_debug_hard_del_all,
	/client/proc/restart_controller,
	/client/proc/enable_mapping_verbs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/SDQL2_query,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/client/proc/debugNatureMapGenerator,
	/client/proc/check_bomb_impacts,
	/proc/machine_upgrade,
	/client/proc/populate_world,
	/client/proc/get_dynex_power, //*debug verbs for dynex explosions.
	/client/proc/get_dynex_range, //*debug verbs for dynex explosions.
	/client/proc/set_dynex_scale,
	/client/proc/cmd_display_del_log,
	/client/proc/outfit_manager,
	/client/proc/open_colorblind_test,
	/client/proc/generate_wikichem_list,
	/client/proc/modify_goals,
	/client/proc/debug_huds,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/jump_to_ruin,
	/client/proc/clear_dynamic_transit,
	/client/proc/run_empty_query,
	/client/proc/toggle_medal_disable,
	/client/proc/view_runtimes,
	/client/proc/pump_random_event,
	/client/proc/cmd_display_init_log,
	/client/proc/cmd_display_overlay_log,
	/client/proc/reload_configuration,
	/client/proc/atmos_control,
	/client/proc/reload_cards,
	/client/proc/validate_cards,
	/client/proc/test_cardpack_distribution,
	/client/proc/print_cards,
	#ifdef TESTING
	/client/proc/check_missing_sprites,
	/client/proc/run_dynamic_simulations,
	#endif
	/client/proc/display_sendmaps,
	/datum/admins/proc/create_or_modify_area,
	/client/proc/check_timer_sources,
	/client/proc/toggle_cdn,
	/client/proc/cmd_sdql_spell_menu,
	/client/proc/adventure_manager,
	/client/proc/load_circuit,
	/client/proc/cmd_admin_toggle_fov,
	/client/proc/cmd_admin_debug_traitor_objectives,
	/client/proc/spawn_debug_full_crew,
	/client/proc/validate_puzzgrids,
	)
GLOBAL_LIST_INIT(admin_verbs_possess, list(/proc/possess, /proc/release))
GLOBAL_PROTECT(admin_verbs_possess)
GLOBAL_LIST_INIT(admin_verbs_permissions, list(/client/proc/edit_admin_permissions))
GLOBAL_PROTECT(admin_verbs_permissions)
GLOBAL_LIST_INIT(admin_verbs_poll, list(/client/proc/poll_panel))
GLOBAL_PROTECT(admin_verbs_poll)

//verbs which can be hidden - needs work
GLOBAL_LIST_INIT(admin_verbs_hideable, list(
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
	/client/proc/deadmin,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/show_skill_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/datum/admins/proc/set_admin_notice,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_headset_message,
	/client/proc/cmd_admin_check_contents,
	/datum/admins/proc/access_news_network,
	/client/proc/admin_call_shuttle,
	/client/proc/admin_cancel_shuttle,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/cmd_admin_local_narrate,
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/set_round_end_sound,
	/client/proc/cmd_select_equipment,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/drop_dynex_bomb,
	/client/proc/get_dynex_range,
	/client/proc/get_dynex_power,
	/client/proc/set_dynex_scale,
	/client/proc/cinematic,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/cmd_change_command_name,
	/client/proc/object_say,
	/client/proc/toggle_random_events,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_force_del_all,
	/client/proc/cmd_debug_hard_del_all,
	/client/proc/enable_mapping_verbs,
	/proc/possess,
	/proc/release,
	/client/proc/reload_admins,
	/client/proc/panicbunker,
	/client/proc/toggle_interviews,
	/client/proc/admin_change_sec_level,
	/client/proc/toggle_nuke,
	/client/proc/cmd_display_del_log,
	/client/proc/toggle_combo_hud,
	/client/proc/debug_huds
	))
GLOBAL_PROTECT(admin_verbs_hideable)

/client/proc/add_admin_verbs()
	if(holder)
		control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

		var/rights = holder.rank_flags()
		add_verb(src, GLOB.admin_verbs_default)
		if(rights & R_BUILD)
			add_verb(src, /client/proc/togglebuildmodeself)
		if(rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_admin)
		if(rights & R_BAN)
			add_verb(src, GLOB.admin_verbs_ban)
		if(rights & R_FUN)
			add_verb(src, GLOB.admin_verbs_fun)
		if(rights & R_SERVER)
			add_verb(src, GLOB.admin_verbs_server)
		if(rights & R_DEBUG)
			add_verb(src, GLOB.admin_verbs_debug)
		if(rights & R_POSSESS)
			add_verb(src, GLOB.admin_verbs_possess)
		if(rights & R_PERMISSIONS)
			add_verb(src, GLOB.admin_verbs_permissions)
		if(rights & R_STEALTH)
			add_verb(src, /client/proc/stealth)
		if(rights & R_ADMIN)
			add_verb(src, GLOB.admin_verbs_poll)
		if(rights & R_SOUND)
			add_verb(src, GLOB.admin_verbs_sounds)
			if(CONFIG_GET(string/invoke_youtubedl))
				add_verb(src, /client/proc/play_web_sound)
		if(rights & R_SPAWN)
			add_verb(src, GLOB.admin_verbs_spawn)

/client/proc/remove_admin_verbs()
	remove_verb(src, list(
		GLOB.admin_verbs_default,
		/client/proc/togglebuildmodeself,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_fun,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		/client/proc/stealth,
		GLOB.admin_verbs_poll,
		GLOB.admin_verbs_sounds,
		/client/proc/play_web_sound,
		GLOB.admin_verbs_spawn,
		/*Debug verbs added by "show debug verbs"*/
		GLOB.admin_verbs_debug_mapping,
		/client/proc/disable_mapping_verbs,
		/client/proc/readmin
		))

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	add_verb(src, /client/proc/show_verbs)

	to_chat(src, span_interface("Almost all of your adminverbs have been hidden."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide All Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!




/client/proc/admin_ghost()
	set category = "Admin.Game"
	set name = "Aghost"
	if(!holder)
		return
	. = TRUE
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		if(!ghost.mind || !ghost.mind.current) //won't do anything if there is no body
			return FALSE
		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(usr)] re-entered corpse")
			message_admins("[key_name_admin(usr)] re-entered corpse")
		ghost.can_reenter_corpse = 1 //force re-entering even when otherwise not possible
		ghost.reenter_corpse()
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Reenter") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>", confidential = TRUE)
		return FALSE
	else
		//ghostize
		log_admin("[key_name(usr)] admin ghosted.")
		message_admins("[key_name_admin(usr)] admin ghosted.")
		var/mob/body = mob
		body.ghostize(1)
		init_verbs()
		if(body && !body.key)
			body.key = "@[key]" //Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Ghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin.Game"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(holder && mob)
		if(initial(mob.invisibility) == INVISIBILITY_OBSERVER)
			to_chat(mob, span_boldannounce("Invisimin toggle failed. You are already an invisible mob like a ghost."), confidential = TRUE)
			return
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, span_boldannounce("Invisimin off. Invisibility reset."), confidential = TRUE)
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			to_chat(mob, span_adminnotice("<b>Invisimin on. You are now as invisible as a ghost.</b>"), confidential = TRUE)

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin.Game"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.") //for tsar~
		if(!isobserver(usr) && SSticker.HasRoundStarted())
			message_admins("[key_name_admin(usr)] checked antagonists.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antagonists") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/ban_panel()
	set name = "Banning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Banning Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unban_panel()
	set name = "Unbanning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.unban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unbanning Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin.Game"
	if(holder)
		holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/poll_panel()
	set name = "Server Poll Management"
	set category = "Admin"
	if(!check_rights(R_POLL))
		return
	holder.poll_list_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Server Poll Management") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!holder)
		return

	if(holder.fakekey)
		disable_stealth_mode()
	else
		enable_stealth_mode()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#define STEALTH_MODE_TRAIT "stealth_mode"

/client/proc/enable_stealth_mode()
	var/new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Fake Key", key, 26))
	if(!new_key)
		return
	holder.fakekey = new_key
	createStealthKey()
	if(isobserver(mob))
		mob.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
		mob.alpha = 0 //JUUUUST IN CASE
		mob.name = " "
		mob.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	ADD_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)
	QDEL_NULL(mob.orbiters)

	log_admin("[key_name(usr)] has turned stealth mode ON")
	message_admins("[key_name_admin(usr)] has turned stealth mode ON")

/client/proc/disable_stealth_mode()
	holder.fakekey = null
	if(isobserver(mob))
		mob.invisibility = initial(mob.invisibility)
		mob.alpha = initial(mob.alpha)
		if(mob.mind)
			if(mob.mind.ghostname)
				mob.name = mob.mind.ghostname
			else
				mob.name = mob.mind.name
		else
			mob.name = mob.real_name
		mob.mouse_opacity = initial(mob.mouse_opacity)

	REMOVE_TRAIT(mob, TRAIT_ORBITING_FORBIDDEN, STEALTH_MODE_TRAIT)

	log_admin("[key_name(usr)] has turned stealth mode OFF")
	message_admins("[key_name_admin(usr)] has turned stealth mode OFF")

#undef STEALTH_MODE_TRAIT

/client/proc/drop_bomb()
	set category = "Admin.Fun"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/list/choices = list("Small Bomb (1, 2, 3, 3)", "Medium Bomb (2, 3, 4, 4)", "Big Bomb (3, 5, 7, 5)", "Maxcap", "Custom Bomb")
	var/choice = tgui_input_list(src, "What size explosion would you like to produce? NOTE: You can do all this rapidly and in an IC manner (using cruise missiles!) with the Config/Launch Supplypod verb. WARNING: These ignore the maxcap", "Drop Bomb", choices)
	if(isnull(choice))
		return
	var/turf/epicenter = mob.loc

	switch(choice)
		if("Small Bomb (1, 2, 3, 3)")
			explosion(epicenter, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 3, adminlog = TRUE, ignorecap = TRUE, explosion_cause = mob)
		if("Medium Bomb (2, 3, 4, 4)")
			explosion(epicenter, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, flash_range = 4, adminlog = TRUE, ignorecap = TRUE, explosion_cause = mob)
		if("Big Bomb (3, 5, 7, 5)")
			explosion(epicenter, devastation_range = 3, heavy_impact_range = 5, light_impact_range = 7, flash_range = 5, adminlog = TRUE, ignorecap = TRUE, explosion_cause = mob)
		if("Maxcap")
			explosion(epicenter, devastation_range = GLOB.MAX_EX_DEVESTATION_RANGE, heavy_impact_range = GLOB.MAX_EX_HEAVY_RANGE, light_impact_range = GLOB.MAX_EX_LIGHT_RANGE, flash_range = GLOB.MAX_EX_FLASH_RANGE, adminlog = TRUE, ignorecap = TRUE, explosion_cause = mob)
		if("Custom Bomb")
			var/range_devastation = input("Devastation range (in tiles):") as null|num
			if(range_devastation == null)
				return
			var/range_heavy = input("Heavy impact range (in tiles):") as null|num
			if(range_heavy == null)
				return
			var/range_light = input("Light impact range (in tiles):") as null|num
			if(range_light == null)
				return
			var/range_flash = input("Flash range (in tiles):") as null|num
			if(range_flash == null)
				return
			if(range_devastation > GLOB.MAX_EX_DEVESTATION_RANGE || range_heavy > GLOB.MAX_EX_HEAVY_RANGE || range_light > GLOB.MAX_EX_LIGHT_RANGE || range_flash > GLOB.MAX_EX_FLASH_RANGE)
				if(tgui_alert(usr, "Bomb is bigger than the maxcap. Continue?",,list("Yes","No")) != "Yes")
					return
			epicenter = mob.loc //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range = range_devastation, heavy_impact_range = range_heavy, light_impact_range = range_light, flash_range = range_flash, adminlog = TRUE, ignorecap = TRUE, explosion_cause = mob)
	message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/drop_dynex_bomb()
	set category = "Admin.Fun"
	set name = "Drop DynEx Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/ex_power = input("Explosive Power:") as null|num
	var/turf/epicenter = mob.loc
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(usr)] creating an admin explosion at [epicenter.loc].")
		log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Dynamic Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dynex_range()
	set category = "Debug"
	set name = "Get DynEx Range"
	set desc = "Get the estimated range of a bomb, using explosive power."

	var/ex_power = input("Explosive Power:") as null|num
	if (isnull(ex_power))
		return
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Range: (Devastation: [round(range*0.25)], Heavy: [round(range*0.5)], Light: [round(range)])", confidential = TRUE)

/client/proc/get_dynex_power()
	set category = "Debug"
	set name = "Get DynEx Power"
	set desc = "Get the estimated required power of a bomb, to reach a specific range."

	var/ex_range = input("Light Explosion Range:") as null|num
	if (isnull(ex_range))
		return
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(usr, "Estimated Explosive Power: [power]", confidential = TRUE)

/client/proc/set_dynex_scale()
	set category = "Debug"
	set name = "Set DynEx Scale"
	set desc = "Set the scale multiplier of dynex explosions. The default is 0.5."

	var/ex_scale = input("New DynEx Scale:") as null|num
	if(!ex_scale)
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] has  modified Dynamic Explosion Scale: [ex_scale]")

/client/proc/atmos_control()
	set name = "Atmos Control Panel"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	SSair.ui_interact(mob)

/client/proc/reload_cards()
	set name = "Reload Cards"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	SStrading_card_game.reloadAllCardFiles()

/client/proc/validate_cards()
	set name = "Validate Cards"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	var/message = SStrading_card_game.checkCardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.checkCardDatums()
	if(message)
		message_admins(message)

/client/proc/test_cardpack_distribution()
	set name = "Test Cardpack Distribution"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	var/pack = input("Which pack should we test?", "You fucked it didn't you") as null|anything in sort_list(SStrading_card_game.card_packs)
	var/batchCount = input("How many times should we open it?", "Don't worry, I understand") as null|num
	var/batchSize = input("How many cards per batch?", "I hope you remember to check the validation") as null|num
	var/guar = input("Should we use the pack's guaranteed rarity? If so, how many?", "We've all been there. Man you should have seen the old system") as null|num
	SStrading_card_game.checkCardDistribution(pack, batchSize, batchCount, guar)

/client/proc/print_cards()
	set name = "Print Cards"
	set category = "Debug"
	SStrading_card_game.printAllCards()

/client/proc/give_spell(mob/spell_recipient in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	var/list/spell_list = list()
	var/type_length = length_char("/obj/effect/proc_holder/spell") + 2
	for(var/spell in GLOB.spells)
		spell_list[copytext_char("[spell]", type_length)] = spell
	var/spell_desc = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in sort_list(spell_list)
	if(!spell_desc)
		return

	var/robeless = (tgui_alert(usr, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(spell_recipient)] the spell [spell_desc][robeless ? " (Forced robeless)" : ""].")
	message_admins(span_adminnotice("[key_name_admin(usr)] gave [key_name_admin(spell_recipient)] the spell [spell_desc][spell_desc][robeless ? " (Forced robeless)" : ""]."))

	var/spell_path = spell_list[spell_desc]
	var/obj/effect/proc_holder/spell/new_spell = new spell_path()

	if(robeless)
		new_spell.clothes_req = FALSE

	if(spell_recipient.mind)
		spell_recipient.mind.AddSpell(new_spell)
	else
		spell_recipient.AddSpell(new_spell)
		message_admins(span_danger("Spells given to mindless mobs will not be transferred in mindswap or cloning!"))

/client/proc/remove_spell(mob/removal_target in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Remove Spell"
	set desc = "Remove a spell from the selected mob."

	var/target_spell_list = length(removal_target?.mind?.spell_list) ? removal_target.mind.spell_list : removal_target.mob_spell_list

	if(!length(target_spell_list))
		return

	var/obj/effect/proc_holder/spell/removed_spell = input("Choose the spell to remove", "NO ABRAKADABRA") as null|anything in sort_list(target_spell_list)
	if(removed_spell)
		removal_target.mind.RemoveSpell(removed_spell)
		log_admin("[key_name(usr)] removed the spell [removed_spell] from [key_name(removal_target)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] removed the spell [removed_spell] from [key_name_admin(removal_target)]."))
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_disease(mob/living/T in GLOB.mob_living_list)
	set category = "Admin.Fun"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	if(!istype(T))
		to_chat(src, span_notice("You can only give a disease to a mob of type /mob/living."), confidential = TRUE)
		return
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in sort_list(SSdisease.diseases, /proc/cmp_typepaths_asc)
	if(!D)
		return
	T.ForceContractDisease(new D, FALSE, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins(span_adminnotice("[key_name_admin(usr)] gave [key_name_admin(T)] the disease [D]."))

/client/proc/object_say(obj/O in world)
	set category = "Admin.Events"
	set name = "OSay"
	set desc = "Makes an object say something."
	var/message = tgui_input_text(usr, "What do you want the message to be?", "Make Sound", encode = FALSE)
	if(!message)
		return
	O.say(message, sanitize = FALSE)
	log_admin("[key_name(usr)] made [O] at [AREACOORD(O)] say \"[message]\"")
	message_admins(span_adminnotice("[key_name_admin(usr)] made [O] at [AREACOORD(O)]. say \"[message]\""))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Object Say") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Admin.Events"
	if (!(holder.rank_flags() & R_BUILD))
		return
	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin.Game"
	if(holder)
		src.holder.output_ai_laws()

/client/proc/deadmin()
	set name = "Deadmin"
	set category = "Admin"
	set desc = "Shed your admin powers."

	if(!holder)
		return

	holder.deactivate()

	to_chat(src, span_interface("You are now a normal player."))
	log_admin("[src] deadminned themselves.")
	message_admins("[src] deadminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Deadmin")

/client/proc/readmin()
	set name = "Readmin"
	set category = "Admin"
	set desc = "Regain your admin powers."

	var/datum/admins/A = GLOB.deadmins[ckey]

	if(!A)
		A = GLOB.admin_datums[ckey]
		if (!A)
			var/msg = " is trying to readmin but they have no deadmin entry"
			message_admins("[key_name_admin(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	A.associate(src)

	if (!holder)
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, span_interface("You are now an admin."), confidential = TRUE)
	message_admins("[src] re-adminned themselves.")
	log_admin("[src] re-adminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Readmin")

/client/proc/populate_world(amount = 50 as num)
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

					if (length(candidates))
						k = 100

						do
							tile = pick(candidates)
						while ((!tile || !istype(tile)) && --k > 0)

						if (tile)
							var/mob/living/carbon/human/hooman = new(tile)
							hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
							testing("Spawned test mob at [COORD(tile)]")
			while (!area && --j > 0)

/client/proc/toggle_AI_interact()
	set name = "Toggle Admin AI Interact"
	set category = "Admin.Game"
	set desc = "Allows you to interact with most machines as an AI would as a ghost"

	AI_Interact = !AI_Interact
	if(mob && isAdminGhostAI(mob))
		mob.has_unlimited_silicon_privilege = AI_Interact

	log_admin("[key_name(usr)] has [AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] has [AI_Interact ? "activated" : "deactivated"] their AI interaction")

/client/proc/debugstatpanel()
	set name = "Debug Stat Panel"
	set category = "Debug"

	src.stat_panel.send_message("create_debug")

/client/proc/admin_2fa_verify()
	set name = "Verify Admin"
	set category = "Admin"

	var/datum/admins/admin = GLOB.admin_datums[ckey]
	admin?.associate(src)

/client/proc/display_sendmaps()
	set name = "Send Maps Profile"
	set category = "Debug"

	src << link("?debug=profile&type=sendmaps&window=test")

/**
 * Debug verb that spawns human crewmembers
 * of each job type, gives them a mind and assigns the role,
 * and injects them into the manifest, as if they were a "player".
 *
 * This spawns humans with minds and jobs, but does NOT make them 'players'.
 * They're all clientles mobs with minds / jobs.
 */
/client/proc/spawn_debug_full_crew()
	set name = "Spawn Debug Full Crew"
	set desc = "Creates a full crew for the station, filling the datacore and assigning them all minds / jobs. Don't do this on live"
	set category = "Debug"

	if(!check_rights(R_DEBUG))
		return

	var/mob/admin = usr

	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(admin, "You should only be using this after a round has setup and started.")
		return

	// Two input checks here to make sure people are certain when they're using this.
	if(tgui_alert(admin, "This command will create a bunch of dummy crewmembers with minds, job, and datacore entries, which will take a while and fill the manifest.", "Spawn Crew", list("Yes", "Cancel")) != "Yes")
		return

	if(tgui_alert(admin, "I sure hope you aren't doing this on live. Are you sure?", "Spawn Crew (Be certain)", list("Yes", "Cancel")) != "Yes")
		return

	// Find the observer spawn, so we have a place to dump the dummies.
	var/obj/effect/landmark/observer_start/observer_point = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	var/turf/destination = get_turf(observer_point)
	if(!destination)
		to_chat(admin, "Failed to find the observer spawn to send the dummies.")
		return

	// Okay, now go through all nameable occupations.
	// Pick out all jobs that have JOB_CREW_MEMBER set.
	// Then, spawn a human and slap a person into it.
	var/number_made = 0
	for(var/rank in SSjob.name_occupations)
		var/datum/job/job = SSjob.GetJob(rank)

		// JOB_CREW_MEMBER is all jobs that pretty much aren't silicon
		if(!(job.job_flags & JOB_CREW_MEMBER))
			continue

		// Create our new_player for this job and set up its mind.
		var/mob/dead/new_player/new_guy = new()
		new_guy.mind_initialize()
		new_guy.mind.name = "[rank] Dummy"

		// Assign the rank to the new player dummy.
		if(!SSjob.AssignRole(new_guy, job))
			qdel(new_guy)
			to_chat(admin, "[rank] wasn't able to be spawned.")
			continue

		// It's got a job, spawn in a human and shove it in the human.
		var/mob/living/carbon/human/character = new(destination)
		character.name = new_guy.mind.name
		new_guy.mind.transfer_to(character)
		qdel(new_guy)

		// Then equip up the human with job gear.
		SSjob.EquipRank(character, job)
		job.after_latejoin_spawn(character)

		// Finally, ensure the minds are tracked and in the manifest.
		SSticker.minds += character.mind
		if(ishuman(character))
			GLOB.data_core.manifest_inject(character)

		number_made++
		CHECK_TICK

	to_chat(admin, "[number_made] crewmembers have been created.")
