/datum/computer_file/program/nt_pay
	tgui_id = "NtosPayVoidcrew"

	///The bank account swiped onto the tablet, saved here.
	var/obj/item/card/id/inserted_id

/datum/computer_file/program/nt_pay/application_attackby(obj/item/attacking_item, mob/living/user)
	if(isidcard(attacking_item))
		inserted_id = attacking_item

/datum/computer_file/program/nt_pay/ui_data(mob/user)
	var/list/data = ..()

	data["all_accounts"] = list()
	for(var/obj/item/card/id/cards as anything in current_user.bank_cards)
		data["all_accounts"] += list(list(
			"ref" = REF(cards),
			"name" = cards.name,
		))

	if(inserted_id)
		data["swiped_id"] = list(list(
			"ref" = REF(inserted_id),
			"account" = inserted_id,
		))

	return data

/datum/computer_file/program/nt_pay/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	switch(action)
		if("add_account")
			if(!inserted_id || (inserted_id.registered_account == computer.computer_id_slot.registered_account))
				return
			if(inserted_id.registered_account)
				//disconnect from old account
				inserted_id.registered_account.bank_cards -= src
			inserted_id.registered_account = computer.computer_id_slot.registered_account
			inserted_id.registered_account.bank_cards += src
		if("remove_account")
			var/obj/item/card/id/card = locate(params["removed_account"]) in computer.computer_id_slot.registered_account.bank_cards
			//don't remove yourself
			if(!card || (card == computer.computer_id_slot))
				return
			//only the captain can edit
			if(computer.computer_id_slot.assignment != computer.computer_id_slot.registered_account.account_job.title)
				return
			card.registered_account.bank_cards -= src
			card.clear_account()
