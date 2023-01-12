
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
	///A static typecache of all the money-based items that can be actively used as currency.
	var/static/list/allowed_money = typecacheof(list(
		/obj/item/stack/spacecash,
		/obj/item/holochip,
		/obj/item/coin))

/datum/component/payment/Initialize(_cost, _target, _style)
	target_acc = _target
	if(!target_acc)
		target_acc = SSeconomy.get_dep_account(ACCOUNT_CIV)
	cost = _cost
	transaction_style = _style

/datum/component/payment/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE, PROC_REF(attempt_charge))
	RegisterSignal(parent, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE, PROC_REF(change_cost))
	RegisterSignal(SSdcs, COMSIG_GLOB_REVOLUTION_VICTORY, PROC_REF(clean_up))

/datum/component/payment/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_OBJ_ATTEMPT_CHARGE, COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE))
	UnregisterSignal(SSdcs, COMSIG_GLOB_REVOLUTION_VICTORY)

/datum/component/payment/proc/attempt_charge(datum/source, atom/movable/target, extra_fees = 0)
	SIGNAL_HANDLER
	if(!cost && !extra_fees) //In case a free variant of anything is made it'll skip charging anyone.
		return
	var/total_cost = cost + extra_fees
	if(!ismob(target))
		return COMPONENT_OBJ_CANCEL_CHARGE
	var/mob/living/user = target
	if(issilicon(user) || isdrone(user) || isAdminGhostAI(user)) //They have evolved beyond the need for mere credits
		return
	var/obj/item/card/id/card
	if(istype(user))
		card = user.get_idcard(TRUE)
	if(!card && istype(user.pulling, /obj/item/card/id))
		card = user.pulling
	if(handle_card(user, card, total_cost))
		return //Only breaks here if the card can handle the cost of purchasing with someone's ID.
	if(handle_cardless(user, total_cost)) //Here we attempt to handle the purchase physically, with held money first. Otherwise we default to below.
		return
	return COMPONENT_OBJ_CANCEL_CHARGE

/**
 * Proc that changes the base cost of the interaction.
 *
 * * source: Datum source of the thing changing the cost.
 * * new_cost: the int value of the attempted new_cost to replace the cost value.
 */
/datum/component/payment/proc/change_cost(datum/source, new_cost)
	SIGNAL_HANDLER

	if(!isnum(new_cost))
		CRASH("change_cost called with variable new_cost as not a number.")
	cost = new_cost

/**
 * Attempts to charge the mob, user, an integer number of credits, total_cost, without the use of an ID card to directly draw upon.
 */
/datum/component/payment/proc/handle_cardless(mob/living/user, total_cost)
	//Here is all the possible non-ID payment methods.
	var/list/counted_money = list()
	var/physical_cash_total = 0
	for(var/obj/item/credit in typecache_filter_list(user.get_all_contents(), allowed_money)) //Coins, cash, and credits.
		if(physical_cash_total > total_cost)
			break
		physical_cash_total += credit.get_item_credit_value()
		counted_money += credit

	if(is_type_in_typecache(user.pulling, allowed_money) && (physical_cash_total < total_cost)) //Coins(Pulled).
		var/obj/item/counted_credit = user.pulling
		physical_cash_total += counted_credit.get_item_credit_value()
		counted_money += counted_credit

	if(physical_cash_total < total_cost)
		var/armless //Suggestions for those with no arms/simple animals.
		if(!ishuman(user) && !isslime(user))
			armless = TRUE
		else
			var/mob/living/carbon/human/harmless_armless = user
			if(!harmless_armless.get_bodypart(BODY_ZONE_L_ARM) && !harmless_armless.get_bodypart(BODY_ZONE_R_ARM))
				armless = TRUE

		if(armless)
			if(!user.pulling || !iscash(user.pulling) && !istype(user.pulling, /obj/item/card/id))
				to_chat(user, span_notice("Try pulling a valid ID, space cash, holochip or coin while using \the [parent]!"))
				return FALSE
		return FALSE

	if(physical_cash_total < total_cost)
		to_chat(user, span_notice("Insufficient funds. Aborting."))
		return FALSE
	for(var/obj/cash_object in counted_money)
		qdel(cash_object)
	physical_cash_total -= total_cost

	if(physical_cash_total > 0)
		var/obj/item/holochip/holochange = new /obj/item/holochip(user.loc) //Change is made in holocredits exclusively.
		holochange.credits = physical_cash_total
		holochange.name = "[holochange.credits] credit holochip"
		if(ishuman(user))
			var/mob/living/carbon/human/paying_customer = user
			if(!INVOKE_ASYNC(paying_customer, TYPE_PROC_REF(/mob, put_in_hands), holochange))
				user.pulling = holochange
		else
			user.pulling = holochange
	log_econ("[total_cost] credits were spent on [parent] by [user].")
	to_chat(user, span_notice("Purchase completed with held credits."))
	playsound(user, 'sound/effects/cashregister.ogg', 20, TRUE)
	return TRUE

/**
 * Attempts to charge a mob, user, an integer number of credits, total_cost, directly from an ID card/bank account.
 */
/datum/component/payment/proc/handle_card(mob/living/user, obj/item/card/id/idcard, total_cost)
	var/atom/atom_parent = parent

	if(!idcard)
		return FALSE
	if(!idcard?.registered_account)
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("There's no account detected on your ID, how mysterious!"))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("ARE YOU JOKING. YOU DON'T HAVE A BANK ACCOUNT ON YOUR ID YOU IDIOT."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks a bank account. Advancing."))
		return FALSE

	if(!(idcard.registered_account.has_money(total_cost)))
		switch(transaction_style)
			if(PAYMENT_FRIENDLY)
				to_chat(user, span_warning("I'm so sorry... You don't seem to have enough money."))
			if(PAYMENT_ANGRY)
				to_chat(user, span_warning("YOU MORON. YOU ABSOLUTE BAFOON. YOU INSUFFERABLE TOOL. YOU ARE POOR."))
			if(PAYMENT_CLINICAL)
				to_chat(user, span_warning("ID Card lacks funds. Aborting."))
		atom_parent.balloon_alert(user, "needs [total_cost] credit\s!")
		return FALSE
	target_acc.transfer_money(idcard.registered_account, total_cost, "Nanotrasen: Usage of Corporate Machinery")
	log_econ("[total_cost] credits were spent on [parent] by [user] via [idcard.registered_account.account_holder]'s card.")
	idcard.registered_account.bank_card_talk("[total_cost] credits deducted from your account.")
	playsound(src, 'sound/effects/cashregister.ogg', 20, TRUE)
	SSeconomy.track_purchase(idcard.registered_account, total_cost, parent)
	return TRUE

/**
 * Attempts to remove the payment component, currently when the crew wins a revolution.
 * * datum/source: source of the signal.
 */
/datum/component/payment/proc/clean_up(datum/source)
	SIGNAL_HANDLER
	target_acc = null
	qdel(src)
