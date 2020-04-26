/**
  * A machine that acts basically like a quest board.
  * Enables crew to create requests, crew can sign up to perform the request, and the requester can chose who to pay-out.
  */
/obj/machinery/request_kiosk
	name = "request kiosk"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to stasis beds within its line of sight for surgical tech advancement."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	circuit = /obj/item/circuitboard/machine/request_kiosk
	ui_x = 450
	ui_y = 450
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/request_kiosk/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "RequestKiosk", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/request_kiosk/ui_act(action, list/params)
	. = ..()

/obj/machinery/request_kiosk/ui_data(mob/user)
	. = ..()
