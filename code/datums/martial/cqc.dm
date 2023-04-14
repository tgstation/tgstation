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
	RegisterSignal(cqc_user, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))

/datum/martial_art/cqc/on_remove(mob/living/cqc_user)
	UnregisterSignal(cqc_user, COMSIG_PARENT_ATTACKBY)
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

/datum/martial_art/cqc/proc/check_streak(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	if(findtext(streak,SLAM_COMBO))
		reset_streak()
		return Slam(user, target)
	if(findtext(streak,KICK_COMBO))
		reset_streak()
		return Kick(user, target)
	if(findtext(streak,RESTRAIN_COMBO))
		reset_streak()
		return Restrain(user, target)
	if(findtext(streak,PRESSURE_COMBO))
		reset_streak()
		return Pressure(user, target)
	if(findtext(streak,CONSECUTIVE_COMBO))
		reset_streak()
		return Consecutive(user, target)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	if(target.body_position == STANDING_UP)
		target.visible_message(span_danger("[user] slams [target] into the ground!"), \
						span_userdanger("You're slammed into the ground by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You slam [target] into the ground!"))
		playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, TRUE, -1)
		target.apply_damage(10, BRUTE)
		target.Paralyze(12 SECONDS)
		log_combat(user, target, "slammed (CQC)")
		return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	if(!target.stat || !target.IsParalyzed())
		target.visible_message(span_danger("[user] kicks [target] back!"), \
						span_userdanger("You're kicked back by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You kick [target] back!"))
		playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(target, user.dir)
		target.throw_at(throw_target, 1, 14, user)
		target.apply_damage(10, user.get_attack_type())
		log_combat(user, target, "kicked (CQC)")
		. = TRUE
	if(target.IsParalyzed() && !target.stat)
		log_combat(user, target, "knocked out (Head kick)(CQC)")
		target.visible_message(span_danger("[user] kicks [target]'s head, knocking [target.p_them()] out!"), \
						span_userdanger("You're knocked unconscious by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You kick [target]'s head, knocking [target.p_them()] out!"))
		playsound(get_turf(user), 'sound/weapons/genhit1.ogg', 50, TRUE, -1)
		target.SetSleeping(30 SECONDS)
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
		. = TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	log_combat(user, target, "pressured (CQC)")
	target.visible_message(span_danger("[user] punches [target]'s neck!"), \
					span_userdanger("Your neck is punched by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You punch [target]'s neck!"))
	target.adjustStaminaLoss(60)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/user, mob/living/target)
	if(restraining_mob)
		return
	if(!can_use(user))
		return FALSE
	if(!target.stat)
		log_combat(user, target, "restrained (CQC)")
		target.visible_message(span_warning("[user] locks [target] into a restraining position!"), \
						span_userdanger("You're locked into a restraining position by [user]!"), span_hear("You hear shuffling and a muffled groan!"), null, user)
		to_chat(user, span_danger("You lock [target] into a restraining position!"))
		target.adjustStaminaLoss(20)
		target.Stun(10 SECONDS)
		restraining_mob = target
		addtimer(VARSET_CALLBACK(src, restraining_mob, null), 50, TIMER_UNIQUE)
		return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	if(!target.stat)
		log_combat(user, target, "consecutive CQC'd (CQC)")
		target.visible_message(span_danger("[user] strikes [target]'s abdomen, neck and back consecutively"), \
						span_userdanger("Your abdomen, neck and back are struck consecutively by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You strike [target]'s abdomen, neck and back consecutively!"))
		playsound(get_turf(target), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
		var/obj/item/held_item = target.get_active_held_item()
		if(held_item && target.temporarilyRemoveItemFromInventory(held_item))
			user.put_in_hands(held_item)
		target.adjustStaminaLoss(50)
		target.apply_damage(25, user.get_attack_type())
		return TRUE

/datum/martial_art/cqc/grab_act(mob/living/user, mob/living/target)
	if(user != target && can_use(user)) // user != target prevents grabbing yourself
		add_to_streak("G", target)
		if(check_streak(user, target)) //if a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = user.grab_state
		target.grabbedby(user, 1)
		if(old_grab_state == GRAB_PASSIVE)
			target.drop_all_held_items()
			user.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if on grab intent
			log_combat(user, target, "grabbed", addition="aggressively")
			target.visible_message(span_warning("[user] violently grabs [target]!"), \
							span_userdanger("You're grabbed violently by [user]!"), span_hear("You hear sounds of aggressive fondling!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You violently grab [target]!"))
		return TRUE
	else
		return FALSE

/datum/martial_art/cqc/harm_act(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	add_to_streak("H", target)
	if(check_streak(user, target))
		return TRUE
	log_combat(user, target, "attacked (CQC)")
	user.do_attack_animation(target)
	var/picked_hit_type = pick("CQC", "Big Boss")
	var/bonus_damage = 13
	if(target.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = "stomp"
	target.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		playsound(get_turf(target), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
	else
		playsound(get_turf(target), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	target.visible_message(span_danger("[user] [picked_hit_type]ed [target]!"), \
					span_userdanger("You're [picked_hit_type]ed by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You [picked_hit_type] [target]!"))
	log_combat(user, target, "[picked_hit_type]s (CQC)")
	if(user.resting && !target.stat && !target.IsParalyzed())
		target.visible_message(span_danger("[user] leg sweeps [target]!"), \
						span_userdanger("Your legs are sweeped by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You leg sweep [target]!"))
		playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		target.apply_damage(10, BRUTE)
		target.Paralyze(6 SECONDS)
		log_combat(user, target, "sweeped (CQC)")
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/user, mob/living/target)
	if(!can_use(user))
		return FALSE
	add_to_streak("D", target)
	var/obj/item/held_item = null
	if(check_streak(user, target))
		return TRUE
	log_combat(user, target, "disarmed (CQC)", "[held_item ? " grabbing \the [held_item]" : ""]")
	if(restraining_mob && user.pulling == restraining_mob)
		log_combat(user, target, "knocked out (Chokehold)(CQC)")
		target.visible_message(span_danger("[user] puts [target] into a chokehold!"), \
						span_userdanger("You're put into a chokehold by [user]!"), span_hear("You hear shuffling and a muffled groan!"), null, user)
		to_chat(user, span_danger("You put [target] into a chokehold!"))
		target.SetSleeping(40 SECONDS)
		restraining_mob = null
		if(user.grab_state < GRAB_NECK && !HAS_TRAIT(user, TRAIT_PACIFISM))
			user.setGrabState(GRAB_NECK)
		return TRUE
	if(prob(65))
		if(!target.stat || !target.IsParalyzed() || !restraining_mob)
			held_item = target.get_active_held_item()
			target.visible_message(span_danger("[user] strikes [target]'s jaw with their hand!"), \
							span_userdanger("Your jaw is struck by [user], you feel disoriented!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_danger("You strike [target]'s jaw, leaving [target.p_them()] disoriented!"))
			playsound(get_turf(target), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
			if(held_item && target.temporarilyRemoveItemFromInventory(held_item))
				user.put_in_hands(held_item)
			target.set_jitter_if_lower(4 SECONDS)
			target.apply_damage(5, user.get_attack_type())
	else
		target.visible_message(span_danger("[user] fails to disarm [target]!"), \
						span_userdanger("You're nearly disarmed by [user]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("You fail to disarm [target]!"))
		playsound(target, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
	return FALSE


/mob/living/proc/CQC_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	to_chat(usr, "<b><i>You try to remember some of the basics of CQC.</i></b>")

	to_chat(usr, "[span_notice("Slam")]: Grab Punch. Slam opponent into the ground, knocking them down.")
	to_chat(usr, "[span_notice("CQC Kick")]: Punch Punch. Knocks opponent away. Knocks out stunned or knocked down opponents.")
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
	var/list/job_changes = SSmapping.config.job_changes

	if(!length(job_changes))
		return

	var/list/cook_changes = job_changes[JOB_COOK]

	if(!length(cook_changes))
		return

	var/list/additional_cqc_areas = cook_changes["additional_cqc_areas"]

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
