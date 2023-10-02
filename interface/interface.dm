//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Type what you want to know about.  This will open the wiki in your web browser. Type nothing to go to the main page."
	set hidden = TRUE
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		src << link(wikiurl) // monkestation edit
	else
		to_chat(src, span_danger("The wiki URL is not set in the server configuration."))
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = TRUE
	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		if(tgui_alert(src, "This will open the forum in your browser. Are you sure?",, list("Yes","No"))!="Yes")
			return
		src << link(forumurl)
	else
		to_chat(src, span_danger("The forum URL is not set in the server configuration."))
	return

/client/verb/rules()
	set name = "rules"
	set desc = "Show Server Rules."
	set hidden = TRUE
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(tgui_alert(src, "This will open the rules in your browser. Are you sure?",, list("Yes","No"))!="Yes")
			return
		src << link(rulesurl)
	else
		to_chat(src, span_danger("The rules URL is not set in the server configuration."))
	return

/client/verb/github()
	set name = "github"
	set desc = "Visit Github"
	set hidden = TRUE
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		if(tgui_alert(src, "This will open the Github repository in your browser. Are you sure?",, list("Yes","No"))!="Yes")
			return
		src << link(githuburl)
	else
		to_chat(src, span_danger("The Github URL is not set in the server configuration."))
	return

/client/verb/reportissue()
	set name = "report-issue"
	set desc = "Report an issue"
	set hidden = TRUE
	var/githuburl = CONFIG_GET(string/githuburl)
	var/issue_key = CONFIG_GET(string/issue_key)
	if(!issue_key)
		to_chat(src, span_danger("Issue Reporting is not properly configured."))
		return
	//Are we pre-interview or otherwise not allowed to do this?
	if(interviewee || is_banned_from(ckey, "Bug Report"))
		to_chat(src, span_warning("You are not currently allowed to make a bug report through this system."))
		return
	var/message = "This will start reporting an issue, gathering some information from the server and your client, before submitting it to github."
	if(GLOB.revdata.testmerge.len)
		message += "<br>The following experimental changes are active and may be the cause of any new or sudden issues:<br>"
		message += GLOB.revdata.GetTestMergeInfo(FALSE)
	// We still use tgalert here because some people were concerned that if someone wanted to report that tgui wasn't working
	// then the report issue button being tgui-based would be problematic.
	if(tgalert(src, message, "Report Issue","Yes","No")!="Yes")
		return

	// Keep a static version of the template to avoid reading file
	var/static/issue_template = file2text(".github/ISSUE_TEMPLATE/bug_report.md")

	// Get a local copy of the template for modification
	var/local_template = issue_template

	// Remove comment header
	var/content_start = findtext(local_template, "<")
	if(content_start)
		local_template = copytext(local_template, content_start)

	// Insert round
	if(GLOB.round_id)
		local_template = replacetext(local_template, "## Round ID:\n", "## Round ID:\n[GLOB.round_id]")

	// Insert testmerges
	if(GLOB.revdata.testmerge.len)
		var/list/all_tms = list()
		for(var/entry in GLOB.revdata.testmerge)
			var/datum/tgs_revision_information/test_merge/tm = entry
			all_tms += "- \[[tm.title]\]([githuburl]/pull/[tm.number])"
		var/all_tms_joined = all_tms.Join("\n") // for some reason this can't go in the []
		local_template = replacetext(local_template, "## Testmerges:\n", "## Testmerges:\n[all_tms_joined]")

	//Collect client info:
	var/issue_title = input(src, "Please give the issue a title:","Issue Title") as text|null
	if(!issue_title)
		return //Consider it aborted
	var/user_description = input(src, "Please describe the issue you are reporting:","Issue Body") as message|null
	if(!user_description)
		return

	local_template = replacetext(local_template, "## Reproduction:\n", "## Reproduction:\n[user_description]")

	var/client_info = "\
	Client Information:\n\
	BYOND:[byond_version].[byond_build]\n\
	Key:[ckey]\n\
	\
	"
	var/issue_body = "Reporting client info: [client_info]\n\n[local_template]"
	var/list/body_structure = list(
		"title" = issue_title,
		"body" = issue_body
	)
	var/datum/http_request/issue_report = new
	rustg_file_write(issue_body, "[GLOB.log_directory]/issue_reports/[ckey]-[world.time]-[SANITIZE_FILENAME(issue_title)].txt")
	message_admins("BUGREPORT: Bug report filed by [ADMIN_LOOKUPFLW(src)], Title: [strip_html(issue_title)]")
	issue_report.prepare(
		RUSTG_HTTP_METHOD_POST,
		"https://api.github.com/repos/[CONFIG_GET(string/issue_slug)]/issues",
		json_encode(body_structure), //this is slow slow slow but no other options buckaroo
		list(
			"Accept"="application/vnd.github+json",
			"Authorization"="Bearer [issue_key]",
			"X-GitHub-Api-Version"="2022-11-28"
		)
	)
	to_chat(src, span_notice("Sending issue report..."))
	SEND_SOUND(src, 'sound/misc/compiler-stage1.ogg')
	issue_report.begin_async()
	UNTIL(issue_report.is_complete() || !src) //Client fuckery.
	var/datum/http_response/issue_response = issue_report.into_response()
	if(issue_response.errored || issue_response.status_code != 201)
		SEND_SOUND(src, 'sound/misc/compiler-failure.ogg')
		to_chat(src, "[span_alertwarning("Bug report FAILED!")]\n\
		[span_warning("Please adminhelp immediately!")]\n\
		[span_notice("Code:[issue_response.status_code || "9001 CATASTROPHIC ERROR"]")]")

		return
	SEND_SOUND(src, 'sound/misc/compiler-stage2.ogg')
	to_chat(src, span_notice("Bug submitted successfully."))

/client/verb/changelog()
	set name = "Changelog"
	set category = "OOC"
	if(!GLOB.changelog_tgui)
		GLOB.changelog_tgui = new /datum/changelog()

	GLOB.changelog_tgui.ui_interact(mob)
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")

/client/verb/hotkeys_help()
	set name = "Hotkeys Help"
	set category = "OOC"

	if(!GLOB.hotkeys_tgui)
		GLOB.hotkeys_tgui = new /datum/hotkeys_help()

	GLOB.hotkeys_tgui.ui_interact(mob)
