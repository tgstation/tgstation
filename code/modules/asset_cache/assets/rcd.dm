
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
				var/atom/path = design[RCD_DESIGN_PATH]
				if(!ispath(path))
					continue
				sprite_name = RCD_SPRITESHEET_PATH_KEY(path)
				//icon for windows are blended with frames if required and loaded from radial menu
				if(ispath(path, /obj/structure/window))
					var/obj/structure/window/window_path = path
					if(initial(window_path.fulltile))
						sprite_icon = icon(icon = 'icons/obj/structures/smooth/window_frames/window_frame_normal.dmi', icon_state = "window_frame_normal-0", dir = SOUTH)

						var/obj/structure/window_frame/frame_path = /obj/structure/window_frame

						sprite_icon.Blend(icon(icon = initial(frame_path.grille_black_icon), icon_state = "[initial(frame_path.grille_icon_state)]_black-[0]"), ICON_OVERLAY)
						sprite_icon.Blend(icon(icon = initial(frame_path.grille_icon), icon_state = "[initial(frame_path.grille_icon_state)]-[0]"), ICON_OVERLAY)
						sprite_icon.Blend(icon(icon = initial(path.icon), icon_state = initial(path.icon_state)), ICON_OVERLAY)
					else
						sprite_icon = icon(icon = initial(path.icon), icon_state = initial(path.icon_state))

				//icons for solid airlocks have an added solid overlay on top of their glass icons
				else if(ispath(path, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/airlock_path = path
					var/airlock_icon = initial(airlock_path.icon)

					sprite_icon = icon(icon = airlock_icon, icon_state = "closed", dir = SOUTH)
					if(!initial(airlock_path.glass))
						sprite_icon.Blend(icon(icon = airlock_icon, icon_state = "fill_closed"), ICON_OVERLAY)

				//for all other icons we load the paths default icon & icon state
				else
					sprite_icon = icon(icon = initial(path.icon), icon_state = initial(path.icon_state), dir = SOUTH)

				Insert(sanitize_css_class_name(sprite_name), sprite_icon)
