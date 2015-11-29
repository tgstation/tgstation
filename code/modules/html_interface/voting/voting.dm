var/global/datum/controller/vote/vote = new()
#define vote_head "<script type=\"text/javascript\" src=\"3-jquery.timers.js\"></script><script type=\"text/javascript\" src=\"libraries.min.js\"></script><link rel=\"stylesheet\" type=\"text/css\" href=\"html_interface_icons.css\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"voting.css\" /><script type=\"text/javascript\" src=\"voting.js\"></script>"

#define VOTE_SCREEN_WIDTH 400
#define VOTE_SCREEN_HEIGHT 400


/datum/html_interface/nanotrasen/vote/registerResources()
	. = ..()

	register_asset("voting.js", 'voting.js')
	register_asset("voting.css", 'voting.css')

/datum/html_interface/nanotrasen/vote/sendAssets(var/client/client)
	..()

	send_asset(client, "voting.js")
	send_asset(client, "voting.css")

/datum/html_interface/nanotrasen/vote/Topic(href, href_list[])
	..()
	if(href_list["html_interface_action"] == "onclose")

		var/datum/html_interface_client/hclient = getClient(usr.client)
		if (istype(hclient))
			src.hide(hclient)
			vote.voting -= usr.client


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
	var/list/ismapvote
	var/chosen_map
	var/name = "datum"
	var/datum/html_interface/nanotrasen/vote/interface
	var/list/data
	var/list/status_data
	var/last_update = 0
	var/initialized = 0
	var/lastupdate = 0

/datum/controller/vote/New()
	. = ..()
	src.data = list()
	src.status_data = list()
	spawn(5)
		if(!src.interface)
			src.interface = new/datum/html_interface/nanotrasen/vote(src, "Voting Panel", 400, 400, vote_head)
			src.interface.updateContent("content", "<div id='vote_main'></div><div id='vote_choices'></div><div id='vote_admin'></div>")
		initialized = 1
	if (vote != src)
		if (istype(vote))
			qdel(vote)

		vote = src
//datum/controller/vote/proc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
//	return

/datum/controller/vote/proc/process()	//called by master_controller
	if(mode)
		// No more change mode votes after the game has started.
		// 3 is GAME_STATE_PLAYING, but that #define is undefined for some reason
		if(mode == "gamemode" && ticker.current_state >= 2)
			to_chat(world, "<b>Voting aborted due to game start.</b>")
			src.reset()
			return

		// Calculate how much time is remaining by comparing current time, to time of vote start,
		// plus vote duration
		time_remaining = (ismapvote && ismapvote.len) ? (round((started_time + 600 - world.time)/10)) : (round((started_time + config.vote_period - world.time)/10))

		if(time_remaining <= 0)
			result()
			for(var/client/C in voting)
				if(C)
					//nanomanager.close_user_uis(C.mob, src)
					src.interface.hide(C)
			src.reset()
		else
			update(1)
/datum/controller/vote/proc/reset()
	initiator = null
	time_remaining = 0
	mode = null
	question = null
	choices.len = 0
	voted.len = 0
	voting.len = 0
	current_votes.len = 0
	update(1)

/datum/controller/vote/proc/get_result()
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
				to_chat(world, "<font color='purple'>Crew Transfer Factor: [factor]</font>")
				greatest_votes = max(choices["Initiate Crew Transfer"], choices["Continue The Round"])


	//get all options with that many votes and return them in a list
	. = list()
	if(greatest_votes)
		for(var/option in choices)
			if(choices[option] == greatest_votes)
				. += option
	return .

/datum/controller/vote/proc/announce_result()
	var/list/winners = get_result()
	var/text
	var/feedbackanswer
	if(winners.len > 0)
		if(winners.len > 1)
			text = "<b>Vote Tied Between:</b><br>"
			for(var/option in winners)
				text += "\t[option]<br>"
			feedbackanswer = list2text(winners, " ")
		. = pick(winners)
		if(mode == "map")
			if(!feedbackanswer)
				feedbackanswer = .
				feedback_set("map vote winner", feedbackanswer)
			else
				feedback_set("map vote tie", "[feedbackanswer] chosen: [.]")

		text += "<b>Vote Result: [.] with [choices[.]] vote\s</b>"
		for(var/choice in choices)
			if(. == choice) continue
			text += "<br>\t [choice] had [choices[choice] != null ? choices[choice] : "0"] vote\s"
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	log_vote(text)
	to_chat(world, "<font color='purple'>[text]</font>")
	return .

/datum/controller/vote/proc/result()
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
					to_chat(world, "<font color='red'><b>The round will start soon.</b></font>")
			if("crew_transfer")
				if(. == "Initiate Crew Transfer")
					init_shift_change(null, 1)
			if("map")
				if(.)
					chosen_map = ismapvote[.]
					var/mapname = .
					watchdog.chosen_map = copytext(mapname,1,(length(mapname)))
					log_game("Players voted and chose.... [watchdog.chosen_map]!")
					//testing("Vote picked [chosen_map]")


	if(restart)
		to_chat(world, "World restarting due to vote...")
		feedback_set_details("end_error","restart vote")
		if(blackbox)	blackbox.save_all_data_to_sql()
		CallHook("Reboot",list())
		sleep(50)
		log_game("Rebooting due to restart vote")
		world.Reboot()

	return .

/datum/controller/vote/proc/submit_vote(var/ckey, var/vote)
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

/datum/controller/vote/proc/initiate_vote(var/vote_type, var/initiator_key, var/popup = 0)
	if(!mode)
		if(started_time != null && !check_rights(R_ADMIN))
			var/next_allowed_time = (started_time + config.vote_delay)
			if(next_allowed_time > world.time)
				return 0

		reset()
		switch(vote_type)
			if("restart")
				choices.Add("Restart Round","Continue Playing")
				question = "Restart the round?"
			if("gamemode")
				if(ticker.current_state >= 2)
					return 0
				choices.Add(config.votable_modes)
				question = "What gamemode?"
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
			if("map")
				question = "What should the next map be?"
				var/list/maps = get_maps()
				for(var/key in maps)
					choices.Add(key)
				if(!choices.len)
					to_chat(world, "<span class='danger'>Failed to initiate map vote, no maps found.</span>")
					return 0
				ismapvote = maps
			else
				return 0
		mode = vote_type
		initiator = initiator_key
		started_time = world.time
		var/text = "[capitalize(mode)] vote started by [initiator]."
		choices = shuffle(choices)
		if(mode == "custom")
			text += "<br>[question]"

		log_vote(text)
		update(1)
		if(popup)
			for(var/client/C in clients)
				interact(C)
		else
			if(istype(usr) && usr.client)
				interact(usr.client)
		to_chat(world, "<font color='purple'><b>[text]</b><br>Type vote to place your votes.<br>You have [ismapvote && ismapvote.len ? "60" : config.vote_period/10] seconds to vote.</font>")
		switch(vote_type)
			if("crew_transfer")
				to_chat(world, sound('sound/voice/Serithi/Shuttlehere.ogg'))
			if("gamemode")
				to_chat(world, sound('sound/voice/Serithi/pretenddemoc.ogg'))
			if("custom")
				to_chat(world, sound('sound/voice/Serithi/weneedvote.ogg'))
			if("map")
				to_chat(world, sound('sound/misc/rockthevote.ogg'))
		if(mode == "gamemode" && going)
			going = 0
			to_chat(world, "<font color='red'><b>Round start has been delayed.</b></font>")

		time_remaining = (ismapvote && ismapvote.len ? 60 : round(config.vote_period/10))
		return 1
	return 0

/datum/controller/vote/proc/updateFor(hclient_or_mob)
	// This check will succeed if updateFor is called after showing to the player, but will fail
	// on regular updates. Since we only really need this once we don't care if it fails.

	interface.callJavaScript("clearAll", new/list(), hclient_or_mob)
	interface.callJavaScript("update_mode", status_data, hclient_or_mob)
	if(data.len)
		for (var/list/L in data)
			interface.callJavaScript("update_choices", L, hclient_or_mob)


/datum/controller/vote/proc/interact(client/user)
	if(!user || !initialized)
		return
	if(ismob(user)) user = user:client
	voting |= user
	interface.show(user)
	var/list/client_data = list()
	var/admin = 0
	var/currvote = 0
	if(current_votes[user.ckey])
		currvote = current_votes[user.ckey]
	client_data[++client_data.len] = (currvote)
		//interface.callJavascript("current_vote", current_votes[user.ckey])
	if(user.holder)
		admin = 1
		if(user.holder.rights & R_ADMIN)
			admin = 2
	client_data[++client_data.len] = (admin)
	interface.callJavaScript("client_data", client_data, user)
	src.updateFor(user, interface)


/datum/controller/vote/proc/update(refresh = 0)
	if(!interface)
		interface = new/datum/html_interface/nanotrasen/vote(src, "Voting Panel", 400, 400, vote_head)
		interface.updateContent("content", "<div id='vote_main'></div><div id='vote_choices'></div><div id='vote_admin'></div>")

	if(world.time < last_update + 2)
		return
	last_update = world.time
	status_data.len = 0
	status_data[++status_data.len] = mode
	status_data[++status_data.len] = question
	status_data[++status_data.len] = time_remaining
	if(config.allow_vote_restart)
		status_data[++status_data.len] = 1
	else
		status_data[++status_data.len] = 0
	if(config.allow_vote_mode)
		status_data[++status_data.len] = 1
	else
		status_data[++status_data.len] = 0

	var/list/choices_list = list()
	if(mode)
		for(var/i = 1; i <= choices.len; i++)
			choices_list[++choices_list.len] = list(i, choices[i], (!isnull(choices[choices[i]]) ? choices[choices[i]] : 0))
	data = choices_list
	if(refresh && interface) updateFor()


/datum/controller/vote/Topic(href,href_list[],hsrc)
	if(!usr || !usr.client)	return	//not necessary but meh...just in-case somebody does something stupid
	switch(href_list["vote"])
		if("cancel")
			if(usr.client.holder)
				reset()
				update()
		if("toggle_restart")
			if(usr.client.holder)
				config.allow_vote_restart = !config.allow_vote_restart
				update()
		if("toggle_gamemode")
			if(usr.client.holder)
				config.allow_vote_mode = !config.allow_vote_mode
				update()
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
		if(!vote.initialized) to_chat(usr, "<span class='info'>The voting controller isn't fully initialized yet.</span>")
		else vote.interact(usr.client)
