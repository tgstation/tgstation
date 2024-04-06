/datum/ai_controller/basic_controller/raptor
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/raptor,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/raptor,
        BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/raptor),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/raptor/baby_raptor),
		BB_MAX_CHILDREN = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
        /datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/raptor,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
        /datum/ai_planning_subtree/find_and_hunt_target/heal_raptors,
        /datum/ai_planning_subtree/pet_planning,
        /datum/ai_planning_subtree/target_retaliate,
        /datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/care_for_young,
        /datum/ai_planning_subtree/make_babies,
        /datum/ai_planning_subtree/raptor_start_trouble,
	)

/datum/targeting_strategy/basic/raptor

//dont attack anyone with the neutral faction. 
/datum/targeting_strategy/basic/proc/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return the_target.Find(FACTION_NEUTRAL)

/datum/ai_planning_subtree/find_and_hunt_target/heal_raptors
	target_key = BB_INJURED_RAPTOR
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/heal_raptor
	finding_behavior = /datum/ai_behavior/find_hunt_target/injured_raptor
	hunt_targets = list(/mob/living/basic/raptor)
	hunt_chance = 70
	hunt_range = 9

/datum/ai_behavior/hunt_target/unarmed_attack_target/heal_raptor
    always_reset_target = TRUE

/datum/ai_behavior/find_hunt_target/injured_raptor

/datum/ai_behavior/find_hunt_target/injured_raptor/valid_dinner(mob/living/source, mob/living/target, radius)
    return (target.health < target.maxHealth)

/datum/ai_planning_subtree/find_and_hunt_target/heal_raptors/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(!controller.blackboard[BB_BASIC_MOB_HEALER])
        return
    return ..()
/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/raptor
    target_key = BB_BASIC_MOB_FLEE_TARGET

/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/raptor/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(!controller.blackboard[BB_RAPTOR_COWARD])
        return
    return ..()

/datum/ai_planning_subtree/raptor_start_trouble

/datum/ai_planning_subtree/raptor_start_trouble/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(!controller.blackboard[BB_RAPTOR_TROUBLE_MAKER] || !SPT_PROB(0.5, seconds_per_tick))
        return
    if(world.time > controller.blackboard[BB_RAPTOR_TROUBLE_COOLDOWN])
        return
    controller.queue_behavior(/datum/ai_behavior/find_and_set/raptor_victim, BB_BASIC_MOB_CURRENT_TARGET, /mob/living/basic/mining/raptor)

/datum/ai_behavior/find_and_set/raptor_victim

/datum/ai_behavior/find_and_set/raptor_victim/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/basic/mining/raptor/target in oview(search_range, controller.pawn))
        if(target.stat == DEAD)
            continue
		if(target.ai_controller?.blackboard[BB_RAPTOR_TROUBLE_MAKER])
            continue
        return target
	
    return null

/datum/ai_behavior/find_and_set/raptor_victim/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
    if(succeeded)
        controller.blackboard[BB_RAPTOR_TROUBLE_COOLDOWN] = world.time + 5 MINUTES
    return ..()

/datum/ai_planning_subtree/find_and_hunt_target/care_for_young
	target_key = BB_RAPTOR_BABY
	hunting_behavior = /datum/ai_behavior/hunt_target/care_for_young
	finding_behavior = /datum/ai_behavior/find_hunt_target/raptor_baby
	hunt_targets = list(/mob/living/basic/raptor/raptor_baby)
	hunt_chance = 30
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/care_for_young/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(!controller.blackboard[BB_RAPTOR_MOTHERLY])
        return
    return ..()

/datum/ai_behavior/find_hunt_target/raptor_baby/valid_dinner(mob/living/source, mob/living/target, radius)
	return can_see(source, target, radius) && target.stat != DEAD

/datum/ai_behavior/hunt_target/care_for_young
    always_reset_target = TRUE

/datum/ai_behavior/hunt_target/care_for_young/target_caught(mob/living/hunter, atom/hunted)
    hunter.manual_emote("grooms [hunted]!")
    hunter.set_combat_mode(FALSE)
    hunter.OnClick(hunted)

/datum/ai_behavior/hunt_target/care_for_young/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
    var/mob/living/living_pawn = controller.pawn
    living_pawn.set_combat_mode(initial(living_pawn.combat_mode))
    return ..()
