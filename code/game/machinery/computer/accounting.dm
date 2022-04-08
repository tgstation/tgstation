/obj/machinery/computer/accounting
	name = "employee accounting console"
	desc = "Used to view crewmember accounts and purchases."
	icon_screen = "security"
	icon_keyboard = "security_key"
	circuit = null
	light_color = COLOR_SOFT_green

/obj/machinery/computer/communications/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AccountingConsole")
		ui.open()

/obj/machinery/computer/accounting/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/player_accounts = list()

	for(var/current_account as anything in SSeconomy.bank_accounts_by_id)

	return data

/obj/machinery/computer/communications/ui_act(action, list/params)
	. = ..()



