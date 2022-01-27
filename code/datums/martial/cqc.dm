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
	var/old_grab_state = null
	var/restraining = FALSE
	display_combos = TRUE

/datum/martial_art/cqc/reset_streak(mob/living/new_target)
	. = ..()
	restraining = FALSE

/datum/martial_art/cqc/proc/check_streak(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,SLAM_COMBO))
		streak = ""
		return Slam(A,D)
	if(findtext(streak,KICK_COMBO))
		streak = ""
		return Kick(A,D)
	if(findtext(streak,RESTRAIN_COMBO))
		streak = ""
		return Restrain(A,D)
	if(findtext(streak,PRESSURE_COMBO))
		streak = ""
		return Pressure(A,D)
	if(findtext(streak,CONSECUTIVE_COMBO))
		streak = ""
		return Consecutive(A,D)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(D.body_position == STANDING_UP)
		D.visible_message(span_danger("[A] slams [D] into the ground!"), \
						span_userdanger("You're slammed into the ground by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You slam [D] into the ground!"))
		playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, TRUE, -1)
		D.apply_damage(10, BRUTE)
		D.Paralyze(120)
		log_combat(A, D, "slammed (CQC)")
		return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat || !D.IsParalyzed())
		D.visible_message(span_danger("[A] kicks [D] back!"), \
						span_userdanger("You're kicked back by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_danger("You kick [D] back!"))
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 1, 14, A)
		D.apply_damage(10, A.get_attack_type())
		log_combat(A, D, "kicked (CQC)")
		. = TRUE
	if(D.IsParalyzed() && !D.stat)
		log_combat(A, D, "knocked out (Head kick)(CQC)")
		D.visible_message(span_danger("[A] kicks [D]'s head, knocking [D.p_them()] out!"), \
						span_userdanger("You're knocked unconscious by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You kick [D]'s head, knocking [D.p_them()] out!"))
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, TRUE, -1)
		D.SetSleeping(300)
		D.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
		. = TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "pressured (CQC)")
	D.visible_message(span_danger("[A] punches [D]'s neck!"), \
					span_userdanger("Your neck is punched by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You punch [D]'s neck!"))
	D.adjustStaminaLoss(60)
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/A, mob/living/D)
	if(restraining)
		return
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "restrained (CQC)")
		D.visible_message(span_warning("[A] locks [D] into a restraining position!"), \
						span_userdanger("You're locked into a restraining position by [A]!"), span_hear("You hear shuffling and a muffled groan!"), null, A)
		to_chat(A, span_danger("You lock [D] into a restraining position!"))
		D.adjustStaminaLoss(20)
		D.Stun(100)
		restraining = TRUE
		addtimer(VARSET_CALLBACK(src, restraining, FALSE), 50, TIMER_UNIQUE)
		return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "consecutive CQC'd (CQC)")
		D.visible_message(span_danger("[A] strikes [D]'s abdomen, neck and back consecutively"), \
						span_userdanger("Your abdomen, neck and back are struck consecutively by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_danger("You strike [D]'s abdomen, neck and back consecutively!"))
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
		var/obj/item/I = D.get_active_held_item()
		if(I && D.temporarilyRemoveItemFromInventory(I))
			A.put_in_hands(I)
		D.adjustStaminaLoss(50)
		D.apply_damage(25, A.get_attack_type())
		return TRUE

/datum/martial_art/cqc/grab_act(mob/living/A, mob/living/D)
	if(A!=D && can_use(A)) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = A.grab_state
		D.grabbedby(A, 1)
		if(old_grab_state == GRAB_PASSIVE)
			D.drop_all_held_items()
			A.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if on grab intent
			log_combat(A, D, "grabbed", addition="aggressively")
			D.visible_message(span_warning("[A] violently grabs [D]!"), \
							span_userdanger("You're grabbed violently by [A]!"), span_hear("You hear sounds of aggressive fondling!"), COMBAT_MESSAGE_RANGE, A)
			to_chat(A, span_danger("You violently grab [D]!"))
		return TRUE
	else
		return FALSE

/datum/martial_art/cqc/harm_act(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "attacked (CQC)")
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC", "Big Boss")
	var/bonus_damage = 13
	if(D.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = "stomp"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, TRUE, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	D.visible_message(span_danger("[A] [picked_hit_type]ed [D]!"), \
					span_userdanger("You're [picked_hit_type]ed by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You [picked_hit_type] [D]!"))
	log_combat(A, D, "[picked_hit_type]s (CQC)")
	if(A.resting && !D.stat && !D.IsParalyzed())
		D.visible_message(span_danger("[A] leg sweeps [D]!"), \
						span_userdanger("Your legs are sweeped by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You leg sweep [D]!"))
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
		D.apply_damage(10, BRUTE)
		D.Paralyze(60)
		log_combat(A, D, "sweeped (CQC)")
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/A, mob/living/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	var/obj/item/I = null
	if(check_streak(A,D))
		return TRUE
	if(prob(65))
		if(!D.stat || !D.IsParalyzed() || !restraining)
			I = D.get_active_held_item()
			D.visible_message(span_danger("[A] strikes [D]'s jaw with their hand!"), \
							span_userdanger("Your jaw is struck by [A], you feel disoriented!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
			to_chat(A, span_danger("You strike [D]'s jaw, leaving [D.p_them()] disoriented!"))
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
			if(I && D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, A.get_attack_type())
	else
		D.visible_message(span_danger("[A] fails to disarm [D]!"), \
						span_userdanger("You're nearly disarmed by [A]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_warning("You fail to disarm [D]!"))
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
	log_combat(A, D, "disarmed (CQC)", "[I ? " grabbing \the [I]" : ""]")
	if(restraining && A.pulling == D)
		log_combat(A, D, "knocked out (Chokehold)(CQC)")
		D.visible_message(span_danger("[A] puts [D] into a chokehold!"), \
						span_userdanger("You're put into a chokehold by [A]!"), span_hear("You hear shuffling and a muffled groan!"), null, A)
		to_chat(A, span_danger("You put [D] into a chokehold!"))
		D.SetSleeping(400)
		restraining = FALSE
		if(A.grab_state < GRAB_NECK && !HAS_TRAIT(A, TRAIT_PACIFISM))
			A.setGrabState(GRAB_NECK)
	else
		restraining = FALSE
		return FALSE
	return TRUE

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
	var/list/kitchen_areas

/// Refreshes the valid areas from the cook job singleton, otherwise uses the default kitchen area as a fallback option. See also [/datum/job/cook/New].
/datum/martial_art/cqc/under_siege/proc/refresh_valid_areas()
	var/datum/job/cook/cook_job = SSjob.GetJobType(/datum/job/cook)
	kitchen_areas = cook_job.kitchen_areas.Copy()

/// Limits where the chef's CQC can be used to only whitelisted areas.
/datum/martial_art/cqc/under_siege/can_use(mob/living/owner)
	if(!is_type_in_list(get_area(owner), kitchen_areas))
		return FALSE
	return ..()
