var/datum/subsystem/tgui/SStgui

/datum/subsystem/tgui
	name = "tgui"
	wait = 10
	init_order = 16
	display_order = 6
	flags = SS_NO_INIT|SS_FIRE_IN_LOBBY
	priority = 110

	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/processing_uis = list() // A list of processing UIs, ungrouped.
	var/basehtml // The HTML base used for all UIs.

/datum/subsystem/tgui/New()
	basehtml = file2text('tgui/tgui.html') // Read the HTML from disk.

	NEW_SS_GLOBAL(SStgui)

/datum/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]")

/datum/subsystem/tgui/fire()
	for(var/thing in processing_uis)
		var/datum/tgui/ui = thing
		if(ui && ui.user && ui.src_object)
			ui.process()
			continue
		processing_uis.Remove(ui)
