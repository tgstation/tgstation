/* How it works:
The shuttle arrives at CentCom dock and calls sell(), which recursively loops through all the shuttle contents that are unanchored.

Each object in the loop is checked for applies_to() of various export datums, except the invalid ones.
*/

/* The rule in figuring out item export cost:
Export cost of goods in the shipping crate must be always equal or lower than:
	packcage cost - crate cost - manifest cost
Crate cost is 500cr for a regular plasteel crate and 100cr for a large wooden one. Manifest cost is always 200cr.
This is to avoid easy cargo points dupes.

Credit dupes that require a lot of manual work shouldn't be removed, unless they yield too much profit for too little work.
For example, if some player buys iron and glass sheets and uses them to make and sell reinforced glass:

100 glass + 50 iron-> 100 reinforced glass
1500cr -> 1600cr)

Then the player gets the profit from selling his own wasted time.
*/

// Simple holder datum to pass export results around
/datum/export_report
	///names of atoms sold/deleted by export
	var/list/exported_atoms = list()
	///export instance => total count of sold objects of its type, only exists if any were sold
	var/list/total_amount = list()
	///export instance => total value of sold objects
	var/list/total_value = list()
	///set to false if any objects in a dry run were unscannable
	var/all_contents_scannable = TRUE

/*
	* Handles exporting a movable atom and its contents
	* Arguments:
	** apply_elastic: if the price will change based on amount sold, where applicable
	** delete_unsold: if the items that were not sold should be deleted
	** dry_run: if the item should be actually sold, or if it's just a pirce test
	** external_report: works as "transaction" object, pass same one in if you're doing more than one export in single go
	** ignore_typecache: typecache containing types that should be completely ignored
	** export_markets: Defines the market that the items are being sold to.
*/
/proc/export_item_and_contents(atom/movable/exported_atom, apply_elastic = TRUE, delete_unsold = TRUE, dry_run = FALSE, datum/export_report/external_report, list/ignore_typecache, export_markets = list(EXPORT_MARKET_STATION))
	if(!islist(export_markets))
		export_markets = list(export_markets)

	if(!external_report)
		external_report = new

	var/list/contents = exported_atom.get_all_contents_ignoring(ignore_typecache)

	// We go backwards, so it'll be innermost objects sold first. We also make sure nothing is accidentally delete before everything is sold.
	var/list/to_delete = list()
	for(var/atom/movable/thing as anything in reverse_range(contents))
		var/sold = _export_loop(thing, apply_elastic, dry_run, external_report, export_markets)
		if(!dry_run && (sold || delete_unsold) && sold != EXPORT_SOLD_DONT_DELETE)
			if(ismob(thing))
				thing.investigate_log("deleted through cargo export", INVESTIGATE_CARGO)
			to_delete += thing

	for(var/atom/movable/thing as anything in to_delete)
		if(!QDELETED(thing))
			qdel(thing)

	return external_report

/// It works like export_item_and_contents(), however it ignores the contents. Meaning only `exported_atom` will be valued.
/proc/export_single_item(atom/movable/exported_atom, apply_elastic = TRUE, delete_unsold = TRUE, dry_run = FALSE, datum/export_report/external_report, export_markets = list(EXPORT_MARKET_STATION))
	if(!external_report)
		external_report = new

	var/sold = _export_loop(exported_atom, apply_elastic, dry_run, external_report, export_markets)
	if(!dry_run && (sold || delete_unsold) && sold != EXPORT_SOLD_DONT_DELETE)
		if(ismob(exported_atom))
			exported_atom.investigate_log("deleted through cargo export", INVESTIGATE_CARGO)
		qdel(exported_atom)

	return external_report

/// The main bit responsible for selling the item. Shared by export_single_item() and export_item_and_contents()
/proc/_export_loop(atom/movable/exported_atom, apply_elastic = TRUE, dry_run = FALSE, datum/export_report/external_report, export_markets)
	var/sold = EXPORT_NOT_SOLD
	for(var/datum/export/export as anything in GLOB.exports_list)
		if(export.applies_to(exported_atom, apply_elastic, export_markets))
			if(!dry_run && (SEND_SIGNAL(exported_atom, COMSIG_ITEM_PRE_EXPORT) & COMPONENT_STOP_EXPORT))
				break
			//Don't add value of unscannable items for a dry run report
			if(dry_run && !export.scannable)
				external_report.all_contents_scannable = FALSE
				break
			sold = export.sell_object(exported_atom, external_report, dry_run, apply_elastic)
			break
	return sold

/datum/export
	abstract_type = /datum/export

	/// Unit name. Only used in "Received [total_amount] [name]s [message]."
	var/unit_name = ""
	/// Message appended to the sale report
	var/message = ""

	///Price per unit of an exported item
	var/cost = 1
	/// whether this export can have a negative impact on the cargo budget or not
	var/allow_negative_cost = FALSE
	///The percentage of an items real price that is earned when selling that item on cargo
	var/k_elasticity = 1
	///The percentage decrease on this exports elasticity per unit of item sold
	var/k_hit_percentile = 0.05
	///Time taken for this exports elasticity to reach back to 100%
	var/k_recovery_time = 10 MINUTES

	/// The multiplier of the amount sold shown on the report. Useful for exports, such as material, which costs are not strictly per single units sold.
	var/amount_report_multiplier = 1
	/// Type of the exported object. If none, the export datum is considered base type.
	var/list/export_types = list()
	/// Set to FALSE to make the datum apply only to a strict type.
	var/include_subtypes = TRUE
	/// Types excluded from export
	var/list/exclude_types = list()
	/// Set to false if the cost shouldn't be determinable by an export scanner
	var/scannable = TRUE
	/// Export market that this export applies to. Defaults to EXPORT_MARKET_STATION for items sold to the standard supply shuttle, replacements exist for pirates, etc.
	var/sales_market = EXPORT_MARKET_STATION

/datum/export/New()
	..()
	export_types = typecacheof(export_types, only_root_path = !include_subtypes)
	exclude_types = typecacheof(exclude_types)

/datum/export/Destroy()
	return ..()

/datum/export/process(seconds_per_tick)
	k_elasticity += seconds_per_tick / k_recovery_time
	if(k_elasticity >= 1)
		k_elasticity = 1
		return PROCESS_KILL

/**
 * Returns the cost of 1 unit of the exported item
 *
 * Arguments
 * * obj/exported_item - the item we whos base cost we are trying to compute
*/
/datum/export/proc/get_base_cost(obj/exported_item)
	return cost

/*
 * Returns the amount of exportable in object. Credits in the bill, sheets in the stack, etc.
 * Usually acts as a multiplier for a cost, so item that has 0 amount will be skipped in export.
 *
 * Arguments
 * * obj/exported_item - the amount of units in this exported item
*/
/datum/export/proc/get_amount(obj/exported_item)
	return 1


/**
 * Returns the cost of the xported item i.e. amount * base cost * elasticity if TRUE
 *
 * Arguments
 * * obj/exported_item - the item we are trying to export
 * * apply_elastic - should we use elasticity
*/
/datum/export/proc/get_cost(obj/exported_item, apply_elastic = TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/total = get_base_cost(exported_item) * get_amount(exported_item)
	if(apply_elastic && initial(k_elasticity) > 0)
		total *= k_elasticity
	return ROUND_UP(total)

/// Checks if the item is fit for export datum.
/datum/export/proc/applies_to(obj/exported_item, apply_elastic = TRUE, export_markets)
	for(var/found_market in export_markets)
		if(!is_type_in_typecache(exported_item, export_types))
			continue
		if(include_subtypes && is_type_in_typecache(exported_item, exclude_types))
			continue
		if(!get_cost(exported_item, apply_elastic))
			continue
		if(found_market != sales_market)
			continue
		if(exported_item.flags_1 & HOLOGRAM_1)
			continue
		return TRUE

/**
 * Calculates the exact export value of the object, while factoring in all the relivant variables.
 *
 * Called only once, when the object is actually sold by the datum.
 * Adds item's cost and amount to the current export cycle.
 * get_cost, get_amount and applies_to do not neccesary mean a successful sale.
 *
 */
/datum/export/proc/sell_object(obj/sold_item, datum/export_report/report, dry_run = TRUE, apply_elastic = TRUE)
	///This is the value of the object, as derived from export datums.
	var/export_value = get_cost(sold_item, apply_elastic)
	///Quantity of the object in question.
	var/export_amount = get_amount(sold_item)

	if(export_amount <= 0 || (export_value <= 0 && !allow_negative_cost))
		return EXPORT_NOT_SOLD

	// If we're not doing a dry run, send COMSIG_ITEM_EXPORTED to the sold item
	var/export_result
	if(!dry_run)
		export_result = SEND_SIGNAL(sold_item, COMSIG_ITEM_EXPORTED, src, report, export_value)

	// If the signal handled adding it to the report, don't do it now
	if(!(export_result & COMPONENT_STOP_EXPORT_REPORT))
		report.total_value[src] += export_value
		report.total_amount[src] += export_amount * amount_report_multiplier
		report.exported_atoms += "[sold_item.name]"

	if(!dry_run)
		if(apply_elastic && k_elasticity > 0)
			k_elasticity -= export_amount * k_hit_percentile
			if(k_elasticity < 0)
				k_elasticity = 0
			SSprocessing.processing |= src
		SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[sold_item.type]", "[export_value]"))
	return EXPORT_SOLD

/*
* Total printout for the cargo console.
* Called before the end of current export cycle.
* It must always return something if the datum adds or removes any credtis.
*/
/datum/export/proc/total_printout(datum/export_report/ex, notes = TRUE)
	if(!ex.total_amount[src] || !ex.total_value[src])
		return ""

	var/total_value = ex.total_value[src]
	var/total_amount = ex.total_amount[src]

	var/msg = "[total_value] [MONEY_NAME]: Received [total_amount] "
	if(total_value > 0)
		msg = "+" + msg

	if(unit_name)
		msg += unit_name
		if(total_amount > 1)
			msg += "s"
		if(message)
			msg += " "

	if(message)
		msg += message

	msg += "."
	return msg

