/datum/component/pricetag
	///Payee gets 100% of the value if no ratio has been set.
	var/default_profit_ratio = 1
	///List of bank accounts this pricetag pays out to. Format is payees[bank_account] = profit_ratio.
	var/list/payees = list()

/datum/component/pricetag/Initialize(_owner,_profit_ratio)
	if(!isobj(parent)) //Has to account for both objects and sellable structures like crates.
		return COMPONENT_INCOMPATIBLE

	if(_profit_ratio)
		payees[_owner] = _profit_ratio
	else
		payees[_owner] = default_profit_ratio

	RegisterSignal(parent, list(COMSIG_ITEM_SOLD), .proc/split_profit)
	RegisterSignal(parent, list(COMSIG_STRUCTURE_UNWRAPPED, COMSIG_ITEM_UNWRAPPED), .proc/Unwrapped)
	RegisterSignal(parent, list(COMSIG_ITEM_SPLIT_PROFIT, COMSIG_ITEM_SPLIT_PROFIT_DRY), .proc/return_ratio)

/datum/component/pricetag/proc/Unwrapped()
	SIGNAL_HANDLER

	qdel(src) //Once it leaves it's wrapped container, the object in question should lose it's pricetag component.

/datum/component/pricetag/proc/split_profit(item_value)
	SIGNAL_HANDLER

	var/price = item_value
	if(price)
		for(var/datum/bank_account/payee in payees)
			var/profit_ratio = payees[payee]
			var/adjusted_value = price * profit_ratio
			var/datum/bank_account/bank_account = payee
			bank_account.adjust_money(adjusted_value)
			bank_account.bank_card_talk("Sale of [parent] recorded. [adjusted_value] credits added to account.")
		return TRUE

/datum/component/pricetag/proc/return_ratio()
	SIGNAL_HANDLER
	return default_profit_ratio
