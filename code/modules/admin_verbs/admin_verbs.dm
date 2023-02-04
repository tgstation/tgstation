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

ADMIN_VERB(events, access_news_network, "Access News Network", "Allows you to view, add and edit news feeds", R_ADMIN)
	var/datum/newspanel/new_newspanel = new
	new_newspanel.ui_interact(usr)

ADMIN_VERB(admin, announce, "Announce", "Announce your desires to the world", (R_ADMIN|R_SERVER), message as message|null)
	if(!message)
		return
	message = check_rights_for(usr.client, R_SERVER) ? message : adminscrub(message, 500)
	to_chat(world, "[span_adminnotice("<b>[usr.client.holder.fakekey ? "Administrator" : usr.key] Announces:</b>")]\n \t [message]")
	log_admin("Announce: [key_name(usr)] : [message]")

ADMIN_VERB(admin, known_alts_panel, "Known Alts Panel", "View all known alt accounts", NONE)
	GLOB.known_alts.show_panel(usr.client)
