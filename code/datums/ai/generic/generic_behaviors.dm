
/datum/ai_behavior/resist/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, TRUE)
	living_pawn.execute_resist()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/battle_screech
	///List of possible screeches the behavior has
	var/list/screeches

/datum/ai_behavior/battle_screech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(screeches))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

///Moves to target then finishes
/datum/ai_behavior/move_to_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_behavior/break_spine
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 0.7 SECONDS
	var/give_up_distance = 10

/datum/ai_behavior/break_spine/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/break_spine/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/batman = controller.blackboard[target_key]
	var/mob/living/big_guy = controller.pawn //he was molded by the darkness

	if(QDELETED(batman) || get_dist(batman, big_guy) >= give_up_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(batman.stat != CONSCIOUS)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	big_guy.start_pulling(batman)
	big_guy.face_atom(batman)

	batman.visible_message(span_warning("[batman] gets a slightly too tight hug from [big_guy]!"), span_userdanger("You feel your body break as [big_guy] embraces you!"))

	if(iscarbon(batman))
		var/mob/living/carbon/carbon_batman = batman
		for(var/obj/item/bodypart/bodypart_to_break in carbon_batman.bodyparts)
			if(bodypart_to_break.body_zone == BODY_ZONE_HEAD)
				continue
			bodypart_to_break.receive_damage(brute = 15, wound_bonus = 35)
	else
		batman.adjustBruteLoss(150)

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/break_spine/finish_action(datum/ai_controller/controller, succeeded, target_key)
	if(succeeded)
		var/mob/living/bane = controller.pawn
		if(QDELETED(bane)) // pawn can be null at this point
			return ..()
		bane.stop_pulling()
		controller.clear_blackboard_key(target_key)
	return ..()

/// Use in hand the currently held item
/datum/ai_behavior/use_in_hand
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM


/datum/ai_behavior/use_in_hand/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/obj/item/held = pawn.get_active_held_item()
	if(!held)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	pawn.activate_hand()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Use the currently held item, or unarmed, on a weakref to an object in the world
/datum/ai_behavior/use_on_object
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/use_on_object/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/use_on_object/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_item_by_slot(pawn.get_active_hand())
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	pawn.set_combat_mode(FALSE)
	if(held_item)
		held_item.melee_attack_chain(pawn, target)
	else
		pawn.UnarmedAttack(target, TRUE)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/give
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH


/datum/ai_behavior/give/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/give/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_active_held_item()
	var/atom/target = controller.blackboard[target_key]

	if(!held_item) //if held_item is null, we pretend that action was succesful
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(!target || !isliving(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_target = target
	var/perform_flags = try_to_give_item(controller, living_target, held_item)
	if(perform_flags & AI_BEHAVIOR_FAILED)
		return perform_flags
	controller.PauseAi(1.5 SECONDS)
	living_target.visible_message(
		span_info("[pawn] starts trying to give [held_item] to [living_target]!"),
		span_warning("[pawn] tries to give you [held_item]!")
	)
	if(!do_after(pawn, 1 SECONDS, living_target))
		return AI_BEHAVIOR_DELAY | perform_flags

	perform_flags |= try_to_give_item(controller, living_target, held_item, actually_give = TRUE)
	return AI_BEHAVIOR_DELAY | perform_flags

/datum/ai_behavior/give/proc/try_to_give_item(datum/ai_controller/controller, mob/living/target, obj/item/held_item, actually_give)
	if(QDELETED(held_item) || QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/has_left_pocket = target.can_equip(held_item, ITEM_SLOT_LPOCKET)
	var/has_right_pocket = target.can_equip(held_item, ITEM_SLOT_RPOCKET)
	var/has_valid_hand

	for(var/hand_index in target.get_empty_held_indexes())
		if(target.can_put_in_hand(held_item, hand_index))
			has_valid_hand = TRUE
			break

	if(!has_left_pocket && !has_right_pocket && !has_valid_hand)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!actually_give)
		return AI_BEHAVIOR_DELAY

	if(!has_valid_hand || prob(50))
		target.equip_to_slot_if_possible(held_item, (!has_left_pocket ? ITEM_SLOT_RPOCKET : (prob(50) ? ITEM_SLOT_LPOCKET : ITEM_SLOT_RPOCKET)))
	else
		target.put_in_hands(held_item)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/datum/ai_behavior/consume
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	action_cooldown = 2 SECONDS

/datum/ai_behavior/consume/setup(datum/ai_controller/controller, target_key)
	. = ..()
	set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/consume/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hunger_timer_key)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY

	if(!(target in living_pawn.held_items))
		if(!living_pawn.get_empty_held_indexes() || !living_pawn.put_in_hands(target))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	target.melee_attack_chain(living_pawn, living_pawn)

	if(QDELETED(target) || prob(10)) // Even if we don't finish it all we can randomly decide to be done
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/consume/finish_action(datum/ai_controller/controller, succeeded, target_key, hunger_timer_key)
	. = ..()
	if(succeeded)
		controller.set_blackboard_key(hunger_timer_key, world.time + rand(12 SECONDS, 60 SECONDS))

/**
 * Drops items in hands, very important for future behaviors that require the pawn to grab stuff
 */
/datum/ai_behavior/drop_item

/datum/ai_behavior/drop_item/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/best_held = GetBestWeapon(controller, null, living_pawn.held_items)
	for(var/obj/item/held as anything in living_pawn.held_items)
		if(!held || held == best_held)
			continue
		living_pawn.dropItemToGround(held)
	return AI_BEHAVIOR_DELAY

/// This behavior involves attacking a target.
/datum/ai_behavior/attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/attack/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return AI_BEHAVIOR_DELAY

	var/atom/movable/attack_target = controller.blackboard[BB_ATTACK_TARGET]
	if(!attack_target || !can_see(living_pawn, attack_target, length = controller.blackboard[BB_VISION_RANGE]))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_target = attack_target
	if(istype(living_target) && (living_target.stat == DEAD))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	set_movement_target(controller, living_target)
	attack(controller, living_target)
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/attack/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_ATTACK_TARGET)

/// A proc representing when the mob is pushed to actually attack the target. Again, subtypes can be used to represent different attacks from different animals, or it can be some other generic behavior
/datum/ai_behavior/attack/proc/attack(datum/ai_controller/controller, mob/living/living_target)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.ClickOn(living_target, list())

/// This behavior involves attacking a target.
/datum/ai_behavior/follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/follow/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return AI_BEHAVIOR_DELAY

	var/atom/movable/follow_target = controller.blackboard[BB_FOLLOW_TARGET]
	if(!follow_target || get_dist(living_pawn, follow_target) > controller.blackboard[BB_VISION_RANGE])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_target = follow_target
	if(istype(living_target) && (living_target.stat == DEAD))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	set_movement_target(controller, living_target)
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/follow/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_FOLLOW_TARGET)

/datum/ai_behavior/perform_emote

/datum/ai_behavior/perform_emote/perform(seconds_per_tick, datum/ai_controller/controller, emote, speech_sound)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return AI_BEHAVIOR_INSTANT
	living_pawn.manual_emote(emote)
	if(speech_sound) // Only audible emotes will pass in a sound
		playsound(living_pawn, speech_sound, 80, vary = TRUE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/perform_speech

/datum/ai_behavior/perform_speech/perform(seconds_per_tick, datum/ai_controller/controller, speech, speech_sound)
	. = ..()

	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return AI_BEHAVIOR_INSTANT
	living_pawn.say(speech, forced = "AI Controller")
	if(speech_sound)
		playsound(living_pawn, speech_sound, 80, vary = TRUE)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/perform_speech_radio

/datum/ai_behavior/perform_speech_radio/perform(seconds_per_tick, datum/ai_controller/controller, speech, obj/item/radio/speech_radio, list/try_channels = list(RADIO_CHANNEL_COMMON))
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !istype(speech_radio) || QDELETED(speech_radio) || !length(try_channels))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	speech_radio.talk_into(living_pawn, speech, pick(try_channels))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

//song behaviors

/datum/ai_behavior/setup_instrument

/datum/ai_behavior/setup_instrument/perform(seconds_per_tick, datum/ai_controller/controller, song_instrument_key, song_lines_key)
	var/obj/item/instrument/song_instrument = controller.blackboard[song_instrument_key]
	var/datum/song/song = song_instrument.song
	var/song_lines = controller.blackboard[song_lines_key]

	//just in case- it won't do anything if the instrument isn't playing
	song.stop_playing()
	song.ParseSong(new_song = song_lines)
	song.repeat = 10
	song.volume = song.max_volume - 10
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/play_instrument

/datum/ai_behavior/play_instrument/perform(seconds_per_tick, datum/ai_controller/controller, song_instrument_key)
	var/obj/item/instrument/song_instrument = controller.blackboard[song_instrument_key]
	var/datum/song/song = song_instrument.song

	song.start_playing(controller.pawn)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_nearby

/datum/ai_behavior/find_nearby/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/list/possible_targets = list()
	for(var/atom/thing in view(2, controller.pawn))
		if(!thing.mouse_opacity)
			continue
		if(thing.IsObscured())
			continue
		if(isitem(thing))
			var/obj/item/item = thing
			if(item.item_flags & ABSTRACT)
				continue
		possible_targets += thing
	if(!possible_targets.len)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, pick(possible_targets))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
