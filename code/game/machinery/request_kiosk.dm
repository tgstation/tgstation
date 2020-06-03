/**
  * A machine that acts basically like a quest board.
  * Enables crew to create requests, crew can sign up to perform the request, and the requester can chose who to pay-out.
  */
/obj/machinery/request_kiosk
	name = "request kiosk"
	desc = "Alows you to place requests for goods and services across the station, as well as pay those who actually did it."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "request_kiosk"
	ui_x = 601
	ui_y = 601
	light_color = LIGHT_COLOR_GREEN
	///Static, global list for containing request datums across all request kiosks.
	var/static/list/request_list
	///Static, global value so that each request has a universal value for what request number it is.
	var/static/request_number
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request

/obj/machinery/request_kiosk/Initialize()
	. = ..()
	if(!request_list)
		request_list = list()
		//The below is a test case, and will be removed for the final product.
		var/datum/station_request/testcase = new /datum/station_request("Pat Sajack", 100, "Ayo get me some coffee ya dig?", 1)
		request_list += testcase
	if(!request_number)
		request_number = 2

/obj/machinery/request_kiosk/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I,/obj/item/card/id))
		var/obj/item/card/id/current_card = I
		if(current_card.registered_account)
			current_user = current_card.registered_account
			return TRUE
		else
			to_chat(user, "There's no account assigned with this ID.")
			return TRUE
	if(istype(I, /obj/item/bounty_card))
		var/obj/item/bounty_card/curr_bounty = I
		var/datum/station_request/curr_request = curr_bounty.new_request
		if(!curr_request)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
			return
		curr_request.req_number = request_number
		request_list += list(curr_bounty.new_request)
		request_number++
		playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)
		qdel(I)

/obj/machinery/request_kiosk/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RequestKiosk", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/request_kiosk/ui_data(mob/user)
	var/list/data = list()
	var/list/formatted_requests = list()
	for(var/i in request_list)
		if(!i)
			continue
		var/datum/station_request/request = i
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "req_number" = request.req_number, "applicants" = request.applicants))
	if(current_user)
		data["AccountName"] = current_user.account_holder
	if(active_request)
		data["Applicants"] = active_request.applicants
	data["Requests"] = formatted_requests
	return data

/obj/machinery/request_kiosk/ui_act(action, list/params)
	if(..())
		return
	var/current_ref_num = params["request"]
	var/datum/bank_account/current_applicant = params["applicant"]
	say("[current_ref_num] is the current_ref_num")
	for(var/datum/station_request/i in request_list)
		say("[i.req_number] is the loop number.")
		if("[i.req_number]" == "[current_ref_num]") //Why do we not have a num2string function? Even MATLAB has a num2string! And matlab sucks!
			active_request = i
			say("Active Request set! The number is [active_request.req_number].")
			break
	switch(action)
		if("CreateBounty")
			say("Dispensing Card.")
			new /obj/item/bounty_card(loc)
			return TRUE
		if("Apply")
			if(!current_user)
				say("Please swipe your ID card first.")
				return TRUE
			if(current_user.account_holder == active_request.owner)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			active_request.applicants += list(list("name" = current_user.account_holder, "account" = current_user, "second_req_number" = active_request.req_number))
		if("PayApplicant")
			current_applicant.transfer_money(current_applicant, 15)
			say("Paid out [active_request.value] credits to someone.")
			return TRUE
		if("Clear")
			if(current_user)
				current_user = null
				say("Account Reset.")
				return TRUE
		if("DeleteRequest")
			if(active_request.owner != current_user.account_holder)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			say("Deleted Current Request.")
			request_list.Remove(active_request)
			return TRUE
	. = TRUE

/obj/item/bounty_card
	name = "bounty card"
	desc = "Can be filled out, then inserted into a request console to create a bounty."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "bountycard"
	w_class = WEIGHT_CLASS_TINY
	var/datum/station_request/new_request

/obj/item/bounty_card/attack_self(mob/user)
	if(new_request)
		to_chat(user, "<span class='warning'>[src] is already filled out.</span>")
		return
	var/description = input(user, "Please enter your request description.", "Request description") as message|null
	if(!description || !(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)))
		return
	description = sanitize(copytext_char(description, 1, MAX_MESSAGE_LEN))
	var/new_cost = input(user, "Set the cost for this request.","Bounty cost") as num|null
	if(!new_cost || !(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)))
		return
	new_cost = clamp(round(new_cost, 1), 0, 1000)
	new_request = new /datum/station_request(user.name, new_cost, description)
	icon_state = "bountycardfull"

/obj/item/bounty_card/examine(mob/user)
	. = ..()
	if(new_request)
		. += (new_request.description)
		. += ("The Price on this bounty is set for [new_request.value] credits.")

/datum/station_request
	///Name of the Request Owner.
	var/owner
	///Value of the request.
	var/value
	///Text description of the request to be shown within the UI.
	var/description
	///Internal number of the request for organizing.
	var/req_number
	///List of applicants who are attempting the task, contains account numbers for payout.
	var/list/applicants = list()

/datum/station_request/New(var/owned, var/newvalue, var/newdescription, var/reqnum, var/list/apps = list())
	. = ..()
	owner = owned
	value = newvalue
	description = newdescription
	req_number = reqnum
	applicants = apps
	if(!applicants)
		applicants = list()
