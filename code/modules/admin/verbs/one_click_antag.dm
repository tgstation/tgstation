client/proc/one_click_antag()
	set name = "Create Antagonist"
	set desc = "Auto-create an antagonist of your choice"
	set category = "Admin"

	if(holder)
		holder.one_click_antag()
	return


/datum/admins/proc/one_click_antag()

	var/dat = {"<B>Quick-Create Antagonist</B><br>
		<a href='?src=\ref[src];makeAntag=1'>Make Traitors</a><br>
		<a href='?src=\ref[src];makeAntag=2'>Make Changelings</a><br>
		<a href='?src=\ref[src];makeAntag=3'>Make Revs</a><br>
		<a href='?src=\ref[src];makeAntag=4'>Make Cult</a><br>
		<a href='?src=\ref[src];makeAntag=5'>Make Malf AI</a><br>
		<a href='?src=\ref[src];makeAntag=11'>Make Blob</a><br>
		<a href='?src=\ref[src];makeAntag=12'>Make Gangsters</a><br>
		<a href='?src=\ref[src];makeAntag=6'>Make Wizard (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=7'>Make Nuke Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=10'>Make Deathsquad (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=13'>Make Emergency Response Team (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=14'>Make ERP Squad (Requires Sexy Ghosts)</a><br>
		"}
/* These dont work just yet
	Ninja, aliens and deathsquad I have not looked into yet
	Nuke team is getting a null mob returned from makebody() (runtime error: null.mind. Line 272)


		<a href='?src=\ref[src];makeAntag=8'>Make Space Ninja (Requires Ghosts)</a><br>
		<a href='?src=\ref[src];makeAntag=9'>Make Aliens (Requires Ghosts)</a><br>
		"}
*/
	usr << browse(dat, "window=oneclickantag;size=400x400")
	return


/datum/admins/proc/makeMalfAImode()

	var/list/mob/living/silicon/AIs = list()
	var/mob/living/silicon/malfAI = null
	var/datum/mind/themind = null

	for(var/mob/living/silicon/ai/ai in player_list)
		if(ai.client)
			AIs += ai

	if(AIs.len)
		malfAI = pick(AIs)

	if(malfAI)
		themind = malfAI.mind
		themind.make_AI_Malf()
		return 1

	return 0


/datum/admins/proc/makeTraitors()
	var/datum/game_mode/traitor/temp = new

	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.prefs.be_special & BE_TRAITOR)
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "traitor") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numTraitors = min(candidates.len, 3)

		for(var/i = 0, i<numTraitors, i++)
			H = pick(candidates)
			H.mind.make_Traitor()
			candidates.Remove(H)

		return 1


	return 0


/datum/admins/proc/makeChanglings()

	var/datum/game_mode/changeling/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.prefs.be_special & BE_CHANGELING)
			if(!applicant.stat)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "changeling") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numChanglings = min(candidates.len, 3)

		for(var/i = 0, i<numChanglings, i++)
			H = pick(candidates)
			H.mind.make_Changling()
			candidates.Remove(H)

		return 1

	return 0

/datum/admins/proc/makeRevs()

	var/datum/game_mode/revolution/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.prefs.be_special & BE_REV)
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "revolutionary") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numRevs = min(candidates.len, 3)

		for(var/i = 0, i<numRevs, i++)
			H = pick(candidates)
			H.mind.make_Rev()
			candidates.Remove(H)
		return 1

	return 0

/datum/admins/proc/makeWizard()
	var/datum/game_mode/wizard/temp = new
	var/list/mob/dead/observer/candidates = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
			if(temp.age_check(G.client))
				spawn(0)
					switch(alert(G, "Do you wish to be considered for the position of Space Wizard Foundation 'diplomat'?","Please answer in 30 seconds!","Yes","No"))
						if("Yes")
							if((world.time-time_passed)>300)//If more than 30 game seconds passed.
								return
							candidates += G
						if("No")
							return
						else
							return

	sleep(300)

	if(candidates.len)
		shuffle(candidates)
		for(var/mob/i in candidates)
			if(!i || !i.client) continue //Dont bother removing them from the list since we only grab one wizard

			theghost = i
			break

	if(theghost)
		var/mob/living/carbon/human/new_character=makeBody(theghost)
		new_character.mind.make_Wizard()
		return 1

	return 0


/datum/admins/proc/makeCult()

	var/datum/game_mode/cult/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.prefs.be_special & BE_CULTIST)
			if(applicant.stat == CONSCIOUS)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "cultist") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len)
		var/numCultists = min(candidates.len, 4)

		for(var/i = 0, i<numCultists, i++)
			H = pick(candidates)
			H.mind.make_Cultist()
			candidates.Remove(H)
			temp.grant_runeword(H)

		return 1

	return 0



/datum/admins/proc/makeNukeTeam()

	var/datum/game_mode/nuclear/temp = new
	var/list/mob/dead/observer/candidates = list()
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null
	var/time_passed = world.time

	for(var/mob/dead/observer/G in player_list)
		if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
			if(temp.age_check(G.client))
				spawn(0)
					switch(alert(G,"Do you wish to be considered for a nuke team being sent in?","Please answer in 30 seconds!","Yes","No"))
						if("Yes")
							if((world.time-time_passed)>300)//If more than 30 game seconds passed.
								return
							candidates += G
						if("No")
							return
						else
							return

	sleep(300)

	if(candidates.len)
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = j
				candidates.Remove(theghost)
				chosen += theghost
				agentcount++
				break
		//Making sure we have atleast 3 Nuke agents, because less than that is kinda bad
		if(agentcount < 3)
			return 0

		var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
		var/obj/effect/landmark/closet_spawn = locate("landmark*Syndicate-Uplink")
		var/nuke_code = "[rand(10000, 99999)]"

		if(nuke_spawn)
			var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
			the_bomb.r_code = nuke_code

		if(closet_spawn)
			new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

		//Let's find the spawn locations
		var/list/turf/synd_spawn = list()
		for(var/obj/effect/landmark/A in landmarks_list)
			if(A.name == "Syndicate-Spawn")
				synd_spawn += get_turf(A)
				continue

		var/leader_chosen
		var/spawnpos = 1 //Decides where they'll spawn. 1=leader.

		for(var/mob/c in chosen)
			if(spawnpos > synd_spawn.len)
				spawnpos = 2 //Ran out of spawns. Let's loop back to the first non-leader position
			var/mob/living/carbon/human/new_character=makeBody(c)
			if(!leader_chosen)
				leader_chosen = 1
				new_character.mind.make_Nuke(synd_spawn[spawnpos],nuke_code,1)
			else
				new_character.mind.make_Nuke(synd_spawn[spawnpos],nuke_code)
			spawnpos++

	return 1





/datum/admins/proc/makeAliens()
	new /datum/round_event/alien_infestation{spawncount=3}()
	return 1

/datum/admins/proc/makeSpaceNinja()
	new /datum/round_event/ninja()
	return 1

// DEATH SQUADS
/datum/admins/proc/makeDeathsquad()
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time
	var/mission = input("Assign a mission to the deathsquad", "Assign Mission", "Leave no witnesses.")

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.
	for(var/mob/dead/observer/G in player_list)
		spawn(0)
			switch(alert(G,"Do you wish to be considered for an elite Nanotrasen strike team being sent in?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return
				else
					return
	sleep(300)

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len >= 3) //Minimum 3 to be considered a squad
		//Pick the lucky players
		var/numagents = min(5,candidates.len) //How many commandos to spawn
		var/list/spawnpoints = deathsquadspawn
		while(numagents && spawnpoints.len && candidates.len)
			var/spawnloc = spawnpoints[1]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn and equip the commando
			var/mob/living/carbon/human/Commando = new(spawnloc)
			chosen_candidate.client.prefs.copy_to(Commando)
			ready_dna(Commando)
			if(numagents == 1) //If Squad Leader
				Commando.real_name = "Officer [pick(commando_names)]"
				equip_deathsquad(Commando, 1)
			else
				Commando.real_name = "Trooper [pick(commando_names)]"
				equip_deathsquad(Commando)
			Commando.key = chosen_candidate.key
			Commando.mind.assigned_role = "Death Commando"

			//Assign antag status and the mission
			ticker.mode.traitors += Commando.mind
			Commando.mind.special_role = "deathsquad"
			var/datum/objective/missionobj = new
			missionobj.owner = Commando.mind
			missionobj.explanation_text = mission
			missionobj.completed = 1
			Commando.mind.objectives += missionobj

			//Greet the commando
			Commando << "<B><font size=3 color=red>You are the [numagents==1?"Deathsquad Officer":"Death Commando"].</font></B>"
			var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
			if(numagents == 1) //If Squad Leader
				missiondesc += " Lead your squad to ensure the completion of the mission. Board the shuttle when your team is ready."
			else
				missiondesc += " Follow orders given to you by your squad leader."
			missiondesc += "<BR><B>Your Mission</B>: [mission]"
			Commando << missiondesc

			//Logging and cleanup
			if(numagents == 1)
				message_admins("The deathsquad has spawned with the mission: [mission].")
			log_game("[key_name(Commando)] has been selected as a Death Commando")
			spawnpoints -= spawnloc
			numagents--

		return 1

	return


/datum/admins/proc/makeGangsters()

	var/datum/game_mode/gang/temp = new
	if(config.protect_roles_from_antagonist)
		temp.restricted_jobs += temp.protected_jobs

	if(config.protect_assistant_from_antagonist)
		temp.restricted_jobs += "Assistant"

	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H = null

	for(var/mob/living/carbon/human/applicant in player_list)
		if(applicant.client.prefs.be_special & BE_GANG)
			if(!applicant.stat)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "gangster") && !jobban_isbanned(applicant, "Syndicate"))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									candidates += applicant

	if(candidates.len >= 2)
		H = pick(candidates)
		H.mind.make_Gang("A")
		candidates.Remove(H)
		H = pick(candidates)
		H.mind.make_Gang("B")
		return 1

	return 0

// EMERGENCY RESPONSE TEAM
/datum/admins/proc/makeEmergencyresponseteam()
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time
	var/mission = input("Assign a mission to the Emergency Response Team", "Assign Mission", "Assist the station.")

	//Generates a list of officers from active ghosts. Then the user picks which characters to respawn as the officers.
	for(var/mob/dead/observer/G in player_list)
		spawn(0)
			switch(alert(G,"Do you wish to be considered for an elite Nanotrasen Emergency Response Team being sent in?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return
				else
					return
	sleep(300)

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len >= 4) //Minimum 4 to be considered a squad
		//Pick the (un)lucky players
		var/numagents = min(7,candidates.len) //How many officers to spawn
		var/list/spawnpoints = emergencyresponseteamspawn
		while(numagents && spawnpoints.len && candidates.len)
			var/spawnloc = spawnpoints[1]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn and equip the officer
			var/mob/living/carbon/human/ERTOperative = new(spawnloc)
			var/list/lastname = last_names
			chosen_candidate.client.prefs.copy_to(ERTOperative)
			ready_dna(ERTOperative)
			switch(numagents)
				if(1)
					ERTOperative.real_name = "Commander [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "commander")
				if(2 || 5)
					ERTOperative.real_name = "Security Officer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "sec")
				if(3 || 6)
					ERTOperative.real_name = "Medical Officer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "med")
				if(4 || 7)
					ERTOperative.real_name = "Engineer [pick(lastname)]"
					equip_emergencyresponsesquad(ERTOperative, "eng")
			ERTOperative.key = chosen_candidate.key
			ERTOperative.mind.assigned_role = "ERT"

			//Assign antag status and the mission
			ticker.mode.traitors += ERTOperative.mind
			ERTOperative.mind.special_role = "ert"
			var/datum/objective/missionobj = new
			missionobj.owner = ERTOperative.mind
			missionobj.explanation_text = mission
			missionobj.completed = 1
			ERTOperative.mind.objectives += missionobj

			//Greet the commando
			ERTOperative << "<B><font size=3 color=red>You are [numagents==1?"the Emergency Response Team Commander":"an Emergency Response Officer"].</font></B>"
			var/missiondesc = "Your squad is being sent on a mission to [station_name()] by Nanotrasen's Security Division."
			if(numagents == 1) //If Squad Leader
				missiondesc += " Lead your squad to ensure the completion of the mission. Avoid civilian casualites when possible. Board the shuttle when your team is ready."
			else
				missiondesc += " Follow orders given to you by your commander. Avoid civilian casualites when possible."
			missiondesc += "<BR><B>Your Mission</B>: [mission]"
			ERTOperative << missiondesc

			//Logging and cleanup
			if(numagents == 1)
				message_admins("The emergency response team has spawned with the mission: [mission].")
			log_game("[key_name(ERTOperative)] has been selected as an Emergency Response Officer")
			spawnpoints -= spawnloc
			numagents--

		return 1

	return

/datum/admins/proc/makeERPsquad()
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time

	//Generates a list of ERPers from active ghosts.
	for(var/mob/dead/observer/G in player_list)
		spawn(0)
			switch(alert(G,"Do you wish to be considered for an elite Nanotrasen ERP Squad being sent in?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return
				else
					return
	sleep(300)

	for(var/mob/dead/observer/G in candidates)
		if(!G.key)
			candidates.Remove(G)

	if(candidates.len >= 3) //Minimum 3 to be considered a squad
		//Pick the unlucky players
		var/numerps = min(5,candidates.len) //How many erpers to spawn
		var/list/spawnpoints = deathsquadspawn
		while(numerps && spawnpoints.len && candidates.len)
			var/spawnloc = spawnpoints[1]
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn and equip the erper
			var/mob/living/carbon/human/ERPOperative = new(spawnloc)
			var/list/the_big_list_of_hookers = list("Abriana","Aira","Africa","Alabama","Alana","Alaya","Alecia","Alicia","Alex","Alexis","Alexa","Alexandra","Alexandria","Alison","Allura","Ally","Alpha","Alyssa","Amanda","Amaze","Amber","Amelia","Amethyst","Analis","Anastasia","Andra","Andrea","Andromeda","Angel","Angela","Angelique","Angie","Anise","Anisette","Anna","Annabella","Annie","Annika","Antoinette","Aphrodite","April","Ariel","Aries","Ashlee","Ashley","Ashlyn","Asia","Athena","Atlanta","Aubra","Aubrey","Audra","Aura","Aurora","Austin","Autumn","Ava","Azrael","Baby","Bailey","Bambi","Barbie","Beau","Beautiful","Becky","Bede","Belinda","Belle","Berry","Bethany","Bianca","Bindi","Bird","Bo","Bolero","Blade","Blake","Blanca","Blaze","Blondie","Blossom","Blue","Blush","Bobbie","Bordeaux","Bountiful","Brandy","Brandi","Breeze","Breezy","Brianna","Bridget","Brie","Brilliant","Brita","Britain","Brittany","Bronte","Bubbles","Buffy","Bunny","Burgundie","Butterfly","Callie","Cameo","Camille","Candi","Candice","Candy","Candee","Carmel","Carmela","Carmen","Carrie","Cashmere","Champagne","Chance","Chanel","Chantal","Chantelle","Chantilly","Chantiqua","Chaos","Charity","Charlie","Charlotte","Chastity","Cherie","Cherry","Cheyenne","China","Chloe","Chocolate","Chrissy","Christian","Christi","Lynn","Christy","Christine","Chynna","Cecilia","Cinder","Cinnamon","CJ","Cleo","Cleopatra","Clover","Coco","Cody","Constance","Contessa","Cookie","Crystal","Cuddles","Cynara","Cynder","Cyndi","Dagny","Dahlia","Daisy","Dakota","Dallas","Damiana","Dana","Danger","Danielle","Danni","Daphne","Darby","Darkness","Darla","Dawn","Decadence","Dee","Ann","Deidre","Deja","Delicious","Delight","Delilah","Delta","Deluxe","Denver","Desert","Rose","Desire","Desiree","Destiny","Devon","Devyn","Dharma","Diablo","Diamond","Diana","Dido","Diva","Divine","Divinity","Dixie","Dolly","Dominique","Dream","Duchess","Dusty","Dylan","Ebony","Echo","Ecstasy","Eden","Elan","Ella","Elle","Electra","Eli","Eliza","Elizabeth","Elvira","Elyse","Ember","Emerald","Emergency","Emily","Empress","Envy","Epiphany","Erotica","Esme","Eva","Evie","Eve","Fable","Fabulous","Faith","Fallon","Fame","Fantasia","Fantasy","Farrah","Fate","Fawn","Fawna","Fawnia","Feather","Felicia","Felicity","Felony","Ferrari","Fern","Fetish","Fiona","Fire","Francesca","Flame","Foxxxy","Frankie","Frosty","Gabrielle","Gabriella","Gaia","Gem","Gemma","Gemini","Genie","Gentle","Georgia","Gia","Giggles","Gigi","Gillian","Ginger","Giselle","Glamour","Glitter","Glory","Godiva","Grace","Gracious","Gypsy","Hanna","Harley","Harlow","Harmony","Heather","Heaven","Heavenleigh","Heavenly","Helena","Hillary","Holiday","Holly","Honey","Hope","Houston","Hyacinth","Ianna","Ice","Iesha","Illusion","Imagine","India","Indigo","Inferno","Infinity","Ireland","Irene","Isabel","Isabella","Isis","Ivory","Ivy","Izzy","Jade","Jaguar","Jamie","Janelle","Jasmine","Jasmyn","Jeanette","Jeanie","Jenna","Jenny","Jessica","Jessie","Jewel","Jewels","Jezebel","Jill","Jinx","JJ","Joetta","Joelle","Jolene","Jordan","Journey","Joy","Juicy","Julia","Julie","Juliet","June","Juno","Kaia","Kailli","Kara","Karla","Kashmir","Kat","Kathleen","Kayla","Kelli","Kenya","Karma","Kira","Kitten","Kitty","Krista","Kristen","Kristi","Krystal","Kylie","Kyra","Lace","Lacy","Lainie","Lakota","Lana","Latifah","Laura","Layla","Leah","Leather","Leggs","Leia","Leigh","Lexie","Licorice","Lightning","Lila","Lilith","Lily","Lindsey","Lisa","Lita","Liza","Logan","Lola","London","Loni","Lori","Love","Lucinda","Lucky","Lucretia","Lumina","Luna","Luscious","Luxury","Luxxie","Macy","Madeline","Madison","Magdalene","Magenta","Maggie","Magic","Magnolia","Malia","Malibu","Malice","Mandy","Manhattan","Margot","Maria","Mariah","Mariana","Marilyn","Marina","Marla","Marlena","Marti","Mary","Ann","Mary","Jane","Maxxx","May","McKenzie","Medusa","Megan","Melano","Melanie","Melinda","Melody","Melonie","Mercury","Merlot","Merlyn","Michelle","Mikhaila","Mikki","Mindee","Mindy","Mink","Mistress","Misty","Mercedes","Mercy","Midnight","Miracle","Mocha","Molly","Mona","Monaco","Monica","Monique","Montana","Morgan","Muse","Music","Mystery","Mystique","Nadia","Nanette","Nastasia","Nasty","Natalia","Natalie","Natasha","Nica","Nicole","Nikita","Nikki","Niko","Nina","Nixie","Noel","Nola","Norah","Notorious","Octavia","Olive","Olivia","Olympia","Omega","Opal","Ophelia","Paige","Pallas","Pamela","Pandemonium","Pandora","Pansy","Panther","Paradise","Paris","Passion","Paula","Peaches","Peanut","Pearl","Pebbles","Penelope","Penny","Pepper","Persephone","Petal","Peyton","Phoenix","Piper","Pisces","Pixie","Poison","Porsche","Power","Precious","Princess","Puppy","Queen","Quinn","Rachel","Rain","Ramona","Raven","Reba","Rebecca","Red","Renee","Rhiannon","Ria","Rio","Rita","River","Robyn","Rocki","Roma","Rose","Rosemary","Rosie","Roxanna","Roxanne","Ruby","Sable","Sabrina","Sachet","Saffron","Sage","Salome","Samantha","Sandi","Sapphire","Sarah","Sarasota","Saraya","Sasha","Sashay","Sassparilla","Sassy","Satan","Satin","Sativa","Savannah","Scandal","Scarlet","Selena","September","Septiva","Serena","Serenity","Seven","Shana","Shane","Shannon","Shawna","Shay","Shea","Shelby","Shelly","Sheree","Sherri","Sherry","Shine","Siam","Siena","Sierra","Silk","Silky","Silver","Sin","Simone","Siren","Skye","Sloane","Smoky","Soleil","Sonia","Song","Sorority","Spice","Spider","Spring","Staci","Stacia","Starr","Stevie","Storm","Stormy","Strawberry","Suavecita","Sublime","Sugar","Summer","Sundae","Sundance","Sunday","Sunni","Sunny","Sunshine","Sunset","Susanna","Suzanne","Swallow","Sweet","Sweetness","Tabitha","Taffy","Talia","Tallulah","Tamar","Tamara","Tammi","Tane","Tanya","Tara","Tasha","Tasty","Tatiana","Tawni","Taylor","Temper","Tempest","Temptation","Terra","Terror","Tess","Tessa","Texxxas","Thai","Thia","Thumper","Thyme","Tia","Tickle","Tiffany","Tiger","Tigra","Tika","Time","Tina","Tinker","Tisha","Toffee","Tommy","Toni","Topaz","Tori","Traci","Tracy","Tricia","Trinity","Trip","Tristana","Trixie","Trouble","Tuesday","Tyffany","Tyler","Tyra","Unique","Utopia","Valentina","Valentine","Vandal","Vanessa","Vanity","Velvet","Venus","Veronica","Viagra","Victoria","Victory","Viola","Violet","Viper","Virginia","Virgo","Vision","Vivienne","Vixen","Vonda","Wanda","Wednesday","Wendy","Whimsy","Whisky","Whisper","Willow","Windy","Winter","Wish","Wyndi","Xanadu","Xanthe","Xaviera","Xena","Xiola","Xtase","Yasmin","Yolanda","Yvette","Yvonne","Zena","Zenith","Zinnia","Zoe","Zoey","Zora")
			chosen_candidate.client.prefs.copy_to(ERPOperative)
			ERPOperative.gender = FEMALE
			ERPOperative.hair_style = "Floorlength Braid"
			ERPOperative.facial_hair_style = "Shaved"
			ERPOperative.underwear = "Ladies Kinky"
			ERPOperative.socks = "Nude"
			ERPOperative.undershirt = "Nude"
			ERPOperative.lip_style = pick("red", "purple", "jade", "black")
			ready_dna(ERPOperative)
			ERPOperative.update_body()
			ERPOperative.update_hair()
			ERPOperative.real_name = "[pick(the_big_list_of_hookers)] [pick(last_names)]"
			ERPOperative.key = chosen_candidate.key
			ERPOperative.mind.assigned_role = "ERP"

			//Assign antag status and the mission
			ticker.mode.traitors += ERPOperative.mind
			ERPOperative.mind.special_role = "ert"
			var/datum/objective/missionobj = new
			missionobj.owner = ERPOperative.mind
			missionobj.explanation_text = "Titillate the crew."
			missionobj.completed = 1
			ERPOperative.mind.objectives += missionobj
			var/datum/objective/dontgetbanned/banana = new
			banana.owner = ERPOperative.mind
			ERPOperative.mind.objectives += banana

			//Greet the ERPer
			ERPOperative << "<B><font size=3 color=red>You are an ERP squadmate.</font></B>"
			var/missiondesc = "Your squad is being sent on a goodwill mission to [station_name()]."
			missiondesc += " Work hard, play hard. Don't break the server rules. Avoid civilian casualites when possible."
			missiondesc += "<BR><B>Your Mission</B>:"
			var/obj_count = 1
			for(var/datum/objective/objective in ERPOperative.mind.objectives)
				missiondesc += "<BR><B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++
			ERPOperative << missiondesc

			//Logging and cleanup
			if(numerps == 1)
				message_admins("The ERP Squad has spawned. You asked for this.")
			log_game("[key_name(ERPOperative)] has been selected as an ERP Squadmate")
			spawnpoints -= spawnloc
			numerps--

		return 1

	return

/datum/admins/proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)	return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	G_found.client.prefs.copy_to(new_character)
	ready_dna(new_character)
	new_character.key = G_found.key

	return new_character
