// Proc taken from yogstation, credit to nichlas0010 for the original
ADMIN_VERB_AND_CONTEXT_MENU(fix_air, R_ADMIN, "Fix Air", "Fixes air in a specified radius.", ADMIN_CATEGORY_GAME, turf/open/locale in world, range = 2 as num)
	message_admins("[key_name_admin(user)] fixed air with range [range] in area [locale.loc.name]")
	user.mob.log_message("fixed air with range [range] in area [locale.loc.name]", LOG_ADMIN)

	for(var/turf/open/valid_range_turf in range(range,locale))
		if(valid_range_turf.blocks_air)
		//skip walls
			continue
		var/datum/gas_mixture/GM = SSair.parse_gas_string(valid_range_turf.initial_gas_mix, /datum/gas_mixture/turf)
		valid_range_turf.copy_air(GM)
		valid_range_turf.temperature = initial(valid_range_turf.temperature)
		valid_range_turf.update_visuals()
