#define HEART_PCT_PLAYERS 0.05

/datum/controller/subsystem/ticker/proc/poll_hearts()
	var/number_to_ask = round(LAZYLEN(GLOB.joined_player_list) * HEART_PCT_PLAYERS) + rand(0,1)

	for(var/i in GLOB.joined_player_list)
		var/mob/check_mob = get_mob_by_ckey(i)
		if(!check_mob || !check_mob.mind || !check_mob.client)
			continue

		check_mob.query_heart(1)
		number_to_ask--
		if(number_to_ask == 0)
			break

/datum/controller/subsystem/ticker/proc/handle_hearts()
	for(var/i in hearts)
		var/mob/heart_winner = i
		if(!heart_winner.mind || !heart_winner.client)
			continue
		heart_winner.client.prefs.hearted_until = world.realtime + 24 HOURS // make configable
		if(!heart_winner.client)
			return

		heart_winner.client.prefs.hearted = TRUE // so they get it right away
		if(!heart_winner.client)
			return
		heart_winner.client.prefs.save_preferences()
		var/heart_message = hearts[heart_winner]
		tgalert(heart_winner, "Someone anonymously thanked you for being kind during the last round! [heart_message ? "They left a message: [heart_message]" : ""]", "<3!", "Okay")


/mob/proc/query_heart(attempt=1)
	if(!mind || !client || attempt > 3)
		return
	if(attempt == 1 && tgalert(src, "Was there another character you noticed being kind this round that you would like to anonymously thank?", "<3?", "Yes", "No", StealFocus=FALSE, Timeout = 30 SECONDS) != "Yes")
		return

	var/heart_nominee
	switch(attempt)
		if(1)
			heart_nominee = input(src, "What was their name? Just a first or last name may be enough. (Leave blank to cancel)", "<3?")
		if(2)
			heart_nominee = input(src, "Try again, what was their name? Just a first or last name may be enough. (Leave blank to cancel)", "<3?")
		if(3)
			heart_nominee = input(src, "One more try, what was their name? Just a first or last name may be enough. (Leave blank to cancel)", "<3?")

	if(isnull(heart_nominee) || heart_nominee == "")
		return

	var/list/name_checks = get_mob_by_name(heart_nominee)
	if(!name_checks || name_checks.len == 0)
		query_heart(attempt + 1)
		return
	name_checks = shuffle(name_checks)

	for(var/i in name_checks)
		var/mob/heart_contender = i
		//if(heart_contender == src)
			//continue

		switch(tgalert(src, "Is this the person: [heart_contender.real_name]?", "<3?", "Yes!", "Nope", "Cancel", Timeout = 15 SECONDS))
			if("Yes!")
				nominate_heart(heart_contender)
				return
			if("Nope")
				continue
			if("Cancel")
				return

	query_heart(attempt + 1)

/mob/proc/nominate_heart(mob/heart_recepient)
	if(!mind || !client)
		return
	var/heart_message = input(src, "OPTIONAL: Attach an anonymous message with your thank-you?", "<3?")
	message_admins("[key_name(src)] commended [key_name(heart_recepient)] [heart_message ? "with the message: [heart_message]" : "with no message"] (<a href='?src=[REF(SSticker)];cancel_heart=1;heart_source=[REF(src)];heart_target=[REF(heart_recepient)]'>CANCEL</a>)")
	log_admin("[key_name(src)] commended [key_name(heart_recepient)] [heart_message ? "with the message: [heart_message]" : "with no message"]")
	LAZYINITLIST(SSticker.hearts)
	SSticker.hearts[heart_recepient] = heart_message
