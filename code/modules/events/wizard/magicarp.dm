/datum/round_event_control/wizard/magicarp //these fish is loaded
	name = "Magicarp"
	weight = 1
	typepath = /datum/round_event/wizard/magicarp/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/magicarp/
	announceWhen	= 3
	startWhen = 50

/datum/round_event/wizard/magicarp/setup()
	startWhen = rand(40, 60)

/datum/round_event/wizard/magicarp/announce()
	priority_announce("Unknown magical entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/wizard/magicarp/start()
	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			if(prob(5))
				new /mob/living/simple_animal/hostile/carp/ranged/chaos(C.loc)
			else
				new /mob/living/simple_animal/hostile/carp/ranged(C.loc)

/mob/living/simple_animal/hostile/carp_ranged
	name = "magicarp"
	desc = "50% magic, 50% carp, 100% horrible."
	icon_state = "magicarp"
	icon_living = "magicarp"
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	ranged = 1
	retreat_distance = 2
	minimum_distance = 0 //Between shots they can and will close in to nash
	projectiletype = /obj/item/projectile/magic
	projectilesound = 'sound/weapons/emitter.ogg'
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")

	//Space carp aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	faction = list("carp")
	flying = 1
	pressure_resistance = 200
	gold_core_spawnable = 1
	maxHealth = 50
	health = 50

/mob/living/simple_animal/hostile/carp_ranged/New()
	projectiletype = pick(typesof(initial(projectiletype)))
	..()

/mob/living/simple_animal/hostile/carp_ranged/chaos
	name = "chaos magicarp"
	desc = "50% carp, 100% magic, 150% horrible."
	color = "#00FFFF"
	maxHealth = 75
	health = 75

/mob/living/simple_animal/hostile/carp_ranged/chaos/Shoot()
	projectiletype = pick(typesof(initial(projectiletype)))
	..()