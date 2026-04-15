/// Assoc list of z-levels to `/datum/minimap` instances.
GLOBAL_ALIST_EMPTY(minimaps)

/// Represents a minimap for a single Z-level.
/datum/minimap
	/// The icon of the base map itself.
	var/icon/base_map
	/// Mapping of x/y coords to area names.
	var/alist/map_position_to_name = alist()

/datum/minimap/proc/load_z(z)
	. = FALSE
	if(!isnum(z) || z > length(SSmapping.z_list))
		CRASH("Tried to create minimap for invalid Z-level ([z])")
	base_map = icon('icons/ui_icons/minimap/minimap.dmi')

	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1

	map_position_to_name.Cut()
	for(var/turf/location as anything in Z_TURFS(z))
		if(location.skip_minimap_rendering || isshuttleturf(location))
			continue
		var/area/arealoc = location.loc
		if(arealoc.skip_minimap_rendering)
			continue
		var/x = location.x
		var/y = location.y
		min_x = min(min_x, x)
		min_y = min(min_y, y)
		max_x = max(max_x, x)
		max_y = max(max_y, y)
		map_position_to_name["[x]:[y]"] = arealoc.name
		if(location.density)
			base_map.DrawBox(location.tacmap_color, x, y)
			continue
		var/atom/movable/alttarget = (locate(/obj/machinery/door) in location) || (locate(/obj/structure/window) in location) || (locate(/obj/structure/fence) in location)
		if(alttarget)
			base_map.DrawBox(alttarget.tacmap_color, x, y)
			continue
		if(arealoc.tacmap_color)
			base_map.DrawBox(BlendRGB(location.tacmap_color, arealoc.tacmap_color, 0.5), x, y)
			continue
		if(istype(location, /turf/open/floor/engine/hull))
			var/turf/turf_below = GET_TURF_BELOW(location)
			var/area/below_area = turf_below?.loc
			// we'll draw the below area's color but transparent
			if(below_area?.tacmap_color)
				var/list/below_color = rgb2num(below_area.tacmap_color)
				base_map.DrawBox(rgb(below_color[1], below_color[2], below_color[3], 64), x, y)
				continue
		base_map.DrawBox(location.tacmap_color, x, y)

	base_map.Crop(min_x, min_y, max_x, max_y)
	base_map.Scale(base_map.Width() * 2, base_map.Height() * 2)
	return TRUE

/client/verb/debug_generate_maps()
	set name = "MINIMAP GENERATION TEST (Debug)"
	set desc = "meow meow meow"
	set category = "mrrrp mrrrp mrrrow"

	GLOB.minimaps.Cut()

	rustg_time_reset("meow_all")
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/datum/minimap/z_minimap = new
		GLOB.minimaps[z] = z_minimap
		rustg_time_reset("meow")
		z_minimap.load_z(z)
		var/time_ms = rustg_time_milliseconds("meow")
		message_admins("Minimap generated for Z [z] in [time_ms] ms")
		fcopy(z_minimap.base_map, "tmp/minimaps/minimap_[SSmapping.current_map.map_name].[z].png")
	var/total_ms = rustg_time_milliseconds("meow_all")
	message_admins("total generation time of [total_ms] ms")

/// Gets the `/datum/minimap` for a Z-level - generating it if it hasn't been yet.
/proc/get_minimap_for_z(z) as /datum/minimap
	if(GLOB.minimaps[z])
		return GLOB.minimaps[z]
	var/datum/minimap/minimap = new
	if(minimap.load_z(z))
		GLOB.minimaps[z] = minimap
		return minimap

/// Screen object that renders a [/datum/minimap] base map icon on the HUD.
/atom/movable/screen/minimap_display
	name = "Minimap"
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER

/client/verb/debug_toggle_minimap()
	set name = "MINIMAP DISPLAY TEST (Debug)"
	set desc = "Toggle the rewrite minimap on your HUD."
	set category = "mrrrp mrrrp mrrrow"

	var/datum/hud/hud = mob.hud_used
	if(!hud)
		to_chat(src, "No HUD found.")
		return

	// Toggle off if already visible.
	if(hud.screen_objects["debug_minimap_display"])
		hud.remove_screen_object("debug_minimap_display")
		to_chat(src, "Minimap hidden.")
		return

	var/datum/minimap/minimap = get_minimap_for_z(mob.z)
	if(!minimap)
		to_chat(src, "No minimap generated for z=[mob.z].")
		return

	var/atom/movable/screen/minimap_display/display = new(null, hud)
	display.icon = minimap.base_map
	var/map_width = minimap.base_map.Width()
	var/map_height = minimap.base_map.Height()
	display.screen_loc = "1:[map_width / 2],1:[map_height / 2]"
	hud.add_screen_object(display, "debug_minimap_display", HUD_GROUP_STATIC, update_screen = TRUE)
	to_chat(src, "Minimap shown for z=[mob.z].")
