/datum/computer_file/program/crew_manifest
	filename = "crewmani"
	filedesc = "Crew Manifest"
	program_icon_state = "id"
	extended_desc = "Program for viewing and printing the current crew manifest"
	transfer_access = ACCESS_HEADS
	requires_ntnet = FALSE
	size = 4
	tgui_id = "ntos_crew_manifest"
	ui_x = 400
	ui_y = 480

/datum/computer_file/program/crew_manifest/ui_static_data(mob/user)
	var/list/data = list()
	data["manifest"] = GLOB.data_core.get_manifest()
	return data

/datum/computer_file/program/crew_manifest/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/crew_manifest/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("PRG_print")
			if(computer && printer) //This option should never be called if there is no printer
				var/contents = {"<h4>Crew Manifest</h4>
								<br>
								[GLOB.data_core ? GLOB.data_core.get_manifest_html(0) : ""]
								"}
				if(!printer.print_text(contents,text("crew manifest ([])", station_time_timestamp())))
					to_chat(usr, "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>")
					return
				else
					computer.visible_message("<span class='notice'>\The [computer] prints out a paper.</span>")
