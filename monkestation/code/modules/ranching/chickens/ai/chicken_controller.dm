/datum/ai_controller/chicken
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(/datum/ai_planning_subtree/chicken_tree)
	idle_behavior = /datum/idle_behavior/chicken
	blackboard = list(
		BB_BASIC_MOB_CURRENT_TARGET = null,
		BB_CHICKEN_SHITLIST = list(),
		BB_CHICKEN_AGGRESSIVE = FALSE,
		BB_CHICKEN_RETALIATE = FALSE,
		BB_CHICKEN_TARGETED_ABILITY = null,
		BB_CHICKEN_SELF_ABILITY = null,
		BB_CHICKEN_PROJECTILE = null,
		BB_CHICKEN_RECRUIT_COOLDOWN = null,
		BB_CHICKEN_SHOOT_PROB = 10,
		BB_CHICKEN_SPECALITY_ABILITY = null,
		BB_CHICKEN_CURRENT_LEADER = null,
		BB_CHICKEN_ATTEMPT_TRACKING = 0,
		BB_CHICKEN_NESTING_BOX = null,
		BB_CHICKEN_FEED = null
	)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

/datum/ai_controller/chicken/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/basic/chicken/living_pawn = new_pawn
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_PAW, PROC_REF(on_attack_paw))
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(on_attack_animal))
	RegisterSignal(new_pawn, COMSIG_MOB_ATTACK_ALIEN, PROC_REF(on_attack_alien))
	RegisterSignal(new_pawn, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(new_pawn, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))

	movement_delay = living_pawn.cached_multiplicative_slowdown

	blackboard[BB_CHICKEN_PROJECTILE] = living_pawn.projectile_type
	blackboard[BB_CHICKEN_SHOOT_PROB] = living_pawn.shoot_prob

	AddComponent(/datum/component/connect_loc_behalf, new_pawn, loc_connections)
	return ..() //Run parent at end

/datum/ai_controller/chicken/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_MOB_MOVESPEED_UPDATED, COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_MOB_ATTACK_ALIEN))
	qdel(GetComponent(/datum/component/connect_loc_behalf))
	return ..()//Run parent at end

//HOSTILE
/datum/ai_controller/chicken/hostile

/datum/ai_controller/chicken/hostile/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	blackboard[BB_CHICKEN_AGGRESSIVE] = TRUE

//RETALIATE
/datum/ai_controller/chicken/retaliate

/datum/ai_controller/chicken/retaliate/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	blackboard[BB_CHICKEN_RETALIATE] = TRUE


///Start of ai calls

// Stops sentient chickens from being knocked over like weak dunces.
/datum/ai_controller/chicken/on_sentience_gained()
	. = ..()
	qdel(GetComponent(/datum/component/connect_loc_behalf))

/datum/ai_controller/chicken/on_sentience_lost()
	. = ..()
	AddComponent(/datum/component/connect_loc_behalf, pawn, loc_connections)

/datum/ai_controller/chicken/able_to_run()
	. = ..()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE

//hit signals
/datum/ai_controller/chicken/proc/on_attackby(datum/source, obj/item/hitby_item, mob/user)
	SIGNAL_HANDLER
	if(hitby_item.force && hitby_item.damtype != STAMINA)
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if((user.istate & ISTATE_HARM) && prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_paw(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_animal(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_alien(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_bullet_act(datum/source, obj/projectile/Proj)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(istype(Proj , /obj/projectile/beam)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(Proj.damage < living_pawn.health && isliving(Proj.firer))
				retaliate(Proj.firer)

/datum/ai_controller/chicken/proc/on_hitby(datum/source, atom/movable/movable_hitter, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(movable_hitter, /obj/item))
		var/mob/living/basic/chicken/living_pawn = pawn
		var/obj/item/hitby_item = movable_hitter
		var/mob/thrown_by = hitby_item.thrownby?.resolve()
		var/mob/living/carbon/human/human_target = thrown_by
		if(hitby_item.throwforce < living_pawn.health && ishuman(thrown_by) && living_pawn.Friends[human_target] >= CHICKEN_FRIENDSHIP_ATTACK)
			retaliate(human_target)

/datum/ai_controller/chicken/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown

///Reactive events to being hit
/datum/ai_controller/chicken/proc/retaliate(mob/living/living_retaliate)
	var/list/enemies = blackboard[BB_CHICKEN_SHITLIST]
	enemies[living_retaliate] += CHICKEN_HATRED_AMOUNT

//When idle just kinda fuck around.
/datum/idle_behavior/chicken/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/chicken/living_pawn = controller.pawn

	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	var/list/blackboard = controller.blackboard

	if(SPT_PROB(25, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

	if(blackboard[BB_CHICKEN_SHITLIST] && SPT_PROB(50, seconds_per_tick))
		var/list/enemies = blackboard[BB_CHICKEN_SHITLIST]
		if(enemies.len)
			var/mob/living/picked = pick(enemies)
			enemies[picked]--
			if(enemies[picked] <= 0)
				enemies.Remove(picked)
				blackboard[BB_BASIC_MOB_CURRENT_TARGET] = null
				controller.queue_behavior(/datum/ai_behavior/chicken_flee)

/datum/ai_controller/chicken/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && isliving(arrived))
		var/mob/living/in_the_way_mob = arrived
		in_the_way_mob.knockOver(living_pawn)
		return

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken
	ability_key = BB_CHICKEN_TARGETED_ABILITY
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range
	target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]
	var/datum/action/cooldown/mob_cooldown/chicken/stored_action = controller.blackboard[ability_key]
	use_ability_behaviour = stored_action.what_range
	if (QDELETED(target))
		return
	return ..()

/datum/ai_planning_subtree/use_mob_ability/chicken
	ability_key = BB_CHICKEN_SELF_ABILITY
	finish_planning = TRUE

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/clown

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/clown/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(istype(living_pawn, /mob/living/basic/chicken/clown_sad))
		var/list/clucking_mad = list()
		for(var/mob/living/carbon/human/unlucky in GLOB.player_list)
			clucking_mad |= unlucky

		if(!length(clucking_mad))
			return
		controller.blackboard[target_key] = pick(clucking_mad)
		clucking_mad = null
	else
		var/list/pick_me = list()
		for(var/mob/living/carbon/human/target in view(living_pawn, CHICKEN_ENEMY_VISION))
			pick_me |= target
		if(!length(pick_me))
			return
		controller.blackboard[target_key] = pick(pick_me)

	return ..()


/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/rev

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/rev/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	var/list/viable_conversions = list()
	for(var/mob/living/basic/chicken/found_chicken in view(4, living_pawn.loc))
		if(!istype(found_chicken, /mob/living/basic/chicken/rev_raptor) || !istype(found_chicken, /mob/living/basic/chicken/raptor) || !istype(found_chicken, /mob/living/basic/chicken/rev_raptor))
			viable_conversions |= found_chicken
	if(!length(viable_conversions))
		return
	controller.blackboard[target_key] = pick(viable_conversions)

	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/lay_egg
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range/on_top
	target_key = BB_CHICKEN_NESTING_BOX
	ability_key = BB_CHICKEN_LAY_EGG

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/lay_egg/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/basic/chicken/living_pawn = controller.pawn
	if(living_pawn.eggs_left <= 0)
		return

	var/list/found_spots = list()
	for(var/obj/structure/nestbox/listed_box in view(7, living_pawn.loc))
		found_spots |= listed_box
	if(!length(found_spots))
		return
	controller.blackboard[target_key] = pick(found_spots)
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/feed
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range/on_top
	target_key = BB_BASIC_MOB_CURRENT_TARGET
	ability_key = BB_CHICKEN_FEED

/datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/feed/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	var/list/found_spots = list()
	for(var/obj/effect/chicken_feed/listed_feed in view(7, living_pawn.loc))
		found_spots |= listed_feed
	if(!length(found_spots))
		return
	controller.blackboard[target_key] = pick(found_spots)
	return ..()
