/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = "harm"
	sentience_type = SENTIENCE_BOSS
	environment_smash = 3
	obj_damage = 75
	luminosity = 3
	weather_immunities = list("lava","ash")
	robust_searching = 1
	stat_attack = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	var/medal_type = TEST_MEDAL
	var/score_type = BOSS_SCORE
	var/elimination = 0
	anchored = TRUE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(health > 0)
		return
	else
		if(!admin_spawned)
			feedback_set_details("megafauna_kills","[initial(name)]")
			if(!elimination)	//used so the achievment only occurs for the last legion to die.
				grant_achievement()
		..()

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
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(ranged && ranged_cooldown <= world.time)
				OpenFire()
		else
			devour(L)

/mob/living/simple_animal/hostile/megafauna/onShuttleMove()
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] \
		(<A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A>) \
		moved via shuttle from ([oldloc.x],[oldloc.y],[oldloc.z]) to \
		([newloc.x],[newloc.y],[newloc.z])")

/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/L)
	visible_message(
		"<span class='danger'>[src] devours [L]!</span>",
		"<span class='userdanger'>You feast on [L], restoring your health!</span>")
	adjustBruteLoss(-L.maxHealth/2)
	L.gib()

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch (severity)
		if (1)
			adjustBruteLoss(250)

		if (2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)



/mob/living/simple_animal/hostile/megafauna/proc/grant_achievement()
	if(medal_type == TEST_MEDAL || admin_spawned)
		return
	if(global.medal_hub && global.medal_pass && global.medals_enabled)
		for(var/mob/living/L in view(7,src))
			if(L.stat)
				continue
			if(L.client)
				var/client/C = L.client
				UnlockMedal(medal_type, C)
				SetScore(BOSS_SCORE,C,1)
				SetScore(score_type,C,1)
