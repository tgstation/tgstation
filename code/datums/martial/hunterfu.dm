#define BODYSLAM_COMBO "GH"
#define STAKESTAB_COMBO "HH"
#define NECKSNAP_COMBO "GDH"
#define HOLYKICK_COMBO "DG"

// From CQC.dm
/datum/martial_art/hunterfu
	name = "Hunter-Fu"
	id = MARTIALART_HUNTERFU
	help_verb = /mob/living/carbon/human/proc/hunterfu_help
	block_chance = 60
	allow_temp_override = TRUE
	var/old_grab_state = null

/datum/martial_art/hunterfu/proc/check_streak(mob/living/user, mob/living/target)
	if(findtext(streak, BODYSLAM_COMBO))
		streak = ""
		body_slam(user, target)
		return TRUE
	if(findtext(streak, STAKESTAB_COMBO))
		streak = ""
		stake_stab(user, target)
		return TRUE
	if(findtext(streak, NECKSNAP_COMBO))
		streak = ""
		neck_snap(user, target)
		return TRUE
	if(findtext(streak, HOLYKICK_COMBO))
		streak = ""
		holy_kick(user, target)
		return TRUE
	return FALSE

/datum/martial_art/hunterfu/proc/body_slam(mob/living/user, mob/living/target)
	if(target.mobility_flags & MOBILITY_STAND)
		target.visible_message(
			span_danger("[user] slams both them and [target] into the ground!"),
			span_userdanger("You're slammed into the ground by [user]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
		)
		to_chat(user, span_danger("You slam [target] into the ground!"))
		playsound(get_turf(user), 'sound/weapons/slam.ogg', 50, TRUE, -1)
		log_combat(user, target, "bodyslammed (Hunter-Fu)")
		if(!target.mind)
			target.Paralyze(40)
			user.Paralyze(25)
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(target, span_cultlarge("Our DNA shakes as we are body slammed!"))
			target.apply_damage(15, BRUTE)
			target.Paralyze(60)
			user.Paralyze(25)
			return TRUE
		else
			target.Paralyze(40)
			user.Paralyze(25)
	else
		harm_act(user, target)
	return TRUE

/datum/martial_art/hunterfu/proc/stake_stab(mob/living/user, mob/living/target)
	target.visible_message(
		span_danger("[user] stabs [target] in the heart!"),
		span_userdanger("You're staked in the heart by [user]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
	)
	to_chat(user, span_danger("You stab [target] viciously!"))
	playsound(get_turf(user), 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	log_combat(user, target, "stakestabbed (Hunter-Fu)")
	if(!target.mind)
		target.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
		return TRUE
	if(target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(target, span_danger("Their arm tears through our monstrous form!"))
		target.apply_damage(25, BRUTE, BODY_ZONE_CHEST)
		return TRUE
	if(target.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		to_chat(target, span_cultlarge("Their arm stakes straight into our undead flesh!"))
		target.apply_damage(20, BURN)
		target.apply_damage(10, BRUTE, BODY_ZONE_CHEST)
		return TRUE
	else
		target.apply_damage(15, BRUTE, BODY_ZONE_CHEST)
	return TRUE

/datum/martial_art/hunterfu/proc/neck_snap(mob/living/user, mob/living/target)
	if(!target.stat)
		target.visible_message(
			span_danger("[user] snapped [target]'s neck!"),
			span_userdanger("Your neck is snapped by [user]!"),
			span_hear("You hear a snap!"),
		)
		to_chat(user, span_danger("You snap [target]'s neck!"))
		playsound(get_turf(user), 'sound/effects/snap.ogg', 50, TRUE, -1)
		log_combat(user, target, "neck snapped (Hunter-Fu)")
		if(!target.mind)
			target.SetSleeping(30)
			playsound(get_turf(user), 'sound/effects/snap.ogg', 50, TRUE, -1)
			log_combat(user, target, "neck snapped (Hunter-Fu)")
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(target, span_warning("Our monstrous form protects us from being put to sleep!"))
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/heretic))
			to_chat(target, span_cultlarge("The power of the Codex Cicatrix flares as we are swiftly put to sleep!"))
			target.apply_damage(15, BRUTE, BODY_ZONE_HEAD)
			target.SetSleeping(40)
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/bloodsucker))
			to_chat(target, span_warning("Our undead form protects us from being put to sleep!"))
			return TRUE
		else
			target.SetSleeping(30)
	return TRUE

/datum/martial_art/hunterfu/proc/holy_kick(mob/living/user, mob/living/target)
	target.visible_message(
		span_warning("[user] kicks [target], splashing holy water in every direction!"),
		span_userdanger("You're kicked by [user], with holy water dripping down on you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
	)
	to_chat(user, span_danger("You holy kick [target]!"))
	playsound(get_turf(user), 'sound/weapons/slash.ogg', 50, TRUE, -1)
	log_combat(user, target, "holy kicked (Hunter-Fu)")
	if(!target.mind)
		target.apply_damage(60, STAMINA)
		target.Paralyze(20)
		return TRUE
	if(target.mind.has_antag_datum(/datum/antagonist/heretic))
		to_chat(target, span_cultlarge("The holy water burns our flesh!"))
		target.apply_damage(25, BURN)
		target.apply_damage(60, STAMINA)
		target.Paralyze(20)
		return TRUE
	if(target.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		to_chat(target, span_warning("This just seems like regular water..."))
		return TRUE
	if(target.mind.has_antag_datum(/datum/antagonist/cult))
		for(var/datum/action/innate/cult/blood_magic/BD in target.actions)
			to_chat(target, span_cultlarge("Our blood rites falter as the holy water drips onto our body!"))
			for(var/datum/action/innate/cult/blood_spell/BS in BD.spells)
				qdel(BS)
		target.apply_damage(60, STAMINA)
		target.Paralyze(20)
		return TRUE
	if(target.mind.has_antag_datum(/datum/antagonist/wizard) || (/datum/antagonist/wizard/apprentice))
		to_chat(target, span_danger("The holy water seems to be muting us somehow!"))
		var/mob/living/carbon/human/human_target = target // I guess monkey wizards aren't getting affected.
		if(human_target.silent <= 10)
			human_target.silent = clamp(human_target.silent + 10, 0, 10)
		target.apply_damage(60, STAMINA)
		target.Paralyze(20)
		return TRUE
	else
		target.apply_damage(60, STAMINA)
		target.Paralyze(20)
	return TRUE

/// Intents
/datum/martial_art/hunterfu/disarm_act(mob/living/user, mob/living/target)
	add_to_streak("D", target)
	if(check_streak(user, target))
		return TRUE
	log_combat(user, target, "disarmed (Hunter-Fu)")
	return ..()

/datum/martial_art/hunterfu/harm_act(mob/living/user, mob/living/target)
	add_to_streak("H", target)
	if(check_streak(user, target))
		return TRUE
	var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected))
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	target.visible_message(
		span_danger("[user] [atk_verb]s [target]!"),
		span_userdanger("[user] [atk_verb]s you!"),
	)
	to_chat(user, span_danger("You [atk_verb] [target]!"))
	target.apply_damage(rand(10,15), BRUTE, affecting, wound_bonus = CANT_WOUND)
	playsound(get_turf(target), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(user, target, "harmed (Hunter-Fu)")
	return TRUE

/datum/martial_art/hunterfu/grab_act(mob/living/user, mob/living/target)
	if(user!=target && can_use(user))
		add_to_streak("G", target)
		if(check_streak(user, target)) // If a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = user.grab_state
		target.grabbedby(user, 1)
		if(old_grab_state == GRAB_PASSIVE)
			target.drop_all_held_items()
			user.grab_state = GRAB_AGGRESSIVE // Instant agressive grab
			log_combat(user, target, "grabbed (Hunter-Fu)")
			target.visible_message(
				span_warning("[user] violently grabs [target]!"),
				span_userdanger("You're grabbed violently by [user]!"),
				span_hear("You hear sounds of aggressive fondling!"),
			)
			to_chat(user, span_danger("You violently grab [target]!"))
		return TRUE
	..()

/mob/living/carbon/human/proc/hunterfu_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of Hunter-Fu."
	set category = "Hunter-Fu"
	to_chat(usr, span_notice("<b><i>You try to remember some of the basics of Hunter-Fu.</i></b>"))

	to_chat(usr, span_notice("<b>Body Slam</b>: Grab Harm. Slam opponent into the ground, knocking you both down."))
	to_chat(usr, span_notice("<b>Stake Stab</b>: Harm Harm. Stabs opponent with your bare fist, as strong as a Stake."))
	to_chat(usr, span_notice("<b>Neck Snap</b>: Grab Disarm Harm. Snaps an opponents neck, knocking them out."))
	to_chat(usr, span_notice("<b>Holy Kick</b>: Disarm Grab. Splashes the user with Holy Water, removing Cult Spells, while dealing stamina damage."))

	to_chat(usr, span_notice("<b><i>In addition, by having your throw mode on, you take a defensive position, allowing you to block and sometimes even counter attacks done to you.</i></b>"))
