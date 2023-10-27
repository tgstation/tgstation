/obj/item/inhaler
	name = "inhaler"
	desc = "A small device capable of administering short bursts of aerosolized chemicals. Requires a canister to function."
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/reagent_containers/inhaler_canister/canister

	var/pre_insert_sound = 'sound/items/taperecorder/tape_flip.ogg'
	var/post_insert_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

	var/pre_insert_volume = 50
	var/post_insert_volume = 50

	var/insertion_time = 2 SECONDS

	var/self_administer_delay = 0 SECONDS
	var/other_administer_delay = 3 SECONDS

/obj/item/inhaler/Initialize(mapload)
	if (ispath(canister, /obj/item/reagent_containers/inhaler_canister))
		set_canister(new canister)

	return FALSE

/obj/item/inhaler/attack(mob/living/target_mob, mob/living/user, params)
	if (!can_puff(target_mob, user))
		return FALSE

	var/puff_timer

	var/pre_use_visible_message
	var/pre_use_self_message
	var/pre_use_target_message

	var/post_use_visible_message
	var/post_use_self_message
	var/post_use_target_message

	if (target_mob == user) // no need for a target message
		puff_timer = self_administer_delay

		pre_use_visible_message = span_notice("[user] puts [src] to [user.p_their()] lips, fingers on the canister...")
		pre_use_self_message = span_notice("You put [src] to your lips and put pressure on canister...")

		post_use_visible_message = span_notice("[user] takes a puff of [src]!")
		post_use_self_message = span_notice("You take a puff of [src]!")
	else
		puff_timer = other_administer_delay

		pre_use_visible_message = span_warning("[user] tries to force [src] between [target_mob]'s lips...")
		pre_use_self_message = span_notice("You try to put [src] to [target_mob]'s lips...")
		pre_use_target_message = span_userdanger("[user] tries to force [src] between your lips!")

		post_use_visible_message = span_warning("[user] forces [src] between [target_mob]'s lips and pushes the canister down!")
		post_use_self_message = span_notice("You force [src] between [target_mob]'s lips and press on the canister!")
		post_use_target_message = span_userdanger("[user] forces [src] between your lips and presses on the canister, filling your lungs with aerosol!")

	if (puff_timer > 0)
		user.visible_message(pre_use_visible_message, ignored_mobs = list(user, target_mob))
		to_chat(user, pre_use_self_message)
		if (pre_use_target_message)
			to_chat(target_mob, pre_use_target_message)
		if (!do_after(user, puff_timer))
			return FALSE
		if (!can_puff(target_mob, user)) // sanity
			return FALSE

	user.visible_message(post_use_visible_message, ignored_mobs = list(user, target_mob))
	to_chat(user, post_use_self_message)
	if (post_use_target_message)
		to_chat(target_mob, post_use_target_message)

	canister.puff(user, target_mob)

/obj/item/inhaler/attack_self(mob/user, modifiers)
	try_remove_canister(user, modifiers)

	return ..()

/obj/item/inhaler/attackby(obj/item/attacking_item, mob/user, params)
	if (istype(attacking_item, /obj/item/reagent_containers/inhaler_canister))
		return try_insert_canister(attacking_item, user, params)

	return ..()

/obj/item/inhaler/proc/try_remove_canister(mob/living/user, modifiers)
	if (isnull(canister))
		balloon_alert(user, "no canister inserted!")
		return FALSE

	balloon_alert(user, "canister removed")
	set_canister(null, user)

/obj/item/inhaler/proc/try_insert_canister(obj/item/reagent_container/inhaler_canisters/new_canister, mob/living/user, params)
	if (!isnull(canister))
		balloon_alert(user, "remove the existing canister!")
		return FALSE

	balloon_alert(user, "inserting canister...")
	playsound(src, pre_insert_sound, pre_insert_volume)
	if (!do_after(user, insertion_time))
		return FALSE
	playsound(src, post_insert_sound, post_insert_volume)
	balloon_alert(user, "canister inserted")
	set_canister(new_canister, user)

	return TRUE

/obj/item/inhaler/proc/set_canister(obj/item/reagent_containers/inhaler_canister/new_canister, mob/living/user)

	if (!isnull(canister))
		if (iscarbon(loc))
			var/mob/living/carbon/carbon_loc = loc
			carbon_loc.put_in_hands(canister)
		else if (!isnull(loc))
			canister.forceMove(loc)

	canister = new_canister
	canister?.forceMove(src)

/obj/item/inhaler/proc/can_puff(mob/living/target_mob, mob/living/user, silent = FALSE)
	if (isnull(canister))
		if (!silent)
			balloon_alert(user, "no canister!")
		return FALSE
	if (isnull(canister.reagents) || canister.reagents.total_volume <= 0)
		if (!silent)
			balloon_alert(user, "canister is empty!")
		return FALSE
	if (!iscarbon(target_mob)) // maybe mix this into a general has mouth check
		if (!silent)
			balloon_alert(user, "not a carbon!")
		return FALSE
	if (user.is_mouth_covered())
		if (!silent)
			balloon_alert(user, "expose the mouth!")
		return FALSE
	return TRUE

/obj/item/reagent_containers/inhaler_canister
	name = "inhaler canister"
	desc = "A small canister filled with aerosolized reagents for use in a inhaler."
	w_class = WEIGHT_CLASS_TINY

	amount_per_transfer_from_this = 10
	volume = 30


	var/puff_sound = 'sound/effects/spray.ogg'
	var/puff_volume = 20

/obj/item/reagent_containers/inhaler_canister/proc/puff(mob/living/user, mob/living/carbon/target)
	playsound(src, puff_sound, puff_volume, TRUE, -6)
	reagents.trans_to(M, amount_per_transfer_from_this, transferred_by = user, methods = INHALE)

