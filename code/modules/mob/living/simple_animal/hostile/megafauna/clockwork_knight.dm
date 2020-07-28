/*

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/clockwork_defender
	name = "the clockwork defender"
	desc = "A traitorous clockwork knight who lived on, despite its creators destruction."
	health = 1500
	maxHealth = 1500
	icon_state = "clockwork_defender"
	icon_living = "clockwork_defender"
	icon = 'icons/mob/icemoon/icemoon_monsters.dmi'
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	weather_immunities = list("snow")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 20
	melee_damage_upper = 20
	vision_range = 9
	aggro_vision_range = 9
	speed = 4
	move_to_delay = 4
	rapid_melee = 8 // every 1/4 second
	melee_queue_distance = 20
	ranged = TRUE
	gps_name = "Clockwork Signal"
	loot = list(/obj/item/clockwork_alloy)
	crusher_loot = list(/obj/item/clockwork_alloy)
	wander = FALSE
	del_on_death = TRUE
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// TODO
	achievement_type = /datum/award/achievement/boss/wendigo_kill
	crusher_achievement_type = /datum/award/achievement/boss/wendigo_crusher
	score_achievement_type = /datum/award/score/wendigo_score
	deathmessage = "falls, quickly decaying into centuries old dust."
	deathsound = "bodyfall"
	footstep_type = FOOTSTEP_MOB_HEAVY
	attack_action_types = list(/datum/action/innate/megafauna_attack/daggers,
							   /datum/action/innate/megafauna_attack/battleaxes,
							   /datum/action/innate/megafauna_attack/sword_wall)

/datum/action/innate/megafauna_attack/daggers
	name = "Daggers"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now throwing a storm of daggers where you click.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/battleaxes
	name = "Battleaxes"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	chosen_message = "<span class='colossus'>You are now throwing battleaxes wildly around you.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/sword_wall
	name = "Sword Wall"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall"
	chosen_message = "<span class='colossus'>You are now dashing away from the target you click on while placing a sword wall.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/clockwork_defender/OpenFire()
	SetRecoveryTime(0, 100)

	if(client)
		switch(chosen_attack)
			if(1)
				daggers()
			if(2)
				battleaxes()
			if(3)
				sword_wall()
		return

	chosen_attack = rand(1, 3)
	switch(chosen_attack)
		if(1)
			daggers()
		if(2)
			battleaxes()
		if(3)
			sword_wall()

/// Throws a storm of daggers at the target
/mob/living/simple_animal/hostile/megafauna/clockwork_defender/proc/daggers()
	return

/// Throws battleaxes at random nearby turfs
/mob/living/simple_animal/hostile/megafauna/clockwork_defender/proc/battleaxes()
	return

/// Creates a sword wall at our location and dashes away from the target
/mob/living/simple_animal/hostile/megafauna/clockwork_defender/proc/sword_wall()
	return

/obj/item/clockwork_alloy
	name = "clockwork alloy"
	desc = "The remains of the strongest clockwork knight."
	icon = 'icons/obj/ice_moon/artifacts.dmi'
	icon_state = "clockwork_alloy"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
