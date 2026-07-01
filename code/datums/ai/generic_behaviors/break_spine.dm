/// Applies full-body brute damage to a target while pulling them. Used with a move_to_target sequence.
/datum/bt_node/ai_behavior/break_spine
	var/target_key
	var/give_up_distance = 10

/datum/bt_node/ai_behavior/break_spine/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/batman = controller.blackboard[target_key]
	var/mob/living/big_guy = controller.pawn

	if(QDELETED(batman) || get_dist(batman, big_guy) >= give_up_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(batman.stat != CONSCIOUS)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	INVOKE_ASYNC(big_guy, TYPE_PROC_REF(/atom/movable, start_pulling), batman)
	big_guy.face_atom(batman)
	batman.visible_message(span_warning("[batman] gets a slightly too tight hug from [big_guy]!"), span_userdanger("You feel your body break as [big_guy] embraces you!"))
	for(var/zone in GLOB.all_body_zones - BODY_ZONE_HEAD)
		batman.apply_damage(15, BRUTE, zone, wound_bonus = 35)

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/break_spine/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded)
		var/mob/living/attacker = controller.pawn
		if(!QDELETED(attacker))
			attacker.stop_pulling()
		controller.clear_blackboard_key(target_key)

/// Bane variant: says a quote from bane.json on successful spine-breaking.
/datum/bt_node/ai_behavior/break_spine/bane

/datum/bt_node/ai_behavior/break_spine/bane/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded)
		var/mob/living/bane = controller.pawn
		if(QDELETED(bane))
			return
		var/list/bane_quotes = strings("bane.json", "bane")
		bane.say(pick(bane_quotes))
