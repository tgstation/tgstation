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

/obj/machinery/request_kiosk/Initialize()
	. = ..()
	if(!request_list)
		request_list = list()

/obj/machinery/request_kiosk/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RequestKiosk", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/request_kiosk/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("ApplyRequest")
			say("Applied for a request.")
		if("CreateRequest")
			say("Request Created")
		if("PayApplicant")
			say("Paid out [request_amount] credits to someone.")
		if("DeleteRequest")
			say("Deleted Current Request.")
		if("amount")
			var/input = text2num(params["amount"])
			if(input)
				request_amount = input


/obj/machinery/request_kiosk/ui_data(mob/user)
	var/list/data = list()
	return data
