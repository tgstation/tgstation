//
// Admin Verbs modify the game state in some manner, whether that is by modifying the local area, or the station as a whole
//
#define ADMIN_VERB_ADMIN(module, _name, _desc, params...) ADMIN_VERB(module, _name, _desc, R_ADMIN, params...)

ADMIN_VERB_ADMIN(game, fix_air, "Fixes air in the specified radius", turf/open/target in world)
	var/range = tgui_input_number(usr, "Specify the radius", "Fix Air", 2, min_value = 0)
	message_admins("[key_name_admin(usr)] fixed air with range [range] in area [T.loc.name]")
	usr.log_message("fixed air with range [range] in area [T.loc.name]", LOG_ADMIN)
	for(var/turf/open/open_turf in range(range,T))
		if(open_turf.blocks_air)
			continue

		var/datum/gas_mixture/initial_air = SSair.parse_gas_string(open_turf.initial_gas_mix, /datum/gas_mixture/turf)
		open_turf.copy_air(initial_air)
		open_turf.update_visuals()
