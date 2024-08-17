/proc/count_unique_techweb_nodes()
	var/static/list/L = typesof(/datum/techweb_node)
	return L.len

/proc/count_unique_techweb_designs()
	var/static/list/L = typesof(/datum/design)
	return L.len

/proc/node_boost_error(id, message)
	WARNING("Invalid boost information for node \[[id]\]: [message]")
	SSresearch.invalid_node_boost[id] = message

///Returns an associative list of techweb node datums with values of the nodes it unlocks.
/proc/techweb_item_unlock_check(obj/item/I)
	if(SSresearch.techweb_unlock_items[I.type])
		return SSresearch.techweb_unlock_items[I.type] //It should already be formatted in node datum = list(point type = value)

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]
	return FALSE

/proc/techweb_point_display_generic(pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		if(i in SSresearch.point_types)
			ret += "[SSresearch.point_types[i]]: [pointlist[i]]"
		else
			ret += "ERRORED POINT TYPE: [pointlist[i]]"
	return ret.Join("<BR>")

/proc/techweb_point_display_rdconsole(pointlist, last_pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		var/research_line = "[(i in SSresearch.point_types) || "ERRORED POINT TYPE"]: [pointlist[i]]"
		if(last_pointlist[i] > 0)
			research_line += " (+[(last_pointlist[i]) * ((SSresearch.flags & SS_TICKER)? (600 / (world.tick_lag * SSresearch.wait)) : (600 / SSresearch.wait))]/ minute)"
		ret += research_line
	return ret.Join("<BR>")
