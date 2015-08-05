/client/proc/admin_memo()
	set name = "Memo"
	set category = "Server"
	if(!check_rights(0))	return
	if(!dbcon.IsConnected())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/memotask = input(usr,"Choose task.","Memo") in list("Show","Write","Edit","Remove")
	if(!memotask)
		return
	admin_memo_output(memotask)

/client/proc/admin_memo_output(task)
	if(!task)
		return
	if(!dbcon.IsConnected())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/sql_ckey = sanitizeSQL(src.ckey)
	switch(task)
		if("Write")
			var/DBQuery/query_memocheck = dbcon.NewQuery("SELECT ckey FROM [format_table_name("memo")] WHERE (ckey = '[sql_ckey]')")
			if(!query_memocheck.Execute())
				var/err = query_memocheck.ErrorMsg()
				log_game("SQL ERROR obtaining ckey from memo table. Error : \[[err]\]\n")
				return
			if(query_memocheck.NextRow())
				src << "You already have set a memo."
				return
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
			var/DBQuery/query_memolist = dbcon.NewQuery("SELECT ckey FROM [format_table_name("memo")]")
			if(!query_memolist.Execute())
				var/err = query_memolist.ErrorMsg()
				log_game("SQL ERROR obtaining ckey from memo table. Error : \[[err]\]\n")
				return
			var/list/memolist = list()
			while(query_memolist.NextRow())
				var/lkey = query_memolist.item[1]
				memolist += "[lkey]"
			if(!memolist.len)
				src << "No memos found in database."
				return
			var/target_ckey = input(src, "Select whose memo to edit", "Select memo") as null|anything in memolist
			if(!target_ckey)
				return
			var/target_sql_ckey = sanitizeSQL(target_ckey)
			var/DBQuery/query_memofind = dbcon.NewQuery("SELECT ckey, memotext FROM [format_table_name("memo")] WHERE (ckey = '[target_sql_ckey]')")
			if(!query_memofind.Execute())
				var/err = query_memofind.ErrorMsg()
				log_game("SQL ERROR obtaining ckey, memotext from memo table. Error : \[[err]\]\n")
				return
			if(query_memofind.NextRow())
				var/old_memo = query_memofind.item[2]
				var/new_memo = input("Input new memo", "New Memo", "[old_memo]", null) as null|text
				if(!new_memo)
					return
				new_memo = sanitizeSQL(new_memo)
				var/edit_text = "Edited by [sql_ckey] on [SQLtime()] from<br>[old_memo]<br>to<br>[new_memo]<hr>"
				edit_text = sanitizeSQL(edit_text)
				var/DBQuery/update_query = dbcon.NewQuery("UPDATE [format_table_name("memo")] SET memotext = '[new_memo]', last_editor = '[sql_ckey]', edits = CONCAT(IFNULL(edits,''),'[edit_text]') WHERE (ckey = '[target_sql_ckey]')")
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
			var/DBQuery/query_memoshow = dbcon.NewQuery("SELECT ckey, memotext, timestamp, last_editor FROM [format_table_name("memo")]")
			if(!query_memoshow.Execute())
				var/err = query_memoshow.ErrorMsg()
				log_game("SQL ERROR obtaining ckey, memotext, timestamp, last_editor from memo table. Error : \[[err]\]\n")
				return
			var/output = null
			while(query_memoshow.NextRow())
				var/ckey = query_memoshow.item[1]
				var/memotext = query_memoshow.item[2]
				var/timestamp = query_memoshow.item[3]
				var/last_editor = query_memoshow.item[4]
				output += "<span class='memo'>Memo by <span class='prefix'>[ckey]</span> on [timestamp]"
				if(last_editor)
					output += "<br><span class='memoedit'>Last edit by [last_editor] <A href='?_src_=holder;memoeditlist=[ckey]'>(Click here to see edit log)</A></span>"
				output += "<br>[memotext]</span><br>"
			if(!output)
				src << "No memos found in database."
				return
			src << output
		if("Remove")
			var/DBQuery/query_memodellist = dbcon.NewQuery("SELECT ckey FROM [format_table_name("memo")]")
			if(!query_memodellist.Execute())
				var/err = query_memodellist.ErrorMsg()
				log_game("SQL ERROR obtaining ckey from memo table. Error : \[[err]\]\n")
				return
			var/list/memolist = list()
			while(query_memodellist.NextRow())
				var/ckey = query_memodellist.item[1]
				memolist += "[ckey]"
			if(!memolist.len)
				src << "No memos found in database."
				return
			var/target_ckey = input(src, "Select whose memo to delete", "Select memo") as null|anything in memolist
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