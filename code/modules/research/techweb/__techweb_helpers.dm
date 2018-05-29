
/proc/total_techweb_exports(subsystem = FALSE)
	var/list/datum/techweb_node/processing = list()
	if(!subsystem)
		for(var/i in subtypesof(/datum/techweb_node))
			processing += new i
	else
		for(var/id in SSresearch.nodes)
			processing += SSresearch.nodes[id]
	. = 0
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		. += TN.export_price

/proc/total_techweb_points(subsystem = FALSE)
	var/list/datum/techweb_node/processing = list()
	if(!subsystem)
		for(var/i in subtypesof(/datum/techweb_node))
			processing += new i
	else
		for(var/id in SSresearch.nodes)
			processing += SSresearch.nodes[id]
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.research_points

/proc/total_techweb_points_printout(subsystem = FALSE)
	var/list/datum/techweb_node/processing = list()
	if(!subsystem)
		for(var/i in subtypesof(/datum/techweb_node))
			processing += new i
	else
		for(var/id in SSresearch.nodes)
			processing += SSresearch.nodes[id]
	var/datum/techweb/TW = new
	TW.research_points = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		TW.add_point_list(TN.research_costs)
	return TW.printout_points()

/proc/count_unique_techweb_nodes(subsystem = FALSE)
	var/list/L = list()
	if(!subsystem)
		L = typesof(/datum/techweb_node)
	else
		L = SSresearch.nodes.len
	return L.len

/proc/count_unique_techweb_designs(subsystem = FALSE)
	var/list/L = list()
	if(!subsystem)
		L = typesof(/datum/design)
	else
		L = SSresearch.designs.len
	return L.len

/proc/get_techweb_node_by_id(id)
	return SSresearch.nodes[id]

/proc/get_techweb_design_by_id(id)
	return SSresearch.designs[id]

/proc/techweb_item_boost_check(obj/item/I)			//Returns an associative list of techweb node datums with values of the boost it gives.	var/list/returned = list()
	if(SSresearch.techweb_boost_items[I.type])
		return SSresearch.techweb_boost_items[I.type]		//It should already be formatted in node datum = list(point type = value)

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]

/proc/techweb_point_display_generic(pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		if(SSresearch.point_types[i])
			ret += "[SSresearch.point_types[i]]: [pointlist[i]]"
		else
			ret += "ERRORED POINT TYPE: [pointlist[i]]"
	return ret.Join("<BR>")

/proc/techweb_point_display_rdconsole(pointlist, last_pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		ret += "[SSresearch.point_types[i] || "ERRORED POINT TYPE"]: [pointlist[i]] (+[(last_pointlist[i]) * ((SSresearch.flags & SS_TICKER)? (600 / (world.tick_lag * SSresearch.wait)) : (600 / SSresearch.wait))]/ minute)"
	return ret.Join("<BR>")
