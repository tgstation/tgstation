

//CLEANING

/datum/ai_behavior/find_disposals
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_disposals/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn

	var/obj/machinery/disposal/found_disposals = locate(/obj/machinery/disposal/bin) in oview(7, kitchenbot)

	if(found_disposals)
		kitchenbot.audible_message("<span class='hear'>[kitchenbot] makes a chiming sound! It must have located a disposal bin.</span>")
		playsound(kitchenbot, 'sound/machines/chime.ogg', 50, FALSE)
		controller.blackboard[BB_KITCHENBOT_CHOSEN_DISPOSALS] = found_disposals
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/find_refuse
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_refuse/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/item/found_refuse

	for(var/obj/object in oview(7, kitchenbot))
		if(istype(object, /obj/item/trash/plate)) //dirty dishes
			found_refuse = object
		else if(istype(object, /obj/item/reagent_containers/food/condiment)) //bags of sugar flour etc, dump if empty
			var/obj/item/reagent_containers/food/condiment/condiment_container = object
			if(!condiment_container.reagents || !condiment_container.reagents.total_volume) //EMPTY! TRASH! GARBAGE! REFUUUUUSE
				found_refuse = condiment_container
	if(found_refuse)
		controller.blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE] = found_refuse
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/grab_refuse
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1 //it looks better because of pickup animations

/datum/ai_behavior/grab_refuse/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/item/target_refuse = controller.blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]

	target_refuse.do_pickup_animation(kitchenbot)
	kitchenbot.visible_message("<span class='notice'>[kitchenbot] scoops up [target_refuse]!</span>")
	target_refuse.forceMove(kitchenbot)
	finish_action(controller, TRUE)

/datum/ai_behavior/dump_refuse
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/dump_refuse/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/machinery/disposal/target_disposals = controller.blackboard[BB_KITCHENBOT_CHOSEN_DISPOSALS]
	var/obj/item/found_refuse = controller.blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE]

	target_disposals.place_item_in_disposal(found_refuse, kitchenbot)
	controller.blackboard[BB_KITCHENBOT_TARGET_TO_DISPOSE] = null //cave johnson we're done here
	kitchenbot.audible_message("<span class='hear'>[kitchenbot] makes a delighted ping!</span>")
	playsound(kitchenbot, 'sound/machines/ping.ogg', 50, FALSE)
	finish_action(controller, TRUE)

//GRIDDLING

/datum/ai_behavior/find_griddle
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_griddle/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn

	var/obj/machinery/griddle/found_griddle = locate(/obj/machinery/griddle) in oview(7, kitchenbot)

	if(found_griddle)
		kitchenbot.audible_message("<span class='hear'>[kitchenbot] makes a chiming sound! It must have located a griddle.</span>")
		playsound(kitchenbot, 'sound/machines/chime.ogg', 50, FALSE)
		controller.blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE] = found_griddle
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/find_stockpile
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_stockpile/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn

	var/obj/structure/holosign/kitchenbot_stockpile/stockpile = locate(/obj/structure/holosign/kitchenbot_stockpile) in oview(7, kitchenbot)

	if(stockpile)
		kitchenbot.audible_message("<span class='hear'>[kitchenbot] makes a chiming sound! It must have located a stockpile.</span>")
		playsound(kitchenbot, 'sound/machines/chime.ogg', 50, FALSE)
		controller.blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE] = stockpile
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/grab_griddlable
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1 //it looks better because of pickup animations

/datum/ai_behavior/grab_griddlable/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/item/need_to_grill = controller.current_movement_target

	need_to_grill.do_pickup_animation(kitchenbot)
	kitchenbot.visible_message("<span class='notice'>[kitchenbot] grabs [need_to_grill]!</span>")
	need_to_grill.forceMove(kitchenbot)
	controller.blackboard[BB_KITCHENBOT_TARGET_TO_GRILL] = need_to_grill
	finish_action(controller, TRUE)

/datum/ai_behavior/put_on_grill
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/put_on_grill/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/machinery/griddle/griddle = controller.blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
	var/obj/item/grillable = controller.blackboard[BB_KITCHENBOT_TARGET_TO_GRILL]

	grillable.forceMove(griddle)
	griddle.AddToGrill(grillable, kitchenbot)
	if(!griddle.on)
		kitchenbot.visible_message("<span class='notice'>[kitchenbot] turns on [griddle].</span>")
		griddle.on = TRUE
		griddle.begin_processing()
		griddle.update_appearance()
		griddle.update_grill_audio()
	controller.blackboard[BB_KITCHENBOT_ITEMS_WATCHED] += grillable
	controller.RegisterSignal(grillable, COMSIG_GRILL_COMPLETED, /datum/ai_controller/kitchenbot.proc/GrillCompleted)
	controller.blackboard[BB_KITCHENBOT_TARGET_TO_GRILL] = null
	finish_action(controller, TRUE)


/datum/ai_behavior/take_off_grill
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/take_off_grill/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/machinery/griddle/griddle = controller.blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
	var/list/take_off_grill = controller.blackboard[BB_KITCHENBOT_TAKE_OFF_GRILL]
	var/obj/item/finished_food = take_off_grill[1]

	finished_food.forceMove(get_step(griddle.loc, pick(GLOB.alldirs)))
	griddle.ItemRemovedFromGrill(finished_food)
	take_off_grill.Remove(take_off_grill)
	kitchenbot.audible_message("<span class='hear'>[kitchenbot] makes a delighted ping!</span>")
	playsound(kitchenbot, 'sound/machines/ping.ogg', 50, FALSE)
	finish_action(controller, TRUE)
