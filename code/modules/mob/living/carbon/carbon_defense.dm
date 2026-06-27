#define SHAKE_ANIMATION_OFFSET 4

/mob/living/carbon/get_eye_protection()
	. = ..()
	if(is_blind() && !is_blind_from(list(UNCONSCIOUS_TRAIT, HYPNOCHAIR_TRAIT)))
		return INFINITY //For all my homies that can not see in the world
	var/obj/item/organ/eyes/eyes = get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes)
		. += eyes.flash_protect
	else
		return INFINITY //Can't get flashed without eyes
	if(isclothing(head)) //Adds head protection
		var/obj/item/clothing/helmet = head
		. += helmet.flash_protect
	if(isclothing(glasses)) //Glasses
		. += glasses.flash_protect
	if(isclothing(wear_mask)) //Mask
		. += wear_mask.flash_protect

/mob/living/carbon/sound_damage(damage, deafen)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	if(QDELETED(ears))
		return
	if(damage)
		ears.apply_organ_damage(damage * ears.damage_multiplier)
	if(deafen)
		ears.adjust_temporary_deafness(deafen)

/mob/living/carbon/get_ear_protection(ignore_deafness = FALSE)
	var/obj/item/organ/ears/ears = get_organ_slot(ORGAN_SLOT_EARS)
	return ..() + ears?.bang_protect

/mob/living/carbon/is_mouth_covered(check_flags = ALL)
	if((check_flags & ITEM_SLOT_HEAD) && head && (head.flags_cover & HEADCOVERSMOUTH))
		return head
	if((check_flags & ITEM_SLOT_MASK) && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH))
		return wear_mask

	return null

/mob/living/carbon/is_eyes_covered(check_flags = ALL)
	if((check_flags & ITEM_SLOT_HEAD) && head && (head.flags_cover & HEADCOVERSEYES))
		return head
	if((check_flags & ITEM_SLOT_MASK) && wear_mask && (wear_mask.flags_cover & MASKCOVERSEYES))
		return wear_mask
	if((check_flags & ITEM_SLOT_EYES) && glasses && (glasses.flags_cover & GLASSESCOVERSEYES))
		return glasses

	return null

/mob/living/carbon/is_pepper_proof(check_flags = ALL)
	var/obj/item/organ/eyes/eyes = get_organ_by_type(/obj/item/organ/eyes)
	if(eyes && eyes.pepperspray_protect)
		return eyes
	if((check_flags & ITEM_SLOT_HEAD) && head && (head.flags_cover & PEPPERPROOF))
		return head
	if((check_flags & ITEM_SLOT_MASK) && wear_mask && (wear_mask.flags_cover & PEPPERPROOF))
		return wear_mask

	return null

/mob/living/carbon/is_ears_covered()
	for(var/obj/item/worn_thing as anything in get_equipped_items(INCLUDE_ABSTRACT))
		if(worn_thing.flags_cover & EARS_COVERED)
			return worn_thing

	return null

/mob/living/carbon/check_projectile_dismemberment(obj/projectile/proj, def_zone)
	var/obj/item/bodypart/affecting = get_bodypart(def_zone)
	if(affecting && affecting.can_dismember() && !(affecting.bodypart_flags & BODYPART_UNREMOVABLE) && affecting.get_damage() >= (affecting.max_damage - proj.dismemberment))
		if(!affecting.dismember(proj.damtype) || !proj.catastropic_dismemberment)
			return
		apply_damage(proj.damage, proj.damtype, BODY_ZONE_CHEST, wound_bonus = proj.wound_bonus) //stops a projectile blowing off a limb effectively doing no damage. Mostly relevant for sniper rifles.

/mob/living/carbon/try_catch_item(obj/item/item, skip_throw_mode_check = FALSE, try_offhand = FALSE)
	. = ..()
	if(.)
		throw_mode_off(THROW_MODE_TOGGLE)

/mob/living/carbon/can_catch_item(skip_throw_mode_check = FALSE, try_offhand = FALSE)
	if(!skip_throw_mode_check && !throw_mode)
		return FALSE
	return ..()

/mob/living/carbon/hitby(atom/movable/movable, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(!skipcatch && try_catch_item(movable))
		return TRUE
	return ..()

/mob/living/carbon/send_item_attack_message(obj/item/weapon, mob/living/user, hit_area, def_zone)
	// In the future replace these with parent call if the item attack message proc is ever unshittified
	if(SEND_SIGNAL(weapon, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT, src, user) & SIGNAL_MESSAGE_MODIFIED)
		return TRUE
	if(SEND_SIGNAL(src, COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON, weapon, user) & SIGNAL_MESSAGE_MODIFIED)
		return TRUE

	if(!weapon.force && !length(weapon.attack_verb_simple) && !length(weapon.attack_verb_continuous))
		return
	var/obj/item/bodypart/hit_bodypart = get_bodypart(def_zone)
	if(isnull(hit_bodypart)) // ??
		return ..()

	// Sanity in case one is null for some reason
	var/picked_index = rand(max(length(weapon.attack_verb_simple), length(weapon.attack_verb_continuous)))

	var/message_verb_continuous = "attacks"
	var/message_verb_simple = "attack"
	var/message_hit_area = get_hit_area_message(hit_area)
	// Sanity in case one is... longer than the other?
	if (picked_index && length(weapon.attack_verb_continuous) >= picked_index)
		message_verb_continuous = weapon.attack_verb_continuous[picked_index]
	if (picked_index && length(weapon.attack_verb_simple) >= picked_index)
		message_verb_simple = weapon.attack_verb_simple[picked_index]

	var/extra_wound_details = ""

	if(weapon.damtype == BRUTE && hit_bodypart.can_dismember())

		var/mangled_state = hit_bodypart.get_mangled_state()

		var/bio_status = hit_bodypart.get_bio_state_status()

		var/has_exterior = ((bio_status & ANATOMY_EXTERIOR))
		var/has_interior = ((bio_status & ANATOMY_INTERIOR))

		var/exterior_ready_to_dismember = (!has_exterior || ((mangled_state & BODYPART_MANGLED_EXTERIOR)))
		var/interior_ready_to_dismember = (!has_interior || ((mangled_state & BODYPART_MANGLED_INTERIOR)))

		var/dismemberable = ((hit_bodypart.dismemberable_by_wound()) || hit_bodypart.dismemberable_by_total_damage())
		if (dismemberable)
			extra_wound_details = ", угрожая оторвать конечность!"
		else if((has_interior && (has_exterior && exterior_ready_to_dismember) && weapon.get_sharpness()))
			var/bone_text = hit_bodypart.get_internal_description()
			extra_wound_details = ", [weapon.get_sharpness() == SHARP_EDGED ? "прорезая" : "пронзая"] [bone_text]"
		else if(has_exterior && ((has_interior && interior_ready_to_dismember) && weapon.get_sharpness()))
			var/tissue_text = hit_bodypart.get_external_description()
			extra_wound_details = ", [weapon.get_sharpness() == SHARP_EDGED ? "прорезая" : "пронзая"] оставшуюся [tissue_text]"

	var/attack_message_spectator = "[capitalize(declent_ru(NOMINATIVE))] [ru_attack_verb(message_verb_continuous)][message_hit_area] с помощью [weapon.declent_ru(GENITIVE)][extra_wound_details]!"
	var/attack_message_victim = "Вас [ru_attack_verb(message_verb_continuous)][message_hit_area] с помощью [weapon.declent_ru(GENITIVE)][extra_wound_details]!"
	var/attack_message_attacker = "Вы [ru_attack_verb(message_verb_simple)] [declent_ru(ACCUSATIVE)][message_hit_area] с помощью [weapon.declent_ru(GENITIVE)][extra_wound_details]!"
	if(user in viewers(src, null))
		attack_message_spectator = "[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(message_verb_continuous)] [declent_ru(ACCUSATIVE)][message_hit_area] с помощью [weapon.declent_ru(GENITIVE)][extra_wound_details]!"
		attack_message_victim = "[capitalize(user.declent_ru(NOMINATIVE))] [ru_attack_verb(message_verb_continuous)] вас[message_hit_area] с помощью [weapon.declent_ru(GENITIVE)][extra_wound_details]!"
	if(user == src)
		attack_message_victim = "Вы [ru_attack_verb(message_verb_simple)] себя[message_hit_area] с помощью [weapon.declent_ru(GENITIVE)][extra_wound_details]!"
	visible_message(span_danger("[attack_message_spectator]"),\
		span_userdanger("[attack_message_victim]"), null, COMBAT_MESSAGE_RANGE, user)
	if(user != src)
		to_chat(user, span_danger("[attack_message_attacker]"))
	return TRUE


/mob/living/carbon/attack_drone(mob/living/basic/drone/user)
	return //so we don't call the carbon's attack_hand().

/mob/living/carbon/attack_drone_secondary(mob/living/basic/drone/user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/mob/living/carbon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()

	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
			user.ContactContractDisease(D)

	for(var/thing in user.diseases)
		var/datum/disease/D = thing
		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
			ContactContractDisease(D)

	if(.)
		return TRUE

	for(var/datum/wound/wounds as anything in all_wounds)
		if(wounds.try_handling(user))
			return TRUE

	return FALSE

/mob/living/carbon/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if (!user.combat_mode)
		for (var/datum/wound/wounds as anything in all_wounds)
			if (wounds.try_handling(user))
				return TRUE

	return ..()

/mob/living/carbon/attack_paw(mob/living/carbon/human/user, list/modifiers)

	if(try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		for(var/thing in diseases)
			var/datum/disease/D = thing
			if((D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN) && prob(85))
				user.ContactContractDisease(D)

	for(var/thing in user.diseases)
		var/datum/disease/D = thing
		if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
			ContactContractDisease(D)

	if(!user.combat_mode)
		help_shake_act(user)
		return FALSE

	if(..()) //successful monkey bite.
		for(var/thing in user.diseases)
			var/datum/disease/D = thing
			if(D.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
				continue
			ForceContractDisease(D)
		return TRUE

/**
 * Really weird proc that attempts to dismebmer the passed zone if it is at max damage
 * Unless the attacker is an NPC, in which case it disregards the zone and picks a random one
 *
 * Cannot dismember heads
 *
 * Returns a falsy value (null) on success, and a truthy value (the hit zone) on failure
 */
/mob/living/proc/dismembering_strike(mob/living/attacker, dam_zone)
	return dam_zone

/mob/living/carbon/dismembering_strike(mob/living/attacker, dam_zone)
	if(!attacker.limb_destroyer)
		return dam_zone
	var/obj/item/bodypart/affecting
	if(dam_zone && attacker.client)
		affecting = get_bodypart(get_random_valid_zone(dam_zone))
	else
		var/list/things_to_ruin = shuffle(bodyparts.Copy())
		for(var/obj/item/bodypart/bodypart as anything in things_to_ruin)
			if(bodypart.body_zone == BODY_ZONE_HEAD || bodypart.body_zone == BODY_ZONE_CHEST)
				continue
			if(!affecting || ((affecting.get_damage() / affecting.max_damage) < (bodypart.get_damage() / bodypart.max_damage)))
				affecting = bodypart

	if(affecting)
		dam_zone = affecting.body_zone
		if(affecting.get_damage() >= affecting.max_damage && affecting.dismember())
			return null

	return dam_zone

/mob/living/carbon/blob_act(obj/structure/blob/B)
	if (stat == DEAD)
		return
	else
		show_message(span_userdanger("Блоб атакует!"))
		adjust_brute_loss(10)

///Adds to the parent by also adding functionality to propagate shocks through pulling and doing some fluff effects.
/mob/living/carbon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 20 SECONDS, stutter_time = 4 SECONDS, stun_duration = 4 SECONDS)
	. = ..()
	if(!.)
		return
	//Propagation through pulling, fireman carry
	if(!(flags & SHOCK_ILLUSION))
		if(undergoing_cardiac_arrest())
			set_heartattack(FALSE)
		var/list/shocking_queue = list()
		if(iscarbon(pulling) && source != pulling)
			shocking_queue += pulling
		if(iscarbon(pulledby) && source != pulledby)
			shocking_queue += pulledby
		if(iscarbon(buckled) && source != buckled)
			shocking_queue += buckled
		for(var/mob/living/carbon/carried in buckled_mobs)
			if(source != carried)
				shocking_queue += carried
		//Found our victims, now lets shock them all
		for(var/victim in shocking_queue)
			var/mob/living/carbon/C = victim
			C.electrocute_act(shock_damage*0.75, src, 1, flags, jitter_time, stutter_time, stun_duration)
	//Stun
	var/should_stun = (!(flags & SHOCK_TESLA) || siemens_coeff > 0.5) && !(flags & SHOCK_NOSTUN)
	var/stun = !(flags & SHOCK_KNOCKDOWN)
	var/immediately_stun = should_stun && !(flags & SHOCK_DELAY_STUN)
	if (immediately_stun)
		if (stun)
			// intended effect here is to floor you immediately if you are shocked twice in quick succession
			// or to keep you floored if you are already incapacitated otherwise
			if(incapacitated)
				Paralyze(stun_duration)
			// otherwise it just stuns you upright - until the second shock, which floors you
			else
				Stun(stun_duration)
		else
			Knockdown(stun_duration)
	//Jitter and other fluff.
	do_jitter_animation(300)
	adjust_jitter(jitter_time)
	adjust_stutter(stutter_time)
	if (should_stun)
		addtimer(CALLBACK(src, PROC_REF(secondary_shock), stun, stun_duration * 1.5), 2 SECONDS)
	return shock_damage

///Called slightly after electrocute act to apply a secondary stun.
/mob/living/carbon/proc/secondary_shock(stun, stun_duration)
	if (stun)
		Paralyze(stun_duration)
	else
		Knockdown(stun_duration)

/// When another mob touches us, they may messy us up.
/mob/living/carbon/proc/share_blood_on_touch(mob/living/carbon/human/who_touched_us)
	return

/mob/living/carbon/human/share_blood_on_touch(mob/living/carbon/human/who_touched_us, messy_slots = ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING)
	if(!istype(who_touched_us) || !messy_slots)
		return

	for(var/obj/item/thing as anything in who_touched_us.get_equipped_items())
		if((thing.body_parts_covered & HANDS) && prob(GET_ATOM_BLOOD_DNA_LENGTH(thing) * 25))
			add_blood_DNA_to_items(GET_ATOM_BLOOD_DNA(thing), messy_slots)
			return

	if(prob(blood_in_hands * GET_ATOM_BLOOD_DNA_LENGTH(who_touched_us) * 10))
		add_blood_DNA_to_items(GET_ATOM_BLOOD_DNA(who_touched_us), messy_slots)
		who_touched_us.blood_in_hands -= 1

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/helper, force_friendly)
	if(on_fire)
		to_chat(helper, span_warning("Вы не можете потушить [ru_p_them()] просто вашими голыми руками!"))
		return

	if(SEND_SIGNAL(src, COMSIG_CARBON_PRE_MISC_HELP, helper) & COMPONENT_BLOCK_MISC_HELP)
		return

	if(helper == src)
		check_self_for_injuries()
		return

	if(body_position == LYING_DOWN)
		if(buckled)
			to_chat(helper, span_warning("Для начала вам нужно отстегнуть [declent_ru(ACCUSATIVE)]!"))
			return
		helper.visible_message(span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] трясет [declent_ru(ACCUSATIVE)], пытаясь [ru_p_them()] поднять!"), \
						null, span_hear("Вы слышите шорох одежды."), DEFAULT_MESSAGE_RANGE, list(helper, src))
		to_chat(helper, span_notice("Вы трясете [declent_ru(ACCUSATIVE)], пытаясь [ru_p_them()] поднять!"))
		to_chat(src, span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] трясет вас, чтобы вас поднять!"))
	else if(check_zone(helper.zone_selected) == BODY_ZONE_HEAD && get_bodypart(BODY_ZONE_HEAD)) //Headpats!
		helper.visible_message(span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] гладит [declent_ru(ACCUSATIVE)] по голове, чтобы поднять [ru_p_them()] настроение!"), \
					null, span_hear("Вы слышите тихое поглаживание."), DEFAULT_MESSAGE_RANGE, list(helper, src))
		to_chat(helper, span_notice("Вы гладите [declent_ru(ACCUSATIVE)] по голове, чтобы поднять [ru_p_them()] настроение!"))
		to_chat(src, span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] гладит вас по голове, чтобы поднять ваше настроение!"))

		share_blood_on_touch(helper, ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
		if(HAS_TRAIT(src, TRAIT_BADTOUCH))
			to_chat(helper, span_warning("[capitalize(declent_ru(NOMINATIVE))] выглядит заметно расстроенно, когда вы гладите [ru_p_them()] по голове."))

	else if ((helper.zone_selected == BODY_ZONE_PRECISE_GROIN) && !isnull(src.get_organ_by_type(/obj/item/organ/tail)))
		helper.visible_message(span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] дергает за хвост [declent_ru(GENITIVE)]!"), \
					null, span_hear("Вы слышите тихое поглаживание."), DEFAULT_MESSAGE_RANGE, list(helper, src))
		to_chat(helper, span_notice("Вы дергаете за хвост [declent_ru(GENITIVE)]!"))
		to_chat(src, span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] дергает вас за хвост!"))
		if(HAS_TRAIT(src, TRAIT_BADTOUCH)) //How dare they!
			to_chat(helper, span_warning("[capitalize(declent_ru(NOMINATIVE))] издает ворчащий звук, когда вы дергаете за [ru_p_them()] хвост!"))
		else
			add_mood_event("tailpulled", /datum/mood_event/tailpulled)

	else if ((helper.zone_selected == BODY_ZONE_PRECISE_GROIN) && (istype(head, /obj/item/clothing/head/costume/kitty) || istype(head, /obj/item/clothing/head/collectable/kitty)))
		var/obj/item/clothing/head/faketail = head
		helper.visible_message(span_danger("[capitalize(helper.declent_ru(NOMINATIVE))] дергает за хвост [declent_ru(GENITIVE)]... и хвост отрывается!"), \
					null, span_hear("Вы слышите звук разрыва."), DEFAULT_MESSAGE_RANGE, list(helper, src))
		to_chat(helper, span_danger("Вы дергаете за хвост [declent_ru(GENITIVE)]... и хвост отрывается!"))
		to_chat(src, span_userdanger("[capitalize(helper.declent_ru(NOMINATIVE))] дергает вас за хвост... и хвост отрывается!"))
		playsound(loc, 'sound/effects/cloth_rip.ogg', 75, TRUE)
		dropItemToGround(faketail)
		helper.put_in_hands(faketail)
		helper.add_mood_event("rippedtail", /datum/mood_event/rippedtail)

	else
		if (helper.grab_state >= GRAB_AGGRESSIVE)
			helper.visible_message(span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] заключает [declent_ru(ACCUSATIVE)] в крепких медвежьих объятиях!"), \
						null, span_hear("Вы слышите шорох одежды."), DEFAULT_MESSAGE_RANGE, list(helper, src))
			to_chat(helper, span_notice("Вы заключаете [declent_ru(ACCUSATIVE)] в крепких медвежьих объятиях!"))
			to_chat(src, span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] заключает вас в крепких медвежьих объятиях!"))
		else
			helper.visible_message(span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] обнимает [declent_ru(ACCUSATIVE)], чтобы поднять [ru_p_them()] настроение!"), \
						null, span_hear("Вы слышите шорох одежды."), DEFAULT_MESSAGE_RANGE, list(helper, src))
			to_chat(helper, span_notice("Вы обнимаете [declent_ru(ACCUSATIVE)], чтобы поднять [ru_p_them()] настроение!"))
			to_chat(src, span_notice("[capitalize(helper.declent_ru(NOMINATIVE))] обнимает вас, чтобы поднять ваше настроение!"))

		share_blood_on_touch(helper, ITEM_SLOT_HEAD|ITEM_SLOT_MASK|ITEM_SLOT_GLOVES)
		// Warm them up with hugs
		share_bodytemperature(helper)

		// No moodlets for people who hate touches
		if(!HAS_TRAIT(src, TRAIT_BADTOUCH))
			if (helper.grab_state >= GRAB_AGGRESSIVE)
				add_mood_event("hug", /datum/mood_event/bear_hug)
			else
				if(bodytemperature > helper.bodytemperature)
					if(!HAS_TRAIT(helper, TRAIT_BADTOUCH))
						helper.add_mood_event("hug", /datum/mood_event/warmhug, src) // Hugger got a warm hug (Unless they hate hugs)
					add_mood_event("hug", /datum/mood_event/hug) // Receiver always gets a mood for being hugged
				else
					add_mood_event("hug", /datum/mood_event/warmhug, helper) // You got a warm hug
		else
			if (helper.grab_state >= GRAB_AGGRESSIVE)
				add_mood_event("hug", /datum/mood_event/bad_touch_bear_hug)

		// Let people know if they hugged someone really warm or really cold
		if(helper.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
			to_chat(src, span_warning("Кажется, что [helper.declent_ru(NOMINATIVE)] в состоянии перегрева, когда [helper.ru_p_they()] обнимает вас."))
		else if(helper.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			to_chat(src, span_warning("Кажется, что [helper.declent_ru(NOMINATIVE)] в состоянии переохлаждения, когда [helper.ru_p_they()] обнимает вас."))

		if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
			to_chat(helper, span_warning("Кажется, что [declent_ru(NOMINATIVE)] в состоянии перегрева, когда вы обнимаете [ru_p_them()]."))
		else if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			to_chat(helper, span_warning("Кажется, что [declent_ru(NOMINATIVE)] в состоянии переохлаждения, когда вы обнимаете [ru_p_them()]."))

		if(HAS_TRAIT(helper, TRAIT_FRIENDLY) || force_friendly)
			if (helper.mob_mood.sanity >= SANITY_GREAT)
				new /obj/effect/temp_visual/heart(loc)
				add_mood_event("friendly_hug", /datum/mood_event/besthug, helper)
			else if (helper.mob_mood.sanity >= SANITY_DISTURBED)
				add_mood_event("friendly_hug", /datum/mood_event/betterhug, helper)

		if(HAS_TRAIT(src, TRAIT_BADTOUCH))
			to_chat(helper, span_warning("[capitalize(declent_ru(NOMINATIVE))] выглядит заметно расстроенно, когда вы обнимаете [ru_p_them()]."))

	SEND_SIGNAL(src, COMSIG_CARBON_HELP_ACT, helper)
	SEND_SIGNAL(helper, COMSIG_CARBON_HELPED, src)

	adjust_status_effects_on_shake_up()
	set_resting(FALSE)
	if(body_position != STANDING_UP && !resting && !buckled && !HAS_TRAIT(src, TRAIT_FLOORED))
		get_up(TRUE)

	playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)

	// Shake animation
	if (incapacitated)
		shake_up_animation()

/mob/proc/shake_up_animation()
		var/direction = prob(50) ? -1 : 1
		animate(src, pixel_w = SHAKE_ANIMATION_OFFSET * direction, time = 0.1 SECONDS, easing = QUAD_EASING | EASE_OUT, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)
		animate(pixel_w = SHAKE_ANIMATION_OFFSET * -2 * direction, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
		animate(pixel_w = SHAKE_ANIMATION_OFFSET * direction, time = 0.1 SECONDS, easing = QUAD_EASING | EASE_IN, flags = ANIMATION_RELATIVE)

/// Check ourselves to see if we've got any shrapnel, return true if we do. This is a much simpler version of what humans do, we only indicate we're checking ourselves if there's actually shrapnel
/mob/living/carbon/proc/check_self_for_injuries()
	if(stat >= UNCONSCIOUS)
		return

	var/embeds = FALSE
	for(var/obj/item/bodypart/limb as anything in get_bodyparts())
		for(var/obj/item/weapon as anything in limb.embedded_objects)
			if(!embeds)
				embeds = TRUE
				// this way, we only visibly try to examine ourselves if we have something embedded, otherwise we'll still hug ourselves :)
				visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] осматривает себя."), \
					span_notice("Вы проверяете себя на наличие осколков."), visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE)
			var/harmless = weapon.get_embed().is_harmless()
			var/stuck_wordage = harmless ? "застревает у вас на" : "впивается у вас в"
			var/embed_text = "\t <a href='byond://?src=[REF(src)];embedded_object=[REF(weapon)];embedded_limb=[REF(limb)]'> [icon2html(weapon, src)] [capitalize(weapon.declent_ru(NOMINATIVE))] [stuck_wordage] [limb.declent_ru(PREPOSITIONAL)]!</a>"
			if (harmless)
				to_chat(src, span_italics(span_notice(embed_text)))
			else
				to_chat(src, span_boldwarning(embed_text))
	return embeds

/mob/living/carbon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 25)
	if(SEND_SIGNAL(src, COMSIG_MOB_FLASH_OVERRIDE_CHECK, src) & FLASH_OVERRIDDEN) //Check for behavior overrides before doing the act itself. If we have a behavior override, we handle everything there and skip the rest
		return FLASH_COMPLETED

	var/obj/item/organ/eyes/eyes = get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes) //can't flash what can't see!
		return

	. = ..()

	var/damage = intensity - get_eye_protection()
	if(.) // we've been flashed
		if(visual)
			return

		switch(damage)
			if(1)
				to_chat(src, span_warning("Ваши глаза немного щиплет."))
				if(prob(40))
					eyes.apply_organ_damage(1)

			if(2)
				to_chat(src, span_warning("Ваши глаза горят."))
				eyes.apply_organ_damage(rand(2, 4))

			if(3 to INFINITY)
				to_chat(src, span_warning("Ваши глаза сильно зудят и горят!"))
				eyes.apply_organ_damage(rand(12, 16))

		if(eyes.damage > 10)
			adjust_temp_blindness(damage * 2 SECONDS)
			set_eye_blur_if_lower(damage * rand(6 SECONDS, 12 SECONDS))

			if(eyes.damage > eyes.low_threshold)
				if(!is_nearsighted_from(EYE_DAMAGE) && prob(eyes.damage - eyes.low_threshold))
					to_chat(src, span_warning("Ваши глаза начинают сильно гореть!"))
					eyes.apply_organ_damage(eyes.low_threshold)

				else if(!is_blind() && prob(eyes.damage - eyes.high_threshold))
					to_chat(src, span_warning("Вы ничего не видите!"))
					eyes.apply_organ_damage(eyes.maxHealth)

			else
				to_chat(src, span_warning("Ваши глаза начинают сильно болеть. Это не хорошо!"))
		return TRUE

	else if(damage == 0 && prob(20)) // just enough protection
		to_chat(src, span_notice("Что-то яркое вспыхивает в углу вашего зрения!"))

/mob/living/carbon/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/hit_clothes
		if(wear_mask)
			hit_clothes = wear_mask
		if(wear_neck)
			hit_clothes = wear_neck
		if(head)
			hit_clothes = head
		if(hit_clothes)
			hit_clothes.take_damage(damage_amount, damage_type, damage_flag, 0)

/mob/living/carbon/adjust_oxy_loss(amount, updating_health = TRUE, forced, required_biotype, required_respiration_type)
	if(!forced && HAS_TRAIT(src, TRAIT_NOBREATH))
		amount = min(amount, 0) //Prevents oxy damage but not healing

	. = ..()
	check_passout()

/mob/living/carbon/proc/get_interaction_efficiency(zone)
	var/obj/item/bodypart/limb = get_bodypart(zone)
	if(!limb)
		return

/mob/living/carbon/set_oxy_loss(amount, updating_health = TRUE, forced, required_biotype, required_respiration_type)
	. = ..()
	check_passout()

/**
* Check to see if we should be passed out from oxyloss
*/
/mob/living/carbon/proc/check_passout()
	var/mob_oxyloss = get_oxy_loss()
	if(mob_oxyloss >= OXYLOSS_PASSOUT_THRESHOLD && !HAS_TRAIT(src, TRAIT_NO_OXYLOSS_PASSOUT))
		if(!HAS_TRAIT_FROM(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	else if(mob_oxyloss < OXYLOSS_PASSOUT_THRESHOLD)
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)

/mob/living/carbon/get_organic_health()
	. = health
	for (var/obj/item/bodypart/limb as anything in get_bodyparts())
		if (!IS_ORGANIC_LIMB(limb))
			. += (limb.brute_dam * limb.body_damage_coeff) + (limb.burn_dam * limb.body_damage_coeff)

/mob/living/carbon/grabbedby(mob/living/user, supress_message = FALSE)
	if(user != src)
		return ..()

	var/obj/item/bodypart/grasped_part = get_bodypart(zone_selected)
	if(!grasped_part?.can_be_grasped())
		return
	var/starting_hand_index = active_hand_index
	if(starting_hand_index == grasped_part.held_index)
		to_chat(src, span_danger("Вы не можете прижать вашу [grasped_part.declent_ru(ACCUSATIVE)] ею же!"))
		return

	var/bleed_rate = grasped_part.cached_bleed_rate
	var/bleeding_text = (bleed_rate ? ", пытаясь остановить кровотечение" : "")
	to_chat(src, span_warning("Вы пытаетесь прижать [grasped_part.declent_ru(ACCUSATIVE)][bleeding_text]..."))
	if(!do_after(src, 0.75 SECONDS))
		to_chat(src, span_danger("У вас не получается прижать [grasped_part.declent_ru(ACCUSATIVE)]."))
		return

	var/obj/item/hand_item/self_grasp/grasp = new
	if(starting_hand_index != active_hand_index || !put_in_active_hand(grasp))
		to_chat(src, span_danger("У вас не получается прижать [grasped_part.declent_ru(ACCUSATIVE)]."))
		QDEL_NULL(grasp)
		return
	grasp.grasp_limb(grasped_part)

/// If TRUE, the owner of this bodypart can try grabbing it to slow bleeding, as well as various other effects.
/obj/item/bodypart/proc/can_be_grasped()
	if (cached_bleed_rate)
		return TRUE

	for (var/datum/wound/iterated_wound as anything in wounds)
		if (iterated_wound.wound_flags & CAN_BE_GRASPED)
			return TRUE

	return FALSE

/// an abstract item representing you holding your own limb to staunch the bleeding, see [/mob/living/carbon/proc/grabbedby] will probably need to find somewhere else to put this.
/obj/item/hand_item/self_grasp
	name = "self-grasp"
	desc = "Sometimes all you can do is slow the bleeding."
	icon_state = "latexballoon"
	inhand_icon_state = "nothing"
	slowdown = 0.5
	item_flags = DROPDEL | ABSTRACT | NOBLUDGEON | SLOWS_WHILE_IN_HAND | HAND_ITEM
	/// The bodypart we're staunching bleeding on, which also has a reference to us in [/obj/item/bodypart/var/grasped_by]
	var/obj/item/bodypart/grasped_part
	/// The carbon who owns all of this mess
	var/mob/living/carbon/user

/obj/item/hand_item/self_grasp/Destroy()
	if(user)
		to_chat(user, span_warning("Вы перестаете прижимать[grasped_part ? " [grasped_part.declent_ru(ACCUSATIVE)]" : "себя"]."))
		UnregisterSignal(user, COMSIG_QDELETING)
	if(grasped_part)
		UnregisterSignal(grasped_part, list(COMSIG_CARBON_REMOVE_LIMB, COMSIG_QDELETING))
		grasped_part.grasped_by = null
		grasped_part.refresh_bleed_rate()
	grasped_part = null
	user = null
	return ..()

/// The limb or the whole damn person we were grasping got deleted or dismembered, so we don't care anymore
/obj/item/hand_item/self_grasp/proc/qdel_void()
	SIGNAL_HANDLER
	qdel(src)

/// We've already cleared that the bodypart in question is bleeding in [the place we create this][/mob/living/carbon/proc/grabbedby], so set up the connections
/obj/item/hand_item/self_grasp/proc/grasp_limb(obj/item/bodypart/grasping_part)
	user = grasping_part.owner
	if(!istype(user))
		stack_trace("[src] attempted to try_grasp() with [isdatum(user) ? user.type : isnull(user) ? "null" : user] user")
		qdel(src)
		return

	grasped_part = grasping_part
	grasped_part.grasped_by = src
	grasped_part.refresh_bleed_rate()
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(qdel_void))
	RegisterSignals(grasped_part, list(COMSIG_CARBON_REMOVE_LIMB, COMSIG_QDELETING), PROC_REF(qdel_void))

	var/bleed_rate = grasped_part.cached_bleed_rate
	var/bleeding_text = (bleed_rate ? ", пытаясь остановить кровотечение" : "")
	user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] прижимает [grasped_part.declent_ru(ACCUSATIVE)] у себя[bleeding_text]."), span_notice("Вы крепко прижимаете [grasped_part.declent_ru(ACCUSATIVE)]."), vision_distance=COMBAT_MESSAGE_RANGE)
	playsound(get_turf(src), 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
	return TRUE

/// Randomise a body part and organ of this mob
/mob/living/carbon/proc/bioscramble(scramble_source)
	if(!(mob_biotypes & MOB_ORGANIC))
		return FALSE

	if (HAS_TRAIT(src, TRAIT_GENELESS))
		return FALSE

	if(flags_1 & HOLOGRAM_1)
		return FALSE

	if (run_armor_check(attack_flag = BIO, silent = TRUE) >= 100)
		to_chat(src, span_warning("Ваша броня поглощает воздействие от [scramble_source]!"))
		return FALSE

	if (!length(GLOB.bioscrambler_valid_organs) || !length(GLOB.bioscrambler_valid_parts))
		init_bioscrambler_lists()

	var/changed_something = FALSE
	var/obj/item/organ/new_organ = pick(GLOB.bioscrambler_valid_organs)
	var/obj/item/organ/replaced = get_organ_slot(initial(new_organ.slot))
	if ((!replaced || ORGAN_CAN_BE_BIOSCRAMBLED(replaced)) && get_bodypart(deprecise_zone(new_organ.zone)))
		changed_something = TRUE
		new_organ = new new_organ()
		new_organ.replace_into(src)
		new_organ.organ_flags |= ORGAN_MUTANT

	if (!HAS_TRAIT(src, TRAIT_NODISMEMBER))
		var/obj/item/bodypart/new_part = pick(GLOB.bioscrambler_valid_parts)
		var/obj/item/bodypart/picked_user_part = get_bodypart(initial(new_part.body_zone))
		if (picked_user_part && BODYPART_CAN_BE_BIOSCRAMBLED(picked_user_part))
			changed_something = TRUE
			new_part = new new_part()
			new_part.replace_limb(src)
			if (picked_user_part)
				qdel(picked_user_part)

	if (!changed_something)
		to_chat(src, span_notice("Ваше аугментированное тело защищает вас от: [scramble_source]!"))
		return FALSE
	update_body(TRUE)
	balloon_alert(src, "в вас что-то изменилось")
	return TRUE

/// Fill in the lists of things we can bioscramble into people
/mob/living/carbon/proc/init_bioscrambler_lists()
	var/list/body_parts = typesof(/obj/item/bodypart/chest) + typesof(/obj/item/bodypart/head) + subtypesof(/obj/item/bodypart/arm) + subtypesof(/obj/item/bodypart/leg)
	for(var/obj/item/bodypart/part as anything in body_parts)
		if(!is_type_in_typecache(part, GLOB.bioscrambler_parts_blacklist) && BODYPART_CAN_BE_BIOSCRAMBLED(part))
			continue
		body_parts -= part
	GLOB.bioscrambler_valid_parts = body_parts

	var/list/organs = subtypesof(/obj/item/organ)
	for(var/obj/item/organ/organ_type as anything in organs)
		if(!is_type_in_typecache(organ_type, GLOB.bioscrambler_organs_blacklist) && !(initial(organ_type.organ_flags) & ORGAN_ROBOTIC))
			continue
		organs -= organ_type
	GLOB.bioscrambler_valid_organs = organs

/mob/living/carbon/get_shove_flags(mob/living/shover, obj/item/weapon)
	. = ..()
	. |= SHOVE_CAN_STAGGER
	if(IsKnockdown() && !IsParalyzed() && HAS_TRAIT(src, TRAIT_DAZED))
		. |= SHOVE_CAN_KICK_SIDE
	if(HAS_TRAIT(src, TRAIT_NO_SIDE_KICK)) // added as an extra check, just in case
		. &= ~SHOVE_CAN_KICK_SIDE

#undef SHAKE_ANIMATION_OFFSET
