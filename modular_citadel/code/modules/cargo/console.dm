/obj/machinery/computer/cargo
	req_access = list(ACCESS_CARGO)
	
/obj/machinery/computer/cargo/request
	req_access = list()

/obj/machinery/computer/cargo/emag_act(mob/user)
	req_access = list()
	. = ..()

/obj/machinery/computer/cargo/ui_act(action, params, datum/tgui/ui)
	if(!allowed(usr))
		to_chat(usr, "<span class='notice'>Access denied.</span>")
		return
	. = ..()