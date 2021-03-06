
//Unless specifically mentioned, these are usable on other mobs (but will ofc be themed as kitchenbot)

//CLEANING

/datum/ai_behavior/find_and_set/find_disposals
	locate_path = /obj/machinery/disposal/bin
	bb_key_to_set = BB_KITCHENBOT_CHOSEN_DISPOSALS

/datum/ai_behavior/find_and_set/find_disposals/react_to_success(datum/ai_controller/controller)
	controller.pawn.audible_message("<span class='hear'>[controller.pawn] makes a chiming sound! It must have located a disposal bin.</span>")
	playsound(controller.pawn, 'sound/machines/chime.ogg', 50, FALSE)

//kitchenbot because it uses some fail keys, could def be made normal
/datum/ai_behavior/find_and_set/find_refuse
	bb_key_to_set = BB_KITCHENBOT_TARGET_TO_DISPOSE

/datum/ai_behavior/find_and_set/find_refuse/search_tactic(datum/ai_controller/controller)
	var/obj/item/found_refuse
	for(var/obj/object in oview(7, controller.pawn))
		if(istype(object, /obj/item/trash/plate)) //dirty dishes
			found_refuse = object
		else if(istype(object, /obj/item/reagent_containers/food/condiment)) //bags of sugar flour etc, dump if empty
			var/obj/item/reagent_containers/food/condiment/condiment_container = object
			if(!condiment_container.reagents || !condiment_container.reagents.total_volume) //EMPTY! TRASH! GARBAGE! REFUUUUUSE
				found_refuse = condiment_container
	return found_refuse

/datum/ai_behavior/find_and_set/find_refuse/react_to_success(datum/ai_controller/controller)
	controller.blackboard[BB_KITCHENBOT_FAILED_LAST_TARGET_SEARCH] = FALSE //we found some trash, go start using the fast version

/datum/ai_behavior/find_and_set/find_refuse/fast
	action_cooldown = 0 SECONDS

/datum/ai_behavior/find_and_set/find_refuse/fast/react_to_failure(datum/ai_controller/controller)
	controller.blackboard[BB_KITCHENBOT_FAILED_LAST_TARGET_SEARCH] = TRUE //we didn't find trash, go back to the slow version

/datum/ai_behavior/forcemove_grab/grab_refuse
	bb_key_target = BB_KITCHENBOT_TARGET_TO_DISPOSE
	grab_verb = "scoops up"

/datum/ai_behavior/disposals_item/dump_refuse
	bb_key_target = BB_KITCHENBOT_TARGET_TO_DISPOSE
	bb_key_disposals = BB_KITCHENBOT_CHOSEN_DISPOSALS

/datum/ai_behavior/disposals_item/dump_refuse/react_to_success(datum/ai_controller/controller)
	controller.pawn.audible_message("<span class='hear'>[controller.pawn] makes a delighted ping!</span>")
	playsound(controller.pawn, 'sound/machines/ping.ogg', 50, FALSE)

//GRIDDLING

/datum/ai_behavior/find_and_set/find_griddle
	locate_path = /obj/machinery/griddle
	bb_key_to_set = BB_KITCHENBOT_CHOSEN_GRIDDLE

/datum/ai_behavior/find_and_set/find_griddle/react_to_success(datum/ai_controller/controller)
	controller.pawn.audible_message("<span class='hear'>[controller.pawn] makes a chiming sound! It must have located a griddle.</span>")
	playsound(controller.pawn, 'sound/machines/chime.ogg', 50, FALSE)

/datum/ai_behavior/find_and_set/find_stockpile
	locate_path = /obj/structure/holosign/kitchenbot_stockpile
	bb_key_to_set = BB_KITCHENBOT_CHOSEN_STOCKPILE

/datum/ai_behavior/find_and_set/find_stockpile/react_to_success(datum/ai_controller/controller)
	controller.pawn.audible_message("<span class='hear'>[controller.pawn] makes a chiming sound! It must have located a stockpile.</span>")
	playsound(controller.pawn, 'sound/machines/chime.ogg', 50, FALSE)

//kitchenbot exclusive
/datum/ai_behavior/find_and_set/find_stockpile_target
	bb_key_to_set = BB_KITCHENBOT_TARGET_IN_STOCKPILE

/datum/ai_behavior/find_and_set/find_stockpile_target/search_tactic(datum/ai_controller/controller)
	var/datum/ai_controller/kitchenbot/kitchenbot_controller = controller
	var/obj/stockpile = kitchenbot_controller.blackboard[BB_KITCHENBOT_CHOSEN_STOCKPILE]
	var/turf/stockpile_turf = get_turf(stockpile)
	if(!stockpile_turf)
		return
	var/list/should_griddle = list()
	for(var/obj/item/grillable in stockpile_turf.contents)
		var/list/banned_items = kitchenbot_controller.blackboard[BB_KITCHENBOT_ITEMS_BANNED]
		if(grillable in banned_items)
			continue
		var/datum/component/grillable/grill_comp = grillable.GetComponent(/datum/component/grillable) //change this for final merge
		if(!grill_comp || !grill_comp.positive_result)//bad, don't grill this
			banned_items += grillable
			continue
		should_griddle += grillable
	return pick_n_take(should_griddle)

/datum/ai_behavior/forcemove_grab/grab_griddlable
	bb_key_target = BB_KITCHENBOT_TARGET_IN_STOCKPILE

//kitchenbot exclusive - sorry sorry!
/datum/ai_behavior/put_on_grill
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/put_on_grill/perform(delta_time, datum/ai_controller/controller)
	. = ..()

	var/mob/living/simple_animal/bot/kitchenbot/kitchenbot = controller.pawn
	var/obj/machinery/griddle/griddle = controller.blackboard[BB_KITCHENBOT_CHOSEN_GRIDDLE]
	var/obj/item/grillable = controller.blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE]

	grillable.forceMove(griddle)
	griddle.AddToGrill(grillable, kitchenbot)
	if(!griddle.on)
		kitchenbot.visible_message("<span class='notice'>[kitchenbot] turns on [griddle].</span>")
		griddle.on = TRUE
		griddle.begin_processing()
		griddle.update_appearance()
		griddle.update_grill_audio()
	controller.blackboard[BB_KITCHENBOT_ITEMS_WATCHED] += grillable
	controller.RegisterSignal(grillable, COMSIG_MOVABLE_MOVED, /datum/ai_controller/kitchenbot.proc/DidNotGrill)
	controller.RegisterSignal(grillable, COMSIG_PARENT_QDELETING, /datum/ai_controller/kitchenbot.proc/DidNotGrill)
	controller.RegisterSignal(grillable, COMSIG_GRILL_COMPLETED, /datum/ai_controller/kitchenbot.proc/GrillCompleted)
	controller.blackboard[BB_KITCHENBOT_TARGET_IN_STOCKPILE] = null
	finish_action(controller, TRUE)

//kitchenbot exclusive - sorry sorry!
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

//SERVING CUSTOMERS

/datum/ai_behavior/listen_for_customers/kitchenbot
	bb_key_venue = BB_KITCHENBOT_VENUE
	bb_key_customers_list = BB_KITCHENBOT_CUSTOMERS_NOTED
	bb_key_orders_list = BB_KITCHENBOT_ORDERS_WANTED

/datum/ai_behavior/find_and_set/find_customer_order/kitchenbot
	bb_key_orders_list = BB_KITCHENBOT_ORDERS_WANTED
	bb_key_to_set = BB_KITCHENBOT_DISH_TO_SERVE

/datum/ai_behavior/forcemove_grab/grab_customer_order
	bb_key_target = BB_KITCHENBOT_DISH_TO_SERVE
	grab_verb = "collects"

/datum/ai_behavior/dropoff_item/drop_order_off
	bb_key_item = BB_KITCHENBOT_DISH_TO_SERVE

/datum/ai_behavior/dropoff_item/drop_order_off/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	controller.blackboard[BB_KITCHENBOT_DISH_TO_SERVE] = null
