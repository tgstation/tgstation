/datum/component/pricetag
	var/datum/bank_account/owner = null

/datum/component/pricetag/Initialize(_owner)
	if(_owner)
		owner = _owner
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_SOLD, .proc/split_profit)

/datum/component/pricetag/proc/split_profit(var/item_value)
	var/price = item_value
	if(price)
		owner.adjust_money(price/2)
