/// Performs an action on a blackboard-keyed hunt target once in range.
/// Movement to the target is handled externally via a move_to_target leaf.
/datum/bt_node/ai_behavior/hunt_target
	/// Blackboard key holding the atom to hunt
	var/target_key
	/// Blackboard key to record the cooldown timestamp on success; if null, no cooldown is set
	var/cooldown_key
	/// Duration of the post-hunt cooldown
	var/hunt_cooldown = 5 SECONDS
	/// If TRUE, clears target_key after every hunt regardless of success
	var/always_reset_target = FALSE

/datum/bt_node/ai_behavior/hunt_target/setup(datum/ai_controller/controller)
	var/atom/hunted = controller.blackboard[target_key]
	return !QDELETED(hunted)

/datum/bt_node/ai_behavior/hunt_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/hunted = controller.blackboard[target_key]
	if(QDELETED(hunted))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	target_caught(controller.pawn, hunted)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/hunt_target/proc/target_caught(mob/living/hunter, atom/hunted)
	if(isliving(hunted))
		var/mob/living/living_target = hunted
		hunter.manual_emote("chomps [living_target]!")
		living_target.investigate_log("has been killed by [key_name(hunter)].", INVESTIGATE_DEATHS)
		living_target.death()
	else if(IS_EDIBLE(hunted))
		hunted.attack_animal(hunter)
	else
		hunter.manual_emote("chomps [hunted]!")
		qdel(hunted)

/datum/bt_node/ai_behavior/hunt_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded && cooldown_key)
		controller.set_blackboard_key(cooldown_key, world.time + hunt_cooldown)
	else if(target_key)
		controller.clear_blackboard_key(target_key)
	if(always_reset_target && target_key)
		controller.clear_blackboard_key(target_key)

/// Uses ai_interact() on the target instead of default kill/eat/qdel.
/// behavior_combat_mode, always_reset_target, and hunt_cooldown are all configurable
/datum/bt_node/ai_behavior/hunt_target/interact_with_target
	/// Combat mode to use when interacting with the target
	var/behavior_combat_mode = TRUE

/datum/bt_node/ai_behavior/hunt_target/interact_with_target/target_caught(mob/living/hunter, atom/hunted)
	hunter.ai_controller.ai_interact(target = hunted, combat_mode = behavior_combat_mode)

/// Uses a cooldown ability from ability_key on the target.
/datum/bt_node/ai_behavior/hunt_target/use_ability_on_target
	always_reset_target = TRUE
	/// Blackboard key holding the /datum/action/cooldown ability to use
	var/ability_key

/datum/bt_node/ai_behavior/hunt_target/use_ability_on_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return ..()

/datum/bt_node/ai_behavior/hunt_target/use_ability_on_target/target_caught(mob/living/hunter, atom/hunted)
	var/datum/action/cooldown/ability = hunter.ai_controller.blackboard[ability_key]
	ability.InterceptClickOn(hunter, null, hunted)

/// Celebrates around the target with a spin animation.
/datum/bt_node/ai_behavior/hunt_target/snail_people
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/snail_people/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("Celebrates around [hunted]!")
	hunter.SpinAnimation(speed = 1, loops = 3)

/// Starts pulling the target item toward the hunter.
/datum/bt_node/ai_behavior/hunt_target/pull_target
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/pull_target/target_caught(mob/living/hunter, obj/item/hunted)
	hunter.start_pulling(hunted)

/// Emotes enjoyment of the target's scent.
/datum/bt_node/ai_behavior/hunt_target/sniff_flora
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/sniff_flora/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("Enjoys the sweet scent eminating from [hunted::name]!")

/// Playfully headbutts the target's legs.
/datum/bt_node/ai_behavior/hunt_target/headbutt_leg
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/headbutt_leg/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("playfully headbutts [hunted]'s legs!")

/// Attempts to buckle (latch onto) the target mob.
/datum/bt_node/ai_behavior/hunt_target/latch_onto

/datum/bt_node/ai_behavior/hunt_target/latch_onto/setup(datum/ai_controller/controller)
	if(!..())
		return FALSE
	var/mob/living/living_pawn = controller.pawn
	return !living_pawn.buckled

/datum/bt_node/ai_behavior/hunt_target/latch_onto/target_caught(mob/living/hunter, obj/hunted)
	if(hunter.buckled)
		return FALSE
	if(!hunted.buckle_mob(hunter, force = TRUE))
		return FALSE
	hunted.visible_message(span_notice("[hunted] has been latched onto by [hunter]!"))
	return TRUE


/datum/bt_node/ai_behavior/hunt_target/play_with_owner
	always_reset_target = TRUE

/datum/bt_node/ai_behavior/hunt_target/play_with_owner/target_caught(mob/living/hunter, atom/hunted)
	var/list/interactions_list = hunter.ai_controller.blackboard[BB_INTERACTIONS_WITH_OWNER]
	var/interaction_message = length(interactions_list) ? pick(interactions_list) : "Plays with"
	hunter.manual_emote("[interaction_message] [hunted]!")
