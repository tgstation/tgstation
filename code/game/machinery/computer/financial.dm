/obj/machinery/computer/finances
	name = "Financial Computer"
	desc = "A computer used to manage the stations budget."
	icon_screen = "finances"
	icon_keyboard = "generic_key"
	req_access = list(ACCESS_FINANCE)
	circuit = /obj/item/circuitboard/computer/card/finances
	var/list/account_names = SSeconomy.department_accounts - list(ACCOUNT_CAR)
	var/list/account_shares = SSeconomy.department_share - list(ACCOUNT_CAR)
	var/list/departments = SSeconomy.departments - list(ACCOUNT_CAR)
	var/sum = 0.0

/obj/machinery/computer/finances/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	for(var/S in account_shares)
		sum += S * 100

/obj/machinery/computer/finances/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null,\
		 force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state )
	. = ..()
	ui = SStgui.try_update_ui(user, src, "login")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	if(!ui)
		ui = new(user, drc, ui_key, "financial", name, 300, 300, master_ui, state)
		ui.open()

/obj/machinery/computer/finances/ui_data()
	var/list/data = list()
	if(allowed(usr))
		data["authorized"] = TRUE
	else
		data["authorized"] = FALSE

	data["shares"] = list()
	for(var/A in departments)
		data["shares"] += list(
			"department" = A
			"name" = account_names[A]
			"share" = account_shares[A]
		)
	data["sum"] = sum

/obj/machinery/computer/finances/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	for(var/A in departments)
		if(action == A)
			var/newnum = input("Set the new budget:", "Budget", "0") as num|null
			newnum = newnum/100
			if(!SSeconomy.change_budget)
				return
			else
				SSeconomy.change_budget(A, newnum)




	




	
	
