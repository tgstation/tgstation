#define PLAYER_WEIGHT 1
#define HUMAN_DEATH -500
#define OTHER_DEATH -500
#define EXPLO_SCORE -1000 //boum

//estimated stats
//80 minute round
//60 player server
//48k player-ticks

//60 deaths (ideally)
//20 explosions


var/global/datum/tension/tension_master

/datum/tension
	var/score

	var/deaths
	var/human_deaths
	var/explosions
	var/adminhelps
	var/air_alarms

	var/nuketeam = 0
	var/malfAI = 0
	var/wizard = 0

	var/forcenexttick = 0
	var/supress = 0

	var/list/antagonistmodes = list (
	"POINTS_FOR_TRATIOR" 	=	10000,
	"POINTS_FOR_CHANGLING"	=	12000,
	"POINTS_FOR_REVS"		=	15000,
	"POINTS_FOR_MALF"		=	25000,
	"POINTS_FOR_WIZARD"		=	15000,
 	"POINTS_FOR_CULT"		=	15000,
 	"POINTS_FOR_NUKETEAM"	=	25000,
 	"POINTS_FOR_ALIEN"		=	20000,
 	"POINTS_FOR_NINJA"		=	20000,
 	"POINTS_FOR_DEATHSQUAD"	=	50000
	)

	var/list/potentialgames = list()

	New()
		score = 0
		deaths=0
		human_deaths=0
		explosions=0
		adminhelps=0
		air_alarms=0

	proc/process()
		score += get_num_players()*PLAYER_WEIGHT

		if(config.Tensioner_Active)
			if(score > 100000)
				if(!supress)
					if(prob(1) || forcenexttick)
						if(prob(50) || forcenexttick)
							if(forcenexttick)
								forcenexttick = 0

							for (var/mob/M in world)
								if (M.client && M.client.holder)
									M << "The tensioner wishes to create additional antagonists!  Press (<a href='?src=\ref[tension_master];Supress=1'>this</a>) in 30 seconds to abort!"

							spawn(300)
								if(!supress)
									for(var/V in antagonistmodes)			// OH SHIT SOMETHING IS GOING TO HAPPEN NOW
										if(antagonistmodes[V] < score)
											potentialgames.Add(V)
											antagonistmodes.Remove(V)

									if(potentialgames.len)
										var/thegame = pick(potentialgames)

										switch(thegame)
											if("POINTS_FOR_TRATIOR")
												if(!makeTratiors())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)
											if("POINTS_FOR_CHANGLING")
												if(!makeChanglings())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)
											if("POINTS_FOR_REVS")
												if(!makeRevs())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)
											if("POINTS_FOR_MALF")
												if(!makeMalfAImode())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)
											if("POINTS_FOR_WIZARD")
												if(!makeWizard())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)

											if("POINTS_FOR_CULT")
												if(!makeCult())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)

											if("POINTS_FOR_NUKETEAM")
												if(!makeNukeTeam())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)

											if("POINTS_FOR_ALIEN")
												//makeAliens()
												forcenexttick = 1

											if("POINTS_FOR_NINJA")
												//makeSpaceNinja()
												forcenexttick = 1

											if("POINTS_FOR_DEATHSQUAD")
												//makeDeathsquad()
												forcenexttick = 1




	proc/get_num_players()
		var/peeps = 0
		for (var/mob/M in world)
			if (!M.client)
				continue
			peeps += 1

		return peeps

	proc/death(var/mob/M)
		if (!M) return
		deaths++

		if (istype(M,/mob/living/carbon/human))
			score += HUMAN_DEATH
			human_deaths++
		else
			score += OTHER_DEATH


	proc/explosion()
		score += EXPLO_SCORE
		explosions++

	proc/new_adminhelp()
		adminhelps++

	proc/new_air_alarm()
		air_alarms++


	Topic(href, href_list)

		log_admin("[key_name(usr)] used a tensioner override.  The override was [href]")
		message_admins("[key_name(usr)] used a tensioner override.  The override was [href]")

		if(href_list["addScore"])
			score += 50000

		if (href_list["makeTratior"])
			makeTratiors()

		else if (href_list["makeChanglings"])
			makeChanglings()

		else if (href_list["makeRevs"])
			makeRevs()

		else if (href_list["makeWizard"])
			makeWizard()

		else if (href_list["makeCult"])
			makeCult()

		else if (href_list["makeMalf"])
			makeMalfAImode()

		else if (href_list["makeNukeTeam"])
			makeNukeTeam()

		else if (href_list["makeAliens"])
			makeAliens()

		else if (href_list["makeSpaceNinja"])
			makeSpaceNinja()

		else if (href_list["makeDeathsquad"])
			makeDeathsquad()

		else if (href_list["Supress"])
			supress = 1
			spawn(6000)
				supress = 0


	proc/makeMalfAImode()

		var/list/mob/living/silicon/AIs = list()
		var/mob/living/silicon/malfAI = null
		var/datum/mind/themind = null

		for(var/mob/living/silicon/ai in world)
			if(ai.client)
				AIs += ai

		if(AIs.len)
			malfAI = pick(AIs)

		else
			return 0

		if(malfAI)
			themind = malfAI.mind
			themind.make_AI_Malf()
			return 1


	proc/makeTratiors()

		var/datum/game_mode/traitor/temp = new
		if(config.protect_roles_from_antagonist)
			temp.restricted_jobs += temp.protected_jobs

		var/list/mob/living/carbon/human/candidates = list()
		var/mob/living/carbon/human/H = null

		for(var/mob/living/carbon/human/applicant in world)
			if(applicant.stat < 2)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!(applicant.job in temp.restricted_jobs))
							if(applicant.client)
								candidates += applicant

		if(candidates.len)
			var/numTratiors = min(candidates.len, 3)

			for(var/i = 0, i<numTratiors, i++)
				H = pick(candidates)
				H.mind.make_Tratior()


	proc/makeChanglings()

		var/datum/game_mode/changeling/temp = new
		if(config.protect_roles_from_antagonist)
			temp.restricted_jobs += temp.protected_jobs

		var/list/mob/living/carbon/human/candidates = list()
		var/mob/living/carbon/human/H = null

		for(var/mob/living/carbon/human/applicant in world)
			if(applicant.stat < 2)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!(applicant.job in temp.restricted_jobs))
							if(applicant.client)
								candidates += applicant

		if(candidates.len)
			var/numChanglings = min(candidates.len, 3)

			for(var/i = 0, i<numChanglings, i++)
				H = pick(candidates)
				H.mind.make_Changling()

	proc/makeRevs()

		var/datum/game_mode/revolution/temp = new
		if(config.protect_roles_from_antagonist)
			temp.restricted_jobs += temp.protected_jobs

		var/list/mob/living/carbon/human/candidates = list()
		var/mob/living/carbon/human/H = null

		for(var/mob/living/carbon/human/applicant in world)
			if(applicant.stat < 2)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!(applicant.job in temp.restricted_jobs))
							if(applicant.client)
								candidates += applicant
		if(candidates.len)
			var/numRevs = min(candidates.len, 3)

			for(var/i = 0, i<numRevs, i++)
				H = pick(candidates)
				H.mind.make_Rev()

	proc/makeWizard()
		var/list/mob/dead/observer/candidates = list()
		var/mob/dead/observer/theghost = null
		var/time_passed = world.time


		for(var/mob/dead/observer/G in world)
			switch(alert(G, "Do you wish to be considered for the position of Space Wizard Foundation 'diplomat'?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return


		spawn(300)
			if(candidates.len)
				theghost = pick(candidates)
				var/mob/living/carbon/human/new_character=makeBody(theghost)
				new_character.mind.make_Wizard()

	proc/makeCult()

		var/datum/game_mode/cult/temp = new
		if(config.protect_roles_from_antagonist)
			temp.restricted_jobs += temp.protected_jobs

		var/list/mob/living/carbon/human/candidates = list()
		var/mob/living/carbon/human/H = null

		for(var/mob/living/carbon/human/applicant in world)
			if(applicant.stat < 2)
				if(applicant.mind)
					if (!applicant.mind.special_role)
						if(!(applicant.job in temp.restricted_jobs))
							if(applicant.client)
								candidates += applicant

		if(candidates.len)
			var/numCultists = min(candidates.len, 4)

			for(var/i = 0, i<numCultists, i++)
				H = pick(candidates)
				H.mind.make_Cultist()
				temp.grant_runeword(H)



	proc/makeNukeTeam()

		var/list/mob/dead/observer/candidates = list()
		var/mob/dead/observer/theghost = null
		var/time_passed = world.time

		for(var/mob/dead/observer/G in world)
			switch(alert(G,"Do you wish to be considered for a nuke team being sent in?","Please answer in 30 seconds!","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>300)//If more than 30 game seconds passed.
						return
					candidates += G
				if("No")
					return


		spawn(300)
			if(candidates.len)
				var/numagents = min(candidates.len, 5)
				syndicate_begin()

				for(var/i = 0, i<numagents,i++)
					theghost = pick(candidates)
					var/mob/living/carbon/human/new_character=makeBody(theghost)
					new_character.mind.make_Nuke()


				var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
				var/obj/effect/landmark/closet_spawn = locate("landmark*Nuclear-Closet")

				var/nuke_code = "[rand(10000, 99999)]"

				if(nuke_spawn)
					var/obj/item/weapon/paper/P = new
					P.info = "Sadly, the Syndicate could not get you a nuclear bomb.  We have, however, acquired the arming code for the station's onboard nuke.  The nuclear authorization code is: <b>[nuke_code]</b>"
					P.name = "nuclear bomb code and instructions"
					P.loc = nuke_spawn.loc

				if(closet_spawn)
					new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

				for (var/obj/effect/landmark/A in world)
					if (A.name == "Syndicate-Gear-Closet")
						new /obj/structure/closet/syndicate/personal(A.loc)
						del(A)
						continue

					if (A.name == "Syndicate-Bomb")
						new /obj/effect/spawner/newbomb/timer/syndicate(A.loc)
						del(A)
						continue


				spawn(0)
					for(var/datum/mind/synd_mind in ticker.mode.syndicates)
						if(synd_mind.current)
							if(synd_mind.current.client)
								for(var/image/I in synd_mind.current.client.images)
									if(I.icon_state == "synd")
										del(I)

					for(var/datum/mind/synd_mind in ticker.mode.syndicates)
						if(synd_mind.current)
							if(synd_mind.current.client)
								for(var/datum/mind/synd_mind_1 in ticker.mode.syndicates)
									if(synd_mind_1.current)
										var/I = image('mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
										synd_mind.current.client.images += I

					for (var/obj/machinery/nuclearbomb/bomb in world)
						bomb.r_code = nuke_code						// All the nukes are set to this code.



	proc/makeAliens()
		usr << "Aliens aren't a game mode, silly!"

	proc/makeSpaceNinja()
		usr << "A space ninja isn't a game mode, silly!"

	proc/makeDeathsquad()
		usr << "A deathsquad isn't a game mode, silly!"




	proc/makeBody(var/mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character

		if(!G_found)
			return

		//First we spawn a dude.
		var/mob/living/carbon/human/new_character = new(src)//The mob being spawned.

		//Second, we check if they are an alien or monkey.
		G_found.mind=null//Null their mind so we don't screw things up ahead.
		G_found.real_name="[pick(pick(first_names_male,first_names_female))] [pick(last_names)]"//Give them a random real name.

		new_character.mind = new()
		ticker.minds += new_character.mind//And we'll add it to the minds database.
		new_character.mind.original = new_character//If they are respawning with a new character.
		new_character.mind.assigned_role = "Assistant"//Defaults to assistant.
		new_character.mind.key = G_found.key//In case it's someone else playing as that character.
		new_character.mind.current = new_character//So that it can properly reference later if needed.
		new_character.mind.memory = ""//Memory erased so it doesn't get clunkered up with useless info. This means they may forget their previous mission--this is usually handled through objective code and recalling memory.

		var/datum/data/record/record_found//Referenced to later to either randomize or not randomize the character.
		if(G_found.mind)//They must have a mind to reference the record. Here we also double check for aliens.
			var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
			for(var/datum/data/record/t in data_core.locked)
				if(t.fields["id"]==id)
					record_found = t//We shall now reference the record.
					break

		//Here we either load their saved appearance or randomize it.
		var/datum/preferences/A = new()
		if(A.savefile_load(G_found))//If they have a save file. This will automatically load their parameters.
		//Note: savefile appearances are overwritten later on if the character has a data_core entry. By appearance, I mean the physical appearance.
			var/name_safety = G_found.real_name//Their saved parameters may include a random name. Also a safety in case they are playing a character that got their name after round start.
			A.copy_to(new_character)
			new_character.real_name = name_safety
			new_character.name = name_safety
		else
			if(record_found)//If they have a record we can determine a few things.
				new_character.real_name = record_found.fields["name"]//Not necessary to reference the record but I like to keep things uniform.
				new_character.name = record_found.fields["name"]
				new_character.gender = record_found.fields["sex"]//Sex
				new_character.age = record_found.fields["age"]//Age
				new_character.b_type = record_found.fields["b_type"]//Blood type
				//We will update their appearance when determining DNA.
			else
				new_character.gender = FEMALE
				var/name_safety = G_found.real_name//Default is a random name so we want to save this.
				A.randomize_appearance_for(new_character)//Now we will randomize their appearance since we have no way of knowing what they look/looked like.
				new_character.real_name = name_safety
				new_character.name = name_safety

		//After everything above, it's time to initialize their DNA.
		if(record_found)//Pull up their name from database records if they did have a mind.
			new_character.dna = new()//Let's first give them a new DNA.
			new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.
			new_character.dna.struc_enzymes = record_found.fields["enzymes"]//This is the default of enzymes so I think it's safe to go with.
			new_character.dna.uni_identity = record_found.fields["identity"]//DNA identity is carried over.
			updateappearance(new_character,new_character.dna.uni_identity)//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
		else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
			new_character.dna.ready_dna(new_character)


		var/player_key = G_found.key

		//Here we need to find where to spawn them.
		var/spawn_here = pick(latejoin)//"JoinLate" is a landmark which is deleted on round start. So, latejoin has to be used instead.
		new_character.loc = spawn_here
		//If they need to spawn elsewhere, they will be transferred there momentarily.

		/*
		The code below functions with the assumption that the mob is already a traitor if they have a special role.
		So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
		If they don't have a mind, they obviously don't have a special role.
		*/

		new_character.key = player_key//Throw them into the mob.
/*
		//Now for special roles and equipment.
		switch(new_character.mind.special_role)
			if("Changeling")
				job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
				new_character.make_changeling()
			if("traitor")
				job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
				ticker.mode.equip_traitor(new_character)
			if("Wizard")
				new_character.loc = pick(wizardstart)
				//ticker.mode.learn_basic_spells(new_character)
				ticker.mode.equip_wizard(new_character)
			if("Syndicate")
				var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
				if(synd_spawn)
					new_character.loc = get_turf(synd_spawn)
				call(/datum/game_mode/proc/equip_syndicate)(new_character)
			if("Space Ninja")
				var/ninja_spawn[] = list()
				for(var/obj/effect/landmark/L in world)
					if(L.name=="carpspawn")
						ninja_spawn += L
				new_character.equip_space_ninja()
				new_character.internal = new_character.s_store
				new_character.internals.icon_state = "internal1"
				if(ninja_spawn.len)
					var/obj/effect/landmark/ninja_spawn_here = pick(ninja_spawn)
					new_character.loc = ninja_spawn_here.loc
			if("Death Commando")//Leaves them at late-join spawn.
				new_character.equip_death_commando()
				new_character.internal = new_character.s_store
				new_character.internals.icon_state = "internal1"
			else//They may also be a cyborg or AI.
				switch(new_character.mind.assigned_role)
					if("Cyborg")//More rigging to make em' work and check if they're traitor.
						new_character = new_character.Robotize()
						if(new_character.mind.special_role=="traitor")
							call(/datum/game_mode/proc/add_law_zero)(new_character)
					if("AI")
						new_character = new_character.AIize()
						if(new_character.mind.special_role=="traitor")
							call(/datum/game_mode/proc/add_law_zero)(new_character)
					//Add aliens.
					else
						job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

		//Announces the character on all the systems, based on the record.
		if(!issilicon(new_character))//If they are not a cyborg/AI.
			if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
				//Power to the user!
				if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
					call(/mob/new_player/proc/ManifestLateSpawn)(new_character)

				if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
					call(/mob/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)
*/
		del(G_found)//Don't want to leave ghosts around.
		return new_character
