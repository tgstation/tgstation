/datum/antagonist/nukeop/lone
	name = "Lone Operative"
	always_new_team = TRUE
	send_to_spawnpoint = FALSE //Handled by event
	nukeop_outfit = /datum/outfit/syndicate/full/loneop
	preview_outfit = /datum/outfit/nuclear_operative
	preview_outfit_behind = null
	nuke_icon_state = null

/datum/antagonist/nukeop/lone/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_nukecode()
		var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in SSmachines.get_machines_by_type(/obj/machinery/nuclearbomb/selfdestruct)
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == NUKE_CODE_UNSET)
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Station self-destruct not found during lone op team creation.")
			nuke_team.memorized_code = null
