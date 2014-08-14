/datum/controller/gameticker/proc/scoreboard()

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			call(mode, handler)()

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	// Score Calculation and Display

	// Who is alive/dead, who escaped
	for (var/mob/living/silicon/ai/I in mob_list)
		if (I.stat == 2 && I.z == 1)
			score["deadaipenalty"] = 1
			score["deadcrew"] += 1

	for (var/mob/living/carbon/human/I in mob_list)
//		for (var/datum/ailment/disease/V in I.ailments)
//			if (!V.vaccine && !V.spread != "Remissive") score["disease"]++
		if (I.stat == 2 && I.z == 1) score["deadcrew"] += 1
		if (I.job == "Clown")
			for(var/thing in I.attack_log)
				if(findtext(thing, "<font color='orange'>")) score["clownabuse"]++


	for(var/mob/living/player in mob_list)
		if (player.client)
			if (player.stat != 2)
				var/turf/location = get_turf(player.loc)
				var/area/escape_zone = locate(/area/shuttle/escape/centcom)
				if (location in escape_zone)
					score["escapees"] += 1
//					player.unlock_medal("100M Dash", 1)
//				player.unlock_medal("Survivor", 1)
//				for (var/obj/item/weapon/gnomechompski/G in player.get_contents())
//					player.unlock_medal("Guardin' gnome", 1)


	var/cashscore = 0
	var/dmgscore = 0
	for(var/mob/living/carbon/human/E in mob_list)
		cashscore = 0
		dmgscore = 0
		var/turf/location = get_turf(E.loc)
		var/area/escape_zone = locate(/area/shuttle/escape/centcom)
		if(E.stat != 2 && location in escape_zone) // Escapee Scores
			for (var/obj/item/weapon/card/id/C1 in E.contents) cashscore += C1.money
			for (var/obj/item/weapon/spacecash/C2 in E.contents) cashscore += C2.worth
			for (var/obj/item/weapon/storage/S in E.contents)
				for (var/obj/item/weapon/card/id/C3 in S.contents) cashscore += C3.money
				for (var/obj/item/weapon/spacecash/C4 in S.contents) cashscore += C4.worth
//			for(var/datum/data/record/Ba in data_core.bank)
//				if(Ba.fields["name"] == E.real_name) cashscore += Ba.fields["current_money"]
			if (cashscore > score["richestcash"])
				score["richestcash"] = cashscore
				score["richestname"] = E.real_name
				score["richestjob"] = E.job
				score["richestkey"] = E.key
			dmgscore = E.bruteloss + E.fireloss + E.toxloss + E.oxyloss
			if (dmgscore > score["dmgestdamage"])
				score["dmgestdamage"] = dmgscore
				score["dmgestname"] = E.real_name
				score["dmgestjob"] = E.job
				score["dmgestkey"] = E.key

	var/nukedpenalty = 1000
	if (ticker.mode.config_tag == "nuclear")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
			if (!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if (T && istype(T.loc, /area/security/brig)) score["arrested"] += 1
			else if (M.current.stat == 2) score["opkilled"]++
		if(foecount == score["arrested"]) score["allarrested"] = 1

/*
		score["disc"] = 1
		for(var/obj/item/weapon/disk/nuclear/A in world)
			if(A.loc != /mob/living/carbon) continue
			var/turf/location = get_turf(A.loc)
			var/area/bad_zone1 = locate(/area)
			var/area/bad_zone2 = locate(/area/syndicate_station)
			var/area/bad_zone3 = locate(/area/wizard_station)
			if (location in bad_zone1) score["disc"] = 0
			if (location in bad_zone2) score["disc"] = 0
			if (location in bad_zone3) score["disc"] = 0
			if (A.loc.z != 1) score["disc"] = 0
*/
		if (score["nuked"])
			for (var/obj/machinery/nuclearbomb/NUKE in machines)
				if (NUKE.r_code == "Nope") continue
				var/turf/T = NUKE.loc
				if (istype(T,/area/syndicate_station) || istype(T,/area/wizard_station) || istype(T,/area/solar)) nukedpenalty = 1000
				else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armoury) || istype(T,/area/security/checkpoint2)) nukedpenalty = 50000
				else if (istype(T,/area/engine)) nukedpenalty = 100000
				else nukedpenalty = 10000

	if (ticker.mode.config_tag == "revolution")
		var/foecount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			foecount++
			if (!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if (istype(T.loc, /area/security/brig)) score["arrested"] += 1
			else if (M.current.stat == 2) score["opkilled"]++
		if(foecount == score["arrested"]) score["allarrested"] = 1
		for(var/mob/living/carbon/human/player in world)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if (player.stat == 2) score["deadcommand"]++

	// Check station's power levels
	for (var/obj/machinery/power/apc/A in machines)
		if (A.z != 1) continue
		for (var/obj/item/weapon/cell/C in A.contents)
			if (C.charge < 2300) score["powerloss"] += 1 // 200 charge leeway

	// Check how much uncleaned mess is on the station
	for (var/obj/effect/decal/cleanable/M in world)
		if (M.z != 1) continue
		if (istype(M, /obj/effect/decal/cleanable/blood/gibs/)) score["mess"] += 3
		if (istype(M, /obj/effect/decal/cleanable/blood/)) score["mess"] += 1
//		if (istype(M, /obj/effect/decal/cleanable/greenpuke)) score["mess"] += 1
//		if (istype(M, /obj/effect/decal/cleanable/poop)) score["mess"] += 1 // What the literal fuck Paradise. Jesus christ no. - Iamgoofball
//		if (istype(M, /obj/decal/cleanable/urine)) score["mess"] += 1
		if (istype(M, /obj/effect/decal/cleanable/vomit)) score["mess"] += 1

	// Bonus Modifiers
	//var/traitorwins = score["traitorswon"]
	var/deathpoints = score["deadcrew"] * 25 //done
	var/researchpoints = score["researchdone"] * 30
	var/eventpoints = score["eventsendured"] * 50
	var/escapoints = score["escapees"] * 25 //done
	var/harvests = score["stuffharvested"] * 5 //done
	var/shipping = score["stuffshipped"] * 5
	var/mining = score["oremined"] * 2 //done
	//var/meals = score["meals"] * 5 //done, but this only counts cooked meals, not drinks served
	var/power = score["powerloss"] * 20
	var/messpoints
	if (score["mess"] != 0) messpoints = score["mess"] //done
	var/plaguepoints = score["disease"] * 30

	// Mode Specific
	if (ticker.mode.config_tag == "nuclear")
		if (score["disc"]) score["crewscore"] += 500
		var/killpoints = score["opkilled"] * 250
		var/arrestpoints = score["arrested"] * 1000
		score["crewscore"] += killpoints
		score["crewscore"] += arrestpoints
		if (score["nuked"]) score["crewscore"] -= nukedpenalty

	if (ticker.mode.config_tag == "revolution")
		var/arrestpoints = score["arrested"] * 1000
		var/killpoints = score["opkilled"] * 500
		var/comdeadpts = score["deadcommand"] * 500
		if (score["traitorswon"]) score["crewscore"] -= 10000
		score["crewscore"] += arrestpoints
		score["crewscore"] += killpoints
		score["crewscore"] -= comdeadpts

	// Good Things
	score["crewscore"] += shipping
	score["crewscore"] += harvests
	score["crewscore"] += mining
	score["crewscore"] += researchpoints
	score["crewscore"] += eventpoints
	score["crewscore"] += escapoints

	if (power == 0)
		score["crewscore"] += 2500
		score["powerbonus"] = 1
	if (score["mess"] == 0)
		score["crewscore"] += 3000
		score["messbonus"] = 1
	//score["crewscore"] += meals
	if (score["allarrested"]) score["crewscore"] *= 3 // This needs to be here for the bonus to be applied properly

	// Bad Things
	score["crewscore"] -= deathpoints
	if (score["deadaipenalty"]) score["crewscore"] -= 250
	score["crewscore"] -= power
	//if (score["crewscore"] != 0) // Dont divide by zero!
	//	while (traitorwins > 0)
	//		score["crewscore"] /= 2
	//		traitorwins -= 1
	score["crewscore"] -= messpoints
	score["crewscore"] -= plaguepoints

	// Show the score - might add "ranks" later
	world << "<b>The crew's final score is:</b>"
	world << "<b><font size='4'>[score["crewscore"]]</font></b>"
	for(var/mob/E in player_list)
		if(E.client) E.scorestats()
	return



/mob/proc/scorestats()
	var/dat = {"<B>Round Statistics and Score</B><BR><HR>"}
	if (ticker.mode.name == "nuclear emergency")
		var/foecount = 0
		var/crewcount = 0
		var/diskdat = ""
		var/bombdat = null
		for(var/datum/mind/M in ticker.mode:syndicates)
			foecount++
		for(var/mob/living/C in world)
			if (!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai)) continue
			if (C.stat == 2) continue
			if (!C.client) continue
			crewcount++

		for(var/obj/item/weapon/disk/nuclear/N in world)
			if(!N) continue
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
		var/nukedpenalty = 0
		for(var/obj/machinery/nuclearbomb/NUKE in world)
			if (NUKE.r_code == "Nope") continue
			var/turf/T = NUKE.loc
			bombdat = T.loc
			if (istype(T,/area/syndicate_station) || istype(T,/area/wizard_station) || istype(T,/area/solar/) || istype(T,/area)) nukedpenalty = 1000
			else if (istype(T,/area/security/main) || istype(T,/area/security/brig) || istype(T,/area/security/armoury) || istype(T,/area/security/checkpoint2)) nukedpenalty = 50000
			else if (istype(T,/area/engine)) nukedpenalty = 100000
			else nukedpenalty = 10000
			break
		if (!diskdat) diskdat = "Uh oh. Something has fucked up! Report this."
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
	if (ticker.mode.name == "revolution")
		var/foecount = 0
		var/comcount = 0
		var/revcount = 0
		var/loycount = 0
		for(var/datum/mind/M in ticker.mode:head_revolutionaries)
			if (M.current && M.current.stat != 2) foecount++
		for(var/datum/mind/M in ticker.mode:revolutionaries)
			if (M.current && M.current.stat != 2) revcount++
		for(var/mob/living/carbon/human/player in world)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if (player.stat != 2) comcount++
				else
					if(player.mind in ticker.mode:revolutionaries) continue
					loycount++
		for(var/mob/living/silicon/X in world)
			if (X.stat != 2) loycount++
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
//	var/totalfunds = wagesystem.station_budget + wagesystem.research_budget + wagesystem.shipping_budget
	dat += {"<B><U>GENERAL STATS</U></B><BR>
	<U>THE GOOD:</U><BR>
	<B>Useful Items Shipped:</B> [score["stuffshipped"]] ([score["stuffshipped"] * 5] Points)<BR>
	<B>Hydroponics Harvests:</B> [score["stuffharvested"]] ([score["stuffharvested"] * 5] Points)<BR>
	<B>Ore Mined:</B> [score["oremined"]] ([score["oremined"] * 2] Points)<BR>
	<B>Research Completed:</B> [score["researchdone"]] ([score["researchdone"] * 30] Points)<BR>"}
	dat += "<B>Shuttle Escapees:</B> [score["escapees"]] ([score["escapees"] * 25] Points)<BR>"
	dat += {"<B>Random Events Endured:</B> [score["eventsendured"]] ([score["eventsendured"] * 50] Points)<BR>
	<B>Whole Station Powered:</B> [score["powerbonus"] ? "Yes" : "No"] ([score["powerbonus"] * 2500] Points)<BR>
	<B>Ultra-Clean Station:</B> [score["mess"] ? "No" : "Yes"] ([score["messbonus"] * 3000] Points)<BR><BR>
	<U>THE BAD:</U><BR>
	<B>Dead Bodies on Station:</B> [score["deadcrew"]] (-[score["deadcrew"] * 25] Points)<BR>
	<B>Uncleaned Messes:</B> [score["mess"]] (-[score["mess"]] Points)<BR>
	<B>Station Power Issues:</B> [score["powerloss"]] (-[score["powerloss"] * 20] Points)<BR>
	<B>Rampant Diseases:</B> [score["disease"]] (-[score["disease"] * 30] Points)<BR>
	<B>AI Destroyed:</B> [score["deadaipenalty"] ? "Yes" : "No"] (-[score["deadaipenalty"] * 250] Points)<BR><BR>
	<U>THE WEIRD</U><BR>"}
/*	<B>Final Station Budget:</B> $[num2text(totalfunds,50)]<BR>"}
	var/profit = totalfunds - 100000
	if (profit > 0) dat += "<B>Station Profit:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0) dat += "<B>Station Deficit:</B> [num2text(profit,50)]<BR>"}*/
	dat += {"<B>Food Eaten:</b> [score["foodeaten"]]<BR>
	<B>Times a Clown was Abused:</B> [score["clownabuse"]]<BR><BR>"}
	if (score["escapees"])
		dat += "<B>Most Battered Escapee:</B> [score["dmgestname"]], [score["dmgestjob"]]: [score["dmgestdamage"]] damage ([score["dmgestkey"]])<BR>"
	else
		dat += "The station wasn't evacuated or no one escaped!<BR>"
	dat += {"<HR><BR>
	<B><U>FINAL SCORE: [score["crewscore"]]</U></B><BR>"}
	score["rating"] = "The Aristocrats!"
	switch(score["crewscore"])
		if(-99999 to -50000) score["rating"] = "Even the Singularity Deserves Better"
		if(-49999 to -5000) score["rating"] = "Singularity Fodder"
		if(-4999 to -1000) score["rating"] = "You're All Fired"
		if(-999 to -500) score["rating"] = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250) score["rating"] = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100) score["rating"] = "Outclassed by Lab Monkeys"
		if(-99 to -21) score["rating"] = "The Undesirables"
		if(-20 to 20) score["rating"] = "Ambivalently Average"
		if(21 to 99) score["rating"] = "Not Bad, but Not Good"
		if(100 to 249) score["rating"] = "Skillful Servants of Science"
		if(250 to 499) score["rating"] = "Best of a Good Bunch"
		if(500 to 999) score["rating"] = "Lean Mean Machine Thirteen"
		if(1000 to 4999) score["rating"] = "Promotions for Everyone"
		if(5000 to 9999) score["rating"] = "Ambassadors of Discovery"
		if(10000 to 49999) score["rating"] = "The Pride of Science Itself"
		if(50000 to INFINITY) score["rating"] = "NanoTrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score["rating"]]"
	src << browse(dat, "window=roundstats;size=500x600")
	return
