ADMIN_VERB_CONTEXT_MENU(fix_air, "Fix Air", R_ADMIN, turf/open/target in world)
	var/range = tgui_input_number(user, "What radius would you like to fix the air around the turf.", "Fix Air", 2, max_value = user.view, min_value = 0)
	if(isnull(range))
		return

	var/message = "[key_name(user)] fixed air with a range of [range] centered around [target.loc.name]"
	message_admins("[message][ADMIN_JMP(target)]")
	usr.log_message(message, LOG_ADMIN)

	for(var/turf/open/floor in range(range, target))
		if(floor.blocks_air)
			continue
		var/datum/gas_mixture/initial_gas = SSair.parse_gas_string(floor.initial_gas_mix, /datum/gas_mixture/turf)
		floor.copy_air(initial_gas)
		floor.update_visuals()
