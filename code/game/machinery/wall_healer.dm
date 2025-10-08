/// A wall mounted machine that heals chip damage for a price
/obj/machinery/wall_healer
	name = "\improper Deforest First Aid Station"
	desc = "A wall-mounted first aid station, designed to treat minor injuries - just stick your hand in and try to relax."
	icon = 'icons/obj/machines/wall_healer.dmi'
	icon_state = "wall_healer"
	base_icon_state = "wall_healer"
	density = FALSE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND // manually handled
	payment_department = ACCOUNT_MED
	max_integrity = 150
	armor_type = /datum/armor/obj_machinery/wall_healer

	/// Cost per bandage dispensed. Note, always disregarded on red alert.
	var/per_bandage_cost = (/obj/item/stack/medical/gauze::custom_price) / (/obj/item/stack/medical/gauze::amount)
	/// Number of bandages to dispense on rmb. Never recharges but can be restocked.
	var/num_bandages = 5
	/// Lazylist of bandages that have been restocked into the wall healer.
	VAR_PRIVATE/list/stocked_bandages

	/// Cost per unit of healing applied.
	/// Note: disregarded on red alert.
	var/per_heal_cost = 2.5
	/// Amount of brute healing pooled
	VAR_PRIVATE/brute_healing = MAX_LIVING_HEALTH * 0.4
	/// Amount of burn healing pooled
	VAR_PRIVATE/burn_healing = MAX_LIVING_HEALTH * 0.4
	/// Amount of toxin healing pooled
	VAR_PRIVATE/tox_healing = MAX_LIVING_HEALTH * 0.3
	/// Amount of blood to restore
	VAR_PRIVATE/blood_healing = BLOOD_VOLUME_NORMAL * 0.1

	/// Current mob using the wall healer
	VAR_PRIVATE/mob/living/current_user
	/// Current hand of the mob using the wall healer, if any (can be unset if in use by a simplemob, for example)
	VAR_PRIVATE/obj/item/bodypart/current_hand
	/// Ref of the last user to touch the wall healer - only set when there is no active user
	VAR_PRIVATE/last_user_ref
	/// Bar that props above the healer to show time until next injection
	VAR_PRIVATE/datum/progressbar/wall_healer/injection_bar

	/// How long it takes to recharge the wall healer
	var/recharge_cd_length = 30 SECONDS
	/// How long it takes between injections
	var/injection_cd_length = 4 SECONDS
	/// Cooldown between chem recharges
	COOLDOWN_DECLARE(recharge_cooldown)
	/// Cooldown between chem injections
	COOLDOWN_DECLARE(injection_cooldown)
	/// Only sends messages every X injections to the same user to avoid spam
	VAR_PRIVATE/antispam_counter = 0

/datum/armor/obj_machinery/wall_healer
	melee = 50
	bullet = 30
	laser = 30
	energy = 40
	bomb = 10
	fire = 80
	acid = 80

/obj/machinery/wall_healer/Initialize(mapload)
	. = ..()
	if(!mapload)
		brute_healing = 0
		burn_healing = 0
		tox_healing = 0
		blood_healing = 0
		update_appearance()
	init_payment()
	register_context()

/obj/machinery/wall_healer/Destroy()
	clear_using_mob()
	QDEL_LAZYLIST(stocked_bandages)
	return ..()

/obj/machinery/wall_healer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Heal self"
		context[SCREENTIP_CONTEXT_RMB] = "Get gauze"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stack/medical/gauze))
		context[SCREENTIP_CONTEXT_LMB] = "Restock"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/wall_healer/proc/refill_healing_pool(percent = 100)
	var/amount_refilled = 0

	var/pre_brute_healing = brute_healing
	brute_healing = min(brute_healing + initial(brute_healing) * (percent / 100), initial(brute_healing))
	amount_refilled += brute_healing - pre_brute_healing

	var/pre_burn_healing = burn_healing
	burn_healing = min(burn_healing + initial(burn_healing) * (percent / 100), initial(burn_healing))
	amount_refilled += burn_healing - pre_burn_healing

	var/pre_tox_healing = tox_healing
	tox_healing = min(tox_healing + initial(tox_healing) * (percent / 100), initial(tox_healing))
	amount_refilled += tox_healing - pre_tox_healing

	var/pre_blood_healing = blood_healing
	blood_healing = min(blood_healing + initial(blood_healing) * (percent / 100), initial(blood_healing))
	amount_refilled += blood_healing - pre_blood_healing

	if(amount_refilled > 0)
		update_appearance()

	return amount_refilled

/obj/machinery/wall_healer/proc/init_payment()
	// Cost depends on service (so just use 0 here)
	AddComponent(/datum/component/payment, 0, SSeconomy.get_dep_account(ACCOUNT_MED), PAYMENT_FRIENDLY)
	desc += " Charges by the second, though all costs are waived on red alert."

/obj/machinery/wall_healer/examine(mob/user)
	. = ..()
	var/total_bandages = num_bandages + LAZYLEN(stocked_bandages)
	. += span_notice("It has [total_bandages] bandage\s stocked.\
		[total_bandages ? " [is_free(user) ? "Purchase" : "Retrieve"] a bandage with [EXAMINE_HINT("right-click")]." : ""]")
	if(current_user)
		. += span_notice("[current_user] currently [current_hand ? "has [current_user.p_their()] [current_hand.plaintext_zone] in" : "is using"] it.")

/obj/machinery/wall_healer/update_overlays()
	. = ..()

	var/brute_state = 7 - round(7 * (brute_healing / initial(brute_healing)), 1)
	var/mutable_appearance/brute = mutable_appearance(icon, "bar[brute_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	brute.color = /datum/reagent/medicine/c2/libital::color
	// no offset necessary
	. += brute

	var/burn_state = 7 - round(7 * (burn_healing / initial(burn_healing)), 1)
	var/mutable_appearance/burn = mutable_appearance(icon, "bar[burn_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	burn.color = /datum/reagent/medicine/c2/aiuri::color
	burn.pixel_w += 4
	. += burn

	var/tox_state = 7 - round(7 * (tox_healing / initial(tox_healing)), 1)
	var/mutable_appearance/tox = mutable_appearance(icon, "bar[tox_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	tox.color = /datum/reagent/medicine/c2/syriniver::color
	tox.pixel_w += 8
	. += tox

	var/blood_state = 7 - round(7 * (blood_healing / initial(blood_healing)), 1)
	var/mutable_appearance/blood = mutable_appearance(icon, "bar[blood_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	blood.color = /datum/reagent/blood::color
	blood.pixel_w += 12
	. += blood

	if(is_operational)
		. += emissive_appearance(icon, "bar_emissive", src, alpha = src.alpha)
	. += mutable_appearance(icon, "bar_shadow", alpha = src.alpha, appearance_flags = RESET_COLOR)

/obj/machinery/wall_healer/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE

	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	visible_message(span_warning("Sparks fly out of [src]!"))
	balloon_alert(user, "safeties disabled")
	obj_flags |= EMAGGED
	return TRUE

/// We want user to be right up to the wall mount to use it
/// However people may often map the machine over a table
/// In those contexts, they should be allowed to reach over the table
/obj/machinery/wall_healer/proc/loc_check(mob/checking)
	var/turf/turf_loc = get_turf(src)
	if(turf_loc.is_blocked_turf())
		return checking.Adjacent(turf_loc)
	return checking.loc == turf_loc

/obj/machinery/wall_healer/mouse_drop_receive(atom/dropped, mob/user, params)
	. = ..()
	if(.)
		return .
	if(!isliving(user) || !ishuman(dropped))
		balloon_alert(user, "incompatible!")
		return FALSE
	var/mob/living/who_put_user_in = user
	var/mob/living/new_user = dropped
	if(!loc_check(new_user))
		balloon_alert(who_put_user_in, "[new_user == who_put_user_in ? "get" : "bring [new_user.p_them()]"] closer!")
		return FALSE

	if(do_after(user, 1 SECONDS, src))
		other_put_users_hand_in(new_user, who_put_user_in)
	return TRUE

/obj/machinery/wall_healer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return .
	if(!ishuman(user))
		balloon_alert(user, "incompatible!")
		return FALSE
	if(!loc_check(user))
		balloon_alert(user, "get closer!")
		return FALSE
	if(do_after(user, 0.5 SECONDS, src))
		user_put_in_own_hand(user)
	return TRUE

/obj/machinery/wall_healer/proc/user_put_in_own_hand(mob/living/user)
	if(user == current_user)
		clear_using_mob()
		if(user.get_active_hand() == current_hand)
			user.visible_message(
				span_notice("[user] removes [user.p_their()] hand from [src]."),
				span_notice("You remove your hand from [src]."),
				span_hear("You hear a click."),
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				vision_distance = 5,
			)
		else
			add_fingerprint(user)
			user.visible_message(
				span_notice("[user] removes [user.p_their()] hand from [src] and puts it in [user.p_their()] other hand."),
				span_notice("You remove your hand from [src] and put it in your other hand."),
				span_hear("You hear a click."),
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				vision_distance = 5,
			)
			set_using_mob(user)
		return
	else if(current_user)
		user.visible_message(
			span_notice("[user] tries to put [user.p_their()] hand in [src], but [current_user] is already using it."),
			span_notice("You try to put your hand in [src], but [current_user] is already using it."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
		)
		return

	add_fingerprint(user)
	if(is_operational)
		user.visible_message(
			span_notice("[user] puts [user.p_their()] hand in [src], and immediately some kind of sensor scans [user.p_their()] arm."),
			span_notice("You put your hand in [src], and immediately some kind of sensor scans your arm."),
			span_hear("You hear a click."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
		)
	else
		user.visible_message(
			span_notice("[user] puts [user.p_their()] hand in [src], but it doesn't respond. Seems to be out of order."),
			span_notice("You put your hand in [src], but it doesn't respond."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
		)
	set_using_mob(user)

/obj/machinery/wall_healer/proc/other_put_users_hand_in(mob/living/user, mob/living/who_put_user_in)
	if(who_put_user_in == user)
		return user_put_in_own_hand(user)

	if(current_user == user)
		clear_using_mob()
		if(user.get_active_hand() == current_hand)
			to_chat(who_put_user_in, span_notice("You remove [user]'s hand from [src]."))
			user.visible_message(
				span_notice("[who_put_user_in] removes [user]'s hand from [src]."),
				span_notice("[who_put_user_in] remove your hand from [src]."),
				span_hear("You hear a click."),
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				vision_distance = 5,
				ignored_mobs = who_put_user_in,
			)
		else
			to_chat(who_put_user_in, span_notice("You remove [user]'s hand from [src] and put it in [user.p_their()] other hand."))
			user.visible_message(
				span_notice("[who_put_user_in] removes [user.p_their()] hand from [src] and puts it in [user.p_their()] other hand."),
				span_notice("[who_put_user_in] removes your hand from [src] and puts it in your other hand."),
				span_hear("You hear a click."),
				visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
				vision_distance = 5,
				ignored_mobs = who_put_user_in,
			)
			add_fingerprint(user)
			set_using_mob(who_put_user_in)
		return

	if(current_user)
		to_chat(who_put_user_in, span_notice("You try to put [user]'s hand in [src], but [current_user] is already using it."))
		user.visible_message(
			span_notice("[who_put_user_in] tries to put [user]'s hand in [src], but [current_user] is already using it."),
			span_notice("[who_put_user_in] tries to put your hand in [src], but [current_user] is already using it."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
			ignored_mobs = who_put_user_in,
		)
		return

	add_fingerprint(who_put_user_in)
	if(is_operational)
		to_chat(who_put_user_in, span_notice("You put [user]'s hand in [src], and immediately some kind of sensor scans [user.p_their()] arm."))
		user.visible_message(
			span_notice("[who_put_user_in] puts [user.p_their()] hand in [src], and immediately some kind of sensor scans [user.p_their()] arm."),
			span_notice("[who_put_user_in] puts your hand in [src], and immediately some kind of sensor scans your arm."),
			span_hear("You hear a click."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
			ignored_mobs = who_put_user_in,
		)
	else
		to_chat(who_put_user_in, span_notice("You put [user]'s hand in [src], but it doesn't respond. Seems to be out of order."))
		user.visible_message(
			span_notice("[who_put_user_in] puts [user.p_their()] hand in [src], but it doesn't respond. Seems to be out of order."),
			span_notice("[who_put_user_in] puts your hand in [src], but it doesn't respond."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
			ignored_mobs = who_put_user_in,
		)
	set_using_mob(user)

/obj/machinery/wall_healer/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. != SECONDARY_ATTACK_CALL_NORMAL || !isliving(user))
		return .
	var/mob/living/living_user = user
	if(!is_operational)
		to_chat(user, span_warning("You try to retrieve some gauze, but [src] doesn't respond."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(num_bandages + LAZYLEN(stocked_bandages) <= 0)
		to_chat(user, span_warning("You try to retrieve some gauze, but [src] seems to be out of stock."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(attempt_charge(src, user, extra_fees = floor(per_bandage_cost)) & COMPONENT_OBJ_CANCEL_CHARGE)
		if(!living_user.get_idcard())
			to_chat(user, span_warning("No ID card found. Aborting."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if((obj_flags & EMAGGED) && prob(99))
		to_chat(user, span_warning("You try to retrieve some gauze, but it gets all jammed up in the access port."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/obj/item/stack/medical/gauze/bandage = LAZYACCESS(stocked_bandages, 1)
	if(isnull(bandage))
		num_bandages--
		bandage = new(user.drop_location(), 1)
	user.put_in_hands(bandage)
	user.visible_message(
		span_notice("[user] retrieves [bandage] from [src]."),
		span_notice("You retrieve [bandage] from [src]."),
		span_hear("You hear a click."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		vision_distance = 5,
	)
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/wall_healer/on_deconstruction(disassembled)
	var/atom/drop_loc = drop_location()
	for(var/obj/item/stack/medical/gauze/bandage as anything in stocked_bandages)
		bandage.forceMove(drop_loc)
	new /obj/item/stack/medical/gauze(drop_loc, num_bandages)

/obj/machinery/wall_healer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/medical/gauze))
		return NONE
	if(!user.temporarilyRemoveItemFromInventory(tool))
		to_chat(user, span_warning("You try to restock [src] with [tool], but it seems stuck to your hand."))
		return ITEM_INTERACT_BLOCKING
	user.visible_message(
		span_notice("[user] restocks [src] with [tool]."),
		span_notice("You restock [src] with [tool]."),
		span_hear("You hear a click."),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		vision_distance = 5,
	)
	var/obj/item/stack/medical/gauze/bandage = tool
	while(bandage.amount > 1)
		var/obj/item/stack/medical/gauze/split_bandage = bandage.split_stack(1)
		LAZYADD(stocked_bandages, split_bandage)
		split_bandage.forceMove(src)
	LAZYADD(stocked_bandages, bandage)
	bandage.forceMove(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/wall_healer/proc/set_using_mob(mob/living/user)
	if(last_user_ref != REF(user))
		COOLDOWN_RESET(src, injection_cooldown)

	antispam_counter = 0
	last_user_ref = null

	current_user = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(user_moved))
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(clear_using_mob))

	current_hand = user.get_active_hand()
	if(current_hand)
		RegisterSignals(current_hand, list(COMSIG_BODYPART_REMOVED, COMSIG_QDELETING), PROC_REF(clear_using_mob))

	injection_bar = new(user, injection_cd_length, src, COOLDOWN_TIMELEFT(src, injection_cooldown))

/obj/machinery/wall_healer/proc/clear_using_mob(...)
	SIGNAL_HANDLER
	if(current_hand)
		UnregisterSignal(current_hand, COMSIG_BODYPART_REMOVED)
		UnregisterSignal(current_hand, COMSIG_QDELETING)
		current_hand = null
	if(current_user)
		last_user_ref = REF(current_user)
		UnregisterSignal(current_user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(current_user, COMSIG_QDELETING)
		UnregisterSignal(current_user, COMSIG_CARBON_REMOVE_LIMB)
		current_user = null
	QDEL_NULL(injection_bar)

/obj/machinery/wall_healer/proc/user_moved(...)
	SIGNAL_HANDLER
	if(current_user.loc == loc)
		return
	if(!QDELING(current_user))
		current_user.visible_message(
			span_notice("[current_user] removes [current_user.p_their()] hand from [src]."),
			span_notice("You remove your hand from [src]."),
			span_hear("You hear a click."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
			vision_distance = 5,
		)
	clear_using_mob()

/obj/machinery/wall_healer/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(current_user && current_user.loc != loc)
		clear_using_mob()

/obj/machinery/wall_healer/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(stocked_bandages, gone)

/// Checks if the machine is free for the given mob
/obj/machinery/wall_healer/proc/is_free(mob/living/for_who)
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		return TRUE // always free on red alert
	if(!istype(for_who))
		return FALSE
	var/obj/item/card/id/card = for_who.get_idcard(TRUE)
	if(card?.registered_account?.account_job?.paycheck_department == payment_department)
		return TRUE // free for doctors
	return FALSE

/obj/machinery/wall_healer/attempt_charge(atom/sender, atom/target, extra_fees)
	if(is_free(target))
		return NONE
	return ..()

/obj/machinery/wall_healer/process()
	if(!is_operational)
		// puts off recharging until operational again
		COOLDOWN_START(src, recharge_cooldown, recharge_cd_length * 0.5)
		return
	if(isnull(current_user))
		if(COOLDOWN_FINISHED(src, recharge_cooldown) && refill_healing_pool(10))
			COOLDOWN_START(src, recharge_cooldown, recharge_cd_length)
			playsound(src, 'sound/machines/defib/defib_ready.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	if(!COOLDOWN_FINISHED(src, injection_cooldown))
		return

	COOLDOWN_START(src, injection_cooldown, injection_cd_length)
	antispam_counter++

	var/arm_check = isnull(current_hand) ? (current_user.mob_biotypes & MOB_ORGANIC) : IS_ORGANIC_LIMB(current_hand)
	if(!arm_check)
		playsound(src, 'sound/machines/defib/defib_saftyOff.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(antispam_counter % 3 == 1)
			to_chat(current_user, span_notice("Nothing happens. Seems [src] doesn't recognize non-organic [current_hand ? "limbs" : "beings"]."))
		return

	if(!current_user.can_inject(null, current_hand))
		playsound(src, 'sound/machines/defib/defib_saftyOff.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(antispam_counter % 3 == 1)
			to_chat(current_user, span_notice("Nothing happens. Seems [src] can't find any exposed flesh to work on."))
		return

	if(obj_flags & EMAGGED)
		current_user.apply_damage(33, BRUTE, current_hand, sharpness = SHARP_POINTY)
		playsound(src, 'sound/machines/defib/defib_failed.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(antispam_counter % 2 == 1)
			to_chat(current_user, span_warning("You feel a sharp pain as the machine malfunctions, stabbing you with several instruments and needles!"))
		use_energy(500 JOULES)
		add_mob_blood(current_user)
		return

	var/brute_healing_now = round(min(initial(brute_healing) * 0.1, brute_healing, current_user.getBruteLoss()), DAMAGE_PRECISION)
	var/burn_healing_now = round(min(initial(burn_healing) * 0.1, burn_healing, current_user.getFireLoss()), DAMAGE_PRECISION)
	var/tox_healing_now = round(min(initial(tox_healing) * 0.1, tox_healing, current_user.getToxLoss()), DAMAGE_PRECISION)
	var/blood_healing_now = HAS_TRAIT(current_user, TRAIT_NOBLOOD) ? 0 : round(min(initial(blood_healing) * 0.1, blood_healing, max(BLOOD_VOLUME_OKAY - current_user.blood_volume, 0)), 0.1)

	var/cost = round(per_heal_cost * (brute_healing_now + burn_healing_now + tox_healing_now + blood_healing_now), 1)
	if(attempt_charge(src, current_user, extra_fees = cost) & COMPONENT_OBJ_CANCEL_CHARGE)
		playsound(src, 'sound/machines/defib/defib_saftyOff.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		// attempt charge sends a chat message on fail, except if the user has no ID card
		if((antispam_counter % 3 == 1) && !current_user.get_idcard())
			to_chat(current_user, span_warning("No ID card found. Aborting."))
		return

	var/amount_healed = 0
	if(brute_healing_now)
		amount_healed += current_user.adjustBruteLoss(-brute_healing_now, required_bodytype = BODYTYPE_ORGANIC)
		brute_healing -= brute_healing_now
		add_mob_blood(current_user)
	if(burn_healing_now)
		amount_healed += current_user.adjustFireLoss(-burn_healing_now, required_bodytype = BODYTYPE_ORGANIC)
		burn_healing -= burn_healing_now
	if(tox_healing_now)
		amount_healed += current_user.adjustToxLoss(-tox_healing_now, required_biotype = MOB_ORGANIC)
		tox_healing -= tox_healing_now
	if(blood_healing_now)
		current_user.blood_volume += blood_healing_now
		amount_healed += blood_healing_now
		blood_healing -= blood_healing_now
		add_mob_blood(current_user)

	if(amount_healed)
		playsound(src, 'sound/machines/defib/defib_SaftyOn.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		if(antispam_counter % 2 == 1)
			to_chat(current_user, span_notice("Several instruments and syringes work on your [current_hand?.plaintext_zone || "body"]. You feel a bit better."))
		update_appearance()
		use_energy(200 JOULES) // just some background power drain. we don't really care about whether this is actually successful
		return

	playsound(src, 'sound/machines/defib/defib_saftyOff.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(antispam_counter % 3 != 1)
		return
	var/missed_brute_healing = brute_healing_now > 0 && !current_user.getBruteLoss()
	var/missed_burn_healing = burn_healing_now > 0 && !current_user.getFireLoss()
	var/missed_tox_healing = tox_healing_now > 0 && !current_user.getToxLoss()
	var/missed_blood_healing = blood_healing_now > 0 && current_user.blood_volume >= BLOOD_VOLUME_OKAY
	if(missed_brute_healing || missed_burn_healing || missed_tox_healing || missed_blood_healing)
		to_chat(current_user, span_notice("Nothing happens. Seems like [src] needs to recharge."))
		return
	to_chat(current_user, span_notice("Nothing happens. Seems like you're in good enough shape."))

/// Subtype of progress bar used by the wall healer to show time until next injection
/// This subtype only exists so we can shove fastprocess processing off of the machine itself
/datum/progressbar/wall_healer

/datum/progressbar/wall_healer/New(mob/User, goal_number, atom/target, starting_amount)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/datum/progressbar/wall_healer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/progressbar/wall_healer/process(seconds_per_tick)
	var/obj/machinery/wall_healer/healer = bar_loc
	if(!istype(healer))
		stack_trace("[type] instantiated on a non-wall-healer target [bar_loc || "null"] ([bar_loc?.type || "null"])")
		return PROCESS_KILL

	update(COOLDOWN_FINISHED(healer, injection_cooldown) ? 0 : COOLDOWN_TIMELEFT(healer, injection_cooldown))

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/wall_healer, 32)

/obj/machinery/wall_healer/free
	name = "\improper Deforest Emergency First Aid Station"

/obj/machinery/wall_healer/free/init_payment()
	return

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/wall_healer/free, 32)
