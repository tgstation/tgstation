/obj/machinery/computer/redemption
	name = "security redemption console"
	desc = "Used to manage rehabilitation efforts."
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/redemption
	light_color = COLOR_SOFT_RED


/obj/machinery/computer/redemption/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "RedemptionConsole", name)
		ui.open()


/obj/machinery/computer/redemption/ui_data(mob/user)
	var/list/data = list()

	data["total_points"] = DSsecurity.total_points
	data["available_points"] = DSsecurity.points_available
	data["total_prisoners"] = length(DSsecurity.criminals_apprehended)

	return data

