/**
 * Request Emergency Temporary Access - Admin Verbs
 */

/// Admin command to manually trigger RETA access grant for admins
ADMIN_VERB(reta_manual_trigger, R_ADMIN, "RETA Door Access", "Manually trigger RETA access for testing", ADMIN_CATEGORY_EVENTS)

	var/calling_dept = tgui_input_list(user, "RETA - Which department is CALLING for help?", "Calling Department", list("Security", "Engineering", "Medical", "Science", "Service", "Command", "Cargo", "Mining"))
	if(!calling_dept)
		return

	var/list/available_depts = list("Security", "Engineering", "Medical", "Science", "Service", "Command", "Cargo", "Mining")
	available_depts -= calling_dept

	// Multi-select using repeated input_list calls
	var/list/selected_depts = list()
	var/list/remaining_depts = available_depts.Copy()

	while(length(remaining_depts))
		remaining_depts += "DONE - Finish selection"
		var/choice = tgui_input_list(user, "RETA - Select departments to RESPOND to [calling_dept]\nCurrently selected: [english_list(selected_depts)]\n\nSelect another department or DONE:", "Responding Departments", remaining_depts)

		if(!choice || choice == "DONE - Finish selection")
			break

		selected_depts += choice
		remaining_depts -= choice
		remaining_depts -= "DONE - Finish selection"

	if(!length(selected_depts))
		message_admins("No departments selected for RETA response.")
		return

	var/duration = tgui_input_number(user, "Duration in minutes:", "RETA Duration", 5, 60, 1)
	if(!duration)
		return

	message_admins("[key_name_admin(user)] is manually triggering RETA: [calling_dept] called for help, [english_list(selected_depts)] will get access to [calling_dept] areas for [duration] minutes.")
	log_game("ADMIN: [key_name(user)] is manually triggering RETA: [calling_dept] called for help, [english_list(selected_depts)] will get access to [calling_dept] areas for [duration] minutes.")

	// Grant access to each responding department and collect results
	var/successful_grants = 0
	var/list/granted_depts = list()
	var/total_eligible_cards = 0

	for(var/responding_dept in selected_depts)
		var/dept_eligible_cards = 0
		var/list/job_trims = GLOB.reta_job_trims[responding_dept]

		for(var/mob/living/carbon/human/human_player as anything in GLOB.human_list)
			if(!human_player.client || human_player.stat == DEAD)
				continue

			var/obj/item/card/id/id_card = human_player.get_idcard(hand_first = FALSE)
			if(!id_card || !id_card.trim)
				continue

			if(is_type_in_list(id_card.trim, job_trims))
				dept_eligible_cards++

		total_eligible_cards += dept_eligible_cards
		message_admins("[responding_dept] department: [dept_eligible_cards] eligible cards from living players")

		// Note: RETA grants access FROM calling_dept TO responding_dept personnel
		// So if Medical calls Security, Security personnel get Medical access
		if(reta_find_and_grant_access(responding_dept, calling_dept, duration MINUTES))
			successful_grants++
			granted_depts += responding_dept

	// Report results
	if(successful_grants > 0)
		message_admins("RETA access granted successfully: [english_list(granted_depts)] personnel now have [calling_dept] access. Total eligible cards: [total_eligible_cards]")

		// Send department announcement like the normal system
		var/caller_info = "(Called by CENTCOM)"

		// Send announcements to all successfully granted departments
		for(var/dept in granted_depts)
			switch(dept)
				if("Security")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_SECURITY), "Security")
				if("Engineering")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_ENGINEERING), "Engineering")
				if("Medical")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_MEDICAL), "Medical")
				if("Science")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_SCIENCE), "Science")
				if("Service")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_SERVICE), "Service")
				if("Command")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_COMMAND), "Command")
				if("Cargo")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_SUPPLY), "Cargo")
				if("Mining")
					aas_config_announce(/datum/aas_config_entry/rc_emergency, list("LOCATION" = calling_dept, "CALLER" = caller_info), null, list(RADIO_CHANNEL_SUPPLY), "Mining")

		// Send confirmation to the calling department about who has been given access
		var/grantee = english_list(granted_depts)
		var/list/target_channels = list()
		switch(calling_dept)
			if("Security")
				target_channels += RADIO_CHANNEL_SECURITY
			if("Engineering")
				target_channels += RADIO_CHANNEL_ENGINEERING
			if("Medical")
				target_channels += RADIO_CHANNEL_MEDICAL
			if("Science")
				target_channels += RADIO_CHANNEL_SCIENCE
			if("Service")
				target_channels += RADIO_CHANNEL_SERVICE
			if("Command")
				target_channels += RADIO_CHANNEL_COMMAND
			if("Cargo")
				target_channels += RADIO_CHANNEL_SUPPLY
			if("Mining")
				target_channels += RADIO_CHANNEL_SUPPLY

		aas_config_announce(/datum/aas_config_entry/rc_reta_announcement, list("GRANTEE" = grantee, "CALLER" = caller_info), null, target_channels)
	else
		message_admins("RETA access grant failed for all departments.")
