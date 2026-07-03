/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ChangelogBandaStation")
		ui.open()

/datum/changelog/ui_static_data()
	var/list/data = list("dates" = list())
	var/static/regex/yml_regex = regex(@"\.yml", "g")

	for(var/archive_file in sort_list(flist("html/changelogs/bandastation/archive/")))
		var/archive_date = yml_regex.Replace(archive_file, "")
		data["dates"] = list(archive_date) + data["dates"]

	return data
