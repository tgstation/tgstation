var/datum/subsystem/processing/tgui/SStgui

/datum/subsystem/processing/tgui
	name = "tgui"
	wait = 9
	init_order = 16
	display_order = 6
	flags = SS_FIRE_IN_LOBBY
	priority = 110

	stat_tag = "TG"

	var/list/open_uis // A list of open UIs, grouped by src_object and ui_key.
	var/basehtml // The HTML base used for all UIs.

/datum/subsystem/processing/tgui/New()
	NEW_SS_GLOBAL(SStgui)
	LAZYINITLIST(open_uis)

/datum/subsystem/processing/tgui/Initialize()
	if(!basehtml)
		basehtml = file2text('tgui/tgui.html') // Read the HTML from disk.
	..()

/datum/subsystem/processing/tgui/Shutdown()
	close_all_uis()

/datum/subsystem/processing/tgui/Recover()
	open_uis = SStgui.open_uis
	basehtml = SStgui.basehtml
	..(SStgui)