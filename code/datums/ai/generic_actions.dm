
/datum/ai_behavior/resist/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.resist()
	finish_action(controller, TRUE)

/datum/ai_behavior/battle_screech
	///List of possible screeches the behavior has
	var/list/screeches

/datum/ai_behavior/battle_screech/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick(screeches))
	finish_action(controller, TRUE)

///Moves to target then finishes
/datum/ai_behavior/move_to_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/move_to_target/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE)


/datum/ai_behavior/break_spine
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 0.7 SECONDS
	var/target_key
	var/give_up_distance = 10


/datum/ai_behavior/break_spine/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/batman = controller.blackboard[target_key]
	var/mob/living/big_guy = controller.pawn //he was molded by the darkness

	if(batman.stat)
		finish_action(controller, TRUE)

	if(get_dist(batman, big_guy) >= give_up_distance)
		finish_action(controller, FALSE)

	big_guy.start_pulling(batman)
	big_guy.setDir(get_dir(big_guy, batman))

	batman.visible_message("<span class='warning'>[batman] gets a slightly too tight hug from [big_guy]!</span>", "<span class='userdanger'>You feel your body break as [big_guy] embraces you!</span>")

	if(iscarbon(batman))
		var/mob/living/carbon/carbon_batman = batman
		for(var/obj/item/bodypart/bodypart_to_break in carbon_batman.bodyparts)
			if(bodypart_to_break.body_zone == BODY_ZONE_HEAD)
				continue
			bodypart_to_break.receive_damage(brute = 15, wound_bonus = 35)
	else
		batman.adjustBruteLoss(150)

	finish_action(controller, TRUE)

/datum/ai_behavior/break_spine/finish_action(datum/ai_controller/controller, succeeded)
	if(succeeded)
		controller.blackboard[target_key] = null
	return ..()
