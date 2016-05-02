/datum/polloption
	var/optionid
	var/optiontext

/mob/new_player/proc/handle_player_polling()
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/DBQuery/query_get_poll = dbcon.NewQuery("SELECT id, question FROM [format_table_name("poll_question")] WHERE [(client.holder ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime")
	if(!query_get_poll.Execute())
		var/err = query_get_poll.ErrorMsg()
		log_game("SQL ERROR obtaining id, question from poll_question table. Error : \[[err]\]\n")
		return
	var/output = "<div align='center'><B>Player polls</B><hr><table>"
	var/i = 0
	while(query_get_poll.NextRow())
		var/pollid = query_get_poll.item[1]
		var/pollquestion = query_get_poll.item[2]
		output += "<tr bgcolor='#[ (i % 2 == 1) ? "e2e2e2" : "e2e2e2" ]'><td><a href=\"byond://?src=\ref[src];pollid=[pollid]\"><b>[pollquestion]</b></a></td></tr>"
		i++
	output += "</table>"
	src << browse(output,"window=playerpolllist;size=500x300")

/mob/new_player/proc/poll_player(pollid)
	if(!pollid)
		return
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question, polltype, multiplechoiceoptions FROM [format_table_name("poll_question")] WHERE id = [pollid]")
	if(!select_query.Execute())
		var/err = select_query.ErrorMsg()
		log_game("SQL ERROR obtaining starttime, endtime, question, polltype, multiplechoiceoptions from poll_question table. Error : \[[err]\]\n")
		return
	var/pollstarttime = ""
	var/pollendtime = ""
	var/pollquestion = ""
	var/polltype = ""
	var/multiplechoiceoptions = 0
	if(select_query.NextRow())
		pollstarttime = select_query.item[1]
		pollendtime = select_query.item[2]
		pollquestion = select_query.item[3]
		polltype = select_query.item[4]
		multiplechoiceoptions = text2num(select_query.item[5])
	switch(polltype)
		if(POLLTYPE_OPTION)
			var/DBQuery/voted_query = dbcon.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!voted_query.Execute())
				var/err = voted_query.ErrorMsg()
				log_game("SQL ERROR obtaining optionid from poll_vote table. Error : \[[err]\]\n")
				return
			var/votedoptionid = 0
			if(voted_query.NextRow())
				votedoptionid = text2num(voted_query.item[1])
			var/list/datum/polloption/options = list()
			var/DBQuery/options_query = dbcon.NewQuery("SELECT id, text FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
			if(!options_query.Execute())
				var/err = options_query.ErrorMsg()
				log_game("SQL ERROR obtaining id, text from poll_option table. Error : \[[err]\]\n")
				return
			while(options_query.NextRow())
				var/datum/polloption/PO = new()
				PO.optionid = text2num(options_query.item[1])
				PO.optiontext = options_query.item[2]
				options += PO
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>"
			output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			if(!votedoptionid)
				output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
				output += "<input type='hidden' name='src' value='\ref[src]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_OPTION]>"
			output += "<table><tr><td>"
			for(var/datum/polloption/O in options)
				if(O.optionid && O.optiontext)
					if(votedoptionid)
						if(votedoptionid == O.optionid)
							output += "<b>[O.optiontext]</b><br>"
						else
							output += "[O.optiontext]<br>"
					else
						output += "<input type='radio' name='voteoptionid' value='[O.optionid]'>[O.optiontext]<br>"
			output += "</td></tr></table>"
			if(!votedoptionid)
				output += "<p><input type='submit' value='Vote'>"
				output += "</form>"
			output += "</div>"
			src << browse(output,"window=playerpoll;size=500x250")
		if(POLLTYPE_TEXT)
			var/DBQuery/voted_query = dbcon.NewQuery("SELECT replytext FROM [format_table_name("poll_textreply")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!voted_query.Execute())
				var/err = voted_query.ErrorMsg()
				log_game("SQL ERROR obtaining replytext from poll_textreply table. Error : \[[err]\]\n")
				return
			var/vote_text = ""
			if(voted_query.NextRow())
				vote_text = voted_query.item[1]
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>"
			output += "<font size='2'>Feedback gathering runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			if(!vote_text)
				output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
				output += "<input type='hidden' name='src' value='\ref[src]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_TEXT]>"
				output += "<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>"
				output += "<textarea name='replytext' cols='50' rows='14'></textarea>"
				output += "<p><input type='submit' value='Submit'></form>"
				output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
				output += "<input type='hidden' name='src' value='\ref[src]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_TEXT]>"
				output += "<input type='hidden' name='replytext' value='ABSTAIN'>"
				output += "<input type='submit' value='Abstain'></form>"
			else
				vote_text = replacetext(vote_text, "\n", "<br>")
				output += "[vote_text]"
			src << browse(output,"window=playerpoll;size=500x500")
		if(POLLTYPE_RATING)
			var/DBQuery/voted_query = dbcon.NewQuery("SELECT o.text, v.rating FROM [format_table_name("poll_option")] o, [format_table_name("poll_vote")] v WHERE o.pollid = [pollid] AND v.ckey = '[ckey]' AND o.id = v.optionid")
			if(!voted_query.Execute())
				var/err = voted_query.ErrorMsg()
				log_game("SQL ERROR obtaining o.text, v.rating from poll_option and poll_vote tables. Error : \[[err]\]\n")
				return
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>"
			output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			var/rating
			while(voted_query.NextRow())
				var/optiontext = voted_query.item[1]
				rating = voted_query.item[2]
				output += "<br><b>[optiontext] - [rating]</b>"
			if(!rating)
				output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
				output += "<input type='hidden' name='src' value='\ref[src]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_RATING]>"
				var/minid = 999999
				var/maxid = 0
				var/DBQuery/option_query = dbcon.NewQuery("SELECT id, text, minval, maxval, descmin, descmid, descmax FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
				if(!option_query.Execute())
					var/err = option_query.ErrorMsg()
					log_game("SQL ERROR obtaining id, text, minval, maxval, descmin, descmid, descmax from poll_option table. Error : \[[err]\]\n")
					return
				while(option_query.NextRow())
					var/optionid = text2num(option_query.item[1])
					var/optiontext = option_query.item[2]
					var/minvalue = text2num(option_query.item[3])
					var/maxvalue = text2num(option_query.item[4])
					var/descmin = option_query.item[5]
					var/descmid = option_query.item[6]
					var/descmax = option_query.item[7]
					if(optionid < minid)
						minid = optionid
					if(optionid > maxid)
						maxid = optionid
					var/midvalue = round( (maxvalue + minvalue) / 2)
					output += "<br>[optiontext]: <select name='o[optionid]'>"
					output += "<option value='abstain'>abstain</option>"
					for (var/j = minvalue; j <= maxvalue; j++)
						if(j == minvalue && descmin)
							output += "<option value='[j]'>[j] ([descmin])</option>"
						else if (j == midvalue && descmid)
							output += "<option value='[j]'>[j] ([descmid])</option>"
						else if (j == maxvalue && descmax)
							output += "<option value='[j]'>[j] ([descmax])</option>"
						else
							output += "<option value='[j]'>[j]</option>"
					output += "</select>"
				output += "<input type='hidden' name='minid' value='[minid]'>"
				output += "<input type='hidden' name='maxid' value='[maxid]'>"
				output += "<p><input type='submit' value='Submit'></form>"
			src << browse(output,"window=playerpoll;size=500x500")
		if(POLLTYPE_MULTI)
			var/DBQuery/voted_query = dbcon.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!voted_query.Execute())
				var/err = voted_query.ErrorMsg()
				log_game("SQL ERROR obtaining optionid from poll_vote table. Error : \[[err]\]\n")
				return
			var/list/votedfor = list()
			while(voted_query.NextRow())
				votedfor.Add(text2num(voted_query.item[1]))
			var/list/datum/polloption/options = list()
			var/maxoptionid = 0
			var/minoptionid = 0
			var/DBQuery/options_query = dbcon.NewQuery("SELECT id, text FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
			if(!options_query.Execute())
				var/err = options_query.ErrorMsg()
				log_game("SQL ERROR obtaining id, text from poll_option table. Error : \[[err]\]\n")
				return
			while(options_query.NextRow())
				var/datum/polloption/PO = new()
				PO.optionid = text2num(options_query.item[1])
				PO.optiontext = options_query.item[2]
				if(PO.optionid > maxoptionid)
					maxoptionid = PO.optionid
				if(PO.optionid < minoptionid || !minoptionid)
					minoptionid = PO.optionid
				options += PO
			var/output = "<div align='center'><B>Player poll</B><hr>"
			output += "<b>Question: [pollquestion]</b><br>You can select up to [multiplechoiceoptions] options. If you select more, the first [multiplechoiceoptions] will be saved.<br>"
			output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"
			if(!votedfor.len)
				output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
				output += "<input type='hidden' name='src' value='\ref[src]'>"
				output += "<input type='hidden' name='votepollid' value='[pollid]'>"
				output += "<input type='hidden' name='votetype' value=[POLLTYPE_MULTI]>"
				output += "<input type='hidden' name='maxoptionid' value='[maxoptionid]'>"
				output += "<input type='hidden' name='minoptionid' value='[minoptionid]'>"
			output += "<table><tr><td>"
			for(var/datum/polloption/O in options)
				if(O.optionid && O.optiontext)
					if(votedfor.len)
						if(O.optionid in votedfor)
							output += "<b>[O.optiontext]</b><br>"
						else
							output += "[O.optiontext]<br>"
					else
						output += "<input type='checkbox' name='option_[O.optionid]' value='[O.optionid]'>[O.optiontext]<br>"
			output += "</td></tr></table>"
			if(!votedfor.len)
				output += "<p><input type='submit' value='Vote'></form>"
			output += "</div>"
			src << browse(output,"window=playerpoll;size=500x250")
	return

/mob/new_player/proc/poll_check_voted(pollid, table)
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/DBQuery/query_hasvoted = dbcon.NewQuery("SELECT id FROM [format_table_name(table)] WHERE pollid = [pollid] AND ckey = '[ckey]'")
	if(!query_hasvoted.Execute())
		var/err = query_hasvoted.ErrorMsg()
		log_game("SQL ERROR obtaining id from [table] table. Error : \[[err]\]\n")
		return
	if(query_hasvoted.NextRow())
		usr << "<span class='danger'>You've already replied to this poll.</span>"
		return
	. = "Player"
	if(client.holder)
		. = client.holder.rank
	return .

/mob/new_player/proc/vote_on_poll(pollid, optionid)
	if(!pollid || !optionid)
		return
	var/adminrank = poll_check_voted(pollid, "poll_vote")
	if(!adminrank)
		return
	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO [format_table_name("poll_vote")] (datetime, pollid, optionid, ckey, ip, adminrank) VALUES (Now(), [pollid], [optionid], '[ckey]', '[client.address]', '[adminrank]')")
	if(!query_insert.Execute())
		var/err = query_insert.ErrorMsg()
		log_game("SQL ERROR adding vote to table. Error : \[[err]\]\n")
		return
	usr << browse(null,"window=playerpoll")
	return 1

/mob/new_player/proc/log_text_poll_reply(pollid, replytext)
	if(!pollid)
		return
	if(!replytext)
		usr << "The text you entered was blank. Please correct the text and submit again."
		return
	var/adminrank = poll_check_voted(pollid, "poll_textreply")
	if(!adminrank)
		return
	replytext = sanitizeSQL(replytext)
	if(!(length(replytext) > 0) || !(length(replytext) <= 8000))
		usr << "The text you entered was invalid or too long. Please correct the text and submit again."
		return
	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO [format_table_name("poll_textreply")] (datetime ,pollid ,ckey ,ip ,replytext ,adminrank) VALUES (Now(), [pollid], '[ckey]', '[client.address]', '[replytext]', '[adminrank]')")
	if(!query_insert.Execute())
		var/err = query_insert.ErrorMsg()
		log_game("SQL ERROR adding text reply to table. Error : \[[err]\]\n")
		return
	usr << browse(null,"window=playerpoll")
	return 1

/mob/new_player/proc/vote_on_numval_poll(pollid, optionid, rating)
	if(!pollid || !optionid || !rating)
		return
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/DBQuery/query_hasvoted = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_vote")] WHERE optionid = [optionid] AND ckey = '[ckey]'")
	if(!query_hasvoted.Execute())
		var/err = query_hasvoted.ErrorMsg()
		log_game("SQL ERROR obtaining id from poll_vote table. Error : \[[err]\]\n")
		return
	if(query_hasvoted.NextRow())
		usr << "<span class='danger'>You've already replied to this poll.</span>"
		return
	var/adminrank = "Player"
	if(client.holder)
		adminrank = client.holder.rank
	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO [format_table_name("poll_vote")] (datetime ,pollid ,optionid ,ckey ,ip ,adminrank, rating) VALUES (Now(), [pollid], [optionid], '[ckey]', '[client.address]', '[adminrank]', [(isnull(rating)) ? "null" : rating])")
	if(!query_insert.Execute())
		var/err = query_insert.ErrorMsg()
		log_game("SQL ERROR adding vote to table. Error : \[[err]\]\n")
		return
	usr << browse(null,"window=playerpoll")
	return 1

/mob/new_player/proc/vote_on_multi_poll(pollid, optionid)
	if(!pollid || !optionid)
		return 1
	if(!dbcon.IsConnected())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return 1
	var/DBQuery/query_get_choicelen = dbcon.NewQuery("SELECT multiplechoiceoptions FROM [format_table_name("poll_question")] WHERE id = [pollid]")
	if(!query_get_choicelen.Execute())
		var/err = query_get_choicelen.ErrorMsg()
		log_game("SQL ERROR obtaining multiplechoiceoptions from poll_question table. Error : \[[err]\]\n")
		return 1
	var/i
	if(query_get_choicelen.NextRow())
		i = text2num(query_get_choicelen.item[1])
	var/DBQuery/query_hasvoted = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
	if(!query_hasvoted.Execute())
		var/err = query_hasvoted.ErrorMsg()
		log_game("SQL ERROR obtaining id from poll_vote table. Error : \[[err]\]\n")
		return 1
	while(i)
		if(query_hasvoted.NextRow())
			i--
		else
			break
	if(!i)
		return 2
	var/adminrank = "Player"
	if(client.holder)
		adminrank = client.holder.rank
	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO [format_table_name("poll_vote")] (datetime, pollid, optionid, ckey, ip, adminrank) VALUES (Now(), [pollid], [optionid], '[ckey]', '[client.address]', '[adminrank]')")
	if(!query_insert.Execute())
		var/err = query_insert.ErrorMsg()
		log_game("SQL ERROR adding vote to table. Error : \[[err]\]\n")
		return 1
	usr << browse(null,"window=playerpoll")
	return 0