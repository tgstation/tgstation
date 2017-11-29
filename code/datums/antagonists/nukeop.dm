#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8

/datum/antagonist/nukeop
	name = "Nuclear Operative"
	job_rank = ROLE_OPERATIVE
	var/datum/objective_team/nuclear/nuke_team
	var/always_new_team = FALSE //If not assigned a team by default ops will try to join existing ones, set this to TRUE to always create new team.
	var/send_to_spawnpoint = TRUE //Should the user be moved to default spawnpoint.
	var/nukeop_outfit = /datum/outfit/syndicate

/datum/antagonist/nukeop/proc/update_synd_icons_added(mob/living/M)
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.join_hud(M)
	set_antag_hud(M, "synd")

/datum/antagonist/nukeop/proc/update_synd_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/opshud = GLOB.huds[ANTAG_HUD_OPS]
	opshud.leave_hud(M)
	set_antag_hud(M, null)

/datum/antagonist/nukeop/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_synd_icons_added(M)

/datum/antagonist/nukeop/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_synd_icons_removed(M)

/datum/antagonist/nukeop/proc/equip_op()
	if(!ishuman(owner.current))
		return
	var/mob/living/carbon/human/H = owner.current
	
	H.set_species(/datum/species/human) //Plasamen burn up otherwise, and lizards are vulnerable to asimov AIs

	H.equipOutfit(nukeop_outfit)
	return TRUE

/datum/antagonist/nukeop/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='notice'>You are a [nuke_team ? nuke_team.syndicate_name : "syndicate"] agent!</span>")
	owner.announce_objectives()
	return

/datum/antagonist/nukeop/on_gain()
	give_alias()
	forge_objectives()
	. = ..()
	equip_op()
	memorize_code()
	if(send_to_spawnpoint)
		move_to_spawnpoint()

/datum/antagonist/nukeop/get_team()
	return nuke_team

/datum/antagonist/nukeop/proc/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_nukecode()
		var/obj/machinery/nuclearbomb/nuke = locate("syndienuke") in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == "ADMIN")
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Syndicate nuke not found during nuke team creation.")
			nuke_team.memorized_code = null

/datum/antagonist/nukeop/proc/give_alias()
	if(nuke_team && nuke_team.syndicate_name)
		var/number = 1
		number = nuke_team.members.Find(owner)
		owner.current.real_name = "[nuke_team.syndicate_name] Operative #[number]"

/datum/antagonist/nukeop/proc/memorize_code()
	if(nuke_team && nuke_team.tracked_nuke && nuke_team.memorized_code)
		owner.store_memory("<B>[nuke_team.tracked_nuke] Code</B>: [nuke_team.memorized_code]", 0, 0)
		to_chat(owner, "The nuclear authorization code is: <B>[nuke_team.memorized_code]</B>")
	else
		to_chat(owner, "Unfortunately the syndicate was unable to provide you with nuclear authorization code.")

/datum/antagonist/nukeop/proc/forge_objectives()
	if(nuke_team)
		owner.objectives |= nuke_team.objectives

/datum/antagonist/nukeop/proc/move_to_spawnpoint()
	var/team_number = 1
	if(nuke_team)
		team_number = nuke_team.members.Find(owner)
	owner.current.forceMove(GLOB.nukeop_start[((team_number - 1) % GLOB.nukeop_start.len) + 1])

/datum/antagonist/nukeop/leader/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.nukeop_leader_start))

/datum/antagonist/nukeop/create_team(datum/objective_team/nuclear/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/nukeop/N in GLOB.antagonists)
				if(N.nuke_team)
					nuke_team = N.nuke_team
					return
		nuke_team = new /datum/objective_team/nuclear
		nuke_team.update_objectives()
		assign_nuke() //This is bit ugly
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	nuke_team = new_team

/datum/antagonist/nukeop/leader
	name = "Nuclear Operative Leader"
	nukeop_outfit = /datum/outfit/syndicate/leader
	always_new_team = TRUE
	var/title

/datum/antagonist/nukeop/leader/memorize_code()
	..()
	if(nuke_team && nuke_team.memorized_code)
		var/obj/item/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_team.memorized_code]</b>"
		P.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = owner.current
		if(!istype(H))
			P.forceMove(get_turf(H))
		else
			H.put_in_hands(P, TRUE)
			H.update_icons()

/datum/antagonist/nukeop/leader/give_alias()
	title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	if(nuke_team && nuke_team.syndicate_name)
		owner.current.real_name = "[nuke_team.syndicate_name] [title]"
	else
		owner.current.real_name = "Syndicate [title]"

/datum/antagonist/nukeop/leader/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<B>You are the Syndicate [title] for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</B>")
	to_chat(owner, "<B>If you feel you are not up to this task, give your ID to another operative.</B>")
	to_chat(owner, "<B>In your hand you will find a special item capable of triggering a greater challenge for your team. Examine it carefully and consult with your fellow operatives before activating it.</B>")
	owner.announce_objectives()
	addtimer(CALLBACK(src, .proc/nuketeam_name_assign), 1)


/datum/antagonist/nukeop/leader/proc/nuketeam_name_assign()
	if(!nuke_team)
		return
	nuke_team.rename_team(ask_name())

/datum/objective_team/nuclear/proc/rename_team(new_name)
	syndicate_name = new_name
	name = "[syndicate_name] Team"
	for(var/I in members)
		var/datum/mind/synd_mind = I
		var/mob/living/carbon/human/H = synd_mind.current
		if(!istype(H))
			continue
		var/chosen_name = H.dna.species.random_name(H.gender,0,syndicate_name)
		H.fully_replace_character_name(H.real_name,chosen_name)

/datum/antagonist/nukeop/leader/proc/ask_name()
	var/randomname = pick(GLOB.last_names)
	var/newname = stripped_input(owner.current,"You are the nuke operative [title]. Please choose a last name for your family.", "Name change",randomname)
	if (!newname)
		newname = randomname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = randomname

	return capitalize(newname)

/datum/antagonist/nukeop/lone
	name = "Lone Operative"
	always_new_team = TRUE
	send_to_spawnpoint = FALSE //Handled by event
	nukeop_outfit = /datum/outfit/syndicate/full

/datum/antagonist/nukeop/lone/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_nukecode()
		var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == "ADMIN")
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Station self destruct ot found during lone op team creation.")
			nuke_team.memorized_code = null

/datum/objective_team/nuclear
	var/list/objectives
	var/syndicate_name
	var/obj/machinery/nuclearbomb/tracked_nuke
	var/core_objective = /datum/objective/nuclear
	var/memorized_code

/datum/objective_team/nuclear/New()
	..()
	syndicate_name = syndicate_name()

/datum/objective_team/nuclear/proc/update_objectives()
	objectives = list()
	if(core_objective)
		var/datum/objective/O = new core_objective
		O.team = src
		objectives += O
	return

/datum/objective_team/nuclear/proc/disk_rescued()
	for(var/obj/item/disk/nuclear/D in GLOB.poi_list)
		if(!D.onCentCom())
			return FALSE
	return TRUE

/datum/objective_team/nuclear/proc/operatives_dead()
	for(var/I in members)
		var/datum/mind/operative_mind = I
		if(ishuman(operative_mind.current) && (operative_mind.current.stat != DEAD))
			return FALSE
	return TRUE

/datum/objective_team/nuclear/proc/syndies_escaped()
	var/obj/docking_port/mobile/S = SSshuttle.getShuttle("syndicate")
	return (S && (S.z == ZLEVEL_CENTCOM || S.z == ZLEVEL_TRANSIT))

/datum/objective_team/nuclear/proc/get_result()
	var/evacuation = SSshuttle.emergency.mode == SHUTTLE_ENDGAME
	var/disk_rescued = disk_rescued()
	var/syndies_didnt_escape = !syndies_escaped()
	var/station_was_nuked = SSticker.mode.station_was_nuked
	var/nuke_off_station = SSticker.mode.nuke_off_station

	if(nuke_off_station == NUKE_SYNDICATE_BASE)
		return NUKE_RESULT_FLUKE
	else if(!disk_rescued && station_was_nuked && !syndies_didnt_escape)
		return NUKE_RESULT_NUKE_WIN
	else if (!disk_rescued &&  station_was_nuked && syndies_didnt_escape)
		return NUKE_RESULT_NOSURVIVORS
	else if (!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		return NUKE_RESULT_WRONG_STATION
	else if (!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		return NUKE_RESULT_WRONG_STATION_DEAD
	else if ((disk_rescued || evacuation) && operatives_dead())
		return NUKE_RESULT_CREW_WIN_SYNDIES_DEAD
	else if (disk_rescued)
		return NUKE_RESULT_CREW_WIN
	else if (!disk_rescued && operatives_dead())
		return NUKE_RESULT_DISK_LOST
	else if (!disk_rescued &&  evacuation)
		return NUKE_RESULT_DISK_STOLEN
	else
		return	//Undefined result

/datum/objective_team/nuclear/proc/roundend_display()
	to_chat(world,"<span class='roundendh'>[syndicate_name] Operatives:</span>")
	
	switch(get_result())
		if(NUKE_RESULT_FLUKE)
			to_chat(world, "<FONT size = 3><B>Humiliating Syndicate Defeat</B></FONT>")
			to_chat(world, "<B>The crew of [station_name()] gave [syndicate_name] operatives back their bomb! The syndicate base was destroyed!</B> Next time, don't lose the nuke!")
		if(NUKE_RESULT_NUKE_WIN)
			to_chat(world, "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>")
			to_chat(world, "<B>[syndicate_name] operatives have destroyed [station_name()]!</B>")
		if(NUKE_RESULT_NOSURVIVORS)
			to_chat(world, "<FONT size = 3><B>Total Annihilation</B></FONT>")
			to_chat(world, "<B>[syndicate_name] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!")
		if(NUKE_RESULT_WRONG_STATION)
			to_chat(world, "<FONT size = 3><B>Crew Minor Victory</B></FONT>")
			to_chat(world, "<B>[syndicate_name] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't do that!")
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			to_chat(world, "<FONT size = 3><B>[syndicate_name] operatives have earned Darwin Award!</B></FONT>")
			to_chat(world, "<B>[syndicate_name] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't do that!")
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			to_chat(world, "<FONT size = 3><B>Crew Major Victory!</B></FONT>")
			to_chat(world, "<B>The Research Staff has saved the disk and killed the [syndicate_name] Operatives</B>")
		if(NUKE_RESULT_CREW_WIN)
			to_chat(world, "<FONT size = 3><B>Crew Major Victory</B></FONT>")
			to_chat(world, "<B>The Research Staff has saved the disk and stopped the [syndicate_name] Operatives!</B>")
		if(NUKE_RESULT_DISK_LOST)
			to_chat(world, "<FONT size = 3><B>Neutral Victory!</B></FONT>")
			to_chat(world, "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name] Operatives!</B>")
		if(NUKE_RESULT_DISK_STOLEN)
			to_chat(world, "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>")
			to_chat(world, "<B>[syndicate_name] operatives survived the assault but did not achieve the destruction of [station_name()].</B> Next time, don't lose the disk!")
		else
			to_chat(world, "<FONT size = 3><B>Neutral Victory</B></FONT>")
			to_chat(world, "<B>Mission aborted!</B>")

	var/text = "<br><FONT size=3><B>The syndicate operatives were:</B></FONT>"
	var/purchases = ""
	var/TC_uses = 0
	for(var/I in members)
		var/datum/mind/syndicate = I
		text += SSticker.mode.printplayer(syndicate) //to be moved
		for(var/U in GLOB.uplinks)
			var/datum/component/uplink/H = U
			if(H.owner == syndicate.key)
				TC_uses += H.spent_telecrystals
				if(H.purchase_log)
					purchases += H.purchase_log.generate_render(show_key = FALSE)
				else
					stack_trace("WARNING: Nuke Op uplink with no purchase_log Owner: [H.owner]")
	text += "<br>"
	text += "(Syndicates used [TC_uses] TC) [purchases]"
	if(TC_uses == 0 && SSticker.mode.station_was_nuked && !operatives_dead())
		text += "<BIG>[icon2html('icons/badass.dmi', world, "badass")]</BIG>"
	to_chat(world, text)
