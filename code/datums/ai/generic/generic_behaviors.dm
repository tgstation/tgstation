
/datum/ai_behavior/resist/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.execute_resist()
	finish_action(controller, TRUE)

/datum/ai_behavior/battle_screech
	///List of possible screeches the behavior has
	var/list/screeches

/datum/ai_behavior/battle_screech/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick(screeches))
	finish_action(controller, TRUE)

///Moves to target then finishes
/datum/ai_behavior/move_to_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/move_to_target/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE)


/datum/ai_behavior/break_spine
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 0.7 SECONDS
	var/give_up_distance = 10

/datum/ai_behavior/break_spine/setup(datum/ai_controller/controller, target_key)
	. = ..()
	controller.current_movement_target = controller.blackboard[target_key]

/datum/ai_behavior/break_spine/perform(delta_time, datum/ai_controller/controller, target_key)
	var/mob/living/batman = controller.blackboard[target_key]
	var/mob/living/big_guy = controller.pawn //he was molded by the darkness

	if(batman.stat)
		finish_action(controller, TRUE, target_key)

	if(get_dist(batman, big_guy) >= give_up_distance)
		finish_action(controller, FALSE, target_key)

	big_guy.start_pulling(batman)
	big_guy.setDir(get_dir(big_guy, batman))

	batman.visible_message(span_warning("[batman] gets a slightly too tight hug from [big_guy]!"), span_userdanger("You feel your body break as [big_guy] embraces you!"))

	if(iscarbon(batman))
		var/mob/living/carbon/carbon_batman = batman
		for(var/obj/item/bodypart/bodypart_to_break in carbon_batman.bodyparts)
			if(bodypart_to_break.body_zone == BODY_ZONE_HEAD)
				continue
			bodypart_to_break.receive_damage(brute = 15, wound_bonus = 35)
	else
		batman.adjustBruteLoss(150)

	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/break_spine/finish_action(datum/ai_controller/controller, succeeded, target_key)
	if(succeeded)
		controller.blackboard -= target_key
	return ..()

/// Use in hand the currently held item
/datum/ai_behavior/use_in_hand
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM


/datum/ai_behavior/use_in_hand/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held = pawn.get_item_by_slot(pawn.get_active_hand())
	if(!held)
		finish_action(controller, FALSE)
		return
	pawn.activate_hand(pawn.get_active_hand())
	finish_action(controller, TRUE)

/// Use the currently held item, or unarmed, on a weakref to an object in the world
/datum/ai_behavior/use_on_object
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/use_on_object/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/target_ref = controller.blackboard[target_key]
	var/target = target_ref?.resolve()
	if(!target)
		return FALSE
	controller.current_movement_target = target

/datum/ai_behavior/use_on_object/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_item_by_slot(pawn.get_active_hand())
	var/datum/weakref/target_ref = controller.blackboard[target_key]
	var/atom/target = target_ref?.resolve()

	if(!target || !pawn.CanReach(target))
		finish_action(controller, FALSE)
		return

	pawn.set_combat_mode(FALSE)
	if(held_item)
		held_item.melee_attack_chain(pawn, target)
	else
		pawn.UnarmedAttack(target, TRUE)

	finish_action(controller, TRUE)

/datum/ai_behavior/give
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT


/datum/ai_behavior/give/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/target_ref = controller.blackboard[target_key]
	controller.current_movement_target = target_ref?.resolve()

/datum/ai_behavior/give/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_active_held_item()
	var/datum/weakref/target_ref = controller.blackboard[target_key]
	var/atom/target = target_ref?.resolve()

	if(!held_item) //if held_item is null, we pretend that action was succesful
		finish_action(controller, TRUE)
		return

	if(!target || !pawn.CanReach(target) || !isliving(target))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = target
	controller.PauseAi(1.5 SECONDS)
	living_target.visible_message(
		span_info("[pawn] starts trying to give [held_item] to [living_target]!"),
		span_warning("[pawn] tries to give you [held_item]!")
	)
	if(!do_mob(pawn, living_target, 1 SECONDS))
		return
	if(QDELETED(held_item) || QDELETED(living_target))
		finish_action(controller, FALSE)
		return
	var/pocket_choice = prob(50) ? ITEM_SLOT_RPOCKET : ITEM_SLOT_LPOCKET
	if(prob(50))
		living_target.put_in_hands(held_item)
	else
		living_target.equip_to_slot_if_possible(held_item, pocket_choice)

	finish_action(controller, TRUE)

/datum/ai_behavior/consume
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 2 SECONDS

/datum/ai_behavior/consume/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/target_ref = controller.blackboard[target_key]
	controller.current_movement_target = target_ref?.resolve()

/datum/ai_behavior/consume/perform(delta_time, datum/ai_controller/controller, target_key, hunger_timer_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/datum/weakref/target_ref = controller.blackboard[target_key]
	var/obj/item/target = target_ref.resolve()

	if(!(target in living_pawn.held_items))
		if(!living_pawn.put_in_hand_check(target))
			finish_action(controller, FALSE, target, hunger_timer_key)
			return

		living_pawn.put_in_hands(target)

	target.melee_attack_chain(living_pawn, living_pawn)

	if(QDELETED(target) || prob(10)) // Even if we don't finish it all we can randomly decide to be done
		finish_action(controller, TRUE, null, hunger_timer_key)

/datum/ai_behavior/consume/finish_action(datum/ai_controller/controller, succeeded, target_key, hunger_timer_key)
	. = ..()
	if(succeeded)
		controller.blackboard[hunger_timer_key] = world.time + rand(12 SECONDS, 60 SECONDS)

/**
 * Drops items in hands, very important for future behaviors that require the pawn to grab stuff
 */
/datum/ai_behavior/drop_item

/datum/ai_behavior/drop_item/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/best_held = GetBestWeapon(controller, null, living_pawn.held_items)
	for(var/obj/item/held as anything in living_pawn.held_items)
		if(!held || held == best_held)
			continue
		living_pawn.dropItemToGround(held)

/// This behavior involves attacking a target.
/datum/ai_behavior/attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/attack/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/datum/weakref/attack_ref = controller.blackboard[BB_ATTACK_TARGET]
	var/atom/movable/attack_target = attack_ref?.resolve()
	if(!attack_target || !can_see(living_pawn, attack_target, length=controller.blackboard[BB_VISION_RANGE]))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = attack_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return

	controller.current_movement_target = living_target
	attack(controller, living_target)

/datum/ai_behavior/attack/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.blackboard[BB_ATTACK_TARGET] = null

/// A proc representing when the mob is pushed to actually attack the target. Again, subtypes can be used to represent different attacks from different animals, or it can be some other generic behavior
/datum/ai_behavior/attack/proc/attack(datum/ai_controller/controller, mob/living/living_target)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.ClickOn(living_target, list())

/// This behavior involves attacking a target.
/datum/ai_behavior/follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/follow/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/datum/weakref/follow_ref = controller.blackboard[BB_FOLLOW_TARGET]
	var/atom/movable/follow_target = follow_ref?.resolve()
	if(!follow_target || get_dist(living_pawn, follow_target) > controller.blackboard[BB_VISION_RANGE])
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = follow_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return

	controller.current_movement_target = living_target

/datum/ai_behavior/follow/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.blackboard[BB_FOLLOW_TARGET] = null



/datum/ai_behavior/perform_emote

/datum/ai_behavior/perform_emote/perform(delta_time, datum/ai_controller/controller, emote)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.manual_emote(emote)
	finish_action(controller, TRUE)

/datum/ai_behavior/perform_speech

/datum/ai_behavior/perform_speech/perform(delta_time, datum/ai_controller/controller, speech)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.say(speech, forced = "AI Controller")
	finish_action(controller, TRUE)

//song behaviors

/datum/ai_behavior/setup_instrument

/datum/ai_behavior/setup_instrument/perform(delta_time, datum/ai_controller/controller, song_instrument_key, song_lines_key)
	. = ..()

	var/datum/weakref/instrument_ref = controller.blackboard[song_instrument_key]
	var/obj/item/instrument/song_instrument = instrument_ref.resolve()
	var/datum/song/song = song_instrument.song
	var/song_lines = controller.blackboard[song_lines_key]

	//just in case- it won't do anything if the instrument isn't playing
	song.stop_playing()
	song.ParseSong(song_lines)
	song.repeat = 10
	song.volume = song.max_volume - 10
	finish_action(controller, TRUE)

/datum/ai_behavior/play_instrument

/datum/ai_behavior/play_instrument/perform(delta_time, datum/ai_controller/controller, song_instrument_key)
	. = ..()

	var/datum/weakref/instrument_ref = controller.blackboard[song_instrument_key]
	var/obj/item/instrument/song_instrument = instrument_ref.resolve()
	var/datum/song/song = song_instrument.song

	song.start_playing(controller.pawn)
	finish_action(controller, TRUE)

/datum/ai_behavior/find_nearby

/datum/ai_behavior/find_nearby/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()

	var/list/possible_targets = list()
	for(var/atom/thing in view(2, controller.pawn))
		if(!thing.mouse_opacity)
			continue
		if(thing.IsObscured())
			continue
		possible_targets += thing
	if(!possible_targets.len)
		finish_action(controller, FALSE)
	controller.blackboard[target_key] = WEAKREF(pick(possible_targets))
	finish_action(controller, TRUE)
