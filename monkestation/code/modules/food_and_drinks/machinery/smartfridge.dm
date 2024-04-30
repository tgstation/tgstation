/obj/machinery/smartfridge
	/// The tgui theme to use. Default is null, which means the Nanotrasen theme is used.
	var/tgui_theme = null

/obj/machinery/smartfridge/ui_static_data(mob/user)
	return list("ui_theme" = tgui_theme)
