#define NEXT_EAT_COOLDOWN 2 MINUTES

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
        /datum/ai_planning_subtree/find_and_hunt_target/raptor_trough,
        /datum/ai_planning_subtree/find_and_hunt_target/care_for_young,
        /datum/ai_planning_subtree/make_babies,
        /datum/ai_planning_subtree/find_and_hunt_target/raptor_start_trouble,
        /datum/ai_planning_subtree/express_happiness,
	)

/datum/ai_controller/basic_controller/raptor/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_MOB_ATE, PROC_REF(post_eat))

/datum/ai_controller/basic_controller/raptor/proc/post_eat()
    clear_blackboard_key(BB_RAPTOR_TROUGH_TARGET)
    blackboard[BB_RAPTOR_EAT_COOLDOWN] = world.time + NEXT_EAT_COOLDOWN

/datum/targeting_strategy/basic/raptor

//dont attack anyone with the neutral faction. 
/datum/targeting_strategy/basic/raptor/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
    return (the_target.faction.Find(FACTION_NEUTRAL) || the_target.faction.Find(FACTION_RAPTOR))

/datum/ai_planning_subtree/find_and_hunt_target/heal_raptors
	target_key = BB_INJURED_RAPTOR
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/heal_raptor
	finding_behavior = /datum/ai_behavior/find_hunt_target/injured_raptor
	hunt_targets = list(/mob/living/basic/mining/raptor)
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

/datum/ai_planning_subtree/find_and_hunt_target/raptor_start_trouble
	target_key = BB_RAPTOR_VICTIM
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/bully_raptors
	finding_behavior = /datum/ai_behavior/find_hunt_target/raptor_victim
	hunt_targets = list(/mob/living/basic/mining/raptor)
	hunt_chance = 30
	hunt_range = 9

/datum/ai_behavior/find_hunt_target/raptor_victim

/datum/ai_behavior/find_hunt_target/raptor_victim/valid_dinner(mob/living/source, mob/living/target, radius)
    if(target.ai_controller?.blackboard[BB_RAPTOR_TROUBLE_MAKER])
        return FALSE
    return can_see(source, target, radius) && target.stat != DEAD

/datum/ai_behavior/hunt_target/unarmed_attack_target/bully_raptors
    always_reset_target = TRUE

/datum/ai_behavior/hunt_target/unarmed_attack_target/bully_raptors/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
    if(succeeded)
        controller.blackboard[BB_RAPTOR_TROUBLE_COOLDOWN] = world.time + 30 SECONDS
    return ..()

/datum/ai_planning_subtree/find_and_hunt_target/raptor_start_trouble/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(controller.blackboard[BB_BASIC_MOB_HEALER] || !controller.blackboard[BB_RAPTOR_TROUBLE_MAKER])
        return
    if(world.time < controller.blackboard[BB_RAPTOR_TROUBLE_COOLDOWN])
        return
    return ..()

/datum/ai_planning_subtree/find_and_hunt_target/care_for_young
	target_key = BB_RAPTOR_BABY
	hunting_behavior = /datum/ai_behavior/hunt_target/care_for_young
	finding_behavior = /datum/ai_behavior/find_hunt_target/raptor_baby
	hunt_targets = list(/mob/living/basic/mining/raptor/baby_raptor)
	hunt_chance = 75
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
    hunter.ClickOn(hunted)

/datum/ai_behavior/hunt_target/care_for_young/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
    var/mob/living/living_pawn = controller.pawn
    living_pawn.set_combat_mode(initial(living_pawn.combat_mode))
    return ..()

/datum/ai_planning_subtree/find_and_hunt_target/raptor_trough
    target_key = BB_RAPTOR_TROUGH_TARGET
    hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target
    finding_behavior = /datum/ai_behavior/find_hunt_target/raptor_trough
    hunt_targets = list(/obj/structure/ore_container/food_trough/raptor_trough)
    hunt_chance = 80
    hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/raptor_trough/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
    if(world.time < controller.blackboard[BB_RAPTOR_EAT_COOLDOWN])
        return
    return ..()

/datum/ai_behavior/find_hunt_target/raptor_trough

/datum/ai_behavior/find_hunt_target/raptor_trough/valid_dinner(mob/living/source, atom/movable/trough, radius)
    return !!(locate(/obj/item/stack/ore) in trough.contents)

/datum/ai_behavior/hunt_target/unarmed_attack_target/raptor_trough
    always_reset_target = TRUE

/datum/ai_behavior/hunt_target/unarmed_attack_target/raptor_trough/target_caught(mob/living/hunter, atom/hunted)
    hunter.set_combat_mode(FALSE)

/datum/ai_behavior/hunt_target/unarmed_attack_target/raptor_trough/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
    var/mob/living/living_pawn = controller.pawn
    living_pawn.set_combat_mode(initial(living_pawn.combat_mode))
    return ..()

/datum/ai_controller/basic_controller/baby_raptor
	blackboard = list(
        BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/raptor),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/mining/raptor/baby_raptor),
		BB_MAX_CHILDREN = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
        /datum/ai_planning_subtree/simple_find_target,
        /datum/ai_planning_subtree/flee_target,
        /datum/ai_planning_subtree/find_and_hunt_target/raptor_trough,
        /datum/ai_planning_subtree/express_happiness,
        /datum/ai_planning_subtree/look_for_adult,
	)

#undef NEXT_EAT_COOLDOWN
