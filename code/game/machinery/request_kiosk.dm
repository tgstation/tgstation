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
	var/static/list/request_list
	var/request_amount = 0
	var/datum/bank_account/current_user

/obj/machinery/request_kiosk/Initialize()
	. = ..()
	if(!request_list)
		request_list = list()
		request_list += list("owner" = "Pat Sajack", "value" = 100, "description" = "Ayo get me some fuckin coffee ya dig?", "applicants" = list())

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
		if(!curr_bounty.bounty_price)
			return
		request_list += list("owner" = user.name, "value" = curr_bounty.bounty_price, "", "description" = curr_bounty.bounty_desc, "applicants" = list())

/obj/machinery/request_kiosk/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RequestKiosk", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/request_kiosk/ui_data(mob/user)
	var/list/data = list()
	if(current_user)
		data["AccountName"] = current_user.account_holder
	data["Requests"] = request_list
	return data

/obj/machinery/request_kiosk/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("ApplyRequest")
			say("Applied for a request.")
		if("CreateBounty")
			say("Dispensing Card.")
			new /obj/item/bounty_card(loc)
		if("PayApplicant")
			say("Paid out [request_amount] credits to someone.")
		if("Clear")
			if(current_user)
				current_user = null
				say("Account Reset.")
		if("DeleteRequest")
			say("Deleted Current Request.")
		if("amount")
			var/input = text2num(params["amount"])
			if(input)
				request_amount = input

/obj/item/bounty_card
	name = "bounty card"
	desc = "Can be filled out, then inserted into a request console to create a bounty."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "bountycard"
	w_class = WEIGHT_CLASS_TINY
	var/bounty_desc
	var/bounty_price

/obj/item/bounty_card/attack_self(mob/user)
	var/description = input(user, "Please enter your request description.", "Request description") as message|null
	if(!description || !(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)))
		return
	description = sanitize(copytext_char(description, 1, MAX_MESSAGE_LEN))
	var/new_cost = input(user, "Set the cost for this request.","Bounty cost") as num|null
	if(!new_cost || !(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)))
		return
	new_cost = clamp(round(new_cost, 1), 10, 1000)
	bounty_desc = description
	bounty_price = new_cost
	icon_state = "bountycardfull"

/obj/item/bounty_card/examine(mob/user)
	. = ..()
	if(bounty_desc && bounty_price)
		. += (bounty_desc)
		. += ("The Price on this bounty is set for [bounty_price] credits.")
