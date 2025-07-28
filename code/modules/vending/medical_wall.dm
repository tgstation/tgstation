/obj/machinery/vending/wallmed
	name = "\improper Emergency NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser, Meant to be used in medical emergencies."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	panel_type = "wallmed-panel"
	density = FALSE
	products = list(
		/obj/item/stack/medical/bandage = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/hypospray/medipen/ekit = 1,
		/obj/item/healthanalyzer/simple = 1,
	)
	contraband = list(
		/obj/item/storage/box/bandages = 1,
		/obj/item/storage/box/gum/happiness = 1,
	)
	premium = list(
		/obj/item/reagent_containers/applicator/patch/libital = 1,
		/obj/item/reagent_containers/applicator/patch/aiuri = 1,
	)
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = PAYCHECK_CREW * 0.3 // Cheap since crew should be able to affort it in emergency situations
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_MED
	tiltable = FALSE
	light_mask = "wallmed-light-mask"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/vending/wallmed, 32)

/obj/item/vending_refill/wallmed
	machine_name = "Emergency NanoMed"
	icon_state = "refill_medical"

/obj/machinery/wall_healer
	name = "\improper Deforest First Aid Station"
	desc = "A wall-mounted first aid station, used to treat minor injuries - just stick your hand in and relax."
	icon = 'icons/obj/machines/wall_healer.dmi'
	icon_state = "wall_healer"
	base_icon_state = "wall_healer"
	density = FALSE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND // manually handled

	/// Cost per bandage dispensed. Note, always disregarded on red alert.
	var/per_bandage_cost = (/obj/item/stack/medical/gauze::custom_price) / (/obj/item/stack/medical/gauze::amount)
	/// Number of bandages to dispense on rmb. Never recharges but can be restocked.
	var/num_bandages = 5
	/// Lazylist of bandages that have been restocked into the wall healer.
	VAR_PRIVATE/list/stocked_bandages

	/// Cost per unit of chem injected. Note, always disregarded on red alert.
	var/per_injection_cost = 3
	/// Amount of chems injected per use
	var/per_injection = 3
	/// Reagent container containing chems that heal brute
	VAR_PRIVATE/datum/reagents/brute_healing
	/// Reagenet container containing chems that heal burn
	VAR_PRIVATE/datum/reagents/burn_healing
	/// Reagent container containing chems that heal toxins
	VAR_PRIVATE/datum/reagents/tox_healing
	/// Reagent container containing chems that assuage blood loss
	VAR_PRIVATE/datum/reagents/blood_healing

	/// Current mob using the wall healer
	VAR_PRIVATE/mob/living/current_user
	/// Current hand of the mob using the wall healer, if any
	VAR_PRIVATE/obj/item/bodypart/current_hand
	/// Ref of the last user to touch the wall healer - only set when there is no active user
	VAR_PRIVATE/last_user_ref
	/// Bar that props above the healer to show time until next injection
	VAR_PRIVATE/datum/progressbar/injection_bar

	/// How long it takes to recharge the wall healer
	var/recharge_cd_length = 30 SECONDS
	/// How long it takes between injections
	var/injection_cd_length = 5 SECONDS
	/// Cooldown between chem recharges
	COOLDOWN_DECLARE(recharge_cooldown)
	/// Cooldown between chem injections
	COOLDOWN_DECLARE(injection_cooldown)

/obj/machinery/wall_healer/Initialize(mapload)
	. = ..()
	init_reagent_containers()
	if(mapload)
		fill_reagent_containers()
	init_payment()

/obj/machinery/wall_healer/Destroy()
	clear_using_mob()
	QDEL_NULL(brute_healing)
	QDEL_NULL(burn_healing)
	QDEL_NULL(tox_healing)
	QDEL_NULL(blood_healing)
	QDEL_LAZYLIST(stocked_bandages)
	return ..()

/obj/machinery/wall_healer/proc/init_reagent_containers()
	brute_healing = new(30)
	burn_healing = new(30)
	tox_healing = new(30)
	blood_healing = new(30)

/obj/machinery/wall_healer/proc/fill_reagent_containers(percent = 100)
	// Handles already full containers for us, fortunately
	var/amount_refilled = 0
	amount_refilled += brute_healing.add_reagent(/datum/reagent/medicine/c2/libital, 30 * percent / 100)
	amount_refilled += burn_healing.add_reagent(/datum/reagent/medicine/c2/aiuri, 30 * percent / 100)
	amount_refilled += blood_healing.add_reagent(/datum/reagent/medicine/salglu_solution, 30 * percent / 100)
	amount_refilled += tox_healing.add_reagent(/datum/reagent/medicine/c2/syriniver, 30 * percent / 100)
	if(amount_refilled > 0)
		update_appearance()
	return amount_refilled

/obj/machinery/wall_healer/proc/init_payment()
	// Cost depends on service (so just use 0 here)
	AddComponent(/datum/component/payment, 0, SSeconomy.get_dep_account(ACCOUNT_MED), PAYMENT_FRIENDLY)
	desc += " This one charges by the second - better get your wallet ready."

/obj/machinery/wall_healer/examine(mob/user)
	. = ..()
	. += span_notice("It has [num_bandages + LAZYLEN(stocked_bandages)] bandage\s stocked. Remove a bandage with [EXAMINE_HINT("right-click")].")

/obj/machinery/wall_healer/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][is_operational ? "" : "_off"]"

/obj/machinery/wall_healer/update_overlays()
	. = ..()
	if(!is_operational)
		return

	var/brute_state = round(8 * (brute_healing.total_volume / brute_healing.maximum_volume), 1)
	var/burn_state = round(8 * (burn_healing.total_volume / burn_healing.maximum_volume), 1)
	var/tox_state = round(8 * (tox_healing.total_volume / tox_healing.maximum_volume), 1)
	var/blood_state = round(8 * (blood_healing.total_volume / blood_healing.maximum_volume), 1)

	var/mutable_appearance/brute = mutable_appearance(icon, "bar[brute_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	brute.color = /datum/reagent/medicine/c2/libital::color
	// no offset necessary

	var/mutable_appearance/burn = mutable_appearance(icon, "bar[burn_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	burn.color = /datum/reagent/medicine/c2/aiuri::color
	burn.pixel_z -= 2

	var/mutable_appearance/tox = mutable_appearance(icon, "bar[tox_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	tox.color = /datum/reagent/medicine/c2/syriniver::color
	tox.pixel_z -= 4

	var/mutable_appearance/blood = mutable_appearance(icon, "bar[blood_state]", alpha = src.alpha, appearance_flags = RESET_COLOR)
	blood.color = /datum/reagent/medicine/salglu_solution::color
	blood.pixel_z -= 6

	. += brute
	. += burn
	. += tox
	. += blood
	. += emissive_appearance(icon, "screen_emissive", src, alpha = src.alpha)
	. += emissive_appearance(icon, "bar_emissive", src, alpha = src.alpha)

/obj/machinery/wall_healer/emag_act(mob/user, obj/item/card/emag/emag_card)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/wall_healer/mouse_drop_receive(atom/dropped, mob/user, params)
	. = ..()
	if(.)
		return .
	if(!isliving(user) || !ishuman(dropped))
		return .
	var/mob/living/who_put_user_in = user
	var/mob/living/new_user = dropped
	if(!who_put_user_in.can_perform_action(src) || new_user.loc != loc)
		return .

	if(do_after(user, 1 SECONDS, src))
		user_put_in_other_hand(new_user, who_put_user_in)
	return TRUE

/obj/machinery/wall_healer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return .
	if(!ishuman(user))
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

/obj/machinery/wall_healer/proc/user_put_in_other_hand(mob/living/user, mob/living/who_put_user_in)
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
	if(. != SECONDARY_ATTACK_CALL_NORMAL)
		return .
	if(!is_operational)
		to_chat(user, span_notice("You try to retrieve some gauze, but [src] doesn't respond."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(num_bandages + LAZYLEN(stocked_bandages) <= 0)
		to_chat(user, span_notice("You try to retrieve some gauze, but [src] seems to be out of stock."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(attempt_charge(user, src, extra_fees = round(per_bandage_cost, 1)) & COMPONENT_OBJ_CANCEL_CHARGE)
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
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/wall_healer/on_deconstruction(disassembled)
	var/atom/drop_loc = drop_location()
	for(var/obj/item/stack/medical/gauze/bandage as anything in stocked_bandages)
		bandage.forceMove(drop_loc)
	new /obj/item/stack/medical/gauze(drop_loc, num_bandages)

/obj/machinery/wall_healer/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/medical/gauze))
		return NONE

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
	last_user_ref = null

	current_user = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(user_moved))
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(clear_using_mob))

	// melbert todo : decide if simplemobs are allowed
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

/obj/machinery/wall_healer/attempt_charge(atom/sender, atom/target, extra_fees)
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		return NONE
	return ..()

/obj/machinery/wall_healer/process()
	if(!is_operational)
		COOLDOWN_START(src, recharge_cooldown, recharge_cd_length * 0.5)
		return
	if(isnull(current_user))
		if(COOLDOWN_FINISHED(src, recharge_cooldown) && fill_reagent_containers(10))
			COOLDOWN_START(src, recharge_cooldown, recharge_cd_length)
			playsound(src, 'sound/machines/defib/defib_ready.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	if(!COOLDOWN_FINISHED(src, injection_cooldown))
		injection_bar.update(COOLDOWN_TIMELEFT(src, injection_cooldown))
		return

	COOLDOWN_START(src, injection_cooldown, injection_cd_length)
	injection_bar.update(0)

	if(obj_flags & EMAGGED)
		current_user.apply_damage(33, BRUTE, current_hand, sharpness = SHARP_POINTY)
		playsound(src, 'sound/machines/defib/defib_failed.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(current_user, span_warning("You feel a sharp pain as the machine malfunctions, stabbing you with several needles!"))
		return

	var/need_brute = current_user.getBruteLoss() && !current_user.has_reagent(/datum/reagent/medicine/c2/libital)
	var/need_burn = current_user.getFireLoss() && !current_user.has_reagent(/datum/reagent/medicine/c2/aiuri)
	var/need_blood = !HAS_TRAIT(current_user, TRAIT_NOBLOOD) && current_user.blood_volume < BLOOD_VOLUME_OKAY && !current_user.has_reagent(/datum/reagent/medicine/salglu_solution)
	var/need_tox = current_user.getToxLoss() && !current_user.has_reagent(/datum/reagent/medicine/c2/syriniver)

	var/cost = round(per_injection_cost * per_injection * (need_brute + need_burn + need_blood + need_tox), 1)
	if(attempt_charge(current_user, src, extra_fees = cost) & COMPONENT_OBJ_CANCEL_CHARGE)
		playsound(src, 'sound/machines/defib/defib_saftyOff.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	var/amount_injected = 0
	if(need_brute)
		amount_injected += brute_healing.trans_to(current_user, per_injection, methods = INJECT)
	if(need_burn)
		amount_injected += burn_healing.trans_to(current_user, per_injection, methods = INJECT)
	if(need_blood)
		amount_injected += blood_healing.trans_to(current_user, per_injection, methods = INJECT)
	if(need_tox)
		amount_injected += tox_healing.trans_to(current_user, per_injection, methods = INJECT)

	if(amount_injected)
		playsound(src, 'sound/machines/defib/defib_SaftyOn.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(current_user, span_notice("Several syringes inject you with healing chemicals. You feel better, though a bit tingly."))
	else
		playsound(src, 'sound/machines/defib/defib_saftyOff.ogg', 50, FALSE, SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(current_user, span_notice("Nothing seems to happen."))

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/wall_healer, 32)

/obj/machinery/wall_healer/free
	name = "\improper Deforest Emergency First Aid Station"

/obj/machinery/wall_healer/free/init_payment()
	desc += " This one doesn't charge by the second."

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/wall_healer/free, 32)
