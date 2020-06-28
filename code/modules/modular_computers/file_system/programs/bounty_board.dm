/datum/computer_file/program/bounty_board
	filename = "bountyboard"
	filedesc = "Bounty Board Request Network"
	program_icon_state = "bountyboard"
	extended_desc = "A multi-platform network for placing requests across the station, with payment across the network being possible.."
	requires_ntnet = TRUE
	network_destination = "bounty board interface"
	size = 10
	tgui_id = "NtosRequestKiosk"
	ui_x = 550
	ui_y = 600
	///Static, global value so that each request has a universal value for what request number it is.
	var/static/request_number
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request
	///Has the app been added to the network yet?
	var/networked = FALSE

/datum/computer_file/program/bounty_board/ui_data(mob/user)
	var/list/data = get_header_data()
	var/list/formatted_requests = list()
	var/list/formatted_applicants = list()
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	var/printer_text = "No Printer Detected."
	if(!networked)
		GLOB.allbountyboards += computer
		networked = TRUE
	if(card_slot && card_slot.stored_card && card_slot.stored_card.registered_account)
		current_user = card_slot.stored_card.registered_account
	if(printer)
		printer_text = "[printer.stored_paper]/[printer.max_paper]"
	for(var/i in GLOB.request_list)
		if(!i)
			continue
		var/datum/station_request/request = i
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "acc_number" = request.req_number))
		if(request.applicants)
			for(var/datum/bank_account/j in request.applicants)
				formatted_applicants += list(list("name" = j.account_holder, "request_id" = request.owner_account.account_id, "requestee_id" = j.account_id))
	if(current_user)
		data["AccountName"] = current_user.account_holder
	data["Requests"] = formatted_requests
	data["Applicants"] = formatted_applicants
	data["PrinterPaper"] = printer_text
	return data

/datum/computer_file/program/bounty_board/ui_act(action, list/params)
	if(..())
		return
	var/current_ref_num = params["request"]
	var/current_app_num = params["applicant"]
	var/datum/bank_account/request_target
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	for(var/datum/station_request/i in GLOB.request_list)
		if("[i.req_number]" == "[current_ref_num]")
			active_request = i
			break
	if(active_request)
		for(var/datum/bank_account/j in active_request.applicants)
			if("[j.account_id]" == "[current_app_num]")
				request_target = j
				break
	switch(action)
		if("CreateBounty")
			if(printer.stored_paper < 1)
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			computer.say("Dispensing Card.")
			new /obj/item/bounty_card(get_turf(computer))
			printer.stored_paper -= 1
			return TRUE
		if("Apply")
			if(!current_user)
				computer.say("Please swipe a valid ID first.")
				return TRUE
			if(current_user.account_holder == active_request.owner)
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			active_request.applicants += list(current_user)
		if("PayApplicant")
			if(!current_user)
				return
			if(!current_user.has_money(active_request.value) || (current_user.account_holder != active_request.owner))
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
				return
			request_target.transfer_money(current_user, active_request.value)
			computer.say("Paid out [active_request.value] credits.")
			return TRUE
		if("Clear")
			if(current_user)
				current_user = null
				computer.say("Account Reset.")
				return TRUE
		if("DeleteRequest")
			if(!current_user)
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			if(active_request.owner != current_user.account_holder)
				playsound(computer, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			computer.say("Deleted current request.")
			GLOB.request_list.Remove(active_request)
			return TRUE
	. = TRUE

/datum/computer_file/program/bounty_board/Destroy()
	GLOB.allbountyboards -= computer
	. = ..()
