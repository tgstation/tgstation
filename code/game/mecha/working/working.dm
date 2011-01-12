/obj/mecha/working
	deflect_chance = 10
	health = 500
	req_access = access_heads
	var/datum/mecha_tool/selected_tool
	var/list/tools = new
	operation_req_access = list(access_engine)
	internals_req_access = list(access_engine)
	internal_damage_threshold = 70


/obj/mecha/working/melee_action(atom/target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = pick(oview(1,src))
	if(selected_tool)
		selected_tool.action(target)
	return

/obj/mecha/working/range_action(atom/target as obj|mob|turf)
	return

/obj/mecha/working/Topic(href, href_list)
	..()
	if (href_list["select_tool"])
		var/tool = locate(href_list["select_tool"])
		if(tool)
			src.selected_tool = tool
	return

/obj/mecha/working/get_stats_part()
	var/output = ..()
	output += "<b>[src.name] Tools:</b><div style=\"margin-left: 15px;\">"
	if(tools.len)
		for(var/datum/mecha_tool/MT in tools)
			output += "[selected_tool==MT?"<b>":"<a href='?src=\ref[src];select_tool=\ref[MT]'>"][MT.get_tool_info()][selected_tool==MT?"</b>":"</a>"]<br>"
	else
		output += "None"
	output += "</div>"
	return output


/obj/mecha/working/check_for_internal_damage(var/list/possible_int_damage)
	..(possible_int_damage)
	if(prob(5) && (src.health*100/initial(src.health))<src.internal_damage_threshold)
		if(tools.len)
			var/datum/mecha_tool/destr_tool = pick(tools)
			if(destr_tool)
				tools -= destr_tool
				destr_tool.destroy()
				src.occupant_message("<font color='red'>The [destr_tool] is destroyed!</font>")
				src.log_append_to_last("[destr_tool] is destroyed.")
	return