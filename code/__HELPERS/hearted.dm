/// Called when the shuttle starts launching back to centcom, polls a few random players who joined the round for commendations
/datum/controller/subsystem/ticker/proc/poll_hearts()
	if(!CONFIG_GET(number/commendation_percent_poll))
		return

	var/number_to_ask = round(LAZYLEN(GLOB.joined_player_list) * CONFIG_GET(number/commendation_percent_poll)) + rand(0,1)
	if(number_to_ask == 0)
		message_admins("Not enough eligible players to poll for commendations.")
		return
	message_admins("Polling [number_to_ask] players for commendations.")

	for(var/i in GLOB.joined_player_list)
		var/mob/check_mob = get_mob_by_ckey(i)
		if(!check_mob?.mind || !check_mob.client)
			continue
		// maybe some other filters like bans or whatever
		INVOKE_ASYNC(check_mob, /mob.proc/query_heart, 1)
		number_to_ask--
		if(number_to_ask <= 0)
			break

/// Once the round is actually over, cycle through the ckeys in the hearts list and give them the hearted status
/datum/controller/subsystem/ticker/proc/handle_hearts()
	var/list/message = list("The following players were commended this round: ")
	var/i = 0
	for(var/hearted_ckey in hearts)
		i++
		var/mob/hearted_mob = get_mob_by_ckey(hearted_ckey)
		if(!hearted_mob?.client)
			continue
		hearted_mob.client.adjust_heart()
		message += "[hearted_ckey][i==hearts.len ? "" : ", "]"
	message_admins(message.Join())

/// Ask someone if they'd like to award a commendation for the round, 3 tries to get the name they want before we give up
/mob/proc/query_heart(attempt=1)
	if(!client || attempt > 3)
		return
	if(attempt == 1 && tgui_alert(src, "Was there another character you noticed being kind this round that you would like to anonymously thank?", "<3?", list("Yes", "No"), timeout = 30 SECONDS) != "Yes")
		return

	var/heart_nominee
	switch(attempt)
		if(1)
			heart_nominee = tgui_input_text(src, "What was their name? Just a first or last name may be enough.", "<3?")
		if(2)
			heart_nominee = tgui_input_text(src, "Try again, what was their name? Just a first or last name may be enough.", "<3?")
		if(3)
			heart_nominee = tgui_input_text(src, "One more try, what was their name? Just a first or last name may be enough.", "<3?")

	if(!heart_nominee)
		return

	heart_nominee = lowertext(heart_nominee)
	var/list/name_checks = get_mob_by_name(heart_nominee)
	if(!name_checks || name_checks.len == 0)
		query_heart(attempt + 1)
		return
	name_checks = shuffle(name_checks)

	for(var/i in name_checks)
		var/mob/heart_contender = i
		if(heart_contender == src)
			continue

		switch(tgui_alert(src, "Is this the person: [heart_contender.real_name]?", "<3?", list("Yes!", "Nope", "Cancel"), timeout = 15 SECONDS))
			if("Yes!")
				heart_contender.receive_heart(src)
				return
			if("Nope")
				continue
			else
				return

	query_heart(attempt + 1)

/*
* Once we've confirmed who we're commending, either set their status now or log it for the end of the round
*
* This used to be reversed, being named nominate_heart and being called on the mob sending the commendation and the first argument being
* the heart_recepient, but that was confusing and unintuitive, so now src is the person being commended and the sender is now the first argument.
*
* Arguments:
* * heart_sender: The reference to the mob who sent the commendation, just for the purposes of logging
* * duration: How long from the moment it's applied the heart will last
* * instant: If TRUE (or if the round is already over), we'll give them the heart status now, if FALSE, we wait until the end of the round (which is the standard behavior)
*/
/mob/proc/receive_heart(mob/heart_sender, duration = 24 HOURS, instant = FALSE)
	if(!client)
		return
	to_chat(heart_sender, span_nicegreen("Commendation sent!"))
	message_admins("[key_name(heart_sender)] commended [key_name(src)] [instant ? "(instant)" : ""]")
	log_admin("[key_name(heart_sender)] commended [key_name(src)] [instant ? "(instant)" : ""]")
	if(instant || SSticker.current_state == GAME_STATE_FINISHED)
		client.adjust_heart(duration)
	else
		LAZYADD(SSticker.hearts, ckey)
