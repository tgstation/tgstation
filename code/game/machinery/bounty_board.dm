GLOBAL_LIST_EMPTY(allbountyboards)
GLOBAL_LIST_EMPTY(request_list)
/**
 * A machine that acts basically like a quest board.
 * Enables crew to create requests, crew can sign up to perform the request, and the requester can chose who to pay-out.
 */
/obj/machinery/bounty_board
	name = "bounty board"
	desc = "Allows you to place requests for goods and services across the station, as well as pay those who actually did it."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "request_kiosk"
	light_color = LIGHT_COLOR_GREEN
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///The station request datum being affected by UI actions.
	var/datum/station_request/active_request
	///Value of the currently bounty input
	var/bounty_value = 1
	///Text of the currently written bounty
	var/bounty_text = ""

/obj/machinery/bounty_board/Initialize(mapload, ndir, building)
	. = ..()
	GLOB.allbountyboards += src
	if(building)
		setDir(ndir)
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -32 : 32)
		pixel_y = (dir & 3)? (dir ==1 ? -32 : 32) : 0

/obj/machinery/bounty_board/Destroy()
	GLOB.allbountyboards -= src
	. = ..()

/obj/machinery/bounty_board/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I,/obj/item/card/id))
		var/obj/item/card/id/current_card = I
		if(current_card.registered_account)
			current_user = current_card.registered_account
			return TRUE
		to_chat(user, "There's no account assigned with this ID.")
		return TRUE
	if(I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, "<span class='notice'>You start [anchored ? "un" : ""]securing [name]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 30))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
			if(machine_stat & BROKEN)
				to_chat(user, "<span class='warning'>The broken remains of [src] fall on the ground.</span>")
				new /obj/item/stack/sheet/iron(loc, 3)
				new /obj/item/shard(loc)
			else
				to_chat(user, "<span class='notice'>You [anchored ? "un" : ""]secure [name].</span>")
				new /obj/item/wallframe/bounty_board(loc)
			qdel(src)

/obj/machinery/bounty_board/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestKiosk", name)
		ui.open()

/obj/machinery/bounty_board/ui_data(mob/user)
	var/list/data = list()
	var/list/formatted_requests = list()
	var/list/formatted_applicants = list()
	for(var/i in GLOB.request_list)
		if(!i)
			continue
		var/datum/station_request/request = i
		formatted_requests += list(list("owner" = request.owner, "value" = request.value, "description" = request.description, "acc_number" = request.req_number))
		if(request.applicants)
			for(var/datum/bank_account/j in request.applicants)
				formatted_applicants += list(list("name" = j.account_holder, "request_id" = request.owner_account.account_id, "requestee_id" = j.account_id))
	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/L = user
		id_card = L.get_idcard()
	if(id_card?.registered_account)
		current_user = id_card.registered_account
	if(current_user)
		data["accountName"] = current_user.account_holder
	data["requests"] = formatted_requests
	data["applicants"] = formatted_applicants
	data["bountyValue"] = bounty_value
	data["bountyText"] = bounty_text
	return data

/obj/machinery/bounty_board/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/current_ref_num = params["request"]
	var/current_app_num = params["applicant"]
	var/datum/bank_account/request_target
	if(current_ref_num)
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
		if("createBounty")
			if(!current_user || !bounty_text)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			for(var/datum/station_request/i in GLOB.request_list)
				if("[i.req_number]" == "[current_user.account_id]")
					say("Account already has active bounty.")
					return
			var/datum/station_request/curr_request = new /datum/station_request(current_user.account_holder, bounty_value,bounty_text,current_user.account_id, current_user)
			GLOB.request_list += list(curr_request)
			for(var/obj/i in GLOB.allbountyboards)
				i.say("New bounty has been added!")
				playsound(i.loc, 'sound/effects/cashregister.ogg', 30, TRUE)
		if("apply")
			if(!current_user)
				say("Please swipe a valid ID first.")
				return TRUE
			if(current_user.account_holder == active_request.owner)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			active_request.applicants += list(current_user)
		if("payApplicant")
			if(!current_user)
				return
			if(!current_user.has_money(active_request.value) || (current_user.account_holder != active_request.owner))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
				return
			request_target.transfer_money(current_user, active_request.value)
			say("Paid out [active_request.value] credits.")
			return TRUE
		if("clear")
			if(current_user)
				current_user = null
				say("Account Reset.")
				return TRUE
		if("deleteRequest")
			if(!active_request || !current_user)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return FALSE
			if(active_request?.owner != current_user?.account_holder)
				playsound(src, 'sound/machines/buzz-sigh.ogg', 20, TRUE)
				return TRUE
			say("Deleted current request.")
			GLOB.request_list.Remove(active_request)
			return TRUE
		if("bountyVal")
			bounty_value = text2num(params["bountyval"])
			if(!bounty_value)
				bounty_value = 1
		if("bountyText")
			bounty_text = (params["bountytext"])
	. = TRUE

/obj/item/wallframe/bounty_board
	name = "disassembled bounty board"
	desc = "Used to build a new bounty board, just secure to the wall."
	icon_state = "request_kiosk"
	custom_materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/bounty_board

/**
 * A combined all in one datum that stores everything about the request, the requester's account, as well as the requestee's account
 * All of this is passed to the Request Console UI in order to present in organized way.
 */
/datum/station_request
	///Name of the Request Owner.
	var/owner
	///Value of the request.
	var/value
	///Text description of the request to be shown within the UI.
	var/description
	///Internal number of the request for organizing. Id card number.
	var/req_number
	///The account of the request owner.
	var/datum/bank_account/owner_account
	///the account of the request fulfiller.
	var/list/applicants = list()

/datum/station_request/New(owned, newvalue, newdescription, reqnum, own_account)
	. = ..()
	owner = owned
	value = newvalue
	description = newdescription
	req_number = reqnum
	if(istype(own_account, /datum/bank_account))
		owner_account = own_account
