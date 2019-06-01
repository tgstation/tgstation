/datum/computer_file/program/contract_uplink
	filename = "contract uplink"
	filedesc = "Contract Uplink"
	program_icon_state = "hostile"
	extended_desc = "A standard, Syndicate issued system for handling important contracts while on the field."
	size = 10
	requires_ntnet = 0
	available_on_ntnet = 0
	unsendable = 1
	undeletable = 1
	tgui_id = "synd_contract"
	ui_style = "syndicate"
	ui_x = 600
	ui_y = 600
	var/error = ""

/datum/computer_file/program/contract_uplink/run_program(var/mob/living/user)
	. = ..(user)

/datum/computer_file/program/ntnet_dos/ui_act(action, params)
	if(..())
		return 1

	switch(action)
		if("PRG_contract-accept")
			var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]
			var/datum/antagonist/traitor/traitor_data = hard_drive.traitor_data
			
			// Set as the active contract
			traitor_data.assigned_contracts[params["contract_id"]].status = 2
			traitor_data.current_contract = traitor_data.assigned_contracts[params["contract_id"]]
		if("PRG_login")
			var/datum/antagonist/traitor/traitor_data = usr.mind.has_antag_datum(/datum/antagonist/traitor)
			var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]

			// Bake their data right into the hard drive, or we don't allow non-antags gaining access to unused 
			// contract system.
			if (traitor_data)
				hard_drive.traitor_data = traitor_data
			else 
				error = "Incorrect login details."
			
/datum/computer_file/program/contract_uplink/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]

	if (hard_drive && hard_drive.traitor_data != null)
		var/datum/antagonist/traitor/traitor_data = hard_drive.traitor_data

		error = ""
		data["logged_in"] = TRUE
		data = get_header_data()

		data["station_name"] = GLOB.station_name
		data["contracts"] = traitor_data.assigned_contracts
	else 
		data["logged_in"] = FALSE

	return data
