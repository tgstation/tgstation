// None of these are really complex enough to merit their own file

/**
 * # Pet Command: Idle
 * Tells a pet to resume its idle behaviour, usually staying put where you leave it
 */
/datum/pet_command/idle
	command_name = "Stay"
	command_desc = "Command your pet to stay idle in this location."
	radial_icon_state = "halt"
	speech_commands = list("sit", "stay", "stop")
	command_feedback = "sits"

/datum/pet_command/idle/execute_action(datum/ai_controller/controller)
	return SUBTREE_RETURN_FINISH_PLANNING // This cancels further AI planning

/datum/pet_command/idle/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to stay idle!"

/**
 * # Pet Command: Stop
 * Tells a pet to exit command mode and resume its normal behaviour, which includes regular target-seeking and what have you
 */
/datum/pet_command/free
	command_name = "Loose"
	command_desc = "Allow your pet to resume its natural behaviours."
	radial_icon_state = "free"
	speech_commands = list("free", "loose")
	command_feedback = "relaxes"

/datum/pet_command/free/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return // Just move on to the next planning subtree.

/datum/pet_command/free/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to go free!"

/**
 * # Pet Command: Follow
 * Tells a pet to follow you until you tell it to do something else
 */
/datum/pet_command/follow
	command_name = "Follow"
	command_desc = "Command your pet to accompany you."
	radial_icon_state = "follow"
	speech_commands = list("heel", "follow")
	callout_type = /datum/callout_option/move
	///the behavior we use to follow
	var/follow_behavior = /datum/ai_behavior/pet_follow_friend
	///should we activate immediately if we're doing nothing else and gain a friend?
	var/activate_on_befriend = FALSE

/datum/pet_command/follow/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	set_command_target(parent, commander)

/datum/pet_command/follow/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to follow!"

/datum/pet_command/follow/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(follow_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/follow/add_new_friend(mob/living/tamer)
	. = ..()
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return
	if (activate_on_befriend && !parent.ai_controller.blackboard_key_exists(BB_ACTIVE_PET_COMMAND))
		try_activate_command(tamer)

/// Like follow but start active
/datum/pet_command/follow/start_active
	activate_on_befriend = TRUE

/**
 * # Pet Command: Play Dead
 * Pretend to be dead for a random period of time
 */
/datum/pet_command/play_dead
	command_name = "Play Dead"
	command_desc = "Play a macabre trick."
	radial_icon_state = "play_dead"
	speech_commands = list("play dead") // Don't get too creative here, people talk about dying pretty often

/datum/pet_command/play_dead/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(/datum/ai_behavior/play_dead)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/play_dead/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to play dead!"

/**
 * # Pet Command: Good Boy
 * React if complimented
 */
/datum/pet_command/good_boy
	command_name = "Good Boy"
	command_desc = "Give your pet a compliment."
	hidden = TRUE

/datum/pet_command/good_boy/New(mob/living/parent)
	. = ..()
	speech_commands += "good [parent.name]"
	switch (parent.gender)
		if (MALE)
			speech_commands += "good boy"
			return
		if (FEMALE)
			speech_commands += "good girl"
			return
	// If we get past this point someone has finally added a non-binary dog

/datum/pet_command/good_boy/execute_action(datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	var/mob/living/parent = weak_parent.resolve()
	if (!parent)
		return SUBTREE_RETURN_FINISH_PLANNING

	new /obj/effect/temp_visual/heart(parent.loc)
	parent.emote("spin")
	return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Pet Command: Use ability
 * Use an an ability that does not require any targets
 */
/datum/pet_command/untargeted_ability
	///untargeted ability we will use
	var/ability_key

/datum/pet_command/untargeted_ability/execute_action(datum/ai_controller/controller)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, ability_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/untargeted_ability/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to use an ability!"

/**
 * # Pet Command: Attack
 * Tells a pet to chase and bite the next thing you point at
 */
/datum/pet_command/attack
	command_name = "Attack"
	command_desc = "Command your pet to attack things that you point out to it."
	radial_icon_state = "attack"
	requires_pointing = TRUE
	callout_type = /datum/callout_option/attack
	speech_commands = list("attack", "sic", "kill")
	command_feedback = "growl"
	pointed_reaction = "and growls"
	/// Balloon alert to display if providing an invalid target
	var/refuse_reaction = "shakes head"
	/// Attack behaviour to use
	var/attack_behaviour = /datum/ai_behavior/basic_melee_attack

// Refuse to target things we can't target, chiefly other friends
/datum/pet_command/attack/set_command_target(mob/living/parent, atom/target)
	if (!target)
		return FALSE
	var/mob/living/living_parent = parent
	if (!living_parent.ai_controller)
		return FALSE
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(living_parent.ai_controller.blackboard[targeting_strategy_key])
	if (!targeter)
		return FALSE
	if (!targeter.can_attack(living_parent, target))
		refuse_target(parent, target)
		return FALSE
	return ..()

/datum/pet_command/attack/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to attack [target]!"

/// Display feedback about not targeting something
/datum/pet_command/attack/proc/refuse_target(mob/living/parent, atom/target)
	var/mob/living/living_parent = parent
	living_parent.balloon_alert_to_viewers("[refuse_reaction]")
	living_parent.visible_message(span_notice("[living_parent] refuses to attack [target]."))

/datum/pet_command/attack/execute_action(datum/ai_controller/controller)
	controller.queue_behavior(attack_behaviour, BB_CURRENT_PET_TARGET, targeting_strategy_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Breed command. breed with a partner!
 */
/datum/pet_command/breed
	command_name = "Breed"
	command_desc = "Command your pet to attempt to breed with a partner."
	requires_pointing = TRUE
	radial_icon_state = "breed"
	speech_commands = list("breed", "consummate")
	///the behavior we use to make babies
	var/datum/ai_behavior/reproduce_behavior = /datum/ai_behavior/make_babies

/datum/pet_command/breed/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !isliving(target))
		return FALSE
	if(!HAS_TRAIT(parent, TRAIT_MOB_BREEDER) || !HAS_TRAIT(target, TRAIT_MOB_BREEDER))
		return FALSE
	if(isnull(parent.ai_controller))
		return FALSE
	if(!parent.ai_controller.blackboard[BB_BREED_READY] || isnull(parent.ai_controller.blackboard[BB_BABIES_PARTNER_TYPES]))
		return FALSE
	var/mob/living/living_target = target
	if(!living_target.ai_controller?.blackboard[BB_BREED_READY])
		return FALSE
	return ..()

/datum/pet_command/breed/execute_action(datum/ai_controller/controller)
	if(is_type_in_list(controller.blackboard[BB_CURRENT_PET_TARGET], controller.blackboard[BB_BABIES_PARTNER_TYPES]))
		controller.queue_behavior(reproduce_behavior, BB_CURRENT_PET_TARGET)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/breed/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to breed with [target]!"

/**
 * # Pet Command: Targetted Ability
 * Tells a pet to use some kind of ability on the next thing you point at
 */
/datum/pet_command/use_ability
	command_name = "Use ability"
	command_desc = "Command your pet to use one of its special skills on something that you point out to it."
	radial_icon = 'icons/mob/actions/actions_spells.dmi'
	radial_icon_state = "projectile"
	requires_pointing = TRUE
	speech_commands = list("shoot", "blast", "cast")
	command_feedback = "growl"
	pointed_reaction = "and growls"
	/// Blackboard key where a reference to some kind of mob ability is stored
	var/pet_ability_key
	/// The AI behavior to use for the ability
	var/ability_behavior = /datum/ai_behavior/pet_use_ability

/datum/pet_command/use_ability/execute_action(datum/ai_controller/controller)
	if (!pet_ability_key)
		return
	var/datum/action/cooldown/using_action = controller.blackboard[pet_ability_key]
	if (QDELETED(using_action))
		return
	// We don't check if the target exists because we want to 'sit attentively' if we've been instructed to attack but not given one yet
	// We also don't check if the cooldown is over because there's no way a pet owner can know that, the behaviour will handle it
	controller.queue_behavior(ability_behavior, pet_ability_key, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/use_ability/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to use an ability on [target]!"

/datum/pet_command/protect_owner
	command_name = "Protect owner"
	command_desc = "Your pet will run to your aid."
	hidden = TRUE
	callout_type = /datum/callout_option/guard
	///the range our owner needs to be in for us to protect him
	var/protect_range = 9
	///the behavior we will use when he is attacked
	var/protect_behavior = /datum/ai_behavior/basic_melee_attack
	///message cooldown to prevent too many people from telling you not to commit suicide
	COOLDOWN_DECLARE(self_harm_message_cooldown)

/datum/pet_command/protect_owner/add_new_friend(mob/living/tamer)
	RegisterSignal(tamer, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(set_attacking_target))
	if(!HAS_TRAIT(tamer, TRAIT_RELAYING_ATTACKER))
		tamer.AddElement(/datum/element/relay_attackers)

/datum/pet_command/protect_owner/remove_friend(mob/living/unfriended)
	UnregisterSignal(unfriended, COMSIG_ATOM_WAS_ATTACKED)

/datum/pet_command/protect_owner/execute_action(datum/ai_controller/controller)
	var/mob/living/victim = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(QDELETED(victim))
		return
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!targeter.can_attack(controller.pawn, victim))
		return
	// cancel the action if they're below our given crit stat, OR if we're trying to attack ourselves (this can happen on tamed mobs w/ protect subtree rarely)
	if(victim.stat > controller.blackboard[BB_TARGET_MINIMUM_STAT] || victim == controller.pawn)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return
	controller.queue_behavior(protect_behavior, BB_CURRENT_PET_TARGET, BB_PET_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/protect_owner/set_command_active(mob/living/parent, mob/living/victim)
	. = ..()
	set_command_target(parent, victim)

/datum/pet_command/protect_owner/valid_callout_target(mob/living/speaker, datum/callout_option/callout, atom/target)
	return target == speaker || get_dist(speaker, target) <= 1

/datum/pet_command/protect_owner/proc/set_attacking_target(atom/source, mob/living/attacker)
	SIGNAL_HANDLER

	var/mob/living/basic/owner = weak_parent.resolve()
	if(isnull(owner))
		return
	if(source == attacker)
		var/list/interventions = owner.ai_controller?.blackboard[BB_OWNER_SELF_HARM_RESPONSES] || list()
		if (length(interventions) && COOLDOWN_FINISHED(src, self_harm_message_cooldown) && prob(30))
			COOLDOWN_START(src, self_harm_message_cooldown, 5 SECONDS)
			var/chosen_statement = pick(interventions)
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, say), chosen_statement)
		return
	var/mob/living/current_target = owner.ai_controller?.blackboard[BB_CURRENT_PET_TARGET]
	if(attacker == current_target) //we are already dealing with this target
		return
	if(isliving(attacker) && can_see(owner, attacker, protect_range))
		set_command_active(owner, attacker)

/**
 * # Fish command: command the mob to fish at the next fishing spot you point at. Requires the profound fisher component
 */
/datum/pet_command/fish
	command_name = "Fish"
	command_desc = "Command your pet to try fishing at a nearby fishing spot."
	requires_pointing = TRUE
	radial_icon_state = "fish"
	speech_commands = list("fish")

/datum/pet_command/fish/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(/datum/ai_behavior/interact_with_target/fishing, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/fish/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to go fish!"

/datum/pet_command/move
	command_name = "Move"
	command_desc = "Command your pet to move to a location!"
	requires_pointing = TRUE
	radial_icon_state = "move"
	speech_commands = list("move", "walk")
	///the behavior we use to walk towards targets
	var/datum/ai_behavior/walk_behavior = /datum/ai_behavior/travel_towards

/datum/pet_command/move/set_command_target(mob/living/parent, atom/target)
	if(isnull(target) || !can_see(parent, target, 9))
		return FALSE
	return ..()

/datum/pet_command/move/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(walk_behavior, BB_CURRENT_PET_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/move/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to move!"
