///Dog specific idle behavior.
/datum/idle_behavior/idle_dog/perform_idle_behavior(delta_time, datum/ai_controller/dog/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	// if we were just ordered to heel, chill out for a bit
	if(!COOLDOWN_FINISHED(controller, heel_cooldown))
		return

	// if we're just ditzing around carrying something, occasionally print a message so people know we have something
	if(controller.blackboard[BB_SIMPLE_CARRY_ITEM] && DT_PROB(5, delta_time))
		var/obj/item/carry_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
		living_pawn.visible_message(span_notice("[living_pawn] gently teethes on \the [carry_item] in [living_pawn.p_their()] mouth."), vision_distance=COMBAT_MESSAGE_RANGE)

	if(DT_PROB(5, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE))
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(DT_PROB(10, delta_time))
		living_pawn.manual_emote(pick("dances around.","chases [living_pawn.p_their()] tail!"))
		living_pawn.AddComponent(/datum/component/spinny)
