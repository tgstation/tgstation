#define MEDAL_PREFIX "Boss"


/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 400
	light_range = 3
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")
	movement_type = FLYING
	robust_searching = 1
	ranged_ignores_vision = TRUE
	stat_attack = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	minbodytemp = 0
	maxbodytemp = INFINITY
	aggro_vision_range = 18
	idle_vision_range = 5
	environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/girder,
	/obj/structure/rack,
	/obj/structure/barricade,
	/obj/machinery/field,
	/obj/machinery/power/emitter)
	var/list/crusher_loot
	var/medal_type = MEDAL_PREFIX
	var/score_type = BOSS_SCORE
	var/elimination = 0
	var/anger_modifier = 0

	var/phase = 1 //The "phase" the boss is in; different phases might have different moves.
	var/phase_transition_style = ONE_PHASE //The method the boss uses to transition from phase to phase; see "phases.dm" in __DEFINES for the whole list
	var/list/transition_to_phase_text //Associative list (syntax: "phase number" = "string") - text shown when moving UP to these phases
	var/list/transition_from_phase_text //Associative list (syntax: "phase number" = "string") - text shown when moving DOWN to these phases
	var/list/phase_transition_sound //Associative list (syntax: "phase number" = 'sound path') - sound played when moving to these phases
	var/list/phase_examines //Associative list (syntax: "phase number" = "string") - text shown on examine while the mob's in these phases
	var/list/phase_transition_threshold //Associative list (syntax: "phase number" = % of max health as decimal) - health thresholds to swap phases at, if applicable

	var/obj/item/device/gps/internal
	anchored = TRUE
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	mouse_opacity = 2 // Easier to click on in melee, they're giant targets anyway

/mob/living/simple_animal/hostile/megafauna/Initialize(mapload)
	. = ..()
	apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)

/mob/living/simple_animal/hostile/megafauna/Destroy()
	QDEL_NULL(internal)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/Life()
	..()
	handle_phases()

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(health > 0)
		return
	else
		var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(C && crusher_loot)
			if(C.total_damage >= maxHealth * 0.60) //if you do at least 60% of its health with the crusher, you'll get the item
				spawn_crusher_loot()
		if(!admin_spawned)
			SSblackbox.set_details("megafauna_kills","[initial(name)]")
			if(!elimination)	//used so the achievment only occurs for the last legion to die.
				grant_achievement(medal_type,score_type)
		..()

/mob/living/simple_animal/hostile/megafauna/examine(mob/user)
	..()
	if(!stat && phase_examines["[phase]"])
		to_chat(user, phase_examines["[phase]"])

/mob/living/simple_animal/hostile/megafauna/proc/spawn_crusher_loot()
	loot = crusher_loot

/mob/living/simple_animal/hostile/megafauna/gib()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/dust()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()
		else
			devour(L)

/mob/living/simple_animal/hostile/megafauna/onShuttleMove()
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] [ADMIN_FLW(src)] moved via shuttle from [ADMIN_COORDJMP(oldloc)] to [ADMIN_COORDJMP(newloc)]")

/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/L)
	if(!L)
		return
	visible_message(
		"<span class='danger'>[src] devours [L]!</span>",
		"<span class='userdanger'>You feast on [L], restoring your health!</span>")
	if(z != ZLEVEL_STATION && !client) //NPC monsters won't heal while on station
		adjustBruteLoss(-L.maxHealth/2)
	L.gib()

/mob/living/simple_animal/hostile/megafauna/proc/handle_phases()
	switch(phase_transition_style)
		if(ONE_PHASE) //no extra phases, no reason to switch!
			return
		if(PHASE_TRANSITION_HEALTH)
			if(!phase_transition_threshold.len) //how'd this even happen?
				WARNING("Megafauna [name] ([x], [y], [z]) tried to check health thresholds for phases without actually having any thresholds defined. Yell at the coders!")
				phase_transition_style = ONE_PHASE
				return
			for(var/V in phase_transition_threshold)
				var/threshold = phase_transition_threshold[V]
				if(health / maxHealth <= threshold && "[phase]" != V) //if we're lower than the threshold, swap phases (as long as we're not in that phase already!)
					phase_transition(text2num(V))
				else if(health / maxHealth > threshold && phase == text2num(V) && phase_transition_style != PHASE_TRANSITION_HEALTH_NOREGRESS) //we can also regress to old phases!
					phase_transition(phase - 1)
		if(PHASE_TRANSITION_SET_POINT)
			check_phase_transition()

/mob/living/simple_animal/hostile/megafauna/proc/check_phase_transition() //Override this proc for any megafauna that switches phases with set conditions!
	return

/mob/living/simple_animal/hostile/megafauna/proc/phase_transition(to_phase) //Signals a phase transition
	if(!to_phase)
		return
	if(phase_transition_sound["[to_phase]"]) //this uses a string so as not to be funky with list associations and index positions
		playsound(src, phase_transition_sound["[to_phase]"], 50, 0)
	if(to_phase > phase) //Transitioning to the next phase
		if(transition_to_phase_text["[to_phase]"])
			visible_message(transition_to_phase_text["[to_phase]"])
	else //Transitioning back to the previous phase
		if(transition_from_phase_text["[to_phase]"])
			visible_message(transition_from_phase_text["[to_phase]"])
	log_message("Transitioned from phase <b>[phase]</b> to phase <b>[to_phase]</b>", INDIVIDUAL_ATTACK_LOG)
	phase = to_phase
	enter_phase_effects()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/proc/enter_phase_effects() //Override this with any procs/effects/attacks/etc. you want to occur just after a phase swap
	return

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch (severity)
		if (1)
			adjustBruteLoss(250)

		if (2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)



/mob/living/simple_animal/hostile/megafauna/proc/grant_achievement(medaltype,scoretype)
	if(medal_type == "Boss")	//Don't award medals if the medal type isn't set
		return FALSE

	if(admin_spawned)
		return FALSE

	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		for(var/mob/living/L in view(7,src))
			if(L.stat)
				continue
			if(L.client)
				var/client/C = L.client
				var/suffixm = BOSS_KILL_MEDAL
				UnlockMedal("Boss [suffixm]",C)
				UnlockMedal("[medaltype] [suffixm]",C)
				SetScore(BOSS_SCORE,C,1)
				SetScore(score_type,C,1)
	return TRUE

/proc/UnlockMedal(medal,client/player)

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		spawn()
			var/result = world.SetMedal(medal, player, global.medal_hub, global.medal_pass)
			if(isnull(result))
				global.medals_enabled = FALSE
				log_game("MEDAL ERROR: Could not contact hub to award medal:[medal] player:[player.ckey]")
				message_admins("Error! Failed to contact hub to award [medal] medal to [player.ckey]!")
			else if (result)
				to_chat(player, "<span class='greenannounce'><B>Achievement unlocked: [medal]!</B></span>")


/proc/SetScore(score,client/player,increment,force)

	if(!score || !player)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		spawn()
			var/list/oldscore = GetScore(score,player,1)

			if(increment)
				if(!oldscore[score])
					oldscore[score] = 1
				else
					oldscore[score] = (text2num(oldscore[score]) + 1)
			else
				oldscore[score] = force

			var/newscoreparam = list2params(oldscore)

			var/result = world.SetScores(player.ckey, newscoreparam, global.medal_hub, global.medal_pass)

			if(isnull(result))
				global.medals_enabled = FALSE
				log_game("SCORE ERROR: Could not contact hub to set score. Score:[score] player:[player.ckey]")
				message_admins("Error! Failed to contact hub to set [score] score for [player.ckey]!")


/proc/GetScore(score,client/player,returnlist)

	if(!score || !player)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/scoreget = world.GetScores(player.ckey, score, global.medal_hub, global.medal_pass)
		if(isnull(scoreget))
			global.medals_enabled = FALSE
			log_game("SCORE ERROR: Could not contact hub to get score. Score:[score] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to get score: [score] for [player.ckey]!")
			return

		var/list/scoregetlist = params2list(scoreget)

		if(returnlist)
			return scoregetlist
		else
			return scoregetlist[score]


/proc/CheckMedal(medal,client/player)

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/result = world.GetMedal(medal, player, global.medal_hub, global.medal_pass)

		if(isnull(result))
			global.medals_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to get medal:[medal] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to get [medal] medal for [player.ckey]!")
		else if (result)
			to_chat(player, "[medal] is unlocked")

/proc/LockMedal(medal,client/player)

	if(!player || !medal)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)

		var/result = world.ClearMedal(medal, player, global.medal_hub, global.medal_pass)

		if(isnull(result))
			global.medals_enabled = FALSE
			log_game("MEDAL ERROR: Could not contact hub to clear medal:[medal] player:[player.ckey]")
			message_admins("Error! Failed to contact hub to clear [medal] medal for [player.ckey]!")
		else if (result)
			message_admins("Medal: [medal] removed for [player.ckey]")
		else
			message_admins("Medal: [medal] was not found for [player.ckey]. Unable to clear.")


/proc/ClearScore(client/player)
	world.SetScores(player.ckey, "", global.medal_hub, global.medal_pass)

#undef MEDAL_PREFIX
