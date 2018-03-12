/mob/living/simple_animal/hostile/retaliate/moodlet
	icon = 'icons/mob/screen_gen.dmi'
	name = "Moodlet"
	desc = "Not sure what this is, but it looks like it's gonna do unpleasant things to you in the dark."
	icon_state = "mood5"
	icon_dead = "mood1"
	turns_per_move = 5
	response_help = "hugs"
	response_harm = "robusts"
	movement_type = FLYING
	a_intent = INTENT_HARM
	maxHealth = 100
	health = 100
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 8
	melee_damage_upper = 8
	attacktext = "attacks"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	gold_core_spawnable = FRIENDLY_SPAWN
	var/currentMood = 5

/mob/living/simple_animal/hostile/retaliate/moodlet/attack_hand(mob/living/M)
	..()
	if (M.a_intent == INTENT_HELP && stat == CONSCIOUS)
		if (currentMood < 9)
			currentMood++
			icon_state = "mood[currentMood]"

/mob/living/simple_animal/hostile/retaliate/moodlet/Retaliate()
	..()
	while(currentMood > 2)
		if (stat != CONSCIOUS)
			break
		currentMood--
		icon_state = "mood[currentMood]"
		sleep(4)
