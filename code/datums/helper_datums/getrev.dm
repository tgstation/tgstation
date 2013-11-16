var/global/datum/getrev/revdata = new()

/datum/getrev
	var/project_href
	var/revision
	var/date
	var/showinfo

	New()
		if(fexists("config/git_host.txt"))
			project_href = file2text("config/git_host.txt")
		else
			project_href = "https://www.github.com/tgstation/-tg-station"
		var/list/head_log = file2list(".git/logs/HEAD", "\n")
		for(var/line=head_log.len, line>=1, line--)
			if(head_log[line])
				var/list/last_entry = text2list(head_log[line], " ")
				if(last_entry.len < 2)	continue
				revision = last_entry[2]
				// Get date/time
				if(last_entry.len >= 5)
					var/unix_time = text2num(last_entry[5])
					if(unix_time)
						date = unix2date(unix_time)
				break

		showinfo = "<b>Server Revision:</b> "
		if(revision)
			showinfo += "<a href='[project_href]/commit/[revision]'><BR>[(date ? date : "No Date")]<BR>[revision]</a>"
		else
			showinfo += "*unknown*"
		showinfo += "<p>-<a href='[project_href]/issues/new'>Report Bugs Here-</a><br><i>Please provide as much info as possible<br>Copy/paste the revision date and hash into your issue report if possible, thanks</i> :)</p>"

		world.log << "Running /tg/ revision:"
		world.log << date
		world.log << revision
		return

client/verb/showrevinfo()
	set category = "OOC"
	set name = "Show Server Revision"
	var/output = revdata.showinfo
	output += "<b>Current Infomational Settings:</b><br>"
	output += "Protect Authority Roles From Traitor: [config.protect_roles_from_antagonist]<br>"
	output += "Allow Latejoin Antagonists: [config.allow_latejoin_antagonists]<br>"
	usr << browse(output,"window=revdata");
	return
