/datum/asset/spritesheet/rtd
	name = "rtd"

/datum/asset/spritesheet/rtd/create_spritesheets()
	//some tiles may share the same icon but have different properties to animate that icon
	//so we keep track of what icons we registered
	var/list/registered = list()

	for(var/main_root in GLOB.floor_designs)
		for(var/sub_category in GLOB.floor_designs[main_root])
			for(var/list/design in  GLOB.floor_designs[main_root][sub_category])
				var/obj/item/stack/tile/type = design["type"]
				var/icon_state = initial(type.icon_state)
				if(registered[icon_state])
					continue

				Insert(sprite_name = icon_state, I = 'icons/obj/tiles.dmi', icon_state = icon_state)
				registered[icon_state] = TRUE

				var/list/tile_directions = design["tile_rotate_dirs"]
				if(tile_directions == null)
					continue

				for(var/direction as anything in tile_directions)
					//we can rotate the icon is css for these directions
					if(direction in GLOB.tile_dont_rotate)
						continue

					//but for these directions we have to do some hacky stuff
					var/icon/img = icon(icon = 'icons/obj/tiles.dmi', icon_state = icon_state)
					switch(direction)
						if(NORTHEAST)
							img.Turn(-180)
							var/icon/east_rotated = icon(icon = 'icons/obj/tiles.dmi', icon_state = icon_state)
							east_rotated.Turn(-90)
							img.Blend(east_rotated,ICON_MULTIPLY)
							img.SetIntensity(2,2,2)
						if(NORTHWEST)
							img.Turn(-180)
							var/icon/west_rotated = icon(icon = 'icons/obj/tiles.dmi', icon_state = icon_state)
							west_rotated.Turn(90)
							img.Blend(west_rotated,ICON_MULTIPLY)
							img.SetIntensity(2,2,2)
						if(SOUTHEAST)
							var/icon/east_rotated = icon(icon = 'icons/obj/tiles.dmi', icon_state = icon_state)
							east_rotated.Turn(-90)
							img.Blend(east_rotated,ICON_MULTIPLY)
							img.SetIntensity(2,2,2)
						if(SOUTHWEST)
							var/icon/west_rotated = icon(icon = 'icons/obj/tiles.dmi', icon_state = icon_state)
							west_rotated.Turn(90)
							img.Blend(west_rotated,ICON_MULTIPLY)
							img.SetIntensity(2,2,2)
					Insert(sprite_name = "[icon_state]-[dir2text(direction)]", I = img)
