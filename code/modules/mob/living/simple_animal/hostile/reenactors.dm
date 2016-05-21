/*
-!WARNING!-
-POTENTIAL TRIGGER-INDUCING ITEMS AHEAD-
-TREAD WITH CAUTION-
*/

/mob/living/simple_animal/hostile/wwii
	name = "World War II Reenactor"
	desc = "A VERY enthusiastic WWII reenactor."
	icon_state = "nsoldier"
	icon_living = "nsoldier"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = 1
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "harm"
	loot = list(/obj/effect/mob_spawn/human/wwii)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("german")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1

/mob/living/simple_animal/hostile/wwii/ranged
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "nsoldierranged"
	icon_living = "nsoldierranged"
	casingtype = /obj/item/ammo_casing/c45nostamina
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'

/mob/living/simple_animal/hostile/wwii/melee
	name = "Hulking World War II Reenactor"
	icon_state = "nsoldierbuff"
	icon_living = "nsoldierbuff"
	stat_attack = 0
	speed = 4
	maxHealth = 200
	health = 200
	force_threshold = 10
	harm_intent_damage = 25
	melee_damage_lower = 25
	melee_damage_upper = 30
	environment_smash = 2
	attacktext = "slams"
	deathmessage = "The Reenactor's body collapses in on itself from the strain!"
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/wwii/melee/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(40))
			C.Weaken(3)
			C.adjustBruteLoss(10)
			C.visible_message("<span class='danger'>\The [src] smashes \the [C] into the ground!</span>", \
					"<span class='userdanger'>\The [src] smashes you into the ground!</span>")
			src.say(pick("RAAAAAGGHHHH!!!","AAAARRRGGHHHH!!!","RRRAAUUUGGHH!!!"))


/mob/living/simple_animal/hostile/wwii/bomber
	name = "Mini-Führer"
	desc = "A small, robotic recreation of the Führer himself; it seems like he wants to tell you something."
	icon_state = "miniheil"
	icon_living = "miniheil"
	speed = 1
	maxHealth = 25
	health = 25
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 7
	attacktext = "heils"
	deathmessage = "The Mini-Führer explodes!"
	loot = list(/obj/effect/gibspawner/robot)

/mob/living/simple_animal/hostile/wwii/bomber/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(90))
			C.Weaken(2)
			src.say("HEIL HITLER!")
			explosion(src, 0, 0, 2, 3, 2)
			src.gib()

/*
-YOU HAVE SAFETLY PASSED THE POTENTIALLY-TRIGGERING CONTENT-
-PLEASE RESUME NORMAL, POLITICALLY CORRECT ACTIVITY-
*/
