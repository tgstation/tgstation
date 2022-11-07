/client/proc/fax_panel()
	set category = "Admin.Events"
	set name = "Fax Panel"

	admin_fax_panel()

/client/proc/admin_fax_panel()
	if(!check_rights(R_ADMIN))
		return

	var/datum/fax_panel_interface/ui = new(usr)
	ui.ui_interact(usr)

/// Panel
/datum/fax_panel_interface
	/// All faxes in game list
	var/available_faxes = list()
	/// List with available stamps
	var/stamp_list = list() // I need to understand, how to remove chameleon stamps...

	/// Paper which admin edit and send.
	var/obj/item/paper/fax_paper = new /obj/item/paper(null)

	/// Default name of fax. Used when field with fax name not edited.
	var/sending_fax_name = "Secret"
	/// Default name of paper. paper - bluh-bluh. Used when field with paper name not edited.
	var/default_paper_name = "Standart Report"

/datum/fax_panel_interface/New()
	//Get all faxes, and save them to our list.
	for(var/obj/machinery/fax/fax in GLOB.machines)
		available_faxes += fax
	//Get all stamps
	for(var/stamp in subtypesof(/obj/item/stamp))
		var/obj/item/stamp/real_stamp = stamp 
		if(length(initial(real_stamp.actions)) == 0)// try to remove chameleon, dont work.
			stamp_list += list(list(initial(real_stamp.name), initial(real_stamp.icon_state)))
	//Give our paper special status, to read everywhere.
	fax_paper.request_state = TRUE

//Maybe.. useless proc, but find fax like object what we need.
/datum/fax_panel_interface/proc/get_fax_by_name(name)
	if(!length(available_faxes))
		return

	for(var/obj/machinery/fax/potential_fax in available_faxes)
		if(potential_fax.fax_name == name)
			return potential_fax
	return

/datum/fax_panel_interface/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminFax")
		ui.open()

/datum/fax_panel_interface/ui_state(mob/user)
	return GLOB.admin_state

/datum/fax_panel_interface/ui_static_data(mob/user)
	var/list/data = list()
	data["faxes"] = list()
	data["stamps"] = list()
	for(var/stamp in stamp_list)
		data["stamps"] += list(stamp[1]) // send only names.
	for(var/obj/machinery/fax/another_fax in available_faxes)
		data["faxes"] += list(another_fax.fax_name)
	return data

/datum/fax_panel_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!check_rights(R_ADMIN))
		return
	
	var/obj/machinery/fax/action_fax // fax what we find later

	if(params["faxName"])
		action_fax = get_fax_by_name(params["faxName"]) // that is
	
	switch(action)

		if("jump") // jump on fax. maybe i shoul make follow action(?)
			var/turf/fax_turf = get_turf(action_fax)
			if(!fax_turf || !usr.client)
				return
			
			usr.client.jumptoturf(fax_turf)
		
		if("preview") // see saved variant
			if(!fax_paper)
				return
			
			fax_paper.ui_interact(usr)
		
		if("save") // save paper
			if(params["paperName"])
				default_paper_name = params["paperName"]
			if(params["fromWho"])
				sending_fax_name = params["fromWho"]
			
			fax_paper.ui_status(usr, UI_CLOSE) // i wannd reload, or close and open UI, but i dont know how. need help

			fax_paper.clear_paper()
			var/stamp 

			for(var/needed_stamp in stamp_list)
				if(needed_stamp[1] == params["stamp"])
					stamp = needed_stamp[2]
					break
			
			fax_paper.name = "paper — [default_paper_name]"
			fax_paper.add_raw_text(params["rawText"])

			if(stamp)
				fax_paper.add_stamp("paper121x54 [stamp]", params["stampX"], params["stampY"], params["stampR"], stamp)
			
		if("send")
			//copy
			var/obj/item/paper/our_fax = fax_paper.copy(/obj/item/paper, null, FALSE)
			our_fax.name = fax_paper.name
			//send
			action_fax.receive(our_fax, sending_fax_name)
			message_admins("[key_name_admin(usr)] has send custom fax message to [action_fax.name][ADMIN_FLW(action_fax)][ADMIN_SHOW_PAPER(fax_paper)].")
			log_admin("[key_name(usr)] has send custom fax message to [action_fax.name]")
		
		if("createPaper")

			var/obj/item/paper/our_paper = fax_paper.copy(/obj/item/paper, usr.loc, FALSE)
			our_paper.name = fax_paper.name
			
		

