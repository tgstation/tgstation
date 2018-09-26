/obj/machinery/computer/accounting
	name = "station accounting console"
	desc = "You can use this to manage the distribution of credits on the station's departments."
	icon_screen = "money"
	icon_keyboard = "money_key"
	req_access = list(ACCESS_HOP)
	circuit = /obj/item/circuitboard/computer/accounting
	var/obj/item/card/id/id = null
	light_color = LIGHT_COLOR_BLUE
	
/obj/machinery/computer/accounting/examine(mob/user)
	..()
	if(id)
		to_chat(user, "<span class='notice'>Alt-click to eject the ID card.</span>")
		
/obj/machinery/computer/accounting/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || !is_operational())
		return
	if(id)
		eject_id(user)
		
/obj/machinery/computer/accounting/proc/eject_id(mob/user)
	if(id)
		id.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(id)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		id = null
		
/obj/machinery/computer/accounting/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/idcard = O
		if(check_access(idcard))
			if(!id)
				if(!user.transferItemToLoc(idcard,src))
					return
				id = idcard
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else
		return ..()
		
/obj/machinery/computer/accounting/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
									datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "accounting", name, 450, 300, master_ui, state)
		ui.open()

/obj/machinery/computer/accounting/ui_data(mob/user)
	var/list/data = list()

	data["has_id"] = !isnull(id)
	data["id_name"] = id.name
	
	data["station_budget"] = SSeconomy.station_budget.account_balance
	data["dep_budgets"] = list()
	for(var/X in SSeconomy.generated_accounts)
		var/datum/bank_account/department/D = X
		var/dep_budget = list()
		dep_budget["department"] = D.account_holder
		dep_budget["balance"] = D.account_balance
		dep_budget["distribution"] = SSeconomy.income_distribution[D]

	return data

/obj/machinery/computer/accounting/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear")
			var/zone = params["zone"]
			if(zone in priority_alarms)
				to_chat(usr, "Priority alarm for [zone] cleared.")
				priority_alarms -= zone
				. = TRUE
			if(zone in minor_alarms)
				to_chat(usr, "Minor alarm for [zone] cleared.")
				minor_alarms -= zone
				. = TRUE
	update_icon()