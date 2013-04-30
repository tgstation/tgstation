/*Poll panel*/

/datum/admins/proc/poll_panel()
	if(!check_rights(R_SERVER,1))	return
	
	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/dat = "<html><head><title>Poll Panel</title></head>"
	dat += "<body>"
	dat += "<center><b>Poll Panel</b></center>"
	dat += "<br><a href='?_src_=holder;create_poll_panel=1'>Create Poll</A>"
	dat += "<br><a href='?_src_=holder;manage_poll_panel=1'>Manage Polls</A>"
	dat += "</body></html>"
	usr << browse(dat, "window=adminpollpanel;size=200x150")
	return

/datum/admins/proc/view_poll_panel(var/pollid)
	if(!check_rights(R_SERVER,1))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/DBQuery/poll_query = dbcon.NewQuery("SELECT polltype,question FROM erro_poll_question WHERE id=[pollid];")
	if(!poll_query.Execute())
		usr << "Getting poll failed: [poll_query.ErrorMsg()]"
		return
	//usr << "SELECT polltype,question FROM erro_poll_question WHERE id=[pollid];"

	var/polltype
	var/pollquestion
	while(poll_query.NextRow())
		polltype = poll_query.item[1];
		pollquestion = poll_query.item[2];

	if(polltype == "OPTION" || polltype == "MULTICHOICE")
		var/polloptions[0]

		var/dat = "<html><head><title>View Poll</title></head>"
		dat += "<body><center><b>Poll question: [pollquestion]</b></center>"
		dat += "<table style='font-size:small' border='1' align='center' cellpadding='3'>"
		dat += "<tr><td>Poll option:</td><td>Total:</td><td>ckeys:</td></tr>"

		var/DBQuery/option_query = dbcon.NewQuery("SELECT id,text FROM erro_poll_option WHERE pollid=[pollid];")
		//usr << "SELECT id,text FROM erro_poll_option WHERE pollid=[pollid];"
		if(!option_query.Execute())
			usr << "Getting options failed: [option_query.ErrorMsg()]"
			return	

		while(option_query.NextRow())	
			polloptions += option_query.item[2]
			var/pollvotes[0]
			var/DBQuery/vote_query = dbcon.NewQuery("SELECT ckey FROM erro_poll_vote WHERE optionid=[option_query.item[1]];")
			//usr << "SELECT ckey FROM erro_poll_vote WHERE optionid=[option_query.item[1]];"
			if(!vote_query.Execute())
				usr << "Getting votes failed: [vote_query.ErrorMsg()]"
				return	
			while(vote_query.NextRow())
				pollvotes += vote_query.item[1]
			dat += "<tr><td>[option_query.item[2]]</td><td>[pollvotes.len]</td><td>"
			var/i
			for(i=1;i<=pollvotes.len,i++)
				dat += "<br>[pollvotes[i]]"
			dat += "</td></tr>"
	
		dat += "</table></body></html>"
		usr << browse(dat, "window=viewpollpanel;size=500x500")
	else if(polltype == "TEXT")
		

		var/dat = "<html><head><title>View Poll</title></head>"
		dat += "<body><center><b>Poll question: [pollquestion]</b></center>"
		dat += "<table style='font-size:small' border='1' align='center' cellpadding='3'>"
		dat += "<tr><td>Poll response:</td><td>ckey:</td></tr>"

		var/DBQuery/text_query = dbcon.NewQuery("SELECT ckey,replytext FROM erro_poll_textreply WHERE pollid=[pollid];")
		//usr << "SELECT ckey,replytext FROM erro_poll_textreply WHERE pollid=[pollid];"
		if(!text_query.Execute())
			usr << "Getting text replies failed: [text_query.ErrorMsg()]"
			return	

		while(text_query.NextRow())	
			dat += "<tr><td>[text_query.item[2]]</td><td>[text_query.item[1]]</td>"
	
		dat += "</table></body></html>"
		usr << browse(dat, "window=viewpollpanel;size=400x600")

	else if(polltype == "NUMVAL")
		var/polloptions[0]
		var/minval = 1
		var/maxval = 5

		var/dat = "<html><head><title>View Poll</title></head>"
		dat += "<body><center><b>Poll question: [pollquestion]</b></center>"
		dat += "<table style='font-size:small' border='1' align='center' cellpadding='3'>"
		dat += "<tr><td>Poll option:</td><td>Average rating:</td><td>Total votes:</td><td>ckeys:</td></tr>"

		var/DBQuery/option_query = dbcon.NewQuery("SELECT id,text,minval,maxval FROM erro_poll_option WHERE pollid=[pollid];")
		//usr << "SELECT id,text,minval,maxval FROM erro_poll_option WHERE pollid=[pollid];"
		if(!option_query.Execute())
			usr << "Getting options failed: [option_query.ErrorMsg()]"
			return	

		while(option_query.NextRow())	
			var/average = 0;
			polloptions += option_query.item[2]
			minval = option_query.item[3]
			maxval = option_query.item[4]
			var/pollrating[0]
			var/pollckey[0]
			var/DBQuery/vote_query = dbcon.NewQuery("SELECT ckey,rating FROM erro_poll_vote WHERE optionid=[option_query.item[1]];")
			//usr << "SELECT ckey FROM erro_poll_vote WHERE optionid=[option_query.item[1]];"
			if(!vote_query.Execute())
				usr << "Getting votes failed: [vote_query.ErrorMsg()]"
				return	
			while(vote_query.NextRow())
				pollckey += vote_query.item[1]
				pollrating += text2num(vote_query.item[2])
			if(pollrating.len != 0) // calculate the average
				var/i
				for(i=1;i<=pollrating.len,i++)
					average = average + pollrating[i]
				average = average / pollrating.len

			dat += "<tr><td>[option_query.item[2]] ([minval],[maxval])</td><td>[average]</td><td>[pollrating.len]</td><td>"
			var/i
			for(i=1;i<=pollckey.len,i++)
				dat += "<br>[pollckey[i]] ([pollrating[i]])"
			dat += "</td></tr>"
	
		dat += "</table></body></html>"
		usr << browse(dat, "window=viewpollpanel;size=400x600")

/datum/admins/proc/manage_poll_panel()
	if(!check_rights(R_SERVER,1))	return
	
	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return
	
	var/DBQuery/poll_query = dbcon.NewQuery("SELECT * FROM erro_poll_question;")
	if(!poll_query.Execute())
		usr << "Getting polls failed: [poll_query.ErrorMsg()]"
		return
	var/pollid[0];
	var/polltype[0];
	var/pollstart[0];
	var/pollend[0];
	var/pollquestion[0];
	var/polladmin[0];
	var/polllimit[0];

	while(poll_query.NextRow())
		pollid += poll_query.item[1];
		polltype += poll_query.item[2];
		pollstart += poll_query.item[3];
		pollend += poll_query.item[4];
		pollquestion += poll_query.item[5];
		polladmin += poll_query.item[6];
		polllimit += poll_query.item[7];

	var/i = 0
	var/dat = "<html><head><title>Manage Polls</title></head>"
	dat += "<body><center><b>Manage Polls</b></center>"
	dat += "<table style='font-size:small' border='1' align='center' cellpadding='3'>"
	dat += "<tr><td>Poll question (click for results):</td><td>Poll Type:</td><td>Start time:</td><td>End Time:</td>"
	dat += "<td>Admin-only?</td><td>Choice Limit</td><td>Options</td><td>Remove</td></tr>"

	for(i=1;i<=pollid.len,i++)
		dat += "<tr><td><a href='?_src_=holder;view_poll=[pollid[i]]'>[pollquestion[i]]</a></td>"
		dat += "<td>[polltype[i]]</td><td>[pollstart[i]]</td><td>[pollend[i]]</td>"
		if(polladmin[i] == "1")
			dat += "<td>Yes</td>"
		else
			dat += "<td>No</td>"
		dat += "<td>[polllimit[i]]</td><td>";
		if(polltype[i] != "TEXT")		
			dat += "<ul>"
			var/DBQuery/option_query = dbcon.NewQuery("SELECT text FROM erro_poll_option WHERE pollid=[pollid[i]];")
			//usr << "SELECT text FROM erro_poll_option WHERE pollid=[pollid[i]];"
			if(!option_query.Execute())
				usr << "Getting options failed: [poll_query.ErrorMsg()]"
				return	
			while(option_query.NextRow())
				dat += "<li>[option_query.item[1]]</li>"
			dat += "</ul>"

		dat += "</td><td><a href='?_src_=holder;remove_poll=[pollid[i]]'>X</a></td></tr>"

	dat += "</table></body></html>"	
	usr << browse(dat, "window=managepollpanel;size=750x600")
	return

/datum/admins/proc/create_poll_panel()
	if(!check_rights(R_SERVER,1))	return
	
	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	//<input type='hidden' name='src' value='\ref[src]'>

	var/dat = "<html><head>"
	dat += "<script>"
	dat += "var counter = 1;"
	dat += "var limit = 8;"
	dat += "function addInput(divName){"
	dat += "     if (counter == limit)  {"
	dat += "	  ;"
	dat += "     }"
	dat += "     else {"
	dat += "	  var newdiv = document.createElement('div');"
	dat += "	  document.getElementById(divName).innerHTML=document.getElementById(divName).innerHTML+\"<br>Poll option \" + (counter + 1) + \":<td align='right'><input type='text' name='polloptions[]'>\";"
	dat += "	  counter++;"
	dat += "     }"
	dat += "}"
	dat += "</script>"
	dat += ""
	dat += "<script>"
	dat += "function writeForm(pollType, divName)"
	dat += "{"
	dat += "	if(pollType == 1) {"
	dat += "	document.getElementById(divName).innerHTML=\"<form method='GET' action='?src=\\ref[src]'> \"+"
	dat += "			\"<input type='hidden' name='polltype' value='1'>\" +"
	dat += "			\"<input type='hidden' name='src' value='\ref[src]'>\" +"
	dat += "			\"<input type='hidden' name='create_new_poll' value='1'>\" + "
	dat += "			\"<br>Length (hours):<input type='text' name='timelength'>\" + "
	dat += "			\"<br>Question:<input type='text' name='question' size='80'>\" + "
	dat += "			\"<br>Admin only?:<input type='checkbox' name='adminonly' value='1'>\" + "
	dat += "			\"<div id='dynamicOptions'>\" + "
	dat += "			\"<br>Poll option 1:<input type='text' name='polloptions[]'>\" + "
	dat += "			\"</div>\" + "
	dat += "			\"<input type='button' value='Add another poll option' onClick=\\\"addInput('dynamicOptions');\\\">\" + "
	dat += "			\"<br>\" + "
	dat += "			\"<input type='submit' value='Create Poll'>\" + "
	dat += "			\"</form>\";"
	dat += "	}"
	dat += "	else if(pollType == 2) {"
	dat += "	document.getElementById(divName).innerHTML=\"<form method='GET' action='?src=\\ref[src]'> \"+"
	dat += "			\"<input type='hidden' name='polltype' value='2'>\" +"
	dat += "			\"<input type='hidden' name='src' value='\ref[src]'>\" +"
	dat += "			\"<input type='hidden' name='create_new_poll' value='1'>\" + "
	dat += "			\"<br>Length (hours):<input type='text' name='timelength'>\" + "
	dat += "			\"<br>Question:<input type='text' name='question' size='80'>\" + "
	dat += "			\"<br>Admin only?:<input type='checkbox' name='adminonly' value='1'>\" + "
	dat += "			\"<br>Max number of selections:<input type='text' name='multilimit'>\" +"
	dat += "			\"<div id='dynamicOptions'>\" + "
	dat += "			\"<br>Poll option 1:<input type='text' name='polloptions[]'>\" + "
	dat += "			\"</div>\" + "
	dat += "			\"<input type='button' value='Add another poll option' onClick=\\\"addInput('dynamicOptions');\\\">\" + "
	dat += "			\"<br>\" + "
	dat += "			\"<input type='submit' value='Create Poll'>\" + "
	dat += "			\"</form>\";"
	dat += "	}"
	dat += "	else if(pollType == 3) {"
	dat += "	document.getElementById(divName).innerHTML=\"<form method='GET' action='?src=\\ref[src]'> \"+"
	dat += "			\"<input type='hidden' name='polltype' value='3'>\" +"
	dat += "			\"<input type='hidden' name='src' value='\ref[src]'>\" +"
	dat += "			\"<input type='hidden' name='create_new_poll' value='1'>\" + "
	dat += "			\"<br>Length (hours):<input type='text' name='timelength'>\" + "
	dat += "			\"<br>Question:<input type='text' name='question' size='80'>\" + "
	dat += "			\"<br>Admin only?:<input type='checkbox' name='adminonly' value='1'>\" + "
	dat += "			\"<br><input type='submit' value='Create Poll'>\" + "
	dat += "			\"</form>\";"
	dat += "	}"
	dat += "	else if(pollType == 4) {"
	dat += "	document.getElementById(divName).innerHTML=\"<form method='GET' action='?src=\\ref[src]'> \"+"
	dat += "			\"<input type='hidden' name='polltype' value='4'>\" +"
	dat += "			\"<input type='hidden' name='src' value='\ref[src]'>\" +"
	dat += "			\"<input type='hidden' name='create_new_poll' value='1'>\" + "
	dat += "			\"<br>Length (hours):<input type='text' name='timelength'>\" + "
	dat += "			\"<br>Question:<input type='text' name='question' size='80'>\" + "
	dat += "			\"<br>Admin only?:<input type='checkbox' name='adminonly' value='1'>\" + "
	dat += "			\"<br>Max value:<input type='text' name='maxval'>\" + "
	dat += "			\"<br>Min value:<input type='text' name='minval'>\" + "
	dat += "			\"<br>Max label:<input type='text' name='descmax'>\" + "
	dat += "			\"<br>Min label:<input type='text' name='descmin'>\" + "
	dat += "			\"<br>Mid label:<input type='text' name='descmed'>\" + "
	dat += "			\"<div id='dynamicOptions'>\" + "
	dat += "			\"<br>Poll option 1:<input type='text' name='polloptions[]'>\" + "
	dat += "			\"</div>\" + "
	dat += "			\"<input type='button' value='Add another poll option' onClick=\\\"addInput('dynamicOptions');\\\">\" + "
	dat += "			\"<br>\" + "
	dat += "			\"<br><input type='submit' value='Create Poll'>\" + "
	dat += "			\"</form>\";"
	dat += "	}"
	dat += "	else"
	dat += "	{"
	dat += "	document.getElementById(divName).innerHTML=\"Select a poll type above.\";"
	dat += "	}"
	dat += "}"
	dat += "</script>"
	dat += "<title>Create Poll</title></head>"
	dat += "<body>"
	dat += "<center><b>Create Poll</b></center>"
	dat += ""
	dat += "<br>Poll type: <select name='pollselect' onChange=\"writeForm(this.value,'formArea')\">"
	dat += "	<option value='0'>---</option>"
	dat += "	<option value='1'>Option</option>"
	dat += "	<option value='2'>Multi-choice</option>"
	dat += "	<option value='3'>Text</option>"
	dat += "	<option value='4'>Numerical</option>"
	dat += "	</select>"
	dat += ""
	dat += "<div id='formArea'>"
	dat += "Select a poll type above."
	dat += "</div>"
	dat += ""
	dat += "</body>"
	dat += "</html>"

	usr << browse(dat, "window=admincreatepolls;size=600x650")
	return

/datum/admins/proc/remove_poll(var/pollid)
	if(!check_rights(R_SERVER,1))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/DBQuery/poll_query = dbcon.NewQuery("DELETE FROM erro_poll_question WHERE id=[pollid]")
	if(!poll_query.Execute())
		usr << "Removing poll failed: [poll_query.ErrorMsg()]"
		return
	//usr << "DELETE FROM erro_poll_question WHERE id=[pollid]"
	var/DBQuery/option_query = dbcon.NewQuery("DELETE FROM erro_poll_option WHERE pollid=[pollid]")
	if(!option_query.Execute())
		usr << "Removing options failed: [option_query.ErrorMsg()]"
		return
	//usr << "DELETE FROM erro_poll_option WHERE pollid=[pollid]"
	var/DBQuery/vote_query = dbcon.NewQuery("DELETE FROM erro_poll_vote WHERE pollid=[pollid]")
	if(!vote_query.Execute())
		usr << "Removing votes failed: [vote_query.ErrorMsg()]"
		return
	//usr << "DELETE FROM erro_poll_vote WHERE pollid=[pollid]"
	var/DBQuery/text_query = dbcon.NewQuery("DELETE FROM erro_poll_textreply WHERE pollid=[pollid]")
	if(!text_query.Execute())
		usr << "Removing text replies failed: [text_query.ErrorMsg()]"
		return
	//usr << "DELETE FROM erro_poll_textreply WHERE pollid=[pollid]"

	message_admins("\blue [key_name(usr)] erased poll with id=[pollid].", 1)
	log_admin("[key_name(usr)] erased poll with id=[pollid].")

	return


/datum/admins/proc/create_new_poll(var/polltype,var/timelength,var/question,list/polloptions,var/adminonly,var/multilimit,var/maxval,var/minval,var/descmax,var/descmin,var/descmed)

	if(!check_rights(R_SERVER,1))	return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return
	
	var/i
	var/timestart = time2text(world.realtime,"YYYY-MM-DD hh:mm:ss")
	var/timeend = time2text(world.realtime+timelength*36000,"YYYY-MM-DD hh:mm:ss")

	usr << "Creating poll..."
	usr << "Poll type: [polltype]"
	usr << "Poll length: [timelength]"
	usr << "Poll start: [timestart]"
	usr << "Poll end: [timeend]"
	usr << "Poll question: [question]"
	if(polltype != "TEXT")
		usr << "# of poll options: [polloptions.len]"	
		for(i=1;i<=polloptions.len,i++)
			usr << "Poll option [i]: [polloptions[i]]"

	//usr << "INSERT INTO erro_poll_question VALUES (NULL,'[polltype]','[timestart]','[timeend]','[question]',[adminonly],[multilimit])"
		
	var/DBQuery/poll_query = dbcon.NewQuery("INSERT INTO erro_poll_question VALUES (NULL,'[polltype]','[timestart]','[timeend]','[question]',[adminonly],[multilimit])")
	if(!poll_query.Execute())
		usr << "Adding poll failed: [poll_query.ErrorMsg()]"
		return
	//usr << "SELECT id FROM erro_poll_question WHERE starttime='[timestart]'"
	var/DBQuery/id_query = dbcon.NewQuery("SELECT id FROM erro_poll_question WHERE starttime='[timestart]'")
	if(!id_query.Execute())
		usr << "Finding poll id failed: [id_query.ErrorMsg()]"
		return

	var/id = 0
	var/idfound = 0
	while(id_query.NextRow())
		id = id_query.item[1]
		idfound++;

	if(idfound == 0)
		usr << "ID not found, failed to finish inserting poll into database!"
		return

	if(polltype != "TEXT")
		var/DBQuery/option_query
		for(i=1;i<=polloptions.len,i++)
			//usr << "INSERT INTO erro_poll_option VALUES (NULL,[id],'[polloptions[i]]',1,[minval],[maxval],'[descmin]','[descmed]','[descmax]')"
			option_query = dbcon.NewQuery("INSERT INTO erro_poll_option VALUES (NULL,[id],'[polloptions[i]]',1,[minval],[maxval],'[descmin]','[descmed]','[descmax]')")
			if(!option_query.Execute())
				usr << "Adding option failed: [option_query.ErrorMsg()]"
				return
	message_admins("\blue [key_name(usr)] created poll with id=[id].", 1)
	log_admin("[key_name(usr)] created poll with id=[id].")

	return
