/datum/ai_controller/basic_controller/turtle
	blackboard = list(
		BB_HAPPY_EMOTIONS = list(
			"wiggles its tree in excitement!",
			"raises its head up high!",
			"wags its tail enthusiastically!",
		),
		BB_MODERATE_EMOTIONS = list(
			"keeps its head level, eyes half-closed.",
			"basks in the light peacefully.",
		),
		BB_SAD_EMOTIONS = list(
			"looks towards the floor in dissapointment...",
			"the leaves on its tree droop...",
		),
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/express_happiness,
		/datum/ai_planning_subtree/use_mob_ability/turtle_tree,
		/datum/ai_planning_subtree/find_and_hunt_target/headbutt_people, //playfully headbutt people's legs
		/datum/ai_planning_subtree/find_and_hunt_target/sniff_flora, //mmm the aroma
	)

/datum/ai_planning_subtree/use_mob_ability/turtle_tree
	ability_key = BB_TURTLE_TREE_ABILITY

/datum/ai_planning_subtree/use_mob_ability/turtle_tree/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/happiness_count = controller.blackboard[BB_BASIC_HAPPINESS] * 100
	if(happiness_count > 75)
		return ..()
	if(!SPT_PROB(happiness_count / 50, seconds_per_tick))
		return
	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/sniff_flora
	target_key = BB_TURTLE_FLORA_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/sniff_flora
	hunting_behavior = /datum/ai_behavior/hunt_target/sniff_flora
	hunt_targets = list(
		/obj/machinery/hydroponics,
		/obj/item/kirbyplants,
	)
	hunt_range = 5
	hunt_chance = 45

/datum/ai_behavior/find_hunt_target/sniff_flora
	action_cooldown = 1 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_hunt_target/sniff_flora/valid_dinner(mob/living/source, obj/machinery/hydroponics/dinner, radius, datum/ai_controller/controller, seconds_per_tick)
	if(!istype(dinner))
		return TRUE
	if(isnull(dinner.myseed))
		return FALSE
	if(dinner.weedlevel > 5 || dinner.pestlevel > 5) //too smelly
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/hunt_target/sniff_flora
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/sniff_flora/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("Enjoys the sweet scent eminating from [hunted::name]!")

/datum/ai_planning_subtree/find_and_hunt_target/headbutt_people
	target_key = BB_TURTLE_HEADBUTT_VICTIM
	finding_behavior = /datum/ai_behavior/find_hunt_target/human_to_headbutt
	hunting_behavior = /datum/ai_behavior/hunt_target/headbutt_leg
	hunt_targets = list(/mob/living/carbon/human)
	hunt_range = 4
	hunt_chance = 45

/datum/ai_behavior/find_hunt_target/human_to_headbutt
	action_cooldown = 2 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_hunt_target/human_to_headbutt/valid_dinner(mob/living/source, mob/living/carbon/human/dinner, radius, datum/ai_controller/controller, seconds_per_tick)
	if(dinner.stat != CONSCIOUS)
		return FALSE
	if(isnull(dinner.get_bodypart(BODY_ZONE_R_LEG)) && isnull(dinner.get_bodypart(BODY_ZONE_L_LEG))) //no legs to headbutt!
		return FALSE
	return can_see(source, dinner, radius)

/datum/ai_behavior/hunt_target/headbutt_leg
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/headbutt_leg/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("playfully headbutts [hunted]'s legs!")

