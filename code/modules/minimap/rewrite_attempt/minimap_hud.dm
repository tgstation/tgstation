GLOBAL_ALIST_EMPTY(minimap_blip_tags)

/// Screen object that renders a [/datum/minimap] base map icon on the HUD.
/atom/movable/screen/minimap_display
	name = "Minimap"
	icon_state = ""
	layer = MINIMAP_IMAGE_LAYER
	screen_loc = "1,1"
	var/atom/movable/screen/minimap_drawing/drawing
	/// A reference to the minimap used for this display.
	var/datum/minimap/minimap
	/// Screentext in vis_contents used for the maptext.
	var/atom/movable/screen/minimap_label/screentip
	/// indexed list of currently displayed blips.
	var/list/atom/movable/screen/minimap_blip/blips = list()
	/// The list of minimap blip tags we're going to read from the globalist and listen for additions to
	var/list/valid_minimap_blip_tags = list(MINIMAP_BOMB_BLIP, MINIMAP_NUKEDISK_BLIP, MINIMAP_NUKEOP_BLIP)

/atom/movable/screen/minimap_display/Initialize(mapload, datum/hud/hud_owner, datum/minimap/minimap)
	. = ..()
	if(isnull(minimap))
		CRASH("[type] created without a minimap reference!")
	drawing = new
	vis_contents += drawing
	set_minimap(minimap)
	screentip = new
	vis_contents += screentip
	update_owner_blip(hud.mymob)
	show_tagged_blips()

/atom/movable/screen/minimap_display/Destroy()
	if(hud?.mymob)
		UnregisterSignal(hud.mymob, COMSIG_MOVABLE_Z_CHANGED)
	minimap = null
	QDEL_NULL(drawing)
	QDEL_NULL(screentip)
	return ..()

/atom/movable/screen/minimap_display/set_new_hud(datum/hud/hud_owner)
	if(hud?.mymob)
		UnregisterSignal(hud.mymob, COMSIG_MOVABLE_Z_CHANGED)
	. = ..()
	if(hud?.mymob)
		RegisterSignal(hud.mymob, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_owner_blip))

/atom/movable/screen/minimap_display/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/minimap_display/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	var/list/modifiers = params2list(params)
	var/x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/erase_pixel_range = LAZYACCESS(modifiers, RIGHT_CLICK) ? 5 : 0

	drawing.draw_box(COLOR_RED, x, y, x + 1, y + 1, erase_pixel_range, 1)
	testing("minimapdisplay MouseDrag: [over_object], [src_location], [over_location], [src_control], [json_encode(modifiers)]")

/atom/movable/screen/minimap_display/MouseMove(location, control, params)
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))

	var/x = clamp(MINIMAP_ICON_TO_WORLD(icon_x, minimap.min_x), 1, world.maxx)
	var/y = clamp(MINIMAP_ICON_TO_WORLD(icon_y, minimap.min_y), 1, world.maxy)

	var/area_name = minimap.map_position_to_name["[x]:[y]"]
	if(isnull(area_name))
		var/turf/hovered_loc = locate(x, y, minimap.z)
		area_name = "[hovered_loc?.loc?.name]"
		minimap.map_position_to_name["[x]:[y]"] = area_name
	screentip.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align: left'>[area_name]</span>")
	screentip.pixel_w = icon_x
	screentip.pixel_z = icon_y

/atom/movable/screen/minimap_display/MouseExited(location, control, params)
	screentip.maptext = ""

/atom/movable/screen/minimap_display/proc/update_owner_blip(mob/source)
	SIGNAL_HANDLER
	var/turf/mob_loc = get_turf(source)
	if(!mob_loc || mob_loc.z != minimap.z)
		remove_blip("locator")
		return
	add_blip("locator", "locator", mob_loc.x, mob_loc.y)

/atom/movable/screen/minimap_display/proc/show_tagged_blips()
	for(var/blip_flag in valid_minimap_blip_tags)
		var/blip_list = GLOB.minimap_blip_tags[blip_flag]
		for(var/atom/movable/screen/minimap_blip/blip as anything in blip_list)
			if(blip.track_target.z == minimap.z)
				blip.register_target(blip.track_target)
				blip.start_tracking_target()
				blips += blip
				vis_contents += blip

/atom/movable/screen/minimap_display/proc/set_minimap(datum/minimap/minimap)
	icon = minimap.base_map
	screen_loc = "1:[minimap.base_map.Width() / 2],1:[minimap.base_map.Height() / 2]"
	src.minimap = minimap
	drawing.clear_canvas(minimap.base_map)
	// reset screentip if it exists
	screentip?.maptext = ""

/atom/movable/screen/minimap_display/proc/add_blip(name, icon_state, x, y, large = FALSE)
	var/atom/movable/screen/minimap_blip/new_blip = new(null, null, hud.mymob, icon_state, large)
	new_blip.register_target(hud.mymob)
	new_blip.start_tracking_target()
	blips += new_blip
	vis_contents += new_blip

/atom/movable/screen/minimap_display/proc/update_blip(name, x, y)
	var/atom/movable/screen/minimap_blip/blip = blips[name]
	if(!blip)
		return
	var/half_size = blip.large ? 5 : 3
	blip.pixel_w = MINIMAP_WORLD_TO_PIXEL(x, minimap.min_x, half_size)
	blip.pixel_z = MINIMAP_WORLD_TO_PIXEL(y, minimap.min_y, half_size)

/atom/movable/screen/minimap_display/proc/remove_blip(name)
	var/atom/movable/screen/minimap_blip/blip = blips[name]
	if(!blip)
		return
	blips -= name
	vis_contents -= blip
	qdel(blip)

/atom/movable/screen/minimap_display/proc/remove_all_blips()
	blips.Cut()
	vis_contents.Cut()
	vis_contents += screentip // add screentip back in

/// Create a minimap blip on the z-level in question, object is optional, and will tie the blip to the object in question, and will clean up itself if the object in question is deleted
/proc/add_minimap_blip(atom/object, tag, icon_state, icon = 'icons/ui_icons/minimap/map_blips.dmi', large = FALSE)
	if(!istype(object) || !tag || !icon_state)
		CRASH("Invalid params passed in to add_minimap_blip")
	var/atom/movable/screen/minimap_blip/new_blip = new(null, null, object, icon_state, icon, large, tag)
	LAZYADD(GLOB.minimap_blip_tags[tag], new_blip)
	SEND_GLOBAL_SIGNAL(SIGNAL_MINIMAP_ADD(tag), new_blip)

/proc/remove_minimap_blip(tag, atom/object)
	var/blip_list = GLOB.minimap_blip_tags[tag]
	if(!length(blip_list))
		return
	for(var/atom/movable/screen/minimap_blip/blip as anything in blip_list)
		if(blip.track_target == object)
			qdel(blip)
			SEND_GLOBAL_SIGNAL(SIGNAL_MINIMAP_REMOVE(tag), blip)
			break

/atom/movable/screen/minimap_label
	name = ""
	layer = MINIMAP_LABELS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	maptext = ""
	maptext_width = 96
	maptext_height = 96

/atom/movable/screen/minimap_blip
	name = ""
	icon = 'icons/ui_icons/minimap/map_blips.dmi'
	layer = MINIMAP_BLIPS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	/// Is this a large blip? causes different pixel offsets to be applied
	var/large = FALSE
	/// Minimap datum for the current z-level this blip is on
	var/datum/minimap/minimap
	/// If we are tracking our target or not, to ensure we do not re-register multiple times
	var/tracking = FALSE
	/// what target we're essentially owned by, and will cause this blip to cleanup if it gets deleted
	var/atom/track_target
	/// the tag this blip is associated via in it's stored globalist
	var/blip_tag = ""

/atom/movable/screen/minimap_blip/Initialize(mapload, datum/hud/hud_owner, atom/track_target, icon_state, icon, large = FALSE, blip_tag)
	. = ..()
	src.icon_state = icon_state
	src.large = large
	if(icon)
		src.icon = icon
	if(track_target)
		register_target(track_target)
	if(blip_tag)
		src.blip_tag = blip_tag

/atom/movable/screen/minimap_blip/Destroy()
	. = ..()
	GLOB.minimap_blip_tags -= src

/atom/movable/screen/minimap_blip/proc/register_target(atom/target)
	RegisterSignal(track_target, COMSIG_QDELETING, TYPE_PROC_REF(/datum, selfdelete), override = TRUE)
	track_target = target

/atom/movable/screen/minimap_blip/proc/start_tracking_target()
	if(tracking)
		return
	RegisterSignals(track_target, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(update_blip))
	tracking = TRUE
	INVOKE_ASYNC(src, PROC_REF(delayed_setup))

/atom/movable/screen/minimap_blip/proc/delayed_setup()
	minimap = get_minimap_for_z(track_target.z)
	update_blip()

/atom/movable/screen/minimap_blip/proc/update_blip()
	SIGNAL_HANDLER
	var/half_size = large ? 5 : 3
	pixel_w = MINIMAP_WORLD_TO_PIXEL(track_target.x, minimap.min_x, half_size)
	pixel_z = MINIMAP_WORLD_TO_PIXEL(track_target.y, minimap.min_y, half_size)

/atom/movable/screen/minimap_drawing
	name = ""
	icon = 'icons/ui_icons/minimap/minimap.dmi'
	layer = MINIMAP_LABELS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE

/atom/movable/screen/minimap_drawing/proc/clear_canvas(icon/base_map)
	var/icon/new_icon = icon('icons/ui_icons/minimap/minimap.dmi')
	if(base_map)
		new_icon.Scale(base_map.Width(), base_map.Height())
	icon = new_icon

/atom/movable/screen/minimap_drawing/proc/draw_box(box_color, start_x, start_y, end_x, end_y, erase_pixel_range = 0, erase_padding_multiplier = 0)
	var/icon/new_icon = icon(src.icon)
	if(!isnull(box_color) || !erase_padding_multiplier)
		new_icon.DrawBox(box_color, start_x, start_y, end_x, end_y)
	else
		var/padding = erase_pixel_range * erase_padding_multiplier
		new_icon.DrawBox(box_color, start_x - padding, start_y - padding, end_x + padding, end_y + padding)
	icon = new_icon
