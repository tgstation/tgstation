/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, .proc/on_message)

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/datum/tgui_panel/proc/initialize()
	window.initialize(inline_assets = list(
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/fontawesome))
	client.force_dark_theme()

/datum/tgui_panel/proc/on_message(type, list/payload)
	if(type == "ready")
		window.send_message("update", list(
			"config" = list(
				"panel" = list(),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		winset(client, "output", "is-visible=false")
		winset(client, "browseroutput", "is-disabled=false;is-visible=true")
	return FALSE
