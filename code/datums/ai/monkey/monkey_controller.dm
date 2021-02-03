/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/monkey
	blackboard = list(BB_MONKEY_AGRESSIVE = FALSE,\
	BB_MONKEY_BEST_FORCE_FOUND = 0,\
	BB_MONKEY_ENEMIES = list(),\
	BB_MONKEY_BLACKLISTITEMS = list(),\
	BB_MONKEY_PICKUPTARGET = null,\
	BB_MONKEY_PICKPOCKETING = FALSE,
	BB_MONKEY_DISPOSING = FALSE,
	BB_MONKEY_TARGET_DISPOSAL = null,
	BB_MONKEY_CURRENT_ATTACK_TARGET = null,
	BB_MONKEY_CURRENT_ATTACK_TARGET)

/datum/ai_controller/monkey/angry

/datum/ai_controller/monkey/angry/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	blackboard[BB_MONKEY_AGRESSIVE] = TRUE //Angry cunt

/datum/ai_controller/monkey/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_PAW, .proc/on_attack_paw)
	RegisterSignal(new_pawn, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(new_pawn, COMSIG_ATOM_HITBY, .proc/on_hitby)
	RegisterSignal(new_pawn, COMSIG_MOVABLE_CROSSED, .proc/on_Crossed)
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, .proc/on_startpulling)
	RegisterSignal(new_pawn, COMSIG_LIVING_TRY_SYRINGE, .proc/on_try_syringe)
	RegisterSignal(new_pawn, COMSIG_ATOM_HULK_ATTACK, .proc/on_attack_hulk)
	RegisterSignal(new_pawn, COMSIG_CARBON_CUFF_ATTEMPTED, .proc/on_attempt_cuff)
	return ..() //Run parent at end

/datum/ai_controller/monkey/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_MOVABLE_CROSSED, COMSIG_LIVING_START_PULL,\
	COMSIG_LIVING_TRY_SYRINGE, COMSIG_ATOM_HULK_ATTACK, COMSIG_CARBON_CUFF_ATTEMPTED))
	return ..() //Run parent at end

/datum/ai_controller/monkey/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/monkey/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/living_pawn = pawn

	if(SHOULD_RESIST(living_pawn) && DT_PROB(MONKEY_RESIST_PROB, delta_time))
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/resist) //BRO IM ON FUCKING FIRE BRO
		return //IM NOT DOING ANYTHING ELSE BUT EXTUINGISH MYSELF, GOOD GOD HAVE MERCY.

	var/list/enemies = blackboard[BB_MONKEY_ENEMIES]

	if(HAS_TRAIT(pawn, TRAIT_PACIFISM)) //Not a pacifist? lets try some combat behavior.
		return
	if(length(enemies) || blackboard[BB_MONKEY_AGRESSIVE]) //We have enemies or are pissed

		var/mob/living/selected_enemy

		for(var/mob/living/possible_enemy in view(MONKEY_ENEMY_VISION, living_pawn))
			if(possible_enemy == living_pawn || (!enemies[possible_enemy] && (!blackboard[BB_MONKEY_AGRESSIVE] || HAS_AI_CONTROLLER_TYPE(possible_enemy, /datum/ai_controller/monkey)))) //Are they an enemy? (And do we even care?)
				continue

			selected_enemy = possible_enemy
			break
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

			return //Too busy fighting to steal atm.

	else if(DT_PROB(MONKEY_SHENANIGAN_PROB, delta_time))
		if(TryFindWeapon()) //Found a better weapon, let's grab it first.
			return

///re-used behavior pattern by monkeys for finding a weapon
/datum/ai_controller/monkey/proc/TryFindWeapon()
	var/mob/living/living_pawn = pawn

	if(!locate(/obj/item) in living_pawn.held_items)
		blackboard[BB_MONKEY_BEST_FORCE_FOUND] = 0

	var/obj/item/W
	for(var/obj/item/i in oview(2, living_pawn))
		if(!istype(i))
			continue
		if(HAS_TRAIT(i, TRAIT_NEEDS_TWO_HANDS) || blackboard[BB_MONKEY_BLACKLISTITEMS][i] || i.force > blackboard[BB_MONKEY_BEST_FORCE_FOUND])
			continue
		W = i
		break

	if(W)
		blackboard[BB_MONKEY_PICKUPTARGET] = W
		current_movement_target = W
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_equip/ground)
		return TRUE
	else
		var/mob/living/carbon/human/H = locate(/mob/living/carbon/human/) in oview(2,living_pawn)
		if(H)
			W = pick(H.held_items)
			if(W && !blackboard[BB_MONKEY_BLACKLISTITEMS][W] && W.force > blackboard[BB_MONKEY_BEST_FORCE_FOUND] && !HAS_TRAIT(W, TRAIT_NEEDS_TWO_HANDS))
				blackboard[BB_MONKEY_PICKUPTARGET] = W
				current_movement_target = W
				current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/monkey_equip/pickpocket)
				return TRUE

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
	if(L.a_intent == INTENT_HARM && prob(MONKEY_RETALIATE_HARM_PROB))
		retaliate(L)
	else if(L.a_intent == INTENT_DISARM && prob(MONKEY_RETALIATE_DISARM_PROB))
		retaliate(L)

/datum/ai_controller/monkey/proc/on_attack_paw(datum/source, mob/living/L)
	SIGNAL_HANDLER
	if(L.a_intent == INTENT_HARM && prob(MONKEY_RETALIATE_HARM_PROB))
		retaliate(L)
	else if(L.a_intent == INTENT_DISARM && prob(MONKEY_RETALIATE_DISARM_PROB))
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

/datum/ai_controller/monkey/proc/on_Crossed(datum/source, atom/movable/AM)
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
