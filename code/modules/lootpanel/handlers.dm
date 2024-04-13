/// On contents change, either reset or update
/datum/lootpanel/proc/on_searchable_deleted(datum/search_object/source)
	SIGNAL_HANDLER

	contents -= source
	to_image -= source

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
	if(isnull(window))
		reset_contents()
		return

	if(isturf(source.item))
		populate_contents()
		return

	window.send_update()
