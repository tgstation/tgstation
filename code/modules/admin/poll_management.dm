/**
  * Datum which holds details of a running poll loaded from the database and supplementary info.
  * 
  * Used to minimize the need for querying this data every time it's needed.
  * 
  */
/datum/poll_question
	///Reference list of the options for this poll, not used by text response polls.
	var/list/options = list()
	///Table id of this poll, will be null until poll has been created.
	var/poll_id
	///The type of poll to be created, must be POLLTYPE_OPTION, POLLTYPE_TEXT, POLLTYPE_RATING, POLLTYPE_MULTI or POLLTYPE_IRV.
	var/poll_type
	///Count of how many players have voted or responded to this poll.
	var/poll_votes
	///Ckey of the poll's original author
	var/created_by
	///Date and time the poll opens, timestamp format is YYYY-MM-DD HH:MM:SS.
	var/start_datetime
	///Date and time the poll will run until, timestamp format is YYYY-MM-DD HH:MM:SS.
	var/end_datetime
	///The title text of the poll, shows up on the list of polls.
	var/question
	///Supplementary text displayed only when responding to a poll.
	var/subtitle
	///Hides the poll from any client without a holder datum.
	var/admin_only
	///The number of responses allowed in a multiple-choice poll, more can be selected but won't be recorded.
	var/options_allowed
	///Hint for statbus, not used by the game; Stops the results of a poll from being displayed until the end_datetime is reached.
	var/dont_show
	///Allows a player to change their vote to a poll they've already voted on, off by default.
	var/allow_revoting
	///Indicates if a poll has been submitted or loaded from the DB so the management panel will open with edit functions.
	var/edit_ready = FALSE

/**
  * Datum which holds details of a poll option loaded from the database.
  * 
  * Used to minimize the need for querying this data every time it's needed.
  * 
  */
/datum/poll_option
	///Reference to the poll this option belongs to
	var/datum/poll_question/parent_poll
	///Table id of this option, will be null until poll has been created.
	var/option_id
	///Description/name of this option
	var/text
	///For rating polls, the minimum selectable value allowed; Supported value range is -2147483648 to 2147483647
	var/min_val
	///For rating polls, the maximum selectable value allowed; Supported value range is -2147483648 to 2147483647
	var/max_val
	///Optional for rating polls, description shown next to the minimum value
	var/desc_min
	///Optional for rating polls, description shown next to the rounded whole middle value
	var/desc_mid
	///Optional for rating polls, description shown next to the maximum value
	var/desc_max
	///Hint for statbus, not used by the game; If this option should be included by default when calculating the resulting percentages of all options for this poll
	var/default_percentage_calc

/**
  * Shows a list of all currently running polls and buttons to edit or delete them or create a new poll.
  * 
  */
/datum/admins/proc/poll_list_panel()
	var/list/output = list("Currently running polls<br>Note when editing polls or their options changes are not saved until you press Submit Poll.<br><a href='?_src_=holder;[HrefToken()];newpoll=1'>New Poll</a><hr>")
	for(var/p in GLOB.polls)
		var/datum/poll_question/poll = p
		output += {"[poll.question]
		<a href='?_src_=holder;[HrefToken()];editpoll=[REF(poll)]'> Edit</a>
		<a href='?_src_=holder;[HrefToken()];deletepoll=[REF(poll)]'> Delete</a>
		"}
		if(poll.subtitle)
			output += "<br>[poll.subtitle]"
		output += "<br>Started at [poll.start_datetime] | Ends at [poll.end_datetime]"
		if(poll.admin_only)
			output += " | Admin only"
		if(poll.dont_show)
			output += " | Hidden from tracking until complete"
		output += " | [poll.poll_votes] players have [poll.poll_type == POLLTYPE_TEXT ? "responded" : "voted"]<hr style='background:#000000; border:0; height:3px'>"
	var/datum/browser/panel = new(usr, "plpanel", "Poll list Panel", 700, 400)
	panel.set_content(jointext(output, ""))
	panel.open()

/**
  * Show the options for creating a poll or editing its parameters along with its linked options.
  * 
  */
/datum/admins/proc/poll_management_panel(datum/poll_question/poll)
	var/list/output = list("<form method='get' action='?src=[REF(src)]'>[HrefTokenFormField()]")
	output += {"<input type='hidden' name='src' value='[REF(src)]'>Poll type
	<div class="select">
		<select name='polltype' [poll ? " disabled": ""]>
			<option value='POLLTYPE_OPTION' [poll?.poll_type == POLLTYPE_OPTION ? " selected" : ""]>Single Option</option>
			<option value='POLLTYPE_TEXT' [poll?.poll_type == POLLTYPE_TEXT ? " selected" : ""]>Text Reply</option>
			<option value='POLLTYPE_RATING' [poll?.poll_type == POLLTYPE_RATING ? " selected" : ""]>Rating</option>
			<option value='POLLTYPE_MULTI' [poll?.poll_type == POLLTYPE_MULTI ? " selected" : ""]>Multiple Choice</option>
			<option value='POLLTYPE_IRV' [poll?.poll_type == POLLTYPE_IRV ? " selected" : ""]>Instant Runoff</option>
		</select>
	</div>
	Question
	<input type='text' name='question' size='34' value='[poll?.question]'>
	Multiple-choice options allowed
	<input type='text' name='optionsallowed' size='2' value='[poll?.options_allowed]'>
	<br>
	<label class='inputlabel checkbox'>
		Admin only
		<input type='checkbox' id='adminonly' name='adminonly' value='1'[poll?.admin_only ? " checked" : ""]>
		<div class='inputbox'></div>
	</label>
	<label class='inputlabel checkbox'>
		Hide results before completion
		<input type='checkbox' id='dontshow' name='dontshow' value='1'[poll?.dont_show ? " checked" : ""]>
		<div class='inputbox'></div>
	</label>
	<label class='inputlabel checkbox'>
		Allow re-voting
		<input type='checkbox' id='allowrevoting' name='allowrevoting' value='1'[poll?.allow_revoting ? " checked" : ""]>
		<div class='inputbox'></div>
	</label>
	<br>
	<div class='row'>
		<div class='column left'>
			Duration
			<br>
			<label class='inputlabel radio'>
				Run for
				<input type='radio' id='runfor' name='radioduration' value='runfor'>
				<div class='inputbox'></div>
			</label>
			<input type='text' name='duration' size='7'>
			<div class="select">
				<select name='durationtype'>
					<option value='SECOND'>Seconds</option>
					<option value='MINUTE'>Minutes</option>
					<option value='HOUR'>Hours</option>
					<option value='DAY' selected>Days</option>
					<option value='WEEK'>Weeks</option>
					<option value='MONTH'>Months</option>
					<option value='YEAR'>Years</option>
				</select>
			</div>
			<br>
			<label class='inputlabel radio'>
				Run until
				<input type='radio' id='rununtil' name='radioduration' value='rununtil' checked>
				<div class='inputbox'></div>
			</label>
			<input type='text' name='enddatetimetext' size='24' value='[poll?.end_datetime ? "[poll.end_datetime]" : "YYYY-MM-DD HH:MM:SS"]'>
		</div>
		<div class='column'>
			Start
			<br>
			<label class='inputlabel radio'>
				Now
				<input type='radio' id='startnow' name='radiostart' value='startnow' checked>
				<div class='inputbox'></div>
			</label>
			</div>
			<br>
			<label class='inputlabel radio'>
				At datetime
				<input type='radio' id='startdatetime' name='radiostart' value='startdatetime'>
				<div class='inputbox'></div>
			</label>
			<input type='text' name='startdatetimetext' size='24' value='[poll?.start_datetime ? "[poll.start_datetime]" : "YYYY-MM-DD HH:MM:SS"]'>
		</div></div>
		<div class='row'>
		<div class='column left'>
			Subtitle (Optional)
			<br>
			<textarea class='textbox' name='subtitle'>[poll?.subtitle]</textarea>
		</div>
		<div class='column spacer'>
		"}
	var/option_count = 0
	if(!poll)
		output += {"<input type='hidden' name='initializepoll' value='1'>
		<input type='submit' value='Initialize Question'>
		</div></div>
		</form>
		<hr>
		First enter the poll question details and press Initialize Question.
		<br>
		Then add poll options and press Submit Poll to save and create the question and options. No options are required for Text Reply polls.
		<br>
		<a href='[CONFIG_GET(string/wikiurl)]/Guide_to_poll_types'>Which poll type should I use?</a>
		"}
	else
		output += "<input type='hidden' name='submitpoll' value='[REF(poll)]'><input type='submit' value='Submit poll'>"
		if(poll.edit_ready)
			output += {"<label class='inputlabel checkbox'>Clear votes on edit
			<input type='checkbox' id='clearvotesedit' name='clearvotesedit' value='1' checked>
			<div class='inputbox'></div>
			</label></form>
			<br>
			"}
			if(poll.poll_type == POLLTYPE_TEXT)
				output += "<a href='?_src_=holder;[HrefToken()];clearpollvotes=[REF(poll)]'>Clear poll responses</a> [poll.poll_votes] players have responded"
			else
				output += "<a href='?_src_=holder;[HrefToken()];clearpollvotes=[REF(poll)]'>Clear poll votes</a> [poll.poll_votes] players have voted"
		if(poll.poll_type == POLLTYPE_TEXT)
			output += "</div></div>"
		else
			output += "</div></div><hr><a href='?_src_=holder;[HrefToken()];addpolloption=[REF(poll)]'>Add Option</a><br>"
			if(length(poll.options))
				for(var/o in poll.options)
					var/datum/poll_option/option = o
					option_count++
					output += {"Option [option_count]
					<a href='?_src_=holder;[HrefToken()];editpolloption=[REF(option)];parentpoll=[REF(poll)]'> Edit</a>
					<a href='?_src_=holder;[HrefToken()];deletepolloption=[REF(option)]'> Delete</a>
					<br>[option.text]
					"}
					if(poll.poll_type == POLLTYPE_RATING)
						output += {"Minimum value: [option.min_val] | Maximum value: [option.max_val]
						<br>Minimum description: [option.desc_min]
						<br>Middle description: [option.desc_mid]
						<br>Maximum description: [option.desc_max]
						"}
					output += "<hr style='background:#000000; border:0; height:3px'>"
	var/datum/browser/panel = new(usr, "pmpanel", "Poll Management Panel", 780, 640)
	panel.add_stylesheet("admin_panelscss", 'html/admin/admin_panels.css')
	if(usr.client.prefs.tgui_fancy) //some browsers (IE8) have trouble with unsupported css3 elements that break the panel's functionality, so we won't load those if a user is in no frills tgui mode since that's for similar compatability support
		panel.add_stylesheet("admin_panelscss3", 'html/admin/admin_panels_css3.css')
	panel.set_content(jointext(output, ""))
	panel.open()

/**
  * Processes topic data from poll management panel.
  * 
  * Reads through returned form data and assigns data to the poll datum, creating a new one if required, before passing it to be saved.
  * Also does some simple error checking to ensure the poll will be valid before creation.
  * 
  */
/datum/admins/proc/poll_parse_href(list/href_list, datum/poll_question/poll)
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/list/error_state = list()
	var/duration
	var/interval
	var/new_poll = FALSE
	var/clear_votes = FALSE
	var/submit_ready = FALSE
	if(!poll)
		poll = new(creator = usr.client.ckey)
		new_poll = TRUE
	poll.poll_type = text2num(href_list["polltype"])
	switch(href_list["radioduration"])
		if("runfor")
			duration = text2num(href_list["duration"])
			interval = href_list["durationtype"]
		if("rununtil")
			duration = href_list["enddatetimetext"]
	if(!duration)
		error_state += "No duration was provided."
	switch(href_list["radiostart"])
		if("startnow")
			poll.start_datetime = null
		if("startdatetime")
			if(href_list["startdatetimetext"])
				poll.start_datetime = href_list["startdatetimetext"]
			else
				error_state += "Start datetime was selected but none was provided."
	if(href_list["question"])
		poll.question = href_list["question"]
	else
		error_state += "No question was provided."
	poll.subtitle = href_list["subtitle"]
	if(href_list["adminonly"])
		poll.admin_only = TRUE
	if(href_list["dontshow"])
		poll.dont_show = TRUE
	if(href_list["allowrevoting"])
		poll.allow_revoting = TRUE
	if(href_list["clearvotesedit"])
		clear_votes = TRUE
	if(href_list["submitpoll"])
		submit_ready = TRUE
	if(poll.poll_type == POLLTYPE_MULTI)
		if(text2num(href_list["optionsallowed"]))
			poll.options_allowed = text2num(href_list["optionsallowed"])
			if(poll.options_allowed == 1)
				error_state += "Multiple choice polls require more than one option allowed, use a standard option poll for singlular voting."
			if(poll.options_allowed < 0)
				error_state += "Multiple choice options allowed cannot be negative."
		else
			error_state += "Multiple choice poll was selected but no number of allowed options was provided."
	if(submit_ready && poll.poll_type != POLLTYPE_TEXT && !length(poll.options))
		error_state += "This poll type requires at least one option."
	if(error_state.len)
		if(poll.edit_ready)
			to_chat(usr, "<span class='danger'>Not all edits were applied because the following errors were present:\n[error_state.Join("\n")]</span>")
		else	
			to_chat(usr, "<span class='danger'>Poll not [poll ? "submitted" : "initialized"] because the following errors were present:\n[error_state.Join("\n")]</span>")
			if(new_poll)
				qdel(poll)
		return
	if(submit_ready)
		var/db = poll.edit_ready //if the poll is new it will need its options inserted for the first time
		poll.save_poll_data(clear_votes, duration, interval)
		if(!db)
			poll.save_all_options()
	poll_management_panel(poll)

/datum/poll_question/New(id, polltype, starttime, endtime, question, subtitle, adminonly, multiplechoiceoptions, dontshow, allow_revoting, vote_count, creator, dbload = FALSE)
	poll_id = text2num(id)
	poll_type = polltype
	start_datetime = starttime
	end_datetime = endtime
	src.question = question
	src.subtitle = subtitle
	admin_only = text2num(adminonly)
	options_allowed = text2num(multiplechoiceoptions)
	dont_show = text2num(dontshow)
	src.allow_revoting = text2num(allow_revoting)
	poll_votes = text2num(vote_count)
	created_by = creator
	edit_ready = dbload
	GLOB.polls += src

/**
  * Sets a poll and its associated data as deleted in the database.
  * 
  * Calls the procedure set_poll_deleted to set the deleted column to 1 for each row in the poll_ tables matching the poll id used.
  * Then deletes each option datum and finally the poll itself.
  * 
  */
/datum/poll_question/proc/delete_poll()
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_delete_poll = SSdbcore.NewQuery("CALL set_poll_deleted('[sanitizeSQL(poll_id)]')")
	if(!query_delete_poll.warn_execute())
		qdel(query_delete_poll)
		return
	qdel(query_delete_poll)
	for(var/o in options)
		var/datum/poll_option/option = o
		qdel(option)
	GLOB.polls -= src
	qdel(src)

/**
  * Inserts or updates a poll question to the database.
  * 
  * Uses INSERT ON DUPLICATE KEY UPDATE to handle both inserting and updating at once.
  * The start and end datetimes and poll id for new polls is then retrieved for the poll datum.
  * Arguments:
  * * clear_votes - When true will call clear_poll_votes() to delete all votes matching this poll id.
  * * duration - This can be either a timestamp or a number to be paired with interval.
  * * interval - A MySQL temporal interval unit from SECOND to YEAR.
  * 
  */
/datum/poll_question/proc/save_poll_data(clear_votes, duration, interval)
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/poll_id_sql = "[sanitizeSQL(poll_id)]"
	if(!poll_id_sql)
		poll_id_sql = "NULL"
	var/poll_type_sql = sanitizeSQL(poll_type)
	var/question_sql = sanitizeSQL(question)
	var/subtitle_sql = sanitizeSQL(subtitle)
	var/admin_only_sql = sanitizeSQL(admin_only)
	var/options_allowed_sql = sanitizeSQL(options_allowed)
	var/dont_show_sql = sanitizeSQL(dont_show)
	var/allow_revoting_sql = sanitizeSQL(allow_revoting)
	var/admin_ckey = sanitizeSQL(created_by)
	var/admin_ip = sanitizeSQL(usr.client.address)
	var/end_datetime_sql
	if(interval)
		end_datetime_sql = "NOW() + INTERVAL [sanitizeSQL(duration)] [sanitizeSQL(interval)]"
	else
		end_datetime_sql = "'[sanitizeSQL(duration)]'"
	var/start_datetime_sql
	if(!start_datetime)
		start_datetime_sql = "NOW()"
	else
		start_datetime_sql = "'[sanitizeSQL(start_datetime)]'"
	var/kn = key_name(usr)
	var/kna = key_name_admin(usr)
	var/datum/DBQuery/query_save_poll = SSdbcore.NewQuery("INSERT INTO [format_table_name("poll_question")] (id, polltype, created_datetime, starttime, endtime, question, subtitle, adminonly, multiplechoiceoptions, createdby_ckey, createdby_ip, dontshow, allow_revoting) VALUES ([poll_id_sql], '[poll_type_sql]', NOW(), [start_datetime_sql], [end_datetime_sql], '[question_sql]', '[subtitle_sql]', '[admin_only_sql]', '[options_allowed_sql]', '[admin_ckey]', INET_ATON('[admin_ip]'), '[dont_show_sql]', '[allow_revoting_sql]') ON DUPLICATE KEY UPDATE starttime = [start_datetime_sql], endtime = [end_datetime_sql], question = '[question_sql]', subtitle = '[subtitle_sql]', adminonly = '[subtitle_sql]', multiplechoiceoptions = '[options_allowed_sql]'', dontshow = '[dont_show_sql]', allow_revoting = '[allow_revoting_sql]'")
	if(!query_save_poll.warn_execute())
		qdel(query_save_poll)
		return
	qdel(query_save_poll)
	if(poll_id_sql == "NULL")
		poll_id_sql = "LAST_INSERT_ID()"
	var/datum/DBQuery/query_get_poll_id_start_endtime = SSdbcore.NewQuery("SELECT LAST_INSERT_ID(), startime, endtime FROM [format_table_name("poll_question")] WHERE id = [poll_id_sql]")
	if(!query_get_poll_id_start_endtime.warn_execute())
		qdel(query_get_poll_id_start_endtime)
		return
	if(query_get_poll_id_start_endtime.NextRow())
		if(!poll_id)
			poll_id = text2num(query_get_poll_id_start_endtime.item[1])
		start_datetime = query_get_poll_id_start_endtime.item[2]
		end_datetime = query_get_poll_id_start_endtime.item[3]
	qdel(query_get_poll_id_start_endtime)
	if(clear_votes)
		clear_poll_votes()
	edit_ready = TRUE
	var/msg = "has created a new[admin_only ? " admin only" : ""] server poll. Question: [question]"
	if(admin_only)
		log_admin_private("[kn] [msg]")
	else
		log_admin("[kn] [msg]")
	message_admins("[kna] [msg]")

/**
  * Saves all options of a poll to the database.
  * 
  * Saves all the created options for a poll when it's submitted to the DB for the first time and associated an id with the options.
  * Insertion and id querying for each option is done separately to ensure data integrity; this is less performant, but not significantly.
  * Using MassInsert() would mean having to query a list of rows by poll_id or matching by fields afterwards, which doesn't guarantee accuracy.
  * 
  */
/datum/poll_question/proc/save_all_options()
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	for(var/o in options)
		var/datum/poll_option/option = o
		option.save_option()
		var/datum/DBQuery/query_get_option_id = SSdbcore.NewQuery("SELECT LAST_INSERT_ID()")
		if(!query_get_option_id.warn_execute())
			qdel(query_get_option_id)
			return
		if(query_get_option_id.NextRow())
			option.option_id = text2num(query_get_option_id.item[1])
		qdel(query_get_option_id)

/**
  * Deletes all votes or text replies for this poll, depending on its type.
  * 
  */
/datum/poll_question/proc/clear_poll_votes()
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/table = "poll_vote"
	if(poll_type == POLLTYPE_TEXT)
		table = "poll_textreply"
	var/datum/DBQuery/query_clear_poll_votes = SSdbcore.NewQuery("UPDATE [format_table_name("[table]")] SET deleted = 1 WHERE pollid = [sanitizeSQL(poll_id)]")
	if(!query_clear_poll_votes.warn_execute())
		qdel(query_clear_poll_votes)
		return
	qdel(query_clear_poll_votes)
	to_chat(usr, "<span class='danger'>Poll [poll_type == POLLTYPE_TEXT ? "responses" : "votes"] cleared.</span>")

/**
  * Show the options for creating a poll option or editing its parameters.
  * 
  */
/datum/admins/proc/poll_option_panel(datum/poll_question/poll, datum/poll_option/option)
	var/list/output = list("<form method='get' action='?src=[REF(src)]'>[HrefTokenFormField()]")
	output += {"<input type='hidden' name='src' value='[REF(src)]'>	Option for poll [poll.question]
	<br>
	<textarea class='reason' name='optiontext'>[option?.text]</textarea>
	<br>
	"}
	if(poll.poll_type == POLLTYPE_RATING)
		output += {"Minimum value
		<input type='text' name='minval' size='3' value='[option?.min_val]'>
		Maximum Value
		<input type='text' name='maxval' size='3' value='[option?.max_val]'>
		<div class='row'>
  			<div class='column left'>
				<label class='inputlabel checkbox'>Minimum description
				<input type='checkbox' id='descmincheck' name='descmincheck' value='1'[option?.desc_min ? " checked": ""]>
				<div class='inputbox'></div></label>
				<br>
				<label class='inputlabel checkbox'>Middle description
				<input type='checkbox' id='descmidcheck' name='descmidcheck' value='1'[option?.desc_mid ? " checked": ""]>
				<div class='inputbox'></div></label>
				<br>
				<label class='inputlabel checkbox'>Maximum description
				<input type='checkbox' id='descmaxcheck' name='descmaxcheck' value='1'[option?.desc_max ? " checked": ""]>
				<div class='inputbox'></div></label>
			</div>
			<div class='column'>
				<input type='text' name='descmintext' size='26' value='[option?.desc_min]'>
				<br>
				<input type='text' name='descmidtext' size='26' value='[option?.desc_mid]'>
				<br>
				<input type='text' name='descmaxtext' size='26' value='[option?.desc_max]'>
			</div>
		</div>
		<label class='inputlabel checkbox'>Include option in poll's results percentage calculation
		<input type='checkbox' id='defpercalc' name='defpercalc' value='1'[option?.default_percentage_calc ? " checked": ""]>
		<div class='inputbox'></div></label><br>
		"}
	output += "<input type='hidden' name='submitoption' value='[REF(option)]'><input type='hidden' name='submitoptionpoll' value='[REF(poll)]'><input type='submit' value='Add option'>"
	var/panel_height = 120
	if(poll.poll_type == POLLTYPE_RATING)
		panel_height = 190
	var/datum/browser/panel = new(usr, "popanel", "Poll Option Panel", 370, panel_height)
	panel.add_stylesheet("admin_panelscss", 'html/admin/admin_panels.css')
	panel.set_content(jointext(output, ""))
	panel.open()

/**
  * Processes topic data from poll option panel.
  * 
  * Reads through returned form data and assigns data to the option datum, creating a new one if required, before passing it to be saved.
  * Also does some simple error checking to ensure the option will be valid before creation.
  * 
  */
/datum/admins/proc/poll_option_parse_href(list/href_list, datum/poll_question/poll, datum/poll_option/option)
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/list/error_state = list()
	var/new_option = FALSE
	if(!option)
		option = new()
		new_option = TRUE
	if(href_list["optiontext"])
		option.text = href_list["optiontext"]
	else
		error_state += "No option text was provided."
	if(href_list["defpercalc"])
		option.default_percentage_calc = TRUE
	if(poll.poll_type == POLLTYPE_RATING)
		if(href_list["minval"])
			if(-2147483647 < text2num(href_list["minval"] > 2147483647))
				error_state += "Minimum value out of range."
			else
				option.min_val = text2num(href_list["minval"])
		else
			error_state += "No minimum value was provided."
		if(href_list["maxval"])
			if(-2147483647 < text2num(href_list["maxval"] > 2147483647))
				error_state += "Maximum value out of range."
			else
				option.max_val = text2num(href_list["maxval"])
		else
			error_state += "No maximum value was provided."
		if(href_list["descmincheck"])
			if(href_list["descmintext"])
				option.desc_min = href_list["descmintext"]
			else
				error_state += "Minimum value description was selected but not provided."
		else
			option.desc_min = null
		if(href_list["descmidcheck"])
			if(href_list["descmidtext"])
				option.desc_mid = href_list["descmidtext"]
			else
				error_state += "Middle value description was selected but not provided."
		else
			option.desc_mid = null
		if(href_list["descmaxcheck"])
			if(href_list["descmaxtext"])
				option.desc_max = href_list["descmaxtext"]
			else
				error_state += "Maximum value description was selected but not provided."
		else
			option.desc_max = null
	if(error_state.len)
		if(new_option)
			to_chat(usr, "<span class='danger'>Option not added because the following errors were present:\n[error_state.Join("\n")]</span>")
			qdel(option)
		else
			to_chat(usr, "<span class='danger'>Not all edits were applied because the following errors were present:\n[error_state.Join("\n")]</span>")
		return
	if(new_option)
		poll.options += src
		option.parent_poll = poll
	if(poll.edit_ready)
		option.save_option()
	poll_management_panel(poll)

/datum/poll_option/New(id, text, minval, maxval, descmin, descmid, descmax, default_percentage_calc)
	option_id = text2num(id)
	src.text = text
	min_val = text2num(minval)
	max_val = text2num(maxval)
	desc_min = descmin
	desc_mid = descmid
	desc_max = descmax
	src.default_percentage_calc = text2num(default_percentage_calc)
	GLOB.poll_options += src

/datum/poll_option/Destroy()
	parent_poll.options -= src
	parent_poll = null
	GLOB.poll_options -= src
	return ..()

/**
  * Inserts or updates a poll option to the database.
  * 
  * Uses INSERT ON DUPLICATE KEY UPDATE to handle both inserting and updating at once.
  * The list of columns and values is built dynamically to avoid excess data being sent when not a rating type poll.
  * 
  */
/datum/poll_option/proc/save_option()
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/list/columns = list("text", "default_percentage_calc", "pollid", "id")
	var/list/values = list("'[sanitizeSQL(text)]'", "[sanitizeSQL(default_percentage_calc)]", "'[sanitizeSQL(parent_poll.poll_id)]'")
	if(option_id)
		columns += "[sanitizeSQL(option_id)]"
	else
		columns += "NULL"
	if(parent_poll.poll_type == POLLTYPE_RATING)
		columns.Add("minval", "maxval", "descmin", "descmid", "descmax")
		values.Add("[sanitizeSQL(min_val)]", "[sanitizeSQL(max_val)]")
		if(desc_min)
			values += "[sanitizeSQL(desc_min)]"
		else
			values += "NULL"
		if(desc_mid)
			values += "descmid = [sanitizeSQL(desc_mid)]"
		else
			values += "NULL"
		if(desc_max)
			values += "[sanitizeSQL(desc_max)]"
		else
			values += "NULL"
	var/list/update_data = list()
	for(var/i in columns)
		if(i == "pollid" || "id") //we don't want to update the pollid or option id so skip including those
			continue
		update_data += "[columns[i]] = [values[i]]"
	var/datum/DBQuery/query_update_poll_option = SSdbcore.NewQuery("INSERT INTO [format_table_name("poll_option")] ([jointext(columns, ",")]) VALUES ([jointext(values, ",")]) ON DUPLICATE KEY UPDATE [jointext(update_data, " ")]")
	if(!query_update_poll_option.warn_execute())
		qdel(query_update_poll_option)
		return
	qdel(query_update_poll_option)

/**
  * Sets a poll option and its votes as deleted in the database then deletes its datum.
  * 
  */
/datum/poll_option/proc/delete_option()
	if(!check_rights(R_POLL))
		return
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_delete_poll_option = SSdbcore.NewQuery("UPDATE [format_table_name("poll_option")] AS o INNER JOIN [format_table_name("poll_vote")] AS v ON o.id = v.optionid SET o.deleted = 1, v.deleted = 1 WHERE o.id = [sanitizeSQL(option_id)]")
	if(!query_delete_poll_option.warn_execute())
		qdel(query_delete_poll_option)
		return
	qdel(query_delete_poll_option)
	qdel(src)

/**
  * Loads all currently running server polls and their options to store both as datums.
  * 
  */
/proc/load_poll_data()
	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	var/datum/DBQuery/query_load_polls = SSdbcore.NewQuery("SELECT id, polltype, starttime, endtime, question, subtitle, adminonly, multiplechoiceoptions, dontshow, allow_revoting, IF(polltype='TEXT',(SELECT COUNT(*) FROM [format_table_name("poll_textreply")] AS t WHERE t.pollid = q.id), (SELECT COUNT(*) FROM [format_table_name("poll_vote")] AS v WHERE v.pollid = q.id)), IFNULL((SELECT byond_key FROM [format_table_name("player")] AS p WHERE p.ckey = q.createdby_ckey), createdby_ckey) FROM [format_table_name("poll_question")] AS q WHERE NOW() BETWEEN starttime AND endtime AND deleted = 0")
	if(!query_load_polls.Execute())
		qdel(query_load_polls)
		return
	var/list/poll_ids = list()
	while(query_load_polls.NextRow())
		new /datum/poll_question(query_load_polls.item[1], query_load_polls.item[2], query_load_polls.item[3], query_load_polls.item[4], query_load_polls.item[5], query_load_polls.item[6], query_load_polls.item[7], query_load_polls.item[8], query_load_polls.item[9], query_load_polls.item[10], query_load_polls.item[11], query_load_polls.item[12], TRUE)
		poll_ids += query_load_polls.item[1]
	qdel(query_load_polls)
	var/datum/DBQuery/query_load_poll_options = SSdbcore.NewQuery("SELECT id, text, minval, maxval, descmin, descmid, descmax, default_percentage_calc, pollid FROM [format_table_name("poll_option")] WHERE pollid IN ([jointext(poll_ids, ",")])")
	if(!query_load_poll_options.Execute())
		qdel(query_load_poll_options)
		return
	while(query_load_poll_options.NextRow())
		var/datum/poll_option/option = new(query_load_poll_options.item[1], query_load_poll_options.item[2], query_load_poll_options.item[3], query_load_poll_options.item[4], query_load_poll_options.item[5], query_load_poll_options.item[6], query_load_poll_options.item[7], query_load_poll_options.item[8])
		var/option_poll_id = text2num(query_load_poll_options.item[9])
		for(var/q in GLOB.polls)
			var/datum/poll_question/poll = q
			if(poll.poll_id == option_poll_id)
				poll.options += option
				option.parent_poll = poll
	qdel(query_load_poll_options)
