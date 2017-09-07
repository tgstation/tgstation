/datum/game_mode
	var/list/datum/mind/cult = list()
	var/list/cult_objectives = list()
	var/eldergod = 1 //for the summon god objective

/proc/iscultist(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_CULT)

/proc/is_sacrifice_target(datum/mind/mind)
	if(mind == GLOB.sac_mind)
		return TRUE
	return FALSE

/proc/is_convertable_to_cult(mob/living/M)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(is_sacrifice_target(M.mind))
			return FALSE
		if(M.mind.enslaved_to && !iscultist(M.mind.enslaved_to))
			return FALSE
	else
		return FALSE
	if(M.isloyal() || issilicon(M) || isbot(M) || isdrone(M) || is_servant_of_ratvar(M))
		return FALSE //can't convert machines, shielded, or ratvar's dogs
	return TRUE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	antag_flag = ROLE_CULTIST
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 24
	required_enemies = 4
	recommended_enemies = 4
	enemy_minimum_age = 14

	announce_span = "cult"
	announce_text = "Some crew members are trying to start a cult to Nar-Sie!\n\
	<span class='cult'>Cultists</span>: Carry out Nar-Sie's will.\n\
	<span class='notice'>Crew</span>: Prevent the cult from expanding and drive it out."

	var/finished = 0

	var/acolytes_needed = 10 //for the survive objective
	var/acolytes_survived = 0

	var/list/cultists_to_cult = list() //the cultists we'll convert


/datum/game_mode/cult/pre_setup()
	cult_objectives += "sacrifice"

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	//cult scaling goes here
	recommended_enemies = 3 + round(num_players()/15)


	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = pick(antag_candidates)
		antag_candidates -= cultist
		cultists_to_cult += cultist
		cultist.special_role = "Cultist"
		cultist.restricted_roles = restricted_jobs
		log_game("[cultist.key] (ckey) has been selected as a cultist")

	return (cultists_to_cult.len>=required_enemies)


/datum/game_mode/cult/post_setup()
	modePlayer += cultists_to_cult
	if("sacrifice" in cult_objectives)
		var/list/possible_targets = get_unconvertables()
		if(!possible_targets.len)
			message_admins("Cult Sacrifice: Could not find unconvertable target, checking for convertable target.")
			for(var/mob/living/carbon/human/player in GLOB.player_list)
				if(player.mind && !(player.mind in cultists_to_cult))
					possible_targets += player.mind
		if(possible_targets.len > 0)
			GLOB.sac_mind = pick(possible_targets)
			if(!GLOB.sac_mind)
				message_admins("Cult Sacrifice: ERROR -  Null target chosen!")
			else
				var/datum/job/sacjob = SSjob.GetJob(GLOB.sac_mind.assigned_role)
				var/datum/preferences/sacface = GLOB.sac_mind.current.client.prefs
				var/icon/reshape = get_flat_human_icon(null, sacjob, sacface)
				reshape.Shift(SOUTH, 4)
				reshape.Shift(EAST, 1)
				reshape.Crop(7,4,26,31)
				reshape.Crop(-5,-3,26,30)
				GLOB.sac_image = reshape
		else
			message_admins("Cult Sacrifice: Could not find unconvertable or convertable target. WELP!")
	if(!GLOB.summon_spots.len)
		while(GLOB.summon_spots.len < SUMMON_POSSIBILITIES)
			var/area/summon = pick(GLOB.sortedAreas - GLOB.summon_spots)
			if((summon.z == ZLEVEL_STATION) && summon.valid_territory)
				GLOB.summon_spots += summon
	cult_objectives += "eldergod"

	for(var/datum/mind/cult_mind in cultists_to_cult)
		equip_cultist(cult_mind.current)
		update_cult_icons_added(cult_mind)
		to_chat(cult_mind.current, "<span class='userdanger'>You are a member of the cult!</span>")
		cult_mind.current.playsound_local(get_turf(cult_mind.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
		add_cultist(cult_mind, 0)
	..()

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob,tome = 0)
	if(!istype(mob))
		return
	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.dna.remove_mutation(CLOWNMUT)

	if(tome)
		. += cult_give_item(/obj/item/tome, mob)
	else
		. += cult_give_item(/obj/item/paper/talisman/supply, mob)
	to_chat(mob, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")

/datum/game_mode/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store
	)

	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(mob, "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>")
		return 0
	else
		to_chat(mob, "<span class='danger'>You have a [item_name] in your [where].</span>")
		if(where == "backpack")
			var/obj/item/storage/B = mob.back
			B.orient2hud(mob)
			B.show_to(mob)
		return 1

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind, stun) //BASE
	if (!istype(cult_mind))
		return 0
	if(cult_mind.add_antag_datum(ANTAG_DATUM_CULT))
		if(stun)
			cult_mind.current.Unconscious(100)
		return 1

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, silent, stun)
	if(cult_mind.current)
		var/datum/antagonist/cult/cult_datum = cult_mind.has_antag_datum(ANTAG_DATUM_CULT)
		if(!cult_datum)
			return FALSE
		cult_datum.silent = silent
		cult_datum.on_removal()
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "cult")

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !is_convertable_to_cult(player) && !(player.mind in cultists_to_cult))
			ucs += player.mind
	return ucs

/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(cult_objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(cult_objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(cult_objectives.Find("sacrifice"))
		if(GLOB.sac_mind && !GLOB.sac_complete) //if the target has been GLOB.sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++
	return cult_fail //if any objectives aren't met, failure


/datum/game_mode/cult/proc/check_survive()
	var/acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if (cult_mind.current && cult_mind.current.stat != DEAD)
			if(cult_mind.current.onCentCom() || cult_mind.current.onSyndieBase())
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/datum/game_mode/cult/declare_completion()

	if(!check_cult_victory())
		SSticker.mode_result = "win - cult win"
		to_chat(world, "<span class='greentext'>The cult has succeeded! Nar-sie has snuffed out another torch in the void!</span>")
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		to_chat(world, "<span class='redtext'>The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!</span>")

	var/text = ""

	if(cult_objectives.len)
		text += "<br><b>The cultists' objectives were:</b>"
		for(var/obj_count=1, obj_count <= cult_objectives.len, obj_count++)
			var/explanation
			switch(cult_objectives[obj_count])
				if("survive")
					if(!check_survive())
						explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. ([acolytes_survived] escaped) <span class='greenannounce'>Success!</span>"
						SSblackbox.add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
						SSticker.news_report = CULT_ESCAPE
					else
						explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. ([acolytes_survived] escaped) <span class='boldannounce'>Fail.</span>"
						SSblackbox.add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
						SSticker.news_report = CULT_FAILURE
				if("sacrifice")
					if(GLOB.sac_complete)
						explanation = "Sacrifice [GLOB.sac_mind], the [GLOB.sac_mind.assigned_role]. <span class='greenannounce'>Success!</span>"
						SSblackbox.add_details("cult_objective","cult_sacrifice|SUCCESS")
					else
						explanation = "Sacrifice [GLOB.sac_mind], the [GLOB.sac_mind.assigned_role]. <span class='boldannounce'>Fail.</span>"
						SSblackbox.add_details("cult_objective","cult_sacrifice|FAIL")
				if("eldergod")
					if(!eldergod)
						explanation = "Summon Nar-Sie. The summoning can only be accomplished in [english_list(GLOB.summon_spots)].<span class='greenannounce'>Success!</span>"
						SSblackbox.add_details("cult_objective","cult_narsie|SUCCESS")
						SSticker.news_report = CULT_SUMMON
					else
						explanation = "Summon Nar-Sie. The summoning can only be accomplished in [english_list(GLOB.summon_spots)]<span class='boldannounce'>Fail.</span>"
						SSblackbox.add_details("cult_objective","cult_narsie|FAIL")
						SSticker.news_report = CULT_FAILURE

			text += "<br><B>Objective #[obj_count]</B>: [explanation]"
	to_chat(world, text)
	..()
	return 1


/datum/game_mode/proc/datum_cult_completion()
	var/text = ""
	var/cult_fail = 0
	cult_fail += eldergod
	if(!GLOB.sac_complete)
		cult_fail++
	if(!cult_fail)
		SSticker.mode_result = "win - cult win"
		to_chat(world, "<span class='greentext'>The cult has succeeded! Nar-sie has snuffed out another torch in the void!</span>")
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		to_chat(world, "<span class='redtext'>The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!</span>")
	if(cult_objectives.len)
		text += "<br><b>The cultists' objectives were:</b>"
		for(var/obj_count in 1 to 2)
			var/explanation
			switch(cult_objectives[obj_count])
				if("sacrifice")
					if(GLOB.sac_mind)
						if(GLOB.sac_complete)
							explanation = "Sacrifice [GLOB.sac_mind], the [GLOB.sac_mind.assigned_role]. <span class='greenannounce'>Success!</span>"
							SSblackbox.add_details("cult_objective","cult_sacrifice|SUCCESS")
						else
							explanation = "Sacrifice [GLOB.sac_mind], the [GLOB.sac_mind.assigned_role]. <span class='boldannounce'>Fail.</span>"
							SSblackbox.add_details("cult_objective","cult_sacrifice|FAIL")
				if("eldergod")
					if(!eldergod)
						explanation = "Summon Nar-Sie. <span class='greenannounce'>Success!</span>"
						SSblackbox.add_details("cult_objective","cult_narsie|SUCCESS")
						SSticker.news_report = CULT_SUMMON
					else
						explanation = "Summon Nar-Sie. <span class='boldannounce'>Fail.</span>"
						SSblackbox.add_details("cult_objective","cult_narsie|FAIL")
						SSticker.news_report = CULT_FAILURE
			text += "<br><B>Objective #[obj_count]</B>: [explanation]"
	to_chat(world, text)
