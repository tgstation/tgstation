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

/proc/remove_minimap_blip(tag, atom/object)
	for(var/atom/movable/screen/minimap_element/blip/blip as anything in GLOB.minimap_blip_tags[tag])
		if(blip.track_target != object)
			continue
		SEND_GLOBAL_SIGNAL(COMSIG_MINIMAP_REMOVE(tag), blip)
		LAZYREMOVE(GLOB.minimap_blip_tags[tag], blip)
		qdel(blip)
		break
