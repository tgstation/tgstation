#define TECHWEB_SVG_NODE_HEIGHT_PX 128
#define TECHWEB_SVG_NODE_WIDTH_PX 512

#define TECHWEB_SVG_PADDING_PX 128

/datum/techweb/proc/generate_SVG_techweb()
	if(!techweb_tree_node_height || !techweb_tree_node_width)
		return "ERROR"
	var/list/node_html = list()
	var/list/node_status = list()
	for(var/id in researched_nodes)
		node_html[id] = techweb_single_node_html(get_techweb_node_by_id(id))
		node_status[id] = "RESEARCHED"
	for(var/id in available_nodes)
		node_html[id] = techweb_single_node_html(get_techweb_node_by_id(id))
		node_status[id] = "AVAILABLE"
	for(var/id in visible_nodes)
		node_html[id] = techweb_single_node_html(get_techweb_node_by_id(id))
		node_status[id] = "VISIBLE"
	var/SVG_height = TECHWEB_SVG_NODE_HEIGHT_PX * techweb_tree_node_height + TECHWEB_SVG_PADDING_PX * 2
	var/SVG_height = TECHWEB_SVG_NODE_WIDTH_PX * techweb_tree_node_width + TECHWEB_SVG_PADDING_PX * 2



/proc/techweb_single_node_html(datum/techweb_node/node, selflink = TRUE, minimal = FALSE)
	var/list/l = list()
	if(stored_research.hidden_node_ids[node.id])
		return l
	var/display_name = node.display_name
	if(selflink)
		display_name = "<A href='?src=[REF(src)];view_node=[node.id];back_screen=[screen]'>[display_name]</A>"
	l += "<div class='statusDisplay technode'><b>[display_name]</b> [RDSCREEN_NOBREAK]"
	if(minimal)
		l += "<br>[node.description]"
	else
		if(stored_research.researched_node_ids[node.id])
			l += "<span class='linkOff'>Researched</span>"
		else if(stored_research.available_node_ids[node.id])
			if(stored_research.can_afford(node.get_price(stored_research)))
				l += "<BR><A href='?src=[REF(src)];research_node=[node.id]'>[node.price_display(stored_research)]</A>"
			else
				l += "<BR><span class='linkOff'>[node.price_display(stored_research)]</span>"  // gray - too expensive
		else
			l += "<BR><span class='linkOff bad'>[node.price_display(stored_research)]</span>"  // red - missing prereqs
		if(ui_mode == RDCONSOLE_UI_MODE_NORMAL)
			l += "[node.description]"
			for(var/i in node.design_ids)
				var/datum/design/D = get_techweb_design_by_id(i)
				l += "<span data-tooltip='[D.name]' onclick='location=\"?src=[REF(src)];view_design=[i];back_screen=[screen]\"'>[D.icon_html(usr)]</span>[RDSCREEN_NOBREAK]"
	l += "</div>[RDSCREEN_NOBREAK]"
	return l
