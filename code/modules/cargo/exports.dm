/* How it works:
 The shuttle arrives at Centcom dock and calls sell(), which recursively loops through all the shuttle contents that are unanchored.
 The loop only checks contents of storage types, see supply.dm shuttle code.

 Each object in the loop is checked for applies_to() of various export datums, except the invalid ones.
 Objects on shutlle floor are checked only against shuttle_floor = TRUE exports.

 If applies_to() returns TRUE, sell_object() is called on object and checks against exports are stopped for this object.
 sell_object() must add object amount and cost to export's total_cost and total_amount.

 When all the shuttle objects are looped, export cycle is over. The shuttle calls total_printout() for each valid export.
 If total_printout() returns something, the export datum's total_cost is added to cargo credits, then export_end() is called to reset total_cost and total_amount.
*/

/* The rule in figuring out item export cost:
 Export cost of goods in the shipping crate must be always equal or lower than:
  packcage cost - crate cost - manifest cost
 Crate cost is 500cr for a regular plasteel crate and 100cr for a large wooden one. Manifest cost is always 200cr.
 This is to avoid easy cargo points dupes.

Credit dupes that require a lot of manual work shouldn't be removed, unless they yield too much profit for too little work.
 For example, if some player buys metal and glass sheets and uses them to make and sell reinforced glass:

 100 glass + 50 metal -> 100 reinforced glass
 (1500cr -> 1600cr)

 then the player gets the profit from selling his own wasted time.
*/
/proc/export_item_and_contents(atom/movable/AM, contraband, emagged, dry_run=FALSE)
	if(!GLOB.exports_list.len)
		setupExports()

	var/sold_str = ""
	var/cost = 0

	var/list/contents = AM.GetAllContents()

	// We go backwards, so it'll be innermost objects sold first
	for(var/i in reverseRange(contents))
		var/atom/movable/thing = i
		for(var/datum/export/E in GLOB.exports_list)
			if(!E)
				continue
			if(E.applies_to(thing, contraband, emagged))
				if(dry_run)
					cost += E.get_cost(thing, contraband, emagged)
				else
					E.sell_object(thing, contraband, emagged)
					sold_str += " [thing.name]"
				break
		if(!dry_run)
			qdel(thing)

	if(dry_run)
		return cost
	else
		return sold_str

/datum/export
	var/unit_name = ""				// Unit name. Only used in "Received [total_amount] [name]s [message]." message
	var/message = ""
	var/cost = 100					// Cost of item, in cargo credits. Must not alow for infinite price dupes, see above.
	var/contraband = FALSE			// Export must be unlocked with multitool.
	var/emagged = FALSE				// Export must be unlocked with emag.
	var/list/export_types = list()	// Type of the exported object. If none, the export datum is considered base type.
	var/include_subtypes = TRUE		// Set to FALSE to make the datum apply only to a strict type.
	var/list/exclude_types = list()	// Types excluded from export

	// Used by print-out
	var/total_cost = 0
	var/total_amount = 0

// Checks the cost. 0 cost items are skipped in export.
/datum/export/proc/get_cost(obj/O, contr = 0, emag = 0)
	return cost * get_amount(O, contr, emag)

// Checks the amount of exportable in object. Credits in the bill, sheets in the stack, etc.
// Usually acts as a multiplier for a cost, so item that has 0 amount will be skipped in export.
/datum/export/proc/get_amount(obj/O, contr = 0, emag = 0)
	return 1

// Checks if the item is fit for export datum.
/datum/export/proc/applies_to(obj/O, contr = 0, emag = 0)
	if(contraband && !contr)
		return FALSE
	if(emagged && !emag)
		return FALSE
	if(!include_subtypes && !(O.type in export_types))
		return FALSE
	if(include_subtypes && (!is_type_in_list(O, export_types) || is_type_in_list(O, exclude_types)))
		return FALSE
	if(!get_cost(O, contr, emag))
		return FALSE
	if(HAS_SECONDARY_FLAG(O, HOLOGRAM))
		return FALSE
	return TRUE

// Called only once, when the object is actually sold by the datum.
// Adds item's cost and amount to the current export cycle.
// get_cost, get_amount and applies_to do not neccesary mean a successful sale.
/datum/export/proc/sell_object(obj/O, contr = 0, emag = 0)
	var/cost = get_cost(O)
	var/amount = get_amount(O)
	total_cost += cost
	total_amount += amount
	SSblackbox.add_details("export_sold_amount","[O.type]|[amount]")
	SSblackbox.add_details("export_sold_cost","[O.type]|[cost]")

// Total printout for the cargo console.
// Called before the end of current export cycle.
// It must always return something if the datum adds or removes any credts.
/datum/export/proc/total_printout(contr = 0, emag = 0)
	if(!total_cost && !total_amount)
		return ""
	var/msg = "[total_cost] credits: Received [total_amount] "
	if(total_cost > 0)
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

// The current export cycle is over now. Reset all the export temporary vars.
/datum/export/proc/export_end()
	total_cost = 0
	total_amount = 0

GLOBAL_LIST_EMPTY(exports_list)

/proc/setupExports()
	for(var/subtype in subtypesof(/datum/export))
		var/datum/export/E = new subtype
		if(E.export_types && E.export_types.len) // Exports without a type are invalid/base types
			GLOB.exports_list += E
