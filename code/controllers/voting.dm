var/datum/controller/vote/vote = new()

datum/controller/vote
	var/initiator = null
	var/started_timeofday = null
	var/time_remaining = 0
	var/mode = null
	var/question = null
	var/list/choices = list()
	var/list/voted = list()
	var/list/voting = list()

	New()
		if(vote != src)
			if(istype(vote))
				del(vote)
			vote = src

	proc/process()	//called by master_controller
		if(mode)
			time_remaining = started_timeofday + config.vote_period
			if(world.timeofday < started_timeofday)
				time_remaining -= 864000
			time_remaining = round((time_remaining - world.timeofday)/10)

			var/i=1
			if(time_remaining < 0)
				result()
				while(i<=voting.len)
					var/client/C = voting[i]
					if(C)
						C << browse(null,"window=vote;can_close=0")
					i++
				reset()
			else
				while(i<=voting.len)
					var/client/C = voting[i]
					if(C)
						C << browse(vote.interface(C),"window=vote;can_close=0")
						i++
					else
						voting.Cut(i,i+1)

	proc/reset()
		initiator = null
		time_remaining = 0
		mode = null
		question = null
		choices.Cut()
		voted.Cut()
		voting.Cut()

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
			var/non_voters = (client_list.len - total_votes)
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

		if(restart)
			world << "World restarting due to vote..."
			feedback_set_details("end_error","restart vote")
			if(blackbox)	blackbox.save_all_data_to_sql()
			sleep(50)
			log_game("Rebooting due to restart vote")
			world.Reboot()

		return .

	proc/submit_vote(var/vote)
		if(mode)
			if(config.vote_no_dead && usr.stat == DEAD && !usr.client.holder)
				return 0
			if(!(usr.ckey in voted))
				if(vote && 1<=vote && vote<=choices.len)
					voted += usr.ckey
					choices[choices[vote]]++	//check this
					return vote
		return 0

	proc/initiate_vote(var/vote_type, var/initiator_key)
		if(!mode)
			if(started_timeofday != null)
				var/next_allowed_timeofday = (started_timeofday + config.vote_delay)
				if(world.timeofday < started_timeofday)
					next_allowed_timeofday -= 864000
				if(next_allowed_timeofday > world.timeofday)
					return 0

			reset()
			switch(vote_type)
				if("restart")	choices.Add("Restart Round","Continue Playing")
				if("gamemode")	choices.Add(config.votable_modes)
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
			started_timeofday = world.timeofday
			var/text = "[capitalize(mode)] vote started by [initiator]."
			log_vote(text)
			world << "<font color='purple'><b>[text]</b>\nType vote to place your votes.\nYou have [config.vote_period/10] seconds to vote.</font>"
			time_remaining = round(config.vote_period/10)
			return 1
		return 0

	proc/interface(var/client/C)
		if(!C)	return
		var/admin = 0
		if(C.holder)
			admin = 1
		voting |= C

		. = "<html><head><title>Voting Panel</title></head><body>"
		if(mode)
			if(question)	. += "<h2>Vote: '[question]'</h2>"
			else			. += "<h2>Vote: [capitalize(mode)]</h2>"
			. += "Time Left: [time_remaining] s<hr><ul>"
			for(var/i=1,i<=choices.len,i++)
				var/votes = choices[choices[i]]
				if(!votes)	votes = 0
				. += "<li><a href='?src=\ref[src];vote=[i]'>[choices[i]]</a> ([votes] votes)</li>"
			. += "</ul><hr>"
			if(admin)
				. += "(<a href='?src=\ref[src];vote=cancel'>Cancel Vote</a>) "
		else
			. += "<h2>Start a vote:</h2><hr><ul><li>"
			//restart
			if(admin || config.allow_vote_restart)
				. += "<a href='?src=\ref[src];vote=restart'>Restart</a>"
			else
				. += "<font color='grey'>Restart (Disallowed)</font>"
			if(admin)
				. += "\t(<a href='?src=\ref[src];vote=toggle_restart'>[config.allow_vote_restart?"Allowed":"Disallowed"]</a>)"
			. += "</li><li>"
			//gamemode
			if(admin || config.allow_vote_mode)
				. += "<a href='?src=\ref[src];vote=gamemode'>GameMode</a>"
			else
				. += "<font color='grey'>GameMode (Disallowed)</font>"
			if(admin)
				. += "\t(<a href='?src=\ref[src];vote=toggle_gamemode'>[config.allow_vote_mode?"Allowed":"Disallowed"]</a>)"

			. += "</li>"
			//custom
			if(admin)
				. += "<li><a href='?src=\ref[src];vote=custom'>Custom</a></li>"
			. += "</ul><hr>"
		. += "<a href='?src=\ref[src];vote=close' style='position:absolute;right:50px'>Close</a></body></html>"
		return .


	Topic(href,href_list[],hsrc)
		if(!usr || !usr.client)	return	//not necessary but meh...just in-case somebody does something stupid
		switch(href_list["vote"])
			if("close")
				voting -= usr.ckey
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
			if("custom")
				if(usr.client.holder)
					initiate_vote("custom",usr.key)
			else
				submit_vote(round(text2num(href_list["vote"])))
		usr.vote()


/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	if(vote)
		src << browse(vote.interface(client),"window=vote;can_close=0")