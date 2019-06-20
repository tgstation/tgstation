/datum/computer_file/program/contract_uplink
	filename = "contract uplink"
	filedesc = "Syndicate Contract Uplink"
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

/datum/computer_file/program/contract_uplink/ui_act(action, params)
	if(..())
		return 1

	var/mob/living/user = usr
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]

	switch(action)
		if("PRG_contract-accept")
			var/contract_id = text2num(params["contract_id"])

			// Set as the active contract
			hard_drive.traitor_data.assigned_contracts[contract_id].status = CONTRACT_STATUS_ACTIVE
			hard_drive.traitor_data.current_contract = hard_drive.traitor_data.assigned_contracts[contract_id]
			return 1
		if("PRG_login")
			var/datum/antagonist/traitor/traitor_data = user.mind.has_antag_datum(/datum/antagonist/traitor)

			// Bake their data right into the hard drive, or we don't allow non-antags gaining access to unused
			// contract system.
			// We also create their contracts at this point.
			if (traitor_data)
				// We don't give them more contracts if they somehow assign themselves to a new uplink.
				if (!traitor_data.assigned_contracts.len)
					traitor_data.create_contracts()
				hard_drive.traitor_data = traitor_data
			else
				error = "Incorrect login details."
			return 1
		if("PRG_call_extraction")
			if (hard_drive.traitor_data.current_contract.status != CONTRACT_STATUS_EXTRACTING)
				if (hard_drive.traitor_data.current_contract.handle_extraction(user))
					user.playsound_local(user, 'sound/effects/confirmdropoff.ogg', 100, 1)
					hard_drive.traitor_data.current_contract.status = CONTRACT_STATUS_EXTRACTING
				else
					user.playsound_local(user, 'sound/machines/uplinkerror.ogg', 50)
			else 
				user.playsound_local(user, 'sound/machines/uplinkerror.ogg', 50)
			
			return 1
		if("PRG_contract_abort")
			var/contract_id = hard_drive.traitor_data.current_contract.id

			hard_drive.traitor_data.current_contract = null
			hard_drive.traitor_data.assigned_contracts[contract_id].status = CONTRACT_STATUS_ABORTED

			return 1
		if("PRG_redeem_TC")
			if (hard_drive.traitor_data.contract_TC_to_redeem)
				var/obj/item/stack/telecrystal/crystals = new /obj/item/stack/telecrystal(get_turf(user), 
															hard_drive.traitor_data.contract_TC_to_redeem)
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(H.put_in_hands(crystals))
						to_chat(H, "<span class='notice'>Your payment materializes into your hands!</span>")
					else
						to_chat(user, "<span class='notice'>Your payment materializes onto the floor.</span>")

				hard_drive.traitor_data.contract_TC_payed_out += hard_drive.traitor_data.contract_TC_to_redeem
				hard_drive.traitor_data.contract_TC_to_redeem = 0
				return 1
			else
				user.playsound_local(user, 'sound/machines/uplinkerror.ogg', 50)
			return 1


/datum/computer_file/program/contract_uplink/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/computer_hardware/hard_drive/small/syndicate/hard_drive = computer.all_components[MC_HDD]

	if (hard_drive && hard_drive.traitor_data != null)
		var/datum/antagonist/traitor/traitor_data = hard_drive.traitor_data

		error = ""
		data = get_header_data()

		if (traitor_data.current_contract)
			data["ongoing_contract"] = TRUE
			if (traitor_data.current_contract.status == CONTRACT_STATUS_EXTRACTING)
				data["extraction_enroute"] = TRUE

		data["logged_in"] = TRUE
		data["station_name"] = GLOB.station_name
		data["redeemable_tc"] = traitor_data.contract_TC_to_redeem

		for (var/datum/syndicate_contract/contract in traitor_data.assigned_contracts)
			data["contracts"] += list(list(
				"target" = contract.contract.target,
				"payout" = contract.contract.payout,
				"payout_bonus" = contract.contract.payout_bonus,
				"dropoff" = contract.contract.dropoff,
				"id" = contract.id,
				"status" = contract.status
			))

		var/direction
		if (traitor_data.current_contract)
			var/turf/curr = get_turf(user)
			var/turf/dropoff_turf 
			data["current_location"] = "[get_area_name(curr, TRUE)]"
			
			for (var/turf/content in traitor_data.current_contract.contract.dropoff.contents)
				if (isturf(content))
					dropoff_turf = content
					break

			if(curr.z == dropoff_turf.z) //Direction calculations for same z-level only
				direction = uppertext(dir2text(get_dir(curr, dropoff_turf))) //Direction text (East, etc). Not as precise, but still helpful.
				if(get_area(user) == traitor_data.current_contract.contract.dropoff)
					direction = "LOCATION CONFIRMED"
			else
				direction = "???"

			data["dropoff_direction"] = direction
	else
		data["error"] = error
		data["logged_in"] = FALSE
	return data
