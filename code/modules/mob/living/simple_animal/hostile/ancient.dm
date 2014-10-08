/mob/living/simple_animal/hostile/ancient
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "ancient_assistant"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "robusts"
	speed = 0
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	var/drop1
	var/drop2
	attacktext = "punches"
	a_intent = "harm"
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atmos_damage = 15
	faction = list("ancient")
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/ancient/Die()
	..()
	if(drop1)
		new drop1 (src.loc)
	if(drop2)
		new drop2 (src.loc)
	return

/mob/living/simple_animal/hostile/ancient/security
	name = "Security Officer"
	desc = "An ancient security officer from times long past. He doesn't like you very much."
	icon_state = "ancient_security"
	icon_living = "ancient_security"
	icon_dead = "ancient_security_dead"
	drop1 = /obj/item/weapon/gun/energy/taser/old
	drop2 = /obj/item/device/multitool/old
/mob/living/simple_animal/hostile/ancient/assistant
	name = "Assistant"
	desc = "An ancient assistant from times long past. He doesn't like you very much."
	icon_state = "ancient_assistant"
	icon_living = "ancient_assistant"
	icon_dead = "ancient_assistant_dead"
	drop1 = /obj/item/device/multitool/old
/mob/living/simple_animal/hostile/ancient/spaceman
	name = "Spaceman"
	desc = "An ancient spaceman from times long past. He doesn't like you very much."
	icon_state = "ancient_spaceman"
	icon_living = "ancient_spaceman"
	icon_dead = "ancient_spaceman_dead"
	drop1 = /obj/item/weapon/gun/energy/taser/old
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0