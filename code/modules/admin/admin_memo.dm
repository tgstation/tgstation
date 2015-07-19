/client/proc/admin_memo(task in list("Show","Write","Edit","Remove"))
	set name = "Memo"
	set category = "Server"
	if(!check_rights(0))	return
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/sql_ckey = sanitizeSQL(src.ckey)
	switch(task)
		if("Write")
			var/memotext = input(src,"Write your Memo","Memo") as text|null
			if(!memotext)
				return
			memotext = sanitizeSQL(memotext)
			var/timestamp = SQLtime()
			var/DBQuery/query_memoadd = dbcon.NewQuery("INSERT INTO [format_table_name("memo")] (ckey, memotext, timestamp) VALUES ('[sql_ckey]', '[memotext]', '[timestamp]')")
			if(!query_memoadd.Execute())
				var/err = query_memoadd.ErrorMsg()
				log_game("SQL ERROR adding new memo. Error : \[[err]\]\n")
				return
			log_admin("[key_name(src)] has set a memo: [memotext]")
			message_admins("[key_name_admin(src)] has set a memo:<br>[memotext]")
		if("Edit")
			var/DBQuery/query_memolist = dbcon.NewQuery("SELECT ckey FROM [format_table_name("memo")])") //should select all memos there are
			query_memolist.Execute()
			var/list/memolist = list()
			while(query_memolist.NextRow())
				var/ckey = query_memolist.item[2]
				memolist += "[ckey]"
			if(!memolist.len)
				src << "No memos found in database."
				return
			var/target_ckey = input(src, "Select whose memo to edit", "Select memo") as null|anything in memolist
			if(!target_ckey)
				return
			var/target_sql_ckey = sanitizeSQL(target_ckey)
			var/DBQuery/query_memofind = dbcon.NewQuery("SELECT ckey, memotext FROM [format_table_name("memo")] WHERE (ckey = '[target_sql_ckey]')")
			query_memofind.Execute()
			if(query_memofind.NextRow())
				var/old_memo = query_memofind.item[3]
				var/new_memo = input("Input new memo", "New Memo", "[old_memo]", null) as null|text
				if(!new_memo)
					return
				new_memo = sanitizeSQL(new_memo)
				var/edit_text = "Edited by [sql_ckey] on [SQLtime()] from<br>[old_memo]<br>to<br>[new_memo]<hr>"
				edit_text = sanitizeSQL(edit_text)
				var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("memo")] SET memotext = '[new_memo]', last_editor = '[sql_ckey]', edits = CONCAT(edits,'[edit_text]') WHERE (ckey = '[target_sql_ckey]')")
				if(!update_query.Execute())
					var/err = update_query.ErrorMsg()
					log_game("SQL ERROR editing memo. Error : \[[err]\]\n")
					return
				if(target_sql_ckey == sql_ckey)
					log_admin("[key_name(src)] has edited their memo from [old_memo] to [new_memo]")
					message_admins("[key_name_admin(src)] has edited their memo from<br>[old_memo]<br>to<br>[new_memo]")
				else
					log_admin("[key_name(src)] has edited [target_sql_ckey]'s memo from [old_memo] to [new_memo]")
					message_admins("[key_name_admin(src)] has edited [target_sql_ckey]'s memo from<br>[old_memo]<br>to<br>[new_memo]")
		if("Show")
			var/DBQuery/query_memoshow = dbcon.NewQuery("SELECT id, ckey, memotext, timestamp, last_editor FROM [format_table_name("memo")])")
			while(query_memoshow.NextRow())
				var/output
				var/id = query_memoshow.item[1]
				var/ckey = query_memoshow.item[2]
				var/memotext = query_memoshow.item[3]
				var/timestamp = query_memoshow.item[4]
				var/last_editor = query_memoshow.item[5]
				output += "<span class='memo'>Memo by <span class='prefix'>[ckey]</span> on [timestamp]:"
				if(last_editor)
					output += "<br><span class='memoedit'>Last edit by [last_editor] <A href='?_src_=holder;memoeditlist=[id]'>(Click here to see edit log)</A></span>"
				output += "<br>[memotext]</span><br>
			src << output
		if("Remove")
			var/DBQuery/query_memolist = dbcon.NewQuery("SELECT ckey FROM [format_table_name("memo")])") //should select all memos there are
			query_memolist.Execute()
			if(!query_memolist.NextRow())
				src << "No memos found in database."
				return
			var/target_ckey = input(src, "Select whose memo to delete", "Select memo") as null|anything in query_memolist //does this work? it's not initialized as an actual list
			if(!target_ckey)
				return
			var/target_sql_ckey = sanitizeSQL(target_ckey)
			var/DBQuery/query_memodel = dbcon.NewQuery("DELETE FROM [format_table_name("memo")] WHERE ckey = '[target_sql_ckey]'")
			if(!query_memodel.Execute())
				var/err = query_memodel.ErrorMsg()
				log_game("SQL ERROR removing memo. Error : \[[err]\]\n")
				return
			if(target_sql_ckey == sql_ckey)
				log_admin("[key_name(src)] has removed their memo.")
				message_admins("[key_name_admin(src)] has removed their memo.")
			else
				log_admin("[key_name(src)] has removed [target_sql_ckey]'s memo.")
				message_admins("[key_name_admin(src)] has removed [target_sql_ckey]'s memo.")