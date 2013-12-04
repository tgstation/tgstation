/mob/living/simple_animal/hostile/assistant
	name = "Assistant"
	desc = "Standard-issue Nanotrasen Assistant, ready to robust."
	icon_state = "assistant"
	icon_living = "assistant"
	icon_dead = "assistant_dead"
	speak = list("VIVA LA REVOLUTION!", "LYNCH HE!", "CAPTAIN'S A COMDOM", "GIBE ALL ACCESS PLS", "GREY PRIDE GALAXY WIDE!", "SHITCURITY!", "GOTTA GET MY VALIDS", "ONE DAY WHILE ANDY WAS MASTURBATING", "FARTFARTFARJDKAFEJKFDK")
	speak_chance = 5
	turns_per_move = 5
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "robusts"
	attack_sound = 'sound/weapons/smash.ogg'

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	var/corpse = /obj/effect/landmark/mobcorpse/assistant
	var/weapon1 = /obj/item/weapon/storage/toolbox/mechanical
	var/enemy_list = list()

	faction = "greytide"
	idle_env_destroyer = 1
	wall_smash = 1

/mob/living/simple_animal/hostile/assistant/New()
	..()
	name += " [pick(last_names)]"

/mob/living/simple_animal/hostile/assistant/Die()
	..()
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	del src
	return


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