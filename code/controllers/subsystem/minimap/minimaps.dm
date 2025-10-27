/**
 *  # Minimaps subsystem
 *
 * Handles updating and handling of the by-zlevel minimaps
 *
 * Minimaps are a low priority subsystem that fires relatively often
 * the Initialize proc for this subsystem draws the maps as one of the last initializing subsystems
 *
 * Fire() for this subsystem doens't actually updates anything, and purely just reapplies the overlays that it already tracks
 * actual updating of marker locations is handled by [/datum/tactical_map/proc/on_move]
 * and zlevel changes are handled in [/datum/tactical_map/proc/on_z_change]
 * tracking of the actual atoms you want to be drawn on is done by means of datums holding info pertaining to them with [/datum/hud_displays]
 *
 * Todo
 * *: add fetching of images to allow stuff like adding/removing xeno crowns easily
 * *: add a system for viscontents so things like minimap draw are more responsive
 */

// Minimap datum that is created only when needed
/datum/tactical_map
	///Minimap hud display datums sorted by zlevel
	var/list/datum/hud_displays/minimaps_by_z = list()
	///Assoc list of images we hold by their source
	var/list/image/images_by_source = list()
	///the update target datums, sorted by update flag type
	var/list/update_targets = list()
	///Nonassoc list of updators we want to have their overlays reapplied
	var/list/datum/minimap_updator/update_targets_unsorted = list()
	///Assoc list of removal callbacks to invoke to remove images from the raw lists
	var/list/datum/callback/removal_cbs = list()
	///list of holders for data relating to tracked zlevel and tracked atum
	var/list/datum/minimap_updator/updators_by_datum = list()
	///assoc list of hash = image of images drawn by players
	var/list/image/drawn_images = list()
	///list of callbacks we need to invoke late because Initialize happens early, or a Z-level was loaded after init
	var/list/list/datum/callback/earlyadds = list()
	///assoc list of minimap objects that are hashed so we have to update as few as possible
	var/list/hashed_minimaps = list()

/// Initialized only when needed
/datum/tactical_map/proc/Initialize()
	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		load_new_z(null, z_level)

/* XANTODO Check this out?
/datum/tactical_map/Recover()
	minimaps_by_z = SSminimaps.minimaps_by_z
	images_by_source = SSminimaps.images_by_source
	update_targets = SSminimaps.update_targets
	update_targets_unsorted = SSminimaps.update_targets_unsorted
	removal_cbs = SSminimaps.removal_cbs
	updators_by_datum = SSminimaps.updators_by_datum
	drawn_images = SSminimaps.drawn_images
*/

/datum/tactical_map/process(seconds_per_tick)
	var/static/iteration = 0
	var/depthcount = 0
	for(var/datum/minimap_updator/updator as anything in update_targets_unsorted)
		if(depthcount < iteration) //under high load update in chunks
			depthcount++
			continue
		updator.minimap.overlays = updator.raw_blips
		depthcount++
		iteration++
/* XANTODO Maybe this exists for a reason lol
		if(MC_TICK_CHECK)
			return
*/
	iteration = 0

///Creates a minimap for a particular z level
/datum/tactical_map/proc/load_new_z(datum/dcs, datum/space_level/z_level)
	SIGNAL_HANDLER

	var/level = z_level.z_value
	minimaps_by_z["[level]"] = new /datum/hud_displays
	if(!is_station_level(level)) //todo: maybe move this around
		return
	var/icon/icon_gen = new('icons/ui_icons/minimap/minimap.dmi') //480x480 blank icon template for drawing on the map
	for(var/xval = 1 to world.maxx)
		for(var/yval = 1 to world.maxy) //Scan all the turfs and draw as needed
			var/turf/location = locate(xval,yval,level)
			if(isspaceturf(location))
				continue
			if(location.density)
				icon_gen.DrawBox(location.tacmap_color, xval, yval)
				continue
			var/atom/movable/alttarget = (locate(/obj/machinery/door) in location) || (locate(/obj/structure/window) in location) || (locate(/obj/structure/fence) in location)
			if(alttarget)
				icon_gen.DrawBox(alttarget.tacmap_color, xval, yval)
				continue
			var/area/turfloc = location.loc
			if(turfloc.tacmap_color)
				icon_gen.DrawBox(BlendRGB(location.tacmap_color, turfloc.tacmap_color, 0.5), xval, yval)
				continue
			icon_gen.DrawBox(location.tacmap_color, xval, yval)
	icon_gen.Scale(480*2,480*2) //scale it up x2 to make it easer to see
	icon_gen.Crop(1, 1, min(icon_gen.Width(), 480), min(icon_gen.Height(), 480)) //then cut all the empty pixels

	//generation is done, now we need to center the icon to someones view,
	//this can be left out if you like it ugly and will halve SSinit time

	//calculate the offset of the icon
	var/largest_x = 0
	var/smallest_x = SCREEN_PIXEL_SIZE
	var/largest_y = 0
	var/smallest_y = SCREEN_PIXEL_SIZE
	for(var/xval=1 to SCREEN_PIXEL_SIZE step 2) //step 2 is twice as fast :)
		for(var/yval=1 to SCREEN_PIXEL_SIZE step 2) //keep in mind 1 wide giant straight lines will offset wierd but you shouldnt be mapping those anyway right???
			if(!icon_gen.GetPixel(xval, yval))
				continue
			if(xval > largest_x)
				largest_x = xval
			else if(xval < smallest_x)
				smallest_x = xval
			if(yval > largest_y)
				largest_y = yval
			else if(yval < smallest_y)
				smallest_y = yval

	minimaps_by_z["[level]"].x_offset = FLOOR((SCREEN_PIXEL_SIZE-largest_x-smallest_x)/2, 1)
	minimaps_by_z["[level]"].y_offset = FLOOR((SCREEN_PIXEL_SIZE-largest_y-smallest_y)/2, 1)

	icon_gen.Shift(EAST, minimaps_by_z["[level]"].x_offset)
	icon_gen.Shift(NORTH, minimaps_by_z["[level]"].y_offset)

	minimaps_by_z["[level]"].hud_image = icon_gen //done making the image!

	//lateload icons
	if(!earlyadds["[level]"])
		return

	for(var/datum/callback/callback as anything in earlyadds["[level]"])
		callback.Invoke()
	earlyadds["[level]"] = null //then clear them

/**
 * Adds an atom to the processing updators that will have blips drawn on them
 * Arguments:
 * * target: the target we want to be updating the overlays on
 * * flags: flags for the types of blips we want to be updated
 * * ztarget: zlevel we want to be updated with
 */
/datum/tactical_map/proc/add_to_updaters(atom/target, flags, ztarget)
	var/datum/minimap_updator/holder = new(target, ztarget)
	for(var/flag in bitfield2list(flags))
		LAZYADD(update_targets["[flag]"], holder)
		holder.raw_blips += minimaps_by_z["[ztarget]"].images_raw["[flag]"]
	updators_by_datum[target] = holder
	update_targets_unsorted += holder
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_updator))

/**
 * Removes a atom from the subsystems updating overlays
 */
/datum/tactical_map/proc/remove_updator(atom/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_QDELETING)
	var/datum/minimap_updator/holder = updators_by_datum[target]
	updators_by_datum -= target
	for(var/key in update_targets)
		LAZYREMOVE(update_targets[key], holder)
	update_targets_unsorted -= holder

/**
 * Holder datum for a zlevels data, concerning the overlays and the drawn level itself
 * The individual image trackers have a raw and a normal list
 * raw lists just store the images, while the normal ones are assoc list of [tracked_atom] = image
 * the raw lists are to speed up the Fire() of the subsystem so we dont have to filter through
 */
/datum/hud_displays
	///Actual icon of the drawn zlevel with all of it's atoms
	var/icon/hud_image
	///Assoc list of updating images; list("[flag]" = list([source] = blip)
	var/list/images_assoc = list()
	///Raw list containing updating images by flag; list("[flag]" = list(blip))
	var/list/images_raw = list()
	///x offset of the actual icon to center it to screens
	var/x_offset = 0
	///y offset of the actual icons to keep it to screens
	var/y_offset = 0

/datum/hud_displays/New()
	..()
	for(var/flag in GLOB.all_minimap_flags)
		images_assoc["[flag]"] = list()
		images_raw["[flag]"] = list()

/**
 * Holder datum to ease updating of atoms to update
 */
/datum/minimap_updator
	/// Atom to update with the overlays
	var/atom/minimap
	///Target zlevel we want to be updating to
	var/ztarget = 0
	/// list of overlays we update
	var/raw_blips

/datum/minimap_updator/New(minimap, ztarget)
	..()
	src.minimap = minimap
	src.ztarget = ztarget
	raw_blips = list()

/**
 * Adds an atom we want to track with blips to the subsystem
 * Arguments:
 * * target: atom we want to track
 * * hud_flags: tracked HUDs we want this atom to be displayed on
 * * marker: image or mutable_appearance we want to be using on the map
 */
/datum/tactical_map/proc/add_marker(atom/target, hud_flags = NONE, image/blip)
	if(!isatom(target) || !hud_flags || !blip)
		CRASH("Invalid marker added to subsystem")

	// XANTODO Probably need initialized check somehow if(!initialized || !(minimaps_by_z["[target.z]"])) //the minimap doesn't exist yet, z level was probably loaded after init
	if(!(minimaps_by_z["[target.z]"])) //the minimap doesn't exist yet, z level was probably loaded after init
		for(var/datum/callback/callback as anything in earlyadds["[target.z]"])
			if(callback.arguments[1] == target)
				return
		LAZYADDASSOC(earlyadds, "[target.z]", CALLBACK(src, PROC_REF(add_marker), target, hud_flags, blip))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_earlyadd), override = TRUE) //Override required for late z-level loading to prevent hard dels where an atom is initiated during z load, but is qdel'd before it finishes
		return

	var/turf/target_turf = get_turf(target)

	blip.pixel_x = MINIMAP_PIXEL_FROM_WORLD(target_turf.x) + minimaps_by_z["[target_turf.z]"].x_offset
	blip.pixel_y = MINIMAP_PIXEL_FROM_WORLD(target_turf.y) + minimaps_by_z["[target_turf.z]"].y_offset

	images_by_source[target] = blip
	for(var/flag in bitfield2list(hud_flags))
		minimaps_by_z["[target_turf.z]"].images_assoc["[flag]"][target] = blip
		minimaps_by_z["[target_turf.z]"].images_raw["[flag]"] += blip
		for(var/datum/minimap_updator/updator as anything in update_targets["[flag]"])
			if(target_turf.z == updator.ztarget)
				updator.raw_blips += blip
	if(ismovable(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(minimap_on_move))
	removal_cbs[target] = CALLBACK(src, PROC_REF(removeimage), blip, target, hud_flags)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_marker), override = TRUE) //override for atoms that were on a late loaded z-level, overrides the remove_earlyadd above

///Removes the object from the earlyadds list, in case it was qdel'd before the z-level was fully loaded
/datum/tactical_map/proc/remove_earlyadd(atom/source)
	SIGNAL_HANDLER
	remove_marker(source)
	for(var/datum/callback/callback in earlyadds["[source.z]"])
		if(callback.arguments[1] != source)
			continue
		earlyadds["[source.z]"] -= callback
		UnregisterSignal(source, COMSIG_QDELETING)
		return

/**
 * removes an image from raw tracked lists, invoked by callback
 */
/datum/tactical_map/proc/removeimage(image/blip, atom/target, hud_flags)
	var/turf/target_turf = get_turf(target)
	for(var/flag in bitfield2list(hud_flags))
		minimaps_by_z["[target_turf.z]"].images_raw["[flag]"] -= blip
		for(var/datum/minimap_updator/updator as anything in update_targets["[flag]"])
			if(updator.ztarget == target_turf.z)
				updator.raw_blips -= blip
	blip.UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	removal_cbs -= target

/**
 * Called on zlevel change of a blip-atom so we can update the image lists as needed
 *
 * TODO gross amount of assoc usage and unneeded ALL FLAGS iteration
 */
/datum/tactical_map/proc/on_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	var/image/blip
	for(var/flag in GLOB.all_minimap_flags)
		if(!minimaps_by_z["[oldz]"]?.images_assoc["[flag]"][source])
			continue
		if(!blip)
			blip = minimaps_by_z["[oldz]"].images_assoc["[flag]"][source]
		// todo maybe make update_targets also sort by zlevel?
		for(var/datum/minimap_updator/updator as anything in update_targets["[flag]"])
			if(updator.ztarget == oldz)
				updator.raw_blips -= blip
			else if(updator.ztarget == newz)
				updator.raw_blips += blip
		minimaps_by_z["[newz]"].images_assoc["[flag]"][source] = blip
		minimaps_by_z["[oldz]"].images_assoc["[flag]"] -= source

		minimaps_by_z["[newz]"].images_raw["[flag]"] += blip
		minimaps_by_z["[oldz]"].images_raw["[flag]"] -= blip

/**
 * Simple proc, updates overlay position on the map when a atom moves
 */
/datum/tactical_map/proc/minimap_on_move(atom/movable/source, oldloc)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		images_by_source[source].pixel_x = MINIMAP_PIXEL_FROM_WORLD(source.x) + minimaps_by_z["[source.z]"].x_offset
		images_by_source[source].pixel_y = MINIMAP_PIXEL_FROM_WORLD(source.y) + minimaps_by_z["[source.z]"].y_offset
		return

	var/atom/movable/movable_loc = source.loc
	source.override_minimap_tracking(source.loc, src)
	images_by_source[movable_loc].pixel_x = MINIMAP_PIXEL_FROM_WORLD(movable_loc.x) + minimaps_by_z["[movable_loc.z]"].x_offset
	images_by_source[movable_loc].pixel_y = MINIMAP_PIXEL_FROM_WORLD(movable_loc.y) + minimaps_by_z["[movable_loc.z]"].y_offset

///Used to handle minimap tracking inside other movables
/atom/movable/proc/override_minimap_tracking(atom/movable/loc, datum/tactical_map/map)
	var/image/blip = map.images_by_source[src]
	blip.RegisterSignal(loc, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/datum/tactical_map, minimap_on_move))
	RegisterSignal(loc, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/tactical_map, cancel_override_minimap_tracking))

///Stops minimap override tracking
/datum/tactical_map/proc/cancel_override_minimap_tracking(atom/movable/source, atom/movable/mover)
	SIGNAL_HANDLER
	if(mover != source)
		return
	var/image/blip = images_by_source[source]
	blip?.UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)

/**
 * Removes an atom and it's blip from the subsystem
 */
/datum/tactical_map/proc/remove_marker(atom/source)
	SIGNAL_HANDLER
	if(!removal_cbs[source]) //already removed
		return
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	var/turf/source_turf = get_turf(source)
	for(var/flag in GLOB.all_minimap_flags)
		minimaps_by_z["[source_turf.z]"].images_assoc["[flag]"] -= source
	images_by_source -= source
	removal_cbs[source].Invoke()
	removal_cbs -= source

/**
 * Fetches a /atom/movable/screen/minimap instance or creates on if none exists
 * Note this does not destroy them when the map is unused, might be a potential thing to do?
 * Arguments:
 * * zlevel: zlevel to fetch map for
 * * flags: map flags to fetch from
 */
/datum/tactical_map/proc/fetch_minimap_object(zlevel, flags)
	var/hash = "[zlevel]-[flags]"
	if(hashed_minimaps[hash])
		return hashed_minimaps[hash]
	var/atom/movable/screen/minimap/map = new(null, null, zlevel, flags, src)
	if (!map.icon) //Don't wanna save an unusable minimap for a z-level.
		CRASH("Empty and unusable minimap generated for '[zlevel]-[flags]'") //Can be caused by atoms calling this proc before minimap subsystem initializing.
	hashed_minimaps[hash] = map
	return map

///fetches the drawing icon for a minimap flag and returns it, creating it if needed. assumes minimap_flag is ONE flag
/datum/tactical_map/proc/get_drawing_image(zlevel, minimap_flag)
	var/hash = "[zlevel]-[minimap_flag]"
	if(drawn_images[hash])
		return drawn_images[hash]
	var/image/blip = new // could use MA but yolo
	blip.icon = icon('icons/ui_icons/minimap/minimap.dmi')
	minimaps_by_z["[zlevel]"].images_raw["[minimap_flag]"] += blip
	drawn_images[hash] = blip
	return blip

///Default HUD screen minimap object
/atom/movable/screen/minimap
	name = "Minimap"
	icon = null
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "1,1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///assoc list of mob choices by clicking on coords. only exists fleetingly for the wait loop in [/proc/get_coords_from_click]
	var/list/mob/choices_by_mob
	///assoc list to determine if get_coords_from_click should stop waiting for an input for that specific mob
	var/list/mob/stop_polling
	///z this minimap is displaying
	var/tracked_z
	///ref to the minimap we follow
	var/datum/tactical_map/my_map

/atom/movable/screen/minimap/Initialize(mapload, datum/hud/hud_owner, target, flags, tactical_map)
	. = ..()
	my_map = tactical_map
	tracked_z = target
	if(!my_map.minimaps_by_z["[target]"])
		return
	choices_by_mob = list()
	stop_polling = list()
	icon = my_map.minimaps_by_z["[target]"].hud_image
	my_map.add_to_updaters(src, flags, target)

/atom/movable/screen/minimap/Destroy()
	my_map.hashed_minimaps -= src
	stop_polling = null
	return ..()

/**
 * lets the user get coordinates by clicking the actual map
 * Returns a list(x_coord, y_coord)
 * note: sleeps until the user makes a choice, stop_polling is set to TRUE for this specific user or they disconnect
 */
/atom/movable/screen/minimap/proc/get_coords_from_click(mob/user)
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	while(!(choices_by_mob[user] || stop_polling[user]) && user.client && islist(stop_polling))
		stoplag(1)
	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	. = choices_by_mob[user]
	choices_by_mob -= user
	// I have an extra layer of shitcode for you
	stop_polling -= user

/**
 * Handles fetching the targetted coordinates when the mob tries to click on this map
 * does the following:
 * turns map targetted pixel into a list(x, y)
 * gets z level of this map
 * x and y minimap centering is reverted, then the x2 scaling of the map is removed
 * round up to correct if an odd pixel was clicked and make sure its valid
 */
/atom/movable/screen/minimap/proc/on_click(datum/source, atom/A, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	// we only care about absolute coords because the map is fixed to 1,1 so no client stuff
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	var/zlevel = my_map.updators_by_datum[src].ztarget
	var/x = (pixel_coords[1] - my_map.minimaps_by_z["[zlevel]"].x_offset) / 2
	var/y = (pixel_coords[2] - my_map.minimaps_by_z["[zlevel]"].y_offset) / 2
	var/c_x = clamp(CEILING(x, 1), 1, world.maxx)
	var/c_y = clamp(CEILING(y, 1), 1, world.maxy)
	choices_by_mob[source] = list(c_x, c_y)
	return COMSIG_MOB_CANCEL_CLICKON

/atom/movable/screen/minimap_locator
	name = "You are here"
	icon = 'icons/ui_icons/minimap/map_blips.dmi'
	icon_state = "locator"
	layer = MINIMAP_LOCATOR_LAYER // 1 above minimap
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///ref to the minimap we follow
	var/datum/tactical_map/my_map

///updates the screen loc of the locator so that it's on the movers location on the minimap
/atom/movable/screen/minimap_locator/proc/update(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/turf/mover_turf = get_turf(mover)
	var/x_coord = mover_turf.x * 2
	var/y_coord = mover_turf.y * 2
	x_coord += my_map.minimaps_by_z["[mover_turf.z]"].x_offset
	y_coord += my_map.minimaps_by_z["[mover_turf.z]"].y_offset
	// + 1 because tiles start at 1
	var/x_tile = FLOOR(x_coord/32, 1) + 1
	// -3 to center the image
	var/x_pixel = x_coord % 32 - 3
	var/y_tile = FLOOR(y_coord/32, 1) + 1
	var/y_pixel = y_coord % 32 - 3
	screen_loc = "[x_tile]:[x_pixel],[y_tile]:[y_pixel]"

/atom/movable/screen/minimap_extras
	/// minimap action this extra button is owned by
	var/datum/action/minimap/minimap_action

/atom/movable/screen/minimap_extras/Destroy()
	minimap_action = null
	return ..()

/atom/movable/screen/minimap_extras/minimap_z_indicator
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "zindicator"
	screen_loc = ui_ai_floor_indicator

///sets the currently indicated relative floor
/atom/movable/screen/minimap_extras/minimap_z_indicator/proc/set_indicated_z(newz)
	if(!newz)
		return
	var/list/linked_zs = SSmapping.get_connected_levels(newz)
	if(!length(linked_zs))
		return
	linked_zs = sort_list(linked_zs, /proc/cmp_numeric_asc)
	var/relativez = linked_zs.Find(newz)
	var/text = "Floor<br/>[relativez]"
	maptext = MAPTEXT_TINY_UNICODE("<div align='center' valign='middle' style='position:relative; top:0px; left:0px'>[text]</div>")

/atom/movable/screen/minimap_extras/minimap_z_up
	name = "go up"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "up"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = ui_ai_godownup

/atom/movable/screen/minimap_extras/minimap_z_up/Click(location,control,params)
	flick("uppressed",src)
	if(!minimap_action.map_object)
		return
	var/currentz = minimap_action.map_object.tracked_z
	var/list/linked_zs = SSmapping.get_connected_levels(currentz)
	if(!length(linked_zs))
		return
	linked_zs = sort_list(linked_zs, /proc/cmp_numeric_asc)
	var/relativez = linked_zs.Find(currentz)
	if(relativez == length(linked_zs))
		return //topmost z with nothing above. we still play effects just dont do anything
	minimap_action.change_z_shown(++currentz)

/atom/movable/screen/minimap_extras/minimap_z_down
	name = "go down"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "down"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = ui_ai_godownup

/atom/movable/screen/minimap_extras/minimap_z_down/Click(location,control,params)
	flick("downpressed",src)
	if(!minimap_action.map_object)
		return
	var/currentz = minimap_action.map_object.tracked_z
	var/list/linked_zs = SSmapping.get_connected_levels(currentz)
	if(!length(linked_zs))
		return
	linked_zs = sort_list(linked_zs, /proc/cmp_numeric_asc)
	var/relativez = linked_zs.Find(currentz)
	if(relativez == 1)
		return //bottommost z with nothing below. we still play effects just dont do anything
	minimap_action.change_z_shown(--currentz)

/**
 * Action that gives the owner access to the minimap pool
 */
/datum/action/minimap
	name = "Toggle Minimap"
	button_icon_state = "minimap"
	///Flags to allow the owner to see others of this type
	var/minimap_flags = MINIMAP_FLAG_ALL
	///marker flags this will give the target, mostly used for marine minimaps
	var/marker_flags = MINIMAP_FLAG_ALL
	///boolean as to whether the minimap is currently shown
	var/minimap_displayed = FALSE
	///Minimap object we'll be displaying
	var/atom/movable/screen/minimap/map_object
	///Overrides what the locator tracks aswell what z the map displays as opposed to always tracking the minimap's owner. Default behavior when null.
	var/atom/movable/locator_override
	///Minimap "You are here" indicator for when it's up
	var/atom/movable/screen/minimap_locator/locator
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/minimap_extras/minimap_z_indicator/z_indicator
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/minimap_extras/minimap_z_up/z_up
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/minimap_extras/minimap_z_down/z_down
	///Sets a fixed z level to be tracked by this minimap action instead of being influenced by the owner's / locator override's z level.
	var/default_overwatch_level = 0
	///Reference to the map datum we display
	var/datum/tactical_map/my_map

/datum/action/minimap/New(Target, new_minimap_flags, new_marker_flags, tactical_map)
	. = ..()
	my_map = tactical_map
	locator = new
	locator.my_map = tactical_map
	z_indicator = new
	z_indicator.minimap_action = src
	z_up = new
	z_up.minimap_action = src
	z_down = new
	z_down.minimap_action = src

	if(new_minimap_flags)
		minimap_flags = new_minimap_flags
	if(new_marker_flags)
		marker_flags = new_marker_flags

/datum/action/minimap/Destroy()
	map_object = null
	locator_override = null
	QDEL_NULL(locator)
	QDEL_NULL(z_indicator)
	QDEL_NULL(z_up)
	QDEL_NULL(z_down)
	return ..()

/datum/action/minimap/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!map_object)
		return FALSE

	return toggle_minimap()

/// Toggles the minimap, has a variable to force on or off (most likely only going to be used to close it)
/datum/action/minimap/proc/toggle_minimap(force_state)
	// No force state? Invert the current state
	if(isnull(force_state))
		force_state = !minimap_displayed
	if(force_state == minimap_displayed)
		return FALSE
	if(!locator_override && ismovable(owner.loc))
		override_locator(owner.loc)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	if(force_state)
		if(locate(/atom/movable/screen/minimap) in owner.client.screen) //This seems like the most effective way to do this without some wacky code
			to_chat(owner, span_warning("You already have a minimap open!"))
			return FALSE
		owner.client.screen += map_object
		owner.client.screen += locator
		if(length(SSmapping.get_connected_levels(tracking.z)) > 1)
			owner.client.screen += z_indicator
			owner.client.screen += z_up
			owner.client.screen += z_down
		locator.update(tracking)
		locator.RegisterSignal(tracking, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
	else
		if(owner.client)
			owner.client.screen -= map_object
			owner.client.screen -= locator
			owner.client.screen -= z_indicator
			owner.client.screen -= z_up
			owner.client.screen -= z_down
		map_object.stop_polling -= owner
		locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
	minimap_displayed = force_state
	return TRUE

///Overrides the minimap locator to a given atom
/datum/action/minimap/proc/override_locator(atom/movable/to_track)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	var/atom/movable/new_track = to_track ? to_track : owner
	if(locator_override)
		clear_locator_override()
	if(owner)
		UnregisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED)
	if(!minimap_displayed)
		locator_override = to_track
		if(to_track)
			RegisterSignal(to_track, COMSIG_QDELETING, TYPE_PROC_REF(/datum/action/minimap, clear_locator_override))
			if(owner && owner.loc == to_track)
				RegisterSignal(to_track, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/action/minimap, on_exit_check))
		if(owner)
			RegisterSignal(new_track, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
			var/turf/old_turf = get_turf(tracking)
			if(!old_turf || !old_turf.z || old_turf.z != new_track.z)
				on_owner_z_change(new_track, old_turf?.z, new_track?.z)
		return
	locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
	locator_override = to_track
	if(to_track)
		RegisterSignal(to_track, COMSIG_QDELETING, TYPE_PROC_REF(/datum/action/minimap, clear_locator_override))
		if(owner.loc == to_track)
			RegisterSignal(to_track, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/action/minimap, on_exit_check))
	RegisterSignal(new_track, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
	var/turf/old_turf = get_turf(tracking)
	if(old_turf.z != new_track.z)
		on_owner_z_change(new_track, old_turf.z, new_track.z)
	locator.RegisterSignal(new_track, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
	locator.update(new_track)

///checks if we should clear override if the owner exits this atom
/datum/action/minimap/proc/on_exit_check(datum/source, atom/movable/mover)
	SIGNAL_HANDLER
	if(mover && mover != owner)
		return
	clear_locator_override()

///CLears the locator override in case the override target is deleted
/datum/action/minimap/proc/clear_locator_override()
	SIGNAL_HANDLER
	if(!locator_override)
		return
	UnregisterSignal(locator_override, list(COMSIG_QDELETING, COMSIG_ATOM_EXITED))
	if(owner)
		UnregisterSignal(locator_override, COMSIG_MOVABLE_Z_CHANGED)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
		var/turf/owner_turf = get_turf(owner)
		if(owner_turf.z != locator_override.z)
			on_owner_z_change(owner, locator_override.z, owner_turf.z)
	if(minimap_displayed)
		locator.UnregisterSignal(locator_override, COMSIG_MOVABLE_MOVED)
		locator.RegisterSignal(owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
		locator.update(owner)
	locator_override = null

/datum/action/minimap/Grant(mob/grant_to)
	. = ..()
	var/atom/movable/tracking = locator_override ? locator_override : grant_to
	RegisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
	z_indicator.set_indicated_z(default_overwatch_level ? default_overwatch_level : tracking.z)
	if(default_overwatch_level)
		if(!my_map.minimaps_by_z["[default_overwatch_level]"] || !my_map.minimaps_by_z["[default_overwatch_level]"].hud_image)
			return
		map_object = my_map.fetch_minimap_object(default_overwatch_level, minimap_flags)
		return
	if(!my_map.minimaps_by_z["[tracking.z]"] || !my_map.minimaps_by_z["[tracking.z]"].hud_image)
		return
	map_object = my_map.fetch_minimap_object(tracking.z, minimap_flags)

/datum/action/minimap/Remove(mob/remove_from)
	toggle_minimap(FALSE)
	UnregisterSignal(locator_override || remove_from, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/**
 * Updates the map when the owner changes zlevel
 */
/datum/action/minimap/proc/on_owner_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	change_z_shown(newz)

/// changes the currently to be displayed z. takes the new z as an arg
/datum/action/minimap/proc/change_z_shown(newz)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	if(minimap_displayed)
		owner.client?.screen -= map_object
	var/old_map_z = map_object?.tracked_z
	map_object = null

	var/new_z_shown = default_overwatch_level ? default_overwatch_level : newz
	if(minimap_displayed)
		var/new_z_is_multiz = length(SSmapping.get_connected_levels(new_z_shown)) > 1
		var/old_z_is_multiz = old_map_z ? length(SSmapping.get_connected_levels(old_map_z)) > 1 : FALSE
		if(old_z_is_multiz != new_z_is_multiz)
			if(new_z_is_multiz)
				owner.client.screen += z_indicator
				owner.client.screen += z_up
				owner.client.screen += z_down
			else
				owner.client.screen -= z_indicator
				owner.client.screen -= z_up
				owner.client.screen -= z_down

	z_indicator.set_indicated_z(new_z_shown)
	if(!my_map.minimaps_by_z["[new_z_shown]"] || !my_map.minimaps_by_z["[new_z_shown]"].hud_image)
		if(minimap_displayed)
			owner.client?.screen -= locator
			locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
			minimap_displayed = FALSE
		return
	map_object = my_map.fetch_minimap_object(new_z_shown, minimap_flags)
	if(minimap_displayed)
		if(owner.client)
			owner.client.screen += map_object
		else
			minimap_displayed = FALSE







// XANTODO: GRANT SOME WAY OF GETTING A MINIMAP WITHOUT THIS AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

/obj/item/radio/headset/mainship
	name = "marine radio headset"
	///The type of minimap this headset gives access to
	var/datum/action/minimap/minimap_type = /datum/action/minimap
	///Reference to the minimap that is being used
	var/datum/tactical_map/my_map

/obj/item/radio/headset/mainship/Destroy()
	QDEL_NULL(my_map)
	return ..()

/obj/item/radio/headset/mainship/equipped(mob/user, slot, initial)
	. = ..()
	/* XANTODO Create map?
	if(!SSminimaps.initialized)
		SSminimaps.Initialize()
	*/
	if(!(slot_flags & slot))
		remove_minimap(user)
		return
	add_minimap(user)

/// Adds a minimap to the mob, starts the subsystem if it hasnt already
/obj/item/radio/headset/mainship/proc/add_minimap(mob/user)
	remove_minimap(user)
	if(!my_map)
		my_map = new
		my_map.Initialize()
	var/datum/action/minimap/mini = new minimap_type(tactical_map = my_map)
	mini.Grant(user)
	addtimer(CALLBACK(src, PROC_REF(update_minimap_icon), user), 0.1 SECONDS) //Mobs are spawned inside nullspace sometimes so this is to avoid that hijinks

///Remove all action of type minimap from the wearer, and make him disappear from the minimap
/obj/item/radio/headset/mainship/proc/remove_minimap(mob/user)
	my_map?.remove_marker(user)
	for(var/datum/action/action as anything in user.actions)
		if(istype(action, /datum/action/minimap))
			action.Remove(user)

///Updates the wearer's minimap icon
/obj/item/radio/headset/mainship/proc/update_minimap_icon(mob/wearer)
	SIGNAL_HANDLER
	my_map.remove_marker(wearer)
/* XANTODO Conditional map markers
	if(!wearer.job || !wearer.job.minimap_icon)
		return
	var/marker_flags = initial(minimap_type.marker_flags)
	if(wearer.stat == DEAD)
		if(HAS_TRAIT(wearer, TRAIT_UNDEFIBBABLE))
			my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))
			return
		if(!wearer.mind && !wearer.has_ai())
			var/mob/dead/observer/ghost = wearer.get_ghost(TRUE)
			if(!ghost?.can_reenter_corpse)
				my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "undefibbable", MINIMAP_BLIPS_LAYER))
				return
		my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, "defibbable", MINIMAP_LABELS_LAYER))
		return
	if(wearer.assigned_squad)
		var/image/underlay = image('icons/ui_icons/minimap/map_blips.dmi', null, "squad_underlay", MINIMAP_BLIPS_LAYER)
		var/image/overlay = image('icons/ui_icons/minimap/map_blips.dmi', null, wearer.job.minimap_icon)
		overlay.color = wearer.assigned_squad.color
		underlay.overlays += overlay

		if(wearer.assigned_squad?.squad_leader == wearer)
			var/image/leader_trim = image('icons/ui_icons/minimap/map_blips.dmi', null, "leader_trim")
			underlay.overlays += leader_trim

		my_map.add_marker(wearer, marker_flags, underlay)
		return
	my_map.add_marker(wearer, marker_flags, image('icons/ui_icons/minimap/map_blips.dmi', null, wearer.job.minimap_icon), MINIMAP_BLIPS_LAYER)
*/




