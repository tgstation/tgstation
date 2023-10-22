#define SLAM_COMBO "GH"
#define KICK_COMBO "HH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DG"
#define CONSECUTIVE_COMBO "DDH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	help_verb = /mob/living/proc/CQC_help
	block_chance = 75
	smashes_tables = TRUE
	display_combos = TRUE
	var/old_grab_state = null
	var/mob/restraining_mob

/datum/martial_art/cqc/teach(mob/living/cqc_user, make_temporary)
	. = ..()
	RegisterSignal(cqc_user, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/datum/martial_art/cqc/on_remove(mob/living/cqc_user)
	UnregisterSignal(cqc_user, COMSIG_ATOM_ATTACKBY)
	. = ..()

///Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/cqc/proc/on_attackby(mob/living/cqc_user, obj/item/attack_weapon, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(attack_weapon, /obj/item/melee/touch_attack))
		return
	if(!can_use(cqc_user))
		return
	cqc_user.visible_message(
		span_danger("[cqc_user] twists [attacker]'s arm, sending their [attack_weapon] back towards them!"),
		span_userdanger("Making sure to avoid [attacker]'s [attack_weapon], you twist their arm to send it right back at them!"),
	)
	var/obj/item/melee/touch_attack/touch_weapon = attack_weapon
	var/datum/action/cooldown/spell/touch/touch_spell = touch_weapon.spell_which_made_us?.resolve()
	if(!touch_spell)
		return
	INVOKE_ASYNC(touch_spell, TYPE_PROC_REF(/datum/action/cooldown/spell/touch, do_hand_hit), touch_weapon, attacker, attacker)
	return COMPONENT_NO_AFTERATTACK

/datum/martial_art/cqc/reset_streak(mob/living/new_target)
	if(new_target && new_target != restraining_mob)
		restraining_mob = null
	return ..()

/datum/martial_art/cqc/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
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
	if(!can_use(attacker))
		return FALSE
	if(defender.body_position == STANDING_UP)
		defender.visible_message(span_danger("[attacker] slams [defender] into the ground!"), \
						span_userdanger("You're slammed into the ground by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, attacker)
		to_chat(attacker, span_danger("You slam [defender] into the ground!"))
		playsound(get_turf(attacker), 'sound/weapons/slam.ogg', 50, TRUE, -1)
		defender.apply_damage(10, BRUTE)
		defender.Paralyze(12 SECONDS)
		log_combat(attacker, defender, "slammed (CQC)")
		return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker) || defender.stat != CONSCIOUS)
		return FALSE

	if(defender.body_position == LYING_DOWN && !defender.IsUnconscious() && defender.getStaminaLoss() >= 100)
		log_combat(attacker, defender, "knocked out (Head kick)(CQC)")
		defender.visible_message(span_danger("[attacker] kicks [defender]'s head, knocking [defender.p_them()] out!"), \
						span_userdanger("You're knocked unconscious by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, attacker)
		to_chat(attacker, span_danger("You kick [defender]'s head, knocking [defender.p_them()] out!"))
		playsound(get_turf(attacker), 'sound/weapons/genhit1.ogg', 50, TRUE, -1)

		var/helmet_protection = defender.run_armor_check(BODY_ZONE_HEAD, MELEE)
		defender.apply_effect(20 SECONDS, EFFECT_KNOCKDOWN, helmet_protection)
		defender.apply_effect(10 SECONDS, EFFECT_UNCONSCIOUS, helmet_protection)
		defender.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		defender.visible_message(span_danger("[attacker] kicks [defender] back!"), \
						span_userdanger("You're kicked back by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_danger("You kick [defender] back!"))
		playsound(get_turf(attacker), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
		defender.throw_at(throw_target, 1, 14, attacker)
		defender.apply_damage(10, attacker.get_attack_type())
		if(defender.body_position == LYING_DOWN && !defender.IsUnconscious())
			defender.adjustStaminaLoss(45)
		log_combat(attacker, defender, "kicked (CQC)")
	. = TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	log_combat(attacker, defender, "pressured (CQC)")
	defender.visible_message(span_danger("[attacker] punches [defender]'s neck!"), \
					span_userdanger("Your neck is punched by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You punch [defender]'s neck!"))
	defender.adjustStaminaLoss(60)
	playsound(get_turf(attacker), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/attacker, mob/living/defender)
	if(restraining_mob)
		return
	if(!can_use(attacker))
		return FALSE
	if(!defender.stat)
		log_combat(attacker, defender, "restrained (CQC)")
		defender.visible_message(span_warning("[attacker] locks [defender] into a restraining position!"), \
						span_userdanger("You're locked into a restraining position by [attacker]!"), span_hear("You hear shuffling and a muffled groan!"), null, attacker)
		to_chat(attacker, span_danger("You lock [defender] into a restraining position!"))
		defender.adjustStaminaLoss(20)
		defender.Stun(10 SECONDS)
		restraining_mob = defender
		addtimer(VARSET_CALLBACK(src, restraining_mob, null), 50, TIMER_UNIQUE)
		return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	if(!defender.stat)
		log_combat(attacker, defender, "consecutive CQC'd (CQC)")
		defender.visible_message(span_danger("[attacker] strikes [defender]'s abdomen, neck and back consecutively"), \
						span_userdanger("Your abdomen, neck and back are struck consecutively by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_danger("You strike [defender]'s abdomen, neck and back consecutively!"))
		playsound(get_turf(defender), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
		var/obj/item/held_item = defender.get_active_held_item()
		if(held_item && defender.temporarilyRemoveItemFromInventory(held_item))
			attacker.put_in_hands(held_item)
		defender.adjustStaminaLoss(50)
		defender.apply_damage(25, attacker.get_attack_type())
		return TRUE

/datum/martial_art/cqc/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker != defender && can_use(attacker)) // attacker != defender prevents grabbing yourself
		add_to_streak("G", defender)
		if(check_streak(attacker, defender)) //if a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = attacker.grab_state
		defender.grabbedby(attacker, 1)
		if(old_grab_state == GRAB_PASSIVE)
			defender.drop_all_held_items()
			attacker.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if on grab intent
			log_combat(attacker, defender, "grabbed", addition="aggressively")
			defender.visible_message(span_warning("[attacker] violently grabs [defender]!"), \
							span_userdanger("You're grabbed violently by [attacker]!"), span_hear("You hear sounds of aggressive fondling!"), COMBAT_MESSAGE_RANGE, attacker)
			to_chat(attacker, span_danger("You violently grab [defender]!"))
		return TRUE
	else
		return FALSE

/datum/martial_art/cqc/harm_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE

	if(attacker.resting && defender.stat != DEAD && defender.body_position == STANDING_UP)
		defender.visible_message(span_danger("[attacker] leg sweeps [defender]!"), \
						span_userdanger("Your legs are sweeped by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, attacker)
		to_chat(attacker, span_danger("You leg sweep [defender]!"))
		playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		attacker.do_attack_animation(defender)
		defender.apply_damage(10, BRUTE)
		defender.Knockdown(5 SECONDS)
		log_combat(attacker, defender, "sweeped (CQC)")
		reset_streak()
		return TRUE

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return TRUE
	log_combat(attacker, defender, "attacked (CQC)")
	attacker.do_attack_animation(defender)
	var/picked_hit_type = pick("CQC", "Big Boss")
	var/bonus_damage = 13
	if(defender.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = "stomp"
	defender.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		playsound(get_turf(defender), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
	else
		playsound(get_turf(defender), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	defender.visible_message(span_danger("[attacker] [picked_hit_type]ed [defender]!"), \
					span_userdanger("You're [picked_hit_type]ed by [attacker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
	to_chat(attacker, span_danger("You [picked_hit_type] [defender]!"))
	log_combat(attacker, defender, "[picked_hit_type]s (CQC)")

	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/attacker, mob/living/defender)
	if(!can_use(attacker))
		return FALSE
	add_to_streak("D", defender)
	var/obj/item/held_item = null
	if(check_streak(attacker, defender))
		return TRUE
	log_combat(attacker, defender, "disarmed (CQC)", "[held_item ? " grabbing \the [held_item]" : ""]")
	if(restraining_mob && attacker.pulling == restraining_mob)
		log_combat(attacker, defender, "knocked out (Chokehold)(CQC)")
		defender.visible_message(span_danger("[attacker] puts [defender] into a chokehold!"), \
						span_userdanger("You're put into a chokehold by [attacker]!"), span_hear("You hear shuffling and a muffled groan!"), null, attacker)
		to_chat(attacker, span_danger("You put [defender] into a chokehold!"))
		defender.SetSleeping(40 SECONDS)
		restraining_mob = null
		if(attacker.grab_state < GRAB_NECK && !HAS_TRAIT(attacker, TRAIT_PACIFISM))
			attacker.setGrabState(GRAB_NECK)
		return TRUE
	if(prob(65))
		if(!defender.stat || !defender.IsParalyzed() || !restraining_mob)
			held_item = defender.get_active_held_item()
			defender.visible_message(span_danger("[attacker] strikes [defender]'s jaw with their hand!"), \
							span_userdanger("Your jaw is struck by [attacker], you feel disoriented!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, attacker)
			to_chat(attacker, span_danger("You strike [defender]'s jaw, leaving [defender.p_them()] disoriented!"))
			playsound(get_turf(defender), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
			if(held_item && defender.temporarilyRemoveItemFromInventory(held_item))
				attacker.put_in_hands(held_item)
			defender.set_jitter_if_lower(4 SECONDS)
			defender.apply_damage(5, attacker.get_attack_type())
	else
		defender.visible_message(span_danger("[attacker] fails to disarm [defender]!"), \
						span_userdanger("You're nearly disarmed by [attacker]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, attacker)
		to_chat(attacker, span_warning("You fail to disarm [defender]!"))
		playsound(defender, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
	return FALSE


/mob/living/proc/CQC_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	to_chat(usr, "<b><i>You try to remember some of the basics of CQC.</i></b>")

	to_chat(usr, "[span_notice("Slam")]: Grab Punch. Slam opponent into the ground, knocking them down.")
	to_chat(usr, "[span_notice("CQC Kick")]: Punch Punch. Knocks opponent away. Knocks out stunned opponents and does stamina damage.")
	to_chat(usr, "[span_notice("Restrain")]: Grab Grab. Locks opponents into a restraining position, disarm to knock them out with a chokehold.")
	to_chat(usr, "[span_notice("Pressure")]: Shove Grab. Decent stamina damage.")
	to_chat(usr, "[span_notice("Consecutive CQC")]: Shove Shove Punch. Mainly offensive move, huge damage and decent stamina damage.")

	to_chat(usr, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>")

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
/datum/martial_art/cqc/under_siege/can_use(mob/living/owner)
	if(!is_type_in_list(get_area(owner), kitchen_areas))
		return FALSE
	return ..()

#undef SLAM_COMBO
#undef KICK_COMBO
#undef RESTRAIN_COMBO
#undef PRESSURE_COMBO
#undef CONSECUTIVE_COMBO
