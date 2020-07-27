/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken

/datum/tgui_panel/New(client/client)
	src.client = client
	window = new(client, "browseroutput")
	window.subscribe(src, .proc/on_message)

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/datum/tgui_panel/proc/initialize()
	if(!winexists(client, "browseroutput"))
		broken = TRUE
		message_admins("Couldn't start chat for [key_name_admin(client)]!")
		alert(client.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		return
	window.initialize(inline_assets = list(
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/fontawesome))

/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"panel" = list(),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if(type == "changeTheme")
		if(payload["name"] == "dark")
			client.force_dark_theme()
		if(payload["name"] == "light")
			client.force_white_theme()
		return TRUE
