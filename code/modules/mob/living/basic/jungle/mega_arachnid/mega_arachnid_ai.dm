/datum/ai_controller/basic_controller/mega_arachnid
	behavior_tree_json = "code/modules/mob/living/basic/jungle/mega_arachnid/mega_arachnid.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_BASIC_MOB_FLEE_DISTANCE = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/target_source/oview_typed/surveillance_equipment
	typecache = list(/obj/machinery/camera = TRUE, /obj/machinery/light = TRUE)
