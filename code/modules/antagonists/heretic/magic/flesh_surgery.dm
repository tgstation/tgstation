/datum/action/cooldown/spell/touch/flesh_surgery
	name = "Knit Flesh"
	desc = "A touch spell that allows you to either harvest or restore flesh of target. \
		Left-clicking will extract the organs of a victim without needing to complete surgery or disembowel. \
		Right-clicking, if done on summons or minions, will restore health. Can also be used to heal damaged organs."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS
	invocation = "CL'M M'N!" // "CLAIM MINE", but also almost "KALI MA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/flesh_surgery
	can_cast_on_self = TRUE

	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5

/datum/action/cooldown/spell/touch/flesh_surgery/is_valid_target(atom/cast_on)
	return isliving(cast_on) || isorgan(cast_on)

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		return heal_organ(hand, victim, caster)

	if(isliving(victim))
		return steal_organ_from_mob(hand, victim, caster)

	return FALSE

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_secondary_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		return SECONDARY_ATTACK_CALL_NORMAL

	if(isliving(victim))
		var/mob/living/mob_victim = victim
		if(mob_victim.stat == DEAD || !IS_HERETIC_MONSTER(mob_victim))
			return SECONDARY_ATTACK_CALL_NORMAL

		if(heal_heretic_monster(hand, mob_victim, caster))
			return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/datum/action/cooldown/spell/touch/flesh_surgery/register_hand_signals()
	. = ..()
	RegisterSignal(attached_hand, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))
	attached_hand.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS

/datum/action/cooldown/spell/touch/flesh_surgery/unregister_hand_signals()
	. = ..()
	UnregisterSignal(attached_hand, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET)

/// Signal proc for [COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET] to add some context to the hand.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/add_item_context(obj/item/melee/touch_attack/source, list/context, atom/victim, mob/living/user)
	SIGNAL_HANDLER

	. = NONE

	if(isliving(victim))
		var/mob/living/mob_victim = victim

		if(iscarbon(mob_victim))
			context[SCREENTIP_CONTEXT_LMB] = "Extract organ"
			. = CONTEXTUAL_SCREENTIP_SET

		if(IS_HERETIC_MONSTER(mob_victim))
			context[SCREENTIP_CONTEXT_RMB] = "Heal [ishuman(mob_victim) ? "minion" : "summon"]"
			. = CONTEXTUAL_SCREENTIP_SET

	else if(isorgan(victim))
		context[SCREENTIP_CONTEXT_LMB] = "Heal organ"
		. = CONTEXTUAL_SCREENTIP_SET

	return .

/// If cast on an organ, we'll restore it's health and even un-fail it.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_organ(obj/item/melee/touch_attack/hand, obj/item/organ/to_heal, mob/living/carbon/caster)
	if(to_heal.damage == 0)
		to_heal.balloon_alert(caster, "already in good condition!")
		return FALSE
	to_heal.balloon_alert(caster, "healing organ...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "interrupted!")
		return FALSE

	var/organ_hp_to_heal = to_heal.maxHealth * organ_percent_healing
	to_heal.set_organ_damage(max(0 , to_heal.damage - organ_hp_to_heal))
	to_heal.balloon_alert(caster, "organ healed")
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	var/condition = (to_heal.damage > 0) ? "better" : "perfect"
	caster.visible_message(
		span_warning("[caster]'s hand glows a brilliant red as [caster.p_they()] restore \the [to_heal] to [condition] condition!"),
		span_notice("Your hand glows a brilliant red as you restore \the [to_heal] to [condition] condition!"),
	)

	return TRUE

/// If cast on a heretic monster who's not dead we'll heal it a bit.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_heretic_monster(obj/item/melee/touch_attack/hand, mob/living/to_heal, mob/living/carbon/caster)
	var/what_are_we = ishuman(to_heal) ? "minion" : "summon"
	to_heal.balloon_alert(caster, "healing [what_are_we]...")
	if(!do_after(caster, 1 SECONDS, to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "interrupted!")
		return FALSE

	// Keep in mind that, for simplemobs(summons), this will just flat heal the combined value of both brute and burn healing,
	// while for human minions(ghouls), this will heal brute and burn like normal. So be careful adjusting to bigger numbers
	to_heal.balloon_alert(caster, "[what_are_we] healed")
	to_heal.heal_overall_damage(monster_brute_healing, monster_burn_healing)
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		span_warning("[caster]'s hand glows a brilliant red as [caster.p_they()] restore[caster.p_s()] [to_heal] to good condition!"),
		span_notice("Your hand glows a brilliant red as you restore [to_heal] to good condition!"),
	)
	return TRUE

/// If cast on a carbon, we'll try to steal one of their organs directly from their person.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/steal_organ_from_mob(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/carbon/carbon_victim = victim
	if(!istype(carbon_victim) || !length(carbon_victim.organs))
		victim.balloon_alert(caster, "no organs!")
		return FALSE

	// Round u pto the nearest generic zone (body, chest, arm)
	var/zone_to_check = check_zone(caster.zone_selected)
	var/parsed_zone = victim.parse_zone_with_bodypart(zone_to_check)

	var/list/organs_we_can_remove = list()
	for(var/obj/item/organ/organ as anything in carbon_victim.organs)
		// Only show organs which are in our generic zone
		if(deprecise_zone(organ.zone) != zone_to_check)
			continue
		// Also, some organs to exclude. Don't remove vital (brains), don't remove synthetics, and don't remove unremovable
		if(organ.organ_flags & (ORGAN_ROBOTIC|ORGAN_VITAL|ORGAN_UNREMOVABLE))
			continue

		organs_we_can_remove[organ.name] = organ

	if(!length(organs_we_can_remove))
		victim.balloon_alert(caster, "no organs there!")
		return FALSE

	var/chosen_organ = tgui_input_list(caster, "Which organ do you want to extract?", name, sort_list(organs_we_can_remove))
	if(isnull(chosen_organ))
		return FALSE
	var/obj/item/organ/picked_organ = organs_we_can_remove[chosen_organ]
	if(!istype(picked_organ) || !extraction_checks(picked_organ, hand, victim, caster))
		return FALSE

	// Don't let people stam crit into steal heart true combo
	var/time_it_takes = carbon_victim.stat == DEAD ? 3 SECONDS : 15 SECONDS

	// Sure you can remove your own organs, fun party trick
	if(carbon_victim == caster)
		var/are_you_sure = tgui_alert(caster, "Are you sure you want to remove your own [chosen_organ]?", "Are you sure?", list("Yes", "No"))
		if(are_you_sure != "Yes" || !extraction_checks(picked_organ, hand, victim, caster))
			return FALSE

		time_it_takes = 6 SECONDS
		caster.visible_message(
			span_danger("[caster]'s hand glows a brilliant red as [caster.p_they()] reach[caster.p_es()] directly into [caster.p_their()] own [parsed_zone]!"),
			span_userdanger("Your hand glows a brilliant red as you reach directly into your own [parsed_zone]!"),
		)

	else
		carbon_victim.visible_message(
			span_danger("[caster]'s hand glows a brilliant red as [caster.p_they()] reach[caster.p_es()] directly into [carbon_victim]'s [parsed_zone]!"),
			span_userdanger("[caster]'s hand glows a brilliant red as [caster.p_they()] reach[caster.p_es()] directly into your [parsed_zone]!"),
		)

	carbon_victim.balloon_alert(caster, "extracting [chosen_organ]...")
	playsound(victim, 'sound/weapons/slice.ogg', 50, TRUE)
	carbon_victim.add_atom_colour(COLOR_DARK_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, carbon_victim, extra_checks = CALLBACK(src, PROC_REF(extraction_checks), picked_organ, hand, victim, caster)))
		carbon_victim.balloon_alert(caster, "interrupted!")
		carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
		return FALSE

	// Visible message done before Remove()
	// Mainly so it gets across if you're taking the eyes of someone who's conscious
	if(carbon_victim == caster)
		caster.visible_message(
			span_bolddanger("[caster] pulls [caster.p_their()] own [chosen_organ] out of [caster.p_their()] [parsed_zone]!!"),
			span_userdanger("You pull your own [chosen_organ] out of your [parsed_zone]!!"),
		)

	else
		carbon_victim.visible_message(
			span_bolddanger("[caster] pulls [carbon_victim]'s [chosen_organ] out of [carbon_victim.p_their()] [parsed_zone]!!"),
			span_userdanger("[caster] pulls your [chosen_organ] out of your [parsed_zone]!!"),
		)

	picked_organ.Remove(carbon_victim)
	carbon_victim.balloon_alert(caster, "[chosen_organ] removed")
	carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	playsound(victim, 'sound/effects/dismember.ogg', 50, TRUE)
	if(carbon_victim.stat == CONSCIOUS)
		carbon_victim.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/speech/slurring/heretic)
		carbon_victim.emote("scream")

	// We need to wait for the spell to actually finish casting to put the organ in their hands, hence, 1 ms timer.
	addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob, put_in_hands), picked_organ), 0.1 SECONDS)
	return TRUE

/// Extra checks ran while we're extracting an organ to make sure we can continue to do.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/extraction_checks(obj/item/organ/picked_organ, obj/item/melee/touch_attack/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(picked_organ) || QDELETED(victim) || !IsAvailable())
		return FALSE

	return TRUE

/// Extra checks ran while we're healing something (organ, mob).
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_checks(obj/item/melee/touch_attack/hand, atom/healing, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(healing) || !IsAvailable())
		return FALSE

	return TRUE

/obj/item/melee/touch_attack/flesh_surgery
	name = "\improper knit flesh"
	desc = "Let's go practice medicine."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
