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
	data["is_captain"] = (ACCESS_CAPTAIN in id.GetAccess())
	data["station_budget"] = SSeconomy.station_budget.account_balance
	data["station_tax"] = SSeconomy.income_distribution[SSeconomy.station_budget.department_id]
	data["last_income"] = SSeconomy.last_income
	data["dep_budgets"] = list()
	for(var/X in SSeconomy.generated_accounts)
		var/datum/bank_account/department/D = X
		var/dep_budget = list()
		dep_budget["department"] = D.account_holder
		dep_budget["dep_id"] = D.department_id
		dep_budget["balance"] = D.account_balance
		dep_budget["distribution"] = SSeconomy.income_distribution[D.department_id]

	return data

/obj/machinery/computer/accounting/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject_id")
			eject_id(usr)
			. = TRUE
		if("change_distribution")
			var/dep_id = params["target_dep"]
			var/new_value = input("Choose a distribution percentage (0-100):", name, null) as null|num
			if(!isnull(new_value))
				var/prev_value = SSeconomy.income_distribution(dep_id)
				if(SSeconomy.change_distribution(SSeconomy.get_dep_account(dep_id), new_value))
					message_admins("[ADMIN_LOOKUPFLW(usr)] set the distribution percentage for the [SSeconomy.department_accounts[dep_id]]) from [prev_value] to [new_value].")
					log_game("[key_name(usr)] set the distribution percentage for the [SSeconomy.department_accounts[dep_id]]) from [prev_value] to [new_value].")
					to_chat(usr, "<span class='notice'>Distribution modified successfully.</span>")
				else
					to_chat(usr, "<span class='warning'>Error: Distribution percentage higher than available percentage.</span>")
		if("transfer_credits")
			var/dep_id = params["target_dep"]
			var/giving = text2num(params["giving"]) //TRUE: giving, FALSE: taking
			var/all = text2num(params["all"]) //if TRUE, just transfers all credits
			var/datum/bank_account/department/station/station_budget = SSeconomy.station_budget
			var/datum/bank_account/department/target_budget = SSeconomy.get_dep_account(dep_id)
			var/transfer
			if(!all)
				transfer = input("Choose the amount of credits to transfer:", name, null) as null|num
				if(isnull(transfer))
					return TRUE	
			else
				if(alert("Are you sure you want to transfer the full budget [giving ? "to" : "from"] the department?","Are you sure","Yes","No") == "No")
					return TRUE
				if(giving)
					transfer = station_budget.account_balance
				else if(!(ACCESS_CAPTAIN in id.GetAccess())) //only captains can take
					return TRUE
				else
					transfer = target_budget.account_balance
			
			if(giving)
				if(station_budget.adjust_money(-transfer))
					target_budget.adjust_money(transfer)
					message_admins("[ADMIN_LOOKUPFLW(usr)] transferred [transfer] credits from the station budget to [target_budget.account_holder].")
					log_game("[key_name(usr)] transferred [transfer] credits from the station budget to [target_budget.account_holder].")
					to_chat(usr, "<span class='notice'>Transfer completed successfully.</span>")
				else
					to_chat(usr, "<span class='warning'>Error: Not enough funds in station budget.</span>")
			else
				if(target_budget.adjust_money(-transfer))
					station_budget.adjust_money(transfer)
					message_admins("[ADMIN_LOOKUPFLW(usr)] transferred [transfer] credits from the [target_budget.account_holder] to the station budget.")
					log_game("[key_name(usr)] transferred [transfer] credits from the [target_budget.account_holder] to the station budget.")
					to_chat(usr, "<span class='notice'>Transfer completed successfully.</span>")
				else
					to_chat(usr, "<span class='warning'>Error: Not enough funds in department budget.</span>")

