///Bloodsuckers spawning a Guardian will get the Bloodsucker one instead.
/obj/item/guardian_creator/spawn_guardian(mob/living/user, mob/dead/candidate)
	var/list/guardians = user.get_all_linked_holoparasites()
	if(length(guardians) && !allow_multiple)
		to_chat(user, span_holoparasite("You already have a [mob_name]!"))
		used = FALSE
		return
	if(IS_BLOODSUCKER(user))
		var/mob/living/basic/guardian/standard/timestop/bloodsucker_guardian = new(user, GUARDIAN_THEME_MAGIC)

		bloodsucker_guardian.set_summoner(user, different_person = TRUE)
		bloodsucker_guardian.key = candidate.key
		user.log_message("has summoned [key_name(bloodsucker_guardian)], a [bloodsucker_guardian.creator_name] holoparasite.", LOG_GAME)
		bloodsucker_guardian.log_message("was summoned as a [bloodsucker_guardian.creator_name] holoparasite.", LOG_GAME)
		to_chat(user, "...And draw... The World, through sheer luck or perhaps destiny, maybe even your own physiology. Manipulator of time, a guardian powerful enough to control THE WORLD!")
		to_chat(user, replacetext(success_message, "%GUARDIAN", mob_name))
		bloodsucker_guardian.client?.init_verbs()
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
	creator_icon = "standard"
	playstyle_string = span_holoparasite("As a <b>time manipulation</b> type you can stop time. You have a damage multiplier instead of armor as well as powerful melee attacks capable of smashing through walls.")

/mob/living/basic/guardian/standard/timestop/set_summoner(mob/living/to_who, different_person = FALSE)
	. = ..()
	var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = new()
	timestop_ability.Grant(src)
	ADD_TRAIT(to_who, TRAIT_TIME_STOP_IMMUNE, REF(src))

///Guardian Timestop ability
/datum/action/cooldown/spell/timestop/guardian
	name = "Guardian Timestop"
	desc = "This spell stops time for everyone except for you and your master, \
		allowing you to move freely while your enemies and even projectiles are frozen."
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_NONE
