/// Used by SSlooting to process images from the to_image list. Returns success T/F
/datum/lootpanel/proc/process_images()
	for(var/datum/search_object/item as anything in to_image)
		if(QDELETED(item) || item.icon)
			to_image -= item
			continue
	
		var/atom/thing = item.item_ref?.resolve()
		if(QDELETED(thing))
			delete_search_object(item)
			to_image -= item
			continue

		if(!item.generate_icon())
			delete_search_object(item)

		to_image -= item
	
	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents(update = FALSE)
		return TRUE // just remove it from sslooting

	searching = FALSE
	window.send_update()

	return !!length(to_image)
