/// Pricetag components, used when exporting items.
/datum/component/pricetag
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Payee gets 100% of the value if no ratio has been set.
	var/default_profit_ratio = 1
	///List of bank accounts this pricetag pays out to. Format is payees[bank_account] = profit_ratio.
	var/list/payees = list()

/datum/component/pricetag/Initialize(pay_to_account, profit_ratio)
	if(!isobj(parent)) //Has to account for both objects and sellable structures like crates.
		return COMPONENT_INCOMPATIBLE

	payees[pay_to_account] = isnum(profit_ratio) ? profit_ratio : default_profit_ratio

/datum/component/pricetag/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EXPORTED, .proc/on_parent_sold)
	RegisterSignal(parent, list(COMSIG_STRUCTURE_UNWRAPPED, COMSIG_ITEM_UNWRAPPED), .proc/on_parent_unwrap)

/datum/component/pricetag/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EXPORTED,
		COMSIG_STRUCTURE_UNWRAPPED,
		COMSIG_ITEM_UNWRAPPED,
		))

/*
 * Adding a new version of price tag:
 *
 * If the account passed in the new version is already in our list,
 * only override it if the ratio is better for the payee
 *
 * If the account passed in the new version is not in our list,
 * add it like normal
 */
/datum/component/pricetag/InheritComponent(datum/component/pricetag/new_comp, i_am_original, pay_to_account, profit_ratio)
	if(!isnull(payees[pay_to_account]) && payees[pay_to_account] >= profit_ratio) // They're already getting a better ratio, don't scam them
		return
	payees[pay_to_account] = isnum(profit_ratio) ? profit_ratio : default_profit_ratio

/*
 * Signal proc for [COMSIG_STRUCTURE_UNWRAPPED] and [COMSIG_ITEM_UNWRAPPED].
 *
 * Once it leaves it's wrapped container, the the parent should lose its pricetag component.
 */
/datum/component/pricetag/proc/on_parent_unwrap(obj/source)
	SIGNAL_HANDLER

	qdel(src)

/*
 * Signal proc for [COMSIG_ITEM_EXPORTED].
 *
 * Pays out money to everyone in the payees list.
 */
/datum/component/pricetag/proc/on_parent_sold(obj/source, datum/export/export, datum/export_report/report, item_value)
	SIGNAL_HANDLER

	if(!isnum(item_value))
		return

	// Gotta see how much money we've lost by the end of things.
	var/overall_item_price = item_value

	for(var/datum/bank_account/payee as anything in payees)
		// Every payee with a ratio gets a cut based on the item's total value
		var/payee_cut = round(item_value * payees[payee])
		// And of course, the cut is removed from what cargo gets. (But not below zero, just in case)
		overall_item_price = max(0, overall_item_price - payee_cut)

		payee.adjust_money(payee_cut)
		payee.bank_card_talk("Sale of [source] recorded. [payee_cut] credits added to account.")

	// Update the report with the modified final price
	report.total_value[export] += overall_item_price
	report.total_amount[export] += export.get_amount(source) * export.amount_report_multiplier

	// And ensure we don't double-add to the report
	return COMPONENT_STOP_REPORT
