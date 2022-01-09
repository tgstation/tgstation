/*
 * Pricetag component.
 *
 * Used when exporting items via the cargo system.
 * Gives a cut of the profit to one or multiple bank accounts.
 */
/datum/component/pricetag
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Whether we qdel ourself when our parent is unwrapped or not.
	var/delete_on_unwrap = TRUE
	/// List of bank accounts this pricetag pays out to. Format is payees[bank_account] = profit_ratio.
	var/list/payees = list()

/datum/component/pricetag/Initialize(pay_to_account, profit_ratio = 1, delete_on_unwrap = TRUE)
	if(!isobj(parent)) //Has to account for both objects and sellable structures like crates.
		return COMPONENT_INCOMPATIBLE

	if(isnull(pay_to_account))
		stack_trace("[type] component was added to something without a pay_to_account!")
		return COMPONENT_INCOMPATIBLE

	payees[pay_to_account] = profit_ratio
	src.delete_on_unwrap = delete_on_unwrap

/datum/component/pricetag/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EXPORTED, .proc/on_parent_sold)
	// Register this regardless of delete_on_unwrap because it could change by inherited components.
	RegisterSignal(parent, list(COMSIG_STRUCTURE_UNWRAPPED, COMSIG_ITEM_UNWRAPPED), .proc/on_parent_unwrap)

/datum/component/pricetag/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EXPORTED,
		COMSIG_STRUCTURE_UNWRAPPED,
		COMSIG_ITEM_UNWRAPPED,
		))

/*
 * Inheriting an incoming / new version of price tag:
 *
 * If the account passed in the incoming version is already in our list,
 * only override it if the ratio is better for the payee
 *
 * If the account passed in the incoming version is not in our list, add it like normal.
 *
 * If the incoming version shouldn't delete when unwrapped,
 * our version shouldn't either.
 * We don't care about the other way around
 * (Don't go from non-deleting to deleting)
 */
/datum/component/pricetag/InheritComponent(datum/component/pricetag/new_comp, i_am_original, pay_to_account, profit_ratio = 1, delete_on_unwrap = TRUE)
	if(!isnull(payees[pay_to_account]) && payees[pay_to_account] >= profit_ratio) // They're already getting a better ratio, don't scam them
		return

	payees[pay_to_account] = profit_ratio
	if(!delete_on_unwrap)
		src.delete_on_unwrap = delete_on_unwrap


/*
 * Signal proc for [COMSIG_STRUCTURE_UNWRAPPED] and [COMSIG_ITEM_UNWRAPPED].
 *
 * Once it leaves its wrapped container,
 * the parent should loses its pricetag component
 * (if delete_on_unwrap is TRUE)
 */
/datum/component/pricetag/proc/on_parent_unwrap(obj/source)
	SIGNAL_HANDLER

	if(!delete_on_unwrap)
		return

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
	return COMPONENT_STOP_EXPORT_REPORT
