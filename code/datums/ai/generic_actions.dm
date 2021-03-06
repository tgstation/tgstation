
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


///Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
/datum/ai_behavior/find_and_set
	action_cooldown = 15 SECONDS
	var/locate_path
	var/bb_key_to_set

/datum/ai_behavior/find_and_set/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/atom/find_this_thing = search_tactic(controller)
	if(find_this_thing)
		controller.blackboard[bb_key_to_set] = find_this_thing
		react_to_success(controller)
		finish_action(controller, TRUE)
	else
		react_to_failure(controller)
		finish_action(controller, FALSE)

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller)
	return locate(locate_path) in oview(7, controller.pawn)

/datum/ai_behavior/find_and_set/proc/react_to_success(datum/ai_controller/controller)
	return

/datum/ai_behavior/find_and_set/proc/react_to_failure(datum/ai_controller/controller)
	return

///Goes to the move target, and forcemoves it inside itself. Simple creatures will enjoy this, more advanced ones should probably put in hands or something.
/datum/ai_behavior/forcemove_grab
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1 //it looks better because of pickup animations
	var/grab_verb = "grabs"
	var/bb_key_target

/datum/ai_behavior/forcemove_grab/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/obj/item/grabbed_item = controller.blackboard[bb_key_target]
	grabbed_item.do_pickup_animation(controller.pawn)
	controller.pawn.visible_message("<span class='notice'>[controller.pawn] [grab_verb] [grabbed_item]!</span>")
	grabbed_item.forceMove(controller.pawn)
	finish_action(controller, TRUE)

///pawn will flush an item down disposals (so not mobs!)
/datum/ai_behavior/disposals_item
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1
	var/bb_key_target
	///You can use /datum/ai_behavior/find_and_set to locate a disposals bin, pretty handy stuff
	var/bb_key_disposals

/datum/ai_behavior/disposals_item/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/disposals_user = controller.pawn
	var/obj/machinery/disposal/bin/bin = controller.blackboard[bb_key_disposals]
	var/atom/movable/throw_away = controller.blackboard[bb_key_target]

	bin.place_item_in_disposal(throw_away, disposals_user)
	controller.blackboard[bb_key_target] = null //cave johnson we're done here (we probably don't need this again.)

	react_to_success(controller.pawn)
	finish_action(controller, TRUE)

/datum/ai_behavior/disposals_item/proc/react_to_success(mob/pawn)
	return
