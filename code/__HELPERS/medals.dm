//The code here is used for BYOND medals, typically awarded for things like killing megafauna or winning a pulse rifle.
//It also covers stuff for keeping track of certain statistics.

#define ANNOUNCE_TO_NOBODY "nobody" //Silent, doesn't tell anyone
#define ANNOUNCE_TO_PLAYER "player" //Tells the person who earned the achievement
#define ANNOUNCE_TO_ADMINS "admins" //Tells the unlocker and any online admins
#define ANNOUNCE_TO_EVERYONE "everyone" //Tells everyone

/proc/CheckMedal(medal,client/player) //Checks if a player has a medal, returning 1 on a success and 0 on a failure

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/result = world.GetMedal(medal, player, global.medal_hub, global.medal_pass)

		if(isnull(result))
			global.medals_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to get medal:[medal] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to get [medal] medal for [player.ckey]!")
			return 0
		else if (result)
			return TRUE
		return FALSE


/proc/UnlockMedal(medal, client/player, announce = ANNOUNCE_TO_PLAYER) //Adds a medal to the player
	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		spawn()
			var/result = world.SetMedal(medal, player, global.medal_hub, global.medal_pass)
			if(isnull(result))
				global.medals_enabled = FALSE
				log_game("MEDAL ERROR: Could not contact hub to award medal:[medal] player:[player.ckey]")
				message_admins("Error! Failed to contact hub to award [medal] medal to [player.ckey]!")
			else
				log_game("Player [player.ckey] unlocked medal [medal].")
				switch(announce)
					if(ANNOUNCE_TO_PLAYER)
						player << "<span class='noticealien'>Achievement unlocked:</span> <span class='alertalien'>[medal]</span><span class='noticealien'>!</span>"
					if(ANNOUNCE_TO_ADMINS)
						player << "<span class='noticealien'>Achievement unlocked:</span> <span class='alertalien'>[medal]</span><span class='noticealien'>!</span>"
						message_admins("Player [player.ckey] unlocked medal [medal]!")
					if(ANNOUNCE_TO_EVERYONE)
						player << "<span class='noticealien'>[player.ckey] has earned the</span> <span class='alertalien'>[medal]</span> <span class='noticealien'>achievement!</span>"


/proc/LockMedal(medal, client/player, announce = ANNOUNCE_TO_ADMINS) //Removes a medal from the player
	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		var/result = world.ClearMedal(medal, player, global.medal_hub, global.medal_pass)
		if(isnull(result))
			global.medals_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to clear medal:[medal] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to clear [medal] medal for [player.ckey]!")
		else if(result)
			message_admins("Medal: [medal] removed for [player.ckey]")
		else
			log_game("Player [player.ckey] unlocked medal [medal].")
			switch(announce)
				if(ANNOUNCE_TO_PLAYER)
					player << "<span class='danger'>Achievement locked:</span> <span class='boldannounce'>[medal]</span><span class='danger'>!</span>"
				if(ANNOUNCE_TO_ADMINS)
					player << "<span class='danger'>Achievement locked:</span> <span class='boldannounce'>[medal]</span><span class='danger'>!</span>"
					message_admins("Player [player.ckey] lost medal [medal]!")
				if(ANNOUNCE_TO_EVERYONE)
					player << "<span class='danger'>[player.ckey] has lost the</span> <span class='boldannounce'>[medal]</span> <span class='danger'>achievement!</span>"


/proc/SetScore(score,client/player,increment,force)

	if(!score || !player)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		spawn()
			var/list/oldscore = GetScore(score,player,1)

			if(increment)
				if(!oldscore[score])
					oldscore[score] = 1
				else
					oldscore[score] = (text2num(oldscore[score]) + 1)
			else
				oldscore[score] = force

			var/newscoreparam = list2params(oldscore)

			var/result = world.SetScores(player.ckey, newscoreparam, global.medal_hub, global.medal_pass)

			if(isnull(result))
				global.medals_enabled = FALSE
				log_game("SCORE ERROR: Could not contact hub to set score. Score:[score] player:[player.ckey]")
				message_admins("Error! Failed to contact hub to set [score] score for [player.ckey]!")


/proc/GetScore(score,client/player,returnlist)

	if(!score || !player)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/scoreget = world.GetScores(player.ckey, score, global.medal_hub, global.medal_pass)
		if(isnull(scoreget))
			global.medals_enabled = FALSE
			log_game("SCORE ERROR: Could not contact hub to get score. Score:[score] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to get score: [score] for [player.ckey]!")
			return

		var/list/scoregetlist = params2list(scoreget)

		if(returnlist)
			return scoregetlist
		else
			return scoregetlist[score]

/proc/ClearScore(client/player)
	world.SetScores(player.ckey, "", global.medal_hub, global.medal_pass)
