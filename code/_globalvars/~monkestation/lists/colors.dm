GLOBAL_LIST_INIT(color_list_blood_brothers, initialize_bb_colors())

/proc/initialize_bb_colors()
	var/static/list/base_colors = list("red", "purple", "navy", "darkbluesky", "bluesky", "cyan", "lime", "orange", "redorange")
	. = list()
	for(var/color in shuffle(base_colors))
		. += "cfc_[color]"
