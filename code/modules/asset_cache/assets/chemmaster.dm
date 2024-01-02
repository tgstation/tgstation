///Icons for containers printed in ChemMaster
/datum/asset/spritesheet/chemmaster
	name = "chemmaster"

/datum/asset/spritesheet/chemmaster/create_spritesheets()
	var/list/ids = list()
	for(var/category in GLOB.reagent_containers)
		for(var/obj/item/reagent_containers/container as anything in GLOB.reagent_containers[category])
			var/icon_file = initial(container.icon)
			var/icon_state = initial(container.icon_state)
			var/id = sanitize_css_class_name("[container]")
			if(id in ids) // exclude duplicate containers
				continue
			ids += id
			Insert(id, icon_file, icon_state)
