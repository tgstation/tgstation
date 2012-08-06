/datum/vote/New()

	nextvotetime = world.timeofday // + 10*config.vote_delay


/datum/vote/proc/canvote()//marker1
	var/excess = world.timeofday - vote.nextvotetime

	if(excess < -10000)		// handle clock-wrapping problems - very long delay (>20 hrs) if wrapped
		vote.nextvotetime = world.timeofday
		return 1
	return (excess >= 0)

/datum/vote/proc/nextwait()
	return timetext( round( (nextvotetime - world.timeofday)/10) )

/datum/vote/proc/endwait()
	return timetext( round( (votetime - world.timeofday)/10) )

/datum/vote/proc/timetext(var/interval)
	var/minutes = round(interval / 60)
	var/seconds = round(interval % 60)

	var/tmin = "[minutes>0?num2text(minutes)+"min":null]"
	var/tsec = "[seconds>0?num2text(seconds)+"sec":null]"

	if(tmin && tsec)				// hack to skip inter-space if either field is blank
		return "[tmin] [tsec]"
	else
		if(!tmin && !tsec)		// return '0sec' if 0 time left
			return "0sec"
		return "[tmin][tsec]"

/datum/vote/proc/getvotes()
	var/list/L = list()
	for(var/mob/M in world)
		if(M.client && M.client.inactivity < 1200)		// clients inactive for 2 minutes don't count
			L[M.client.vote] += 1

	return L


/datum/vote/proc/endvote()

	if(!voting)		// means that voting was aborted by an admin
		return

	world << "\red <B>***Voting has closed.</B>"

	log_vote("Voting closed, result was [winner]")
	voting = 0
	nextvotetime = world.timeofday + 10*config.vote_delay

	for(var/mob/M in world)		// clear vote window from all clients
		if(M.client)
			M << browse(null, "window=vote")
			M.client.showvote = 0

	calcwin()

	if(!winner || winner == "" || winner == "none")
		winner = "default"

	if(mode == 2)
		var/wintext = capitalize(winner)
		world << "Result is [wintext]"
		for(var/md in vote.choices)
			vote.choices -= md
		return

	else if(mode == 1)
		if(ticker.current_state == 1)
			if(!going)
				world << "<B>The game will start soon.</B>"
				going = 1
		var/wintext = capitalize(winner)
		if(winner=="default")
			world << "Result is \red No change."
			return

		// otherwise change mode


		world << "Result is change to \red [wintext]"
		world.save_mode(winner)

		if(ticker && ticker.mode)
			world <<"\red <B>World will reboot in 10 seconds</B>"

			//feedback_set_details("end_error","mode vote - [winner]")

			if(blackbox)
				blackbox.save_all_data_to_sql()

			sleep(100)
			log_game("Rebooting due to mode vote")
			world.Reboot()
		else
			master_mode = winner

	else

		if(winner=="default")
			world << "Result is \red No restart."
			return

		world << "Result is \red Restart round."

		if(vote.instant_restart)
			world <<"\red <B>World will reboot in 5 seconds</B>"

			//feedback_set_details("end_error","restart vote")

			if(blackbox)
				blackbox.save_all_data_to_sql()

			sleep(50)
			log_game("Rebooting due to restart vote")
			world.Reboot()
		else
			// Call the shift change shuttle instead, the 1 is to force the shuttle to come
			init_shift_change(null, 1)
	return


/datum/vote/proc/calcwin()

	var/list/votes = getvotes()

	if(vote.mode)
		var/best = -1

		for(var/v in votes)
			if(v=="none"||v=="default")
				continue
			if(best < votes[v])
				best = votes[v]


		var/list/winners = list()

		for(var/v in votes)
			if(votes[v] == best && v != "default" && v != "none")
				winners += v

		var/ret = ""


		for(var/w in winners)
			if(lentext(ret) > 0)
				ret += "/"
			if(w=="default")
				winners = list("default")
				ret = "No change"
				break
			else
				ret += capitalize(w)



		if(winners.len != 1)
			ret = "Tie: " + ret


		if(winners.len == 0)
			vote.winner = "default"
			ret = "No change"
		else
			vote.winner = pick(winners)

		return ret
	else

		if(votes["default"] < votes["restart"])

			vote.winner = "restart"
			return "Restart"
		else
			vote.winner = "default"
			return "No restart"


/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"
	usr.client.showvote = 1


	var/text = "<HTML><HEAD><TITLE>Voting</TITLE></HEAD><BODY scroll=no>"

	var/footer = "<HR><A href='?src=\ref[vote];vclose=1'>Close</A></BODY></HTML>"


	if(config.vote_no_dead && usr.stat == 2)
		text += "Voting while dead has been disallowed."
		text += footer
		usr << browse(text, "window=vote")
		usr.client.showvote = 0
		usr.client.vote = "none"
		return

	if(vote.voting)
		// vote in progress, do the current

		var/list/votes = vote.getvotes()
		if(vote.mode == 2)
			text += "A custom vote is in progress.<BR>"
			text += "[vote.endwait()] until voting is closed.<BR>"
			text += "[vote.customname]"

			for(var/md in vote.choices)
				var/disp = capitalize(md)
				if(md=="default")
					disp = "No change"

				//world << "[md]|[disp]|[src.client.vote]|[votes[md]]"

				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];vote=[md]'>[disp]</A>"

				text += "[votes[md]>0?" - [votes[md]] vote\s":null]<BR>"

			text += "</UL>"

			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"

			text += footer

			usr << browse(text, "window=vote")

		else if(vote.mode == 1)		// true if changing mode

			text += "Vote to change mode in progress.<BR>"
			text += "[vote.endwait()] until voting is closed.<BR>"

			text += "Current game mode is: <B>[master_mode]</B>.<BR>Select the mode to change to:<UL>"

			for(var/md in config.votable_modes)
				var/disp = capitalize(md)
				if(md=="default")
					disp = "No change"

				//world << "[md]|[disp]|[src.client.vote]|[votes[md]]"

				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];vote=[md]'>[disp]</A>"

				text += "[votes[md]>0?" - [votes[md]] vote\s":null]<BR>"

			text += "</UL>"

			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"

			text += footer

			usr << browse(text, "window=vote")

		else	// voting to restart
			text += "Vote to call crew transfer shuttle round in progress.<BR>"
			text += "[vote.endwait()] until voting is closed.<BR>"

			if(vote.instant_restart)
				text += "Restart the world? <B><font color='red'>ONLY PRESS THIS IF THERE'S A ROUND-BREAKING GLITCH.</font></B><BR>"
			else
				text += "Call the Crew Transfer Shuttle?<BR>"

			text += "<B><font color=red>*** Please make sure to only vote 'no' if you yourself are currently enjoying the round. If you find the round to have gone stale, you should always vote 'yes', regardless of how others are feeling about the round.</font></B><BR><UL>"

			var/list/VL = list("default","restart")

			for(var/md in VL)
				var/disp = (md=="default"? "No":"Yes")

				if(src.client.vote == md)
					text += "<LI><B>[disp]</B>"
				else
					text += "<LI><A href='?src=\ref[vote];vote=[md]'>[disp]</A>"

				text += "[votes[md]>0?" - [votes[md]] vote\s":null]<BR>"

			text += "</UL>"

			text +="<p>Current winner: <B>[vote.calcwin()]</B><BR>"

			text += footer

			usr << browse(text, "window=vote")


	else		//no vote in progress

		if(shuttlecoming == 1)
			usr << "\blue Cannot start Vote - Shuttle has been called."
			return

		if(!config.allow_vote_restart && !config.allow_vote_mode)
			text += "<P>Player voting is disabled.</BODY></HTML>"

			usr << browse(text, "window=vote")
			usr.client.showvote = 0
			return

		if(!vote.canvote())		// not time to vote yet
			if(config.allow_vote_restart) text+="Voting to restart is enabled.<BR>"
			if(config.allow_vote_mode)
				if(ticker.current_state == 1) text+="Voting to change mode is enabled.<BR>"
				else text += "Change mode votes are disabled while a round is in progress, vote to restart first.<BR>"

			text+="<BR><P>Next vote can begin in [vote.nextwait()]."
			text+=footer

			usr << browse(text, "window=vote")

		else			// voting can begin
			if(config.allow_vote_restart)
				text += "<A href='?src=\ref[vote];vmode=1'>Begin restart vote.</A><BR>"
			if(config.allow_vote_mode)
				if(!ticker || ticker.current_state == 1)
					text += "<A href='?src=\ref[vote];vmode=2'>Begin change mode vote.</A><BR>"
				else
					text += "Change mode votes are disabled while a round is in progress, vote to restart first.<BR>"
			if(src.client.holder)			//Strumpetplaya Add - Custom Votes for Admins
				text += "<A href='?src=\ref[vote];vmode=3'>Begin custom vote.</A><BR>"
			text += footer
			usr << browse(text, "window=vote")

	spawn(20)
		if(usr.client && usr.client.showvote && !vote.enteringchoices)
			usr.vote()
		else
			usr << browse(null, "window=vote")

		return


/datum/vote/Topic(href, href_list)
	..()
	//world << "[usr] has activated the vote Topic"

	if(href_list["voter"])
		world << "[usr.ckey] has attempted to bypass the voting system." //ckey is easy key
		return

	if(href_list["vclose"])

		if(usr)
			usr << browse(null, "window=vote")
			usr.client.showvote = 0
		return

	if(href_list["vmode"])
		if(vote.voting)
			return

		if(!vote.canvote() )	// double check even though this shouldn't happen
			return

		vote.mode = text2num(href_list["vmode"])-1 	// hack to yield 0=restart, 1=changemode

		if(vote.mode == 2)
			vote.enteringchoices = 1
			vote.voting = 1
			vote.customname = input(usr, "What are you voting for?", "Custom Vote") as text
			if(!vote.customname)
				vote.enteringchoices = 0
				vote.voting = 0
				return

			var/N = input(usr, "How many options does this vote have?", "Custom Vote", 0) as num
			if(!N)
				vote.enteringchoices = 0
				vote.voting = 0
				return
			//world << "You're voting for [N] options!"
			var/i
			vote.choices = list()
			for(i=1; i<=N; i++)
				var/addvote = input(usr, "What is option #[i]?", "Enter Option #[i]") as text
				vote.choices += addvote
			//for(var/O in vote.choices)
				//world << "[O]"
			vote.enteringchoices = 0
			vote.votetime = world.timeofday + config.vote_period*10	// when the vote will end

			spawn(config.vote_period * 10)
				vote.endvote()

			world << "\red<B>*** A custom vote has been initiated by [usr.key].</B>"
			world << "\red     You have [vote.timetext(config.vote_period)] to vote."

			//log_vote("Voting to [vote.mode ? "change mode" : "restart round"] started by [M.name]/[M.key]")

			for(var/client/C)
				if(config.vote_no_default || (config.vote_no_dead && C.mob.stat == 2))
					C.vote = "none"
				else
					C.vote = "default"

			if(usr) usr.vote()
			return

		if(vote.mode == 0)
			var/answer = alert(usr,"Do you want to force an immediate restart? Only do this when there are round-breaking glitches, or risk being banned.","Immediate Reboot?","Yes","No")

			if(answer == "Yes")
				vote.instant_restart = 1
				log_admin("[usr.key] has initiated an instant reboot vote! This may be banworthy!")
				message_admins("[usr.key] has initiated an instant reboot vote! This may be banworthy!")
			else
				vote.instant_restart = 0

		if(!ticker && vote.mode == 1)
			if(going)
				world << "<B>The game start has been delayed.</B>"
				going = 0
		vote.voting = 1						// now voting
		vote.votetime = world.timeofday + config.vote_period*10	// when the vote will end

		spawn(config.vote_period*10)
			vote.endvote()

		world << "\red<B>*** A vote to [vote.mode?"change game mode":"restart"] has been initiated by [usr.key].</B>"
		world << "\red     You have [vote.timetext(config.vote_period)] to vote."

		log_vote("Voting to [vote.mode ? "change mode" : "restart round"] started by [usr.name]/[usr.key]")

		for(var/mob/CM in world)
			if(CM.client)
				if( config.vote_no_default || (config.vote_no_dead && CM.stat == 2) )
					CM.client.vote = "none"
				else
					CM.client.vote = "default"

		if(usr) usr.vote()
		return


		return

	if(href_list["vote"] && vote.voting)
		if(usr)
			usr.client.vote = href_list["vote"]

			//world << "Setting client [usr.key]'s vote to: [href_list["vote"]]."

			usr.vote()
		return

proc/automatic_crew_shuttle_vote()

	if(vote.voting)
		return

	if(!vote.canvote() )	// double check even though this shouldn't happen
		return

	vote.mode = 0
	vote.instant_restart = 0

	vote.voting = 1						// now voting
	vote.votetime = world.timeofday + config.vote_period*10	// when the vote will end

	spawn(config.vote_period*10)
		vote.endvote()

	world << "\red<B>*** An *automatic* vote to call the crew transfer shuttle has been initiated.</B>"
	world << "\red     You have [vote.timetext(config.vote_period)] to vote."

	log_vote("Automatic vote to call the crew transfer shuttle.")

	for(var/mob/CM in world)
		if(CM.client)
			if( !CM.is_player_active() )
				CM.client.vote = "none"
			else
				CM.client.vote = "none"

	return