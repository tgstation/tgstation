/// Returns TRUE if the vending machine pawn is currently tilted.
/datum/bt_node/decorator/vending_is_tilted/check_condition(datum/ai_controller/controller)
	var/obj/machinery/vending/vendor_pawn = controller.pawn
	return vendor_pawn.tilted

/// Searches nearby tiles for a valid living target and sets the given BB key. Sets tilt cooldown and fails if none found.
/datum/bt_node/ai_behavior/find_vendor_target
	var/target_key
	var/vision_range
	/// Cooldown applied to BB_VENDING_TILT_COOLDOWN when no valid target is in range
	var/search_cooldown = 2 SECONDS

/datum/bt_node/ai_behavior/find_vendor_target/perform(seconds_per_tick, datum/ai_controller/controller)
	for(var/mob/living/living_target in oview(vision_range, controller.pawn))
		if(living_target.stat || living_target.incorporeal_move)
			continue
		controller.set_blackboard_key(target_key, living_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	controller.clear_blackboard_key(target_key)
	controller.set_blackboard_key(BB_VENDING_TILT_COOLDOWN, world.time + search_cooldown)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Telegraphs and tilts onto the target. Returns success once the machine is tilted.
/datum/bt_node/ai_behavior/vendor_crush
	var/target_key
	/// Time to telegraph before tilting
	var/time_to_tilt = 0.8 SECONDS
	/// Time before machine can untilt after a tilt attempt
	var/untilt_cooldown = 1 SECONDS

/datum/bt_node/ai_behavior/vendor_crush/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/machinery/vending/vendor_pawn = controller.pawn
	if(vendor_pawn.tilted)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(controller.blackboard[BB_VENDING_BUSY_TILTING])
		return AI_BEHAVIOR_DELAY
	controller.ai_movement.stop_moving_towards(controller)
	controller.set_blackboard_key(BB_VENDING_BUSY_TILTING, TRUE)
	var/turf/target_turf = get_turf(controller.blackboard[target_key])
	new /obj/effect/temp_visual/telegraphing/vending_machine_tilt(target_turf)
	addtimer(CALLBACK(src, PROC_REF(tiltonmob), controller, target_turf), time_to_tilt)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/vendor_crush/proc/tiltonmob(datum/ai_controller/controller, turf/target_turf)
	if(QDELETED(controller) || QDELETED(controller.pawn))
		return
	var/obj/machinery/vending/vendor_pawn = controller.pawn
	if(vendor_pawn.tilt(target_turf, 0) & SUCCESSFULLY_CRUSHED_MOB)
		vendor_pawn.say(pick("Supersize this!", "Eat my shiny metal ass!", "Want to consume some of my products?", "SMASH!", "Don't you love these smashing prices!"))
		controller.set_blackboard_key(BB_VENDING_LAST_HIT_SUCCESSFUL, TRUE)
	else
		if(vendor_pawn.icon_deny)
			flick(vendor_pawn.icon_deny, vendor_pawn)
		vendor_pawn.say(pick("Get back here!", "Don't you want my well priced love?"))
		controller.set_blackboard_key(BB_VENDING_LAST_HIT_SUCCESSFUL, FALSE)
	controller.set_blackboard_key(BB_VENDING_UNTILT_COOLDOWN, world.time + untilt_cooldown)
	controller.set_blackboard_key(BB_VENDING_BUSY_TILTING, FALSE)

/datum/bt_node/ai_behavior/vendor_crush/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.set_blackboard_key(BB_VENDING_BUSY_TILTING, FALSE)

/// Untilts the machine. Sets a tilt cooldown if the previous hit was successful.
/datum/bt_node/ai_behavior/vendor_rise_up
	/// Time before machine can tilt again after untilting if the last hit landed
	var/success_tilt_cooldown = 5 SECONDS

/datum/bt_node/ai_behavior/vendor_rise_up/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/machinery/vending/vendor_pawn = controller.pawn
	vendor_pawn.visible_message(span_warning("[vendor_pawn] untilts itself!"))
	if(controller.blackboard[BB_VENDING_LAST_HIT_SUCCESSFUL])
		controller.set_blackboard_key(BB_VENDING_TILT_COOLDOWN, world.time + success_tilt_cooldown)
	vendor_pawn.untilt()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
