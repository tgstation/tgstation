/datum/goap_action/lavaland/rip_and_tear
	name = "RIP AND TEAR"
	cost = 1

/datum/goap_action/lavaland/rip_and_tear/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/lavaland/rip_and_tear/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C)
		target = C
	return (target != null)

/datum/goap_action/lavaland/rip_and_tear/RequiresInRange()
	return TRUE

/datum/goap_action/lavaland/rip_and_tear/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/megafauna/A = agent
	var/mob/living/carbon/C = target
	C.attack_animal(A)
	if(C.stat)
		if(ishuman(C) && A.infest_targets)
			if(C.stat == UNCONSCIOUS)
				var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/AL = new(A.loc)
				AL.infest(C)
		else
			A.devour(C)
	action_done = TRUE
	return TRUE

/datum/goap_action/lavaland/rip_and_tear/CheckDone(atom/agent)
	return action_done

/datum/goap_action/lavaland/rip_and_tear/PerformWhileMoving(atom/agent)
	var/mob/living/simple_animal/hostile/megafauna/BL = agent
	if(BL.environment_smash)
		BL.EscapeConfinement()
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_step(BL, dir)
			for(var/a in T)
				var/atom/A = a
				if(!A.Adjacent(BL))
					continue
				if(is_type_in_typecache(A, BL.environment_target_typecache))
					A.attack_animal(BL)
	return TRUE

/datum/goap_action/lavaland/your_guts
	name = "YOUR GUTS"
	cost = 1

/datum/goap_action/lavaland/your_guts/New()
	..()
	preconditions = list()
	preconditions["specialAttack"] = FALSE
	effects = list()
	effects["specialAttack"] = TRUE

/datum/goap_action/lavaland/your_guts/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C)
		target = C
	return (target != null)

/datum/goap_action/lavaland/your_guts/RequiresInRange()
	return FALSE

/datum/goap_action/lavaland/your_guts/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/megafauna/A = agent
	var/mob/living/L = target
	if(L.stat != DEAD)
		if(A.ranged_cooldown <= world.time)
			A.OpenFire()
	action_done = TRUE
	return TRUE

/datum/goap_action/lavaland/your_guts/CheckDone(atom/agent)
	return action_done

/datum/goap_action/lavaland/your_guts/PerformWhileMoving(atom/agent)
	var/mob/living/simple_animal/hostile/megafauna/BL = agent
	if(BL.environment_smash)
		BL.EscapeConfinement()
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_step(BL, dir)
			for(var/a in T)
				var/atom/A = a
				if(!A.Adjacent(BL))
					continue
				if(is_type_in_typecache(A, BL.environment_target_typecache))
					A.attack_animal(BL)
	return TRUE