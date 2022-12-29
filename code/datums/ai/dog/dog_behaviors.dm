/**
 * Pursue the target, growl if we're close, and bite if we're adjacent
 * Dogs are actually not very aggressive and won't attack unless you approach them
 * Adds a floor to the melee damage of the dog, as most pet dogs don't actually have any melee strength
 */
/datum/ai_behavior/basic_melee_attack/dog
	action_cooldown = 0.8 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3

/datum/ai_behavior/basic_melee_attack/dog/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	controller.behavior_cooldowns[src] = world.time + action_cooldown
	var/mob/living/living_pawn = controller.pawn
	if(!(isturf(living_pawn.loc) || HAS_TRAIT(living_pawn, TRAIT_AI_BAGATTACK))) // Void puppies can attack from inside bags
		finish_action(controller, FALSE, target_key, targetting_datum_key, hiding_location_key)
		return

	// Unfortunately going to repeat this check in parent call but what can you do
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if (!targetting_datum.can_attack(living_pawn, target))
		finish_action(controller, FALSE, target_key, targetting_datum_key, hiding_location_key)
		return

	if (!in_range(living_pawn, target))
		growl_at(living_pawn, target, delta_time)
		return

	if(!controller.blackboard[BB_DOG_HARASS_HARM])
		paw_harmlessly(living_pawn, target, delta_time)
		return

	// Give Ian some teeth
	var/old_melee_lower = living_pawn.melee_damage_lower
	var/old_melee_upper = living_pawn.melee_damage_upper
	living_pawn.melee_damage_lower = max(5, old_melee_lower)
	living_pawn.melee_damage_upper = max(10, old_melee_upper)

	. = ..() // Bite time

	living_pawn.melee_damage_lower = old_melee_lower
	living_pawn.melee_damage_upper = old_melee_upper

/// Swat at someone we don't like but won't hurt
/datum/ai_behavior/basic_melee_attack/dog/proc/paw_harmlessly(mob/living/living_pawn, atom/target, delta_time)
	if(!DT_PROB(20, delta_time))
		return
	living_pawn.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	target.visible_message(span_danger("[living_pawn] paws ineffectually at [target]!"), span_danger("[living_pawn] paws ineffectually at you!"))

/// Let them know we mean business
/datum/ai_behavior/basic_melee_attack/dog/proc/growl_at(mob/living/living_pawn, atom/target, delta_time)
	if(!DT_PROB(15, delta_time))
		return
	living_pawn.manual_emote("[pick("barks", "growls", "stares")] menacingly at [target]!")
	if(!DT_PROB(40, delta_time))
		return
	playsound(living_pawn, pick('sound/creatures/dog/growl1.ogg', 'sound/creatures/dog/growl2.ogg'), 50, TRUE, -1)
