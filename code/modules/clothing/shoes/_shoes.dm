/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/shoes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/shoes_righthand.dmi'
	desc = "Comfortable-looking shoes."
	pickup_sound = 'sound/items/handling/shoes/sneakers_pickup1.ogg'
	drop_sound = 'sound/items/handling/shoes/sneakers_drop1.ogg'
	equip_sound = 'sound/items/equip/sneakers_equip1.ogg'
	sound_vary = TRUE
	gender = PLURAL //Carn: for grammarically correct text-parsing
	clothing_flags = CLOTHING_MOD_OVERSLOTTING
	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET
	armor_type = /datum/armor/clothing_shoes
	slowdown = SHOES_SLOWDOWN
	strip_delay = 1 SECONDS
	article = "a pair of"

	var/offset = 0
	var/equipped_before_drop = FALSE
	/// How do these shoes stay on?
	var/fastening_type = SHOES_LACED

	///Are we currently tied? Can either be SHOES_UNTIED, SHOES_TIED, or SHOES_KNOTTED
	var/tied = SHOES_TIED
	///How long it takes to lace/unlace these shoes
	var/lace_time = 5 SECONDS
	///An active alert
	var/datum/weakref/our_alert_ref
	var/footprint_sprite = FOOTPRINT_SPRITE_SHOES

/datum/armor/clothing_shoes
	bio = 50

/obj/item/clothing/shoes/suicide_act(mob/living/carbon/user)
	if(prob(50))
		user.visible_message(span_suicide("[user] begins fastening \the [src] up waaay too tightly! It looks like [user.p_theyre()] trying to commit suicide!"))
		var/obj/item/bodypart/leg/left = user.get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/leg/right = user.get_bodypart(BODY_ZONE_R_LEG)
		if(left)
			left.dismember()
		if(right)
			right.dismember()
		playsound(user, SFX_DESECRATION, 50, TRUE, -1)
		return BRUTELOSS
	else//didnt realize this suicide act existed (was in miscellaneous.dm) and didnt want to remove it, so made it a 50/50 chance. Why not!
		user.visible_message(span_suicide("[user] is bashing [user.p_their()] own head in with [src]! Ain't that a kick in the head?"))
		for(var/i in 1 to 3)
			sleep(0.3 SECONDS)
			playsound(user, 'sound/items/weapons/genhit2.ogg', 50, TRUE)
		return BRUTELOSS

/obj/item/clothing/shoes/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damagedshoe")

/obj/item/clothing/shoes/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return
	if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		if(clothing_flags & LARGE_WORN_ICON)
			var/mutable_appearance/blood_overlay = mutable_appearance('icons/effects/64x64.dmi', "shoeblood_large")
			blood_overlay.color = get_blood_dna_color(GET_ATOM_BLOOD_DNA(src))
			. += blood_overlay
		else
			var/mutable_appearance/blood_overlay = mutable_appearance('icons/effects/blood.dmi', "shoeblood")
			blood_overlay.color = get_blood_dna_color(GET_ATOM_BLOOD_DNA(src))
			. += blood_overlay

/obj/item/clothing/shoes/examine(mob/user)
	. = ..()

	if(!ishuman(loc))
		return

	if(tied == SHOES_UNTIED)
		. += "The [fastening_type] are [untied_adjective()]."
	else if(tied == SHOES_KNOTTED)
		. += "The [fastening_type] are all knotted together."

/obj/item/clothing/shoes/visual_equipped(mob/user, slot)
	..()
	if(offset && (slot_flags & slot))
		user.pixel_z += offset
		worn_y_dimension -= (offset * 2)
		user.update_worn_shoes()
		equipped_before_drop = TRUE

/obj/item/clothing/shoes/equipped(mob/user, slot)
	. = ..()
	if(fastening_type != SHOES_SLIPON && tied == SHOES_UNTIED)
		our_alert_ref = WEAKREF(user.throw_alert(ALERT_SHOES_KNOT, /atom/movable/screen/alert/shoes/untied))
		RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, PROC_REF(check_trip), override=TRUE)

/obj/item/clothing/shoes/proc/restore_offsets(mob/user)
	equipped_before_drop = FALSE
	user.pixel_z -= offset
	worn_y_dimension = ICON_SIZE_Y

/obj/item/clothing/shoes/dropped(mob/user)
	var/atom/movable/screen/alert/our_alert = our_alert_ref?.resolve()
	if(!our_alert)
		our_alert_ref = null
	if(our_alert?.owner == user)
		user.clear_alert(ALERT_SHOES_KNOT)
	if(offset && equipped_before_drop)
		restore_offsets(user)
	. = ..()

/obj/item/clothing/shoes/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_shoes()

/obj/item/clothing/shoes/generate_digitigrade_icons(icon/base_icon, greyscale_colors)
	return icon(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/digitigrade, greyscale_colors), "boots_worn")

/**
 * adjust_laces adjusts whether our shoes (assuming they can be tied) and tied, untied, or knotted
 *
 * In addition to setting the state, it will deal with getting rid of alerts if they exist, as well as registering and unregistering the stepping signals
 *
 * Arguments:
 * *
 * * state: SHOES_UNTIED, SHOES_TIED, or SHOES_KNOTTED, depending on what you want them to become
 * * user: used to check to see if we're the ones unknotting our own laces
 * * force_lacing: boolean. if TRUE, ignores whether we actually have laces
 */
/obj/item/clothing/shoes/proc/adjust_laces(state, mob/user, force_lacing = FALSE)
	if(fastening_type == SHOES_SLIPON && !force_lacing)
		return

	var/mob/living/carbon/human/our_guy
	if(ishuman(loc))
		our_guy = loc

	tied = state
	if(tied == SHOES_TIED)
		if(our_guy)
			our_guy.clear_alert(ALERT_SHOES_KNOT)
		UnregisterSignal(src, COMSIG_SHOES_STEP_ACTION)
	else
		if(tied == SHOES_UNTIED && our_guy && user == our_guy)
			our_alert_ref = WEAKREF(our_guy.throw_alert(ALERT_SHOES_KNOT, /atom/movable/screen/alert/shoes/untied)) // if we're the ones unknotting our own laces, of course we know they're untied
		RegisterSignal(src, COMSIG_SHOES_STEP_ACTION, PROC_REF(check_trip), override=TRUE)

/**
 * handle_tying deals with all the actual tying/untying/knotting, inferring your intent from who you are in relation to the state of the laces
 *
 * If you're the wearer, you want them to move towards tied-ness (knotted -> untied -> tied). If you're not, you're pranking them, so you're moving towards knotted-ness (tied -> untied -> knotted)
 *
 * Arguments:
 * *
 * * user: who is the person interacting with the shoes?
 */
/obj/item/clothing/shoes/proc/handle_tying(mob/living/user)
	///our_guy here is the wearer, if one exists (and he must exist, or we don't care)
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy))
		return

	if (!isliving(user) || !(user.mobility_flags & MOBILITY_USE))
		return

	if(!in_range(user, our_guy))
		to_chat(user, span_warning("You aren't close enough to interact with [src]'s [fastening_type]!"))
		return

	if(user == loc && tied != SHOES_TIED) // if they're our own shoes, go tie-wards
		if(DOING_INTERACTION_WITH_TARGET(user, our_guy))
			to_chat(user, span_warning("You're already interacting with [src]!"))
			return
		user.visible_message(span_notice("[user] begins [tied ? "unknotting" : "[fastening_verb()]"] the [fastening_type] of [user.p_their()] [src.name]."), span_notice("You begin [tied ? "unknotting" : "[fastening_verb()]"] the [fastening_type] of your [src.name]..."))

		if(do_after(user, lace_time, target = our_guy, extra_checks = CALLBACK(src, PROC_REF(still_shoed), our_guy)))
			to_chat(user, span_notice("You [tied ? "unknot" : "[fasten_verb()]"] the [fastening_type] of your [src.name]."))
			if(tied == SHOES_UNTIED)
				adjust_laces(SHOES_TIED, user)
			else
				adjust_laces(SHOES_UNTIED, user)

	else // if they're someone else's shoes, go knot-wards
		if(user.body_position == STANDING_UP)
			to_chat(user, span_warning("You must be on the floor to interact with [src]!"))
			return
		if(tied == SHOES_KNOTTED)
			to_chat(user, span_warning("The [fastening_type] on [loc]'s [src.name] are already a hopelessly tangled mess!"))
			return
		if(DOING_INTERACTION_WITH_TARGET(user, our_guy))
			to_chat(user, span_warning("You're already interacting with [src]!"))
			return

		var/mod_time = lace_time
		to_chat(user, span_notice("You quietly set to work [tied ? "un[fastening_verb()]" : "knotting"] [loc]'s [src.name]..."))
		if(HAS_TRAIT(user, TRAIT_CLUMSY)) // based clowns trained their whole lives for this
			mod_time *= 0.75

		if(do_after(user, mod_time, target = our_guy, extra_checks = CALLBACK(src, PROC_REF(still_shoed), our_guy), hidden = TRUE))
			to_chat(user, span_notice("You [tied ? "un[fasten_verb()]" : "knot"] the [fastening_type] on [loc]'s [src.name]."))
			if(tied == SHOES_UNTIED)
				adjust_laces(SHOES_KNOTTED, user)
			else
				adjust_laces(SHOES_UNTIED, user)
		else // if one of us moved
			user.visible_message(span_danger("[our_guy] stamps on [user]'s hand, mid-[tied ? "knotting" : "un[fastening_verb()]"]!"), span_userdanger("Ow! [our_guy] stamps on your hand!"), list(our_guy))
			to_chat(our_guy, span_userdanger("You stamp on [user]'s hand! What the- [user.p_they()] [user.p_were()] [tied ? "knotting" : "un[fastening_verb()]"] your [fastening_type]!"))
			user.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
			user.apply_damage(10, BRUTE, user.get_active_hand(), wound_bonus = CANT_WOUND)
			user.apply_damage(40, STAMINA)
			user.Paralyze(1 SECONDS)

///checking to make sure we're still on the person we're supposed to be, for lacing do_after's
/obj/item/clothing/shoes/proc/still_shoed(mob/living/carbon/our_guy)
	return (loc == our_guy)

///check_trip runs on each step to see if we fall over as a result of our lace status. Knotted laces are a guaranteed trip, while untied shoes are just a chance to stumble
/obj/item/clothing/shoes/proc/check_trip()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/our_guy = loc
	if(!istype(our_guy)) // are they REALLY /our guy/?
		return

	if(tied == SHOES_KNOTTED)
		our_guy.Paralyze(5)
		our_guy.Knockdown(10)
		our_guy.visible_message(span_danger("[our_guy] trips on [our_guy.p_their()] knotted [fastening_type] and falls! What a klutz!"), span_userdanger("You trip on your knotted [fastening_type] and fall over!"))
		our_guy.add_mood_event("trip", /datum/mood_event/tripped) // well we realized they're knotted now!
		our_alert_ref = WEAKREF(our_guy.throw_alert(ALERT_SHOES_KNOT, /atom/movable/screen/alert/shoes/knotted))

	else if(tied == SHOES_UNTIED)
		var/wiser = TRUE // did we stumble and realize our laces are undone?
		switch(rand(1, 1000))
			if(1) // .1% chance to trip and fall over (note these are per step while our laces are undone)
				our_guy.Paralyze(5)
				our_guy.Knockdown(10)
				our_guy.add_mood_event("trip", /datum/mood_event/tripped) // well we realized they're knotted now!
				our_guy.visible_message(span_danger("[our_guy] trips on [our_guy.p_their()] [untied_adjective()] [fastening_type] and falls! What a klutz!"), span_userdanger("You trip on your [untied_adjective()] [fastening_type] and fall over!"))

			if(2 to 5) // .4% chance to stumble and lurch forward
				our_guy.throw_at(get_step(our_guy, our_guy.dir), 3, 2)
				to_chat(our_guy, span_danger("You stumble on your [untied_adjective()] [fastening_type] and lurch forward!"))

			if(6 to 13) // .7% chance to stumble and fling what we're holding
				var/have_anything = FALSE
				for(var/obj/item/I in our_guy.held_items)
					have_anything = TRUE
					our_guy.accident(I)
				to_chat(our_guy, span_danger("You trip on your [fastening_type] a bit[have_anything ? ", flinging what you were holding" : ""]!"))

			if(14 to 25) // 1.3ish% chance to stumble and be a bit off balance (like being disarmed)
				to_chat(our_guy, span_danger("You stumble a bit on your [untied_adjective()] [fastening_type]!"))
				our_guy.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH, 10 SECONDS)

			if(26 to 1000)
				wiser = FALSE
		if(wiser)
			our_guy.add_mood_event("untied", /datum/mood_event/untied) // well we realized they're untied now!
			our_alert_ref = WEAKREF(our_guy.throw_alert(ALERT_SHOES_KNOT, /atom/movable/screen/alert/shoes/untied))


/obj/item/clothing/shoes/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!istype(user))
		return ..()
	if(loc == user && tied != SHOES_TIED && (user.mobility_flags & MOBILITY_USE))
		handle_tying(user)
		return
	..()

/obj/item/clothing/shoes/attack_self(mob/user)
	. = ..()

	if (fastening_type == SHOES_SLIPON)
		return

	if(DOING_INTERACTION_WITH_TARGET(user, src))
		to_chat(user, span_warning("You're already interacting with [src]!"))
		return

	to_chat(user, span_notice("You begin [tied ? "un" : ""][fastening_verb()] the [fastening_type] on [src]..."))

	if(do_after(user, lace_time, target = src,extra_checks = CALLBACK(src, PROC_REF(still_shoed), user)))
		to_chat(user, span_notice("You [tied ? "un" : ""][fasten_verb()] the [fastening_type] on [src]."))
		adjust_laces(tied ? SHOES_UNTIED : SHOES_TIED, user)

/obj/item/clothing/shoes/apply_fantasy_bonuses(bonus)
	. = ..()
	slowdown = modify_fantasy_variable("slowdown", slowdown, -bonus * 0.1, 0)
	if(ismob(loc))
		var/mob/wearer = loc
		wearer.update_equipment_speed_mods()

/obj/item/clothing/shoes/remove_fantasy_bonuses(bonus)
	slowdown = reset_fantasy_variable("slowdown", slowdown)
	if(ismob(loc))
		var/mob/wearer = loc
		wearer.update_equipment_speed_mods()
	return ..()

/// Returns appropriate description for unfastened shoes
/obj/item/clothing/shoes/proc/untied_adjective()
	switch(fastening_type)
		if (SHOES_LACED)
			return "untied"
		if (SHOES_VELCRO, SHOES_STRAPS)
			return "loose"

	return "nonexistant"

/// Returns appropriate verb for how to fasten shoes
/obj/item/clothing/shoes/proc/fasten_verb()
	switch(fastening_type)
		if (SHOES_LACED)
			return "tie"
		if (SHOES_VELCRO, SHOES_STRAPS)
			return "fasten"

	return "do something mysterious to"

/// Returns appropriate verb for fastening shoes
/obj/item/clothing/shoes/proc/fastening_verb()
	switch(fastening_type)
		if (SHOES_LACED)
			return "tying"
		if (SHOES_VELCRO, SHOES_STRAPS)
			return "fastening"

	return "doing something mysterious to"
