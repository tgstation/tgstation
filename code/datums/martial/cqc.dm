#define SLAM_COMBO "GH"
#define KICK_COMBO "HH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DG"
#define CONSECUTIVE_COMBO "DDH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	help_verb = "Remember The Basics"
	smashes_tables = TRUE
	display_combos = TRUE
	/// Weakref to a mob we're currently restraining (with grab-grab combo)
	VAR_PRIVATE/datum/weakref/restraining_mob
	/// Probability of successfully blocking attacks while on throw mode
	var/block_chance = 75

/datum/martial_art/cqc/activate_style(mob/living/new_holder)
	. = ..()
	RegisterSignal(new_holder, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_holder, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))

/datum/martial_art/cqc/deactivate_style(mob/living/remove_from)
	UnregisterSignal(remove_from, list(COMSIG_ATOM_ATTACKBY, COMSIG_LIVING_CHECK_BLOCK))
	return ..()

///Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/cqc/proc/on_attackby(mob/living/cqc_user, obj/item/attack_weapon, mob/attacker, list/modifiers)
	SIGNAL_HANDLER

	if(!istype(attack_weapon, /obj/item/melee/touch_attack))
		return
	if(!can_use(cqc_user))
		return
	combat_message(
		attacker = cqc_user,
		defender = attacker,
		to_attacker = "You twist [attacker]'s arm, sending [attacker.p_their()] [attack_weapon] back towards them!",
		to_blind_attacker = "You twist your assailant's arm, sending their hand back towards them!",
		to_defender = "Making sure to avoid your [attack_weapon], [cqc_user] twists your arm to send it right back at you!",
		to_blind_defender = "Making sure to avoid your [attack_weapon], your target twists your arm to send it right back at you!",
		to_viewers = "[cqc_user] twists [attacker]'s arm, sending their [attack_weapon] back towards them!",
		dangerous = TRUE,
	)
	var/obj/item/melee/touch_attack/touch_weapon = attack_weapon
	var/datum/action/cooldown/spell/touch/touch_spell = touch_weapon.spell_which_made_us?.resolve()
	if(!touch_spell)
		return
	INVOKE_ASYNC(touch_spell, TYPE_PROC_REF(/datum/action/cooldown/spell/touch, do_hand_hit), touch_weapon, attacker, attacker)
	return COMPONENT_NO_AFTERATTACK

/datum/martial_art/cqc/proc/check_block(mob/living/cqc_user, atom/movable/hitby, damage, attack_text, attack_type, ...)
	SIGNAL_HANDLER

	if(!can_use(cqc_user) || !cqc_user.throw_mode || INCAPACITATED_IGNORING(cqc_user, INCAPABLE_GRAB))
		return NONE
	if(attack_type == PROJECTILE_ATTACK)
		return NONE

	var/blocking_text = "block"
	var/blocking_text_s = "blocks"
	var/potential_block_chance = block_chance

	if(attack_type == OVERWHELMING_ATTACK)
		blocking_text = "dodge"
		blocking_text_s = "dodges"
		potential_block_chance = clamp(round(potential_block_chance / (attack_type == OVERWHELMING_ATTACK ? 2 : 1), 1), 0, 100)

	if(!prob(potential_block_chance))
		return NONE

	var/mob/living/attacker = GET_ASSAILANT(hitby)
	if(istype(attacker) && cqc_user.Adjacent(attacker))
		combat_message(
			attacker = cqc_user,
			defender = attacker,
			to_attacker = "You [blocking_text] [attack_text] and twist [attacker]'s arm behind [attacker.p_their()] back!",
			to_defender = "[cqc_user] [blocking_text_s] [attack_text] and twists your arm behind your back!",
			to_blind_attacker = "You [blocking_text] [attack_text] and twist your assailant's arm behind their back!",
			to_blind_defender = "Something stops your attack, and wrests your arm behind your back!",
			to_viewers = "[cqc_user] [blocking_text_s] [attack_text] and twists [attacker]'s arm behind [attacker.p_their()] back!",
			dangerous = FALSE,
		)
		attacker.Stun(4 SECONDS)
	else
		combat_message(
			attacker = cqc_user,
			defender = attacker,
			to_attacker = "You [blocking_text] [attack_text]!",
			to_defender = "[cqc_user] [blocking_text_s] [attack_text]!",
			to_blind_defender = "Something stops your attack!",
			to_viewers = "[cqc_user] [blocking_text_s] [attack_text]!",
			dangerous = FALSE,
		)
	return SUCCESSFUL_BLOCK


/datum/martial_art/cqc/reset_streak(mob/living/new_target)
	if(!IS_WEAKREF_OF(new_target, restraining_mob))
		restraining_mob = null
	return ..()

/datum/martial_art/cqc/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, SLAM_COMBO))
		reset_streak()
		return Slam(attacker, defender)
	if(findtext(streak, KICK_COMBO))
		reset_streak()
		return Kick(attacker, defender)
	if(findtext(streak, RESTRAIN_COMBO))
		reset_streak()
		return Restrain(attacker, defender)
	if(findtext(streak, PRESSURE_COMBO))
		reset_streak()
		return Pressure(attacker, defender)
	if(findtext(streak, CONSECUTIVE_COMBO))
		reset_streak()
		return Consecutive(attacker, defender)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/attacker, mob/living/defender)
	if(defender.body_position != STANDING_UP)
		return FALSE

	attacker.do_attack_animation(defender)
	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You slam [defender] into the ground!",
		to_defender = "[attacker] slams you into the ground!",
		to_blind_attacker = "You slam someone to the ground!",
		to_blind_defender = "Someone slams you into the ground!",
		to_viewers = "[attacker] slams [defender] into the ground!",
		to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
		dangerous = TRUE,
	)
	playsound(attacker, 'sound/items/weapons/slam.ogg', 50, TRUE, -1)
	defender.apply_damage(10, BRUTE)
	defender.Paralyze(12 SECONDS)
	log_combat(attacker, defender, "slammed (CQC)")
	return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/attacker, mob/living/defender)
	if(IS_UNCONSCIOUS_OR_CRIT(defender))
		return FALSE

	attacker.do_attack_animation(defender)
	if(defender.body_position == LYING_DOWN && !IS_UNCONSCIOUS(defender) && defender.get_stamina_loss() >= 100)
		log_combat(attacker, defender, "knocked out (Head kick)(CQC)")
		combat_message(
			attacker = attacker,
			defender = defender,
			to_attacker = "You kick [defender]'s head, knocking [defender.p_them()] out!",
			to_defender = "[attacker] kicks you in the head, knocking you unconscious!",
			to_blind_attacker = "You kick someone!",
			to_blind_defender = "Someone kicks you in the head, knocking you unconscious!",
			to_viewers = "[attacker] kicks [defender]'s head, knocking [defender.p_them()] out!",
			to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
			dangerous = TRUE,
		)
		playsound(attacker, 'sound/items/weapons/genhit1.ogg', 50, TRUE, -1)

		var/helmet_protection = defender.run_armor_check(BODY_ZONE_HEAD, MELEE)
		defender.apply_effect(20 SECONDS, EFFECT_KNOCKDOWN, helmet_protection)
		defender.apply_effect(10 SECONDS, EFFECT_UNCONSCIOUS, helmet_protection)
		defender.adjust_organ_loss(ORGAN_SLOT_BRAIN, 15, 150)

	else
		combat_message(
			attacker = attacker,
			defender = defender,
			to_attacker = "You kick [defender] back!",
			to_defender = "[attacker] kicks you back!",
			to_blind_attacker = "You kick someone!",
			to_blind_defender = "Someone kicks you back!",
			to_viewers = "[attacker] kicks [defender] back!",
			to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
		)
		playsound(attacker, 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
		defender.throw_at(throw_target, 1, 14, attacker)
		defender.apply_damage(10, attacker.get_attack_type())
		if(defender.body_position == LYING_DOWN && !IS_UNCONSCIOUS(defender))
			defender.adjust_stamina_loss(45)
		log_combat(attacker, defender, "kicked (CQC)")

	return TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender)
	log_combat(attacker, defender, "pressured (CQC)")
	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You punch [defender]'s neck!",
		to_defender = "[attacker] punches you in the neck!",
		to_blind_attacker = "You strike out, aiming for the neck!",
		to_blind_defender = "Someone punches you in the neck!",
		to_viewers = "[attacker] punches [defender]'s neck!",
		to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
	)
	defender.adjust_stamina_loss(60)
	playsound(attacker, 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/attacker, mob/living/defender)
	if(restraining_mob?.resolve())
		return FALSE
	if(IS_UNCONSCIOUS_OR_CRIT(defender))
		return FALSE

	log_combat(attacker, defender, "restrained (CQC)")
	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You lock [defender] into a restraining position!",
		to_defender = "[attacker] locks you into a restraining position!",
		to_blind_attacker = "You lock someone into a restraining position!",
		to_blind_defender = "Someone locks you into a restraining position!",
		to_viewers = "[attacker] locks [defender] into a restraining position!",
		to_blind_viewers = "You hear shuffling and a muffled groan!",
	)
	defender.adjust_stamina_loss(20)
	defender.Stun(10 SECONDS)
	restraining_mob = WEAKREF(defender)
	addtimer(VARSET_CALLBACK(src, restraining_mob, null), 5 SECONDS, TIMER_UNIQUE)
	return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/attacker, mob/living/defender)
	if(IS_UNCONSCIOUS_OR_CRIT(defender))
		return FALSE

	attacker.do_attack_animation(defender)
	log_combat(attacker, defender, "consecutive CQC'd (CQC)")
	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You strike [defender]'s abdomen, neck and back consecutively!",
		to_defender = "[attacker] consecutively strikes your abdomen, neck and back!",
		to_blind_attacker = "You strike out, aiming for the abdomen, neck, and back consecutively!",
		to_blind_defender = "Someone consecutively strikes your abdomen, neck and back!",
		to_viewers = "[attacker] strikes [defender]'s abdomen, neck and back consecutively!",
		to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
		dangerous = TRUE,
	)
	playsound(defender, 'sound/items/weapons/cqchit2.ogg', 50, TRUE, -1)
	var/obj/item/held_item = defender.get_active_held_item()
	if(held_item && defender.temporarilyRemoveItemFromInventory(held_item))
		attacker.put_in_hands(held_item)
	defender.adjust_stamina_loss(50)
	defender.apply_damage(25, attacker.get_attack_type())
	return TRUE

/datum/martial_art/cqc/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender)
		return MARTIAL_ATTACK_INVALID
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("G", defender)
	if(check_streak(attacker, defender)) //if a combo is made no grab upgrade is done
		return MARTIAL_ATTACK_SUCCESS
	if(attacker.body_position == LYING_DOWN)
		return MARTIAL_ATTACK_INVALID

	var/old_grab_state = attacker.grab_state
	defender.grabbedby(attacker, TRUE)
	if(old_grab_state == GRAB_PASSIVE)
		defender.drop_all_held_items()
		attacker.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if on grab intent
		log_combat(attacker, defender, "grabbed", addition="aggressively")
		combat_message(
			attacker = attacker,
			defender = defender,
			to_attacker = "You violently grab [defender]!",
			to_defender = "[attacker] violently grabs you!",
			to_blind_attacker = "You violently grab someone!",
			to_blind_defender = "Someone violently grabs you!",
			to_viewers = "[attacker] violently grabs [defender]!",
			to_blind_viewers = "You hear sounds of aggressive fondling!",
			dangerous = FALSE,
		)
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/cqc/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker.grab_state == GRAB_KILL \
		&& attacker.zone_selected == BODY_ZONE_HEAD \
		&& attacker.pulling == defender \
		&& defender.stat != DEAD \
	)
		var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head))
			playsound(defender, 'sound/effects/wounds/crack1.ogg', 100)
			combat_message(
				attacker = attacker,
				defender = defender,
				to_attacker = "In a swift motion, you snap the neck of [defender]!",
				to_defender = "[attacker] snaps your neck!",
				to_blind_attacker = "In a swift motion, you snap the neck of someone!",
				to_blind_defender = "Someone snaps your neck!",
				to_viewers = "[attacker] snaps the neck of [defender]!",
				to_blind_viewers = "You hear a sickening snap!",
				dangerous = TRUE,
			)
			log_combat(attacker, defender, "snapped neck")
			defender.apply_damage(100, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND)
			if(!HAS_TRAIT(defender, TRAIT_NODEATH))
				defender.death()
				defender.investigate_log("has had [defender.p_their()] neck snapped by [attacker].", INVESTIGATE_DEATHS)
			return MARTIAL_ATTACK_SUCCESS

	if(defender.check_block(attacker, 10, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	if(attacker.resting && defender.stat != DEAD && defender.body_position == STANDING_UP)
		combat_message(
			attacker = attacker,
			defender = defender,
			to_attacker = "You leg sweep [defender]!",
			to_defender = "[attacker] leg sweeps you!",
			to_blind_attacker = "You leg sweep at someone!",
			to_blind_defender = "Someone sweeps at you!",
			to_viewers = "[attacker] leg sweeps [defender]!",
			to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
			dangerous = TRUE,
		)
		playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		attacker.do_attack_animation(defender)
		defender.apply_damage(10, BRUTE)
		defender.Knockdown(5 SECONDS)
		log_combat(attacker, defender, "sweeped (CQC)")
		reset_streak()
		return MARTIAL_ATTACK_SUCCESS

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS
	attacker.do_attack_animation(defender)
	var/picked_hit_type = pick("CQC", "big boss")
	var/bonus_damage = 13
	if(defender.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = pick("kick", "stomp")
	defender.apply_damage(bonus_damage, BRUTE)

	playsound(defender, (picked_hit_type == "kick" || picked_hit_type == "stomp") ? 'sound/items/weapons/cqchit2.ogg' : 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)

	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You [picked_hit_type] [defender]!",
		to_defender = "[attacker] [PRESENT_TENSE(picked_hit_type)] you!",
		to_blind_attacker = "You [picked_hit_type] someone!",
		to_blind_defender = "Someone [PRESENT_TENSE(picked_hit_type)] you!",
		to_viewers = "[attacker] [PRESENT_TENSE(picked_hit_type)] [defender]!",
		to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
		dangerous = TRUE,
	)
	log_combat(attacker, defender, "attacked ([picked_hit_type]'d)(CQC)")
	return MARTIAL_ATTACK_SUCCESS

/datum/martial_art/cqc/disarm_act(mob/living/attacker, mob/living/defender)
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	if(IS_WEAKREF_OF(attacker.pulling, restraining_mob))
		log_combat(attacker, defender, "disarmed (CQC)", addition = "knocked out (CQC Chokehold)")
		combat_message(
			attacker = attacker,
			defender = defender,
			to_attacker = "You put [defender] into a chokehold!",
			to_defender = "[attacker] puts you into a chokehold!",
			to_blind_attacker = "You put someone into a chokehold!",
			to_blind_defender = "Someone puts you into a chokehold!",
			to_viewers = "[attacker] puts [defender] into a chokehold!",
			to_blind_viewers = "You hear shuffling and a muffled groan!",
			dangerous = TRUE,
		)
		defender.SetSleeping(40 SECONDS)
		restraining_mob = null
		if(attacker.grab_state < GRAB_NECK && !HAS_TRAIT(attacker, TRAIT_PACIFISM))
			attacker.setGrabState(GRAB_NECK)
		return MARTIAL_ATTACK_SUCCESS

	attacker.do_attack_animation(defender, ATTACK_EFFECT_DISARM)
	if(prob(65) && (!IS_UNCONSCIOUS_OR_CRIT(defender) || !defender.IsParalyzed() || !restraining_mob?.resolve()))
		var/obj/item/disarmed_item = defender.get_active_held_item()
		if(disarmed_item && defender.temporarilyRemoveItemFromInventory(disarmed_item))
			defender.dropItemToGround(disarmed_item)
			if(isturf(disarmed_item.loc)) //If it fell on the ground we can take it, otherwise assume it's attached to something.
				attacker.put_in_hands(disarmed_item)
			else
				disarmed_item = null
		else
			disarmed_item = null

		combat_message(
			attacker = attacker,
			defender = defender,
			to_attacker = "You strike [defender]'s jaw with your hand[disarmed_item ? ", disarming [defender.p_them()] of [disarmed_item]" : ""]!",
			to_defender = "[attacker] strikes your jaw,[disarmed_item ? " disarming you of [disarmed_item] and" : ""] leaving you disoriented!",
			to_blind_attacker = "You strike someone's jaw!", // no indication of if you disarmed successfully
			to_blind_defender = "Someone strikes your jaw[disarmed_item ? " disarming you of [disarmed_item] and" : ""] leaving you disoriented!",
			to_viewers = "[attacker] strikes [defender]'s jaw with their hand[disarmed_item ? ", disarming [defender.p_them()] of [disarmed_item]" : ""]!",
			to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
			dangerous = TRUE,
		)
		playsound(defender, 'sound/items/weapons/cqchit1.ogg', 50, TRUE, -1)
		defender.set_jitter_if_lower(4 SECONDS)
		defender.apply_damage(5, attacker.get_attack_type())
		log_combat(attacker, defender, "disarmed (CQC)", addition = disarmed_item ? "(disarmed of [disarmed_item])" : null)
		return MARTIAL_ATTACK_SUCCESS

	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You fail to disarm [defender]!",
		to_defender = "[attacker] nearly disarms you!",
		to_blind_attacker = "You swipe at someone!",
		to_blind_defender = "Someone swipes at you!",
		to_viewers = "[attacker] fails to disarm [defender]!",
		to_blind_viewers = "You hear a swoosh!",
		dangerous = FALSE,
	)
	playsound(defender, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "failed to disarm (CQC)")
	return MARTIAL_ATTACK_FAIL


/datum/martial_art/cqc/get_style_help()
	. = list()

	. += "<b><i>You try to remember some of the basics of CQC.</i></b>"

	. += "[span_notice("Slam")]: Grab Punch. Slam opponent into the ground, knocking them down."
	. += "[span_notice("CQC Kick")]: Punch Punch. Knocks opponent away. Knocks out stunned opponents and does stamina damage."
	. += "[span_notice("Restrain")]: Grab Grab. Locks opponents into a restraining position, disarm to knock them out with a chokehold."
	. += "[span_notice("Pressure")]: Shove Grab. Decent stamina damage."
	. += "[span_notice("Consecutive CQC")]: Shove Shove Punch. Mainly offensive move, huge damage and decent stamina damage."

	. += "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>"
	return .

///Subtype of CQC. Only used for the chef.
/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"
	///List of all areas that CQC will work in, defaults to Kitchen.
	var/list/kitchen_areas = list(/area/station/service/kitchen)

/// Refreshes the valid areas from the cook's mapping config, adding areas in config to the list of possible areas.
/datum/martial_art/cqc/under_siege/proc/refresh_valid_areas()
	var/list/additional_cqc_areas = CHECK_MAP_JOB_CHANGE(JOB_COOK, "additional_cqc_areas")
	if(!additional_cqc_areas)
		return

	if(!islist(additional_cqc_areas))
		stack_trace("Incorrect CQC area format from mapping configs. Expected /list, got: \[[additional_cqc_areas.type]\]")
		return

	for(var/path_as_text in additional_cqc_areas)
		var/path = text2path(path_as_text)
		if(!ispath(path, /area))
			stack_trace("Invalid path in mapping config for chef CQC: \[[path_as_text]\]")
			continue

		kitchen_areas |= path

/// Limits where the chef's CQC can be used to only whitelisted areas.
/datum/martial_art/cqc/under_siege/can_use(mob/living/martial_artist)
	if(!is_type_in_list(get_area(martial_artist), kitchen_areas))
		return FALSE
	return ..()

#undef SLAM_COMBO
#undef KICK_COMBO
#undef RESTRAIN_COMBO
#undef PRESSURE_COMBO
#undef CONSECUTIVE_COMBO
