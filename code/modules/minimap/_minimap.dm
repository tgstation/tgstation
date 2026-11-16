GLOBAL_ALIST_EMPTY(minimap_blip_tags)
GLOBAL_ALIST_EMPTY(minimap_annotations)
GLOBAL_LIST_EMPTY(minimap_annotation_viewers)

/// Create a minimap blip on the z-level in question, object is optional, and will tie the blip to the object in question, and will clean up itself if the object in question is deleted
/proc/add_minimap_blip(atom/object, tag, icon_state, icon = 'icons/ui_icons/minimap/map_blips.dmi', large = FALSE, layer = 12)
	if(!istype(object) || !tag || !icon_state)
		CRASH("Invalid params passed in to add_minimap_blip")
	var/atom/movable/screen/minimap_element/blip/new_blip = new(null, null, object, icon_state, icon, large, tag)
	new_blip.layer = layer
	LAZYADD(GLOB.minimap_blip_tags[tag], new_blip)
	SEND_GLOBAL_SIGNAL(COMSIG_MINIMAP_ADD(tag), new_blip)

/proc/get_minimap_blip(tag, atom/object)
	if(!tag || !istype(object))
		return
	for(var/atom/movable/screen/minimap_element/blip/blip as anything in GLOB.minimap_blip_tags[tag])
		if(blip.track_target == object)
			return blip

/proc/remove_minimap_blip(tag, atom/object)
	var/atom/movable/screen/minimap_element/blip/blip = get_minimap_blip(tag, object)
	if(isnull(blip))
		return
	SEND_GLOBAL_SIGNAL(COMSIG_MINIMAP_REMOVE(tag), blip)
	LAZYREMOVE(GLOB.minimap_blip_tags[tag], blip)
	qdel(blip)

/// Returns minimap blips matching a tag that are within `distance` tiles of `target_turf` on the same z-level.
/proc/get_minimap_blips_in_area(tag, turf/target_turf, distance)
	if(!tag || isnull(target_turf) || !isnum(distance) || !islist(GLOB.minimap_blip_tags[tag]))
		return list()

	var/list/nearby_blips = list()
	for(var/atom/movable/screen/minimap_element/blip/blip as anything in GLOB.minimap_blip_tags[tag])
		var/turf/blip_turf = get_turf(blip.track_target)
		if(isnull(blip_turf))
			continue
		if(blip_turf.z != target_turf.z)
			continue
		if(get_dist(blip_turf, target_turf) > distance)
			continue
		nearby_blips += blip

	return nearby_blips
