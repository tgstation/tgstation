/datum/component/pricetag
	var/datum/bank_account/owner = null
	var/profit_ratio = 1

/datum/component/pricetag/Initialize(_owner,_profit_ratio)
	if(_owner)
		owner = _owner
	if(_profit_ratio)
		profit_ratio = _profit_ratio
	RegisterSignal(parent, COMSIG_ITEM_SOLD, .proc/split_profit)
	RegisterSignal(parent, COMSIG_ITEM_UNWRAPPED, .proc/Unwrapped)

/datum/component/pricetag/proc/Unwrapped()
	qdel(src) //Once it leaves it's wrapped container, the object in question should lose it's pricetag component.

/datum/component/pricetag/proc/split_profit(var/item_value)
	var/price = item_value
	if(price)
		var/adjusted_value = price*(profit_ratio/100)
		owner.adjust_money(adjusted_value)
		owner.bank_card_talk("Sale recorded. [adjusted_value] credits added to account.")
