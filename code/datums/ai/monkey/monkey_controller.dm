/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	movement_delay = 0.4 SECONDS
	blackboard = list(
		BB_MONKEY_AGRESSIVE = FALSE,
		BB_MONKEY_BEST_FORCE_FOUND = 0,
		BB_MONKEY_ENEMIES = list(),
		BB_MONKEY_BLACKLISTITEMS = list(),
		BB_MONKEY_PICKUPTARGET = null,
		BB_MONKEY_PICKPOCKETING = FALSE,
		BB_MONKEY_DISPOSING = FALSE,
		BB_MONKEY_TARGET_DISPOSAL = null,
		BB_MONKEY_CURRENT_ATTACK_TARGET = null,
		BB_MONKEY_GUN_NEURONS_ACTIVATED = FALSE,
		BB_MONKEY_GUN_WORKED = TRUE,
		BB_MONKEY_NEXT_HUNGRY = 0
	)

/datum/ai_controller/monkey/angry

/datum/ai_controller/monkey/angry/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	blackboard[BB_MONKEY_AGRESSIVE] = TRUE //Angry cunt

/datum/ai_controller/monkey/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	blackboard[BB_MONKEY_NEXT_HUNGRY] = world.time + rand(0, 300)

	var/mob/living/living_pawn = new_pawn
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_PAW, .proc/on_attack_paw)
	RegisterSignal(new_pawn, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(new_pawn, COMSIG_ATOM_HITBY, .proc/on_hitby)
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, .proc/on_startpulling)
	RegisterSignal(new_pawn, COMSIG_LIVING_TRY_SYRINGE, .proc/on_try_syringe)
	RegisterSignal(new_pawn, COMSIG_ATOM_HULK_ATTACK, .proc/on_attack_hulk)
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, .proc/on_attempt_cuff)
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, .proc/update_movespeed)
	RegisterSignal(new_pawn, COMSIG_FOOD_EATEN, .proc/on_eat)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, new_pawn, loc_connections)
	movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..() //Run parent at end

/datum/ai_controller/monkey/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_LIVING_START_PULL,\
	COMSIG_LIVING_TRY_SYRINGE, COMSIG_ATOM_HULK_ATTACK, COMSIG_CARBON_CUFF_ATTEMPTED, COMSIG_MOB_MOVESPEED_UPDATED))
	pawn.RemoveElement(/datum/element/connect_loc)

	return ..() //Run parent at end

/datum/ai_controller/monkey/able_to_run()
	. = ..()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE

/datum/ai_controller/monkey/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/living_pawn = pawn

	if(SHOULD_RESIST(living_pawn) && DT_PROB(MONKEY_RESIST_PROB, delta_time))
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

	var/list/enemies = blackboard[BB_MONKEY_ENEMIES]

	if(HAS_TRAIT(pawn, TRAIT_PACIFISM)) //Not a pacifist? lets try some combat behavior.
		return

	var/mob/living/selected_enemy
	if(length(enemies) || blackboard[BB_MONKEY_AGRESSIVE]) //We have enemies or are pissed
		var/list/valids = list()
		for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, living_pawn))
			if(possible_enemy == living_pawn || (!enemies[possible_enemy] && (!blackboard[BB_MONKEY_AGRESSIVE] || HAS_AI_CONTROLLER_TYPE(possible_enemy, /datum/ai_controller/monkey)))) //Are they an enemy? (And do we even care?)
				continue
			// Weighted list, so the closer they are the more likely they are to be chosen as the enemy
			valids[possible_enemy] = CEILING(100 / (get_dist(living_pawn, possible_enemy) || 1), 1)

		selected_enemy = pickweight(valids)

		if(selected_enemy)
			if(!selected_enemy.stat) //He's up, get him!
				if(living_pawn.health < MONKEY_FLEE_HEALTH) //Time to skeddadle
					blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_flee)
					return //I'm running fuck you guys

				if(TryFindWeapon()) //Getting a weapon is higher priority if im not fleeing.
					return

				blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
				current_movement_target = selected_enemy
				if(blackboard[BB_MONKEY_RECRUIT_COOLDOWN] < world.time)
					current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/recruit_monkeys)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/battle_screech/monkey)
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_attack_mob)
				return //Focus on this

			else //He's down, can we disposal him?
				var/obj/machinery/disposal/bodyDisposal = locate(/obj/machinery/disposal/) in view(MONKEY_ENEMY_VISION, living_pawn)
				if(bodyDisposal)
					blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] = selected_enemy
					blackboard[BB_MONKEY_TARGET_DISPOSAL] = bodyDisposal
					current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/disposal_mob)
					return

	if(prob(5))
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/use_in_hand)

	if(selected_enemy || !DT_PROB(MONKEY_SHENANIGAN_PROB, delta_time))
		return

	if(world.time >= blackboard[BB_MONKEY_NEXT_HUNGRY] && TryFindFood())
		return

	if(prob(50))
		var/list/possible_targets = list()
		for(var/atom/thing in view(2, living_pawn))
			if(!thing.mouse_opacity)
				continue
			if(thing.IsObscured())
				continue
			possible_targets += thing
		var/atom/target = pick(possible_targets)
		if(target)
			current_movement_target = target
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/use_on_object)
			return

	if(prob(5) && (locate(/obj/item) in living_pawn.held_items))
		var/list/possible_receivers = list()
		for(var/mob/living/candidate in oview(2, pawn))
			possible_receivers += candidate

		if(length(possible_receivers))
			var/mob/living/target = pick(possible_receivers)
			current_movement_target = target
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/give)
			return

	TryFindWeapon()

///re-used behavior pattern by monkeys for finding a weapon
/datum/ai_controller/monkey/proc/TryFindWeapon()
	var/mob/living/living_pawn = pawn

	if(!locate(/obj/item) in living_pawn.held_items)
		blackboard[BB_MONKEY_BEST_FORCE_FOUND] = 0

	if(blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED] && (locate(/obj/item/gun) in living_pawn.held_items))
		// We have a gun, what could we possibly want?
		return FALSE

	var/obj/item/weapon
	var/list/nearby_items = list()
	for(var/obj/item/item in oview(2, living_pawn))
		nearby_items += item

	weapon = GetBestWeapon(nearby_items, living_pawn.held_items)

	var/pickpocket = FALSE
	for(var/mob/living/carbon/human/human in oview(5, living_pawn))
		var/obj/item/held_weapon = GetBestWeapon(human.held_items + weapon, living_pawn.held_items)
		if(held_weapon == weapon) // It's just the same one, not a held one
			continue
		pickpocket = TRUE
		weapon = held_weapon

	if(!weapon || (weapon in living_pawn.held_items))
		return FALSE

	blackboard[BB_MONKEY_PICKUPTARGET] = weapon
	current_movement_target = weapon
	if(pickpocket)
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_equip/pickpocket)
	else
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_equip/ground)
	return TRUE

/// Returns either the best weapon from the given choices or null if held weapons are better
/datum/ai_controller/monkey/proc/GetBestWeapon(list/choices, list/held_weapons)
	var/gun_neurons_activated = blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED]
	var/top_force = 0
	var/obj/item/top_force_item
	for(var/obj/item/item as anything in held_weapons)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && istype(item, /obj/item/gun))
			// We have a gun, why bother looking for something inferior
			// Also yes it is intentional that monkeys dont know how to pick the best gun
			return item
		if(item.force > top_force)
			top_force = item.force
			top_force_item = item

	for(var/obj/item/item as anything in choices)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && istype(item, /obj/item/gun))
			return item
		if(item.force <= top_force)
			continue
		top_force_item = item
		top_force = item.force

	return top_force_item

/datum/ai_controller/monkey/proc/TryFindFood()
	. = FALSE
	var/mob/living/living_pawn = pawn

	// Held items

	var/list/food_candidates = list()
	for(var/obj/item as anything in living_pawn.held_items)
		if(!item || !IsEdible(item))
			continue
		food_candidates += item

	for(var/obj/item/candidate in oview(2, living_pawn))
		if(!IsEdible(candidate))
			continue
		food_candidates += candidate

	if(length(food_candidates))
		var/obj/item/best_held = GetBestWeapon(null, living_pawn.held_items)
		for(var/obj/item/held as anything in living_pawn.held_items)
			if(!held || held == best_held)
				continue
			living_pawn.dropItemToGround(held)

		AddBehavior(/datum/ai_behavior/consume, pick(food_candidates))
		return TRUE

/datum/ai_controller/monkey/proc/IsEdible(obj/item/thing)
	if(IS_EDIBLE(thing))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = thing
		if(glass.reagents.total_volume) // The glass has something in it, time to drink the mystery liquid!
			return TRUE
	return FALSE

//When idle just kinda fuck around.
/datum/ai_controller/monkey/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(DT_PROB(5, delta_time))
		INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick("screech"))
	else if(DT_PROB(1, delta_time))
		INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick("scratch","jump","roll","tail"))

///Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/L)
	var/list/enemies = blackboard[BB_MONKEY_ENEMIES]
	enemies[L] += MONKEY_HATRED_AMOUNT

/datum/ai_controller/monkey/proc/on_attackby(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(I.force && I.damtype != STAMINA)
		retaliate(user)

/datum/ai_controller/monkey/proc/on_attack_hand(datum/source, mob/living/L)
	SIGNAL_HANDLER
	if(prob(MONKEY_RETALIATE_PROB))
		retaliate(L)


/datum/ai_controller/monkey/proc/on_attack_paw(datum/source, mob/living/L)
	SIGNAL_HANDLER
	if(prob(MONKEY_RETALIATE_PROB))
		retaliate(L)

/datum/ai_controller/monkey/proc/on_bullet_act(datum/source, obj/projectile/Proj)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(istype(Proj , /obj/projectile/beam)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < living_pawn.health && isliving(Proj.firer))
				retaliate(Proj.firer)

/datum/ai_controller/monkey/proc/on_hitby(datum/source, atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(AM, /obj/item))
		var/mob/living/living_pawn = pawn
		var/obj/item/I = AM
		if(I.throwforce < living_pawn.health && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)

/datum/ai_controller/monkey/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && ismob(AM))
		var/mob/living/in_the_way_mob = AM
		in_the_way_mob.knockOver(living_pawn)
		return

/datum/ai_controller/monkey/proc/on_startpulling(datum/source, atom/movable/puller, state, force)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(!IS_DEAD_OR_INCAP(living_pawn) && prob(MONKEY_PULL_AGGRO_PROB)) // nuh uh you don't pull me!
		retaliate(living_pawn.pulledby)
		return TRUE

/datum/ai_controller/monkey/proc/on_try_syringe(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_SYRINGE_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/on_attack_hulk(datum/source, mob/user)
	SIGNAL_HANDLER
	retaliate(user)

/datum/ai_controller/monkey/proc/on_attempt_cuff(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_CUFF_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown

/datum/ai_controller/monkey/proc/target_del(target)
	SIGNAL_HANDLER
	blackboard[BB_MONKEY_BLACKLISTITEMS] -= target

/datum/ai_controller/monkey/proc/on_eat(mob/living/pawn)
	SIGNAL_HANDLER
	blackboard[BB_MONKEY_NEXT_HUNGRY] = world.time + rand(120, 600) SECONDS
