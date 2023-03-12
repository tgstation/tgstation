/datum/computer_file/program/nt_pay
	filename = "ntpay"
	filedesc = "Nanotrasen Pay System"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "generic"
	extended_desc = "An application that locally (in your sector) helps to transfer money or track your expenses and profits."
	size = 2
	tgui_id = "NtosPay"
	program_icon = "money-bill-wave"
	usage_flags = PROGRAM_ALL
	///Reference to the currently logged in user.
	var/datum/bank_account/current_user
	///Pay token, by which we can send credits
	var/token
	///Amount of credits, which we sends
	var/money_to_send = 0
	///Pay token what we want to find
	var/wanted_token

/datum/computer_file/program/nt_pay/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("Transaction")
			token = params["token"]
			money_to_send = params["amount"]
			var/datum/bank_account/recipient
			if(!token)
				return to_chat(usr, span_notice("You need to enter your transfer target's pay token."))
			if(!money_to_send)
				return to_chat(usr, span_notice("You need to specify how much you're sending."))
			if(token == current_user.pay_token)
				return to_chat(usr, span_notice("You can't send credits to yourself."))

			for(var/account as anything in SSeconomy.bank_accounts_by_id)
				var/datum/bank_account/acc = SSeconomy.bank_accounts_by_id[account]
				if(acc.pay_token == token)
					recipient = acc
					break

			if(!recipient)
				return to_chat(usr, span_notice("The app can't find who you're trying to pay. Did you enter the pay token right?"))
			if(!current_user.has_money(money_to_send) || money_to_send < 1)
				return current_user.bank_card_talk("You cannot afford it.")

			recipient.bank_card_talk("You received [money_to_send] credit(s). Reason: transfer from [current_user.account_holder]")
			recipient.transfer_money(current_user, money_to_send)
			current_user.bank_card_talk("You send [money_to_send] credit(s) to [recipient.account_holder]. Now you have [current_user.account_balance] credit(s)")

		if("GetPayToken")
			wanted_token = null
			for(var/account in SSeconomy.bank_accounts_by_id)
				var/datum/bank_account/acc = SSeconomy.bank_accounts_by_id[account]
				if(acc.account_holder == params["wanted_name"])
					wanted_token = "Token: [acc.pay_token]"
					break
			if(!wanted_token)
				return wanted_token = "Account \"[params["wanted_name"]]\" not found."



/datum/computer_file/program/nt_pay/ui_data(mob/user)
	var/list/data = list()

	current_user = computer.computer_id_slot?.registered_account || null
	if(!current_user)
		data["name"] = null
	else
		data["name"] = current_user.account_holder
		data["owner_token"] = current_user.pay_token
		data["money"] = current_user.account_balance
		data["wanted_token"] = wanted_token
		data["transaction_list"] = current_user.transaction_history

	return data
