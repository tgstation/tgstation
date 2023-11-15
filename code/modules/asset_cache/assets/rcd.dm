/datum/asset/spritesheet/rcd
	name = "rcd-tgui"

/datum/asset/spritesheet/rcd/create_spritesheets()
	for(var/root_category in GLOB.rcd_designs)

		var/list/category_designs = GLOB.rcd_designs[root_category]
		if(!length(category_designs))
			continue

		for(var/category in category_designs)
			var/list/designs = category_designs[category]

			var/sprite_name
			var/icon/sprite_icon
			for(var/list/design as anything in designs)
				var/atom/movable/path = design[RCD_DESIGN_PATH]
				if(!ispath(path))
					continue
				sprite_name = initial(path.name)

				//icon for windows are blended with grills if required and loaded from radial menu
				if(ispath(path, /obj/structure/window))
					if(path == /obj/structure/window)
						sprite_icon = icon(icon = 'icons/hud/radial.dmi', icon_state = "windowsize")
					else if(path == /obj/structure/window/reinforced)
						sprite_icon = icon(icon = 'icons/hud/radial.dmi', icon_state = "windowtype")
					else if(path == /obj/structure/window/fulltile || path == /obj/structure/window/reinforced/fulltile)
						sprite_icon = icon(icon = initial(path.icon), icon_state = initial(path.icon_state))
						sprite_icon.Blend(icon(icon = 'icons/obj/structures.dmi', icon_state = "grille"), ICON_UNDERLAY)

				//icons for solid airlocks have an added solid overlay on top of their glass icons
				else if(ispath(path, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/airlock_path = path
					var/airlock_icon = initial(airlock_path.icon)

					sprite_icon = icon(icon = airlock_icon, icon_state = "closed")
					if(!initial(airlock_path.glass))
						sprite_icon.Blend(icon(icon = airlock_icon, icon_state = "fill_closed"), ICON_OVERLAY)

				//for all other icons we load the paths default icon & icon state
				else
					sprite_icon = icon(icon = initial(path.icon), icon_state = initial(path.icon_state))

				Insert(sanitize_css_class_name(sprite_name), sprite_icon)
