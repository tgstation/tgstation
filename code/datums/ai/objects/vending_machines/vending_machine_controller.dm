///AI controller for vending machine gone rogue, Don't try using this on anything else, it wont work.
/datum/ai_controller/vending_machine
	movement_delay = 0.4 SECONDS
	blackboard = list(BB_VENDING_CURRENT_TARGET = null,
	BB_VENDING_TILT_COOLDOWN = 0,
	BB_VENDING_UNTILT_COOLDOWN = 0,
	BB_VENDING_BUSY_TILTING = FALSE,
	BB_VENDING_LAST_HIT_SUCCESFUL = FALSE)
	var/vision_range = 7
	var/search_for_enemy_cooldown = 2 SECONDS

/datum/ai_controller/vending_machine/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /obj/machinery/vending))
		return AI_CONTROLLER_INCOMPATIBLE
	var/obj/machinery/vending/vendor_pawn = new_pawn
	vendor_pawn.tiltable = FALSE  //Not manually tiltable by hitting it anymore. We are now agressively doing it ourselves.
	vendor_pawn.AddElement(/datum/element/waddling)
	vendor_pawn.AddComponent(/datum/component/footstep, FOOTSTEP_OBJ_MACHINE, 1, -6, vary = TRUE)
	vendor_pawn.squish_damage = 15
	return ..() //Run parent at end

/datum/ai_controller/vending_machine/UnpossessPawn(destroy)
	var/obj/machinery/vending/vendor_pawn = pawn
	vendor_pawn.tiltable = TRUE
	vendor_pawn.RemoveElement(/datum/element/waddling)
	vendor_pawn.squish_damage = initial(vendor_pawn.squish_damage)
	qdel(vendor_pawn.GetComponent(/datum/component/footstep))
	return ..() //Run parent at end

/datum/ai_controller/vending_machine/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/obj/machinery/vending/vendor_pawn = pawn

	if(vendor_pawn.tilted) //We're tilted, try to untilt
		if(blackboard[BB_VENDING_UNTILT_COOLDOWN] > world.time)
			return
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/vendor_rise_up)
		return
	else //Not tilted, try to find target to tilt onto.
		if(blackboard[BB_VENDING_TILT_COOLDOWN] > world.time)
			return
		for(var/mob/living/living_target in oview(vision_range, pawn))
			if(living_target.stat) //They're already fucked up
				continue
			current_movement_target = living_target
			blackboard[BB_VENDING_CURRENT_TARGET] = living_target
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/vendor_crush)
			return
		blackboard[BB_VENDING_TILT_COOLDOWN] = world.time + search_for_enemy_cooldown
