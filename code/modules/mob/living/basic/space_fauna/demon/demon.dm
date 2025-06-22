/// Player controlled mobs that rip and tear, typically summoned by wizards.
/mob/living/basic/demon
	name = "imp"
	real_name = "imp"
	unique_name = TRUE
	desc = "A large, menacing creature covered in armored black scales."

	speak_emote = list("cackles","screeches")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	attack_verb_continuous = "wildly tears into"
	attack_verb_simple = "wildly tear into"

	icon = 'icons/mob/simple/demon.dmi'
	icon_state = "demon"
	icon_living = "demon"

	mob_biotypes = MOB_BEAST|MOB_HUMANOID
	status_flags = CANPUSH

	combat_mode = TRUE
	attack_sound = 'sound/effects/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	faction = list(FACTION_HELL)

	maxHealth = 200
	health = 200
	obj_damage = 40
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_attack_cooldown = CLICK_CD_MELEE
	death_message = "screams in agony as it sublimates into a sulfurous smoke."
	death_sound = 'sound/effects/magic/demon_dies.ogg'

	habitable_atmos = null
	minimum_survivable_temperature = T0C - 25 //Weak to cold
	maximum_survivable_temperature = INFINITY

	basic_mob_flags = DEL_ON_DEATH

	// You KNOW we're doing a lightly purple red
	lighting_cutoff_red = 30
	lighting_cutoff_green = 10
	lighting_cutoff_blue = 20

	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)

	/// Typepath of the antag datum to add to the demon when applicable
	var/datum/antagonist/antag_type = null

/mob/living/basic/demon/Initialize(mapload)
	. = ..()
	var/list/grantable_loot = grant_loot()
	if(length(grantable_loot))
		AddElement(/datum/element/death_drops, grantable_loot)

/// Proc that adds the necessary loot for the demon. Return an empty list if you don't want to add anything.
/mob/living/basic/demon/proc/grant_loot()
	return list()

/// Proc that just sets up the demon's antagonism status.
/mob/living/basic/demon/mind_initialize()
	. = ..()
	if(isnull(antag_type) || mind.has_antag_datum(antag_type))
		return // we weren't built for this proc to run

	mind.set_assigned_role(SSjob.get_job_type(/datum/job/slaughter_demon))
	mind.special_role = ROLE_SLAUGHTER_DEMON
	mind.add_antag_datum(antag_type)

	SEND_SOUND(src, 'sound/effects/magic/demon_dies.ogg')
	to_chat(src, span_bold("You are currently not currently in the same plane of existence as the station. Use your Blood Crawl ability near a pool of blood to manifest and wreak havoc."))
