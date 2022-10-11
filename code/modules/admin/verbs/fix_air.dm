// Proc taken from yogstation, credit to nichlas0010 for the original
/client/proc/fix_air(turf/open/T in world)
	set name = "Fix Air"
	set category = "Admin.Game"
	set desc = "Fixes air in specified radius."

	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	if(check_rights(R_ADMIN,1))
		var/range=input("Enter range:","Num",2) as num
		message_admins("[key_name_admin(usr)] fixed air with range [range] in area [T.loc.name]")
		usr.log_message("fixed air with range [range] in area [T.loc.name]", LOG_ADMIN)
		for(var/turf/open/F in range(range,T))
			if(F.blocks_air)
			//skip walls
				continue
			var/datum/gas_mixture/GM = SSair.parse_gas_string(F.initial_gas_mix, /datum/gas_mixture/turf)
			F.copy_air(GM)
			F.update_visuals()
