/datum/controller/gameticker/proc/scoreboard(var/completions)


	//Calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if(findtext("[handler]","auto_declare_completion_"))
			completions += "[call(mode, handler)()]"

	completions += "<br>[ert_declare_completion()]"
	completions += "<br>[deathsquad_declare_completion()]"

	if(bomberman_mode)
		completions += "<br>[bomberman_declare_completion()]"

	if(achievements.len)
		completions += "<br>[achievement_declare_completion()]"

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//If they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	//Score Calculation and Display

	//Run through humans for diseases, also the Clown
	for(var/mob/living/carbon/human/I in mob_list)
		if(I.viruses) //Do this guy have any viruses ?
			for(var/datum/disease/D in I.viruses) //Alright, start looping through those viruses
				score["disease"]++ //One point for every disease

		if(I.job == "Clown")
			for(var/thing in I.attack_log)
				if(findtext(thing, "<font color='orange'>")) //I just dropped 10 IQ points from seeing this
					score["clownabuse"]++

	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/T = get_turf(player)
			if(!T) continue

			if(istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
				score["escapees"]++
//					player.unlock_medal("100M Dash", 1)
//				player.unlock_medal("Survivor", 1)
//				for(var/obj/item/weapon/gnomechompski/G in player.get_contents())
//					player.unlock_medal("Guardin' gnome", 1)

				var/cashscore = 0
				var/dmgscore = 0


				for(var/obj/item/weapon/card/id/C1 in get_contents_in_object(player, /obj/item/weapon/card/id))
					cashscore += C1.GetBalance()

				for(var/obj/item/weapon/spacecash/C2 in get_contents_in_object(player, /obj/item/weapon/spacecash))
					cashscore += (C2.amount * C2.worth)

//					for(var/datum/data/record/Ba in data_core.bank)
//						if(Ba.fields["name"] == E.real_name)
//							cashscore += Ba.fields["current_money"]
				if(cashscore > score["richestcash"])
					score["richestcash"] = cashscore
					score["richestname"] = player.real_name
					score["richestjob"] = player.job
					score["richestkey"] = player.key
				dmgscore = player.bruteloss + player.fireloss + player.toxloss + player.oxyloss
				if(dmgscore > score["dmgestdamage"])
					score["dmgestdamage"] = dmgscore
					score["dmgestname"] = player.real_name
					score["dmgestjob"] = player.job
					score["dmgestkey"] = player.key

	/*

	var/nukedpenalty = 1000
	if(ticker.mode.config_tag == "nuclear")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
			if(!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if(T && istype(T.loc, /area/security/brig))
				score["arrested"]++
			else if(M.current.stat == DEAD)
				score["opkilled"]++
		if(foecount == score["arrested"])
			score["allarrested"] = 1

		score["disc"] = 1
		for(var/obj/item/weapon/disk/nuclear/A in world)
			if(A.loc != /mob/living/carbon) continue
			var/turf/location = get_turf(A.loc)
			var/area/bad_zone1 = locate(/area)
			var/area/bad_zone2 = locate(/area/syndicate_station)
			var/area/bad_zone3 = locate(/area/wizard_station)
			if(location in bad_zone1)
				score["disc"] = 0
			if(location in bad_zone2)
				score["disc"] = 0
			if(location in bad_zone3)
				score["disc"] = 0
			if(A.loc.z != 1)
				score["disc"] = 0

		if(score["nuked"])
			nukedpenalty = 50000 //Congratulations, your score was nuked

			for(var/obj/machinery/nuclearbomb/nuke in machines)
				if(nuke.r_code == "Nope")
					continue
				var/turf/T = get_turf(nuke)
				if(istype(T, /area/syndicate_station) || istype(T, /area/wizard_station) || istype(T, /area/solar))
					nukedpenalty = 1000
				else if(istype(T, /area/security/main) || istype(T, /area/security/brig) || istype(T, /area/security/armory) || istype(T, /area/security/checkpoint2))
					nukedpenalty = 50000
				else if(istype(T, /area/engine))
					nukedpenalty = 100000
				else
					nukedpenalty = 10000


	if(ticker.mode.config_tag == "revolution")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			foecount++
			if(!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if(istype(T.loc, /area/security/brig))
				score["arrested"]++
			else if (M.current.stat == DEAD)
				score["opkilled"]++
		if(foecount == score["arrested"])
			score["allarrested"] = 1
		for(var/mob/living/carbon/human/player in mob_list)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if(player.stat == DEAD)
						score["deadcommand"]++

	*/

	//Check station's power levels
	var/skip_power_loss = 0
	for(var/datum/event/grid_check/check in events)
		if(check.activeFor > check.startWhen && check.activeFor < check.endWhen)
			skip_power_loss = 1
	if(!skip_power_loss)
		for(var/obj/machinery/power/apc/A in power_machines)
			if(A.z != map.zMainStation)
				continue
			for(var/obj/item/weapon/cell/C in A.contents)
				if(C.percent() < 30)
					score["powerloss"]++ //Enough to auto-cut equipment, so alarm

	var/roundlength = world.time/10 //Get a value in seconds
	score["time"] = round(roundlength) //One point for every five seconds. One minute is 12 points, one hour 720 points

	//Check how many uncleaned mess are on the station. We can't run through cleanable for reasons, so yeah, long
	for(var/obj/effect/decal/cleanable/M in decals)
		if(M.z != map.zMainStation) //Won't work on multi-Z stations, but will do for now
			continue
		if(M.messcheck())
			score["mess"]++

	for(var/obj/item/trash/T in trash_items)
		if(T.z != map.zMainStation) //Won't work on multi-Z stations, but will do for now
			continue
		score["litter"]++

	//Bonus Modifiers
	//var/traitorwins = score["traitorswon"]
	var/deathpoints = score["deadcrew"] * 250 //Human beans aren't free
	var/siliconpoints = score["deadsilicon"] * 500 //Silicons certainly aren't either
	//var/researchpoints = score["researchdone"] * 20 //One discovered design is 20 points. You'll usually find hundreds
	var/eventpoints = score["eventsendured"] * 200 //Events fine every 10 to 15 and are uncommon
	var/escapoints = score["escapees"] * 100 //Two rescued human beans are worth a dead one
	var/harvests = score["stuffharvested"] * 1 //One harvest is one product. So 5 wheat is 5 points
	//var/shipping = score["stuffshipped"] * 5 //Does not work currently
	var/mining = score["oremined"] * 1 //Not actually counted at mining, but at processing. One ore smelted is one point
	var/meals = score["meals"] * 5 //Every item cooked (needs to fire make_food()) awards five points
	//var/drinks = score["drinks"] * 5 //All drinks that ever existed award five points. No better way to do it yet
	var/power = score["powerloss"] * 50 //Power issues are BAD, they mean the Engineers aren't doing their job at all
	var/litter = score["litter"] //Every item listed under /obj/item/trash will cost one point if it exists
	var/time = round(score["time"] * 0.2) //Every five seconds the station survives is one point. One minute is 12, one hour 720
	var/messpoints
	//var/atmos
	if(score["mess"] != 0)
		messpoints = score["mess"] //If there are any messes, let's count them
	//if(score["airloss"] != 0)
		//atmos = score["airloss"] * 20 //Air issues are bad, but since it's space, don't stress it too much
	var/plaguepoints = score["disease"] * 50 //A diseased crewman is half-dead, as they say, and a double diseased is double half-dead

	//Mode Specific
	if(ticker.mode.config_tag == "nuclear")
		if(score["disc"])
			score["crewscore"] += 500
		var/killpoints = score["opkilled"] * 250
		var/arrestpoints = score["arrested"] * 1000
		score["crewscore"] += killpoints
		score["crewscore"] += arrestpoints
		//if(score["nuked"])
			//score["crewscore"] -= nukedpenalty

	if(ticker.mode.config_tag == "revolution")
		var/arrestpoints = score["arrested"] * 1000
		var/killpoints = score["opkilled"] * 500
		var/comdeadpts = score["deadcommand"] * 500
		if(score["traitorswon"])
			score["crewscore"] -= 10000
		score["crewscore"] += arrestpoints
		score["crewscore"] += killpoints
		score["crewscore"] -= comdeadpts

	//Good Things
	//score["crewscore"] += shipping
	score["crewscore"] += harvests
	score["crewscore"] += mining
	score["crewscore"] += eventpoints
	score["crewscore"] += escapoints
	score["crewscore"] += meals
	score["crewscore"] += time

	if(!power) //No APCs with bad power
		score["crewscore"] += 2500 //Give the Engineers a pat on the back for bothering
		score["powerbonus"] = 1
	if(!messpoints && !litter) //Not a single mess or litter on station
		score["crewscore"] += 10000 //Congrats, not even a dirt patch or chips bag anywhere
		score["messbonus"] = 1
	//if(!atmos) //No air alarms anywhere
		//score["crewscore"] += 5000 //Give the Atmospheric Technicians a good pat on the back for caring
		//score["atmosbonus"] = 1
	if(score["allarrested"])
		score["crewscore"] *= 3 //This needs to be here for the bonus to be applied properly

	//Bad Things
	score["crewscore"] -= deathpoints
	score["crewscore"] -= siliconpoints
	if(score["deadaipenalty"])
		score["crewscore"] -= 1000 //Give a harsh punishment for killing the AI
	score["crewscore"] -= power
	//score["crewscore"] -= atmos
	//if(score["crewscore"] != 0) //Dont divide by zero!
	//	while(traitorwins > 0)
	//		score["crewscore"] /= 2
	//		traitorwins -= 1
	score["crewscore"] -= messpoints
	score["crewscore"] -= litter
	score["crewscore"] -= plaguepoints
	score["arenafights"] = arena_rounds

	arena_top_score = 0
	for(var/x in arena_leaderboard)
		if(arena_leaderboard[x] > arena_top_score)
			arena_top_score = arena_leaderboard[x]
	for(var/x in arena_leaderboard)
		if(arena_leaderboard[x] == arena_top_score)
			score["arenabest"] += "[x] "

	//Show the score - might add "ranks" later
	to_chat(world, "<b>The crew's final score is:</b>")
	to_chat(world, "<b><font size='4'>[score["crewscore"]]</font></b>")

	for(var/mob/E in player_list)
		if(E.client)
			E.scorestats(completions)
			winset(E.client, "rpane.round_end", "is-visible=true")
	return

/mob/proc/scorestats(var/completions)
	var/dat = completions
	dat += {"<BR><h2>Round Statistics and Score</h2>"}

	/*

	if(ticker.mode.name == "nuclear emergency")
		var/foecount = 0
		var/crewcount = 0
		var/diskdat = ""
		var/bombdat = null
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
		for(var/mob/living/C in mob_list)
			if(!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai))
				continue
			if(C.stat == DEAD)
				continue
			if(!C.client)
				continue
			crewcount++

		for(var/obj/item/weapon/disk/nuclear/N in world)
			if(!N)
				continue
			var/atom/disk_loc = N.loc
			while(!istype(disk_loc, /turf))
				if(istype(disk_loc, /mob))
					var/mob/M = disk_loc
					diskdat += "Carried by [M.real_name] "
				if(istype(disk_loc, /obj))
					var/obj/O = disk_loc
					diskdat += "in \a [O.name] "
				disk_loc = disk_loc.loc
			diskdat += "in [disk_loc.loc]"
			break // Should only need one go-round, probably

		for(var/obj/machinery/nuclearbomb/nuke in machines)
			if(nuke.r_code == "Nope")
				continue
			var/turf/T = NUKE.loc
			bombdat = T.loc
			if(istype(T,/area/syndicate_station) || istype(T,/area/wizard_station) || istype(T,/area/solar/) || istype(T,/area))
				nukedpenalty = 1000
			else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armory) || istype(T,/area/security/checkpoint2))
				nukedpenalty = 50000
			else if (istype(T,/area/engine))
				nukedpenalty = 100000
			else
				nukedpenalty = 10000
			break
		if(!diskdat)
			diskdat = "Uh oh. Something has fucked up! Report this."

		<B>Final Location of Nuke:</B> [bombdat]<BR>
		<B>Final Location of Disk:</B> [diskdat]<BR><BR>

		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Operatives:</B> [foecount]<BR>
		<B>Number of Surviving Crew:</B> [crewcount]<BR>
		<B>Final Location of Nuke:</B> [bombdat]<BR>
		<B>Final Location of Disk:</B> [diskdat]<BR><BR>
		<B>Operatives Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
		<B>Operatives Killed:</B> [score["opkilled"]] ([score["opkilled"] * 250] Points)<BR>
		<B>Station Destroyed:</B> [score["nuked"] ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
		<B>All Operatives Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}
//		<B>Nuclear Disk Secure:</B> [score["disc"] ? "Yes" : "No"] ([score["disc"] * 500] Points)<BR>

	if(ticker.mode.name == "revolution")
		var/foecount = 0
		var/comcount = 0
		var/revcount = 0
		var/loycount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			if(M.current && M.current.stat != 2)
				foecount++
		for(var/datum/mind/M in ticker.mode:revolutionaries)
			if(M.current && M.current.stat != 2)
				revcount++
		for(var/mob/living/carbon/human/player in mob_list)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if(player.stat != 2)
						comcount++
				else
					if(player.mind in ticker.mode:revolutionaries)
						continue
					loycount++
		for(var/mob/living/silicon/X in mob_list)
			if (X.stat != 2)
				loycount++
		var/revpenalty = 10000

		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
		<B>Number of Surviving Command Staff:</B> [comcount]<BR>
		<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
		<B>Number of Surviving Loyal Crew:</B> [loycount]<BR><BR>
		<B>Revolution Heads Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
		<B>Revolution Heads Slain:</B> [score["opkilled"]] ([score["opkilled"] * 500] Points)<BR>
		<B>Command Staff Slain:</B> [score["deadcommand"]] (-[score["deadcommand"] * 500] Points)<BR>
		<B>Revolution Successful:</B> [score["traitorswon"] ? "Yes" : "No"] (-[score["traitorswon"] * revpenalty] Points)<BR>
		<B>All Revolution Heads Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}

	*/

//	var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
	dat += {"<B><U>GENERAL STATS</U></B><BR>

	<U>THE GOOD:</U><BR>
	<B>Length of Shift:</B> [round(world.time/600)] Minutes ([round(score["time"] * 0.2)] Points)<BR>
	<B>Hydroponics Harvests:</B> [score["stuffharvested"]] ([score["stuffharvested"] * 1] Points)<BR>
	<B>Ore Smelted:</B> [score["oremined"]] ([score["oremined"] * 1] Points)<BR>
	<B>Meals Prepared:</B> [score["meals"]] ([score["meals"] * 5] Points)<BR>
	<B>Shuttle Escapees:</B> [score["escapees"]] ([score["escapees"] * 100] Points)<BR>
	<B>Random Events Endured:</B> [score["eventsendured"]] ([score["eventsendured"] * 200] Points)<BR>
	<B>Whole Station Powered:</B> [score["powerbonus"] ? "Yes" : "No"] ([score["powerbonus"] * 2500] Points)<BR>
	<B>Ultra-Clean Station:</B> [score["messbonus"] ? "Yes" : "No"] ([score["messbonus"] * 10000] Points)<BR><BR>

	<U>THE BAD:</U><BR>
	<B>Dead Crewmen:</B> [score["deadcrew"]] (-[score["deadcrew"] * 250] Points)<BR>
	<B>Destroyed Silicons:</B> [score["deadsilicon"]] (-[score["deadsilicon"] * 500] Points)<BR>
	<B>AIs Destroyed:</B> [score["deadaipenalty"]] (-[score["deadaipenalty"] * 1000] Points)<BR>
	<B>Uncleaned Messes:</B> [score["mess"]] (-[score["mess"]] Points)<BR>
	<B>Trash on Station:</B> [score["litter"]] (-[score["litter"]] Points)<BR>
	<B>Station Power Issues:</B> [score["powerloss"]] (-[score["powerloss"] * 50] Points)<BR>
	<B>Unique Disease Vectors:</B> [score["disease"]] (-[score["disease"] * 50] Points)<BR><BR>

	<U>THE WEIRD</U><BR>"}
/*	<B>Final Station Budget:</B> $[num2text(totalfunds,50)]<BR>"}
	var/profit = totalfunds - 100000
	if (profit > 0) dat += "<B>Station Profit:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0) dat += "<B>Station Deficit:</B> [num2text(profit,50)]<BR>"}*/
	dat += {"<B>Food Eaten:</b> [score["foodeaten"]]<BR>
	<B>Times a Clown was Abused:</B> [score["clownabuse"]]<BR>
	<B>Number of Explosions This Shift:</B> [score["explosions"]]<BR>
	<B>Number of Arena Rounds:</B> [score["arenafights"]]<BR>"}

	if(arena_top_score)
		dat += "<B>Best Arena Fighter (won [arena_top_score] rounds!):</B> [score["arenabest"]]<BR>"

	if(score["escapees"])
		if(score["dmgestdamage"])
			dat += "<B>Most Battered Escapee:</B> [score["dmgestname"]], [score["dmgestjob"]]: [score["dmgestdamage"]] damage ([score["dmgestkey"]])<BR>"
		if(score["richestcash"])
			dat += "<B>Richest Escapee:</B> [score["richestname"]], [score["richestjob"]]: [score["richestcash"]] space credits ([score["richestkey"]])<BR>"
	else
		dat += "The station wasn't evacuated or there were no survivors!<BR>"
	dat += {"<HR><BR>

	<B><U>FINAL SCORE: [score["crewscore"]]</U></B><BR>"}
	score["rating"] = "A Rating"

	switch(score["crewscore"])
		if(-INFINITY to -50000) score["rating"] = "Even the Singularity Deserves Better"
		if(-49999 to -5000) score["rating"] = "Singularity Fodder"
		if(-4999 to -1000) score["rating"] = "You're All Fired"
		if(-999 to -500) score["rating"] = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250) score["rating"] = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100) score["rating"] = "Outclassed by Lab Monkeys"
		if(-99 to -21) score["rating"] = "The Undesirables"
		if(-20 to -1) score["rating"] = "Not So Good"
		if(0) score["rating"] = "Nothing of Value"
		if(1 to 20) score["rating"] = "Ambivalently Average"
		if(21 to 99) score["rating"] = "Not Bad, but Not Good"
		if(100 to 249) score["rating"] = "Skillful Servants of Science"
		if(250 to 499) score["rating"] = "Best of a Good Bunch"
		if(500 to 999) score["rating"] = "Lean Mean Machine Thirteen"
		if(1000 to 4999) score["rating"] = "Promotions for Everyone"
		if(5000 to 9999) score["rating"] = "Ambassadors of Discovery"
		if(10000 to 49999) score["rating"] = "The Pride of Science Itself"
		if(50000 to INFINITY) score["rating"] = "NanoTrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score["rating"]]"

	for(var/i = 1; i <= end_icons.len; i++)
		src << browse_rsc(end_icons[i],"logo_[i].png")

	if(!endgame_info_logged) //So the End Round info only gets logged on the first player.
		endgame_info_logged = 1
		round_end_info = dat
		log_game(dat)

	src << browse(dat, "window=roundstats;size=1000x600")
	return
