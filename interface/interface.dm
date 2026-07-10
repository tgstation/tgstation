//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
GAME_VERB_HIDDEN(/client, wiki, "wiki")

	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(!wikiurl)
		to_chat(src, span_danger("The wiki URL is not set in the server configuration."))
		return

	var/query = tgui_input_text(src,
		"Напишите что-то о чём вы хотите узнать. Это откроет вики в вашем браузере. Если ничего не введено, то откроется главная страница.",
		"Вики",
		max_length = MAX_MESSAGE_LEN,
	)
	if(isnull(query)) //cancelled out
		return
	var/output = wikiurl
	if(query != "")
		output += "?title=Special%3ASearch&profile=default&search=[query]"
	DIRECT_OUTPUT(src, link(output))

GAME_VERB_HIDDEN(/client, forum, "forum")

	var/forumurl = CONFIG_GET(string/forumurl)
	if(!forumurl)
		to_chat(src, span_danger("The forum URL is not set in the server configuration."))
		return
	DIRECT_OUTPUT(src, link(forumurl))

GAME_VERB_HIDDEN(/client, rules, "rules")

	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(!rulesurl)
		to_chat(src, span_danger("The rules URL is not set in the server configuration."))
		return
	DIRECT_OUTPUT(src, link(rulesurl))

GAME_VERB_HIDDEN(/client, github, "github")

	var/githuburl = CONFIG_GET(string/githuburl)
	if(!githuburl)
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
		return

	if(tgui_alert(usr, "Хотите перейти на страницу нашего репозитория?", "GitHub", list("Да", "Нет")) != "Да")
		return

	DIRECT_OUTPUT(src, link(githuburl))

GAME_VERB_HIDDEN(/client, config, "config")

	var/configurl = CONFIG_GET(string/configurl)
	if(!configurl)
		to_chat(src, span_danger("The Config URL is not set in the server configuration."))
		return
	DIRECT_OUTPUT(src, link(configurl))

GAME_VERB_DESC(/client, reportissue, "report-issue", "Report an issue", null)

	var/githuburl = CONFIG_GET(string/githuburl)
	if(!githuburl)
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
		return

	var/testmerge_data = GLOB.revdata.testmerge
	var/has_testmerge_data = (length(testmerge_data) != 0)

	var/message = "Нашли баг? Сообщите о нём нам! Это откроет вам страницу создания Issue на Github, открыть?"
	if(has_testmerge_data)
		message += "\n Следующие экспериментальные изменения активны и возможно причина вашей проблемы. В таком случае, постарайтесь не плодить ишуи, и попробуйте найти существующую, где вы можете оставить больше деталей: \n"
		message += GLOB.revdata.GetTestMergeInfo(FALSE)

	if(tgui_alert(usr, message, "Сообщить о баге", list("Ладно", "Миссклик...")) != "Ладно")
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

GAME_VERB(/client, changelog, "Changelog", "OOC")

	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()

GAME_VERB_HIDDEN(/client, hotkeys_help, "Hotkeys Help")

	if(!GLOB.hotkeys_tgui)
		GLOB.hotkeys_tgui = new /datum/hotkeys_help()

	GLOB.hotkeys_tgui.ui_interact(mob)

GAME_VERB_HIDDEN(/client, emote_panel, "Emote Panel")

	if(!isliving(mob))
		to_chat(mob, span_notice("You can only use this while you're alive!"))
		return

	if(!GLOB.emote_panel)
		GLOB.emote_panel = new /datum/emote_panel()
	GLOB.emote_panel.ui_interact(mob)
