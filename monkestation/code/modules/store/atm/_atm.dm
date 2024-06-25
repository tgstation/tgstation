/obj/machinery/atm
	name = "ATM"
	desc = "You can withdraw or deposit Monkecoins in here, also acts as a terminal for flash sale items."

	density = FALSE
	active_power_usage = 0

	max_integrity = 10000

	pixel_y = 30

	icon = 'monkestation/icons/obj/machines/atm.dmi'
	icon_state = "atm"

	///the flash sale item if avaliable
	var/static/datum/store_item/flash_sale_datum
	///the current size of the lottery prize pool
	var/static/lottery_pool = 500
	///list of bank accounts playing the lottery with amount of tickets sold
	var/static/list/ticket_owners = list()
	///static variable to check if a lottery is running
	var/static/lottery_running = FALSE

/obj/machinery/atm/Initialize(mapload)
	. = ..()
	if(!lottery_running)
		lottery_running = TRUE
		addtimer(CALLBACK(src, PROC_REF(pull_lottery_winner)), 20 MINUTES)

/obj/machinery/atm/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	if(!user.client)
		return

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "ATM")
		ui.open()

/obj/machinery/atm/ui_data(mob/user)
	var/list/data = list()

	if(!user.client)
		return
	var/cash_balance = 0
	var/obj/item/user_id = user.get_item_by_slot(ITEM_SLOT_ID)
	if(user_id && istype(user_id, /obj/item/card/id))
		var/obj/item/card/id/id_card = user_id.GetID()
		cash_balance = id_card.registered_account.account_balance
	else
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			var/datum/bank_account/user_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
			cash_balance = user_account.account_balance

	data["meta_balance"] = user.client.prefs.metacoins
	data["cash_balance"] = cash_balance
	data["lottery_pool"] = lottery_pool
	return data

/obj/machinery/atm/ui_static_data(mob/user)
	var/list/data = list()

	var/flash_value = FALSE
	if(flash_sale_datum)
		flash_value = TRUE
		data["flash_sale_name"] = flash_sale_datum.name
		data["flash_sale_cost"] = flash_sale_datum.item_cost
		data["flash_sale_desc"] = flash_sale_datum.store_desc

	data["flash_sale_present"] = flash_value
	return data

/obj/machinery/atm/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("withdraw")
			attempt_withdraw()
			return TRUE
		if("withdraw_cash")
			withdraw_cash()
			return TRUE
		if("lottery_buy")
			buy_lottery()
			return TRUE
		if("buy_flash")
			buy_flash_sale()
			return TRUE
	return TRUE

/obj/machinery/atm/proc/pull_lottery_winner()
	if(length(ticket_owners))
		var/datum/bank_account/winning_account = pick_weight(ticket_owners)
		winning_account.account_balance += lottery_pool
		priority_announce("[winning_account.account_holder] has just won the station lottery winning a total of [lottery_pool] credits! The next lottery will begin in 20 minutes!", "Nanotrasen Gambling Society")
		lottery_pool = 0
	else
		priority_announce("No one has won the lottery with a prize pool of [lottery_pool] credits, the next lottery will happen in 20 minutes.", "Nanotrasen Gambling Society")
	lottery_pool += 500
	ticket_owners = list()
	lottery_running = FALSE
	if(!lottery_running)
		lottery_running = TRUE
		addtimer(CALLBACK(src, PROC_REF(pull_lottery_winner)), 20 MINUTES)

/obj/machinery/atm/proc/buy_lottery()
	if(!iscarbon(usr))
		return

	var/mob/living/carbon/carbon_user = usr
	var/obj/item/user_id = carbon_user.get_item_by_slot(ITEM_SLOT_ID)

	if(user_id)
		var/cash_balance = 0
		var/obj/item/card/id/id_card = user_id.GetID()
		cash_balance = id_card.registered_account.account_balance
		if(cash_balance < 100)
			return
		var/tickets_bought = tgui_input_number(carbon_user, "How many tickets would you like to buy?", "ATM", 0, round(cash_balance * 0.01), 0)

		if(!tickets_bought)
			return

		id_card.registered_account.account_balance -= tickets_bought * 100
		ticket_owners[id_card.registered_account] += tickets_bought
		lottery_pool += tickets_bought * 100

/obj/machinery/atm/proc/buy_flash_sale()
	if(!flash_sale_datum)
		return
	var/mob/living/living_user = usr
	if(flash_sale_datum.item_path in living_user.client.prefs.inventory)
		return
	if(flash_sale_datum.attempt_purchase(living_user.client))
		say("Item successfully purchased.")

/obj/machinery/atm/proc/attempt_withdraw()
	var/mob/living/living_user = usr
	var/current_balance = living_user.client.prefs.metacoins

	var/withdraw_amount = tgui_input_number(living_user, "How many Monkecoins would you like to withdraw?", "ATM", 0 , current_balance, 0)

	if(!withdraw_amount)
		return
	withdraw_amount = clamp(withdraw_amount, 0, current_balance)
	if(!living_user.client.prefs.adjust_metacoins(living_user.client.ckey, -withdraw_amount, donator_multipler = FALSE))
		return

	var/obj/item/stack/monkecoin/coin_stack = new(living_user.loc)
	coin_stack.amount = withdraw_amount
	coin_stack.update_desc()

	living_user.put_in_hands(coin_stack)



/obj/machinery/atm/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(do_after(user, 1 SECONDS, src))
		if(istype(attacking_item, /obj/item/stack/monkecoin))
			var/obj/item/stack/monkecoin/attacked_coins = attacking_item
			if(!user.client.prefs.adjust_metacoins(user.client.ckey, attacked_coins.amount, donator_multipler = FALSE))
				say("Error acceptings coins, please try again later.")
			qdel(attacked_coins)
			say("Coins deposited to your account, have a nice day.")

		if(attacking_item in subtypesof(/obj/item/stack/spacecash))
			var/obj/item/stack/spacecash/attacked_cash = attacking_item
			var/obj/item/user_id = user.get_item_by_slot(ITEM_SLOT_ID)
			if(user_id && istype(user_id, /obj/item/card/id))
				var/obj/item/card/id/id_card = user_id.GetID()
				id_card.registered_account.account_balance += attacked_cash.get_item_credit_value()
			else
				if(ishuman(user))
					var/mob/living/carbon/human/human_user = user
					var/datum/bank_account/user_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
					user_account.account_balance += attacked_cash.get_item_credit_value()
			qdel(attacked_cash)

		else if(istype(attacking_item, /obj/item/holochip))
			var/obj/item/holochip/attacked_chip = attacking_item
			var/obj/item/user_id = user.get_item_by_slot(ITEM_SLOT_ID)
			if(user_id && istype(user_id, /obj/item/card/id))
				var/obj/item/card/id/id_card = user_id.GetID()
				id_card.registered_account.account_balance += attacked_chip.credits
			else
				if(ishuman(user))
					var/mob/living/carbon/human/human_user = user
					var/datum/bank_account/user_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
					user_account.account_balance += attacked_chip.credits
			qdel(attacked_chip)

/obj/machinery/atm/proc/withdraw_cash()
	var/mob/living/living_mob = usr
	var/datum/bank_account/registed_account
	var/obj/item/user_id = living_mob.get_item_by_slot(ITEM_SLOT_ID)
	if(user_id && istype(user_id, /obj/item/card/id))
		var/obj/item/card/id/id_card = user_id.GetID()
		registed_account = id_card.registered_account
	else
		if(ishuman(living_mob))
			var/mob/living/carbon/human/human_user = living_mob
			registed_account = human_user.get_bank_account()

	if(!registed_account)
		return

	var/withdrawn_amount = tgui_input_number(living_mob, "How much cash would you like to withdraw?", "ATM", 0, registed_account.account_balance, 0)
	if(!withdrawn_amount)
		return
	withdrawn_amount = clamp(withdrawn_amount, 0, registed_account.account_balance)
	registed_account.account_balance -= withdrawn_amount
	var/obj/item/stack/spacecash/c1/stack_of_cash = new(living_mob.loc)
	stack_of_cash.amount = withdrawn_amount
	living_mob.put_in_hands(stack_of_cash)


/obj/item/stack/monkecoin
	name = "monkecoin"
	singular_name = "monkecoin"
	icon = 'monkestation/icons/obj/monkecoin.dmi'
	icon_state = "monkecoin"
	amount = 1
	max_amount = INFINITY
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	merge_type = /obj/item/stack/monkecoin
	var/value = 100

/obj/item/stack/monkecoin/Initialize(mapload, new_amount, merge = FALSE, list/mat_override=null, mat_amt=1)
	. = ..()
	update_desc()

/obj/item/stack/monkecoin/update_desc()
	. = ..()
	var/total_worth = get_item_credit_value()
	desc = "Monkecoin, it's the backbone of the economy. "
	desc += "It's worth [total_worth] credit[(total_worth > 1) ? "s" : null] in total."
	update_icon_state()

/obj/item/stack/monkecoin/get_item_credit_value()
	return (amount*value)

/obj/item/stack/monkecoin/merge(obj/item/stack/S)
	. = ..()
	update_desc()

/obj/item/stack/monkecoin/use(used, transfer = FALSE, check = TRUE)
	. = ..()
	update_desc()

/obj/item/stack/monkecoin/update_icon_state()
	. = ..()
	var/coinpress = copytext("[amount]",1,2)
	switch(amount)
		if(1 to 9)
			icon_state = "[initial(icon_state)][coinpress]"
		if(10 to 99)
			icon_state = "[initial(icon_state)][coinpress]0"
		if(100 to 999)
			icon_state = "[initial(icon_state)][coinpress]00"
		if(1000 to 8999)
			icon_state = "[initial(icon_state)][coinpress]000"
		if(9000 to INFINITY)
			icon_state = "[initial(icon_state)]9000"

/obj/item/stack/monkecoin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to gouge [user.p_their()] eyes with the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.emote("scream")
	if(do_after(user, 5 SECONDS, src))
		return BRUTELOSS
	else
		user.visible_message(span_suicide("[user] puts the [src] down away from [user.p_their()] eyes."))
