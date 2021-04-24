/datum/changelog

/datum/changelog/ui_state()
	return GLOB.always_state

/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Changelog")
		ui.open()

/datum/changelog/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "get_month")
		var/filename = params["filename"]
		return ui.send_asset(file("html/changelogs/archive/" + filename))

/datum/changelog/ui_static_data()
	var/list/data = list( "dates" = list() )
	var/regex/ymlRegex = regex(@"\.yml", "g")

	for(var/archive_file in flist("[global.config.directory]/../html/changelogs/archive/"))
		var/archive_date = ymlRegex.Replace(archive_file, "")
		data["dates"] = list(archive_date) + data["dates"]

	return data
