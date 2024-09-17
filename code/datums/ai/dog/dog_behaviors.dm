/**
 * Pursue the target, growl if we're close, and bite if we're adjacent
 * Dogs are actually not very aggressive and won't attack unless you approach them
 * Adds a floor to the melee damage of the dog, as most pet dogs don't actually have any melee strength
 */
/datum/ai_behavior/basic_melee_attack/dog
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3

/datum/ai_behavior/basic_melee_attack/dog/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	controller.behavior_cooldowns[src] = world.time + get_cooldown(controller)
	var/mob/living/living_pawn = controller.pawn
	if(!(isturf(living_pawn.loc) || HAS_TRAIT(living_pawn, TRAIT_AI_BAGATTACK))) // Void puppies can attack from inside bags
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	// Unfortunately going to repeat this check in parent call but what can you do
	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if (!targeting_strategy.can_attack(living_pawn, target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if (!living_pawn.Adjacent(target))
		growl_at(living_pawn, target, seconds_per_tick)
		return AI_BEHAVIOR_INSTANT

	if(!controller.blackboard[BB_DOG_HARASS_HARM])
		paw_harmlessly(living_pawn, target, seconds_per_tick)
		return AI_BEHAVIOR_INSTANT

	// Give Ian some teeth
	var/old_melee_lower = living_pawn.melee_damage_lower
	var/old_melee_upper = living_pawn.melee_damage_upper
	living_pawn.melee_damage_lower = max(5, old_melee_lower)
	living_pawn.melee_damage_upper = max(10, old_melee_upper)

	. = ..() // Bite time

	living_pawn.melee_damage_lower = old_melee_lower
	living_pawn.melee_damage_upper = old_melee_upper
	return AI_BEHAVIOR_DELAY

/// Swat at someone we don't like but won't hurt
/datum/ai_behavior/basic_melee_attack/dog/proc/paw_harmlessly(mob/living/living_pawn, atom/target, seconds_per_tick)
	if(!SPT_PROB(20, seconds_per_tick))
		return
	living_pawn.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(target, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
	target.visible_message(span_danger("[living_pawn] paws ineffectually at [target]!"), span_danger("[living_pawn] paws ineffectually at you!"))

/// Let them know we mean business
/datum/ai_behavior/basic_melee_attack/dog/proc/growl_at(mob/living/living_pawn, atom/target, seconds_per_tick)
	if(!SPT_PROB(15, seconds_per_tick))
		return
	living_pawn.manual_emote("[pick("barks", "growls", "stares")] menacingly at [target]!")
	if(!SPT_PROB(40, seconds_per_tick))
		return
	playsound(living_pawn, pick('sound/mobs/non-humanoids/dog/growl1.ogg', 'sound/mobs/non-humanoids/dog/growl2.ogg'), 50, TRUE, -1)
