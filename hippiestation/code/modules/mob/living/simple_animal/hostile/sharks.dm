//shameless copies of carps.

/mob/living/simple_animal/hostile/shark
	name = "Space Shark"
	desc = "The best terror of the seas, next to the kraken."
	icon_state = "shark"
	icon_living = "shark"
	icon = 'hippiestation/icons/mob/sharks.dmi'
	icon_dead = "shark_dead"
	icon_gib = "carp_gib"
	environment_smash = 0
	speak_chance = 0
	turns_per_move = 3
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	speed = 0
	maxHealth = 75
	health = 75
	harm_intent_damage = 18
	melee_damage_lower = 18
	melee_damage_upper = 18
	attacktext = "maims"
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = 1
	//Space shark aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	faction = list("shark")

/mob/living/simple_animal/hostile/shark/Process_Spacemove(var/movement_dir = 0)
	return 1   //No drifting in space for space sharks....either!

/mob/living/simple_animal/hostile/shark/FindTarget()
	. = ..()
	if(.)
		emote("me", 1, "growls at [.]!")

/mob/living/simple_animal/hostile/shark/AttackingTarget()
	. =..()
	var/mob/living/carbon/L = .
	if(istype(L))
		if(prob(25))
			L.Knockdown(20)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")


/mob/living/simple_animal/hostile/shark/laser
	name = "Laser-Shark"
	desc = "NOW we've jumped the shark."
	icon_state = "lasershark"
	icon_living = "lasershark"
	icon_dead = "lasershark_dead"
	icon_gib = "carp_gib"
	ranged = 1
	retreat_distance = 3
	minimum_distance = 0 //Between shots they can and will close in to nash
	projectiletype = /obj/item/projectile/beam/laser/heavylaser
	projectilesound = 'sound/weapons/lasercannonfire.ogg'
	maxHealth = 50
	health = 50

/mob/living/simple_animal/hostile/shark/kawaii
	name = "Kawaii Shark"
	desc = "Senpai~ Notice me.."
	icon_state = "kawaiishark"
	icon_living = "kawaiishark"
	icon_dead = "kawaiishark_dead"
	speak = list("Oh Senpai","Notice me senpai!","Oh my...","Kawaii~")
	speak_emote = list("lovingly says","says")
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/mob/living/simple_animal/butterfly = 3)
	maxHealth = 50
	health = 50
	maxbodytemp = INFINITY

	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "violently hugs"
	vision_range = 0

/mob/living/simple_animal/hostile/shark/kawaii/death()
	visible_message("<span class='name'>[src]</span> says : Senpai, you noticed~!")
	LoseAggro()
	..()
	walk(src, 0)