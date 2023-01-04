// /*
// 	/client/proc/debugstatpanel,
// 	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
// 	/client/proc/dsay, /*talk in deadchat using our ckey/fakekey*/
// 	/client/proc/fix_air, /*resets air in designated radius to its default atmos composition*/
// 	/client/proc/hide_verbs, /*hides all our adminverbs*/
// 	/client/proc/investigate_show, /*various admintools for investigation. Such as a singulo grief-log*/
// 	/client/proc/mark_datum_mapview,
// 	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
// 	/client/proc/tag_datum_mapview,
// */

ADMIN_VERB(admin, deadmin, "Become a normal player", NONE)
	usr.client.holder.deactivate()

ADMIN_VERB(debug, reload_admins, "Reloads all admins from the data store", NONE)
	var/confirm = tgui_alert(usr, "Are you sure you want to reload all admins?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	message_admins("[key_name_admin(usr)] manually reloaded admins.")
	load_admins()

ADMIN_VERB(debug, stop_all_sounds, "Stop all sounds on all connected clients", NONE)
	log_admin("[key_name(usr)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(usr)] stopped all currently playing sounds.")
	for(var/mob/player as anything in GLOB.player_list)
		SEND_SOUND(player, sound(null))
		// player list is only supposed to contain mobs with an attached client,
		// but clients can just poof in and out of existence
		player.client?.tgui_panel.stop_music()

ADMIN_VERB(game, secrets_panel, "Abuse harder than you ever knew was possible", NONE)
	usr.client?.secrets()

ADMIN_VERB(game, requests_manager, "Open the request manager panel to view all requests during this round", NONE)
	GLOB.requests.ui_interact(usr)
