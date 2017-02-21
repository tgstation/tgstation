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
	if (!dbcon.Connect())
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
			src << browse(null ,"window=playerpolllist")
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
			src << browse(null ,"window=playerpolllist")
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
			src << browse(null ,"window=playerpolllist")
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
			src << browse(null ,"window=playerpolllist")
			src << browse(output,"window=playerpoll;size=500x250")
		if(POLLTYPE_IRV)
			var/datum/asset/irv_assets = get_asset_datum(/datum/asset/simple/IRV)
			irv_assets.send(src)

			var/DBQuery/voted_query = dbcon.NewQuery("SELECT optionid FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
			if(!voted_query.Execute())
				var/err = voted_query.ErrorMsg()
				log_game("SQL ERROR obtaining optionid from poll_vote table. Error : \[[err]\]\n")
				return

			var/list/votedfor = list()
			while(voted_query.NextRow())
				votedfor.Add(text2num(voted_query.item[1]))

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
				options["[PO.optionid]"] += PO

			//if they already voted, use their sort
			if (votedfor.len)
				var/list/datum/polloption/newoptions = list()
				for (var/V in votedfor)
					var/datum/polloption/PO = options["[V]"]
					if(PO)
						newoptions["[V]"] = PO
						options -= "[V]"
				//add any options that they didn't vote on (some how, some way)
				options = shuffle(options)
				for (var/V in options)
					newoptions["[V]"] = options["[V]"]
				options = newoptions
			//otherwise, lets shuffle it.
			else
				var/list/datum/polloption/newoptions = list()
				while (options.len)
					var/list/local_options = options.Copy()
					var/key
					//the jist is we randomly remove all options from a copy of options until only one reminds,
					//	move that over to our new list
					//	and repeat until we've moved all of them
					while (local_options.len)
						key = local_options[rand(1, local_options.len)]
						local_options -= key
					var/value = options[key]
					options -= key
					newoptions[key] = value
				options = newoptions

			var/output = {"
				<html>
				<head>
				<meta http-equiv="X-UA-Compatible" content="IE=edge" />
				<script src="jquery-1.10.2.min.js"></script>
				<script src="jquery-ui.custom-core-widgit-mouse-sortable-min.js"></script>
				<style>
					#sortable { list-style-type: none; margin: 0; padding: 2em; }
					#sortable li { min-height: 1em; margin: 0px 1px 1px 1px; padding: 1px; border: 1px solid black; border-radius: 5px; background-color: white; cursor:move;}
					#sortable .sortable-placeholder-highlight { min-height: 1em; margin: 0 2px 2px 2px; padding: 2px; border: 1px dotted blue; border-radius: 5px; background-color: GhostWhite; }
					span.grippy { content: '....'; width: 10px; height: 20px; display: inline-block; overflow: hidden; line-height: 5px; padding: 3px 1px; cursor: move; vertical-align: middle; margin-top: -.7em; margin-right: .3em; font-size: 12px; font-family: sans-serif; letter-spacing: 2px; color: #cccccc; text-shadow: 1px 0 1px black; }
					span.grippy::after { content: '.. .. .. ..';}
				</style>
				<script>
					$(function() {
						$( "#sortable" ).sortable({
							placeholder: "sortable-placeholder-highlight",
							axis: "y",
							containment: "#ballot",
							scroll: false,
							cursor: "ns-resize",
							tolerance: "pointer"
						});
						$( "#sortable" ).disableSelection();
						$('form').submit(function(){
						    $('#IRVdata').val($( "#sortable" ).sortable("toArray", { attribute: "voteid" }));
						});
					});

				</script>
				</head>
				<body>
				<div align='center'><B>Player poll</B><hr>
				<b>Question: [pollquestion]</b><br>Please sort the options in the order of <b>most preferred</b> to <b>least preferred</b><br>
				<font size='2'>Revoting has been enabled on this poll, if you think you made a mistake, simply revote<br></font>
				<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>
				</div>
				<form name='cardcomp' action='?src=\ref[src]' method='POST'>
				<input type='hidden' name='src' value='\ref[src]'>
				<input type='hidden' name='votepollid' value='[pollid]'>
				<input type='hidden' name='votetype' value=[POLLTYPE_IRV]>
				<input type='hidden' name='IRVdata' id='IRVdata'>
				<div id="ballot" class="center">
				<b><center>Most Preferred</center></b>
				<ol id="sortable" class="rankings" style="padding:0px">
			"}
			for(var/O in options)
				var/datum/polloption/PO = options["[O]"]
				if(PO.optionid && PO.optiontext)
					output += "<li voteid='[PO.optionid]' class='ranking'><span class='grippy'></span> [PO.optiontext]</li>\n"
			output += {"
				</ol>
					<b><center>Least Preferred</center></b><br>
				</div>
					<p><input type='submit' value='[( votedfor.len ? "Re" : "")]Vote'></form>
			"}
			src << browse(null ,"window=playerpolllist")
			src << browse(output,"window=playerpoll;size=500x500")
	return

/mob/new_player/proc/poll_check_voted(pollid, text = FALSE)
	var/table = "poll_vote"
	if (text)
		table = "poll_textreply"
	if (!dbcon.Connect())
		usr << "<span class='danger'>Failed to establish database connection.</span>"
		return
	var/DBQuery/query_hasvoted = dbcon.NewQuery("SELECT id FROM `[format_table_name(table)]` WHERE pollid = [pollid] AND ckey = '[ckey]'")
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


/mob/new_player/proc/vote_rig_check()
	if (usr != src)
		if (!usr || !src)
			return 0
		//we gots ourselfs a dirty cheater on our hands!
		log_game("[key_name(usr)] attempted to rig the vote by voting as [ckey]")
		message_admins("[key_name_admin(usr)] attempted to rig the vote by voting as [ckey]")
		usr << "<span class='danger'>You don't seem to be [ckey].</span>"
		src << "<span class='danger'>Something went horribly wrong processing your vote. Please contact an administrator, they should have gotten a message about this</span>"
		return 0
	return 1

/mob/new_player/proc/vote_valid_check(pollid, holder, type)
	if (!dbcon.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return 0
	pollid = text2num(pollid)
	if (!pollid || pollid < 0)
		return 0
	//validate the poll is actually the right type of poll and its still active
	var/DBQuery/select_query = dbcon.NewQuery({"
		SELECT id
		FROM [format_table_name("poll_question")]
		WHERE
			[(holder ? "" : "adminonly = false AND")]
			id = [pollid]
			AND
			Now() BETWEEN starttime AND endtime
			AND
			polltype = '[type]'
	"})
	if (!select_query.Execute())
		var/err = select_query.ErrorMsg()
		log_game("SQL ERROR validating poll via poll_question table. Error : \[[err]\]\n")
		return 0
	if (!select_query.NextRow())
		return 0
	return 1

/mob/new_player/proc/vote_on_irv_poll(pollid, list/votelist)
	if (!dbcon.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return 0
	if (!vote_rig_check())
		return 0
	pollid = text2num(pollid)
	if (!pollid || pollid < 0)
		return 0
	if (!votelist || !istype(votelist) || !votelist.len)
		return 0
	if (!client)
		return 0
	//save these now so we can still process the vote if the client goes away while we process.
	var/datum/admins/holder = client.holder
	var/rank = "Player"
	if (holder)
		rank = holder.rank
	var/ckey = client.ckey
	var/address = client.address

	//validate the poll
	if (!vote_valid_check(pollid, holder, POLLTYPE_IRV))
		return 0

	//lets collect the options
	var/DBQuery/options_query = dbcon.NewQuery("SELECT id FROM [format_table_name("poll_option")] WHERE pollid = [pollid]")
	if (!options_query.Execute())
		var/err = options_query.ErrorMsg()
		log_game("SQL ERROR obtaining id from poll_option table. Error : \[[err]\]\n")
		return 0
	var/list/optionlist = list()
	while (options_query.NextRow())
		optionlist += text2num(options_query.item[1])

	//validate their votes are actually in the list of options and actually numbers
	var/list/numberedvotelist = list()
	for (var/vote in votelist)
		vote = text2num(vote)
		numberedvotelist += vote
		if (!vote) //this is fine because voteid starts at 1, so it will never be 0
			src << "<span class='danger'>Error: Invalid (non-numeric) votes in the vote data.</span>"
			return 0
		if (!(vote in optionlist))
			src << "<span class='danger'>Votes for choices that do not appear to be in the poll detected<span>"
			return 0
	if (!numberedvotelist.len)
		src << "<span class='danger'>Invalid vote data</span>"
		return 0

	//lets add the vote, first we generate a insert statement.

	var/sqlrowlist = ""
	for (var/vote in numberedvotelist)
		if (sqlrowlist != "")
			sqlrowlist += ", " //a comma (,) at the start of the first row to insert will trigger a SQL error
		sqlrowlist += "(Now(), [pollid], [vote], '[sanitizeSQL(ckey)]', '[sanitizeSQL(address)]', '[sanitizeSQL(rank)]')"

	//now lets delete their old votes (if any)
	var/DBQuery/voted_query = dbcon.NewQuery("DELETE FROM [format_table_name("poll_vote")] WHERE pollid = [pollid] AND ckey = '[ckey]'")
	if (!voted_query.Execute())
		var/err = voted_query.ErrorMsg()
		log_game("SQL ERROR clearing out old votes. Error : \[[err]\]\n")
		return 0

	//now to add the new ones.
	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO [format_table_name("poll_vote")] (datetime, pollid, optionid, ckey, ip, adminrank) VALUES [sqlrowlist]")
	if(!query_insert.Execute())
		var/err = query_insert.ErrorMsg()
		log_game("SQL ERROR adding vote to table. Error : \[[err]\]\n")
		src << "<span class='danger'>Error adding vote.</span>"
		return 0
	src << browse(null,"window=playerpoll")
	return 1


/mob/new_player/proc/vote_on_poll(pollid, optionid)
	if (!dbcon.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid || !optionid)
		return
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_OPTION))
		return 0
	var/adminrank = poll_check_voted(pollid)
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
	if (!dbcon.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid)
		return
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_TEXT))
		return 0
	if(!replytext)
		usr << "The text you entered was blank. Please correct the text and submit again."
		return
	var/adminrank = poll_check_voted(pollid, TRUE)
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
	if (!dbcon.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid || !optionid || !rating)
		return
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_RATING))
		return 0
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
	if (!dbcon.Connect())
		src << "<span class='danger'>Failed to establish database connection.</span>"
		return 0
	if (!vote_rig_check())
		return 0
	if(!pollid || !optionid)
		return 1
	//validate the poll
	if (!vote_valid_check(pollid, client.holder, POLLTYPE_MULTI))
		return 0
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