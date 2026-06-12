/atom/movable/screen/minimap_element
	name = "unknown"
	layer = MINIMAP_LABELS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	/// the tag this blip is associated via in it's stored globalist
	var/blip_tag = ""

/atom/movable/screen/minimap_element/Destroy()
	if(blip_tag)
		LAZYREMOVE(GLOB.minimap_blip_tags[blip_tag], src)
	return ..()
