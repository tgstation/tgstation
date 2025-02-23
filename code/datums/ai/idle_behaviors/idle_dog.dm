///Dog specific idle behavior.
/datum/idle_behavior/idle_dog/perform_idle_behavior(seconds_per_tick, datum/ai_controller/basic_controller/dog/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	var/obj/item/carry_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	// if we're just ditzing around carrying something, occasionally print a message so people know we have something
	if(carry_item && SPT_PROB(5, seconds_per_tick))
		living_pawn.visible_message(span_notice("[living_pawn] gently teethes on \the [carry_item] in [living_pawn.p_their()] mouth."), vision_distance=COMBAT_MESSAGE_RANGE)

	// Custom movement rate, for old corgis, etc.
	var/move_chance = controller.blackboard[BB_DOG_IS_SLOW] ? 2.5 : 5

	if(SPT_PROB(move_chance, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE))
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(SPT_PROB(2, seconds_per_tick))
		living_pawn.manual_emote(pick("dances around.", "chases [living_pawn.p_their()] tail!"))
		living_pawn.AddComponent(/datum/component/spinny)
