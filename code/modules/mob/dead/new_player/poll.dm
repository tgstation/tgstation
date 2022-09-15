
///All currently running polls held as datums
GLOBAL_LIST_EMPTY(polls)
GLOBAL_PROTECT(polls)

///All poll option datums of running polls
GLOBAL_LIST_EMPTY(poll_options)
GLOBAL_PROTECT(poll_options)

/**
 * Shows a list of currently running polls a player can vote/has voted on
 *
 */
/mob/dead/new_player/proc/handle_player_polling()
	var/list/output = list("<div align='center'><B>Player polls</B><hr><table>")
	var/rs = REF(src)
	for(var/p in GLOB.polls)
		var/datum/poll_question/poll = p
		if((poll.admin_only && !client.holder) || poll.future_poll)
			continue
		output += "<tr bgcolor='#e2e2e2'><td><a href='?src=[rs];viewpoll=[REF(poll)]'><b>[poll.question]</b></a></td></tr>"
	output += "</table>"
	src << browse(jointext(output, ""),"window=playerpolllist;size=500x300")

/**
 * Redirects a player to the correct poll window based on poll type.
 *
 */
/mob/dead/new_player/proc/poll_player(datum/poll_question/poll)
	if(!poll)
		return
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	switch(poll.poll_type)
		if(POLLTYPE_OPTION)
			poll_player_option(poll)
		if(POLLTYPE_TEXT)
			poll_player_text(poll)
		if(POLLTYPE_RATING)
			poll_player_rating(poll)
		if(POLLTYPE_MULTI)
			poll_player_multi(poll)
		if(POLLTYPE_IRV)
			poll_player_irv(poll)

/**
 * Shows voting window for an option type poll, listing its options and relevant details.
 *
 * If already voted on, the option a player voted for is pre-selected.
 *
 */
/mob/dead/new_player/proc/poll_player_option(datum/poll_question/poll)
	var/datum/db_query/query_option_get_voted = SSdbcore.NewQuery({"
		SELECT optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_option_get_voted.warn_execute())
		qdel(query_option_get_voted)
		return
	var/voted_option_id = 0
	if(query_option_get_voted.NextRow())
		voted_option_id = text2num(query_option_get_voted.item[1])
	qdel(query_option_get_voted)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!voted_option_id || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		"}
	output += "<table><tr><td>"
	for(var/o in poll.options)
		var/datum/poll_option/option = o
		output += "<label><input type='radio' name='voteoptionref' value='[REF(option)]'"
		if(voted_option_id && !poll.allow_revoting)
			output += " disabled"
		if(voted_option_id == option.option_id)
			output += " selected"
		output += ">[option.text]</label><br>"
	output += "</td></tr></table>"
	if(!voted_option_id || poll.allow_revoting)
		output += "<p><input type='submit' value='Vote'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x250")

/**
 * Shows voting window for a text response type poll, listing its relevant details.
 *
 * If already responded to, the saved response of a player is shown.
 *
 */
/mob/dead/new_player/proc/poll_player_text(datum/poll_question/poll)
	var/datum/db_query/query_text_get_replytext = SSdbcore.NewQuery({"
		SELECT replytext FROM [format_table_name("poll_textreply")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_text_get_replytext.warn_execute())
		qdel(query_text_get_replytext)
		return
	var/reply_text = ""
	if(query_text_get_replytext.NextRow())
		reply_text = query_text_get_replytext.item[1]
	qdel(query_text_get_replytext)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Feedback gathering runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!reply_text || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		<font size='2'>Please provide feedback below. You can use any letters of the English alphabet, numbers and the symbols: . , ! ? : ; -</font><br>
		<textarea name='replytext' cols='50' rows='14'>[reply_text]</textarea>
		<p><input type='submit' value='Submit'></form>
		"}
	else
		output += "[reply_text]"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x500")

/**
 * Shows voting window for a rating type poll, listing its options and relevant details.
 *
 * If already voted on, the options a player voted for are pre-selected.
 *
 */
/mob/dead/new_player/proc/poll_player_rating(datum/poll_question/poll)
	var/datum/db_query/query_rating_get_votes = SSdbcore.NewQuery({"
		SELECT optionid, rating FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_rating_get_votes.warn_execute())
		qdel(query_rating_get_votes)
		return
	var/list/voted_ratings = list()
	while(query_rating_get_votes.NextRow())
		voted_ratings += list("[query_rating_get_votes.item[1]]" = query_rating_get_votes.item[2])
	qdel(query_rating_get_votes)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!length(voted_ratings) || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		"}
	for(var/o in poll.options)
		var/datum/poll_option/option = o
		var/mid_val = round((option.max_val + option.min_val) / 2)
		var/selected_rating = text2num(voted_ratings["[option.option_id]"])
		output += "<label><br>[option.text]: <select name='[REF(option)]'"
		if(length(voted_ratings) && !poll.allow_revoting)
			output += " disabled"
		output += ">"
		for(var/rating in option.min_val to option.max_val)
			output += "<option value='[rating]'"
			if(selected_rating == rating)
				output += " selected"
			output += ">[rating]"
			if(option.desc_min && rating == option.min_val)
				output += " ([option.desc_min])"
			else if(option.desc_mid && rating == mid_val)
				output += " ([option.desc_mid])"
			else if(option.desc_max && rating == option.max_val)
				output += " ([option.desc_max])"
			output += "</option>"
		output += "</select></label>"
	if(!length(voted_ratings) || poll.allow_revoting)
		output += "<p><input type='submit' value='Submit'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x500")

/**
 * Shows voting window for a multiple choice type poll, listing its options and relevant details.
 *
 * If already voted on, the options a player voted for are pre-selected.
 *
 */
/mob/dead/new_player/proc/poll_player_multi(datum/poll_question/poll)
	var/datum/db_query/query_multi_get_votes = SSdbcore.NewQuery({"
		SELECT optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_multi_get_votes.warn_execute())
		qdel(query_multi_get_votes)
		return
	var/list/voted_for = list()
	while(query_multi_get_votes.NextRow())
		voted_for += text2num(query_multi_get_votes.item[1])
	qdel(query_multi_get_votes)
	var/list/output = list("<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>")
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "You can select up to [poll.options_allowed] options. If you select more, the first [poll.options_allowed] will be saved.<br><font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	if(!length(voted_for) || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='get'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		"}
	output += "<table><tr><td>"
	for(var/o in poll.options)
		var/datum/poll_option/option = o
		output += "<label><input type='checkbox' name='[REF(option)]' value='[option.option_id]'"
		if(length(voted_for) && !poll.allow_revoting)
			output += " disabled"
		if(option.option_id in voted_for)
			output += " checked"
		output += ">[option.text]</label><br>"
	output += "</td></tr></table>"
	if(!length(voted_for) || poll.allow_revoting)
		output += "<p><input type='submit' value='Vote'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x300")

/**
 * Shows voting window for an IRV type poll, listing its options and relevant details.
 *
 * If already voted on, the options are sorted how a player voted for them, otherwise they are randomly shuffled.
 *
 */
/mob/dead/new_player/proc/poll_player_irv(datum/poll_question/poll)
	var/datum/asset/irv_assets = get_asset_datum(/datum/asset/group/irv)
	irv_assets.send(src)
	var/datum/db_query/query_irv_get_votes = SSdbcore.NewQuery({"
		SELECT optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_irv_get_votes.warn_execute())
		qdel(query_irv_get_votes)
		return
	var/list/voted_for = list()
	while(query_irv_get_votes.NextRow())
		voted_for += text2num(query_irv_get_votes.item[1])
	qdel(query_irv_get_votes)
	var/list/prepared_options = list()
	//if they've already voted we use the order they voted in plus a shuffle of any options they haven't voted for, if any
	if(length(voted_for))
		var/list/option_copy = poll.options.Copy()
		for(var/vote_id in voted_for)
			for(var/o in option_copy)
				var/datum/poll_option/option = o
				if(option.option_id == vote_id)
					prepared_options += option
					option_copy -= option
		prepared_options += shuffle(option_copy)
	//otherwise just shuffle the options
	else
		prepared_options = shuffle(poll.options)
	var/list/output = list({"<html><head><meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
	<script src="[SSassets.transport.get_asset_url("jquery.min.js")]"></script>
	<script src="[SSassets.transport.get_asset_url("jquery-ui.custom-core-widgit-mouse-sortable.min.js")]"></script>
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
				$('#IRVdata').val($( "#sortable" ).sortable("toArray", { attribute: "optionref" }));
			});
		});
	</script>
	</head>
	<body>
	<div align='center'><B>Player poll</B><hr><b>Question: [poll.question]</b><br>"})
	if(poll.subtitle)
		output += "[poll.subtitle]<br>"
	output += "<font size='2'>Poll runs from <b>[poll.start_datetime]</b> until <b>[poll.end_datetime]</b></font><br>"
	if(poll.allow_revoting)
		output += "<font size='2'>Revoting is enabled.</font>"
	output += "Please sort the options in the order of <b>most preferred</b> to <b>least preferred</b><br></div>"
	if(!length(voted_for) || poll.allow_revoting)
		output += {"<form action='?src=[REF(src)]' method='POST'>
		<input type='hidden' name='src' value='[REF(src)]'>
		<input type='hidden' name='votepollref' value='[REF(poll)]'>
		<input type='hidden' name='IRVdata' id='IRVdata'>
		"}
	output += "<div id='ballot' class='center'><b><center>Most Preferred</center></b><ol id='sortable' class='rankings' style='padding:0px'>"
	for(var/o in prepared_options)
		var/datum/poll_option/option = o
		output += "<li optionref='[REF(option)]' class='ranking'><span class='grippy'></span> [option.text]</li>\n"
	output += "</ol><b><center>Least Preferred</center></b><br>"
	if(!length(voted_for) || poll.allow_revoting)
		output += "<p><input type='submit' value='Vote'></form>"
	output += "</div>"
	src << browse(jointext(output, ""),"window=playerpoll;size=500x500")

/**
 * Runs some poll validation before a vote is processed.
 *
 * Checks a player is who they claim to be and that a poll is actually still running.
 * Also loads the vote_id to pass onto single-option and text polls.
 * Increments the vote count when successful.
 *
 */
/mob/dead/new_player/proc/vote_on_poll_handler(datum/poll_question/poll, href_list)
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	if(!poll || !href_list)
		return
	if(IsAdminAdvancedProcCall())
		usr.log_message("attempted to rig the vote by voting as [key].", LOG_ADMIN)
		message_admins("[key_name_admin(usr)] attempted to rig the vote by voting as [key].")
		to_chat(usr, span_danger("You don't seem to be [key]."))
		to_chat(src, span_danger("Something went horribly wrong processing your vote. Please contact an administrator, they should have gotten a message about this."))
		return
	var/admin_rank
	if(client.holder)
		admin_rank = client.holder.rank_names()
	else
		if(poll.admin_only)
			return
		else
			admin_rank = "Player"
	var/table = "poll_vote"
	if(poll.poll_type == POLLTYPE_TEXT)
		table = "poll_textreply"
	var/sql_poll_id = poll.poll_id
	var/vote_id //only used for option and text polls to save needing another query
	var/datum/db_query/query_validate_poll_vote = SSdbcore.NewQuery({"
		SELECT
			(SELECT id FROM [format_table_name(table)] WHERE ckey = :ckey AND pollid = :pollid AND deleted = 0 LIMIT 1)
		FROM [format_table_name("poll_question")]
		WHERE NOW() BETWEEN starttime AND endtime AND deleted = 0 AND id = :pollid
	"}, list("ckey" = ckey, "pollid" = sql_poll_id))
	if(!query_validate_poll_vote.warn_execute())
		qdel(query_validate_poll_vote)
		return
	//triple state return: no row returned if poll isn't running, null if no vote found, otherwise returns the vote id
	if(query_validate_poll_vote.NextRow())
		vote_id = text2num(query_validate_poll_vote.item[1])
		if(vote_id && !poll.allow_revoting)
			to_chat(usr, span_danger("Poll revoting is disabled and you've already replied to this poll."))
			qdel(query_validate_poll_vote)
			return
	else
		to_chat(usr, span_danger("Selected poll is not open."))
		qdel(query_validate_poll_vote)
		return
	qdel(query_validate_poll_vote)
	var/vote_success = FALSE
	switch(poll.poll_type)
		if(POLLTYPE_OPTION)
			vote_success = vote_on_poll_option(poll, href_list, admin_rank, sql_poll_id, vote_id)
		if(POLLTYPE_TEXT)
			vote_success = vote_on_poll_text(href_list, admin_rank, sql_poll_id, vote_id)
		if(POLLTYPE_RATING)
			vote_success = vote_on_poll_rating(poll, href_list, admin_rank, sql_poll_id)
		if(POLLTYPE_MULTI)
			vote_success = vote_on_poll_multi(poll, href_list, admin_rank, sql_poll_id)
		if(POLLTYPE_IRV)
			vote_success = vote_on_poll_irv(poll, href_list, admin_rank, sql_poll_id)
	if(vote_success)
		if(!vote_id)
			poll.poll_votes++
		to_chat(usr, span_notice("Vote successful."))

/**
 * Processes vote form data and saves results to the database for an option type poll.
 *
 */
/mob/dead/new_player/proc/vote_on_poll_option(datum/poll_question/poll, href_list, admin_rank, sql_poll_id, vote_id)
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	if(IsAdminAdvancedProcCall())
		return
	var/datum/poll_option/option = locate(href_list["voteoptionref"]) in poll.options
	if(!option)
		to_chat(src, span_danger("No option was selected."))
		return
	var/datum/db_query/query_vote_option = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_vote")] (id, datetime, pollid, optionid, ckey, ip, adminrank)
		VALUES (:vote_id, NOW(), :poll_id, :option_id, :ckey, INET_ATON(:ip), :admin_rank)
		ON DUPLICATE KEY UPDATE datetime = NOW(), optionid = :option_id, ip = INET_ATON(:ip), adminrank = :admin_rank
	"}, list(
		"vote_id" = vote_id,
		"poll_id" = sql_poll_id,
		"option_id" = option.option_id,
		"ckey" = ckey,
		"ip" = client.address,
		"admin_rank" = admin_rank,
	))
	if(!query_vote_option.warn_execute())
		qdel(query_vote_option)
		return
	qdel(query_vote_option)
	return TRUE

/**
 * Processes response form data and saves results to the database for a text response type poll.
 *
 */
/mob/dead/new_player/proc/vote_on_poll_text(href_list, admin_rank, sql_poll_id, vote_id)
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	if(IsAdminAdvancedProcCall())
		return
	var/reply_text = href_list["replytext"]
	if(!reply_text || (length(reply_text) > 2048))
		to_chat(src, span_danger("The text you entered was blank or too long. Please correct the text and submit again."))
		return
	var/datum/db_query/query_vote_text = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_textreply")] (id, datetime, pollid, ckey, ip, replytext, adminrank)
		VALUES (:vote_id, NOW(), :poll_id, :ckey, INET_ATON(:ip), :reply_text, :admin_rank)
		ON DUPLICATE KEY UPDATE datetime = NOW(), ip = INET_ATON(:ip), replytext = :reply_text, adminrank = :admin_rank
	"}, list(
		"vote_id" = vote_id,
		"poll_id" = sql_poll_id,
		"ckey" = ckey,
		"ip" = client.address,
		"reply_text" = reply_text,
		"admin_rank" = admin_rank,
	))
	if(!query_vote_text.warn_execute())
		qdel(query_vote_text)
		return
	qdel(query_vote_text)
	return TRUE

/**
 * Processes vote form data and saves results to the database for a rating type poll.
 *
 */
/mob/dead/new_player/proc/vote_on_poll_rating(datum/poll_question/poll, list/href_list, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	if(IsAdminAdvancedProcCall())
		return
	var/list/votes = list()
	var/datum/db_query/query_get_rating_votes = SSdbcore.NewQuery({"
		SELECT id, optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_get_rating_votes.warn_execute())
		qdel(query_get_rating_votes)
		return
	while(query_get_rating_votes.NextRow())
		votes += list("[query_get_rating_votes.item[2]]" = text2num(query_get_rating_votes.item[1]))
	qdel(query_get_rating_votes)
	href_list.Cut(1,3) //first two values aren't options

	var/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	for(var/h in href_list)
		var/datum/poll_option/option = locate(h) in poll.options
		sql_votes += list(list(
			"id" = votes["[option.option_id]"],
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank,
			"rating" = href_list[h]
		))
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, duplicate_key = TRUE, special_columns = special_columns)
	return TRUE

/**
 * Processes vote form data and saves results to the database for a multiple choice type poll.
 *
 */
/mob/dead/new_player/proc/vote_on_poll_multi(datum/poll_question/poll, list/href_list, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	if(IsAdminAdvancedProcCall())
		return
	if(length(href_list) > 2)
		href_list.Cut(1,3) //first two values aren't options
	else
		to_chat(src, span_danger("No options were selected."))

	var/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	var/vote_count = 0
	for(var/h in href_list)
		if(vote_count == poll.options_allowed)
			to_chat(src, span_danger("Allowed option count exceeded, only the first [poll.options_allowed] selected options have been saved."))
			break
		vote_count++
		var/datum/poll_option/option = locate(h) in poll.options
		sql_votes += list(list(
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank
		))
	/*with revoting and poll editing possible there can be an edge case where a poll is changed to allow less multiple choice options than a user has already voted on
	rather than trying to calculate which options should be updated and which deleted, we just delete all of a user's votes and re-insert as needed*/
	var/datum/db_query/query_delete_multi_votes = SSdbcore.NewQuery({"
		UPDATE [format_table_name("poll_vote")] SET deleted = 1 WHERE pollid = :pollid AND ckey = :ckey
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_delete_multi_votes.warn_execute())
		qdel(query_delete_multi_votes)
		return
	qdel(query_delete_multi_votes)
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, special_columns = special_columns)
	return TRUE

/**
 * Processes vote form data and saves results to the database for an IRV type poll.
 *
 */
/mob/dead/new_player/proc/vote_on_poll_irv(datum/poll_question/poll, list/href_list, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, span_danger("Failed to establish database connection."))
		return
	if(IsAdminAdvancedProcCall())
		return
	var/list/votelist = splittext(href_list["IRVdata"], ",")
	if(!length(votelist))
		to_chat(src, span_danger("No ordering data found. Please try again or contact an administrator."))

	var/list/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/list/sql_votes = list()
	var/list/option_copy = poll.options.Copy()
	for(var/o in votelist)
		var/datum/poll_option/option = locate(o) in option_copy
		if (!option)
			to_chat(src, span_warning("invalid votes were trimmed from your ballot, please revote ."))
		sql_votes += list(list(
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank
		))
	//IRV results are calculated based on id order, we delete all of a user's votes to avoid potential errors caused by revoting and option editing
	var/datum/db_query/query_delete_irv_votes = SSdbcore.NewQuery({"
		UPDATE [format_table_name("poll_vote")] SET deleted = 1 WHERE pollid = :pollid AND ckey = :ckey
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_delete_irv_votes.warn_execute())
		qdel(query_delete_irv_votes)
		return
	qdel(query_delete_irv_votes)
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, special_columns = special_columns)
	return TRUE
