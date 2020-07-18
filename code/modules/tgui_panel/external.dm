/client/var/datum/tgui_panel/tgui_panel

/proc/tgui_panel_setup(client/client)
	client.tgui_panel = new(client)
	client.tgui_panel.initialize()
