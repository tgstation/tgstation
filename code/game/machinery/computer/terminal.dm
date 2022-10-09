//Basic computer meant for basic detailing in ruins and away missions, NOT meant for the station
/obj/machinery/computer/terminal
	name = "terminal"
	desc = "A relatively low-tech solution for internal computing, internal network mail, and logging. This model appears to be quite old."
	circuit = /obj/item/circuitboard/computer/terminal //Deconstruction still wipes contents but this is easier than smashing the console
	///Text that displays on top of the actual 'lore' funnies.
	var/upperinfo = "COPYRIGHT 2487 NANOSOFT-TM - DO NOT REDISTRIBUTE"
	///Text this terminal contains, not dissimilar to paper. Unlike paper, players cannot add or edit existing info.
	var/content = list("Congratulations on your purchase of a NanoSoft-TM terminal! Further instructions on setup available in \
	user manual. For license and registration, please contact your licensed NanoSoft vendor and repair service representative.")
	///The TGUI theme this console uses. Defaults to hackerman, a retro greeny pallete which should fit most terminals.
	var/tguitheme = "hackerman"

/obj/machinery/computer/terminal/ui_interact(mob/user, datum/tgui/ui)
	..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terminal", name) //The paper tgui file scares me, so new type of UI
		ui.open()

/obj/machinery/computer/terminal/ui_static_data(mob/user)
	return list(
		"messages" = content,
		"uppertext" = upperinfo,
		"tguitheme" = tguitheme,
	)

