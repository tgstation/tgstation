/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	movement_delay = 0.4 SECONDS
	planning_subtrees = list(
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/monkey_combat,
		/datum/ai_planning_subtree/generic_hunger,
		/datum/ai_planning_subtree/generic_play_instrument,
		/datum/ai_planning_subtree/monkey_shenanigans,
	)
	blackboard = list(
		BB_MONKEY_AGGRESSIVE = FALSE,
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
		BB_SONG_LINES = MONKEY_SONG,
	)
	idle_behavior = /datum/idle_behavior/idle_monkey

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
	blackboard[BB_MONKEY_AGGRESSIVE] = TRUE //Angry cunt

/datum/ai_controller/monkey/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	var/mob/living/living_pawn = new_pawn
	living_pawn.AddElement(/datum/element/relay_attackers)
	RegisterSignal(new_pawn, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, PROC_REF(on_startpulling))
	RegisterSignal(new_pawn, COMSIG_LIVING_TRY_SYRINGE, PROC_REF(on_try_syringe))
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, PROC_REF(on_attempt_cuff))
	RegisterSignal(new_pawn, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))

	movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..() //Run parent at end

/datum/ai_controller/monkey/UnpossessPawn(destroy)

	UnregisterSignal(pawn, list(
		COMSIG_ATOM_WAS_ATTACKED,
		COMSIG_LIVING_START_PULL,
		COMSIG_LIVING_TRY_SYRINGE,
		COMSIG_CARBON_CUFF_ATTEMPTED,
		COMSIG_MOB_MOVESPEED_UPDATED,
	))

	return ..() //Run parent at end

/datum/ai_controller/monkey/on_sentience_lost()
	. = ..()
	set_trip_mode(mode = TRUE)

/datum/ai_controller/monkey/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/monkey/get_human_examine_text()
	var/text = "[span_monkey("[pawn.p_they(TRUE)] have a primal look in [pawn.p_their()] eyes.")]"
	return text

/datum/ai_controller/monkey/proc/set_trip_mode(mode = TRUE)
	var/mob/living/carbon/regressed_monkey = pawn
	var/brain = regressed_monkey.getorganslot(ORGAN_SLOT_BRAIN)
	if(istype(brain, /obj/item/organ/internal/brain/primate)) // In case we are a monkey AI in a human brain by who was previously controlled by a client but it now not by some marvel
		var/obj/item/organ/internal/brain/primate/monkeybrain = brain
		monkeybrain.tripping = mode

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

	for(var/obj/item/item in living_pawn.held_items) // If we've got some garbage in out hands thats going to stop us from effectivly attacking, we should get rid of it.
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

	if(weapon.force < 2) // our bite does 2 damage on avarage, no point in settling for anything less
		return FALSE

	blackboard[BB_MONKEY_PICKUPTARGET] = weapon
	set_movement_target(type, weapon)
	if(pickpocket)
		queue_behavior(/datum/ai_behavior/monkey_equip/pickpocket)
	else
		queue_behavior(/datum/ai_behavior/monkey_equip/ground)
	return TRUE

///Reactive events to being hit
/datum/ai_controller/monkey/proc/retaliate(mob/living/L)
	var/list/enemies = blackboard[BB_MONKEY_ENEMIES]
	enemies[WEAKREF(L)] += MONKEY_HATRED_AMOUNT

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

/datum/ai_controller/monkey/proc/target_del(target)
	SIGNAL_HANDLER
	blackboard[BB_MONKEY_BLACKLISTITEMS] -= target
