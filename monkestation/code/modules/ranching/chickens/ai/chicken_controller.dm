/datum/ai_controller/chicken
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(/datum/ai_planning_subtree/chicken_tree)
	blackboard = list(
		BB_CHICKEN_SHITLIST = list(),
		BB_CHICKEN_AGGRESSIVE = FALSE,
		BB_CHICKEN_RETALIATE = FALSE,
		BB_CHICKEN_CURRENT_ATTACK_TARGET = null,
		BB_CHICKEN_ABILITY = null,
		BB_CHICKEN_PROJECTILE = null,
		BB_CHICKEN_RECRUIT_COOLDOWN = null,
		BB_CHICKEN_COMBAT_ABILITY = FALSE,
		BB_CHICKEN_ABILITY_COOLDOWN = null,
		BB_CHICKEN_SHOOT_PROB = 10,
		BB_CHICKEN_HONKS_SORROW = FALSE,
		BB_CHICKEN_SPECALITY_ABILITY = null,
		BB_CHICKEN_CURRENT_LEADER = null,
		BB_CHICKEN_READY_LAY = FALSE,
		BB_CHICKEN_ATTEMPT_TRACKING = 0,
	)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)

/datum/ai_controller/chicken/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	var/mob/living/simple_animal/chicken/living_pawn = new_pawn
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_PAW, .proc/on_attack_paw)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_ANIMAL, .proc/on_attack_animal)
	RegisterSignal(new_pawn, COMSIG_MOB_ATTACK_ALIEN, .proc/on_attack_alien)
	RegisterSignal(new_pawn, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(new_pawn, COMSIG_ATOM_HITBY, .proc/on_hitby)
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, .proc/update_movespeed)

	movement_delay = living_pawn.cached_multiplicative_slowdown

	blackboard[BB_CHICKEN_ABILITY] = living_pawn.unique_ability
	blackboard[BB_CHICKEN_COMBAT_ABILITY] = living_pawn.combat_ability
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


//CLOWN AIS


/datum/ai_controller/chicken/clown/sad

/datum/ai_controller/chicken/clown/sad/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	blackboard[BB_CHICKEN_HONKS_SORROW] = TRUE // honk but sad
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
	if(user.a_intent == INTENT_HARM && prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_paw(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_animal(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(user.melee_damage > 0 && prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_attack_alien(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(prob(CHICKEN_RETALIATE_PROB))
		retaliate(user)

/datum/ai_controller/chicken/proc/on_bullet_act(datum/source, obj/item/projectile/Proj)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(istype(Proj , /obj/item/projectile/beam)||istype(Proj, /obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < living_pawn.health && isliving(Proj.firer))
				retaliate(Proj.firer)

/datum/ai_controller/chicken/proc/on_hitby(datum/source, atom/movable/movable_hitter, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(movable_hitter, /obj/item))
		var/mob/living/simple_animal/chicken/living_pawn = pawn
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
/datum/ai_controller/chicken/PerformIdleBehavior(delta_time)
	. = ..()
	var/mob/living/simple_animal/chicken/living_pawn = pawn

	if((!blackboard[BB_CHICKEN_READY_LAY]&& DT_PROB(10, delta_time) && living_pawn.eggs_left > 0) && living_pawn.egg_type && GLOB.total_chickens < CONFIG_GET(number/max_chickens) && living_pawn.gender == FEMALE && behavior_cooldowns[/datum/ai_behavior/find_and_lay] < world.time)
		blackboard[BB_CHICKEN_READY_LAY] = TRUE

	if(blackboard[BB_CHICKEN_READY_LAY])
		queue_behavior(/datum/ai_behavior/find_and_lay)

	if(DT_PROB(10, delta_time) && behavior_cooldowns[/datum/ai_behavior/eat_ground_food] < world.time)
		if(locate(/obj/item/food) in view(5, pawn))
			queue_behavior(/datum/ai_behavior/eat_ground_food)

	if(blackboard[BB_CHICKEN_SPECALITY_ABILITY] && DT_PROB(living_pawn.ability_prob, delta_time) && blackboard[BB_CHICKEN_ABILITY_COOLDOWN] < world.time)
		// this will be expanded in the future its just easier to leave it like this now
		switch(blackboard[BB_CHICKEN_SPECALITY_ABILITY])
			if(CHICKEN_REV)
				queue_behavior(/datum/ai_behavior/revolution)
			if(CHICKEN_SUGAR_RUSH)
				queue_behavior(/datum/ai_behavior/sugar_rush)
			if(CHICKEN_HONK)
				queue_behavior(/datum/ai_behavior/chicken_honk_target)

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

	if(blackboard[BB_CHICKEN_SHITLIST] && DT_PROB(50, delta_time))
		var/list/enemies = blackboard[BB_CHICKEN_SHITLIST]
		if(enemies.len)
			var/mob/living/picked = pick(enemies)
			enemies[picked]--
			if(enemies[picked] <= 0)
				enemies.Remove(picked)
				blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET] = null
				queue_behavior(/datum/ai_behavior/chicken_flee)


/datum/ai_controller/chicken/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && isliving(arrived))
		var/mob/living/in_the_way_mob = arrived
		in_the_way_mob.knockOver(living_pawn)
		return
