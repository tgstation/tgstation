/datum/asset/spritesheet/cell_line
	name = "cell_line"

/datum/asset/spritesheet/cell_line/create_spritesheets()
	var/list/id_list = list()
	for (var/path in subtypesof(/datum/micro_organism/cell_line))
		var/datum/micro_organism/cell_line/cell_line = path
		var/atom/organism = cell_line.resulting_atom
		if(!organism)
			continue
		var/organism_icon = initial(organism.icon)
		var/organism_icon_state = initial(organism.icon_state)
		var/id = sanitize_css_class_name("[organism_icon][organism_icon_state]")
		if(id in id_list) //no dupes
			continue
		id_list += id
		Insert(id, organism_icon, organism_icon_state)
