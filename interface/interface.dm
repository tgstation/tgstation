//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
DEFINE_VERB(/client, wiki, "wiki", \
	"Brings you to the Wiki", \
	TRUE, "")
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(!wikiurl)
		to_chat(src, span_danger("The wiki URL is not set in the server configuration."))
		return

	var/query = tgui_input_text(src,
		"Type what you want to know about. This will open the wiki in your web browser. Type nothing to go to the main page.",
		"Wiki",
		max_length = MAX_MESSAGE_LEN,
	)
	if(isnull(query)) //cancelled out
		return
	var/output = wikiurl
	if(query != "")
		output += "?title=Special%3ASearch&profile=default&search=[query]"
	DIRECT_OUTPUT(src, link(output))

DEFINE_VERB(/client, forum, "forum", "Visit the forum.", TRUE, "")
	var/forumurl = CONFIG_GET(string/forumurl)
	if(!forumurl)
		to_chat(src, span_danger("The forum URL is not set in the server configuration."))
		return
	DIRECT_OUTPUT(src, link(forumurl))

DEFINE_VERB(/client, rules, "rules", "Show Server Rules.", TRUE, "")
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(!rulesurl)
		to_chat(src, span_danger("The rules URL is not set in the server configuration."))
		return
	DIRECT_OUTPUT(src, link(rulesurl))

DEFINE_VERB(/client, github, "github", "Visit Github", TRUE, "")
	var/githuburl = CONFIG_GET(string/githuburl)
	if(!githuburl)
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
		return
	DIRECT_OUTPUT(src, link(githuburl))

DEFINE_VERB(/client, reportissue, "report-issue", "Report an issue", TRUE, "")
	var/githuburl = CONFIG_GET(string/githuburl)
	if(!githuburl)
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
		return

	var/testmerge_data = GLOB.revdata.testmerge
	var/has_testmerge_data = (length(testmerge_data) != 0)

	var/message = "This will open the Github issue reporter in your browser. Are you sure?"
	if(has_testmerge_data)
		message += "<br>The following experimental changes are active and are probably the cause of any new or sudden issues you may experience. If possible, please try to find a specific thread for your issue instead of posting to the general issue tracker:<br>"
		message += GLOB.revdata.GetTestMergeInfo(FALSE)

	// We still use tg_alert here because some people were concerned that if someone wanted to report that tgui wasn't working
	// then the report issue button being tgui-based would be problematic.
	if(tg_alert(src, message, "Report Issue", "Yes", "No") != "Yes")
		return

	var/base_link = githuburl + "/issues/new?template=bug_report_form.yml"
	var/list/concatable = list(base_link)

	var/client_version = "[byond_version].[byond_build]"
	concatable += ("&reporting-version=" + client_version)

	// the way it works is that we use the ID's that are baked into the template YML and replace them with values that we can collect in game.
	if(GLOB.round_id)
		concatable += ("&round-id=" + GLOB.round_id)

	// Insert testmerges
	if(has_testmerge_data)
		var/list/all_tms = list()
		for(var/entry in testmerge_data)
			var/datum/tgs_revision_information/test_merge/tm = entry
			all_tms += "- \[[tm.title]\]([githuburl]/pull/[tm.number])"
		var/all_tms_joined = jointext(all_tms, "\n")

		concatable += ("&test-merges=" + url_encode(all_tms_joined))

	DIRECT_OUTPUT(src, link(jointext(concatable, "")))

DEFINE_VERB(/client, changelog, "Changelog", "", FALSE, "OOC")
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infobuttons.changelog", "font-style=;")

DEFINE_VERB(/client, hotkeys_help, "Hotkeys Help", "", FALSE, "OOC")
	if(!GLOB.hotkeys_tgui)
		GLOB.hotkeys_tgui = new /datum/hotkeys_help()

	GLOB.hotkeys_tgui.ui_interact(mob)
