// Throwing stuff
/mob/living/proc/toggle_throw_mode()
	if(stat)
		return
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return
	if(throw_mode)
		throw_mode_off(THROW_MODE_TOGGLE)
	else
		throw_mode_on(THROW_MODE_TOGGLE)


/mob/living/proc/throw_mode_off(method)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return
	if(throw_mode > method) //A toggle doesnt affect a hold
		return
	throw_mode = THROW_MODE_DISABLED
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw"
	SEND_SIGNAL(src, COMSIG_LIVING_THROW_MODE_TOGGLE, throw_mode)


/mob/living/proc/throw_mode_on(mode = THROW_MODE_TOGGLE)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return
	throw_mode = mode
	if(hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"
	SEND_SIGNAL(src, COMSIG_LIVING_THROW_MODE_TOGGLE, throw_mode)

/mob/proc/throw_item(atom/target)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		return FALSE
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	return TRUE

/mob/living/throw_item(atom/target)
	. = ..()
	throw_mode_off(THROW_MODE_TOGGLE)
	if(!HAS_TRAIT(src, TRAIT_CAN_THROW_ITEMS))
		stack_trace("[src] tried to throw [target], but they shouldn't be able to throw things")
		return FALSE
	if(!target || !isturf(loc))
		return FALSE
	if(istype(target, /atom/movable/screen))
		return FALSE
	var/atom/movable/thrown_thing
	var/obj/item/held_item = get_active_held_item()
	var/verb_text = pick("throw", "toss", "hurl", "chuck", "fling")
	if(prob(0.5))
		verb_text = "yeet"
	var/neckgrab_throw = FALSE // we can't check for if it's a neckgrab throw when totaling up power_throw since we've already stopped pulling them by then, so get it early
	var/frequency_number = 1 //We assign a default frequency number for the sound of the throw.
	if(!held_item)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				if(grab_state >= GRAB_NECK)
					neckgrab_throw = TRUE
				stop_pulling()
				if(HAS_TRAIT(src, TRAIT_PACIFISM) || HAS_TRAIT(src, TRAIT_NO_THROWING))
					to_chat(src, span_notice("You gently let go of [throwable_mob]."))
					return FALSE
	else
		thrown_thing = held_item.on_thrown(src, target)
	if(!thrown_thing)
		return FALSE
	if(isliving(thrown_thing))
		var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
		var/turf/end_T = get_turf(target)
		if(start_T && end_T)
			log_combat(src, thrown_thing, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")
	var/power_throw = 0
	var/extra_throw_range = HAS_TRAIT(src, TRAIT_THROWINGARM) ? 2 : 0

	var/obj/item/organ/cyberimp/chest/spine/potential_spine = get_organ_slot(ORGAN_SLOT_SPINE)
	if(istype(potential_spine))
		power_throw += potential_spine.added_throw_speed
		extra_throw_range += potential_spine.added_throw_range

	if(HAS_TRAIT(src, TRAIT_HULK))
		power_throw++
	if(HAS_TRAIT(src, TRAIT_DWARF))
		power_throw--
	if(HAS_TRAIT(thrown_thing, TRAIT_DWARF))
		power_throw++
	if(neckgrab_throw)
		power_throw++
	if(HAS_TRAIT(src, TRAIT_TOSS_GUN_HARD) && isgun(thrown_thing))
		power_throw++
	if(isitem(thrown_thing))
		var/obj/item/thrown_item = thrown_thing
		frequency_number = 1-(thrown_item.w_class-3)/8 //At normal weight, the frequency is at 1. For tiny, it is 1.25. For huge, it is 0.75.
		if(thrown_item.throw_verb)
			verb_text = thrown_item.throw_verb
	do_attack_animation(target, no_effect = 1)
	var/sound/throwsound = 'sound/items/weapons/throw.ogg'
	var/power_throw_text = "."
	if(power_throw > 0) //If we have anything that boosts our throw power like hulk, we use the rougher heavier variant.
		throwsound = 'sound/items/weapons/throwhard.ogg'
		power_throw_text = " really hard!"
	if(power_throw < 0) //if we have anything that weakens our throw power like dward, we use a slower variant.
		throwsound = 'sound/items/weapons/throwsoft.ogg'
		power_throw_text = " flimsily."
	frequency_number = frequency_number + (rand(-5,5)/100); //Adds a bit of randomness in the frequency to not sound exactly the same.
	//The volume of the sound takes the minimum between the distance thrown or the max range an item, but no more than 50. Short throws are quieter. A fast throwing speed also makes the noise sharper.
	playsound(src, throwsound, clamp(8*min(get_dist(loc,target),thrown_thing.throw_range), 10, 50), vary = TRUE, extrarange = -1, frequency = frequency_number)
	visible_message(span_danger("[src] [verb_text][plural_s(verb_text)] [thrown_thing][power_throw_text]"), \
					span_danger("You [verb_text] [thrown_thing][power_throw_text]"))
	log_message("has thrown [thrown_thing] [power_throw_text]", LOG_ATTACK)

	var/drift_force = max(0.5 NEWTONS, 1 NEWTONS + power_throw)
	if (isitem(thrown_thing))
		var/obj/item/thrown_item = thrown_thing
		drift_force *= WEIGHT_TO_NEWTONS(thrown_item.w_class)

	newtonian_move(get_angle(target, src), drift_force = drift_force)
	thrown_thing.safe_throw_at(target, thrown_thing.throw_range + extra_throw_range, max(1,thrown_thing.throw_speed + power_throw), src, null, null, null, move_force)

// Giving stuff
/**
 * Proc called when offering an item to another player
 *
 * This handles creating an alert and adding an overlay to it
 * Arguments:
 * * offered - The player being offered the item (optional, if null the offer is to everyone around)
 */
/mob/living/proc/give(mob/living/offered)
	if(has_status_effect(/datum/status_effect/offering))
		to_chat(src, span_warning("You're already offering something!"))
		return

	if(IS_DEAD_OR_INCAP(src))
		to_chat(src, span_warning("You're unable to offer anything in your current state!"))
		return

	var/obj/item/offered_item = get_active_held_item()
	// if it's an abstract item, should consider it to be non-existent (unless it's a HAND_ITEM, which means it's an obj/item that is just a representation of our hand)
	if(!offered_item || ((offered_item.item_flags & ABSTRACT) && !(offered_item.item_flags & HAND_ITEM)))
		to_chat(src, span_warning("You're not holding anything to offer!"))
		return

	if(offered)
		if(offered == src)
			if(!swap_hand(get_inactive_hand_index())) //have to swap hands first to take something
				to_chat(src, span_warning("You try to take [offered_item] from yourself, but fail."))
				return
			if(!put_in_active_hand(offered_item))
				to_chat(src, span_warning("You try to take [offered_item] from yourself, but fail."))
				return
			else
				to_chat(src, span_notice("You take [offered_item] from yourself."))
				return

		if(IS_DEAD_OR_INCAP(offered))
			to_chat(src, span_warning("[offered.p_Theyre()] unable to take anything in [offered.p_their()] current state!"))
			return

		if(!CanReach(offered))
			to_chat(src, span_warning("You have to be beside [offered.p_them()]!"))
			return

		if(!HAS_TRAIT(offered, TRAIT_CAN_HOLD_ITEMS))
			to_chat(src, span_warning("[offered.p_They()] can't hold anything you offer!"))
			return
	else if(!(locate(/mob/living) in orange(1, src)))
		to_chat(src, span_warning("There's nobody beside you to take it!"))
		return

	if(offered_item.on_offered(src)) // see if the item interrupts with its own behavior
		return

	balloon_alert_to_viewers("offers something")
	visible_message(span_notice("[src] is offering [offered ? "[offered] " : ""][offered_item]."), \
					span_notice("You offer [offered ? "[offered] " : ""][offered_item]."), null, 2)

	apply_status_effect(/datum/status_effect/offering, offered_item, null, offered)

/**
 * Proc called when the player clicks the give alert
 *
 * Handles checking if the player taking the item has open slots and is in range of the offerer
 * Also deals with the actual transferring of the item to the players hands
 * Arguments:
 * * offerer - The living mob giving the original item
 * * offered_item - The item being given by the offerer
 */
/mob/living/proc/take(mob/living/offerer, obj/item/offered_item)
	clear_alert("[offerer]")
	if(IS_DEAD_OR_INCAP(src))
		to_chat(src, span_warning("You're unable to take anything in your current state!"))
		return
	if(get_dist(src, offerer) > 1)
		to_chat(src, span_warning("[offerer] is out of range!"))
		return
	if(!offered_item || offerer.get_active_held_item() != offered_item)
		to_chat(src, span_warning("[offerer] is no longer holding the item they were offering!"))
		return
	if(!get_empty_held_indexes())
		to_chat(src, span_warning("You have no empty hands!"))
		return

	if(offered_item.on_offer_taken(offerer, src)) // see if the item has special behavior for being accepted
		return

	if(!offerer.temporarilyRemoveItemFromInventory(offered_item))
		visible_message(span_notice("[offerer] tries to hand over [offered_item] but it's stuck to them...."))
		return

	visible_message(span_notice("[src] takes [offered_item] from [offerer]."), \
					span_notice("You take [offered_item] from [offerer]."))
	offered_item.do_pickup_animation(src, offerer)
	put_in_hands(offered_item)


/mob/living/click_ctrl_shift(mob/user)
	if(HAS_TRAIT(src, TRAIT_CAN_HOLD_ITEMS))
		var/mob/living/living_user = user
		living_user.give(src)
