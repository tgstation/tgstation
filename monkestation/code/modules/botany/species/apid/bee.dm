/datum/ai_controller/basic_controller/apid_bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_valid_home,
		/datum/ai_planning_subtree/enter_exit_home,
		/datum/ai_planning_subtree/find_and_hunt_target/pollinate,
	)

/mob/living/basic/bee/apid_summoned
	ai_controller = /datum/ai_controller/basic_controller/apid_bee
	var/specalized_stat = "potency"

/mob/living/basic/bee/apid_summoned/pollinate(atom/movable/hydro)
	var/datum/component/plant_growing/growing = GetComponent(/datum/component/plant_growing)
	if(growing)
		for(var/item as anything in growing.managed_seeds)
			var/obj/item/seeds/seed = growing.managed_seeds[item]
			if(!seed)
				continue
			switch(specalized_stat)
				if("potency")
					seed.adjust_potency(rand(1,5))
				if("yield")
					seed.adjust_yield(rand(1,5))
				if("endurance")
					seed.adjust_endurance(rand(1,5))
				if("lifespan")
					seed.adjust_lifespan(rand(1,5))
				if("maturation")
					seed.adjust_maturation(rand(1, 5))
				if("production")
					seed.adjust_production(rand(1, 5))

	SEND_SIGNAL(hydro, COMSIG_TRY_POLLINATE)

	if(beehome)
		beehome.bee_resources = min(beehome.bee_resources + health, 100)
		if(istype(beehome, /obj/structure/beebox/hive))
			var/obj/structure/beebox/hive/hive = beehome
			hive.stored_honey += rand(1, 5)

/mob/living/basic/bee/apid_summoned/handle_habitation(obj/structure/beebox/hive/hive)
	. = ..()
	if(!istype(hive))
		return
	specalized_stat = hive.current_stat
