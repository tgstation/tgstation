/datum/component/pricetag
	var/datum/bank_account/owner = null

/datum/component/pricetag/Initialize(_owner)
	if(_owner)
		owner = _owner
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_SOLD, .proc/split_profit)

/datum/component/pricetag/proc/split_profit(obj/source)
	var/datum/export_report/ex = export_item_and_contents(source, allowed_categories = (ALL), dry_run=TRUE)
	var/price = 0
	for(var/x in ex.total_amount)
		price += ex.total_value[x]
	if(price)
		owner.adjust_money(price/2)
