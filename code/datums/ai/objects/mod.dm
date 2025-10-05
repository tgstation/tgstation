/// An AI controller for the MODsuit pathfinder module. It's activated by module and attaches itself to the user.
/datum/ai_controller/mod
	blackboard = list(
		BB_MOD_TARGET,
		BB_MOD_MODULE,
	)
	can_idle = FALSE
	max_target_distance = MOD_AI_RANGE //a little spicy but its one specific item that summons it, and it doesn't run otherwise
	ai_movement = /datum/ai_movement/jps/modsuit
	///ID card generated from the suit's required access. Used for pathing.
	var/obj/item/card/id/advanced/id_card

/datum/ai_controller/mod/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /obj/item/mod/control))
		return AI_CONTROLLER_INCOMPATIBLE
	var/obj/item/mod/control/mod = new_pawn
	id_card = new /obj/item/card/id/advanced/simple_bot()
	if(length(mod.req_access))
		id_card.set_access(mod.req_access)
	return ..() //Run parent at end

/datum/ai_controller/mod/UnpossessPawn(destroy)
	QDEL_NULL(id_card)
	return ..() //Run parent at end

/datum/ai_controller/mod/SelectBehaviors(seconds_per_tick)
	current_behaviors = list()
	if(blackboard[BB_MOD_TARGET] && blackboard[BB_MOD_MODULE])
		queue_behavior(/datum/ai_behavior/mod_attach)

/datum/ai_controller/mod/get_access()
	return id_card.GetAccess()

/datum/ai_behavior/mod_attach
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT|AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/mod_attach/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!controller.pawn.Adjacent(controller.blackboard[BB_MOD_TARGET]))
		return AI_BEHAVIOR_DELAY
	var/obj/item/mod/module/pathfinder/module = controller.blackboard[BB_MOD_MODULE]
	module.attach(controller.blackboard[BB_MOD_TARGET])
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/mod_attach/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_MOD_TARGET)
	var/obj/item/mod/module/pathfinder/module = controller.blackboard[BB_MOD_MODULE]
	module.end_recall(succeeded)
