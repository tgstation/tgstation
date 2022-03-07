/obj/machinery/computer/terminal
	name = "terminal"
	desc = "A relatively low-tech solution for internal computing, internal network mail, and logging. This model appears to be quite old."
///Text this terminal contains, not dissimilar to paper. Unlike paper, players cannot add or edit existing info.
///Essentially: Ruins and gateways only if you don't wanna look like a dweeb
	var/info = "Congratulations on your purchase of a NanoSoft-TM terminal! Further instructions on setup available in \
	user manual. For license and registration, please contact your licensed NanoSoft vendor and repair service representative."
///Text that displays on top of the actual 'lore' funnies.
	var/upperinfo = "COPYRIGHT 2487 NANOSOFT-TM - DO NOT REDISTRIBUTE"

/obj/machinery/computer/terminal/ui_interact(mob/user, datum/tgui/ui)
	// Update the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terminal", name) //The paper tgui file scares me, so new type of UI
		ui.open()

/obj/machinery/computer/terminal/ui_static_data(mob/user)
	. = list()
	.["text"] = info
	.["uppertext"] = upperinfo
