#define MAPHEADER "<script type=\"text/javascript\" src=\"3-jquery.timers.js\"></script><script type=\"text/javascript\" src=\"libraries.min.js\"></script><link rel=\"stylesheet\" type=\"text/css\" href=\"html_interface_icons.css\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"map_shared.css\" /><script type=\"text/javascript\" src=\"map_shared.js\">"
#define MAPCONTENT "<div id='switches'><a href=\"javascript:switchTo(0);\">Switch to mini map</a> <a href=\"javascript:switchTo(1);\">Switch to text-based</a> <a href='javascript:changezlevels();'>Change Z-Level</a> </div><div id=\"uiMapContainer\"><div id=\"uiMap\" unselectable=\"on\"></div></div><div id=\"textbased\"></div>"
// Base datum for html_interface interactive maps.
var/const/MAX_ICON_DIMENSION = 1024
var/const/ICON_SIZE = 4
var/const/ALLOW_CENTCOMM = FALSE

/datum/interactive_map
	var/list/interfaces
	var/list/data
/datum/interactive_map/New()
	. = ..()
	src.interfaces = list()
	src.data = list()

/datum/interactive_map/Destroy()
	if (src.interfaces)
		for (var/datum/html_interface/hi in interfaces)
			Destroy(hi)
		src.interfaces = null

	return ..()

//Override this to show the user the interface
/datum/interactive_map/proc/show(mob/mob, z)

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/interactive_map/proc/show() called tick#: [world.time]")


/datum/interactive_map/proc/updateFor(hclient_or_mob, datum/html_interface/hi, z)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\datum/interactive_map/proc/updateFor() called tick#: [world.time]")
	// This check will succeed if updateFor is called after showing to the player, but will fail
	// on regular updates. Since we only really need this once we don't care if it fails.
	hi.callJavaScript("clearAll", new/list(), hclient_or_mob)
	for (var/list/L in data)
		hi.callJavaScript("add", L, hclient_or_mob)

// Override this to update an interface
/datum/interactive_map/proc/update(z, ignore_unused = FALSE)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/interactive_map/proc/update() called tick#: [world.time]")

/datum/interactive_map/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\datum/interactive_map/proc/hiIsValidClient() called tick#: [world.time]")
	return (hclient.client.mob && hclient.client.mob.stat == CONSCIOUS)

/datum/interactive_map/Topic(href, href_list[], datum/html_interface_client/hclient, datum/html_interface/currui)
	..()
	if (istype(hclient))
		if(hclient && hclient.client && hclient.client.mob)
			var/mob/living/L = hclient.client.mob
			if(!istype(L)) return
			switch (href_list["action"])
				if("changez")
					var/newz = text2num(href_list["value"])
					if(newz)
						show(L,newz,currui)
						return 1 //Tell children we handled the topic

// Override this to queue an interface to be updated
/datum/interactive_map/proc/queueUpdate(z)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/interactive_map/proc/queueUpdate() called tick#: [world.time]")

/proc/generateMiniMaps()
	//spawn // NO
	for (var/z = 1 to world.maxz)
		if(z == CENTCOMM_Z && !ALLOW_CENTCOMM) continue
		generateMiniMap(z)

	testing("MINIMAP: All minimaps have been generated.")
	minimapinit = 1
	// some idiot put HTML asset sending here.  In a spawn.  After a long wait for minimap generation.
	// Dear Idiot: don't do that anymore.
	// You can put MINIMAP sending here, but we need HTML assets ASAP for character editing.
	//for (var/client/C in clients)
	//	C.send_html_resources()


/datum/interactive_map/proc/sendResources(client/C)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/interactive_map/proc/sendResources() called tick#: [world.time]")
	C << browse_rsc('map_shared.js')
	C << browse_rsc('map_shared.css')
	for (var/z = 1 to world.maxz)
		if(z == CENTCOMM_Z) continue
		C << browse_rsc(file("[getMinimapFile(z)].png"), "minimap_[z].png")

/proc/getMinimapFile(z)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/getMinimapFile() called tick#: [world.time]")
	return "data/minimaps/map_[z]"

// Activate this to debug tile mismatches in the minimap.
// This will store the full information on each tile and compare it the next time you run the minimap.
// It can be used to find out what's changed since the last iteration.
// Only activate this when you need it - this should never be active on a live server!
// #define MINIMAP_DEBUG

/proc/generateMiniMap(z, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/generateMiniMap() called tick#: [world.time]")
	var/result_path = "[getMinimapFile(z)].png"
	var/hash_path = "[getMinimapFile(z)].md5"
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
		if      (istype(tile.loc, /area/asteroid) || istype(tile.loc, /area/mine/unexplored) || istype(tile, /turf/unsimulated/mineral) || (tile.loc.name == "Space" && istype(tile, /turf/unsimulated/floor/asteroid)))
			temp = "/area/asteroid"
		else if (istype(tile.loc, /area/mine) && istype(tile, /turf/unsimulated/floor/asteroid))
			temp = "/area/mine/explored"
		else if (tile.loc.type == /area/start || (tile.type == /turf/space && !(locate(/obj/structure/lattice) in tile)) || istype(tile, /turf/space/transit))
			temp = "/turf/space"
			if (locate(/obj/structure/catwalk) in tile)

			else
		else if (tile.type == /turf/space)
			if (locate(/obj/structure/catwalk) in tile)
				temp = "/obj/structure/lattice/catwalk"
			else
				temp = "/obj/structure/lattice"
		else if (tile.type == /turf/simulated/floor/plating && (locate(/obj/structure/shuttle/window) in tile))
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

		testing("MINIMAP: Generating minimap for z-level [z].")

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
				if (istype(tile.loc, /area/asteroid) || istype(tile.loc, /area/mine/unexplored) || istype(tile, /turf/unsimulated/mineral) || (tile.loc.name == "Space" && istype(tile, /turf/unsimulated/floor/asteroid)))
					new_icon = 'icons/turf/walls.dmi'
					new_icon_state = "rock"
					new_dir = 2
				else if (istype(tile.loc, /area/mine) && istype(tile, /turf/unsimulated/floor/asteroid))
					new_icon = 'icons/turf/floors.dmi'
					new_icon_state = "asteroid"
					new_dir = 2
				else if (tile.type == /turf/space)
					obj = locate(/obj/structure/lattice) in tile

					if (!obj) obj = locate(/obj/structure/transit_tube) in tile

					ASSERT(obj != null)

					if (obj)
						new_icon = obj.icon
						new_dir = obj.dir
						new_icon_state = obj.icon_state
				else if (tile.type == /turf/simulated/floor/plating && (locate(/obj/structure/shuttle/window) in tile))
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

				if ((i % 1024) == 0) testing("MINIMAP: Generated [i] of [tiles.len] tiles.")
			else
				sleep(-1) // avoid sleeping if possible: prioritize pending procs

		testing("MINIMAP: Generated [tiles.len] of [tiles.len] tiles.")

		// BYOND BUG: map_icon now contains 4 directions? Create a new icon with only a single state.
		var/icon/result_icon = new/icon()

		result_icon.Insert(map_icon, "", SOUTH, 1, 0)

		fcopy(result_icon, result_path)
		text2file(hash, hash_path)

#ifdef MINIMAP_DEBUG
#undef MINIMAP_DEBUG
#endif
