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
	var/eversupressed = 0
	var/cooldown = 0

	var/round1 = 0
	var/round2 = 0
	var/round3 = 0
	var/round4 = 0

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
			if(score > 10000)
				round1++
				if(!supress && !cooldown)
					if(prob(1) || forcenexttick)
						round2++
						if(prob(50) || forcenexttick)
							round3++
							if(forcenexttick)
								forcenexttick = 0

							for (var/mob/M in world)
								if (M.client && M.client.holder)
									M << "The tensioner wishes to create additional antagonists!  Press (<a href='?src=\ref[tension_master];Supress=1'>this</a>) in 30 seconds to abort!"

							spawn(300)
								if(!supress)
									cooldown = 1
									spawn(6000)
										cooldown = 0
									round4++
									for(var/V in antagonistmodes)			// OH SHIT SOMETHING IS GOING TO HAPPEN NOW
										if(antagonistmodes[V] < score)
											potentialgames.Add(V)
											antagonistmodes.Remove(V)

									if(potentialgames.len)
										var/thegame = pick(potentialgames)

										log_admin("The tensioner fired, and decided on [thegame]")

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
												if(!makeAliens())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)

											if("POINTS_FOR_NINJA")
												if(!makeSpaceNinja())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)

											if("POINTS_FOR_DEATHSQUAD")
												if(!makeDeathsquad())
													forcenexttick = 1
												else
													potentialgames.Remove(thegame)



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
			eversupressed++
			spawn(6000)
				supress = 0

		else if (href_list["ToggleStatus"])
			config.Tensioner_Active = !config.Tensioner_Active


	proc/makeMalfAImode()

		var/list/mob/living/silicon/AIs = list()
		var/mob/living/silicon/malfAI = null
		var/datum/mind/themind = null

		for(var/mob/living/silicon/ai/ai in world)
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
						if(!jobban_isbanned(applicant, "traitor") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								if(applicant.client)
									candidates += applicant

		if(candidates.len)
			var/numTratiors = min(candidates.len, 3)

			for(var/i = 0, i<numTratiors, i++)
				H = pick(candidates)
				H.mind.make_Tratior()

			return 1

		else
			return 0


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
						if(!jobban_isbanned(applicant, "changeling") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								if(applicant.client)
									candidates += applicant

		if(candidates.len)
			var/numChanglings = min(candidates.len, 3)

			for(var/i = 0, i<numChanglings, i++)
				H = pick(candidates)
				H.mind.make_Changling()

			return 1

		else
			return 0

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
						if(!jobban_isbanned(applicant, "revolutionary") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								if(applicant.client)
									candidates += applicant
		if(candidates.len)
			var/numRevs = min(candidates.len, 3)

			for(var/i = 0, i<numRevs, i++)
				H = pick(candidates)
				H.mind.make_Rev()

			return 1

		else
			return 0

	proc/makeWizard()
		var/list/mob/dead/observer/candidates = list()
		var/mob/dead/observer/theghost = null
		var/time_passed = world.time

		for(var/mob/dead/observer/G in world)
			if(!jobban_isbanned(G, "wizard") && !jobban_isbanned(G, "Syndicate"))
				spawn(0)
					switch(alert(G, "Do you wish to be considered for the position of Space Wizard Foundation 'diplomat'?","Please answer in 30 seconds!","Yes","No"))
						if("Yes")
							if((world.time-time_passed)>300)//If more than 30 game seconds passed.
								return
							candidates += G
						if("No")
							return


		spawn(300)
			if(candidates.len)
				while(!theghost && candidates.len)
					theghost = pick(candidates)
					candidates.Remove(theghost)
				if(!theghost)
					return 0
				var/mob/living/carbon/human/new_character=makeBody(theghost)
				del(theghost)
				new_character.mind.make_Wizard()



		return 1 // Has to return one before it knows if there's a wizard to prevent the parent from automatically selecting another game mode.


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
						if(!jobban_isbanned(applicant, "cultist") && !jobban_isbanned(applicant, "Syndicate"))
							if(!(applicant.job in temp.restricted_jobs))
								if(applicant.client)
									candidates += applicant

		if(candidates.len)
			var/numCultists = min(candidates.len, 4)

			for(var/i = 0, i<numCultists, i++)
				H = pick(candidates)
				H.mind.make_Cultist()
				temp.grant_runeword(H)

				return 1

		else
			return 0



	proc/makeNukeTeam()

		var/list/mob/dead/observer/candidates = list()
		var/mob/dead/observer/theghost = null
		var/time_passed = world.time

		for(var/mob/dead/observer/G in world)
			if(!jobban_isbanned(G, "operative") && !jobban_isbanned(G, "Syndicate"))
				spawn(0)
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
					while(!theghost && candidates.len)
						theghost = pick(candidates)
						candidates.Remove(theghost)
					if(!theghost)
						break
					var/mob/living/carbon/human/new_character=makeBody(theghost)
					del(theghost)
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

			return 1 // Has to return one before it knows if there's a wizard to prevent the parent from automatically selecting another game mode.





	proc/makeAliens()
		alien_infestation(3)
		return 1

	proc/makeSpaceNinja()
		space_ninja_arrival()
		return 1

	proc/makeDeathsquad()
		var/list/mob/dead/observer/candidates = list()
		var/mob/dead/observer/theghost = null
		var/time_passed = world.time
		var/input = "Purify the station."
		if(prob(1))
			input = "Save Runtime and any other cute things on the station."
	/*
		if (emergency_shuttle.direction == 1 && emergency_shuttle.online == 1)
			emergency_shuttle.recall()
			world << "\blue <B>Alert: The shuttle is going back!</B>"
	*/
		var/syndicate_commando_number = syndicate_commandos_possible //for selecting a leader
		var/syndicate_leader_selected = 0 //when the leader is chosen. The last person spawned.

	//Generates a list of commandos from active ghosts. Then the user picks which characters to respawn as the commandos.

		for(var/mob/dead/observer/G in world)
			spawn(0)
				switch(alert(G,"Do you wish to be considered for an elite syndicate strike team being sent in?","Please answer in 30 seconds!","Yes","No"))
					if("Yes")
						if((world.time-time_passed)>300)//If more than 30 game seconds passed.
							return
						candidates += G
					if("No")
						return

		spawn(300)
			if(candidates.len)
				var/numagents = min(candidates.len, 6)

				//Spawns commandos and equips them.
				for (var/obj/effect/landmark/L in world)
					if(numagents<=0)
						break
					if (L.name == "Syndicate-Commando")
						syndicate_leader_selected = syndicate_commando_number == 1?1:0

						var/mob/living/carbon/human/new_syndicate_commando = create_syndicate_death_commando(L, syndicate_leader_selected)

						while(!theghost && candidates.len)
							theghost = pick(candidates)
							candidates.Remove(theghost)

						if(!theghost)
							del(new_syndicate_commando)
							break

							new_syndicate_commando.mind.key = theghost.key//For mind stuff.
							new_syndicate_commando.key = theghost.key
							new_syndicate_commando.internal = new_syndicate_commando.s_store
							new_syndicate_commando.internals.icon_state = "internal1"
							candidates -= theghost
							del(theghost)

						//So they don't forget their code or mission.
						new_syndicate_commando.mind.store_memory("<B>Mission:</B> \red [input].")

						new_syndicate_commando << "\blue You are an Elite Syndicate. [!syndicate_leader_selected?"commando":"<B>LEADER</B>"] in the service of the Syndicate. \nYour current mission is: \red<B> [input]</B>"

						numagents--

			//Spawns the rest of the commando gear.
			//	for (var/obj/effect/landmark/L)
				//	if (L.name == "Commando_Manual")
						//new /obj/item/weapon/gun/energy/pulse_rifle(L.loc)
					//	var/obj/item/weapon/paper/P = new(L.loc)
					//	P.info = "<p><b>Good morning soldier!</b>. This compact guide will familiarize you with standard operating procedure. There are three basic rules to follow:<br>#1 Work as a team.<br>#2 Accomplish your objective at all costs.<br>#3 Leave no witnesses.<br>You are fully equipped and stocked for your mission--before departing on the Spec. Ops. Shuttle due South, make sure that all operatives are ready. Actual mission objective will be relayed to you by Central Command through your headsets.<br>If deemed appropriate, Central Command will also allow members of your team to equip assault power-armor for the mission. You will find the armor storage due West of your position. Once you are ready to leave, utilize the Special Operations shuttle console and toggle the hull doors via the other console.</p><p>In the event that the team does not accomplish their assigned objective in a timely manner, or finds no other way to do so, attached below are instructions on how to operate a Nanotrasen Nuclear Device. Your operations <b>LEADER</b> is provided with a nuclear authentication disk and a pin-pointer for this reason. You may easily recognize them by their rank: Lieutenant, Captain, or Major. The nuclear device itself will be present somewhere on your destination.</p><p>Hello and thank you for choosing Nanotrasen for your nuclear information needs. Today's crash course will deal with the operation of a Fission Class Nanotrasen made Nuclear Device.<br>First and foremost, <b>DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.</b> Pressing any button on the compacted bomb will cause it to extend and bolt itself into place. If this is done to unbolt it one must completely log in which at this time may not be possible.<br>To make the device functional:<br>#1 Place bomb in designated detonation zone<br> #2 Extend and anchor bomb (attack with hand).<br>#3 Insert Nuclear Auth. Disk into slot.<br>#4 Type numeric code into keypad ([nuke_code]).<br>Note: If you make a mistake press R to reset the device.<br>#5 Press the E button to log onto the device.<br>You now have activated the device. To deactivate the buttons at anytime, for example when you have already prepped the bomb for detonation, remove the authentication disk OR press the R on the keypad. Now the bomb CAN ONLY be detonated using the timer. A manual detonation is not an option.<br>Note: Toggle off the <b>SAFETY</b>.<br>Use the - - and + + to set a detonation time between 5 seconds and 10 minutes. Then press the timer toggle button to start the countdown. Now remove the authentication disk so that the buttons deactivate.<br>Note: <b>THE BOMB IS STILL SET AND WILL DETONATE</b><br>Now before you remove the disk if you need to move the bomb you can: Toggle off the anchor, move it, and re-anchor.</p><p>The nuclear authorization code is: <b>[nuke_code ? nuke_code : "None provided"]</b></p><p><b>Good luck, soldier!</b></p>"
					//	P.name = "Spec. Ops. Manual"

				for (var/obj/effect/landmark/L in world)
					if (L.name == "Syndicate-Commando-Bomb")
						new /obj/effect/spawner/newbomb/timer/syndicate(L.loc)
						del(L)

			return 1 // Has to return one before it knows if there's a wizard to prevent the parent from automatically selecting another game mode.

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

	/proc/create_syndicate_death_commando(obj/spawn_location, syndicate_leader_selected = 0)
		var/mob/living/carbon/human/new_syndicate_commando = new(spawn_location.loc)
		var/syndicate_commando_leader_rank = pick("Lieutenant", "Captain", "Major")
		var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
		var/syndicate_commando_name = pick(last_names)

		new_syndicate_commando.gender = pick(MALE, FEMALE)

		var/datum/preferences/A = new()//Randomize appearance for the commando.
		A.randomize_appearance_for(new_syndicate_commando)

		new_syndicate_commando.real_name = "[!syndicate_leader_selected ? syndicate_commando_rank : syndicate_commando_leader_rank] [syndicate_commando_name]"
		new_syndicate_commando.age = !syndicate_leader_selected ? rand(23,35) : rand(35,45)

		new_syndicate_commando.dna.ready_dna(new_syndicate_commando)//Creates DNA.

		//Creates mind stuff.
		new_syndicate_commando.mind = new
		new_syndicate_commando.mind.current = new_syndicate_commando
		new_syndicate_commando.mind.original = new_syndicate_commando
		new_syndicate_commando.mind.assigned_role = "MODE"
		new_syndicate_commando.mind.special_role = "Syndicate Commando"
		if(!(new_syndicate_commando.mind in ticker.minds))
			ticker.minds += new_syndicate_commando.mind//Adds them to regular mind list.
		if(!(new_syndicate_commando.mind in ticker.mode.traitors))//If they weren't already an extra traitor.
			ticker.mode.traitors += new_syndicate_commando.mind//Adds them to current traitor list. Which is really the extra antagonist list.
		new_syndicate_commando.equip_syndicate_commando(syndicate_leader_selected)
		del(spawn_location)
		return new_syndicate_commando
