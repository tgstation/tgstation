/datum/ai_behavior/battle_screech/dog
	screeches = list("barks","howls")

/// Fetching makes the pawn chase after whatever it's targeting and pick it up when it's in range, with the dog_equip behavior
/datum/ai_behavior/fetch
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/fetch/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/fetch_thing = controller.blackboard[BB_FETCH_TARGET]

	if(fetch_thing.anchored || !isturf(fetch_thing.loc) || IS_EDIBLE(fetch_thing)) //either we can't pick it up, or we'd rather eat it, so stop trying.
		finish_action(controller, FALSE)
		return

	if(in_range(living_pawn, fetch_thing))
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)

/datum/ai_behavior/fetch/finish_action(datum/ai_controller/controller, success)
	. = ..()

	if(!success) //Don't try again on this item if we failed
		var/obj/item/target = controller.blackboard[BB_FETCH_TARGET]
		if(target)
			controller.blackboard[BB_FETCH_IGNORE_LIST][target] = TRUE
		controller.blackboard[BB_FETCH_TARGET] = null
		controller.blackboard[BB_FETCH_DELIVER_TO] = null


/// This is simply a behaviour to pick up a fetch target
/datum/ai_behavior/simple_equip/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/obj/item/fetch_target = controller.blackboard[BB_FETCH_TARGET]
	if(!isturf(fetch_target?.loc)) // someone picked it up or something happened to it
		finish_action(controller, FALSE)
		return

	if(in_range(controller.pawn, fetch_target))
		pickup_item(controller, fetch_target)
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/simple_equip/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_FETCH_TARGET] = null

/datum/ai_behavior/simple_equip/proc/pickup_item(datum/ai_controller/controller, obj/item/target)
	var/atom/pawn = controller.pawn
	drop_item(controller)
	pawn.visible_message("<span class='notice'>[pawn] picks up [target] in [pawn.p_their()] mouth.</span>")
	target.forceMove(pawn)
	controller.blackboard[BB_SIMPLE_CARRY_ITEM] = target
	return TRUE

/datum/ai_behavior/simple_equip/proc/drop_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	if(!carried_item)
		return

	var/atom/pawn = controller.pawn
	pawn.visible_message("<span class='notice'>[pawn] drops [carried_item].</span>")
	carried_item.forceMove(get_turf(pawn))
	controller.blackboard[BB_SIMPLE_CARRY_ITEM] = null
	return TRUE



/// This behavior involves dropping off a carried item to a specified person (or place)
/datum/ai_behavior/deliver_item
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/deliver_item/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/return_target = controller.blackboard[BB_FETCH_DELIVER_TO]
	if(!return_target)
		finish_action(controller, FALSE)
	if(in_range(controller.pawn, return_target))
		deliver_item(controller)
		finish_action(controller, TRUE)

/datum/ai_behavior/deliver_item/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.blackboard[BB_FETCH_DELIVER_TO] = null

/// Actually drop the fetched item to the target
/datum/ai_behavior/deliver_item/proc/deliver_item(datum/ai_controller/controller)
	var/obj/item/carried_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	var/atom/movable/return_target = controller.blackboard[BB_FETCH_DELIVER_TO]
	if(!carried_item || !return_target)
		finish_action(controller, FALSE)
		return

	if(ismob(return_target))
		controller.pawn.visible_message("<span class='notice'>[controller.pawn] delivers [carried_item] at [return_target]'s feet.</span>")
	else // not sure how to best phrase this
		controller.pawn.visible_message("<span class='notice'>[controller.pawn] delivers [carried_item] to [return_target].</span>")

	carried_item.forceMove(get_turf(return_target))
	controller.blackboard[BB_SIMPLE_CARRY_ITEM] = null
	return TRUE

/// This behavior involves either eating a snack we can reach, or begging someone holding a snack
/datum/ai_behavior/eat_snack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/eat_snack/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/obj/item/snack = controller.current_movement_target
	if(!istype(snack) || !IS_EDIBLE(snack) || !(isturf(snack.loc) || ishuman(snack.loc)))
		finish_action(controller, FALSE)

	var/mob/living/living_pawn = controller.pawn
	if(!in_range(living_pawn, snack))
		return

	if(isturf(snack.loc))
		snack.attack_animal(living_pawn) // snack attack!
	else if(iscarbon(snack.loc) && DT_PROB(10, delta_time))
		living_pawn.manual_emote("stares at [snack.loc]'s [snack.name] with a sad puppy-face.")

	if(QDELETED(snack)) // we ate it!
		finish_action(controller, TRUE)


/// This behavior involves either eating a snack we can reach, or begging someone holding a snack
/datum/ai_behavior/play_dead
	behavior_flags = NONE

/datum/ai_behavior/play_dead/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn))
		return

	if(!controller.blackboard[BB_DOG_PLAYING_DEAD])
		controller.blackboard[BB_DOG_PLAYING_DEAD] = TRUE
		simple_pawn.emote("deathgasp", intentional=FALSE)
		simple_pawn.icon_state = simple_pawn.icon_dead
		if(simple_pawn.flip_on_death)
			simple_pawn.transform = simple_pawn.transform.Turn(180)
		simple_pawn.density = FALSE

	if(DT_PROB(10, delta_time))
		finish_action(controller, TRUE)

/datum/ai_behavior/play_dead/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn) || simple_pawn.stat) // imagine actually dying while playing dead. hell, imagine being the kid waiting for your pup to get back up :(
		return
	controller.blackboard[BB_DOG_PLAYING_DEAD] = FALSE
	simple_pawn.visible_message("<span class='notice'>[simple_pawn] springs to [simple_pawn.p_their()] feet, panting excitedly!</span>")
	simple_pawn.icon_state = simple_pawn.icon_living
	if(simple_pawn.flip_on_death)
		simple_pawn.transform = simple_pawn.transform.Turn(180)
	simple_pawn.density = initial(simple_pawn.density)

/// This behavior involves either eating a snack we can reach, or begging someone holding a snack
/datum/ai_behavior/harass
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3

/datum/ai_behavior/harass/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return

	var/atom/movable/harass_target = controller.blackboard[BB_DOG_HARASS_TARGET]
	if(!harass_target || !can_see(living_pawn, harass_target, length=AI_DOG_VISION_RANGE))
		finish_action(controller, FALSE)
		return

	if(controller.blackboard[BB_DOG_FRIENDS][harass_target])
		living_pawn.visible_message("<span class='danger'>[living_pawn] looks sideways at [harass_target] for a moment, then shakes [living_pawn.p_their()] head and ceases aggression.</span>")
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = harass_target
	if(istype(living_target) && (living_target.stat || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)))
		finish_action(controller, TRUE)
		return

	// subtypes of this behavior can change behavior for how eager/averse the pawn is to attack the target as opposed to falling back/making noise/getting help
	if(in_range(living_pawn, living_target))
		attack(controller, living_target)
	else if(DT_PROB(50, delta_time))
		living_pawn.manual_emote("[pick("barks", "growls", "stares")] menacingly at [harass_target]!")

/datum/ai_behavior/harass/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.blackboard[BB_DOG_HARASS_TARGET] = null

/// A proc representing when the mob is pushed to actually attack the target. Again, subtypes can be used to represent different attacks from different animals, or it can be some other generic behavior
/datum/ai_behavior/harass/proc/attack(datum/ai_controller/controller, mob/living/living_target)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.do_attack_animation(living_target, ATTACK_EFFECT_BITE)
	living_target.visible_message("<span class='danger'>[living_pawn] bites at [living_target]!</span>", "<span class='userdanger'>[living_pawn] bites at you!</span>", vision_distance = COMBAT_MESSAGE_RANGE)
	if(istype(living_target))
		living_target.take_bodypart_damage(rand(5, 10))
		log_combat(living_pawn, living_target, "bit (AI)")
