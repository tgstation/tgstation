//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode
	var/list/datum/mind/cult = list()
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")


/proc/iscultist(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.cult)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))	return 0
	if(istype(mind.current, /mob/living/carbon/human) && (mind.assigned_role == "Chaplain"))	return 0
	for(var/obj/item/weapon/implant/loyalty/L in mind.current)
		if(L && (L.imp_in == mind.current))//Checks to see if the person contains an implant, then checks that the implant is actually inside of them
			return 0
	return 1

//Objectives revamped in February 2015 by Deity Link #vgstation

//Cult round flow:
//* at the beginning of the round, cultists aren't able to summon Nar-Sie.
//* during the first phase, cultists start the round with only one objective: either "bloodspill", "convert", or "sacrifice"
//* once they complete that objective, the game checks how well the cult is performing (Are there still at least 4 of them? Are they getting outnumbered by loyalty implanted people?)
//* if the cult is performing well, the game will try to give them another objective among the above three.
//* if the cult is in bad shape, or all objectives have been completed, or none of the remaining possible objectives are feasible, then the game let's them summon Nar-Sie
//* once Nar-Sie is summonned, the shuttle automatically arrives after 10 minutes (even if the shuttle was already on its way) and can't be recalled
//* the cultists get one last bonus objective to complete before the round ends: either "harvest", "hijack", or "massacre"

//* the cult "wins" as soon as it summons Nar-Sie.

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Internal Affairs Agent", "Mobile MMI", "Head of Personnel")
	protected_jobs = list()
	required_players = 5
	required_players_secret = 15
	required_enemies = 3
	recommended_enemies = 4

	uplink_welcome = "Nar-Sie Uplink Console:"//what?
	uplink_uses = 10//whaaaat?

	var/datum/mind/sacrifice_target = null
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/startwords = list("blood","join","self","hell")

	var/list/objectives = list()

	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4
	var/acolytes_survived = 0
	var/ext_survivors = 0

	var/narsie_condition_cleared = 0	//allows Nar-Sie to be summonned during cult rounds. set to 1 once the cult reaches the second phase.
	var/current_objective = 1	//equals the number of cleared objectives + 1
	var/prenarsie_objectives = 2 //how many objectives at most before the cult gets to summon narsie
	var/list/bloody_floors = list()
	var/spilltarget = 100	//how many floor tiles must be covered in blood to complete the bloodspill objective
	var/convert_target = 0	//how many members the cult needs to reach to complete the convert objective
	var/harvested = 0

	var/list/sacrificed = list()	//contains the mind of the sacrifice target ONCE the sacrifice objective has been completed
	var/mass_convert = 0	//set to 1 if the convert objective has been accomplised once that round
	var/spilled_blood = 0	//set to 1 if the bloodspill objective has been accomplised once that round
	var/max_spilled_blood = 0	//highest quantity of blood covered tiles during the round
	var/bonus = 0	//set to 1 if the cult has completed the bonus (third phase) objective (harvest, hijack, massacre)

	var/harvest_target = 10
	var/massacre_target = 5

	var/escaped_shuttle = 0
	var/escaped_pod = 0
	var/survivors = 0

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentCom-allowed faith they had.</B>")


/datum/game_mode/cult/pre_setup()
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)
	for(var/datum/mind/player in cultists_possible)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				cultists_possible -= player

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist

	if(cult.len <= 0)
		log_admin("Failed to set-up a round of cult. Couldn't pick any players to be starting cultists.")
		message_admins("Failed to set-up a round of cult. Couldn't pick any players to be starting cultists.")
	else
		log_admin("Starting a round of cult with [cult.len] starting cultists.")
		message_admins("Starting a round of cult with [cult.len] starting cultists.")

	return (cult.len > 0)

/datum/game_mode/cult/proc/blood_check()
	max_spilled_blood = (max(bloody_floors.len,max_spilled_blood))
	if((objectives[current_objective] == "bloodspill") && (bloody_floors.len >= spilltarget) && !spilled_blood)
		spilled_blood = 1
		additional_phase()

/datum/game_mode/cult/proc/check_numbers()
	if((objectives[current_objective] == "convert") && (cult.len >= convert_target) && !mass_convert)
		mass_convert = 1
		additional_phase()

/datum/game_mode/cult/proc/first_phase()


	var/new_objective = pick_objective()

	objectives += new_objective

	var/explanation

	switch(new_objective)
		if("convert")
			explanation = "We must increase our influence before we can summon Nar-Sie. Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
		if("bloodspill")
			spilltarget = 100 + rand(0,player_list.len * 3)
			explanation = "We must prepare this place for the Geometer of Blood's coming. Spill blood and gibs over [spilltarget] floor tiles."
		if("sacrifice")
			explanation = "We need to sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role], for his blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune (Hell Blood Join) to perform the ritual."

	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		grant_runeword(cult_mind.current)
		update_cult_icons_added(cult_mind)
		cult_mind.special_role = "Cultist"
		to_chat(cult_mind.current, "<span class='sinister'>You are a member of the cult!</span>")
		to_chat(cult_mind.current, "<span class='sinister'>You can now speak and understand the forgotten tongue of Nar-Sie.</span>")
		cult_mind.current.add_language("Cult")
		//memoize_cult_objectives(cult_mind)



		to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

/datum/game_mode/cult/proc/bypass_phase()
	switch(objectives[current_objective])
		if("convert")
			mass_convert = 1
		if("bloodspill")
			spilled_blood = 1
		if("sacrifice")
			sacrificed += sacrifice_target
	additional_phase()

/datum/game_mode/cult/proc/additional_phase()
	current_objective++

	message_admins("Picking a new Cult objective.")
	var/new_objective = "eldergod"
	//the idea here is that if the cult performs well, the should get more objectives before they can summon Nar-Sie.
	if(cult.len >= 4)//if there are less than 4 remaining cultists, they get a free pass to the summon objective.
		if(current_objective <= prenarsie_objectives)
			var/list/unconvertables = get_unconvertables()
			if(unconvertables.len <= (cult.len * 2))//if cultists are getting radically outnumbered, they get a free pass to the summon objective.
				new_objective = pick_objective()
			else
				message_admins("There are over twice more unconvertables than there are cultists ([cult.len] cultists for [unconvertables.len]) unconvertables! Nar-Sie objective unlocked.")
				log_admin("There are over twice more unconvertables than there are cultists ([cult.len] cultists for [unconvertables.len]) unconvertables! Nar-Sie objective unlocked.")
		else
			message_admins("The Cult has already completed [prenarsie_objectives] objectives! Nar-Sie objective unlocked.")
			log_admin("The Cult has already completed [prenarsie_objectives] objectives! Nar-Sie objective unlocked.")
	else
		message_admins("There are less than 4 cultists! Nar-Sie objective unlocked.")
		log_admin("There are less than 4 cultists! Nar-Sie objective unlocked.")

	if(!sacrificed.len && (new_objective != "sacrifice"))
		sacrifice_target = null

	if(new_objective == "eldergod")
		second_phase()
		return
	else
		objectives += new_objective

		var/explanation

		switch(new_objective)
			if("convert")
				explanation = "We must increase our influence before we can summon Nar-Sie. Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
			if("bloodspill")
				spilltarget = 100 + rand(0,player_list.len * 3)
				explanation = "We must prepare this place for the Geometer of Blood's coming. Spread blood and gibs over [spilltarget] of the Station's floor tiles."
			if("sacrifice")
				explanation = "We need to sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role], for his blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune (Hell Blood Join) to perform the ritual."

		for(var/datum/mind/cult_mind in cult)
			to_chat(cult_mind.current, "<span class='sinister'>You and your acolytes have completed your task, but this place requires yet more preparation!</span>")
			to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
			cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

		message_admins("New Cult Objective: [new_objective]")
		log_admin("New Cult Objective: [new_objective]")

		blood_check()//in case there are already enough blood covered tiles when the objective is given.

/datum/game_mode/cult/proc/second_phase()
	narsie_condition_cleared = 1

	objectives += "eldergod"

	var/explanation = "Summon Nar-Sie on the Station via the use of the Tear Reality rune (Hell Join Self). You will need 9 cultists standing on and around the rune to summon Him."

	for(var/datum/mind/cult_mind in cult)
		to_chat(cult_mind.current, "<span class='sinister'>You and your acolytes have succeeded in preparing the station for the ultimate ritual!</span>")
		to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

/datum/game_mode/cult/proc/third_phase()
	current_objective++

	sleep(10)

	var/last_objective = pick_bonus_objective()

	objectives += last_objective

	var/explanation

	switch(last_objective)
		if("harvest")
			explanation = "The Geometer of Blood hungers for his first meal of this never-ending day. Offer him [harvest_target] humans in sacrifice."
		if("hijack")
			explanation = "Nar-Sie wishes for his troops to start the assault on Centcom immediately. Hijack the escape shuttle and don't let a single non-cultist board it."
		if("massacre")
			explanation = "Nar-Sie wants to watch you as you massacre the remaining humans on the station (until less than [massacre_target] humans are left alive)."

	for(var/datum/mind/cult_mind in cult)
		to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"

	message_admins("Last Cult Objective: [last_objective]")
	log_admin("Last Cult Objective: [last_objective]")

/datum/game_mode/cult/post_setup()
	modePlayer += cult

	first_phase()

	if(!mixed)
		spawn (rand(waittime_l, waittime_h))
			send_intercept()
	..()

/datum/game_mode/cult/proc/pick_objective()
	var/list/possible_objectives = list()

	if(!spilled_blood && (bloody_floors.len < spilltarget))
		possible_objectives |= "bloodspill"

	if(!sacrificed.len)
		var/list/possible_targets = list()
		for(var/mob/living/carbon/human/player in player_list)
			if(player.z == map.zCentcomm) //We can't sacrifice people that are on the centcom z-level
				continue
			if(player.mind && !is_convertable_to_cult(player.mind) && (player.stat != DEAD))
				possible_targets += player.mind

		if(!possible_targets.len)
			//There are no living Unconvertables on the station. Looking for a Sacrifice Target among the ordinary crewmembers
			for(var/mob/living/carbon/human/player in player_list)
				if(player.z == map.zCentcomm) //We can't sacrifice people that are on the centcom z-level
					continue
				if(player.mind && !(player.mind in cult))
					possible_targets += player.mind

		if(possible_targets.len > 0)
			sacrifice_target = pick(possible_targets)
			possible_objectives |= "sacrifice"
		else
			message_admins("Didn't find a suitable sacrifice target...what the hell? Shout at Deity.")
			log_admin("Didn't find a suitable sacrifice target...what the hell? Shout at Deity.")

	if(!mass_convert)
		var/living_crew = 0
		var/living_cultists = 0
		for(var/mob/living/L in player_list)
			if(L.stat != DEAD)
				if(L.mind in cult)
					living_cultists++
				else
					if(istype(L, /mob/living/carbon))
						living_crew++

		var/total = living_crew + living_cultists

		if((living_cultists * 2) < total)
			if (total < 15)
				message_admins("There are [total] players, too little for the mass convert objective!")
				log_admin("There are [total] players, too little for the mass convert objective!")
			else if (total > 50)
				message_admins("There are [total] players, too many for the mass convert objective!")
				log_admin("There are [total] players, too many for the mass convert objective!")
			else
				possible_objectives |= "convert"
				convert_target = round(total / 2)

	if(!possible_objectives.len)//No more possible objectives, time to summon Nar-Sie
		message_admins("No suitable objectives left! Nar-Sie objective unlocked.")
		log_admin("No suitable objectives left! Nar-Sie objective unlocked.")
		return "eldergod"
	else
		return pick(possible_objectives)

/datum/game_mode/cult/proc/pick_bonus_objective()
	var/list/possible_objectives = list()

	var/living_crew = 0
	for(var/mob/living/carbon/C in player_list)
		if(C.stat != DEAD)
			if(!(C.mind in cult))
				var/turf/T = get_turf(C)
				if(T.z == map.zMainStation)	//we're only interested in the remaining humans on the station
					living_crew++

	if(living_crew > 5)
		possible_objectives |= "massacre"

	if(living_crew > 10)
		possible_objectives |= "harvest"

	possible_objectives |= "hijack"	//we need at least one objective guarranted to fire

	return pick(possible_objectives)


/datum/game_mode/cult/proc/memoize_cult_objectives(var/datum/mind/cult_mind)
	to_chat(cult_mind.current, "The convert rune is Join Blood Self")
	cult_mind.memory += "The convert rune is Join Blood Self<BR>"
	var/explanation
	switch(objectives[current_objective])
		if("convert")
			explanation = "We must increase our influence before we can summon Nar-Sie. Convert [convert_target] crew members. Take it slowly to avoid raising suspicions."
		if("bloodspill")
			explanation = "We must prepare this place for the Geometer of Blood's coming. Spill blood and gibs over [spilltarget] floor tiles."
		if("sacrifice")
			explanation = "We need to sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role], for his blood is the key that will lead our master to this realm. You will need 3 cultists around a Sacrifice rune (Hell Blood Join) to perform the ritual."
		if("eldergod")
			explanation = "Summon Nar-Sie via the use of the Tear Reality rune (Hell Join Self). You will need 9 cultists standing on and around the rune to summon Him."
	to_chat(cult_mind.current, "<B>Objective #[current_objective]</B>: [explanation]")
	cult_mind.memory += "<B>Objective #[current_objective]</B>: [explanation]<BR>"


/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(M_CLUMSY)


	var/obj/item/weapon/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots, EQUIP_FAILACTION_DROP)
	if (!where)
		to_chat(mob, "<span class='sinister'>Unfortunately, you weren't able to sneak in a talisman. Pray, and He most likely shall get you one.</span>")
	else
		to_chat(mob, "<span class='sinister'>You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.</span>")
		mob.update_icons()
		return 1


/datum/game_mode/cult/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if (!word)
		if(startwords.len > 0)
			word=pick(startwords)
			startwords -= word
	return ..(cult_mob,word)


/datum/game_mode/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if(!cultwords["travel"])
		runerandom()
	if (!word)
		word=pick(allwords)
	var/wordexp = "[cultwords[word]] is [word]..."
	to_chat(cult_mob, "<span class='sinister'>You remember one thing from the dark teachings of your master... [wordexp]</span>")
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0, 0)


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if (!istype(cult_mind))
		return 0
	if(!(cult_mind in cult) && is_convertable_to_cult(cult_mind))
		cult += cult_mind
		update_cult_icons_added(cult_mind)
		if(name == "cult")
			var/datum/game_mode/cult/C = src
			C.check_numbers()
		return 1


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	memoize_cult_objectives(cult_mind)


/datum/game_mode/proc/remove_cultist(var/datum/mind/cult_mind, var/show_message = 1, var/log=1)
	if(cult_mind in cult)
		update_cult_icons_removed(cult_mind)
		cult -= cult_mind
		to_chat(cult_mind.current, "<span class='danger'><FONT size = 3>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and removing all of the memories of your time as his servant, except the one who converted you, with it.</FONT></span>")
		to_chat(cult_mind.current, "<span class='danger'>You find yourself unable to mouth the words of the forgotten...</span>")
		cult_mind.current.remove_language("Cult")
		cult_mind.memory = ""

		if(show_message)
			for(var/mob/M in viewers(cult_mind.current))
				to_chat(M, "<FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</FONT>")
		if(log)
			log_admin("[cult_mind.current] ([ckey(cult_mind.current.key)] has been deconverted from the cult")

/datum/game_mode/proc/update_all_cult_icons()
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult")
							cultist.current.client.images -= I

		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/datum/mind/cultist_1 in cult)
						if(cultist_1.current)
							var/imageloc = cultist_1.current
							if(istype(cultist_1.current.loc,/obj/mecha))
								imageloc = cultist_1.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "cult")
							cultist.current.client.images += I


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	if(!cult_mind)
		return 0
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					var/imageloc = cult_mind.current
					if(istype(cult_mind.current.loc,/obj/mecha))
						imageloc = cult_mind.current.loc
					var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "cult", layer = 13)
					cultist.current.client.images += I
			if(cult_mind.current)
				if(cult_mind.current.client)
					var/imageloc = cultist.current
					if(istype(cultist.current.loc,/obj/mecha))
						imageloc = cultist.current.loc
					var/image/J = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "cult", layer = 13)
					cult_mind.current.client.images += J


/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult" && ((I.loc == cult_mind.current) || (I.loc == cult_mind.current.loc)))
							cultist.current.client.images -= I

		if(cult_mind.current)
			if(cult_mind.current.client)
				for(var/image/I in cult_mind.current.client.images)
					if(I.icon_state == "cult")
						cult_mind.current.client.images -= I


/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(player.mind && (!is_convertable_to_cult(player.mind) || jobban_isbanned(player, "cultist")))
			ucs += player.mind
	return ucs

/datum/game_mode/cult/proc/bonus_check()
	if(universe.name == "Hell Rising")
		switch(objectives[current_objective])
			if("harvest")
				if(harvested >= harvest_target)
					bonus = 1

			if("hijack")
				for(var/mob/living/L in player_list)
					if(L.stat != DEAD)
						if(!(L.mind in cult))
							var/turf/T = get_turf(L)
							if(istype(T.loc, /area/shuttle/escape/centcom))
								escaped_shuttle++
							else if(istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
								escaped_pod++
				if(!escaped_shuttle)
					bonus = 1

			if("massacre")
				for(var/mob/living/carbon/C in player_list)
					if(C.stat != DEAD)
						if(!(C.mind in cult))
							var/turf/T = get_turf(C)
							if(T.z == map.zMainStation)	//we're only interested in the remaining humans on the station
								survivors++
				if(survivors < massacre_target)
					bonus = 1

/datum/game_mode/cult/declare_completion()

	bonus_check()

	if(universe.name == "Hell Rising")
		if(bonus)
			feedback_set_details("round_end_result","win - narsie summoned - all objectives completed")
			completion_text += "<FONT size = 3><B>Cult Total Victory!</B></FONT>"
			completion_text +=  "<BR><B>The Cult has summoned Nar-Sie and fulfilled all of his requests</B>"
		else
			feedback_set_details("round_end_result","win - narsie summoned")
			completion_text +=  "<FONT size = 3><B>Cult Major Victory!</B></FONT>"
			completion_text +=  "<BR><B>The Cult has managed to summon Nar-Sie</B>"
	else
		if(current_objective > 1)
			feedback_set_details("round_end_result","halfwin - some objectives completed")
			completion_text +=  "<FONT size = 3><B>Crew Minor Victory!</B></FONT>"
			completion_text +=  "<BR><B>The Cult didn't summon Nar-Sie in time but still managed to fulfill some of his requests.</B>"
		else
			feedback_set_details("round_end_result","loss - no objective done")
			completion_text +=  "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
			completion_text +=  "<BR><B>The Staff has managed to stop the Cult</B>"

	var/text = "<BR><b>Objectives Completed:</b> [current_objective - 1 + bonus]"

	if(objectives.len)
		text += "<br><b>The cultists' objectives were:</b>"
		for(var/obj_count=1, obj_count <= objectives.len, obj_count++)
			var/explanation
			switch(objectives[obj_count])
				if("convert")//convert half the crew
					if(obj_count < objectives.len)
						explanation = "Convert [convert_target] crewmembers ([cult.len] cultists at round end). <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_convertion|SUCCESS")
					else
						explanation = "Convert [convert_target] crewmembers ([cult.len] total cultists). <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_convertion|FAIL")

				if("bloodspill")//cover a large portion of the station in blood
					if(obj_count < objectives.len)
						explanation = "Cover [spilltarget] tiles of the station in blood (The peak number of covered tiles was: [max_spilled_blood]). <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_bloodspill|SUCCESS")
					else
						explanation = "Cover [spilltarget] tiles of the station in blood (The peak number of covered tiles was: [max_spilled_blood]). <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_bloodspill|FAIL")

				if("sacrifice")//sacrifice a high value target
					if(sacrifice_target)
						if(sacrifice_target in sacrificed)
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='green'><B>Success!</B></font>"
							feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
						else if(sacrifice_target && sacrifice_target.current)
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Fail.</font>"
							feedback_add_details("cult_objective","cult_sacrifice|FAIL")
						else
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Fail (Gibbed).</font>"
							feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")

				if("eldergod")//summon narsie
					if(universe.name == "Hell Rising")
						explanation = "Summon Nar-Sie. <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_narsie|SUCCESS")
					else
						explanation = "Summon Nar-Sie. <font color='red'>Fail.</font>"
						feedback_add_details("cult_objective","cult_narsie|FAIL")

				if("harvest")
					if(harvested > harvest_target)
						explanation = "Offer [harvest_target] humans for Nar-Sie's first meal of the day. ([harvested] eaten) <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_harvest|SUCCESS")
					else
						explanation = "Offer [harvest_target] humans for Nar-Sie's first meal of the day. ([harvested] eaten) <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_harvest|FAIL")

				if("hijack")
					if(!escaped_shuttle)
						explanation = "Do not let a single non-cultist board the Escape Shuttle. ([escaped_shuttle] escaped on the shuttle) ([escaped_pod] escaped on pods) <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_hijack|SUCCESS")
					else
						explanation = "Do not let a single non-cultist board the Escape Shuttle. ([escaped_shuttle] escaped on the shuttle) ([escaped_pod] escaped on pods) <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_hijack|FAIL")

				if("massacre")
					if(survivors < massacre_target)
						explanation = "Massacre the crew until less than [massacre_target] humans are left on the station. ([survivors] humans left alive) <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_massacre|SUCCESS")
					else
						explanation = "Massacre the crew until less than [massacre_target] humans are left on the station. ([survivors] humans left alive) <font color='red'><B>Fail!</B></font>"
						feedback_add_details("cult_objective","cult_massacre|FAIL")

			text += "<br><B>Objective #[obj_count]</B>: [explanation]"

	completion_text += text
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_cult()
	var/text = ""
	if( cult.len || (ticker && istype(ticker.mode,/datum/game_mode/cult)) )
		var/icon/logo = icon('icons/mob/mob.dmi', "cult-logo")
		end_icons += logo
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <FONT size = 2><B>The cultists were:</B></FONT> <img src="logo_[tempstate].png">"}
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				var/icon/flat = getFlatIcon(cultist.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[cultist.key]</b> was <b>[cultist.name]</b> ("}
				if(cultist.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(cultist.current.real_name != cultist.name)
					text += " as [cultist.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> [cultist.key] was [cultist.name] ("}
				text += "body destroyed"
			text += ")"
		text += "<BR><HR>"

	return text
