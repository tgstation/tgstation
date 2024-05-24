/datum/changelog/ui_static_data()
	. = ..()
	for(var/datum/tgs_revision_information/test_merge/testmerge in world.TgsTestMerges())
		if(!testmerge.body || findtext(testmerge.title, @"[s]"))
			continue
		var/list/changes = parse_github_changelog(testmerge.body)
		if(!length(changes))
			changes = list("unknown" = list("Changes are not documented. Ask the author ([testmerge.author]) to add a changelog to their PR!"))
		var/list/testmerge_data = list(
			"title" = "[testmerge.title]",
			"number" = testmerge.number,
			"author" = testmerge.author,
			"link" = testmerge.url,
			"changes" = changes,
		)
		LAZYADD(.["testmerges"], list(testmerge_data))

/proc/parse_github_changelog(body) as /list
	var/static/regex/cl_pattern = new(@"(:cl:|🆑)([\S \t]*)$")
	var/static/regex/entry_pattern = new(@"(\w+): (.+)")
	var/static/regex/end_pattern = new(@"^/(:cl:|🆑)")
	var/static/regex/newline_pattern = new(@"(\r\n|\r|\n)")

	var/started = FALSE
	var/list/lines = splittext_char(trimtext(body), newline_pattern)

	for (var/line in lines)
		line = trimtext(line)
		if(findtext_char(line, end_pattern))
			break
		if(started)
			if (findtext_char(line, entry_pattern))
				var/change_type = trimtext(entry_pattern.group[1])
				var/change_desc = trimtext(entry_pattern.group[2])
				if(!change_type || !change_desc)
					continue
				LAZYADDASSOCLIST(., change_type, change_desc)
		else
			if(findtext_char(line, cl_pattern))
				started = TRUE
