// /*
// 	/client/proc/cmd_admin_pm_context, /*right-click adminPM interface*/
// 	/client/proc/debugstatpanel,
// 	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
// 	/client/proc/dsay, /*talk in deadchat using our ckey/fakekey*/
// 	/client/proc/fix_air, /*resets air in designated radius to its default atmos composition*/
// 	/client/proc/hide_verbs, /*hides all our adminverbs*/
// 	/client/proc/investigate_show, /*various admintools for investigation. Such as a singulo grief-log*/
// 	/client/proc/mark_datum_mapview,
// 	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
// 	/client/proc/requests,
// 	/client/proc/tag_datum_mapview,
// */

// /datum/admin_verb_datum/deadmin
// 	verb_name = "DeAdmin"
// 	verb_desc = "Become a normal player"

// /datum/admin_verb_datum/deadmin/invoke()
// 	usr.client.holder.deactivate()

// /datum/admin_verb_datum/reload_admins
// 	verb_name = "Reload Admins"
// 	verb_desc = "Reloads all admins from the data store"
// 	verb_category = "Debug"

// /datum/admin_verb_datum/reload_admins/invoke(client/target, list/arguments)
// 	var/confirm = tgui_alert(target, "Are you sure you want to reload all admins?", "Confirm", list("Yes", "No"))
// 	if(confirm != "Yes")
// 		return

// 	message_admins("[key_name_admin(usr)] manually reloaded admins.")
// 	load_admins()

// /datum/admin_verb_datum/stop_all_sounds
// 	verb_name = "Stop All Sounds"
// 	verb_desc = "Stop all sounds on every connected client"
// 	verb_category = "Debug"

// /datum/admin_verb_datum/stop_all_sounds/invoke(client/target, list/arguments)
// 	log_admin("[key_name(target)] stopped all currently playing sounds.")
// 	message_admins("[key_name_admin(target)] stopped all currently playing sounds.")
// 	for(var/mob/player as anything in GLOB.player_list)
// 		SEND_SOUND(player, sound(null))
// 		// player list is only supposed to contain mobs with an attached client,
// 		// but clients can just poof in and out of existence
// 		player.client?.tgui_panel?.stop_music()

// /datum/admin_verb_datum/secrets_menu
// 	verb_name = "Secrets Panel"
// 	verb_desc = "Abuse harder than you even knew was possible"
// 	verb_category = "Game"

// /datum/admin_verb_datum/secrets_menu/invoke(client/target, list/arguments)
// 	target.secrets()

ADMIN_CONTEXT_ENTRY(context_admin_pm, "Admin PM", NONE, mob/target in GLOB.player_list)
	to_chat(target, span_warning("Cope"))
