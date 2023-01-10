//
// Admin Verbs modify the game state in some manner, whether that is by modifying the local area, or the station as a whole
//
#define ADMIN_VERB_ADMIN(module, _name, _desc, params...) ADMIN_VERB(module, _name, _desc, R_ADMIN, ##params)

ADMIN_CONTEXT_ENTRY(contextcmd_fix_air, "Fix Air", R_ADMIN, turf/target in world)
	var/range = tgui_input_number(usr, "Specify the radius", "Fix Air", 2, min_value = 0)
	message_admins("[key_name_admin(usr)] fixed air with range [range] in area [target.loc.name]")
	usr.log_message("fixed air with range [range] in area [target.loc.name]", LOG_ADMIN)
	for(var/turf/open/open_turf in range(range, target))
		if(open_turf.blocks_air)
			continue

		var/datum/gas_mixture/initial_air = SSair.parse_gas_string(open_turf.initial_gas_mix, /datum/gas_mixture/turf)
		open_turf.copy_air(initial_air)
		open_turf.update_visuals()

ADMIN_VERB_ADMIN(events, access_news_network, "Allows you to view, add and edit news feeds")
	var/datum/newspanel/new_newspanel = new
	new_newspanel.ui_interact(usr)

ADMIN_VERB_ADMIN(admin, announce, "Announce your desires to the world", message as message|null)
	if(!message)
		return
	message = check_rights_for(usr.client, R_SERVER) ? message : adminscrub(message, 500)
	to_chat(world, "[span_adminnotice("<b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b>")]\n \t [message]")
	log_admin("Announce: [key_name(usr)] : [message]")

ADMIN_VERB(admin, known_alts_panel, "View all known alt accounts", NONE)
	GLOB.known_alts.show_panel(usr.client)

/**
/datum/admins/proc/display_tags
/datum/admins/proc/show_lag_switch_panel
/datum/admins/proc/open_borgopanel
/datum/admins/proc/open_shuttlepanel /* Opens shuttle manipulator UI */
/datum/admins/proc/paintings_manager
/datum/admins/proc/set_admin_notice /*announcement all clients see when joining the server.*/
/datum/admins/proc/show_player_panel /*shows an interface for individual players, with various links (links require additional flags*/
/datum/admins/proc/toggleenter /*toggles whether people can join the current game*/
/datum/admins/proc/toggleguests /*toggles whether guests can join the current game*/
/datum/admins/proc/toggleooc /*toggles ooc on/off for everyone*/
/datum/admins/proc/toggleoocdead /*toggles ooc on/off for everyone who is dead*/
/datum/admins/proc/trophy_manager
/datum/admins/proc/view_all_circuits
/datum/verbs/menu/Admin/verb/playerpanel /* It isn't /datum/admin but it fits no less */
/client/proc/admin_call_shuttle /*allows us to call the emergency shuttle*/
/client/proc/admin_cancel_shuttle /*allows us to cancel the emergency shuttle, sending it back to centcom*/
/client/proc/admin_disable_shuttle /*allows us to disable the emergency shuttle admin-wise so that it cannot be called*/
/client/proc/admin_enable_shuttle  /*undoes the above*/
/client/proc/admin_ghost /*allows us to ghost/reenter body at will*/
/client/proc/admin_hostile_environment /*Allows admins to prevent the emergency shuttle from leaving, also lets admins clear hostile environments if theres one stuck*/
/client/proc/cmd_admin_check_contents /*displays the contents of an instance*/
/client/proc/cmd_admin_check_player_exp /* shows players by playtime */
/client/proc/cmd_admin_create_centcom_report
/client/proc/cmd_admin_delete /*delete an instance/object/mob/etc*/
/client/proc/cmd_admin_direct_narrate /*send text directly to a player with no padding. Useful for narratives and fluff-text*/
/client/proc/cmd_admin_headset_message /*send a message to somebody through their headset as CentCom*/
/client/proc/cmd_admin_local_narrate /*sends text to all mobs within view of atom*/
/client/proc/cmd_admin_subtle_message /*send a message to somebody as a 'voice in their head'*/
/client/proc/cmd_admin_world_narrate /*sends text to all players with no padding*/
/client/proc/cmd_change_command_name
/client/proc/centcom_podlauncher/*Open a window to launch a Supplypod and configure it or it's contents*/
/client/proc/check_ai_laws /*shows AI and borg laws*/
/client/proc/fax_panel /*send a paper to fax*/
/client/proc/force_load_lazy_template
/client/proc/Getmob /*teleports a mob to our location*/
/client/proc/Getkey /*teleports a mob with a certain ckey to our location*/
/client/proc/getserverlogs /*for accessing server logs*/
/client/proc/getcurrentlogs /*for accessing server logs for the current round*/
/client/proc/ghost_pool_protection /*opens a menu for toggling ghost roles*/
/client/proc/jumptoarea
/client/proc/jumptokey /*allows us to jump to the location of a mob with a certain ckey*/
/client/proc/jumptomob /*allows us to jump to a specific mob*/
/client/proc/jumptoturf /*allows us to jump to a specific turf*/
/client/proc/jumptocoord /*we ghost and jump to a coordinate*/
/client/proc/message_pda /*send a message to somebody on PDA*/
/client/proc/respawn_character
/client/proc/toggle_AI_interact /*toggle admin ability to interact with machines as an AI*/
/client/proc/toggle_combo_hud /* toggle display of the combination pizza antag and taco sci/med/eng hud */
/client/proc/toggle_view_range /*changes how far we can see*/
 */
