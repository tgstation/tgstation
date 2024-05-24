/datum/controller/subsystem/ticker/proc/save_tokens()
	rustg_file_write(json_encode(GLOB.saved_token_values), "[GLOB.log_directory]/tokens.json")

/datum/controller/subsystem/ticker/proc/distribute_rewards()
	var/hour = round((world.time - SSticker.round_start_time) / 36000)
	var/minute = round(((world.time - SSticker.round_start_time) - (hour * 36000)) / 600)
	var/added_xp = round(25 + (minute**0.85))
	for(var/client/client as anything in GLOB.clients)
		if(!istype(client) || QDELING(client))
			continue
		if(!QDELETED(client?.prefs))
			client?.prefs?.adjust_metacoins(client?.ckey, 75, "Played a Round")
			client?.prefs?.adjust_metacoins(client?.ckey, client?.reward_this_person, "Special Bonus")
			// WHYYYYYY
			if(QDELETED(client))
				continue
			if(client?.mob?.mind?.assigned_role)
				add_jobxp(client, added_xp, client?.mob?.mind?.assigned_role?.title)
		if(QDELETED(client))
			continue
		if(length(client?.applied_challenges))
			var/mob/living/client_mob = client?.mob
			if(!istype(client_mob) || QDELING(client_mob) || client_mob?.stat == DEAD)
				continue
			var/total_payout = 0
			for(var/datum/challenge/listed_challenge as anything in client?.applied_challenges)
				if(listed_challenge.failed)
					continue
				total_payout += listed_challenge.challenge_payout
			if(total_payout)
				client?.prefs?.adjust_metacoins(client?.ckey, total_payout, "Challenge rewards.")
