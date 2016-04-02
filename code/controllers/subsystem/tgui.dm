var/datum/subsystem/tgui/SStgui

/datum/subsystem/tgui
	name = "tgui"
	wait = 1
	dynamic_wait = 1
	dwait_delta = 4
	dwait_buffer = 0.1
	dwait_lower = 1
	dwait_upper = 5
	priority = 16
	display = 6

	can_fire = 1 // This needs to fire before round start.

	var/list/open_uis = list() // A list of open UIs, grouped by src_object and ui_key.
	var/list/currentrun = list() // list of what things still need to be processed
	var/list/processing_uis = list() // A list of processing UIs, ungrouped.
	var/basehtml // The HTML base used for all UIs.

/datum/subsystem/tgui/New()
	basehtml = file2text('tgui/tgui.html') // Read the HTML from disk.

	NEW_SS_GLOBAL(SStgui)

/datum/subsystem/tgui/stat_entry()
	..("P:[processing_uis.len]")

/datum/subsystem/tgui/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing_uis.Copy()
	var/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/tgui/ui = currentrun[1]
		currentrun.Cut(1, 2)
		if(ui && ui.user && ui.src_object)
			ui.process()
		else
			processing_uis.Remove(ui)
		if(MC_TICK_CHECK)
			return
