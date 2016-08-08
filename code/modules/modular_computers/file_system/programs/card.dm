/datum/computer_file/program/card_mod
	filename = "cardmod"
	filedesc = "ID card modification program"
	program_icon_state = "id"
	extended_desc = "Program for programming employee ID cards to access parts of the station."
	required_access = access_change_ids
	requires_ntnet = 0
	size = 8
	var/mod_mode = 1
	var/is_centcom = 0
	var/show_assignments = 0
	var/list/region_access = null
	var/list/head_subordinates = null
	var/target_dept = 0 //Which department this computer has access to. 0=all departments
	var/change_position_cooldown = 60
	//Jobs you cannot open new positions for
	var/list/blacklisted = list(
		"AI",
		"Assistant",
		"Cyborg",
		"Captain",
		"Head of Personnel",
		"Head of Security",
		"Chief Engineer",
		"Research Director",
		"Chief Medical Officer",
		"Chaplain")

	//The scaling factor of max total positions in relation to the total amount of people on board the station in %
	var/max_relative_positions = 30 //30%: Seems reasonable, limit of 6 @ 20 players

	//This is used to keep track of opened positions for jobs to allow instant closing
	//Assoc array: "JobName" = (int)<Opened Positions>
	var/list/opened_positions = list();


/datum/computer_file/program/card_mod/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)

		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)

		ui = new(user, src, ui_key, "identification_computer", "ID card modification program", 600, 700, state = state)
		ui.open()
		ui.set_autoupdate(state = 1)


/datum/computer_file/program/card_mod/proc/format_jobs(list/jobs)
	var/obj/item/weapon/card/id/id_card = computer.card_slot.stored_card
	var/list/formatted = list()
	for(var/job in jobs)
		formatted.Add(list(list(
			"display_name" = replacetext(job, "&nbsp", " "),
			"target_rank" = id_card && id_card.assignment ? id_card.assignment : "Unassigned",
			"job" = job)))

	return formatted

/datum/computer_file/program/card_mod/ui_act(action, params)
	if(..())
		return 1

	var/obj/item/weapon/card/id/user_id_card = null
	var/mob/user = usr

	if(ishuman(user))
		var/mob/living/carbon/human/h = user
		user_id_card = h.get_idcard()

	var/obj/item/weapon/card/id/id_card = computer.card_slot.stored_card
	switch(action)
		if("PRG_switchm")
			if(params["target"] == "mod")
				mod_mode = 1
			else if (params["target"] == "manifest")
				mod_mode = 0
		if("PRG_togglea")
			if(show_assignments)
				show_assignments = 0
			else
				show_assignments = 1
		if("PRG_print")
			if(computer && computer.nano_printer) //This option should never be called if there is no printer
				if(mod_mode)
					if(can_run(user, 1))
						var/contents = {"<h4>Access Report</h4>
									<u>Prepared By:</u> [user_id_card.registered_name ? user_id_card.registered_name : "Unknown"]<br>
									<u>For:</u> [id_card.registered_name ? id_card.registered_name : "Unregistered"]<br>
									<hr>
									<u>Assignment:</u> [id_card.assignment]<br>
									<u>Access:</u><br>
								"}

						var/known_access_rights = get_all_accesses()
						for(var/A in id_card.access)
							if(A in known_access_rights)
								contents += "  [get_access_desc(A)]"

						if(!computer.nano_printer.print_text(contents,"access report"))
							usr << "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>"
							return
						else
							computer.visible_message("<span class='notice'>\The [computer] prints out paper.</span>")
				else
					var/contents = {"<h4>Crew Manifest</h4>
									<br>
									[data_core ? data_core.get_manifest(0) : ""]
									"}
					if(!computer.nano_printer.print_text(contents,text("crew manifest ([])", worldtime2text())))
						usr << "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>"
						return
					else
						computer.visible_message("<span class='notice'>\The [computer] prints out paper.</span>")
		if("PRG_eject")
			if(computer && computer.card_slot)
				if(id_card)
					data_core.manifest_modify(id_card.registered_name, id_card.assignment)
				computer.proc_eject_id(user)
		if("PRG_terminate")
			if(computer && can_run(user, 1))
				id_card.assignment = "Terminated"
				remove_nt_access(id_card)

		if("PRG_edit")
			if(computer && can_run(user, 1))
				if(params["name"])
					var/temp_name = reject_bad_name(input("Enter name.", "Name", id_card.registered_name))
					if(temp_name)
						id_card.registered_name = temp_name
					else
						computer.visible_message("<span class='notice'>[computer] buzzes rudely.</span>")
				//else if(params["account"])
				//	var/account_num = text2num(input("Enter account number.", "Account", id_card.associated_account_number))
				//	id_card.associated_account_number = account_num
		if("PRG_assign")
			if(computer && can_run(user, 1) && id_card)
				var/t1 = params["assign_target"]
				if(t1 == "Custom")
					var/temp_t = reject_bad_text(input("Enter a custom job assignment.","Assignment", id_card.assignment), 45)
					//let custom jobs function as an impromptu alt title, mainly for sechuds
					if(temp_t)
						id_card.assignment = temp_t
				else
					var/list/access = list()
					if(is_centcom)
						access = get_centcom_access(t1)
					else
						var/datum/job/jobdatum
						for(var/jobtype in typesof(/datum/job))
							var/datum/job/J = new jobtype
							if(ckey(J.title) == ckey(t1))
								jobdatum = J
								break
						if(!jobdatum)
							usr << "<span class='warning'>No log exists for this job: [t1]</span>"
							return

						access = jobdatum.get_access()

					remove_nt_access(id_card)
					apply_access(id_card, access)
					id_card.assignment = t1

		if("PRG_access")
			if(params["allowed"] && computer && can_run(user, 1))
				var/access_type = text2num(params["access_target"])
				var/access_allowed = text2num(params["allowed"])
				world << "type [access_type]"
				world << "allow [access_allowed]"
				if(access_type in (is_centcom ? get_all_centcom_access() : get_all_accesses()))
					world << "yes"
					id_card.access -= access_type
					if(!access_allowed)
						world << "check"
						id_card.access += access_type
	if(id_card)
		id_card.name = text("[id_card.registered_name]'s ID Card ([id_card.assignment])")

	return 1

/datum/computer_file/program/card_mod/proc/remove_nt_access(var/obj/item/weapon/card/id/id_card)
	id_card.access -= get_all_accesses()

/datum/computer_file/program/card_mod/proc/apply_access(var/obj/item/weapon/card/id/id_card, var/list/accesses)
	id_card.access |= accesses

/datum/computer_file/program/card_mod/ui_data(mob/user)

	var/list/data = get_header_data()

	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["manifest"] = data_core ? data_core.get_manifest(0) : null
	data["assignments"] = show_assignments
	if(computer)
		data["have_id_slot"] = !!computer.card_slot
		data["have_printer"] = !!computer.nano_printer
		data["authenticated"] = can_run(user)
		if(!computer.card_slot)
			mod_mode = 0 //We can't modify IDs when there is no card reader
	else
		data["have_id_slot"] = 0
		data["have_printer"] = 0
		data["authenticated"] = 0
	data["mmode"] = mod_mode
	data["centcom_access"] = is_centcom

	if(computer && computer.card_slot)
		var/obj/item/weapon/card/id/id_card = computer.card_slot.stored_card
		data["has_id"] = !!id_card
		data["id_rank"] = id_card && id_card.assignment ? html_encode(id_card.assignment) : "Unassigned"
		data["id_owner"] = id_card && id_card.registered_name ? html_encode(id_card.registered_name) : "-----"
		data["id_name"] = id_card ? strip_html_simple(id_card.name) : "-----"


		data["engineering_jobs"] = format_jobs(engineering_positions)
		data["medical_jobs"] = format_jobs(medical_positions)
		data["science_jobs"] = format_jobs(science_positions)
		data["security_jobs"] = format_jobs(security_positions)
		data["cargo_jobs"] = format_jobs(supply_positions)
		data["civilian_jobs"] = format_jobs(supply_positions)
		data["centcom_jobs"] = format_jobs(get_all_centcom_jobs())

	if(computer.card_slot.stored_card)
		var/obj/item/weapon/card/id/id_card = computer.card_slot.stored_card
		if(is_centcom)
			var/list/all_centcom_access = list()
			for(var/access in get_all_centcom_access())
				all_centcom_access.Add(list(list(
					"desc" = replacetext(get_centcom_access_desc(access), "&nbsp", " "),
					"ref" = access,
					"allowed" = (access in id_card.access) ? 1 : 0)))
			data["all_centcom_access"] = all_centcom_access
		else
			var/list/regions = list()
			for(var/i = 1; i <= 7; i++)
				var/list/accesses = list()
				for(var/access in get_region_accesses(i))
					if (get_access_desc(access))
						accesses.Add(list(list(
							"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
							"ref" = access,
							"allowed" = (access in id_card.access) ? 1 : 0)))

				regions.Add(list(list(
					"name" = get_region_accesses_name(i),
					"accesses" = accesses)))
			data["regions"] = regions

	return data