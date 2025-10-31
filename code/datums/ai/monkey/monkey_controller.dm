/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/generic_hunger,
		/datum/ai_planning_subtree/generic_play_instrument,
		/datum/ai_planning_subtree/monkey_shenanigans,
	)
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/monkey,
		BB_MONKEY_AGGRESSIVE = FALSE,
		BB_MONKEY_BEST_FORCE_FOUND = 0,
		BB_MONKEY_ENEMIES = list(),
		BB_MONKEY_BLACKLISTITEMS = list(),
		BB_MONKEY_PICKPOCKETING = FALSE,
		BB_MONKEY_DISPOSING = FALSE,
		BB_MONKEY_GUN_NEURONS_ACTIVATED = FALSE,
		BB_SONG_LINES = MONKEY_SONG,
		BB_RESISTING = FALSE,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey

/datum/targeting_strategy/basic/monkey

/datum/targeting_strategy/basic/monkey/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	// if they wronged us, all bets are off
	if(controller.blackboard[BB_MONKEY_ENEMIES][the_target])
		return FALSE
	// target was forcibly set, all bets are off again
	if(controller.blackboard[BB_MONKEY_CURRENT_ATTACK_TARGET] == the_target)
		return FALSE
	return ..()

/datum/ai_controller/monkey/process(seconds_per_tick)

	var/mob/living/living_pawn = src.pawn

	if(!length(living_pawn.do_afters) && living_pawn.ai_controller.blackboard[BB_RESISTING])
		living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, FALSE)

	if(living_pawn.ai_controller.blackboard[BB_RESISTING])
		return

	. = ..()

/datum/ai_controller/monkey/New(atom/new_pawn)
	var/static/list/control_examine = list(
		ORGAN_SLOT_EYES = span_monkey("%PRONOUN_They stare%PRONOUN_s around with wild, primal eyes."),
	)
	AddElement(/datum/element/ai_control_examine, control_examine)
	return ..()

/datum/ai_controller/monkey/pun_pun
	movement_delay = 0.7 SECONDS //pun pun moves slower so the bartender can keep track of them
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/generic_hunger,
		/datum/ai_planning_subtree/generic_play_instrument,
		/datum/ai_planning_subtree/punpun_shenanigans,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey/pun_pun

/datum/ai_controller/monkey/angry

/datum/ai_controller/monkey/angry/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	pawn = new_pawn
	set_blackboard_key(BB_MONKEY_AGGRESSIVE, TRUE) //Angry cunt
	set_trip_mode(mode = FALSE)

/datum/ai_controller/monkey/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	var/mob/living/living_pawn = new_pawn
	if(!HAS_TRAIT(living_pawn, TRAIT_RELAYING_ATTACKER))
		living_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, PROC_REF(on_startpulling))
	RegisterSignals(new_pawn, list(COMSIG_LIVING_TRY_SYRINGE_INJECT, COMSIG_LIVING_TRY_SYRINGE_WITHDRAW), PROC_REF(on_try_syringe))
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(on_attempt_cuff))
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))

	movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..() //Run parent at end

/datum/ai_controller/monkey/UnpossessPawn(destroy)

	UnregisterSignal(pawn, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_LIVING_START_PULL,
		COMSIG_LIVING_TRY_SYRINGE_INJECT,
		COMSIG_LIVING_TRY_SYRINGE_WITHDRAW,
		COMSIG_CARBON_CUFF_ATTEMPTED,
		COMSIG_MOB_MOVESPEED_UPDATED,
	))

	return ..() //Run parent at end

/datum/ai_controller/monkey/on_sentience_lost()
	. = ..()
	set_trip_mode(mode = TRUE)

/datum/ai_controller/monkey/on_stat_changed(mob/living/source, new_stat)
	. = ..()
	update_able_to_run()

/datum/ai_controller/monkey/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_MOB_INCAPACITATE_CHANGED, PROC_REF(update_able_to_run))

/datum/ai_controller/monkey/clear_able_to_run()
	UnregisterSignal(pawn, list(COMSIG_MOB_INCAPACITATE_CHANGED, COMSIG_MOB_STATCHANGE))
	return ..()

/datum/ai_controller/monkey/get_able_to_run()
	var/mob/living/living_pawn = pawn

	if(INCAPACITATED_IGNORING(living_pawn, INCAPABLE_RESTRAINTS|INCAPABLE_STASIS|INCAPABLE_GRAB) || living_pawn.stat > CONSCIOUS)
		return AI_UNABLE_TO_RUN
	return ..()

/datum/ai_controller/monkey/proc/set_trip_mode(mode = TRUE)
	var/mob/living/carbon/regressed_monkey = pawn
	var/brain = regressed_monkey.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(istype(brain, /obj/item/organ/brain/primate)) // In case we are a monkey AI in a human brain by who was previously controlled by a client but it now not by some marvel
		var/obj/item/organ/brain/primate/monkeybrain = brain
		monkeybrain.tripping = mode

///re-used behavior pattern by monkeys for finding a weapon
/datum/ai_controller/monkey/proc/TryFindWeapon()
	var/mob/living/living_pawn = pawn

	if(!(locate(/obj/item) in living_pawn.held_items))
		set_blackboard_key(BB_MONKEY_BEST_FORCE_FOUND, 0)

	if(blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED] && (locate(/obj/item/gun) in living_pawn.held_items))
		// We have a gun, what could we possibly want?
		return FALSE

	var/obj/item/weapon
	var/list/nearby_items = list()
	for(var/obj/item/item in oview(2, living_pawn))
		nearby_items += item

	for(var/obj/item/item in living_pawn.held_items) // If we've got some garbage in out hands that's going to stop us from effectively attacking, we should get rid of it.
		if(item.force < 2)
			living_pawn.dropItemToGround(item)

	weapon = GetBestWeapon(src, nearby_items, living_pawn.held_items)

	var/pickpocket = FALSE
	for(var/mob/living/carbon/human/human in oview(5, living_pawn))
		var/obj/item/held_weapon = GetBestWeapon(src, human.held_items + weapon, living_pawn.held_items)
		if(held_weapon == weapon) // It's just the same one, not a held one
			continue
		pickpocket = TRUE
		weapon = held_weapon

	if(!weapon || (weapon in living_pawn.held_items))
		return FALSE

	if(weapon.force < 2) // our bite does 2 damage on average, no point in settling for anything less
		return FALSE

	set_blackboard_key(BB_MONKEY_PICKUPTARGET, weapon)
	if(pickpocket)
		queue_behavior(/datum/ai_behavior/monkey_equip/pickpocket, BB_MONKEY_PICKUPTARGET)
	else
		queue_behavior(/datum/ai_behavior/monkey_equip/ground, BB_MONKEY_PICKUPTARGET)
	return TRUE

///Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/living_mob)
	// just to be safe
	if(QDELETED(living_mob))
		return

	add_blackboard_key_assoc(BB_MONKEY_ENEMIES, living_mob, MONKEY_HATRED_AMOUNT)

/datum/ai_controller/monkey/proc/on_attacked(datum/source, mob/attacker)
	SIGNAL_HANDLER
	if(prob(MONKEY_RETALIATE_PROB))
		retaliate(attacker)

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

/datum/ai_controller/monkey/proc/on_attempt_cuff(datum/source, mob/user)
	SIGNAL_HANDLER
	// chance of monkey retaliation
	if(prob(MONKEY_CUFF_RETALIATION_PROB))
		retaliate(user)

/datum/ai_controller/monkey/proc/update_movespeed(mob/living/pawn)
	SIGNAL_HANDLER
	movement_delay = pawn.cached_multiplicative_slowdown
