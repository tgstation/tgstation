
/**
 * Handles simple payment operations where the cost of the object in question doesn't change.
 *
 * What this is useful for:
 * Basic forms of vending.
 * Objects that can drain the owner's money linearly.
 * What this is not useful for:
 * Things where the seller may want to fluxuate the price of the object.
 * Improving standardizing every form of payment handing, as some custom handling is specific to that object.
 **/
/datum/component/payment
	dupe_mode = COMPONENT_DUPE_UNIQUE ///NO OVERRIDING TO CHEESE BOUNTIES
	///Standardized of operation.
	var/cost = 10
	///Flavor style for handling cash (Friendly? Hostile? etc.)
	var/transaction_style = "Clinical"
	///Who's getting paid?
	var/datum/bank_account/target_acc
	///Does this payment component respect same-department-discount?
	var/department_discount = FALSE

/datum/component/payment/Initialize(_cost, _target, _style, _discount)
	target_acc = _target
	if(!target_acc)
		target_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	if(_discount)
		department_discount = _discount
	cost = _cost
	transaction_style = _style
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE, .proc/attempt_charge)
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE, .proc/change_cost)

/datum/component/payment/proc/attempt_charge(datum/source, atom/movable/target, extra_fees = 0)
	SIGNAL_HANDLER

	if(!cost && !extra_fees) //In case a free variant of anything is made it'll skip charging anyone.
		return
	if(!ismob(target))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/mob/living/user = target
	if(issilicon(user)) //They have evolved beyond the need for mere credits
		return
	var/obj/item/card/id/card
	if(istype(user))
		card = user.get_idcard(TRUE)
	if(!card)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("ID not detected, sorry [user]!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("WHERE IS YOUR GOD DAMN CARD! GOD DAMNIT!"))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID card not present. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE
	if(!card.registered_account)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("There's no account detected on your ID, how mysterious!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("ARE YOU JOKING. YOU DON'T HAVE A BANK ACCOUNT ON YOUR ID YOU IDIOT."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks a bank account. Aborting."))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/total_cost = cost + extra_fees
	if(department_discount)
		var/datum/job/our_job = card.registered_account.account_job
        if(our_job && SSeconomy.get_dep_account(our_job) == target_acc)
			total_cost = max(round(total_cost * DEPARTMENT_DISCOUNT), 1)

	if(!(card.registered_account.has_money(total_cost)))
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("I'm so sorry... You don't seem to have enough money."))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("YOU MORON. YOU ABSOLUTE BAFOON. YOU INSUFFERABLE TOOL. YOU ARE POOR."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks funds. Aborting."))
		user.balloon_alert(user, "Cost: [total_cost] credits.")
		return COMPONENT_OBJ_CANCEL_CHARGE
	target_acc.transfer_money(card.registered_account, total_cost)
	card.registered_account.bank_card_talk("[total_cost] credits deducted from your account.")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)

/datum/component/payment/proc/change_cost(datum/source, new_cost)
	SIGNAL_HANDLER

	if(!isnum(new_cost))
		CRASH("change_cost called with variable new_cost as not a number.")
	cost = new_cost
