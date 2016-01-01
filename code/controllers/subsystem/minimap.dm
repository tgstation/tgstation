// Activate this to debug tile mismatches in the minimap.
// This will store the full information on each tile and compare it the next time you run the minimap.
// It can be used to find out what's changed since the last iteration.
// Only activate this when you need it - this should never be active on a live server!
// #define MINIMAP_DEBUG

var/datum/subsystem/minimap/SSminimap

/datum/subsystem/minimap
	name = "Minimap"
	priority = -2

	var/const/MAX_ICON_DIMENSION = 1024
	var/const/ICON_SIZE = 4

/datum/subsystem/minimap/New()
	NEW_SS_GLOBAL(SSminimap)

/datum/subsystem/minimap/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	for(var/z = 1 to ZLEVEL_SPACEMAX)
		generate(z)
	for (var/z = 1 to ZLEVEL_SPACEMAX)
		register_asset("minimap_[z].png", file("[getMinimapFile(z)].png"))
	..()

/datum/subsystem/minimap/proc/generate(z, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy)
	var/result_path = "[src.getMinimapFile(z)].png"
	var/hash_path = "[src.getMinimapFile(z)].md5"
	var/list/tiles = block(locate(x1, y1, z), locate(x2, y2, z))
	var/hash = ""
	var/temp
	var/obj/obj

	#ifdef MINIMAP_DEBUG
	var/tiledata_path = "data/minimaps/debug_tiledata_[z].sav"
	var/savefile/F = new/savefile(tiledata_path)
	#endif

	// Note for future developer: If you have tiles on the map with random or dynamic icons this hash check will fail
	// every time. You'll have to modify this code to generate a unique hash for your object.
	// Don't forget to modify the minimap generation code to use a default icon (or skip generation altogether).
	for (var/turf/tile in tiles)
		if      (istype(tile.loc, /area/asteroid) || istype(tile.loc, /area/mine/unexplored) || istype(tile, /turf/simulated/mineral) || (istype(tile.loc, /area/space) && istype(tile, /turf/simulated/floor/plating/asteroid)))
			temp = "/area/asteroid"
		else if (istype(tile.loc, /area/mine) && istype(tile, /turf/simulated/floor/plating/asteroid))
			temp = "/area/mine/explored"
		else if (tile.loc.type == /area/start || (tile.type == /turf/space && !(locate(/obj/structure/lattice) in tile)) || istype(tile, /turf/space/transit))
			temp = "/turf/space"
			if (locate(/obj/structure/lattice/catwalk) in tile)

			else
		else if (tile.type == /turf/space)
			if (locate(/obj/structure/lattice/catwalk) in tile)
				temp = "/obj/structure/lattice/catwalk"
			else
				temp = "/obj/structure/lattice"
		else if (tile.type == /turf/simulated/floor/plating/abductor)
			temp = "/turf/simulated/floor/plating/abductor"
		else if (tile.type == /turf/simulated/floor/plating && (locate(/obj/structure/window/shuttle) in tile))
			temp = "/obj/structure/window/shuttle"
		else
			temp = "[tile.icon][tile.icon_state][tile.dir]"

		obj = locate(/obj/structure/transit_tube) in tile

		if (obj) temp = "[temp]/obj/structure/transit_tube[obj.icon_state][obj.dir]"

		#ifdef MINIMAP_DEBUG
		if (F["/[tile.y]/[tile.x]"] && F["/[tile.y]/[tile.x]"] != temp)
			CRASH("Mismatch: [tile.type] at [tile.x],[tile.y],[tile.z] ([tile.icon], [tile.icon_state], [tile.dir])")
		else
			F["/[tile.y]/[tile.x]"] << temp
		#endif

		hash = md5("[hash][temp]")

	if (fexists(result_path))
		if (!fexists(hash_path) || trim(file2text(hash_path)) != hash)
			fdel(result_path)
			fdel(hash_path)

	if (!fexists(result_path))
		ASSERT(x1 > 0)
		ASSERT(y1 > 0)
		ASSERT(x2 <= world.maxx)
		ASSERT(y2 <= world.maxy)

		var/icon/map_icon = new/icon('html/mapbase1024.png')

		// map_icon is fine and contains only 1 direction at this point.

		ASSERT(map_icon.Width() == MAX_ICON_DIMENSION && map_icon.Height() == MAX_ICON_DIMENSION)


		var/i = 0
		var/icon/turf_icon
		var/icon/obj_icon
		var/old_icon
		var/old_icon_state
		var/old_dir
		var/new_icon
		var/new_icon_state
		var/new_dir

		for (var/turf/tile in tiles)
			if (tile.loc.type != /area/start && (tile.type != /turf/space || (locate(/obj/structure/lattice) in tile) || (locate(/obj/structure/transit_tube) in tile)) && !istype(tile, /turf/space/transit))
				if (istype(tile.loc, /area/asteroid) || istype(tile.loc, /area/mine/unexplored) || istype(tile, /turf/simulated/mineral) || (istype(tile.loc, /area/space) && istype(tile, /turf/simulated/floor/plating/asteroid)))
					new_icon = 'icons/turf/mining.dmi'
					new_icon_state = "rock"
					new_dir = 2
				else if (istype(tile.loc, /area/mine) && istype(tile, /turf/simulated/floor/plating/asteroid))
					new_icon = 'icons/turf/floors.dmi'
					new_icon_state = "asteroid"
					new_dir = 2
				else if (tile.type == /turf/simulated/floor/plating/abductor)
					new_icon = 'icons/turf/floors.dmi'
					new_icon_state = "alienpod1"
					new_dir = 2
				else if (tile.type == /turf/space)
					obj = locate(/obj/structure/lattice) in tile

					if (!obj) obj = locate(/obj/structure/transit_tube) in tile

					ASSERT(obj != null)

					if (obj)
						new_icon = obj.icon
						new_dir = obj.dir
						new_icon_state = obj.icon_state
				else if (tile.type == /turf/simulated/floor/plating && (locate(/obj/structure/window/shuttle) in tile))
					new_icon = 'icons/obj/structures.dmi'
					new_dir = 2
					new_icon_state = "swindow"
				else
					new_icon = tile.icon
					new_icon_state = tile.icon_state
					new_dir = tile.dir

				if (new_icon != old_icon || new_icon_state != old_icon_state || new_dir != old_dir)
					old_icon = new_icon
					old_icon_state = new_icon_state
					old_dir = new_dir

					turf_icon = new/icon(new_icon, new_icon_state, new_dir, 1, 0)
					turf_icon.Scale(ICON_SIZE, ICON_SIZE)

				if (tile.type != /turf/space || (locate(/obj/structure/lattice) in tile))
					obj = locate(/obj/structure/transit_tube) in tile

					if (obj)
						obj_icon = new/icon(obj.icon, obj.icon_state, obj.dir, 1, 0)
						obj_icon.Scale(ICON_SIZE, ICON_SIZE)
						turf_icon.Blend(obj_icon, ICON_OVERLAY)

				map_icon.Blend(turf_icon, ICON_OVERLAY, ((tile.x - 1) * ICON_SIZE), ((tile.y - 1) * ICON_SIZE))

				if ((++i) % 512 == 0) sleep(1) // deliberate delay to avoid lag spikes

			else
				sleep(-1) // avoid sleeping if possible: prioritize pending procs

		// BYOND BUG: map_icon now contains 4 directions? Create a new icon with only a single state.
		var/icon/result_icon = new/icon()

		result_icon.Insert(map_icon, "", SOUTH, 1, 0)

		fcopy(result_icon, result_path)
		text2file(hash, hash_path)

/datum/subsystem/minimap/proc/getMinimapFile(zlevel)
	return "data/minimaps/[MAP_NAME]_[zlevel]"

/datum/subsystem/minimap/proc/sendMinimaps(client/client)
	for (var/z = 1 to world.maxz)
		send_asset(client, "minimap_[z].png")

#ifdef MINIMAP_DEBUG
#undef MINIMAP_DEBUG
#endif