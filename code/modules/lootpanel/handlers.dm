/// On contents change, either reset or update
/datum/lootpanel/proc/on_searchable_deleted(datum/search_object/source)
	SIGNAL_HANDLER

	contents -= source
	to_image -= source

	var/datum/tgui/window = SStgui.get_open_ui(owner.mob, src)
#if !defined(UNIT_TESTS) // we dont want to delete contents if we're testing
	if(isnull(window))
		reset_contents()
		return
#endif

	if(isturf(source.item))
		populate_contents()
		return

	window?.send_update()
