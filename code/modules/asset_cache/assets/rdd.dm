/datum/asset/spritesheet_batched/rdd
	name = "rdd"

/datum/asset/spritesheet_batched/rdd/create_spritesheets()
	for(var/category in GLOB.rdd_designs)
		for(var/list/design in GLOB.rdd_designs[category])
			var/obj/structure/decoration/dec_path = design["path"]
			var/sprite_name = sanitize_css_class_name(design["name"])
			var/datum/universal_icon/icon = uni_icon(initial(dec_path.icon), initial(dec_path.icon_state))
			icon.scale(32, 32)
			insert_icon(sprite_name, icon)
