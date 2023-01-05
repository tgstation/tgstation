/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	//Hiding location is priority
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]
	if (!targetting_datum)
		return
	set_movement_target(controller, target)

/datum/ai_behavior/basic_melee_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	//targetting datum will kill the action if not real anymore
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum.can_attack(basic_mob, target))
		finish_action(controller, FALSE, target_key)
		return

	var/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!

	controller.blackboard[hiding_location_key] = hiding_target

	if(hiding_target) //Slap it!
		basic_mob.melee_attack(hiding_target)
	else
		basic_mob.melee_attack(target)


/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.blackboard -= target_key

/datum/ai_behavior/basic_ranged_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3
	/// How many shots to fire
	var/shots = 1
	/// The interval between individual shots in a burst
	var/burst_interval = 0.2 SECONDS

/datum/ai_behavior/basic_ranged_attack/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/basic_ranged_attack/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/basic_mob = controller.pawn
	//targetting datum will kill the action if not real anymore
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/datum/targetting_datum/targetting_datum = controller.blackboard[targetting_datum_key]

	if(!targetting_datum.can_attack(basic_mob, target))
		finish_action(controller, FALSE, target_key)
		return

	var/atom/hiding_target = targetting_datum.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!
	var/atom/final_target = hiding_target ? hiding_target : target

	if(!can_see(basic_mob, final_target, required_distance))
		finish_action(controller, FALSE, target_key)
		return

	controller.blackboard[hiding_location_key] = WEAKREF(hiding_target)

	if(shots>1)
		var/atom/burst_target = final_target
		var/datum/callback/callback = CALLBACK(basic_mob, TYPE_PROC_REF(/mob/living/basic,RangedAttack), burst_target)
		for(var/i in 2 to shots)
			addtimer(callback, (i - 1) * burst_interval)
		callback.Invoke()
	else
		basic_mob.RangedAttack(final_target)

/datum/ai_behavior/basic_ranged_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.blackboard -= target_key
