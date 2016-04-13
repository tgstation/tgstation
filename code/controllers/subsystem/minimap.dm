var/datum/subsystem/minimap/SSminimap

/datum/subsystem/minimap
	name = "Minimap"
	priority = -2

	var/const/MINIMAP_SIZE = 2048
	var/const/TILE_SIZE = 8

	var/list/z_levels = list(ZLEVEL_STATION)

/datum/subsystem/minimap/New()
	NEW_SS_GLOBAL(SSminimap)

/datum/subsystem/minimap/Initialize(timeofday, zlevel)
	if(zlevel)
		return ..()
	if(!config.generate_minimaps)
		world << "Minimap generation disabled... Skipping"
		return
	var/hash = md5(file2text("_maps/[MAP_PATH]/[MAP_FILE]"))
	if(hash == trim(file2text(hash_path())))
		return ..()

	for(var/z in z_levels)
		generate(z)
		register_asset("minimap_[z].png", fcopy_rsc(map_path(z)))
	fdel(hash_path())
	text2file(hash, hash_path())
	..()

/datum/subsystem/minimap/proc/hash_path()
	return "data/minimaps/[MAP_NAME].md5"

/datum/subsystem/minimap/proc/map_path(z)
	return "data/minimaps/[MAP_NAME]_[z].png"

/datum/subsystem/minimap/proc/send(client/client)
	for(var/z in z_levels)
		send_asset(client, "minimap_[z].png")

/datum/subsystem/minimap/proc/generate(z = 1, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy)
	// Load the background.
	var/icon/minimap = new /icon('icons/minimap.dmi')
	// Scale it up to our target size.
	minimap.Scale(MINIMAP_SIZE, MINIMAP_SIZE)

	var/counter = 512
	// Loop over turfs and generate icons.
	for(var/T in block(locate(x1, y1, z), locate(x2, y2, z)))
		generate_tile(T, minimap)

		//byond bug, this fixes OOM crashes by flattening and reseting the minimap icon holder every so and so tiles
		counter--
		if(counter <= 0)
			counter = 512
			var/icon/flatten = new /icon()
			flatten.Insert(minimap, "", SOUTH, 1, 0)
			del(minimap)
			minimap = flatten
			stoplag() //we have to sleep in order to get byond to clear out the proc's garbage bin

		CHECK_TICK


	// Create a new icon and insert the generated minimap, so that BYOND doesn't generate different directions.
	var/icon/final = new /icon()
	final.Insert(minimap, "", SOUTH, 1, 0)
	fcopy(final, map_path(z))

/datum/subsystem/minimap/proc/generate_tile(turf/tile, icon/minimap)
	var/icon/tile_icon
	var/obj/obj
	var/list/obj_icons = list()
	// Don't use icons for space, just add objects in space if they exist.
	if(istype(tile, /turf/open/space))
		obj = locate(/obj/structure/lattice/catwalk) in tile
		if(obj)
			tile_icon = new /icon('icons/obj/smooth_structures/catwalk.dmi', "catwalk", SOUTH)
		obj = locate(/obj/structure/lattice) in tile
		if(obj)
			tile_icon = new /icon('icons/obj/smooth_structures/lattice.dmi', "lattice", SOUTH)
		obj = locate(/obj/structure/grille) in tile
		if(obj)
			tile_icon = new /icon('icons/obj/structures.dmi', "grille", SOUTH)
		obj = locate(/obj/structure/transit_tube) in tile
		if(obj)
			tile_icon = new /icon('icons/obj/atmospherics/pipes/transit_tube.dmi', obj.icon_state, obj.dir)
	else
		tile_icon = new /icon(tile.icon, tile.icon_state, tile.dir)
		obj_icons.Cut()

		obj = locate(/obj/structure) in tile
		if(obj)
			obj_icons += getFlatIcon(obj)
		obj = locate(/obj/machinery) in tile
		if(obj)
			obj_icons += new /icon(obj.icon, obj.icon_state, obj.dir, 1, 0)
		obj = locate(/obj/structure/window) in tile
		if(obj)
			obj_icons += new /icon('icons/obj/smooth_structures/window.dmi', "window", SOUTH)

		for(var/I in obj_icons)
			var/icon/obj_icon = I
			tile_icon.Blend(obj_icon, ICON_OVERLAY)

	if(tile_icon)
		// Scale the icon.
		tile_icon.Scale(TILE_SIZE, TILE_SIZE)
		// Add the tile to the minimap.
		minimap.Blend(tile_icon, ICON_OVERLAY, ((tile.x - 1) * TILE_SIZE), ((tile.y - 1) * TILE_SIZE))
		del(tile_icon)
