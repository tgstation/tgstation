var/global/datum/controller/vote/vote = new()

/datum/controller/vote
	var/initiator = null
	var/started_time = null
	var/time_remaining = 0
	var/mode = null
	var/question = null
	var/list/choices = list()
	var/list/voted = list()
	var/list/voting = list()
	var/list/current_votes = list()

	New()
		. = ..()

		if (vote != src)
			if (istype(vote))
				qdel(vote)

			vote = src

	proc/process()	//called by master_controller
		if(mode)
			// No more change mode votes after the game has started.
			// 3 is GAME_STATE_PLAYING, but that #define is undefined for some reason
			if(mode == "gamemode" && ticker.current_state >= 2)
				world << "<b>Voting aborted due to game start.</b>"
				src.reset()
				return

			// Calculate how much time is remaining by comparing current time, to time of vote start,
			// plus vote duration
			time_remaining = round((started_time + config.vote_period - world.time)/10)

			if(time_remaining < 0)
				result()
				for(var/client/C in voting)
					if(C)
						C << browse(null,"window=vote;can_close=0")
				reset()
			else
				for(var/client/C in voting)
					if(C)
						C << browse(vote.interface(C),"window=vote;can_close=0")

				voting.Cut()

	proc/reset()
		initiator = null
		time_remaining = 0
		mode = null
		question = null
		choices.Cut()
		voted.Cut()
		voting.Cut()
		current_votes.Cut()

	proc/get_result()
		//get the highest number of votes
		var/greatest_votes = 0
		var/total_votes = 0
		for(var/option in choices)
			var/votes = choices[option]
			total_votes += votes
			if(votes > greatest_votes)
				greatest_votes = votes
		//default-vote for everyone who didn't vote
		if(!config.vote_no_default && choices.len)
			var/non_voters = (clients.len - total_votes)
			if(non_voters > 0)
				if(mode == "restart")
					choices["Continue Playing"] += non_voters
					if(choices["Continue Playing"] >= greatest_votes)
						greatest_votes = choices["Continue Playing"]
				else if(mode == "gamemode")
					if(master_mode in choices)
						choices[master_mode] += non_voters
						if(choices[master_mode] >= greatest_votes)
							greatest_votes = choices[master_mode]
				else if(mode == "crew_transfer")
					var/factor = 0.5
					switch(world.time / (10 * 60)) // minutes
						if(0 to 60)
							factor = 0.5
						if(61 to 120)
							factor = 0.8
						if(121 to 240)
							factor = 1
						if(241 to 300)
							factor = 1.2
						else
							factor = 1.4
					choices["Initiate Crew Transfer"] = round(choices["Initiate Crew Transfer"] * factor)
					world << "<font color='purple'>Crew Transfer Factor: [factor]</font>"
					greatest_votes = max(choices["Initiate Crew Transfer"], choices["Continue The Round"])


		//get all options with that many votes and return them in a list
		. = list()
		if(greatest_votes)
			for(var/option in choices)
				if(choices[option] == greatest_votes)
					. += option
		return .

	proc/announce_result()
		var/list/winners = get_result()
		var/text
		if(winners.len > 0)
			if(winners.len > 1)
				text = "<b>Vote Tied Between:</b>\n"
				for(var/option in winners)
					text += "\t[option]\n"
			. = pick(winners)
			text += "<b>Vote Result: [.]</b>"
		else
			text += "<b>Vote Result: Inconclusive - No Votes!</b>"
		log_vote(text)
		world << "<font color='purple'>[text]</font>"
		return .

	proc/result()
		. = announce_result()
		var/restart = 0
		if(.)
			switch(mode)
				if("restart")
					if(. == "Restart Round")
						restart = 1
				if("gamemode")
					if(master_mode != .)
						world.save_mode(.)
						if(ticker && ticker.mode)
							restart = 1
						else
							master_mode = .
					if(!going)
						going = 1
						world << "<font color='red'><b>The round will start soon.</b></font>"
				if("crew_transfer")
					if(. == "Initiate Crew Transfer")
						init_shift_change(null, 1)


		if(restart)
			world << "World restarting due to vote..."
			feedback_set_details("end_error","restart vote")
			if(blackbox)	blackbox.save_all_data_to_sql()
			CallHook("Reboot",list())
			sleep(50)
			log_game("Rebooting due to restart vote")
			world.Reboot()

		return .

	proc/submit_vote(var/ckey, var/vote)
		if(mode)
			if(config.vote_no_dead && usr.stat == DEAD && !usr.client.holder)
				return 0
			if(current_votes[ckey])
				choices[choices[current_votes[ckey]]]--
			if(vote && 1<=vote && vote<=choices.len)
				voted += usr.ckey
				choices[choices[vote]]++	//check this
				current_votes[ckey] = vote
				return vote
		return 0

	proc/initiate_vote(var/vote_type, var/initiator_key)
		if(!mode)
			if(started_time != null && !check_rights(R_ADMIN))
				var/next_allowed_time = (started_time + config.vote_delay)
				if(next_allowed_time > world.time)
					return 0

			reset()
			switch(vote_type)
				if("restart")
					choices.Add("Restart Round","Continue Playing")
				if("gamemode")
					if(ticker.current_state >= 2)
						return 0
					choices.Add(config.votable_modes)
				if("crew_transfer")
					if(ticker.current_state <= 2)
						return 0
					question = "End the shift?"
					choices.Add("Initiate Crew Transfer", "Continue The Round")
				if("custom")
					question = html_encode(input(usr,"What is the vote for?") as text|null)
					if(!question)	return 0
					for(var/i=1,i<=10,i++)
						var/option = capitalize(html_encode(input(usr,"Please enter an option or hit cancel to finish") as text|null))
						if(!option || mode || !usr.client)	break
						choices.Add(option)
				else			return 0
			mode = vote_type
			initiator = initiator_key
			started_time = world.time
			var/text = "[capitalize(mode)] vote started by [initiator]."
			if(mode == "custom")
				text += "\n[question]"

			log_vote(text)
			world << "<font color='purple'><b>[text]</b>\nType vote to place your votes.\nYou have [config.vote_period/10] seconds to vote.</font>"
			switch(vote_type)
				if("crew_transfer")
					world << sound('sound/voice/Serithi/Shuttlehere.ogg')
				if("gamemode")
					world << sound('sound/voice/Serithi/pretenddemoc.ogg')
				if("custom")
					world << sound('sound/voice/Serithi/weneedvote.ogg')
			if(mode == "gamemode" && going)
				going = 0
				world << "<font color='red'><b>Round start has been delayed.</b></font>"

			time_remaining = round(config.vote_period/10)
			return 1
		return 0

	proc/interface(var/client/C)
		if(!C)	return
		var/admin = 0
		var/trialmin = 0
		if(C.holder)
			admin = 1
			if(C.holder.rights & R_ADMIN)
				trialmin = 1
		voting |= C

		. = "<html><head><title>Voting Panel</title></head><body>"
		if(mode)
			if(question)	. += "<h2>Vote: '[question]'</h2>"
			else			. += "<h2>Vote: [capitalize(mode)]</h2>"
			. += "Time Left: [time_remaining] s<hr><ul>"
			for(var/i = 1, i <= choices.len, i++)
				var/votes = choices[choices[i]]
				if(!votes)	votes = 0
				if(current_votes[C.ckey] == i)
					. += "<li><b><a href='?src=\ref[src];vote=[i]'>[choices[i]]</a> ([votes] votes)</b></li>"
				else
					. += "<li><a href='?src=\ref[src];vote=[i]'>[choices[i]]</a> ([votes] votes)</li>"

			. += "</ul><hr>"
			if(admin)
				. += "(<a href='?src=\ref[src];vote=cancel'>Cancel Vote</a>) "
		else
			. += "<h2>Start a vote:</h2><hr><ul><li>"
			//restart
			if(trialmin || config.allow_vote_restart)
				. += "<a href='?src=\ref[src];vote=restart'>Restart</a>"
			else
				. += "<font color='grey'>Restart (Disallowed)</font>"
			. += "</li><li>"
			if(trialmin || config.allow_vote_restart)
				. += "<a href='?src=\ref[src];vote=crew_transfer'>Crew Transfer</a>"
			else
				. += "<font color='grey'>Crew Transfer (Disallowed)</font>"
			if(trialmin)
				. += "\t(<a href='?src=\ref[src];vote=toggle_restart'>[config.allow_vote_restart?"Allowed":"Disallowed"]</a>)"
			. += "</li><li>"
			//gamemode
			if(trialmin || config.allow_vote_mode)
				. += "<a href='?src=\ref[src];vote=gamemode'>GameMode</a>"
			else
				. += "<font color='grey'>GameMode (Disallowed)</font>"
			if(trialmin)
				. += "\t(<a href='?src=\ref[src];vote=toggle_gamemode'>[config.allow_vote_mode?"Allowed":"Disallowed"]</a>)"

			. += "</li>"
			//custom
			if(trialmin)
				. += "<li><a href='?src=\ref[src];vote=custom'>Custom</a></li>"
			. += "</ul><hr>"
		. += "<a href='?src=\ref[src];vote=close' style='position:absolute;right:50px'>Close</a></body></html>"
		return .


	Topic(href,href_list[],hsrc)
		if(!usr || !usr.client)	return	//not necessary but meh...just in-case somebody does something stupid
		switch(href_list["vote"])
			if("close")
				voting -= usr.client
				usr << browse(null, "window=vote")
				return
			if("cancel")
				if(usr.client.holder)
					reset()
			if("toggle_restart")
				if(usr.client.holder)
					config.allow_vote_restart = !config.allow_vote_restart
			if("toggle_gamemode")
				if(usr.client.holder)
					config.allow_vote_mode = !config.allow_vote_mode
			if("restart")
				if(config.allow_vote_restart || usr.client.holder)
					initiate_vote("restart",usr.key)
			if("gamemode")
				if(config.allow_vote_mode || usr.client.holder)
					initiate_vote("gamemode",usr.key)
			if("crew_transfer")
				if(config.allow_vote_restart || usr.client.holder)
					initiate_vote("crew_transfer",usr.key)
			if("custom")
				if(usr.client.holder)
					initiate_vote("custom",usr.key)
			else
				submit_vote(usr.ckey, round(text2num(href_list["vote"])))
		usr.vote()


/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	if(vote)
		src << browse(vote.interface(client),"window=vote;can_close=0")
