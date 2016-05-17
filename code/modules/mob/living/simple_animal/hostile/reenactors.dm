/*
-!WARNING!-
-POTENTIAL TRIGGER-INDUCING ITEMS AHEAD-
-TREAD WITH CAUTION-
*/

/mob/living/simple_animal/hostile/wwii
	name = "New Wehrmacht Soldier"
	desc = "A soldier of the New Wehrmacht, a combined syndicate of old-Earth fascist ideals."
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
	name = "Hulking New Wehrmacht Soldier"
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
	deathmessage = "The New Wehrmacht's body collapses in on itself from the strain!"
	loot = list(/obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/wwii/melee/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/C = target
		if(prob(40))
			C.Weaken(3)
			C.adjustBruteLoss(10)
			C.visible_message("<span class='danger'>\The [src] smashes \the [C] into the ground!</span>", \
					"<span class='userdanger'>\The [src] smashes you into the ground!</span>")
			src.say(pick("RAAAAAGGHHHH!!!","AAAARRRGGHHHH!!!","RRRAAUUUGGHH!!!"))

/mob/living/simple_animal/hostile/wwii/bomber
	name = "Porta-Bomb"
	desc = "A small robotic figure designed as a front-line bomber, meant to strike fear into opposing groups."
	icon_state = "miniheil"
	icon_living = "miniheil"
	speed = 1
	maxHealth = 25
	health = 25
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 7
	attacktext = "heils"
	deathmessage = "The Porta-Bomb explodes!"
	loot = list(/obj/effect/gibspawner/robot)

/mob/living/simple_animal/hostile/wwii/bomber/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(90))
			C.Weaken(2)
			src.say("HEIL!")
			explosion(src, 0, 0, 2, 3, 2)
			src.gib()

/*
 *Mecha Hitler
 */

/mob/living/simple_animal/hostile/syndicate/mecha_pilot/roboheil //hitler's head in a jar with a spider walker sort of thing
	name = "Cyborg Hitler"
	icon_state = "roboheil"
	icon_living = "roboheil"
	desc = "A horrifying mixture of scientific advancement and fasicst ideals. Freedom at its very core is in danger as long as this mechanical menace lives."
	maxHealth = 500
	health = 500
	faction = list("german")
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	deathmessage = "Mecha Hitler's body activates its self-destruct function!"
	loot = list(/obj/effect/gibspawner/robot, /mob/living/simple_animal/hostile/wwii/brain)
	wanted_objects = list()
	search_objects = 0
	spawn_mecha_type = /obj/mecha/combat/marauder/mauler/roboh

/mob/living/simple_animal/hostile/wwii/brain
	name = "Hitler's Head in a Jar"
	icon_state = "robobrain"
	icon_living = "robobrain"
	desc = "Don't let it get away!"
	loot = list(/obj/effect/gibspawner/robot)
	maxHealth = 25
	health = 25


/*
 *Mecha Hitler's Mech
 */

/obj/mecha/combat/marauder/mauler/roboh
	name = "\improper Mecha-Hitler"
	desc = "A heavily modified marauder mech with reinforced reflective plating."
	icon_state = "mauler"
	health = 4000
	deflect_chance = 40
	damage_absorption = list("brute"=0.6,"fire"=0.3,"bullet"=0.7,"laser"=0.4,"energy"=0.5,"bomb"=0.5)
	force = 75
	operation_req_access = list(access_syndicate)
	wreckage = /obj/structure/mecha_wreckage/mauler


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack/tier2
	name = "\improper SRM-16 missile rack"
	desc = "A modified version of the SMR-8, equipped with an additional 8 racks and a more powerful missile."
	icon_state = "mecha_missilerack"
	projectile = /obj/item/missile/tier2
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 16
	projectile_energy_cost = 1000
	equip_cooldown = 60

/obj/item/missile/tier2
	throwforce = 25

/obj/item/missile/tier2/throw_impact(atom/hit_atom)
	if(primed)
		explosion(hit_atom, 0, 0, 4, 6, 3)
		qdel(src)
	else
		..()


/obj/mecha/combat/marauder/mauler/roboh/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack/tier2
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	return

/*
-YOU HAVE SAFETLY PASSED THE POTENTIALLY-TRIGGERING CONTENT-
-PLEASE RESUME NORMAL, POLITICALLY CORRECT ACTIVITY-
*/
