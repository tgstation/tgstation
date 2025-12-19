/datum/martial_art/kaza_ruk
	name = "Kaza Ruk"
	id = MARTIALART_KAZA_RUK
	grab_damage_modifier = 5
	grab_escape_chance_modifier = -10
	VAR_PRIVATE/datum/action/neck_chop/neckchop
	VAR_PRIVATE/datum/action/low_sweep/lowsweep
	VAR_PRIVATE/datum/action/lung_punch/lungpunch

/datum/martial_art/kaza_ruk/activate_style(mob/living/new_holder)
	. = ..()
	RegisterSignal(new_holder, COMSIG_HUMAN_PUNCHED, PROC_REF(blow_followup))

/datum/martial_art/kaza_ruk/deactivate_style(mob/living/old_holder)
	. = ..()
	UnregisterSignal(old_holder, COMSIG_HUMAN_PUNCHED)

/datum/martial_art/kaza_ruk/New()
	. = ..()
	neckchop = new(src)
	lowsweep = new(src)
	lungpunch = new(src)

/datum/martial_art/kaza_ruk/Destroy()
	neckchop = null
	lowsweep = null
	lungpunch = null
	return ..()

/datum/action/neck_chop
	name = "Neck Chop"
	desc = "Injures the neck, stopping the victim from speaking for a while."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "neckchop"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/neck_chop/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == "neck_chop")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.balloon_alert(owner, "cleared")
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Neck Chop stance!"), "<b><i>Your next attack will be a Neck Chop.</i></b>")
		owner.balloon_alert(owner, "neck chop")
		source.streak = "neck_chop"

/datum/action/low_sweep
	name = "Low Sweep"
	desc = "Trips the victim, knocking them down for a brief moment."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "legsweep"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/low_sweep/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == "low_sweep")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.balloon_alert(owner, "cleared")
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Low Sweep stance!"), "<b><i>Your next attack will be a Low Sweep.</i></b>")
		owner.balloon_alert(owner, "low sweep")
		source.streak = "low_sweep"

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch"
	desc = "Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "lungpunch"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS

/datum/action/lung_punch/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	var/datum/martial_art/source = target
	if (source.streak == "quick_choke")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.balloon_alert(owner, "cleared")
		source.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Lung Punch stance!"), "<b><i>Your next attack will be a Lung Punch.</i></b>")
		owner.balloon_alert(owner, "lung punch")
		source.streak = "quick_choke"//internal name for lung punch

/datum/martial_art/kaza_ruk/activate_style(mob/living/new_holder)
	. = ..()
	to_chat(new_holder, span_userdanger("You know the arts of [name]!"))
	to_chat(new_holder, span_danger("Place your cursor over a move at the top of the screen to see what it does."))
	neckchop.Grant(new_holder)
	lowsweep.Grant(new_holder)
	lungpunch.Grant(new_holder)

/datum/martial_art/kaza_ruk/deactivate_style(mob/living/remove_from)
	to_chat(remove_from, span_userdanger("You suddenly forget the arts of [name]..."))
	neckchop?.Remove(remove_from)
	lowsweep?.Remove(remove_from)
	lungpunch?.Remove(remove_from)
	return ..()

/datum/martial_art/kaza_ruk/proc/check_streak(mob/living/attacker, mob/living/defender)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(attacker, defender)
			return TRUE
		if("low_sweep")
			streak = ""
			low_sweep(attacker, defender)
			return TRUE
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(attacker, defender)
			return TRUE
	return FALSE

/datum/martial_art/kaza_ruk/proc/low_sweep(mob/living/attacker, mob/living/defender)
	if(defender.stat != CONSCIOUS || defender.IsParalyzed())
		return MARTIAL_ATTACK_INVALID
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		return MARTIAL_ATTACK_INVALID // Does 5 damage, so we can't let pacifists leg sweep.

	var/tail_sweeping = FALSE
	var/sweeping_language = "leg"
	if(ishuman(attacker))
		var/mob/living/carbon/possible_human = attacker
		var/obj/item/organ/tail/lizard/possible_lizard_tail = possible_human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
		if(possible_lizard_tail)
			tail_sweeping = TRUE
			sweeping_language = "tail"

	defender.visible_message(
		span_warning("[attacker] [sweeping_language] sweeps [defender]!"),
		span_userdanger("Your legs are sweeped by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You [sweeping_language] sweep [defender]!"))
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)

	if(tail_sweeping)
		attacker.emote("spin")

	defender.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
	defender.Knockdown(6 SECONDS)
	log_combat(attacker, defender, "leg sweeped")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/kaza_ruk/proc/quick_choke(mob/living/attacker, mob/living/defender)//is actually lung punch
	attacker.do_attack_animation(defender)
	defender.visible_message(
		span_warning("[attacker] pounds [defender] on the chest!"),
		span_userdanger("Your chest is slammed by [attacker]! You can't breathe!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You pound [defender] on the chest!"))
	playsound(attacker, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	if(defender.losebreath <= 10)
		defender.losebreath = clamp(defender.losebreath + 5, 0, 10)
	defender.adjust_oxy_loss(10)
	log_combat(attacker, defender, "quickchoked")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/kaza_ruk/proc/neck_chop(mob/living/attacker, mob/living/defender)
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		return MARTIAL_ATTACK_INVALID // Does 10 damage, so we can't let pacifists neck chop.
	attacker.do_attack_animation(defender)
	defender.visible_message(
		span_warning("[attacker] karate chops [defender]'s neck!"),
		span_userdanger("Your neck is karate chopped by [attacker], rendering you unable to speak!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You karate chop [defender]'s neck, rendering [defender.p_them()] unable to speak!"))
	playsound(attacker, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	defender.apply_damage(10, attacker.get_attack_type(), BODY_ZONE_HEAD)
	defender.adjust_silence_up_to(20 SECONDS, 20 SECONDS)
	log_combat(attacker, defender, "neck chopped")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/kaza_ruk/harm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 10, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	return MARTIAL_ATTACK_INVALID

/datum/martial_art/kaza_ruk/disarm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	var/obj/item/stuff_in_hand = defender.get_active_held_item()
	if(prob(60) && stuff_in_hand && defender.temporarilyRemoveItemFromInventory(stuff_in_hand))
		attacker.put_in_hands(stuff_in_hand)
		defender.visible_message(
			span_danger("[attacker] disarms [defender]!"),
			span_userdanger("You're disarmed by [attacker]!"),
			span_hear("You hear aggressive shuffling!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("You disarm [defender]!"))
		playsound(defender, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
		log_combat(attacker, defender, "disarmed (Kaza Ruk)", addition = "(disarmed of [stuff_in_hand])")
	return MARTIAL_ATTACK_INVALID // normal shove

/// First, determine if we're going to execute our followup attack

/datum/martial_art/kaza_ruk/proc/blow_followup(mob/living/source, mob/living/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	SIGNAL_HANDLER

	if(!prob(50))
		return

	addtimer(CALLBACK(src, PROC_REF(execute_followup), source, target, damage, attack_type, affecting, final_armor_block, kicking, limb_sharpness), 0.25 SECONDS)

/// After our delay, do the followup.

/datum/martial_art/kaza_ruk/proc/execute_followup(mob/living/source, mob/living/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	if(QDELETED(source) || QDELETED(target))
		return

	if(!source.Adjacent(target))
		return

	var/tail_usage = FALSE
	var/kick_language = "an axe kick"
	var/strike_language = "an elbow strike"
	if(ishuman(source))
		var/mob/living/carbon/possible_human = source
		var/obj/item/organ/tail/lizard/possible_lizard_tail = possible_human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
		if(possible_lizard_tail)
			tail_usage = TRUE
			kick_language = "a helmsplitter tail strike"
			strike_language = "a whiplash tail spin"

	source.visible_message(
		span_warning("[source] follows up with [kicking ? kick_language : strike_language] against [target]!"),
		span_notice("You deliver [kicking ? kick_language : strike_language] against [target]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
	)
	if(tail_usage)
		source.emote(kicking ? "flip" : "spin")
	playsound(source, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	source.do_attack_animation(target, ATTACK_EFFECT_KICK)
	target.apply_damage(round(damage/3,1), attack_type, affecting, final_armor_block, wound_bonus = damage) //Ostensibly, apply a third of our damage again // We're not being too fussy about limb bonuses for this
	log_combat(source, target, "auto-followup strike (Kaza Ruk)")

//Kaza Ruk Gloves

/obj/item/clothing/gloves/kaza_ruk
	abstract_type = /obj/item/clothing/gloves/kaza_ruk
	clothing_traits = list(TRAIT_FAST_CUFFING)

/obj/item/clothing/gloves/kaza_ruk/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/kaza_ruk)

/datum/atom_skin/kaza_ruk
	abstract_type = /datum/atom_skin/kaza_ruk
	reset_missing = FALSE
	/// Color (/matrix) applied with the skin. If null, no color is applied.
	var/reskin_color

/datum/atom_skin/kaza_ruk/apply(atom/apply_to)
	. = ..()
	if(reskin_color)
		apply_to.add_atom_colour(color_matrix_filter(reskin_color), FIXED_COLOUR_PRIORITY)

/datum/atom_skin/kaza_ruk/clear_skin(atom/clear_from)
	. = ..()
	if(reskin_color)
		clear_from.remove_atom_colour(FIXED_COLOUR_PRIORITY, reskin_color)

/datum/atom_skin/kaza_ruk/get_preview_icon(atom/for_atom)
	var/image/generated = ..()
	if(reskin_color)
		generated.add_filter("preview_filter", 1, color_matrix_filter(reskin_color))
	return generated

/datum/atom_skin/kaza_ruk/red
	preview_name = "Red"

/datum/atom_skin/kaza_ruk/blue
	preview_name = "Blue"
	reskin_color = list(0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1)

/obj/item/clothing/gloves/kaza_ruk/sec//more obviously named, given to sec
	name = "kaza ruk gloves"
	desc = "These gloves seem to guide you through a non-lizardperson friendly variant of the Tiziran martial art, Kaza Ruk. \
		You're not entirely sure how they do that. Probably nanites."
	icon_state = "fightgloves"
	greyscale_colors = "#c41e0d"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/kaza_ruk/sec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/kaza_ruk, infinite = TRUE)

/obj/item/clothing/gloves/kaza_ruk/combatglovesplus
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and electrically insulated. These gloves seem to guide you through a non-lizardperson friendly variant of the Tiziran martial art, Kaza Ruk."
	icon_state = "black"
	greyscale_colors = "#2f2e31"
	siemens_coefficient = 0
	strip_delay = 8 SECONDS
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	armor_type = /datum/armor/kaza_ruk_combatglovesplus

/datum/armor/kaza_ruk_combatglovesplus
	bio = 90
	fire = 80
	acid = 50
