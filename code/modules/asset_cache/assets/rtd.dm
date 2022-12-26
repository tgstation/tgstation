/datum/asset/spritesheet/rtd
	name = "rtd-tgui"

/datum/asset/spritesheet/rtd/create_spritesheets()
	var/list/tiles = list(
		/obj/item/stack/tile/iron,
		/obj/item/stack/tile/iron/edge,
		/obj/item/stack/tile/iron/half,
		/obj/item/stack/tile/iron/corner,
		/obj/item/stack/tile/iron/large,
		/obj/item/stack/tile/iron/small,
		/obj/item/stack/tile/iron/diagonal,
		/obj/item/stack/tile/iron/herringbone,
		/obj/item/stack/tile/iron/textured,
		/obj/item/stack/tile/iron/textured_edge,
		/obj/item/stack/tile/iron/textured_half,
		/obj/item/stack/tile/iron/textured_corner,
		/obj/item/stack/tile/iron/textured_large,
		/obj/item/stack/tile/iron/dark,
		/obj/item/stack/tile/iron/dark/smooth_edge,
		/obj/item/stack/tile/iron/dark/smooth_half,
		/obj/item/stack/tile/iron/dark/smooth_corner,
		/obj/item/stack/tile/iron/dark/smooth_large,
		/obj/item/stack/tile/iron/dark/small,
		/obj/item/stack/tile/iron/dark/diagonal,
		/obj/item/stack/tile/iron/dark/herringbone,
		/obj/item/stack/tile/iron/dark_side,
		/obj/item/stack/tile/iron/dark_corner,
		/obj/item/stack/tile/iron/checker,
		/obj/item/stack/tile/iron/dark/textured,
		/obj/item/stack/tile/iron/dark/textured_edge,
		/obj/item/stack/tile/iron/dark/textured_half,
		/obj/item/stack/tile/iron/dark/textured_corner,
		/obj/item/stack/tile/iron/dark/textured_large,
		/obj/item/stack/tile/iron/white,
		/obj/item/stack/tile/iron/white/smooth_edge,
		/obj/item/stack/tile/iron/white/smooth_half,
		/obj/item/stack/tile/iron/white/smooth_corner,
		/obj/item/stack/tile/iron/white/smooth_large,
		/obj/item/stack/tile/iron/white/small,
		/obj/item/stack/tile/iron/white/diagonal,
		/obj/item/stack/tile/iron/white/herringbone,
		/obj/item/stack/tile/iron/white_side,
		/obj/item/stack/tile/iron/white_corner,
		/obj/item/stack/tile/iron/cafeteria,
		/obj/item/stack/tile/iron/white/textured,
		/obj/item/stack/tile/iron/white/textured_edge,
		/obj/item/stack/tile/iron/white/textured_half,
		/obj/item/stack/tile/iron/white/textured_corner,
		/obj/item/stack/tile/iron/white/textured_large,
		/obj/item/stack/tile/iron/recharge_floor,
		/obj/item/stack/tile/iron/smooth,
		/obj/item/stack/tile/iron/smooth_edge,
		/obj/item/stack/tile/iron/smooth_half,
		/obj/item/stack/tile/iron/smooth_corner,
		/obj/item/stack/tile/iron/smooth_large,
		/obj/item/stack/tile/iron/terracotta,
		/obj/item/stack/tile/iron/terracotta/small,
		/obj/item/stack/tile/iron/terracotta/diagonal,
		/obj/item/stack/tile/iron/terracotta/herringbone,
		/obj/item/stack/tile/iron/kitchen,
		/obj/item/stack/tile/iron/kitchen/small,
		/obj/item/stack/tile/iron/kitchen/diagonal,
		/obj/item/stack/tile/iron/kitchen/herringbone,
		/obj/item/stack/tile/iron/chapel,
		/obj/item/stack/tile/iron/showroomfloor,
		/obj/item/stack/tile/iron/solarpanel,
		/obj/item/stack/tile/iron/freezer,
		/obj/item/stack/tile/iron/grimy,
		/obj/item/stack/tile/iron/sepia,
		/obj/item/stack/tile/glass,
		/obj/item/stack/tile/rglass,
		/obj/item/stack/tile/circuit,
		/obj/item/stack/tile/circuit/green,
		/obj/item/stack/tile/circuit/red,
	)

	for(var/obj/item/stack/tile/tile as anything in tiles)
		var/icon_state = initial(tile.icon_state)
		Insert(sprite_name = icon_state , I = 'icons/obj/tiles.dmi', icon_state = icon_state)

		var/list/tile_directions = GLOB.tile_rotations[initial(tile.singular_name)]
		if(tile_directions == null)
			continue

		for(var/direction as anything in tile_directions)
			var/icon/img = icon(icon = 'icons/obj/tiles.dmi', icon_state = icon_state)
			switch(direction)
				if(NORTH)
					img.Turn(-180)
				if(WEST)
					img.Turn(90)
				if(EAST)
					img.Turn(-90)
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
