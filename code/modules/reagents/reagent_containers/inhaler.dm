/obj/item/inhaler
	name = "inhaler"
	desc = "A small device capable of administering short bursts of aerosolized chemicals. Requires a canister to function."
	w_class = WEIGHT_CLASS_SMALL

	var/obj/item/reagent_containers/inhaler_canister/canister
	var/obj/item/reagent_containers/inhaler_canister/initial_casister_path

	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "inhaler"

	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 0.1)

	var/mutable_appearance/canister_underlay
	var/canister_underlay_y_offset = 4
	var/show_puffs_left = TRUE

/obj/item/inhaler/Initialize(mapload)
	if (ispath(initial_casister_path, /obj/item/reagent_containers/inhaler_canister))
		set_canister(new initial_casister_path)

	return ..()

/obj/item/inhaler/Destroy(force)
	set_canister(null)

	return ..()

/obj/item/inhaler/examine(mob/user)
	. = ..()

	if (!isnull(canister))
		. += span_blue("It seems to have <b>[canister]</b> inserted.")
		if (show_puffs_left)
			. += "Its rotary display shows its canister can be used [span_blue("[canister.get_puffs_left()]")] more times."

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
		puff_timer = canister.self_administer_delay

		pre_use_visible_message = span_notice("[user] puts [src] to [user.p_their()] lips, fingers on the canister...")
		pre_use_self_message = span_notice("You put [src] to your lips and put pressure on canister...")

		post_use_visible_message = span_notice("[user] takes a puff of [src]!")
		post_use_self_message = span_notice("You take a puff of [src]!")
	else
		puff_timer = canister.other_administer_delay

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

	if (canister.removal_time > 0)
		balloon_alert(user, "removing canister...")
		if (!do_after(user, canister.removal_time))
			return FALSE

	balloon_alert(user, "canister removed")
	playsound(src, canister.post_insert_sound, canister.post_insert_volume)
	set_canister(null, user)

/obj/item/inhaler/proc/try_insert_canister(obj/item/reagent_containers/inhaler_canister/new_canister, mob/living/user, params)
	if (!isnull(canister))
		balloon_alert(user, "remove the existing canister!")
		return FALSE

	balloon_alert(user, "inserting canister...")
	playsound(src, new_canister.pre_insert_sound, new_canister.pre_insert_volume)
	if (!do_after(user, new_canister.insertion_time))
		return FALSE
	playsound(src, new_canister.post_insert_sound, new_canister.post_insert_volume)
	balloon_alert(user, "canister inserted")
	set_canister(new_canister, user)

	return TRUE

/obj/item/inhaler/proc/set_canister(obj/item/reagent_containers/inhaler_canister/new_canister, mob/living/user)
	if (!isnull(canister))
		if (iscarbon(loc))
			var/mob/living/carbon/carbon_loc = loc
			INVOKE_ASYNC(carbon_loc, TYPE_PROC_REF(/mob/living/carbon, put_in_hands), canister)
		else if (!isnull(loc))
			canister.forceMove(loc)
		UnregisterSignal(canister, COMSIG_QDELETING)

	canister = new_canister
	canister?.forceMove(src)
	RegisterSignal(canister, COMSIG_QDELETING, PROC_REF(canister_deleting))
	update_canister_underlay()

/obj/item/inhaler/proc/update_canister_underlay()
	if (isnull(canister))
		underlays -= canister_underlay
		canister_underlay = null
	else if (isnull(canister_underlay))
		canister_underlay = mutable_appearance(canister.icon, canister.icon_state)
		canister_underlay.pixel_y = canister_underlay_y_offset
		underlays += canister_underlay

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

/obj/item/inhaler/proc/canister_deleting(datum/signal_source)
	SIGNAL_HANDLER

	set_canister(null)

/obj/item/reagent_containers/inhaler_canister
	name = "inhaler canister"
	desc = "A small canister filled with aerosolized reagents for use in a inhaler."
	w_class = WEIGHT_CLASS_TINY

	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "inhaler_canister"

	amount_per_transfer_from_this = 5
	volume = 25
	reagent_flags = SEALED_CONTAINER|DRAINABLE|REFILLABLE
	has_variable_transfer_amount = FALSE

	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.2)

	var/puff_sound = 'sound/effects/spray.ogg'
	var/puff_volume = 20

	var/pre_insert_sound = 'sound/items/taperecorder/tape_flip.ogg'
	var/post_insert_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

	var/pre_insert_volume = 50
	var/post_insert_volume = 50

	var/insertion_time = 2 SECONDS
	var/removal_time = 0.5 SECONDS

	var/other_administer_delay = 3 SECONDS
	var/self_administer_delay = 1 SECONDS

/obj/item/reagent_containers/inhaler_canister/proc/puff(mob/living/user, mob/living/carbon/target)
	playsound(src, puff_sound, puff_volume, TRUE, -6)
	reagents.trans_to(target, amount_per_transfer_from_this, transferred_by = user, methods = INHALE)

/obj/item/reagent_containers/inhaler_canister/proc/get_puffs_left()
	return ROUND_UP(reagents.total_volume / amount_per_transfer_from_this)

/obj/item/inhaler/salbutamol
	name = "salbutamol inhaler"
	initial_casister_path = /obj/item/reagent_containers/inhaler_canister/salbutamol

/obj/item/reagent_containers/inhaler_canister/salbutamol
	name = "salbutamol canister"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 30)

/obj/item/inhaler/albuterol
	name = "albuterol inhaler"
	initial_casister_path = /obj/item/reagent_containers/inhaler_canister/albuterol

/obj/item/reagent_containers/inhaler_canister/albuterol
	name = "albuterol canister"
	desc = "A small canister filled with aerosolized reagents for use in a inhaler. This one contains albuterol, a potent bronchodilator that can stop \
	asthma attacks in their tracks."
	list_reagents = list(/datum/reagent/medicine/albuterol = 30)

/obj/item/reagent_containers/inhaler_canister/albuterol/asthma
	name = "low-pressure albuterol canister"
	desc = "A small canister filled with aerosolized reagents for use in a inhaler. This one contains albuterol, a potent bronchodilator that can stop \
	asthma attacks in their tracks. It seems to be a lower-pressure variant, and can only hold 20u."
	list_reagents = list(/datum/reagent/medicine/albuterol = 20)
	volume = 20
	amount_per_transfer_from_this = 5

/obj/item/inhaler/albuterol/asthma
	name = "rescue inhaler"
	initial_casister_path = /obj/item/reagent_containers/inhaler_canister/albuterol/asthma
