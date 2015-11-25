//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
var/list/admin_verbs_default = list(
	/datum/admins/proc/show_player_panel,	/*shows an interface for individual players, with various links (links require additional flags*/
	/client/proc/toggleadminhelpsound,	/*toggles whether we hear a sound when adminhelps/PMs are used*/
	/client/proc/deadmin_self,			/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/hide_most_verbs,		/*hides all our hideable adminverbs*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/check_antagonists,		/*shows all antags*/
	/datum/admins/proc/checkCID,
	/datum/admins/proc/checkCKEY
//	/client/proc/deadchat				/*toggles deadchat on/off*/
	)
var/list/admin_verbs_admin = list(
	/client/proc/player_panel,			/*shows an interface for all players, with links to various panels (old style)*/
	/client/proc/player_panel_new,		/*shows an interface for all players, with links to various panels*/
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
//	/datum/admins/proc/show_traitor_panel,	/*interface which shows a mob's mind*/ -Removed due to rare practical use. Moved to debug verbs ~Errorage
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/client/proc/colorooc,				/*allows us to set a custom colour for everythign we say in ooc*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/datum/admins/proc/view_txt_log,	/*shows the server log (diary) for today*/
	/datum/admins/proc/view_atk_log,	/*shows the server combat-log, doesn't do anything presently*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/datum/admins/proc/access_news_network,	/*allows access of newscasters*/
	/client/proc/giveruntimelog,		/*allows us to give access to runtime logs to somebody*/
	/client/proc/getruntimelog,			/*allows us to access runtime logs to somebody*/
	/client/proc/getserverlog,			/*allows us to fetch server logs (diary) for other days*/
	/client/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
//	/client/proc/sendmob,				/*sends a mob somewhere*/ -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/client/proc/Jump,
	/client/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcomm*/
	/client/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_local_narrate,	/*send text locally to all players in view, similar to direct narrate*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/check_words,			/*displays cult-words*/
	/client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/admin_memo,			/*admin memo system. show/delete/write. +SERVER needed to delete admin memos of others*/
	/client/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/toggleprayers,			/*toggles prayers on/off*/
//	/client/proc/toggle_hear_deadcast,	/*toggles whether we hear deadchat*/
	/client/proc/toggle_hear_radio,		/*toggles whether we hear the radio*/
	/client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,
	/client/proc/shuttle_magic,
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/cmd_admin_say,			/*admin-only ooc chat*/
	/datum/admins/proc/PlayerNotes,
	/client/proc/cmd_mod_say,
	/client/proc/cmd_mod_window,
	/datum/admins/proc/show_player_info,
	/client/proc/free_slot,			/*frees slot for chosen job*/
	/client/proc/cmd_admin_change_custom_event,
	/client/proc/cmd_admin_rejuvenate,
	/client/proc/toggleattacklogs,
	/client/proc/toggledebuglogs,
	/client/proc/check_customitem_activity,
	// /client/proc/man_up,
	// /client/proc/global_man_up,
	/client/proc/response_team, // Response Teams admin verb
	/client/proc/toggle_antagHUD_use,
	/client/proc/toggle_antagHUD_restrictions,
	/client/proc/allow_character_respawn    /* Allows a ghost to respawn */
)
var/list/admin_verbs_ban = list(
	/client/proc/unban_panel,
	/client/proc/jobbans,
	/client/proc/unjobban_panel
	// /client/proc/DB_ban_panel
	)
var/list/admin_verbs_sounds = list(
	/client/proc/play_local_sound,
	/client/proc/play_sound
	)
var/list/admin_verbs_fun = list(
	/datum/admins/proc/media_stop_all,
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/drop_emp,
	/client/proc/cinematic,
	/client/proc/one_click_antag,
	/client/proc/antag_madness,
	/datum/admins/proc/toggle_aliens,
	// FUUUUCKED /client/proc/zombie_event, // ZOMBB-B-BIES
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/set_ooc,
	/client/proc/editappear,
	/client/proc/commandname,
	/client/proc/delete_all_adminbus,
	/client/proc/delete_all_bomberman,
	/client/proc/create_bomberman_arena,
	/client/proc/control_bomberman_arena,
	/client/proc/gib_money, // /vg/
	/client/proc/smissmas,
	/client/proc/achievement,
	/client/proc/mommi_static,
	/client/proc/makepAI
	)
var/list/admin_verbs_spawn = list(
	/datum/admins/proc/spawn_atom,		/*	Allows us to spawn instances.							*/
	/client/proc/spawn_datum,		/*	Allows us to spawn datums to the marked datum buffer.	*/
	/client/proc/respawn_character
	)
var/list/admin_verbs_server = list(
	/client/proc/Set_Holiday,
	/client/proc/ToRban,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_debug_del_all,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/datum/admins/proc/toggle_aliens,
	/client/proc/toggle_random_events,
	/client/proc/check_customitem_activity,
	/client/proc/dump_chemreactions,
	)
var/list/admin_verbs_debug = list(
	/client/proc/getSchedulerContext,
	/client/proc/cmd_admin_list_open_jobs,
	/proc/getbrokeninhands,
	/client/proc/Debug2,
	/client/proc/kill_air,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/kill_airgroup,
	/client/proc/debug_controller,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/air_report,
	/client/proc/reload_admins,
	/client/proc/restart_controller,
	/client/proc/enable_debug_verbs,
	/client/proc/callproc,
	/client/proc/toggledebuglogs,
	/client/proc/qdel_toggle,              // /vg/
	/client/proc/cmd_admin_dump_instances, // /vg/
	/client/proc/cmd_admin_dump_machine_type_list, // /vg/
	/client/proc/disable_bloodvirii,       // /vg
	/client/proc/handle_paperwork, //this is completely experimental
	/client/proc/reload_style_sheet,
	/client/proc/reset_style_sheet,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/client/proc/configFood,
	/client/proc/debug_reagents,
	/client/proc/make_invulnerable,
	/client/proc/cmd_admin_dump_delprofile,
	/client/proc/mob_list,
	/client/proc/cure_disease,
	/client/proc/check_bomb,
	/client/proc/set_teleport_pref,
	/client/proc/check_convertables,
	/client/proc/check_spiral,
	/client/proc/cmd_admin_find_bad_blood_tracks,
#ifdef PROFILE_MACHINES
	/client/proc/cmd_admin_dump_macprofile,
#endif
	/client/proc/debugNatureMapGenerator,
	/client/proc/callatomproc
	)
var/list/admin_verbs_possess = list(
	/proc/possess,
	/proc/release
	)
var/list/admin_verbs_permissions = list(
	/client/proc/edit_admin_permissions
	)
var/list/admin_verbs_rejuv = list(
	/client/proc/respawn_character
	)

//verbs which can be hidden - needs work
var/list/admin_verbs_hideable = list(
	/client/proc/set_ooc,
	/client/proc/deadmin_self,
//	/client/proc/deadchat,
	/client/proc/toggleprayers,
	/client/proc/toggle_hear_radio,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/client/proc/colorooc,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/datum/admins/proc/view_txt_log,
	/datum/admins/proc/view_atk_log,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_check_contents,
	/datum/admins/proc/access_news_network,
	/client/proc/admin_call_shuttle,
	/client/proc/admin_cancel_shuttle,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/check_words,
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/object_talk,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/drop_emp,
	/client/proc/cinematic,
	/datum/admins/proc/toggle_aliens,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/make_sound,
	/client/proc/toggle_random_events,
	/client/proc/cmd_admin_add_random_ai_law,
	/client/proc/Set_Holiday,
	/client/proc/ToRban,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/toggleaban,
	/client/proc/toggle_log_hrefs,
	/datum/admins/proc/immreboot,
	/client/proc/everyone_random,
	/client/proc/shuttle_magic,
	/datum/admins/proc/toggleAI,
	/datum/admins/proc/adrev,
	/datum/admins/proc/adspawn,
	/datum/admins/proc/adjump,
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/callproc,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/kill_air,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/kill_airgroup,
	/client/proc/debug_controller,
	/client/proc/startSinglo,
	/client/proc/cheat_power,
	/client/proc/setup_atmos,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_all,
	/client/proc/cmd_debug_tog_aliens,
	/client/proc/air_report,
	/client/proc/enable_debug_verbs,
	/client/proc/mob_list,
	/proc/possess,
	/proc/release
	)
var/list/admin_verbs_mod = list(
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,	/*admin-pm list*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game.*/
	/client/proc/toggledebuglogs,
	/datum/admins/proc/PlayerNotes,
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/cmd_mod_say,
	/client/proc/cmd_mod_window,
	/datum/admins/proc/show_player_info,
	/client/proc/player_panel_new,
	/client/proc/vv_marked_datum,
	/datum/admins/proc/view_mob_attack_log /* Allow you to view attack logs since doing it in VV sucks */
)
/client/proc/add_admin_verbs()
	if(holder)
		verbs += admin_verbs_default
		if(holder.rights & R_BUILDMODE)		verbs += /client/proc/togglebuildmodeself
		if(holder.rights & R_ADMIN)			verbs += admin_verbs_admin
		if(holder.rights & R_BAN)			verbs += admin_verbs_ban
		if(holder.rights & R_FUN)			verbs += admin_verbs_fun
		if(holder.rights & R_SERVER)		verbs += admin_verbs_server
		if(holder.rights & R_DEBUG)			verbs += admin_verbs_debug
		if(holder.rights & R_POSSESS)		verbs += admin_verbs_possess
		if(holder.rights & R_PERMISSIONS)	verbs += admin_verbs_permissions
		if(holder.rights & R_STEALTH)		verbs += /client/proc/stealth
		if(holder.rights & R_REJUVINATE)	verbs += admin_verbs_rejuv
		if(holder.rights & R_SOUNDS)		verbs += admin_verbs_sounds
		if(holder.rights & R_SPAWN)			verbs += admin_verbs_spawn
		if(holder.rights & R_MOD)			verbs += admin_verbs_mod
		if(holder.rights & R_ADMINBUS)		verbs += /client/proc/secrets

/client/proc/remove_admin_verbs()
	verbs.Remove(
		admin_verbs_default,
		/client/proc/togglebuildmodeself,
		admin_verbs_admin,
		admin_verbs_ban,
		admin_verbs_fun,
		admin_verbs_server,
		admin_verbs_debug,
		admin_verbs_possess,
		admin_verbs_permissions,
		/client/proc/stealth,
		admin_verbs_rejuv,
		admin_verbs_sounds,
		admin_verbs_spawn,
		/*Debug verbs added by "show debug verbs"*/
		/client/proc/Cell,
		/client/proc/pdiff,
		/client/proc/do_not_use_these,
		/client/proc/camera_view,
		/client/proc/sec_camera_report,
		/client/proc/intercom_view,
		/client/proc/air_status,
		/client/proc/atmosscan,
		/client/proc/powerdebug,
		/client/proc/count_objects_on_z_level,
		/client/proc/count_objects_all,
		/client/proc/cmd_assume_direct_control,
		/client/proc/jump_to_dead_group,
		/client/proc/startSinglo,
		/client/proc/cheat_power,
		/client/proc/setup_atmos,
		/client/proc/ticklag,
		/client/proc/cmd_admin_grantfullaccess,
		/client/proc/kaboom,
		/client/proc/splash,
		/client/proc/cmd_admin_areatest,
		/client/proc/readmin,
		)

/client/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"
	verbs.Remove(/client/proc/hide_most_verbs, admin_verbs_hideable)
	verbs += /client/proc/show_verbs

	to_chat(src, "<span class='interface'>Most of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","HMV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"
	remove_admin_verbs()
	verbs += /client/proc/show_verbs
	to_chat(src, "<span class='interface'>Almost all of your adminverbs have been hidden.</span>")
	feedback_add_details("admin_verb","TAVVH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	verbs -= /client/proc/show_verbs
	add_admin_verbs()
	to_chat(src, "<span class='interface'>All of your adminverbs are now visible.</span>")
	feedback_add_details("admin_verb","TAVVS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!





/client/proc/admin_ghost()
	set category = "Admin"
	set name = "Aghost"
	if(!holder)	return
	if(istype(mob,/mob/dead/observer))
		//re-enter
		var/mob/dead/observer/ghost = mob
		ghost.can_reenter_corpse = 1			//just in-case.
		ghost.reenter_corpse()
		feedback_add_details("admin_verb","P") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else if(istype(mob,/mob/new_player))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or Observe first.</font>")
	else
		//ghostize
		var/mob/body = mob
		if(body.mind) body.mind.isScrying = 1
		body.ghostize(1)

		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		feedback_add_details("admin_verb","O") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Toggles ghost-like invisibility (Don't abuse this)"
	if(holder && mob)
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, "<span class='danger'>Invisimin off. Invisibility reset.</span>")
			mob.icon_state = "ghost"
			mob.icon = 'icons/mob/human.dmi'
			mob.update_icons()
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			to_chat(mob, "<span class='notice'><b>Invisimin on. You are now as invisible as a ghost.</b></span>")
			mob.icon_state = "ghost"
			mob.icon = 'icons/mob/mob.dmi'


/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if(holder)
		holder.player_panel_old()
	feedback_add_details("admin_verb","PP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/player_panel_new()
	set name = "Player Panel New"
	set category = "Admin"
	if(holder)
		holder.player_panel_new()
	feedback_add_details("admin_verb","PPN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Admin"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
	feedback_add_details("admin_verb","CHA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jobbans()
	set name = "Display Job bans"
	set category = "Admin"
	if(holder)
		if(config.ban_legacy_system)
			holder.Jobbans()
		else
			holder.DB_ban_panel()
	feedback_add_details("admin_verb","VJB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if(holder)
		if(config.ban_legacy_system)
			holder.unbanpanel()
		else
			holder.DB_ban_panel()
	feedback_add_details("admin_verb","UBP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if(holder)
		holder.Game()
	feedback_add_details("admin_verb","GP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (holder)
		holder.Secrets()
	feedback_add_details("admin_verb","S") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/colorooc()
	set category = "Fun"
	set name = "OOC Text Color"
	if(!holder)	return
	var/new_ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color|null
	if(new_ooccolor)
		prefs.ooccolor = new_ooccolor
		prefs.save_preferences_sqlite(src, ckey)
	feedback_add_details("admin_verb","OC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(input("Enter your desired display name.", "Fake Key", key) as text|null)
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(usr)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]", 1)
	feedback_add_details("admin_verb","SM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#define MAX_WARNS 3
#define AUTOBANTIME 90

/client/proc/warn(warned_ckey)
	var/reason = "Autobanning due to too many formal warnings"
	if(!check_rights(R_ADMIN))	return

	if(!warned_ckey || !istext(warned_ckey))	return


	var/datum/preferences/D
	var/client/C = directory[warned_ckey]
	if(C)	D = C.prefs
	else	D = preferences_datums[warned_ckey]

	if(!D)
		to_chat(src, "<font color='red'>Error: warn(): No such ckey found.</font>")
		return

	var/warn_reason = input("Reason for warning?", "Admin abuuuuuuuse") as null|text
	if(!warn_reason)
		return
	notes_add(warned_ckey,warn_reason,src.mob)
	if(++D.warns >= MAX_WARNS)					//uh ohhhh...you'reee iiiiin trouuuubble O:)
		var/bantime = AUTOBANTIME//= (++D.warnbans * AUTOBANTIME)
		D.warns = 0
		++D.warnbans
		for(var/i = 1; i < D.warnbans; i++)
			bantime *= 2
		ban_unban_log_save("[ckey] warned [warned_ckey] - [warn_reason], resulting in a [bantime] minute autoban.")
		if(C)
			message_admins("[key_name_admin(src)] has warned [key_name_admin(C)] - [warn_reason], resulting in a [bantime] minute ban.")
			to_chat(C, "<span class='danger'><BIG>You have been autobanned due to a warning by [ckey] - Reason: [warn_reason].</BIG></span><br>This is a temporary ban, it will be removed in [bantime] minutes.")
		else
			message_admins("[key_name_admin(src)] has warned [warned_ckey] - [warn_reason], resulting in a [bantime] minute ban.")
		AddBan(warned_ckey, D.last_id, "Autobanning due to too many formal warnings - [warn_reason]", ckey, 1, bantime)
		holder.DB_ban_record(BANTYPE_TEMP, null, bantime, "[reason] - [warn_reason]", , ,warned_ckey)
		feedback_inc("ban_warn",1)
		D.save_preferences_sqlite(C, C.ckey)
		del(C)
	else
		if(C)
			to_chat(C, "<span class='danger'><BIG>You have been formally warned by an administrator - Reason: [warn_reason].</span></BIG><br>Further warnings will result in an autoban.</font>")
			message_admins("[key_name_admin(src)] has warned [key_name_admin(C)] - [warn_reason]. They have [MAX_WARNS-D.warns] strikes remaining. And have been warn banned [D.warnbans] [D.warnbans == 1 ? "time" : "times"]")
		else
			message_admins("[key_name_admin(src)] has warned [warned_ckey] (DC) - [warn_reason]. They have [MAX_WARNS-D.warns] strikes remaining. And have been warn banned [D.warnbans] [D.warnbans == 1 ? "time" : "times"]")
		D.save_preferences_sqlite(C, C.ckey)
	feedback_add_details("admin_verb","WARN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unwarn(warned_ckey)
	if(!check_rights(R_ADMIN))	return

	if(!warned_ckey || !istext(warned_ckey))	return
	/*if(warned_ckey in admin_datums)
		to_chat(usr, "<font color='red'>Error: warn(): You can't warn admins.</font>")
		return*/

	var/datum/preferences/D
	var/client/C = directory[warned_ckey]
	if(C)	D = C.prefs
	else	D = preferences_datums[warned_ckey]

	if(!D)
		to_chat(src, "<font color='red'>Error: unwarn(): No such ckey found.</font>")
		return

	if(D.warns == 0)
		to_chat(src, "<font color='red'>Error: unwarn(): You can't unwarn someone with 0 warnings, you big dummy.</font>")
		return

	D.warns-=1
	var/strikesleft = MAX_WARNS-D.warns
	if(C)
		to_chat(C, "<font color='red'><BIG><B>One of your warnings has been removed.</B></BIG><br>You currently have [strikesleft] strike\s left</font>")
		message_admins("[key_name_admin(src)] has unwarned [key_name_admin(C)]. They have [strikesleft] strike(s) remaining, and have been warn banned [D.warnbans] [D.warnbans == 1 ? "time" : "times"]")
	else
		message_admins("[key_name_admin(src)] has unwarned [warned_ckey] (DC). They have [strikesleft] strike(s) remaining, and have been warn banned [D.warnbans] [D.warnbans == 1 ? "time" : "times"]")
	D.save_preferences_sqlite(C, C.ckey)
	feedback_add_details("admin_verb","UNWARN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef MAX_WARNS
#undef AUTOBANTIME

/client/proc/drop_bomb() // Some admin dickery that can probably be done better -- TLE
	set category = "Special Verbs"
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small Bomb (1,2,3)", "Medium Bomb (2,3,4)", "Big Bomb (3,5,7)", "Custom Bomb")
	var/choice = input("What size explosion would you like to produce?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small Bomb (1,2,3)")
			explosion(epicenter, 1, 2, 3, 3)
		if("Medium Bomb (2,3,4)")
			explosion(epicenter, 2, 3, 4, 4)
		if("Big Bomb (3,5,7)")
			explosion(epicenter, 3, 5, 7, 5)
		if("Custom Bomb")
			var/devastation_range = input("Devastation range (in tiles):") as num
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			var/flash_range = input("Flash range (in tiles):") as num
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	log_admin("[key_name(usr)] creating an admin explosion at [epicenter.loc] ([epicenter.x],[epicenter.y],[epicenter.z]).")
	message_admins("<span class='notice'>[key_name_admin(src)] creating an admin explosion at [epicenter.loc] ([epicenter.x],[epicenter.y],[epicenter.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</A>).</span>")
	feedback_add_details("admin_verb","DB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/drop_emp()
	set category = "Special Verbs"
	set name = "Drop EMP"
	set desc = "Cause an EMP of varying strength at your location."

	var/turf/epicenter = mob.loc
	var/list/choices = list("Small EMP (1,2)", "Medium EMP (2,4)", "Big EMP (4,8)", "Custom EMP")
	var/choice = input("What size EMP would you like to produce?") in choices
	switch(choice)
		if(null)
			return 0
		if("Small EMP (1,2)")
			empulse(epicenter, 1, 2)
		if("Medium EMP (2,4)")
			empulse(epicenter, 2, 4)
		if("Big EMP (4,8)")
			empulse(epicenter, 4, 8)
		if("Custom EMP")
			var/heavy_impact_range = input("Heavy impact range (in tiles):") as num
			var/light_impact_range = input("Light impact range (in tiles):") as num
			empulse(epicenter, heavy_impact_range, light_impact_range)
	log_admin("[key_name(usr)] creating an admin EMP at [epicenter.loc] ([epicenter.x],[epicenter.y],[epicenter.z]).")
	message_admins("<span class='notice'>[key_name_admin(src)] creating an admin EMP at [epicenter.loc] ([epicenter.x],[epicenter.y],[epicenter.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</A>).</span>")
	feedback_add_details("admin_verb","DE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_spell(mob/T as mob in mob_list) // -- Urist
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Gives a spell to a mob."

	var/spell/S = input("Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spells
	if(!S) return
	T.add_spell(new S)
	feedback_add_details("admin_verb","GS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("<span class='notice'>[key_name_admin(usr)] gave [key_name(T)] the spell [S].</span>", 1)

/client/proc/give_disease(mob/T as mob in mob_list) // -- Giacom
	set category = "Fun"
	set name = "Give Disease"
	set desc = "Gives a Disease to a mob."
	var/datum/disease/D = input("Choose the disease to give to that guy", "ACHOO") as null|anything in diseases
	if(!D) return
	T.contract_disease(new D, 1)
	feedback_add_details("admin_verb","GD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("<span class='notice'>[key_name_admin(usr)] gave [key_name(T)] the disease [D].</span>", 1)

/client/proc/make_sound(var/obj/O in world) // -- TLE
	set category = "Special Verbs"
	set name = "Make Sound"
	set desc = "Display a message to everyone who can hear the target"
	if(istype(O))
		var/message = input("What do you want the message to be?", "Make Sound") as text|null
		if(!message)
			return
		var/mob/living/M
		var/olduniv
		if(ismob(O))
			M = O
			olduniv = M.universal_speak
			M.universal_speak = 1
		O.say(message)
		if(M)
			M.universal_speak = olduniv
		log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound")
		message_admins("<span class='notice'>[key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z]. make a sound</span>", 1)
		feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Special Verbs"
	if(src.mob)
		togglebuildmode(src.mob)
	feedback_add_details("admin_verb","TBMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/object_talk(var/obj/O in world) // -- TLE
	set category = "Special Verbs"
	set name = "OSay"
	set desc = "Make an object say something"
	var/message = input(usr, "What do you want the message to be?", "Make Sound") as text | null
	if(!message)
		return
	var/mob/living/M
	var/olduniv
	if(ismob(O))
		M = O
		olduniv = M.universal_speak
		M.universal_speak = 1
	O.say(message)
	if(M)
		M.universal_speak = olduniv
	log_admin("[key_name(usr)] made [O] at [O.x], [O.y], [O.z] say \"[message]\"")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] made [O] at [O.x], [O.y], [O.z]. say \"[message]\"</span>", 1)
	feedback_add_details("admin_verb","OT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/kill_air() // -- TLE
	set category = "Debug"
	set name = "Kill Air"
	set desc = "Toggle Air Processing"
	if(air_processing_killed)
		air_processing_killed = 0
		to_chat(usr, "<b>Enabled air processing.</b>")
	else
		air_processing_killed = 1
		to_chat(usr, "<b>Disabled air processing.</b>")
	feedback_add_details("admin_verb","KA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] used 'kill air'.")
	message_admins("<span class='notice'>[key_name_admin(usr)] used 'kill air'.</span>", 1)

/client/proc/deadmin_self()
	set name = "De-admin self"
	set category = "Admin"

	if(holder)
		if(alert("Are you sure you want to deadmin?","Deadmin","Yes","No")=="No")
			return
		log_admin("[src] deadminned themself.")
		message_admins("[src] deadminned themself.")
		deadmin()
		verbs += /client/proc/readmin
		deadmins += ckey
		to_chat(src, "<span class='interface'>You are now a normal player.</span>")
	feedback_add_details("admin_verb","DAS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_log_hrefs()
	set name = "Toggle href logging"
	set category = "Server"
	if(!holder)	return
	if(config)
		if(config.log_hrefs)
			config.log_hrefs = 0
			to_chat(src, "<b>Stopped logging hrefs</b>")
		else
			config.log_hrefs = 1
			to_chat(src, "<b>Started logging hrefs</b>")

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"
	if(holder)
		src.holder.output_ai_laws()


//---- bs12 verbs ----

/client/proc/mod_panel()
	set name = "Moderator Panel"
	set category = "Admin"

/*	if(holder)
		holder.mod_panel()*/
//	feedback_add_details("admin_verb","MP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/editappear(mob/living/carbon/human/M as mob in mob_list)
	set name = "Edit Appearance"
	set category = "Fun"

	if(!check_rights(R_FUN))	return

	if(!istype(M, /mob/living/carbon/human))
		to_chat(usr, "<span class='warning'>You can only do this to humans!</span>")
		return
	switch(alert("Are you sure you wish to edit this mob's appearance? Skrell, Unathi, Vox and Tajaran can result in unintended consequences.",,"Yes","No"))
		if("No")
			return
	var/new_facial = input("Please select facial hair color.", "Character Generation") as color
	if(new_facial)
		M.r_facial = hex2num(copytext(new_facial, 2, 4))
		M.g_facial = hex2num(copytext(new_facial, 4, 6))
		M.b_facial = hex2num(copytext(new_facial, 6, 8))

	var/new_hair = input("Please select hair color.", "Character Generation") as color
	if(new_facial)
		M.r_hair = hex2num(copytext(new_hair, 2, 4))
		M.g_hair = hex2num(copytext(new_hair, 4, 6))
		M.b_hair = hex2num(copytext(new_hair, 6, 8))

	var/new_eyes = input("Please select eye color.", "Character Generation") as color
	if(new_eyes)
		M.r_eyes = hex2num(copytext(new_eyes, 2, 4))
		M.g_eyes = hex2num(copytext(new_eyes, 4, 6))
		M.b_eyes = hex2num(copytext(new_eyes, 6, 8))

	var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

	if (new_tone)
		M.s_tone = max(min(round(text2num(new_tone)), 220), 1)
		M.s_tone =  -M.s_tone + 35

	// hair
	var/new_hstyle = input(usr, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
	if(new_hstyle)
		M.h_style = new_hstyle

	// facial hair
	var/new_fstyle = input(usr, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
	if(new_fstyle)
		M.f_style = new_fstyle

	var/new_gender = alert(usr, "Please select gender.", "Character Generation", "Male", "Female")
	if (new_gender)
		if(new_gender == "Male")
			M.setGender(MALE)
		else
			M.setGender(FEMALE)
	M.update_hair()
	M.update_body()
	M.check_dna(M)

/client/proc/playernotes()
	set name = "Show Player Info"
	set category = "Admin"
	if(holder)
		holder.PlayerNotes()
	return

/client/proc/free_slot()
	set name = "Free Job Slot"
	set category = "Admin"
	if(holder)
		var/list/jobs = list()
		for (var/datum/job/J in job_master.occupations)
			if (J.current_positions >= J.total_positions && J.total_positions != -1)
				jobs += J.title
		if (!jobs.len)
			to_chat(usr, "There are no fully staffed jobs.")
			return
		var/job = input("Please select job slot to free", "Free job slot")  as null|anything in jobs
		if (job)
			job_master.FreeRole(job)
	return

/client/proc/toggleattacklogs()
	set name = "Toggle Attack Log Messages"
	set category = "Preferences"

	prefs.toggles ^= CHAT_ATTACKLOGS
	prefs.save_preferences_sqlite(src, ckey)
	if (prefs.toggles & CHAT_ATTACKLOGS)
		to_chat(usr, "You now will get attack log messages")
	else
		to_chat(usr, "You now won't get attack log messages")

/client/proc/commandname()
	set name = "Set Command Name"
	set category = "Fun"

	var/text = input(usr,"Please select a new Central Command name.", null)as text|null
	if(text)
		change_command_name(text)

/client/proc/toggledebuglogs()
	set name = "Toggle Debug Log Messages"
	set category = "Preferences"

	prefs.toggles ^= CHAT_DEBUGLOGS
	prefs.save_preferences_sqlite(src, ckey)
	if (prefs.toggles & CHAT_DEBUGLOGS)
		to_chat(usr, "You now will get debug log messages")
	else
		to_chat(usr, "You now won't get debug log messages")


/client/proc/man_up(mob/T as mob in mob_list)
	set category = "Fun"
	set name = "Man Up"
	set desc = "Tells mob to man up and deal with it."

	to_chat(T, "<span class='notice'><b><font size=3>Man up and deal with it.</font></b></span>")
	to_chat(T, "<span class='notice'>Move on.</span>")

	log_admin("[key_name(usr)] told [key_name(T)] to man up and deal with it.")
	message_admins("<span class='notice'>[key_name_admin(usr)] told [key_name(T)] to man up and deal with it.</span>", 1)

/client/proc/global_man_up()
	set category = "Fun"
	set name = "Man Up Global"
	set desc = "Tells everyone to man up and deal with it."

	for (var/mob/T as mob in mob_list)
		to_chat(T, "<br><center><span class='notice'><b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.</span></center><br>")
		to_chat(T, 'sound/voice/ManUp1.ogg')

	log_admin("[key_name(usr)] told everyone to man up and deal with it.")
	message_admins("<span class='notice'>[key_name_admin(usr)] told everyone to man up and deal with it.</span>", 1)


/client/proc/readmin()
	set name = "Re-admin self"
	set category = "Admin"
	set desc = "Regain your admin powers."
	var/datum/admins/D = admin_datums[ckey]
	if(config.admin_legacy_system)
		to_chat(src, "<span class='notice'>Legacy admins is not supported yet</span>")
		return
	else
		if(!dbcon.IsConnected())
			message_admins("Warning, mysql database is not connected.")
			to_chat(src, "Warning, mysql database is not connected.")
			return
		if(D)
			to_chat(src, "You are already an admin.")
			verbs -= /client/proc/readmin
			return
		var/sql_ckey = sanitizeSQL(ckey(ckey))
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey, rank, level, flags FROM erro_admin WHERE ckey = '[sql_ckey]'")
		query.Execute()
		while(query.NextRow())
			var/dckey = query.item[1]
			var/rank = query.item[2]
			if(rank == "Removed")	continue	//This person was de-adminned. They are only in the admin list for archive purposes.

			var/rights = query.item[4]
			if(istext(rights))	rights = text2num(rights)
			D = new /datum/admins(rank, rights, dckey)

			//find the client for a ckey if they are connected and associate them with the new admin datum
			D.associate(src)
			message_admins("[src] re-adminned themselves.")
			log_admin("[src] re-adminned themselves.")
			feedback_add_details("admin_verb","RAS")
			verbs -= /client/proc/readmin
			return

/client/proc/achievement()
	set name = "Give Achievement"
	set category = "Fun"

	if(!check_rights(R_FUN))	return

	var/achoice = "Cancel"

	if(!player_list.len)
		to_chat(usr, "player list is empty!")
		return

	var/mob/winner = input("Who's a winner?", "Achievement Winner") in player_list
	var/name = input("What will you call your achievement?", "Achievement Winner", "New Achievement")
	var/desc = input("What description will you give it?", "Achievement Description", "You Win")

	if(istype(winner, /mob/living))
		achoice = alert("Give our winner his own trophy?","Achievement Trophy", "Confirm","Cancel")

	var/glob = alert("Announce the achievement globally? (Beware! Ruins immersion!)","Last Question", "No!","Yes!")

	if(achoice == "Confirm")
		var/obj/item/weapon/reagent_containers/food/drinks/golden_cup/C = new(get_turf(winner))
		C.name = name
		C.desc = desc
		if(iscarbon(winner) && (winner.stat == CONSCIOUS))
			winner.put_in_hands(C)
	else
		to_chat(winner, "<span class='danger'>You win [name]! [desc]</span>")

	var/icon/cup = icon('icons/obj/drinks.dmi', "golden_cup")

	if(glob == "No!")
		to_chat(winner.client, sound('sound/misc/achievement.ogg'))
		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='danger'>\icon[cup] <b>[winner.name]</b> wins \"<b>[name]</b>\"!</span>")
	else
		to_chat(world, sound('sound/misc/achievement.ogg'))
		to_chat(world, "<span class='danger'>\icon[cup] <b>[winner.name]</b> wins \"<b>[name]</b>\"!</span>")

	to_chat(winner, "<span class='danger'>Congratulations!</span>")

	achievements += "<b>[winner.key]</b> as <b>[winner.name]</b> won \"<b>[name]</b>\"! \"[desc]\""

	message_admins("[key_name_admin(usr)] has awarded <b>[winner.key]</b>([winner.name]) with the achievement \"<b>[name]</b>\"! \"[desc]\".", 1)

/client/proc/mommi_static()
	set name = "Toggle MoMMI Static"
	set desc = "Toggle whether MoMMIs can see mobs or if the mobs are cloaked in static"
	set category = "Fun"

	if(!holder || !config)
		return

	config.mommi_static = !config.mommi_static
	log_admin("[key_name(src)] turned MoMMI static [config.mommi_static ? "on" : "off"].")
	message_admins("[key_name(src)] turned MoMMI static [config.mommi_static ? "on" : "off"].")
	for(var/mob/living/silicon/robot/mommi/M in player_list)
		if(M.can_see_static())
			M.add_static_overlays()
		else
			M.remove_static_overlays()

/client/proc/shuttle_magic()
	set name = "Shuttle Magic"
	set desc = "Open a menu with magic"
	set category = "Admin"

	if(!holder || !config)
		return

	holder.shuttle_magic()


/datum/admins/proc/media_stop_all()
	set name = "Stop All Media"
	set desc = "Stops all music and video."
	set category = "Fun"

	if(!check_rights(R_FUN))
		return

	message_admins("[key_name_admin(usr)] has stopped all media.", 1)

	stop_all_media()
