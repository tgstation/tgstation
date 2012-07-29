
/mob/new_player/proc/handle_privacy_poll()
	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
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

	dbcon.Disconnect()

/mob/new_player/proc/privacy_poll()
	var/output = "<div align='center'><B>Player poll</B>"
	output +="<hr>"
	output += "<b>We would like to expand our stats gathering.</b>"
	output += "<br>This however involves gathering data about player behavior, play styles, unique player numbers, play times, etc. Data like that cannot be gathered fully anonymously, which is why we're asking you how you'd feel if player-specific data was gathered. Prior to any of this actually happening, a privacy policy will be discussed, but before that can begin, we'd preliminarily like to know how you feel about the concept."
	output +="<hr>"
	output += "How do you feel about the game gathering player-specific statistics? This includes statistics about individual players as well as in-game polling/opinion requests."

	output += "<p><a href='byond://?src=\ref[src];privacy_poll=signed'>Signed stats gathering</A>"
	output += "<br>Pick this option if you think usernames should be logged with stats. This allows us to have personalized stats as well as polls."

	output += "<p><a href='byond://?src=\ref[src];privacy_poll=anonymous'>Anonymous stats gathering</A>"
	output += "<br>Pick this option if you think only hashed (indecipherable) usernames should be logged with stats. This doesn't allow us to have personalized stats, as we can't tell who is who (hashed values aren't readable), we can however have ingame polls."

	output += "<p><a href='byond://?src=\ref[src];privacy_poll=nostats'>No stats gathering</A>"
	output += "<br>Pick this option if you don't want player-specific stats gathered. This does not allow us to have player-specific stats or polls."

	output += "<p><a href='byond://?src=\ref[src];privacy_poll=later'>Ask again later</A>"
	output += "<br>This poll will be brought up again next round."

	output += "<p><a href='byond://?src=\ref[src];privacy_poll=abstain'>Don't ask again</A>"
	output += "<br>Only pick this if you are fine with whatever option wins."

	output += "</div>"

	src << browse(output,"window=privacypoll;size=600x500")
	return

/datum/polloption
	var/optionid
	var/optiontext

/mob/new_player/proc/handle_player_polling()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(dbcon.IsConnected())
		var/isadmin = 0
		if(src.client && src.client.holder)
			isadmin = 1

		var/DBQuery/select_query = dbcon.NewQuery("SELECT id, question FROM erro_poll_question WHERE [(isadmin ? "" : "adminonly = false AND")] Now() BETWEEN starttime AND endtime")
		select_query.Execute()

		var/output = "<div align='center'><B>Player polls</B>"
		output +="<hr>"

		var/pollid
		var/pollquestion

		output += "<table>"
		var/color1 = "#ececec"
		var/color2 = "#e2e2e2"
		var/i = 0

		while(select_query.NextRow())
			pollid = select_query.item[1]
			pollquestion = select_query.item[2]
			output += "<tr bgcolor='[ (i % 2 == 1) ? color1 : color2 ]'><td><a href=\"byond://?src=\ref[src];pollid=[pollid]\"><b>[pollquestion]</b></a></td></tr>"
			i++

		output += "</table>"

		src << browse(output,"window=playerpolllist;size=500x300")

	dbcon.Disconnect()


/mob/new_player/proc/poll_player(var/pollid = -1)
	if(pollid == -1) return

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question FROM erro_poll_question WHERE id = [pollid]")
		select_query.Execute()

		var/pollstarttime = ""
		var/pollendtime = ""
		var/pollquestion = ""
		var/found = 0

		while(select_query.NextRow())
			pollstarttime = select_query.item[1]
			pollendtime = select_query.item[2]
			pollquestion = select_query.item[3]
			found = 1
			break

		if(!found)
			usr << "\red Poll question details not found."
			return

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

		dbcon.Disconnect()

		var/output = "<div align='center'><B>Player poll</B>"
		output +="<hr>"
		output += "<b>Question: [pollquestion]</b><br>"
		output += "<font size='2'>Poll runs from <b>[pollstarttime]</b> until <b>[pollendtime]</b></font><p>"

		if(!voted)	//Only make this a form if we have not voted yet
			output += "<form name='cardcomp' action='?src=\ref[src]' method='get'>"
			output += "<input type='hidden' name='src' value='\ref[src]'>"
			output += "<input type='hidden' name='votepollid' value='[pollid]'>"

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
			output += "<p><input type='submit' value='Vote'>"
			output += "</form>"

		output += "</div>"

		src << browse(output,"window=playerpoll;size=500x250")
		return

/mob/new_player/proc/vote_on_poll(var/pollid = -1, var/optionid = -1)
	if(pollid == -1 || optionid == -1)
		return

	if(!isnum(pollid) || !isnum(optionid))
		return

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	var/DBConnection/dbcon = new()
	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	if(dbcon.IsConnected())

		var/DBQuery/select_query = dbcon.NewQuery("SELECT starttime, endtime, question FROM erro_poll_question WHERE id = [pollid] AND Now() BETWEEN starttime AND endtime")
		select_query.Execute()

		var/validpoll = 0

		while(select_query.NextRow())
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

		var/DBQuery/voted_query = dbcon.NewQuery("SELECT id FROM erro_poll_vote WHERE pollid = [pollid] AND ckey = '[usr.ckey]'")
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


		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO erro_poll_vote (id ,datetime ,pollid ,optionid ,ckey ,ip ,adminrank) VALUES (null, Now(), [pollid], [optionid], '[usr.ckey]', '[usr.client.address]', '[adminrank]')")
		insert_query.Execute()

		usr << "\blue Vote successful."
		usr << browse(null,"window=playerpoll")