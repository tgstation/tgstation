/**
 * Called when the shuttle starts launching back to centcom, polls a few random players who joined the round for commendations
 */
/datum/controller/subsystem/ticker/proc/poll_commendations()
	if(!CONFIG_GET(number/commendations))
		return
	var/number_to_ask = round(LAZYLEN(GLOB.joined_player_list) * CONFIG_GET(number/commendations)) + rand(0,1)

	for(var/i in GLOB.joined_player_list)
		var/mob/check_mob = get_mob_by_ckey(i)
		if(!check_mob?.mind || !check_mob.client)
			continue
		// maybe some other filters like bans or whatever
		INVOKE_ASYNC(check_mob, /mob.proc/query_commendation, 1)
		number_to_ask--
		if(number_to_ask == 0)
			break

/**
 * Once the round is actually over, cycle through the commendations in the list and give them the commendation status
 */
/datum/controller/subsystem/ticker/proc/handle_commendations()
	for(var/i in commendations_this_round)
		var/mob/commendation_winner = i
		if(!commendation_winner.mind || !commendation_winner.client)
			continue
		commendation_winner.client.prefs.commendation_until = world.realtime + 24 HOURS // make configable
		if(!commendation_winner.client)
			return

		commendation_winner.client.prefs.commendation = TRUE // so they get it right away
		if(!commendation_winner.client)
			return
		commendation_winner.client.prefs.save_preferences()
		tgui_alert(commendation_winner, "Someone anonymously thanked you for being kind during the last round!", "<3!", list("Okay"))

/**
 * Ask someone if they'd like to award a commendation for the round, 3 tries to get the name they want before we give up
 */
/mob/proc/query_commendation(attempt=1)
	if(!mind || !client || attempt > 3)
		return
	if(attempt == 1 && tgui_alert(src, "Was there another character you noticed being kind this round that you would like to anonymously thank?", "<3?", list("Yes", "No"), timeout = 30 SECONDS) != "Yes")
		return

	var/commendation_nominee
	switch(attempt)
		if(1)
			commendation_nominee = input(src, "What was their name? Just a first or last name may be enough. (Leave blank to cancel)", "<3?")
		if(2)
			commendation_nominee = input(src, "Try again, what was their name? Just a first or last name may be enough. (Leave blank to cancel)", "<3?")
		if(3)
			commendation_nominee = input(src, "One more try, what was their name? Just a first or last name may be enough. (Leave blank to cancel)", "<3?")

	if(isnull(commendation_nominee) || commendation_nominee == "")
		return

	commendation_nominee = lowertext(commendation_nominee)
	var/list/name_checks = get_mob_by_name(commendation_nominee)
	if(!name_checks || name_checks.len == 0)
		query_commendation(attempt + 1)
		return
	name_checks = shuffle(name_checks)

	for(var/i in name_checks)
		var/mob/commendation_contender = i
		if(commendation_contender == src)
			continue

		switch(tgui_alert(src, "Is this the person: [commendation_contender.real_name]?", "<3?", list("Yes!", "Nope", "Cancel"), timeout = 15 SECONDS))
			if("Yes!")
				nominate_commendation(commendation_contender)
				return
			if("Nope")
				continue
			if("Cancel")
				return

	query_commendation(attempt + 1)

/**
 * Once we've confirmed who we're commendating, log it and add them to the commendations list
 */
/mob/proc/nominate_commendation(mob/commendation_recepient)
	if(!mind || !client)
		return
	to_chat(src, "<span class='nicegreen'>Commendation sent!</span>")
	message_admins("[key_name(src)] commended [key_name(commendation_recepient)] (<a href='?src=[REF(SSticker)];cancel_commendation=1;commendation_source=[REF(src)];commendation_target=[REF(commendation_recepient)]'>CANCEL</a>)") // cancel is probably unnecessary without messages
	log_admin("[key_name(src)] commended [key_name(commendation_recepient)]")
	LAZYADD(SSticker.commendations_this_round, commendation_recepient)
