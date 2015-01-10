/mob/living/simple_animal/hostile/assistant
	name = "Assistant"
	desc = "A faceless member of the Grey"
	icon_state = "assistant"
	icon_living = "assistant"
	icon_dead = "assistant_dead"
	icon_gib = "assistant_gib"
	turns_per_move = 5
	response_help = "hugs"
	response_disarm = "disarms"
	response_harm = "punches"
	speak = list("VIVA!", "Lynch lynch lynch!", "Greytide!", "RIOT!!!")
	speak_chance = 1
	a_intent = "harm"
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	speed = 0
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = "punch"
	environment_smash = 1
	gender = MALE
	faction = "greytide"
	var/enemy_list = list()

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 270
	maxbodytemp = 370
	heat_damage_per_tick = 15	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 10	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	unsuitable_atmos_damage = 10

/mob/living/simple_animal/hostile/assistant/New()
	name = "[pick(first_names_male)] [pick(last_names)]"
	..()

/mob/living/simple_animal/hostile/assistant/female
	name = "Assistant"
	icon_state = "assistant_f"
	icon_living = "assistant_f"
	icon_dead = "assistant_f_dead"
	icon_gib = "assistant_f_gib"
	gender = FEMALE

/mob/living/simple_animal/hostile/assistant/female/New()
	name = "[pick(first_names_female)] [pick(last_names)]"
	..()

/mob/living/simple_animal/hostile/assistant/ListTargets(var/override = -1)

	var/list/L = ..()
	for(var/atom/A in L)
		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = A
			if(H.name == "Unknown" || ((H.get_assignment() == "Assistant") && !(H in enemy_list)))
				L -= H
	return L

//Adds attacker to enemy_list and makes him the new target
/mob/living/simple_animal/hostile/assistant/attackby(obj/O as obj, mob/user as mob)
	..()
	attacked(user)

/mob/living/simple_animal/hostile/assistant/attack_hand(mob/user as mob)
	..()
	attacked(user)

/mob/living/simple_animal/hostile/assistant/proc/attacked(var/mob/attacker)
	if(!(attacker in enemy_list))
		enemy_list += attacker
	if(attacker != target)
		GiveTarget(attacker)
