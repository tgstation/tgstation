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
