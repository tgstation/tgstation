/datum/asset/spritesheet/seeds
	name = "seeds"

/datum/asset/spritesheet/seeds/create_spritesheets()
	var/list/id_list = list()
	for (var/path in subtypesof(/obj/item/seeds))
		var/obj/item/seeds/seed_type = path
		var/icon = initial(seed_type.icon)
		var/icon_state = initial(seed_type.icon_state)
		var/id = sanitize_css_class_name("[icon][icon_state]")
		if(id in id_list) //no dupes
			continue
		id_list += id
		Insert(id, icon, icon_state)
