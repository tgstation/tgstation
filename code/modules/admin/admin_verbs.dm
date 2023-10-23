//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
//the procs are cause you can't put the comments in the GLOB var define
GLOBAL_LIST_INIT(admin_verbs_default, world.AVerbsDefault())
GLOBAL_PROTECT(admin_verbs_default)
/world/proc/AVerbsDefault()
	return list(
	/client/proc/cmd_admin_pm_context, /*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel, /*admin-pm list*/
	/client/proc/cmd_admin_say, /*admin-only ooc chat*/
	/client/proc/deadmin, /*destroys our own admin datum so we can play as a regular player*/
	/client/proc/debugstatpanel,
	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/dsay, /*talk in deadchat using our ckey/fakekey*/
	/client/proc/fix_air, /*resets air in designated radius to its default atmos composition*/
	/client/proc/hide_verbs, /*hides all our adminverbs*/
	/client/proc/investigate_show, /*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/mark_datum_mapview,
	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
	/client/proc/reload_admins,
	/client/proc/requests,
	/client/proc/secrets,
	/client/proc/stop_sounds,
	/client/proc/tag_datum_mapview,
	)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVerbsAdmin())
GLOBAL_PROTECT(admin_verbs_admin)
/world/proc/AVerbsAdmin()
	return list(
// Admin datums
	/datum/admins/proc/access_news_network, /*allows access of newscasters*/
	/datum/admins/proc/announce, /*priority announce something to all clients.*/
	/datum/admins/proc/display_tags,
	/datum/admins/proc/fishing_calculator,
	/datum/admins/proc/known_alts_panel,
	/datum/admins/proc/show_lag_switch_panel,
	/datum/admins/proc/open_borgopanel,
	/datum/admins/proc/open_shuttlepanel, /* Opens shuttle manipulator UI */
	/datum/admins/proc/paintings_manager,
	/datum/admins/proc/set_admin_notice, /*announcement all clients see when joining the server.*/
	/datum/admins/proc/show_player_panel, /*shows an interface for individual players, with various links (links require additional flags*/
	/datum/admins/proc/toggleenter, /*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests, /*toggles whether guests can join the current game*/
	/datum/admins/proc/toggleooc, /*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead, /*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/trophy_manager,
	/datum/admins/proc/view_all_circuits,
	/datum/verbs/menu/Admin/verb/playerpanel, /* It isn't /datum/admin but it fits no less */
	/datum/admins/proc/change_shuttle_events, //allows us to change the shuttle events
	/datum/admins/proc/reset_tram, //tram related admin actions
// Client procs
	/client/proc/admin_call_shuttle, /*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle, /*allows us to cancel the emergency shuttle, sending it back to centcom*/
	/client/proc/admin_disable_shuttle, /*allows us to disable the emergency shuttle admin-wise so that it cannot be called*/
	/client/proc/admin_enable_shuttle,  /*undoes the above*/
	/client/proc/admin_ghost, /*allows us to ghost/reenter body at will*/
	/client/proc/admin_hostile_environment, /*Allows admins to prevent the emergency shuttle from leaving, also lets admins clear hostile environments if theres one stuck*/
	/client/proc/centcom_podlauncher,/*Open a window to launch a Supplypod and configure it or it's contents*/
	/client/proc/check_ai_laws, /*shows AI and borg laws*/
	/client/proc/check_antagonists, /*shows all antags*/
	/client/proc/cmd_admin_check_contents, /*displays the contents of an instance*/
	/client/proc/cmd_admin_check_player_exp, /* shows players by playtime */
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/cmd_admin_delete, /*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_direct_narrate, /*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_headset_message, /*send a message to somebody through their headset as CentCom*/
	/client/proc/cmd_admin_local_narrate, /*sends text to all mobs within view of atom*/
	/client/proc/cmd_admin_subtle_message, /*send a message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_world_narrate, /*sends text to all players with no padding*/
	/client/proc/cmd_change_command_name,
	/client/proc/create_mob_worm,
	/client/proc/fax_panel, /*send a paper to fax*/
	/client/proc/force_load_lazy_template,
	/client/proc/game_panel, /*game panel, allows to change game-mode etc*/
	/client/proc/Getmob, /*teleports a mob to our location*/
	/client/proc/Getkey, /*teleports a mob with a certain ckey to our location*/
	/client/proc/getserverlogs, /*for accessing server logs*/
	/client/proc/getcurrentlogs, /*for accessing server logs for the current round*/
	/client/proc/ghost_pool_protection, /*opens a menu for toggling ghost roles*/
	/client/proc/invisimin, /*allows our mob to go invisible/visible*/
	/client/proc/jumptoarea,
	/client/proc/jumptokey, /*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob, /*allows us to jump to a specific mob*/
	/client/proc/jumptoturf, /*allows us to jump to a specific turf*/
	/client/proc/jumptocoord, /*we ghost and jump to a coordinate*/
	/client/proc/list_bombers,
	/client/proc/list_dna,
	/client/proc/list_fingerprints,
	/client/proc/list_law_changes,
	/client/proc/list_signalers,
	/client/proc/manage_sect, /*manage chaplain religious sect*/
	/client/proc/message_pda, /*send a message to somebody on PDA*/
	/client/proc/respawn_character,
	/client/proc/show_manifest,
	/client/proc/toggle_AI_interact, /*toggle admin ability to interact with machines as an AI*/
	/client/proc/toggle_combo_hud, /* toggle display of the combination pizza antag and taco sci/med/eng hud */
	/client/proc/toggle_view_range, /*changes how far we can see*/
	/client/proc/cmd_admin_law_panel,
	/client/proc/log_viewer_new,
	/client/proc/player_ticket_history,
	)
GLOBAL_LIST_INIT(admin_verbs_ban, list(/client/proc/unban_panel, /client/proc/ban_panel, /client/proc/stickybanpanel, /client/proc/library_control))
GLOBAL_PROTECT(admin_verbs_ban)
GLOBAL_LIST_INIT(admin_verbs_sounds, list(/client/proc/play_local_sound, /client/proc/play_direct_mob_sound, /client/proc/play_sound, /client/proc/set_round_end_sound))
GLOBAL_PROTECT(admin_verbs_sounds)
GLOBAL_LIST_INIT(admin_verbs_fun, list(
// Admin datums
	/datum/admins/proc/station_traits_panel,
// Client procs
	/client/proc/admin_away,
	/client/proc/add_marked_mob_ability,
	/client/proc/admin_change_sec_level,
	/client/proc/cinematic,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_gib_self,
	/client/proc/cmd_select_equipment,
	/client/proc/command_report_footnote,
	/client/proc/delay_command_report,
	/client/proc/drop_bomb,
	/client/proc/drop_dynex_bomb,
	/client/proc/forceEvent,
	/client/proc/mass_zombie_cure,
	/client/proc/mass_zombie_infection,
	/client/proc/object_say,
	/client/proc/polymorph_all,
	/client/proc/remove_marked_mob_ability,
	/client/proc/reset_ooc,
	/client/proc/run_weather,
	/client/proc/set_dynex_scale,
	/client/proc/set_ooc,
	/client/proc/show_tip,
	/client/proc/smite,
	/client/proc/summon_ert,
	/client/proc/toggle_nuke,
	/client/proc/toggle_random_events,
	))
GLOBAL_PROTECT(admin_verbs_fun)
GLOBAL_LIST_INIT(admin_verbs_spawn, list(/datum/admins/proc/spawn_atom, /datum/admins/proc/podspawn_atom, /datum/admins/proc/spawn_cargo, /datum/admins/proc/spawn_objasmob, /client/proc/respawn_character, /datum/admins/proc/beaker_panel))
GLOBAL_PROTECT(admin_verbs_spawn)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVerbsServer())
GLOBAL_PROTECT(admin_verbs_server)
/world/proc/AVerbsServer()
	return list(
// Admin datums
	/datum/admins/proc/delay,
	/datum/admins/proc/delay_round_end,
	/datum/admins/proc/end_round,
	/datum/admins/proc/restart,
	/datum/admins/proc/startnow,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/toggleAI,
// Client procs
	/client/proc/adminchangemap,
	/client/proc/cmd_admin_delete, /*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_force_del_all,
	/client/proc/cmd_debug_hard_del_all,
	/client/proc/everyone_random,
	/client/proc/forcerandomrotate,
	/client/proc/generate_job_config,
	/client/proc/panicbunker,
	/client/proc/toggle_cdn,
	/client/proc/toggle_hub,
	/client/proc/toggle_interviews,
	/client/proc/toggle_random_events,
	)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVerbsDebug())
GLOBAL_PROTECT(admin_verbs_debug)
/world/proc/AVerbsDebug()
	return list(
	#ifdef TESTING /* Keep these at the top to not make the list look fugly */
	/client/proc/check_missing_sprites,
	/client/proc/run_dynamic_simulations,
	#endif
	/proc/machine_upgrade,
	/datum/admins/proc/create_or_modify_area,
	/client/proc/adventure_manager,
	/client/proc/atmos_control,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/check_bomb_impacts,
	/client/proc/check_timer_sources,
	/client/proc/clear_dynamic_transit,
	/client/proc/cmd_admin_debug_traitor_objectives,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/cmd_admin_toggle_fov,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_force_del_all,
	/client/proc/cmd_debug_hard_del_all,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_display_del_log,
	/client/proc/cmd_display_init_log,
	/client/proc/cmd_display_overlay_log,
	/client/proc/Debug2,
	/client/proc/debug_controller,
	/client/proc/debug_hallucination_weighted_list_per_type,
	/client/proc/debug_huds,
	/client/proc/debugNatureMapGenerator,
	/client/proc/debug_plane_masters,
	/client/proc/debug_spell_requirements,
	/client/proc/display_sendmaps,
	/client/proc/enable_mapping_verbs,
	/client/proc/generate_wikichem_list,
	/client/proc/get_dynex_power, /*debug verbs for dynex explosions.*/
	/client/proc/get_dynex_range, /*debug verbs for dynex explosions.*/
	/client/proc/jump_to_ruin,
	/client/proc/load_circuit,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/modify_goals,
	/client/proc/open_colorblind_test,
	/client/proc/open_lua_editor,
	/client/proc/outfit_manager,
	/client/proc/populate_world,
	/client/proc/pump_random_event,
	/client/proc/print_cards,
	/client/proc/reestablish_tts_connection,
	/client/proc/reload_cards,
	/client/proc/reload_configuration,
	/client/proc/restart_controller,
	/client/proc/run_empty_query,
	/client/proc/SDQL2_query,
	/client/proc/set_dynex_scale,
	/client/proc/spawn_debug_full_crew,
	/client/proc/test_cardpack_distribution,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/client/proc/toggle_cdn,
	/client/proc/toggle_medal_disable,
	/client/proc/unload_ctf,
	/client/proc/validate_cards,
	/client/proc/validate_puzzgrids,
	/client/proc/GeneratePipeSpritesheet,
	/client/proc/view_runtimes,
	)
GLOBAL_LIST_INIT(admin_verbs_possess, list(/proc/possess, /proc/release))
GLOBAL_PROTECT(admin_verbs_possess)
GLOBAL_LIST_INIT(admin_verbs_permissions, list(/client/proc/edit_admin_permissions))
GLOBAL_PROTECT(admin_verbs_permissions)
GLOBAL_LIST_INIT(admin_verbs_poll, list(/client/proc/poll_panel))
GLOBAL_PROTECT(admin_verbs_poll)

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
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide All Adminverbs") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!




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
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Reenter") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>", confidential = TRUE)
		return FALSE
	else
		//ghostize
		log_admin("[key_name(usr)] admin ghosted.")
		message_admins("[key_name_admin(usr)] admin ghosted.")
		var/mob/body = mob
		body.ghostize(TRUE)
		init_verbs()
		if(body && !body.key)
			body.key = "@[key]" //Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Ghost") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin.Game"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(isnull(holder) || isnull(mob))
		return
	if(mob.invisimin)
		mob.invisimin = FALSE
		mob.RemoveInvisibility(INVISIBILITY_SOURCE_INVISIMIN)
		to_chat(mob, span_boldannounce("Invisimin off. Invisibility reset."), confidential = TRUE)
	else
		mob.invisimin = TRUE
		mob.SetInvisibility(INVISIBILITY_OBSERVER, INVISIBILITY_SOURCE_INVISIMIN, INVISIBILITY_PRIORITY_ADMIN)
		to_chat(mob, span_adminnotice("<b>Invisimin on. You are now as invisible as a ghost.</b>"), confidential = TRUE)

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin.Game"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.") //for tsar~
		if(!isobserver(usr) && SSticker.HasRoundStarted())
			message_admins("[key_name_admin(usr)] checked antagonists.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antagonists") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/list_bombers()
	set name = "List Bombers"
	set category = "Admin.Game"
	if(!holder)
		return
	holder.list_bombers()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Bombers") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/list_signalers()
	set name = "List Signalers"
	set category = "Admin.Game"
	if(!holder)
		return
	holder.list_signalers()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Signalers") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/list_law_changes()
	set name = "List Law Changes"
	set category = "Debug"
	if(!holder)
		return
	holder.list_law_changes()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Law Changes") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/show_manifest()
	set name = "Show Manifest"
	set category = "Debug"
	if(!holder)
		return
	holder.show_manifest()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Manifest") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/list_dna()
	set name = "List DNA"
	set category = "Debug"
	if(!holder)
		return
	holder.list_dna()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List DNA") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/list_fingerprints()
	set name = "List Fingerprints"
	set category = "Debug"
	if(!holder)
		return
	holder.list_fingerprints()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "List Fingerprints") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/ban_panel()
	set name = "Banning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Banning Panel") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/unban_panel()
	set name = "Unbanning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.unban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unbanning Panel") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin.Game"
	if(holder)
		holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/poll_panel()
	set name = "Server Poll Management"
	set category = "Admin"
	if(!check_rights(R_POLL))
		return
	holder.poll_list_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Server Poll Management") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/// Returns this client's stealthed ckey
/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/// Takes a stealthed ckey as input, returns the true key it represents
/proc/findTrueKey(stealth_key)
	if(!stealth_key)
		return
	for(var/potentialKey in GLOB.stealthminID)
		if(GLOB.stealthminID[potentialKey] == stealth_key)
			return potentialKey

/// Hands back a stealth ckey to use, guarenteed to be unique
/proc/generateStealthCkey()
	var/guess = rand(0, 1000)
	var/text_guess
	var/valid_found = FALSE
	while(valid_found == FALSE)
		valid_found = TRUE
		text_guess = "@[num2text(guess)]"
		// We take a guess at some number, and if it's not in the existing stealthmin list we exit
		for(var/key in GLOB.stealthminID)
			// If it is in the list tho, we up one number, and redo the loop
			if(GLOB.stealthminID[key] == text_guess)
				guess += 1
				valid_found = FALSE
				break

	return text_guess

/client/proc/createStealthKey()
	GLOB.stealthminID["[ckey]"] = generateStealthCkey()

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!holder)
		return

	if(holder.fakekey)
		disable_stealth_mode()
	else
		enable_stealth_mode()

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

#define STEALTH_MODE_TRAIT "stealth_mode"

/client/proc/enable_stealth_mode()
	var/new_key = ckeyEx(stripped_input(usr, "Enter your desired display name.", "Fake Key", key, 26))
	if(!new_key)
		return
	holder.fakekey = new_key
	createStealthKey()
	if(isobserver(mob))
		mob.SetInvisibility(INVISIBILITY_ABSTRACT, INVISIBILITY_SOURCE_STEALTHMODE, INVISIBILITY_PRIORITY_ADMIN)
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
		mob.RemoveInvisibility(INVISIBILITY_SOURCE_STEALTHMODE)
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
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

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
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Dynamic Bomb") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

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
	var/message = SStrading_card_game.check_cardpacks(SStrading_card_game.card_packs)
	message += SStrading_card_game.check_card_datums()
	if(message)
		message_admins(message)
	else
		message_admins("No errors found in card rarities or overrides.")

/client/proc/test_cardpack_distribution()
	set name = "Test Cardpack Distribution"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	if(!SStrading_card_game.loaded)
		message_admins("The card subsystem is not currently loaded")
		return
	var/pack = tgui_input_list(usr, "Which pack should we test?", "You fucked it didn't you", sort_list(SStrading_card_game.card_packs))
	if(!pack)
		return
	var/batch_count = tgui_input_number(usr, "How many times should we open it?", "Don't worry, I understand")
	var/batch_size = tgui_input_number(usr, "How many cards per batch?", "I hope you remember to check the validation")
	var/guar = tgui_input_number(usr, "Should we use the pack's guaranteed rarity? If so, how many?", "We've all been there. Man you should have seen the old system")

	SStrading_card_game.check_card_distribution(pack, batch_size, batch_count, guar)

/client/proc/print_cards()
	set name = "Print Cards"
	set category = "Debug"
	SStrading_card_game.printAllCards()

/client/proc/give_mob_action(mob/ability_recipient in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Give Mob Action"
	set desc = "Gives a mob ability to a mob."

	var/static/list/all_mob_actions = sort_list(subtypesof(/datum/action/cooldown/mob_cooldown), GLOBAL_PROC_REF(cmp_typepaths_asc))
	var/static/list/actions_by_name = list()
	if (!length(actions_by_name))
		for (var/datum/action/cooldown/mob_cooldown as anything in all_mob_actions)
			actions_by_name["[initial(mob_cooldown.name)] ([mob_cooldown])"] = mob_cooldown

	var/ability = tgui_input_list(usr, "Choose an ability", "Ability", actions_by_name)
	if(isnull(ability))
		return

	var/ability_type = actions_by_name[ability]
	var/datum/action/cooldown/mob_cooldown/add_ability

	var/make_sequence = tgui_alert(usr, "Would you like this action to be a sequence of multiple abilities?", "Sequence Ability", list("Yes", "No"))
	if(make_sequence == "Yes")
		add_ability = new /datum/action/cooldown/mob_cooldown(ability_recipient)
		add_ability.sequence_actions = list()
		while(!isnull(ability_type))
			var/ability_delay = tgui_input_number(usr, "Enter the delay in seconds before the next ability in the sequence is used", "Ability Delay", 2)
			if(isnull(ability_delay) || ability_delay < 0)
				ability_delay = 0
			add_ability.sequence_actions[ability_type] = ability_delay * 1 SECONDS
			ability = tgui_input_list(usr, "Choose a new sequence ability", "Sequence Ability", actions_by_name)
			ability_type = actions_by_name[ability]
		var/ability_cooldown = tgui_input_number(usr, "Enter the sequence abilities cooldown in seconds", "Ability Cooldown", 2)
		if(isnull(ability_cooldown) || ability_cooldown < 0)
			ability_cooldown = 2
		add_ability.cooldown_time = ability_cooldown * 1 SECONDS
		var/ability_melee_cooldown = tgui_input_number(usr, "Enter the abilities melee cooldown in seconds", "Melee Cooldown", 2)
		if(isnull(ability_melee_cooldown) || ability_melee_cooldown < 0)
			ability_melee_cooldown = 2
		add_ability.melee_cooldown_time = ability_melee_cooldown * 1 SECONDS
		add_ability.name = tgui_input_text(usr, "Choose ability name", "Ability name", "Generic Ability")
		add_ability.create_sequence_actions()
	else
		add_ability = new ability_type(ability_recipient)

	if(isnull(ability_recipient))
		return
	add_ability.Grant(ability_recipient)

	message_admins("[key_name_admin(usr)] added mob ability [ability_type] to mob [ability_recipient].")
	log_admin("[key_name(usr)] added mob ability [ability_type] to mob [ability_recipient].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Mob Ability") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/remove_mob_action(mob/removal_target in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Remove Mob Action"
	set desc = "Remove a special ability from the selected mob."

	var/list/target_abilities = list()
	for(var/datum/action/cooldown/mob_cooldown/ability in removal_target.actions)
		target_abilities[ability.name] = ability

	if(!length(target_abilities))
		return

	var/chosen_ability = tgui_input_list(usr, "Choose the spell to remove from [removal_target]", "Depower", sort_list(target_abilities))
	if(isnull(chosen_ability))
		return
	var/datum/action/cooldown/mob_cooldown/to_remove = target_abilities[chosen_ability]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(usr)] removed the ability [chosen_ability] from [key_name(removal_target)].")
	message_admins("[key_name_admin(usr)] removed the ability [chosen_ability] from [key_name_admin(removal_target)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Mob Ability") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/give_spell(mob/spell_recipient in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	var/which = tgui_alert(usr, "Chose by name or by type path?", "Chose option", list("Name", "Typepath"))
	if(!which)
		return
	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	var/list/spell_list = list()
	for(var/datum/action/cooldown/spell/to_add as anything in subtypesof(/datum/action/cooldown/spell))
		var/spell_name = initial(to_add.name)
		if(spell_name == "Spell") // abstract or un-named spells should be skipped.
			continue

		if(which == "Name")
			spell_list[spell_name] = to_add
		else
			spell_list += to_add

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to give to [spell_recipient]", "ABRAKADABRA", sort_list(spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/spell_path = which == "Typepath" ? chosen_spell : spell_list[chosen_spell]
	if(!ispath(spell_path))
		return

	var/robeless = (tgui_alert(usr, "Would you like to force this spell to be robeless?", "Robeless Casting?", list("Force Robeless", "Use Spell Setting")) == "Force Robeless")

	if(QDELETED(spell_recipient))
		to_chat(usr, span_warning("The intended spell recipient no longer exists."))
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")
	message_admins("[key_name_admin(usr)] gave [key_name_admin(spell_recipient)] the spell [chosen_spell][robeless ? " (Forced robeless)" : ""].")

	var/datum/action/cooldown/spell/new_spell = new spell_path(spell_recipient.mind || spell_recipient)

	if(robeless)
		new_spell.spell_requirements &= ~SPELL_REQUIRES_WIZARD_GARB

	new_spell.Grant(spell_recipient)

	if(!spell_recipient.mind)
		to_chat(usr, span_userdanger("Spells given to mindless mobs will belong to the mob and not their mind, \
			and as such will not be transferred if their mind changes body (Such as from Mindswap)."))

/client/proc/remove_spell(mob/removal_target in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Remove Spell"
	set desc = "Remove a spell from the selected mob."

	var/list/target_spell_list = list()
	for(var/datum/action/cooldown/spell/spell in removal_target.actions)
		target_spell_list[spell.name] = spell

	if(!length(target_spell_list))
		return

	var/chosen_spell = tgui_input_list(usr, "Choose the spell to remove from [removal_target]", "ABRAKADABRA", sort_list(target_spell_list))
	if(isnull(chosen_spell))
		return
	var/datum/action/cooldown/spell/to_remove = target_spell_list[chosen_spell]
	if(!istype(to_remove))
		return

	qdel(to_remove)
	log_admin("[key_name(usr)] removed the spell [chosen_spell] from [key_name(removal_target)].")
	message_admins("[key_name_admin(usr)] removed the spell [chosen_spell] from [key_name_admin(removal_target)].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Spell") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/give_disease(mob/living/T in GLOB.mob_living_list)
	set category = "Admin.Fun"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	if(!istype(T))
		to_chat(src, span_notice("You can only give a disease to a mob of type /mob/living."), confidential = TRUE)
		return
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in sort_list(SSdisease.diseases, GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!D)
		return
	T.ForceContractDisease(new D, FALSE, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
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
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Object Say") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Admin.Events"
	if (!(holder.rank_flags() & R_BUILD))
		return
	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin.Game"
	if(holder)
		src.holder.output_ai_laws()

/client/proc/manage_sect()
	set name = "Manage Religious Sect"
	set category = "Admin.Game"

	if (!isnull(GLOB.religious_sect))
		var/you_sure = tgui_alert(
			usr,
			"The Chaplain has already chosen [GLOB.religious_sect.name], override their selection?",
			"Replace God?",
			list("Yes", "Cancel"),
		)
		if (you_sure != "Yes")
			return

	var/static/list/choices = list()
	if (!length(choices))
		choices["nothing"] = null
		for(var/datum/religion_sect/sect as anything in subtypesof(/datum/religion_sect))
			choices[initial(sect.name)] = sect
	var/choice = tgui_input_list(usr, "Set new Chaplain sect", "God Picker", choices)
	if(isnull(choice))
		return
	if(choice == "nothing")
		reset_religious_sect()
		return
	set_new_religious_sect(choices[choice], reset_existing = TRUE)

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

/client/proc/populate_world(amount = 50)
	set name = "Populate World"
	set category = "Debug"
	set desc = "(\"Amount of mobs to create\") Populate the world with test mobs."

	for (var/i in 1 to amount)
		var/turf/tile = get_safe_random_station_turf()
		var/mob/living/carbon/human/hooman = new(tile)
		hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
		testing("Spawned test mob at [get_area_name(tile, TRUE)] ([tile.x],[tile.y],[tile.z])")

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
		if(!SSjob.AssignRole(new_guy, job, do_eligibility_checks = FALSE))
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
			GLOB.manifest.inject(character)

		number_made++
		CHECK_TICK

	to_chat(admin, "[number_made] crewmembers have been created.")

/// Debug verb for seeing at a glance what all spells have as set requirements
/client/proc/debug_spell_requirements()
	set name = "Show Spell Requirements"
	set category = "Debug"

	var/header = "<tr><th>Name</th> <th>Requirements</th>"
	var/all_requirements = list()
	for(var/datum/action/cooldown/spell/spell as anything in typesof(/datum/action/cooldown/spell))
		if(initial(spell.name) == "Spell")
			continue

		var/list/real_reqs = list()
		var/reqs = initial(spell.spell_requirements)
		if(reqs & SPELL_CASTABLE_AS_BRAIN)
			real_reqs += "Castable as brain"
		if(reqs & SPELL_REQUIRES_HUMAN)
			real_reqs += "Must be human"
		if(reqs & SPELL_REQUIRES_MIME_VOW)
			real_reqs += "Must be miming"
		if(reqs & SPELL_REQUIRES_MIND)
			real_reqs += "Must have a mind"
		if(reqs & SPELL_REQUIRES_NO_ANTIMAGIC)
			real_reqs += "Must have no antimagic"
		if(reqs & SPELL_REQUIRES_STATION)
			real_reqs += "Must be on the station z-level"
		if(reqs & SPELL_REQUIRES_WIZARD_GARB)
			real_reqs += "Must have wizard clothes"

		all_requirements += "<tr><td>[initial(spell.name)]</td> <td>[english_list(real_reqs, "No requirements")]</td></tr>"

	var/page_style = "<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>"
	var/page_contents = "[page_style]<table style=\"width:100%\">[header][jointext(all_requirements, "")]</table>"
	var/datum/browser/popup = new(mob, "spellreqs", "Spell Requirements", 600, 400)
	popup.set_content(page_contents)
	popup.open()

/client/proc/force_load_lazy_template()
	set name = "Load/Jump Lazy Template"
	set category = "Admin.Events"
	if(!check_rights(R_ADMIN))
		return

	var/list/choices = LAZY_TEMPLATE_KEY_LIST_ALL()
	var/choice = tgui_input_list(usr, "Key?", "Lazy Loader", choices)
	if(!choice)
		return

	choice = choices[choice]
	if(!choice)
		to_chat(usr, span_warning("No template with that key found, report this!"))
		return

	var/already_loaded = LAZYACCESS(SSmapping.loaded_lazy_templates, choice)
	var/force_load = FALSE
	if(already_loaded && (tgui_alert(usr, "Template already loaded.", "", list("Jump", "Load Again")) == "Load Again"))
		force_load = TRUE

	var/datum/turf_reservation/reservation = SSmapping.lazy_load_template(choice, force = force_load)
	if(!reservation)
		to_chat(usr, span_boldwarning("Failed to load template!"))
		return

	if(!isobserver(usr))
		admin_ghost()
	usr.forceMove(reservation.bottom_left_turfs[1])

	message_admins("[key_name_admin(usr)] has loaded lazy template '[choice]'")
	to_chat(usr, span_boldnicegreen("Template loaded, you have been moved to the bottom left of the reservation."))

/client/proc/library_control()
	set name = "Library Management"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return

	if(!holder.library_manager)
		holder.library_manager = new()
	holder.library_manager.ui_interact(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Library Management") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

/client/proc/create_mob_worm()
	set category = "Admin.Fun"
	set name = "Create Mob Worm"
	set desc = "Attached a linked list of mobs to a marked mob"
	if (!check_rights(R_FUN))
		return
	if(isnull(holder))
		return
	if(!isliving(holder.marked_datum))
		to_chat(usr, span_warning("Error: Please mark a mob to attach mobs to."))
		return
	var/mob/living/head = holder.marked_datum

	var/attempted_target_path = tgui_input_text(
		usr,
		"Enter typepath of a mob you'd like to make your chain from.",
		"Typepath",
		"[/mob/living/basic/pet/dog/corgi/ian]",
	)

	if (isnull(attempted_target_path))
		return //The user pressed "Cancel"

	var/desired_mob = text2path(attempted_target_path)
	if(!ispath(desired_mob))
		var/static/list/mob_paths = make_types_fancy(subtypesof(/mob/living))
		desired_mob = pick_closest_path(attempted_target_path, mob_paths)
	if(isnull(desired_mob) || !ispath(desired_mob) || QDELETED(head))
		return //The user pressed "Cancel"

	var/amount = tgui_input_number(usr, "How long should our tail be?", "Worm Configurator", default = 3, min_value = 1)
	if (isnull(amount) || amount < 1 || QDELETED(head))
		return
	head.AddComponent(/datum/component/mob_chain)
	var/mob/living/previous = head
	for (var/i in 1 to amount)
		var/mob/living/segment = new desired_mob(head.drop_location())
		if (QDELETED(segment)) // ffs mobs which replace themselves with other mobs
			i--
			continue
		ADD_TRAIT(segment, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)
		QDEL_NULL(segment.ai_controller)
		segment.AddComponent(/datum/component/mob_chain, front = previous)
		previous = segment
