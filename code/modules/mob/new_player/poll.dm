
/mob/new_player/proc/handle_privacy_poll()
	establish_db_connection()
	if(!dbcon.IsConnected())
		return
	var/voted = 0

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_privacy WHERE ckey='[src.ckey]'")
	query.Execute()
	while(query.NextRow())
		voted = 1
		break

	if(!voted)
		privacy_poll()

/mob/new_player/proc/privacy_poll()
	var/output = "<div align='center'><B>Player poll</B>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:19: output +="<hr>"
	output += {"<hr>
		<b>We would like to expand our stats gathering.</b>
		<br>This however involves gathering data about player behavior, play styles, unique player numbers, play times, etc. Data like that cannot be gathered fully anonymously, which is why we're asking you how you'd feel if player-specific data was gathered. Prior to any of this actually happening, a privacy policy will be discussed, but before that can begin, we'd preliminarily like to know how you feel about the concept.
		<hr>
		How do you feel about the game gathering player-specific statistics? This includes statistics about individual players as well as in-game polling/opinion requests.
		<p><a href='byond://?src=\ref[src];privacy_poll=signed'>Signed stats gathering</A>
		<br>Pick this option if you think usernames should be logged with stats. This allows us to have personalized stats as well as polls.
		<p><a href='byond://?src=\ref[src];privacy_poll=anonymous'>Anonymous stats gathering</A>
		<br>Pick this option if you think only hashed (indecipherable) usernames should be logged with stats. This doesn't allow us to have personalized stats, as we can't tell who is who (hashed values aren't readable), we can however have ingame polls.
		<p><a href='byond://?src=\ref[src];privacy_poll=nostats'>No stats gathering</A>
		<br>Pick this option if you don't want player-specific stats gathered. This does not allow us to have player-specific stats or polls.
		<p><a href='byond://?src=\ref[src];privacy_poll=later'>Ask again later</A>
		<br>This poll will be brought up again next round.
		<p><a href='byond://?src=\ref[src];privacy_poll=abstain'>Don't ask again</A>
		<br>Only pick this if you are fine with whatever option wins.
		</div>"}
	// END AUTOFIX
	src << browse(output,"window=privacypoll;size=600x500")
	return

/datum/polloption
	var/optionid
	var/optiontext

/mob/new_player/proc/handle_player_polling()
	establish_db_connection()
	if(dbcon.IsConnected())
		var/isadmin = 0
		if(src.client && src.client.holder)
			isadmin = 1

		var/DBQuery/select_query = dbcon.NewQuery("SELECT id, question FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime")
		select_query.Execute()


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:56: var/output = "<div align='center'><B>Player polls</B>"
		var/output = {"<div align='center'><B>Player polls</B>
<hr>"}
		// END AUTOFIX
		var/pollid
		var/pollquestion

		output += "<table>"
		var/color1 = "#ececec"
		var/color2 = "#e2e2e2"
		var/i = 0

		while(select_query.NextRow())
			pollid = select_query.item[1]
			pollquestion = select_query.item[2]
			output += "<tr bgcolor='[ (i % 2 == 1) ? color1 : color2 ]'><td><a href=\"byond://?src=\ref[src];pollid=[pollid]\"><b>[pollquestion]</b></a> | <a href=\"byond://?src=\ref[src];pollid=[pollid];results=1\">Results</a></td></tr>"
			i++

		output += "</table>"

		src << browse(output,"window=playerpolllist;size=500x300")



/mob/new_player/proc/poll_player(var/pollid = -1)
	if(pollid == -1) return
	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question, polltype, multiplechoiceoptions FROM erro_poll_question WHERE id = [pollid]")
		select_query.Execute()

		var/pollstarttime = ""
		var/pollendtime = ""
		var/pollquestion = ""
		var/polltype = ""
		var/found = 0
		var/multiplechoiceoptions = 0

		while(select_query.NextRow())
			pollstarttime = select_query.item[1]
			pollendtime = select_query.item[2]
			pollquestion = select_query.item[3]
			polltype = select_query.item[4]
			found = 1
			break

		if(!found)
			usr << "\red Poll question details not found."
			return

		switch(polltype)
			//Polls that have enumerated options
			if("OPTION")
				var/DBQuery/voted_query = dbcon.NewQuery("SELECT optionid FROM erro_poll_vote WHERE pollid = [pollid] AND ckey = '[usr.ckey]'")
				voted_query.Execute()

				var/voted = 0
				var/votedoptionid = 0
				while(voted_query.NextRow())
					votedoptionid = text2num(voted_query.item[1])
					voted = 1
					break

				var/list/datum/polloption/options = list()

				var/DBQuery/options_query = dbcon.NewQuery("SELECT id, text FROM erro_poll_option WHERE pollid = [pollid]")
				options_query.Execute()
				while(options_query.NextRow())
					var/datum/polloption/PO = new()
					PO.optionid = text2num(options_query.item[1])
					PO.optiontext = options_query.item[2]
					options += PO

				var/output = "<div align='center'><B>Player poll</B>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:133: output +="<hr>"
				output += {"<hr>
					<b>Question: [pollquestion]</b><br>
					<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"}
				// END AUTOFIX
				if(!voted)	//Only make this a form if we have not voted yet

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:138: output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += {"<form name='cardcomp' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='votepollid' value='[pollid]'>
						<input type='hidden' name='votetype' value='OPTION'>"}
					// END AUTOFIX

				output += "<table><tr><td>"
				for(var/datum/polloption/O in options)
					if(O.optionid && O.optiontext)
						if(voted)
							if(votedoptionid == O.optionid)
								output += "<b>[O.optiontext]</b><br>"
							else
								output += "[O.optiontext]<br>"
						else
							output += "<input type='radio' name='voteoptionid' value='[O.optionid]'> [O.optiontext]<br>"
				output += "</td></tr></table>"

				if(!voted)	//Only make this a form if we have not voted yet

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:156: output += "<p><input type='submit' value='Vote'>"
					output += {"<p><input type='submit' value='Vote'>
						</form>"}
					// END AUTOFIX

				output += "</div>"

				src << browse(output,"window=playerpoll;size=500x250")

			//Polls with a text input
			if("TEXT")
				var/DBQuery/voted_query = dbcon.NewQuery("SELECT replytext FROM erro_poll_textreply WHERE pollid = [pollid] AND ckey = '[usr.ckey]'")
				voted_query.Execute()

				var/voted = 0
				var/vote_text = ""
				while(voted_query.NextRow())
					vote_text = voted_query.item[1]
					voted = 1
					break


				var/output = "<div align='center'><B>Player poll</B>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:177: output +="<hr>"
				output += {"<hr>
					<b>Question: [pollquestion]</b><br>
					<font size='2'>Feedback gathering runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"}
				// END AUTOFIX
				if(!voted)	//Only make this a form if we have not voted yet

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:182: output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += {"<form name='cardcomp' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='votepollid' value='[pollid]'>
						<input type='hidden' name='votetype' value='TEXT'>
						<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>
						<textarea name='replytext' cols='50' rows='14'></textarea>
						<p><input type='submit' value='Submit'>
						</form>
						<form name='cardcomp' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='votepollid' value='[pollid]'>
						<input type='hidden' name='votetype' value='TEXT'>
						<input type='hidden' name='replytext' value='ABSTAIN'>
						<input type='submit' value='Abstain'>
						</form>"}
					// END AUTOFIX
				else
					output += "[vote_text]"

				src << browse(output,"window=playerpoll;size=500x500")

			//Polls with a text input
			if("NUMVAL")
				var/DBQuery/voted_query = dbcon.NewQuery("SELECT o.text, v.rating FROM erro_poll_option o, erro_poll_vote v WHERE o.pollid = [pollid] AND v.ckey = '[usr.ckey]' AND o.id = v.optionid")
				voted_query.Execute()

				var/output = "<div align='center'><B>Player poll</B>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:211: output +="<hr>"
				output += {"<hr>
					<b>Question: [pollquestion]</b><br>
					<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"}
				// END AUTOFIX
				var/voted = 0
				while(voted_query.NextRow())
					voted = 1

					var/optiontext = voted_query.item[1]
					var/rating = voted_query.item[2]

					output += "<br><b>[optiontext] - [rating]</b>"

				if(!voted)	//Only make this a form if we have not voted yet

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:225: output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += {"<form name='cardcomp' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='votepollid' value='[pollid]'>
						<input type='hidden' name='votetype' value='NUMVAL'>"}
					// END AUTOFIX
					var/minid = 999999
					var/maxid = 0

					var/DBQuery/option_query = dbcon.NewQuery("SELECT id, text, minval, maxval, descmin, descmid, descmax FROM erro_poll_option WHERE pollid = [pollid]")
					option_query.Execute()
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

						if(isnull(minvalue) || isnull(maxvalue) || (minvalue == maxvalue))
							continue


						// AUTOFIXED BY fix_string_idiocy.py
						// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:254: output += "<br>[optiontext]: <select name='o[optionid]'>"
						output += {"<br>[optiontext]: <select name='o[optionid]'>
							<option value='abstain'>abstain</option>"}
						// END AUTOFIX
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


					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:268: output += "<input type='hidden' name='minid' value='[minid]'>"
					output += {"<input type='hidden' name='minid' value='[minid]'>
						<input type='hidden' name='maxid' value='[maxid]'>
						<p><input type='submit' value='Submit'>
						</form>"}
					// END AUTOFIX
				src << browse(output,"window=playerpoll;size=500x500")
			if("MULTICHOICE")
				var/DBQuery/voted_query = dbcon.NewQuery("SELECT optionid FROM erro_poll_vote WHERE pollid = [pollid] AND ckey = '[usr.ckey]'")
				voted_query.Execute()

				var/list/votedfor = list()
				var/voted = 0
				while(voted_query.NextRow())
					votedfor.Add(text2num(voted_query.item[1]))
					voted = 1

				var/list/datum/polloption/options = list()
				var/maxoptionid = 0
				var/minoptionid = 0

				var/DBQuery/options_query = dbcon.NewQuery("SELECT id, text FROM erro_poll_option WHERE pollid = [pollid]")
				options_query.Execute()
				while(options_query.NextRow())
					var/datum/polloption/PO = new()
					PO.optionid = text2num(options_query.item[1])
					PO.optiontext = options_query.item[2]
					if(PO.optionid > maxoptionid)
						maxoptionid = PO.optionid
					if(PO.optionid < minoptionid || !minoptionid)
						minoptionid = PO.optionid
					options += PO


				if(select_query.item[5])
					multiplechoiceoptions = text2num(select_query.item[5])

				var/output = "<div align='center'><B>Player poll</B>"

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:306: output +="<hr>"
				output += {"<hr>
					<b>Question: [pollquestion]</b><br>You can select up to [multiplechoiceoptions] options. If you select more, the first [multiplechoiceoptions] will be saved.<br>
					<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"}
				// END AUTOFIX
				if(!voted)	//Only make this a form if we have not voted yet

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:311: output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
					output += {"<form name='cardcomp' action='?src=\ref[src]' method='get'>
						<input type='hidden' name='src' value='\ref[src]'>
						<input type='hidden' name='votepollid' value='[pollid]'>
						<input type='hidden' name='votetype' value='MULTICHOICE'>
						<input type='hidden' name='maxoptionid' value='[maxoptionid]'>
						<input type='hidden' name='minoptionid' value='[minoptionid]'>"}
					// END AUTOFIX

				output += "<table><tr><td>"
				for(var/datum/polloption/O in options)
					if(O.optionid && O.optiontext)
						if(voted)
							if(O.optionid in votedfor)
								output += "<b>[O.optiontext]</b><br>"
							else
								output += "[O.optiontext]<br>"
						else
							output += "<input type='checkbox' name='option_[O.optionid]' value='[O.optionid]'> [O.optiontext]<br>"
				output += "</td></tr></table>"

				if(!voted)	//Only make this a form if we have not voted yet

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\mob\new_player\poll.dm:331: output += "<p><input type='submit' value='Vote'>"
					output += {"<p><input type='submit' value='Vote'>
						</form>"}
					// END AUTOFIX

				output += "</div>"

				src << browse(output,"window=playerpoll;size=500x250")
		return

/mob/new_player/proc/vote_on_poll(var/pollid = -1, var/optionid = -1, var/multichoice = 0)
	if(pollid == -1 || optionid == -1)
		return

	if(!isnum(pollid) || !isnum(optionid))
		return
	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question, polltype, multiplechoiceoptions FROM erro_poll_question WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime")
		select_query.Execute()

		var/validpoll = 0
		var/multiplechoiceoptions = 0

		while(select_query.NextRow())
			if(select_query.item[4] != "OPTION" && select_query.item[4] != "MULTICHOICE")
				return
			validpoll = 1
			if(select_query.item[5])
				multiplechoiceoptions = text2num(select_query.item[5])
			break

		if(!validpoll)
			usr << "\red Poll is not valid."
			return

		var/DBQuery/select_query2 = dbcon.NewQuery("SELECT id FROM erro_poll_option WHERE id = [optionid] AND pollid = [pollid]")
		select_query2.Execute()

		var/validoption = 0

		while(select_query2.NextRow())
			validoption = 1
			break

		if(!validoption)
			usr << "\red Poll option is not valid."
			return

		var/alreadyvoted = 0

		var/DBQuery/voted_query = dbcon.NewQuery("SELECT id FROM erro_poll_vote WHERE pollid = [pollid] AND ckey = '[usr.ckey]'")
		voted_query.Execute()

		while(voted_query.NextRow())
			alreadyvoted += 1
			if(!multichoice)
				break

		if(!multichoice && alreadyvoted)
			usr << "\red You already voted in this poll."
			return

		if(multichoice && (alreadyvoted >= multiplechoiceoptions))
			usr << "\red You already have more than [multiplechoiceoptions] logged votes on this poll. Enough is enough. Contact the database admin if this is an error."
			return

		var/adminrank = "Player"
		if(usr && usr.client && usr.client.holder)
			adminrank = usr.client.holder.rank


		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO erro_poll_vote (id ,datetime ,pollid ,optionid ,ckey ,ip ,adminrank) VALUES (null, Now(), [pollid], [optionid], '[usr.ckey]', '[usr.client.address]', '[adminrank]')")
		insert_query.Execute()

		usr << "\blue Vote successful."
		usr << browse(null,"window=playerpoll")


/mob/new_player/proc/log_text_poll_reply(var/pollid = -1, var/replytext = "")
	if(pollid == -1 || replytext == "")
		return

	if(!isnum(pollid) || !istext(replytext))
		return
	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question, polltype FROM erro_poll_question WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime")
		select_query.Execute()

		var/validpoll = 0

		while(select_query.NextRow())
			if(select_query.item[4] != "TEXT")
				return
			validpoll = 1
			break

		if(!validpoll)
			usr << "\red Poll is not valid."
			return

		var/alreadyvoted = 0

		var/DBQuery/voted_query = dbcon.NewQuery("SELECT id FROM erro_poll_textreply WHERE pollid = [pollid] AND ckey = '[usr.ckey]'")
		voted_query.Execute()

		while(voted_query.NextRow())
			alreadyvoted = 1
			break

		if(alreadyvoted)
			usr << "\red You already sent your feedback for this poll."
			return

		var/adminrank = "Player"
		if(usr && usr.client && usr.client.holder)
			adminrank = usr.client.holder.rank


		replytext = replacetext(replytext, "%BR%", "")
		replytext = replacetext(replytext, "\n", "%BR%")
		var/text_pass = reject_bad_text(replytext,8000)
		replytext = replacetext(replytext, "%BR%", "<BR>")

		if(!text_pass)
			usr << "The text you entered was blank, contained illegal characters or was too long. Please correct the text and submit again."
			return

		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO erro_poll_textreply (id ,datetime ,pollid ,ckey ,ip ,replytext ,adminrank) VALUES (null, Now(), [pollid], '[usr.ckey]', '[usr.client.address]', '[replytext]', '[adminrank]')")
		insert_query.Execute()

		usr << "\blue Feedback logging successful."
		usr << browse(null,"window=playerpoll")


/mob/new_player/proc/vote_on_numval_poll(var/pollid = -1, var/optionid = -1, var/rating = null)
	if(pollid == -1 || optionid == -1)
		return

	if(!isnum(pollid) || !isnum(optionid))
		return
	establish_db_connection()
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question, polltype FROM erro_poll_question WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime")
		select_query.Execute()

		var/validpoll = 0

		while(select_query.NextRow())
			if(select_query.item[4] != "NUMVAL")
				return
			validpoll = 1
			break

		if(!validpoll)
			usr << "\red Poll is not valid."
			return

		var/DBQuery/select_query2 = dbcon.NewQuery("SELECT id FROM erro_poll_option WHERE id = [optionid] AND pollid = [pollid]")
		select_query2.Execute()

		var/validoption = 0

		while(select_query2.NextRow())
			validoption = 1
			break

		if(!validoption)
			usr << "\red Poll option is not valid."
			return

		var/alreadyvoted = 0

		var/DBQuery/voted_query = dbcon.NewQuery("SELECT id FROM erro_poll_vote WHERE optionid = [optionid] AND ckey = '[usr.ckey]'")
		voted_query.Execute()

		while(voted_query.NextRow())
			alreadyvoted = 1
			break

		if(alreadyvoted)
			usr << "\red You already voted in this poll."
			return

		var/adminrank = "Player"
		if(usr && usr.client && usr.client.holder)
			adminrank = usr.client.holder.rank


		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO erro_poll_vote (id ,datetime ,pollid ,optionid ,ckey ,ip ,adminrank, rating) VALUES (null, Now(), [pollid], [optionid], '[usr.ckey]', '[usr.client.address]', '[adminrank]', [(isnull(rating)) ? "null" : rating])")
		insert_query.Execute()

		usr << "\blue Vote successful."
		usr << browse(null,"window=playerpoll")