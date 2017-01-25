var/datum/subsystem/minimap/SSminimap

/datum/subsystem/minimap
	name = "Minimap"
	init_order = -2
	flags = SS_NO_FIRE
	var/const/MINIMAP_SIZE = 2048
	var/const/TILE_SIZE = 8

	var/list/z_levels = list(ZLEVEL_STATION)

/datum/subsystem/minimap/New()
	NEW_SS_GLOBAL(SSminimap)

/datum/subsystem/minimap/Initialize(timeofday)
	var/hash = md5(file2text("_maps/[MAP_PATH]/[MAP_FILE]"))
	if(config.generate_minimaps)
		if(hash == trim(file2text(hash_path())))
			for(var/z in z_levels)	//We have these files cached, let's register them
				register_asset("minimap_[z].png", fcopy_rsc(map_path(z)))
			return ..()
		for(var/z in z_levels)
			generate(z)
			register_asset("minimap_[z].png", fcopy_rsc(map_path(z)))
		fdel(hash_path())
		text2file(hash, hash_path())
	else
		world << "<span class='boldannounce'>Minimap generation disabled. Loading from cache...</span>"
		var/fileloc = 0
		if(check_files(0))	//Let's first check if we have maps cached in the data folder. NOTE: This will override the backup files even if this map is older.
			if(hash != trim(file2text(hash_path())))
				world << "<span class='boldannounce'>Loaded cached minimap is outdated. There may be minor discrepancies in layout.</span>"	//Disclaimer against players saying map is wrong.
			fileloc = 0
		else
			if(!check_files(1))
				world << "<span class='boldannounce'>Failed to load backup minimap file. Aborting.</span>"	//We couldn't find something. Bail to prevent issues with null files
				return
			fileloc = 1	//No map image cached with the current map, and we have a backup. Let's fall back to it.
			world << "<span class='boldannounce'>No cached minimaps detected. Backup files loaded.</span>"
		for(var/z in z_levels)
			register_asset("minimap_[z].png", fcopy_rsc(map_path(z,fileloc)))
	..()

/datum/subsystem/minimap/proc/check_files(backup)	// If the backup argument is true, looks in the icons folder. If false looks in the data folder.
	for(var/z in z_levels)
		if(!fexists(file(map_path(z,backup))))	//Let's make sure we have a file for this map
			if(backup)
				world.log << "Failed to find backup file for map [MAP_NAME] on zlevel [z]."
			return FALSE
	return TRUE


/datum/subsystem/minimap/proc/hash_path(backup)
	if(backup)
		return "icons/minimaps/[MAP_NAME].md5"
	else
		return "data/minimaps/[MAP_NAME].md5"

/datum/subsystem/minimap/proc/map_path(z,backup)
	if(backup)
		return "icons/minimaps/[MAP_NAME]_[z].png"
	else
		return "data/minimaps/[MAP_NAME]_[z].png"

/datum/subsystem/minimap/proc/send(client/client)
	for(var/z in z_levels)
		send_asset(client, "minimap_[z].png")

/datum/subsystem/minimap/proc/generate(z = 1, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy)
	// Load the background.
	var/icon/minimap = new /icon('icons/minimap.dmi')
	// Scale it up to our target size.
	minimap.Scale(MINIMAP_SIZE, MINIMAP_SIZE)

	// Loop over turfs and generate icons.
	for(var/T in block(locate(x1, y1, z), locate(x2, y2, z)))
		generate_tile(T, minimap)

	// Create a new icon and insert the generated minimap, so that BYOND doesn't generate different directions.
	var/icon/final = new /icon()
	final.Insert(minimap, "", SOUTH, 1, 0)
	fcopy(final, map_path(z))

/datum/subsystem/minimap/proc/generate_tile(turf/tile, icon/minimap)
	var/icon/tile_icon
	var/obj/obj
	var/list/obj_icons
	// Don't use icons for space, just add objects in space if they exist.
	if(isspaceturf(tile))
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
		obj_icons = list()

		obj = locate(/obj/structure) in tile
		if(obj)
			obj_icons += new /icon(obj.icon, obj.icon_state, obj.dir, 1, 0)
		obj = locate(/obj/machinery) in tile
		if(obj)
			obj_icons += new /icon(obj.icon, obj.icon_state, obj.dir, 1, 0)
		obj = locate(/obj/structure/window) in tile
		if(obj)
			obj_icons += new /icon('icons/obj/smooth_structures/window.dmi', "window", SOUTH)
		obj = locate(/obj/structure/table) in tile
		if(obj)
			obj_icons += new /icon('icons/obj/smooth_structures/table.dmi', "table", SOUTH)
		for(var/I in obj_icons)
			var/icon/obj_icon = I
			tile_icon.Blend(obj_icon, ICON_OVERLAY)

	if(tile_icon)
		// Scale the icon.
		tile_icon.Scale(TILE_SIZE, TILE_SIZE)
		// Add the tile to the minimap.
		minimap.Blend(tile_icon, ICON_OVERLAY, ((tile.x - 1) * TILE_SIZE), ((tile.y - 1) * TILE_SIZE))
