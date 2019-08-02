/**
The Financial computer is a system that allows the the changing of deparmental budgets with relative ease.area
It automaticall grabs the ID of the user when they open the UI and doesn't actually work if they are not authorized, 
otherwise it opens like a breeze.
*/
/obj/machinery/computer/finances
	name = "Financial Computer"
	desc = "A computer used to manage the stations budget."
	icon_screen = "finances"
	icon_keyboard = "generic_key"
	req_access = list(ACCESS_FINANCE)
	circuit = /obj/item/circuitboard/computer/card/finances
	var/list/account_names = list()
	var/list/departments = list()
	var/sum = 0.0

/obj/machinery/computer/finances/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	departments += SSeconomy.departments
	account_names += SSeconomy.department_accounts
	account_names -= list(ACCOUNT_CAR)
	departments -= list(ACCOUNT_CAR)

/obj/machinery/computer/finances/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null,\
		 force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state )
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui_key)
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	if(src.z > 6)
		to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
		return
	if(!ui)
		ui = new(user, src, ui_key, "financial", name, 300, 300, master_ui, state)
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
			"department" = A,
			"name" = account_names[A],
			"share" = SSeconomy.get_shares(A)*100
		)

/obj/machinery/computer/finances/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	for(var/A in departments)
		if(action == A)
			var/newnum = input("Set the new budget:", "Budget", "0") as num|null
			newnum = newnum/100
			if(!SSeconomy.change_budget(A, newnum))
				return
			else
				SSeconomy.change_budget(A, newnum)




	




	
	
