///Bloodsuckers spawning a Guardian will get the Bloodsucker one instead.
/obj/item/guardian_creator/attack_self(mob/living/user)
	// If this code looks odd, it's because I'm intentionally inserting a hack,
	// as I'm trying to avoid touching `guardian_creator.dm` in a major way. The
	// intent with this hack is to force Bloodsuckers to always get a Timestop
	// Guardian, no matter the item that a Bloodsucker uses to get a guardian.
	//
	// There is plans to refactor/modularization guardians, which will hopefully
	// allow this all to happen without as much of a hack.

	// START COPIED CODE FROM guardian_creator.dm
	if(isguardian(user) && !allow_guardian)
		balloon_alert(user, "can't do that!")
		return
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allow_multiple)
		balloon_alert(user, "already have one!")
		return
	if(user.mind?.has_antag_datum(/datum/antagonist/changeling) && !allow_changeling)
		to_chat(user, ling_failure)
		return
	if(used)
		to_chat(user, used_message)
		return
	// END COPIED CODE FROM guardian_creator.dm

	if (IS_BLOODSUCKER(user))
		//var/mob/living/basic/guardian/standard/timestop/guardian_path = new(user, GUARDIAN_THEME_MAGIC)
		var/mob/living/basic/guardian/guardian_path = /mob/living/basic/guardian/standard/timestop

		// START COPIED CODE FROM guardian_creator.dm
		used = TRUE
		to_chat(user, use_message)
		var/guardian_type_name = capitalize(initial(guardian_path.creator_name))
		var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
			"Do you want to play as [user.real_name]'s [guardian_type_name] [mob_name]?",
			check_jobban = ROLE_PAI,
			poll_time = 10 SECONDS,
			ignore_category = POLL_IGNORE_HOLOPARASITE,
			alert_pic = guardian_path,
			role_name_text = "guardian spirit",
		)
		if(LAZYLEN(candidates))
			var/mob/dead/observer/candidate = pick(candidates)
			spawn_guardian(user, candidate, guardian_path)
		else
			to_chat(user, failure_message)
			used = FALSE
		// END COPIED CODE FROM guardian_creator.dm

		return

	// Call parent to deal with everyone else
	return ..()

/**
 * The Guardian itself
 */
/mob/living/basic/guardian/standard/timestop
	// Like Bloodsuckers do, you will take more damage to Burn and less to Brute
	damage_coeff = list(BRUTE = 0.5, BURN = 2.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

	creator_name = "Timestop"
	creator_desc = "Devastating close combat attacks and high damage resistance. Can smash through weak walls and stop time."
	creator_icon = "timestop"

/mob/living/basic/guardian/standard/timestop/Initialize(mapload, theme)
	//Wizard Holoparasite theme, just to be more visibly stronger than regular ones
	theme = GLOB.guardian_themes[GUARDIAN_THEME_TECH]
	. = ..()
	var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = new()
	timestop_ability.Grant(src)

/mob/living/basic/guardian/standard/timestop/set_summoner(mob/living/to_who, different_person = FALSE)
	..()
	for(var/action in actions)
		var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = action
		if(istype(timestop_ability))
			timestop_ability.grant_summoner_immunity()

/mob/living/basic/guardian/standard/timestop/cut_summoner(different_person = FALSE)
	for(var/action in actions)
		var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = action
		if(istype(timestop_ability))
			timestop_ability.remove_summoner_immunity()
	..()

///Guardian Timestop ability
/datum/action/cooldown/spell/timestop/guardian
	name = "Guardian Timestop"
	desc = "This spell stops time for everyone except for you and your master, \
		allowing you to move freely while your enemies and even projectiles are frozen."
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/timestop/guardian/proc/grant_summoner_immunity()
	var/mob/living/basic/guardian/standard/timestop/bloodsucker_guardian = owner
	if(bloodsucker_guardian && istype(bloodsucker_guardian) && bloodsucker_guardian.summoner)
		ADD_TRAIT(bloodsucker_guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/cooldown/spell/timestop/guardian/proc/remove_summoner_immunity()
	var/mob/living/basic/guardian/standard/timestop/bloodsucker_guardian = owner
	if(bloodsucker_guardian && istype(bloodsucker_guardian) && bloodsucker_guardian.summoner)
		REMOVE_TRAIT(bloodsucker_guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))
