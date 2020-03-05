/*

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/wendigo
	name = "wendigo"
	desc = "A mythological man-eating legendary creature, you probably aren't going to survive this."
	health = 2500
	maxHealth = 2500
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"
	icon = 'icons/mob/icemoon/64x64megafauna.dmi'
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	weather_immunities = list("snow")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	vision_range = 9
	aggro_vision_range = 36 // man-eating for a reason
	speed = 15
	move_to_delay = 15
	ranged = TRUE
	crusher_loot = list()
	loot = list()
	butcher_results = list()
	guaranteed_butcher_results = list()
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	achievement_type = /datum/award/achievement/boss/demonic_miner_kill
	crusher_achievement_type = /datum/award/achievement/boss/demonic_miner_crusher
	score_achievement_type = /datum/award/score/demonic_miner_score
	deathmessage = "falls, shaking the ground around it"
	deathsound = "gravhit"
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/frost_orbs,
							   /datum/action/innate/megafauna_attack/snowball_machine_gun,
							   /datum/action/innate/megafauna_attack/ice_shotgun)
	var/turf/starting

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize()
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/OpenFire()
	SetRecoveryTime(100, 100)

/mob/living/simple_animal/hostile/megafauna/wendigo/Goto(target, delay, minimum_distance)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/wendigo/MoveToTarget(list/possible_targets)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/wendigo/Move()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/wendigo/death(gibbed, list/force_grant)
	if(health > 0)
		return
	else
		var/obj/effect/portal/permanent/one_way/exit = new /obj/effect/portal/permanent/one_way(starting)
		exit.keep = TRUE
		exit.id = "wendigo exit"
		exit.set_linked()
		. = ..()
