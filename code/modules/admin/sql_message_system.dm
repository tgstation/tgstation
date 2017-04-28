/proc/create_message(type, target_ckey, admin_ckey, text, timestamp, server, secret, logged = 1, browse)
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!type)
		return
	if(!target_ckey && (type == "note" || type == "message" || type == "watchlist entry"))
		var/new_ckey = ckey(input(usr,"Who would you like to create a [type] for?","Enter a ckey",null) as null|text)
		if(!new_ckey)
			return
		new_ckey = sanitizeSQL(new_ckey)
		var/datum/DBQuery/query_find_ckey = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("player")] WHERE ckey = '[new_ckey]'")
		if(!query_find_ckey.warn_execute())
			return
		if(!query_find_ckey.NextRow())
			if(alert(usr, "[new_ckey] has not been seen before, are you sure you want to create a [type] for them?", "Unknown ckey", "Yes", "No", "Cancel") != "Yes")
				return
		target_ckey = new_ckey
	if(target_ckey)
		target_ckey = sanitizeSQL(target_ckey)
	if(!admin_ckey)
		admin_ckey = usr.ckey
		if(!admin_ckey)
			return
	admin_ckey = sanitizeSQL(admin_ckey)
	if(!target_ckey)
		target_ckey = admin_ckey
	if(!text)
		text = input(usr,"Write your [type]","Create [type]") as null|message
		if(!text)
			return
	text = sanitizeSQL(text)
	if(!timestamp)
		timestamp = SQLtime()
	if(!server)
		if (config && config.server_sql_name)
			server = config.server_sql_name
	server = sanitizeSQL(server)
	if(isnull(secret))
		switch(alert("Hide note from being viewed by players?", "Secret note?","Yes","No","Cancel"))
			if("Yes")
				secret = 1
			if("No")
				secret = 0
			else
				return
	var/datum/DBQuery/query_create_message = SSdbcore.NewQuery("INSERT INTO [format_table_name("messages")] (type, targetckey, adminckey, text, timestamp, server, secret) VALUES ('[type]', '[target_ckey]', '[admin_ckey]', '[text]', '[timestamp]', '[server]', '[secret]')")
	if(!query_create_message.warn_execute())
		return
	if(logged)
		log_admin_private("[key_name(usr)] has created a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_ckey]" : ""]: [text]")
		var/header = "[key_name_admin(usr)] has created a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_ckey]" : ""]"
		message_admins("[header]:<br>[text]")
		admin_ticket_log(target_ckey, "<font color='blue'>[header]</font>")
		admin_ticket_log(target_ckey, text)
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = target_ckey)

/proc/delete_message(message_id, logged = 1, browse)
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/type
	var/target_ckey
	var/text
	var/datum/DBQuery/query_find_del_message = SSdbcore.NewQuery("SELECT type, targetckey, adminckey, text FROM [format_table_name("messages")] WHERE id = [message_id]")
	if(!query_find_del_message.warn_execute())
		return
	if(query_find_del_message.NextRow())
		type = query_find_del_message.item[1]
		target_ckey = query_find_del_message.item[2]
		text = query_find_del_message.item[4]
	var/datum/DBQuery/query_del_message = SSdbcore.NewQuery("DELETE FROM [format_table_name("messages")] WHERE id = [message_id]")
	if(!query_del_message.warn_execute())
		return
	if(logged)
		log_admin_private("[key_name(usr)] has deleted a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for" : " made by"] [target_ckey]: [text]")
		message_admins("[key_name_admin(usr)] has deleted a [type][(type == "note" || type == "message" || type == "watchlist entry") ? " for" : " made by"] [target_ckey]:<br>[text]")
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = target_ckey)

/proc/edit_message(message_id, browse)
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/datum/DBQuery/query_find_edit_message = SSdbcore.NewQuery("SELECT type, targetckey, adminckey, text FROM [format_table_name("messages")] WHERE id = [message_id]")
	if(!query_find_edit_message.warn_execute())
		return
	if(query_find_edit_message.NextRow())
		var/type = query_find_edit_message.item[1]
		var/target_ckey = query_find_edit_message.item[2]
		var/admin_ckey = query_find_edit_message.item[3]
		var/old_text = query_find_edit_message.item[4]
		var/editor_ckey = sanitizeSQL(usr.ckey)
		var/new_text = input("Input new [type]", "New [type]", "[old_text]") as null|message
		if(!new_text)
			return
		new_text = sanitizeSQL(new_text)
		var/edit_text = sanitizeSQL("Edited by [editor_ckey] on [SQLtime()] from<br>[old_text]<br>to<br>[new_text]<hr>")
		var/datum/DBQuery/query_edit_message = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET text = '[new_text]', lasteditor = '[editor_ckey]', edits = CONCAT(IFNULL(edits,''),'[edit_text]') WHERE id = [message_id]")
		if(!query_edit_message.warn_execute())
			return
		log_admin_private("[key_name(usr)] has edited a [type] [(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_ckey]" : ""] made by [admin_ckey] from [old_text] to [new_text]")
		message_admins("[key_name_admin(usr)] has edited a [type] [(type == "note" || type == "message" || type == "watchlist entry") ? " for [target_ckey]" : ""] made by [admin_ckey] from<br>[old_text]<br>to<br>[new_text]")
		if(browse)
			browse_messages("[type]")
		else
			browse_messages(target_ckey = target_ckey)

/proc/toggle_message_secrecy(message_id)
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	message_id = text2num(message_id)
	if(!message_id)
		return
	var/datum/DBQuery/query_find_message_secret = SSdbcore.NewQuery("SELECT type, targetckey, adminckey, secret FROM [format_table_name("messages")] WHERE id = [message_id]")
	if(!query_find_message_secret.warn_execute())
		return
	if(query_find_message_secret.NextRow())
		var/type = query_find_message_secret.item[1]
		var/target_ckey = query_find_message_secret.item[2]
		var/admin_ckey = query_find_message_secret.item[3]
		var/secret = text2num(query_find_message_secret.item[4])
		var/editor_ckey = sanitizeSQL(usr.ckey)
		var/edit_text = "Made [secret ? "not secret" : "secret"] by [editor_ckey] on [SQLtime()]<hr>"
		var/datum/DBQuery/query_message_secret = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET secret = NOT secret, lasteditor = '[editor_ckey]', edits = CONCAT(IFNULL(edits,''),'[edit_text]') WHERE id = [message_id]")
		if(!query_message_secret.warn_execute())
			return
		log_admin_private("[key_name(usr)] has toggled [target_ckey]'s [type] made by [admin_ckey] to [secret ? "not secret" : "secret"]")
		message_admins("[key_name_admin(usr)] has toggled [target_ckey]'s [type] made by [admin_ckey] to [secret ? "not secret" : "secret"]")
		browse_messages(target_ckey = target_ckey)

/proc/browse_messages(type, target_ckey, index, linkless = 0, filter)
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/output
	var/ruler = "<hr style='background:#000000; border:0; height:3px'>"
	var/navbar = "<a href='?_src_=holder;nonalpha=1'>\[All\]</a>|<a href='?_src_=holder;nonalpha=2'>\[#\]</a>"
	for(var/letter in GLOB.alphabet)
		navbar += "|<a href='?_src_=holder;showmessages=[letter]'>\[[letter]\]</a>"
	navbar += "|<a href='?_src_=holder;showmemo=1'>\[Memos\]</a>|<a href='?_src_=holder;showwatch=1'>\[Watchlist\]</a>"
	navbar += "<br><form method='GET' name='search' action='?'>\
	<input type='hidden' name='_src_' value='holder'>\
	<input type='text' name='searchmessages' value='[index]'>\
	<input type='submit' value='Search'></form>"
	if(!linkless)
		output = navbar
	if(type == "memo" || type == "watchlist entry")
		if(type == "memo")
			output += "<h2><center>Admin memos</h2>"
			output += "<a href='?_src_=holder;addmemo=1'>\[Add memo\]</a></center>"
		else if(type == "watchlist entry")
			output += "<h2><center>Watchlist entries</h2>"
			output += "<a href='?_src_=holder;addwatchempty=1'>\[Add watchlist entry\]</a>"
			if(filter)
				output += "|<a href='?_src_=holder;showwatch=1'>\[Unfilter clients\]</a></center>"
			else
				output += "|<a href='?_src_=holder;showwatchfilter=1'>\[Filter offline clients\]</a></center>"
		output += ruler
		var/datum/DBQuery/query_get_type_messages = SSdbcore.NewQuery("SELECT id, targetckey, adminckey, text, timestamp, server, lasteditor FROM [format_table_name("messages")] WHERE type = '[type]'")
		if(!query_get_type_messages.warn_execute())
			return
		while(query_get_type_messages.NextRow())
			var/id = query_get_type_messages.item[1]
			var/t_ckey = query_get_type_messages.item[2]
			if(type == "watchlist entry" && filter && !(t_ckey in GLOB.directory))
				continue
			var/admin_ckey = query_get_type_messages.item[3]
			var/text = query_get_type_messages.item[4]
			var/timestamp = query_get_type_messages.item[5]
			var/server = query_get_type_messages.item[6]
			var/editor_ckey = query_get_type_messages.item[7]
			output += "<b>"
			if(type == "watchlist entry")
				output += "[t_ckey] | "
			output += "[timestamp] | [server] | [admin_ckey]</b>"
			output += " <a href='?_src_=holder;deletemessageempty=[id]'>\[Delete\]</a>"
			output += " <a href='?_src_=holder;editmessageempty=[id]'>\[Edit\]</a>"
			if(editor_ckey)
				output += " <font size='2'>Last edit by [editor_ckey] <a href='?_src_=holder;messageedits=[id]'>(Click here to see edit log)</a></font>"
			output += "<br>[text]<hr style='background:#000000; border:0; height:1px'>"
	if(target_ckey)
		target_ckey = sanitizeSQL(target_ckey)
		var/datum/DBQuery/query_get_messages = SSdbcore.NewQuery("SELECT type, secret, id, adminckey, text, timestamp, server, lasteditor FROM [format_table_name("messages")] WHERE type <> 'memo' AND targetckey = '[target_ckey]' ORDER BY timestamp DESC")
		if(!query_get_messages.warn_execute())
			return
		var/messagedata
		var/watchdata
		var/notedata
		while(query_get_messages.NextRow())
			type = query_get_messages.item[1]
			if(type == "memo")
				continue
			var/secret = text2num(query_get_messages.item[2])
			if(linkless && secret)
				continue
			var/id = query_get_messages.item[3]
			var/admin_ckey = query_get_messages.item[4]
			var/text = query_get_messages.item[5]
			var/timestamp = query_get_messages.item[6]
			var/server = query_get_messages.item[7]
			var/editor_ckey = query_get_messages.item[8]
			var/data
			data += "<b>[timestamp] | [server] | [admin_ckey]</b>"
			if(!linkless)
				data += " <a href='?_src_=holder;deletemessage=[id]'>\[Delete\]</a>"
				if(type == "note")
					data += " <a href='?_src_=holder;secretmessage=[id]'>[secret ? "<b>\[Secret\]</b>" : "\[Not secret\]"]</a>"
				if(type == "message sent")
					data += " <font size='2'>Message has been sent</font>"
					if(editor_ckey)
						data += "|"
				else
					data += " <a href='?_src_=holder;editmessage=[id]'>\[Edit\]</a>"
				if(editor_ckey)
					data += " <font size='2'>Last edit by [editor_ckey] <a href='?_src_=holder;messageedits=[id]'>(Click here to see edit log)</a></font>"
			data += "<br>[text]<hr style='background:#000000; border:0; height:1px'>"
			switch(type)
				if("message")
					messagedata += data
				if("message sent")
					messagedata += data
				if("watchlist entry")
					watchdata += data
				if("note")
					notedata += data
		output += "<h2><center>[target_ckey]</center></h2><center>"
		if(!linkless)
			output += "<a href='?_src_=holder;addnote=[target_ckey]'>\[Add note\]</a>"
			output += " <a href='?_src_=holder;addmessage=[target_ckey]'>\[Add message\]</a>"
			output += " <a href='?_src_=holder;addwatch=[target_ckey]'>\[Add to watchlist\]</a>"
			output += " <a href='?_src_=holder;showmessageckey=[target_ckey]'>\[Refresh page\]</a></center>"
		else
			output += " <a href='?_src_=holder;showmessageckeylinkless=[target_ckey]'>\[Refresh page\]</a></center>"
		output += ruler
		if(messagedata)
			output += "<h4>Messages</h4>"
			output += messagedata
		if(watchdata)
			output += "<h4>Watchlist</h4>"
			output += watchdata
		if(notedata)
			output += "<h4>Notes</h4>"
			output += notedata
	if(index)
		var/index_ckey
		var/search
		output += "<center><a href='?_src_=holder;addmessageempty=1'>\[Add message\]</a><a href='?_src_=holder;addwatchempty=1'>\[Add watchlist entry\]</a><a href='?_src_=holder;addnoteempty=1'>\[Add note\]</a></center>"
		output += ruler
		if(!isnum(index))
			index = sanitizeSQL(index)
		switch(index)
			if(1)
				search = "^."
			if(2)
				search = "^\[^\[:alpha:\]\]"
			else
				search = "^[index]"
		var/datum/DBQuery/query_list_messages = SSdbcore.NewQuery("SELECT DISTINCT targetckey FROM [format_table_name("messages")] WHERE type <> 'memo' AND targetckey REGEXP '[search]' ORDER BY targetckey")
		if(!query_list_messages.warn_execute())
			return
		while(query_list_messages.NextRow())
			index_ckey = query_list_messages.item[1]
			output += "<a href='?_src_=holder;showmessageckey=[index_ckey]'>[index_ckey]</a><br>"
	else if(!type && !target_ckey && !index)
		output += "<center></a> <a href='?_src_=holder;addmessageempty=1'>\[Add message\]</a><a href='?_src_=holder;addwatchempty=1'>\[Add watchlist entry\]</a><a href='?_src_=holder;addnoteempty=1'>\[Add note\]</a></center>"
		output += ruler
	usr << browse(output, "window=browse_messages;size=900x500")

proc/get_message_output(type, target_ckey)
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	if(!type)
		return
	var/output
	if(target_ckey)
		target_ckey = sanitizeSQL(target_ckey)
	var/query = "SELECT id, adminckey, text, timestamp, lasteditor FROM [format_table_name("messages")] WHERE type = '[type]'"
	if(type == "message" || type == "watchlist entry")
		query += " AND targetckey = '[target_ckey]'"
	var/datum/DBQuery/query_get_message_output = SSdbcore.NewQuery(query)
	if(!query_get_message_output.warn_execute())
		return
	while(query_get_message_output.NextRow())
		var/message_id = query_get_message_output.item[1]
		var/admin_ckey = query_get_message_output.item[2]
		var/text = query_get_message_output.item[3]
		var/timestamp = query_get_message_output.item[4]
		var/editor_ckey = query_get_message_output.item[5]
		switch(type)
			if("message")
				output += "<font color='red' size='3'><b>Admin message left by <span class='prefix'>[admin_ckey]</span> on [timestamp]</b></font>"
				output += "<br><font color='red'>[text]</font><br>"
				var/datum/DBQuery/query_message_read = SSdbcore.NewQuery("UPDATE [format_table_name("messages")] SET type = 'message sent' WHERE id = [message_id]")
				if(!query_message_read.warn_execute())
					return
			if("watchlist entry")
				message_admins("<font color='red'><B>Notice: </B></font><font color='blue'>[key_name_admin(target_ckey)] is on the watchlist and has just connected - Reason: [text]</font>")
				send2irc_adminless_only("Watchlist", "[key_name(target_ckey)] is on the watchlist and has just connected - Reason: [text]")
			if("memo")
				output += "<span class='memo'>Memo by <span class='prefix'>[admin_ckey]</span> on [timestamp]"
				if(editor_ckey)
					output += "<br><span class='memoedit'>Last edit by [editor_ckey] <A href='?_src_=holder;messageedits=[message_id]'>(Click here to see edit log)</A></span>"
				output += "<br>[text]</span><br>"
	return output

#define NOTESFILE "data/player_notes.sav"
//if the AUTOCONVERT_NOTES is turned on, anytime a player connects this will be run to try and add all their notes to the databas
/proc/convert_notes_sql(ckey)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)
		log_game("Error: Cannot access [NOTESFILE]")
		return
	notesfile.cd = "/[ckey]"
	while(!notesfile.eof)
		var/notetext
		notesfile >> notetext
		var/server
		if(config && config.server_sql_name)
			server = config.server_sql_name
		var/regex/note = new("^(\\d{2}-\\w{3}-\\d{4}) \\| (.+) ~(\\w+)$", "i")
		note.Find(notetext)
		var/timestamp = note.group[1]
		notetext = note.group[2]
		var/admin_ckey = note.group[3]
		var/datum/DBQuery/query_convert_time = SSdbcore.NewQuery("SELECT ADDTIME(STR_TO_DATE('[timestamp]','%d-%b-%Y'), '0')")
		if(!query_convert_time.Execute())
			return
		if(query_convert_time.NextRow())
			timestamp = query_convert_time.item[1]
		if(ckey && notetext && timestamp && admin_ckey && server)
			create_message("note", ckey, admin_ckey, notetext, timestamp, server, 1, 0)
	notesfile.cd = "/"
	notesfile.dir.Remove(ckey)

/*alternatively this proc can be run once to pass through every note and attempt to convert it before deleting the file, if done then AUTOCONVERT_NOTES should be turned off
this proc can take several minutes to execute fully if converting and cause DD to hang if converting a lot of notes; it's not advised to do so while a server is live
/proc/mass_convert_notes()
	to_chat(world, "Beginning mass note conversion")
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)
		log_game("Error: Cannot access [NOTESFILE]")
		return
	notesfile.cd = "/"
	for(var/ckey in notesfile.dir)
		convert_notes_sql(ckey)
	to_chat(world, "Deleting NOTESFILE")
	fdel(NOTESFILE)
	to_chat(world, "Finished mass note conversion, remember to turn off AUTOCONVERT_NOTES")*/
#undef NOTESFILE
