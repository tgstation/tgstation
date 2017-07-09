/datum/goap_action/lavaland/attack_enemy
	name = "Attack Enemy"
	cost = 1

/datum/goap_action/lavaland/attack_enemy/New()
	..()
	preconditions = list()
	preconditions["enemyDead"] = FALSE
	effects = list()
	effects["enemyDead"] = TRUE

/datum/goap_action/lavaland/attack_enemy/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C && !C.stat)
		target = C
	return (target != null)

/datum/goap_action/lavaland/attack_enemy/RequiresInRange()
	return TRUE

/datum/goap_action/lavaland/attack_enemy/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/A = agent
	A.target = target
	A.AttackingTarget()
	action_done = TRUE
	return TRUE

/datum/goap_action/lavaland/attack_enemy/CheckDone(atom/agent)
	return action_done

/datum/goap_action/lavaland/attack_enemy/PerformWhileMoving(atom/agent)
	var/mob/living/simple_animal/hostile/BL = agent
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

/datum/goap_action/lavaland/attack_ranged
	name = "Attack Ranged"
	cost = 1

/datum/goap_action/lavaland/attack_ranged/New()
	..()
	preconditions = list()
	preconditions["specialAttack"] = FALSE
	effects = list()
	effects["specialAttack"] = TRUE

/datum/goap_action/lavaland/attack_ranged/AdvancedPreconditions(atom/agent, list/worldstate)
	var/mob/living/simple_animal/hostile/A = agent
	if(!A.ranged)
		return FALSE
	var/list/viewl = spiral_range(10, agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C && !C.stat)
		target = C
	return (target != null)

/datum/goap_action/lavaland/attack_ranged/RequiresInRange()
	return FALSE

/datum/goap_action/lavaland/attack_ranged/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/A = agent
	var/mob/living/carbon/C = target
	A.RangedAttack(C)
	action_done = TRUE
	return TRUE

/datum/goap_action/lavaland/attack_ranged/CheckDone(atom/agent)
	return action_done

// Interact With Objects
/datum/goap_action/lavaland/attack_wanted_objects
	name = "Interact With Objects"
	cost = 1

/datum/goap_action/lavaland/attack_wanted_objects/New()
	..()
	preconditions = list()
	preconditions["interactWanted"] = FALSE
	effects = list()
	effects["interactWanted"] = TRUE

/datum/goap_action/lavaland/attack_wanted_objects/AdvancedPreconditions(atom/agent, list/worldstate)
	var/mob/living/simple_animal/hostile/H = agent
	for(var/obj/O in spiral_range(10, agent))
		if(is_type_in_typecache(O, H.wanted_objects))
			target = O
			break
	return TRUE

/datum/goap_action/lavaland/attack_wanted_objects/RequiresInRange()
	return TRUE

/datum/goap_action/lavaland/attack_wanted_objects/Perform(atom/agent)
	var/mob/living/simple_animal/hostile/BL = agent
	BL.target = target
	BL.AttackingTarget()
	action_done = TRUE
	return TRUE

/datum/goap_action/lavaland/attack_wanted_objects/CheckDone(atom/agent)
	return action_done