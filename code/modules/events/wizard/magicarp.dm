/datum/round_event_control/wizard/magicarp //these fish is loaded
	name = "Magicarp"
	weight = 1
	typepath = /datum/round_event/wizard/magicarp
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/magicarp
	announceWhen	= 3
	startWhen = 50

/datum/round_event/wizard/magicarp/setup()
	startWhen = rand(40, 60)

/datum/round_event/wizard/magicarp/announce(fake)
	priority_announce("Unknown magical entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")

/datum/round_event/wizard/magicarp/start()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(5))
			new /mob/living/simple_animal/hostile/carp/ranged/chaos(C.loc)
		else
			new /mob/living/simple_animal/hostile/carp/ranged(C.loc)

/mob/living/simple_animal/hostile/carp/ranged
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
	maxHealth = 50
	health = 50
	gold_core_spawnable = NO_SPAWN
	random_color = FALSE
	var/allowed_projectile_types = list(/obj/item/projectile/magic/change, /obj/item/projectile/magic/animate, /obj/item/projectile/magic/resurrection,
	/obj/item/projectile/magic/teleport, /obj/item/projectile/magic/door, /obj/item/projectile/magic/aoe/fireball, /obj/item/projectile/magic/spellblade,
	/obj/item/projectile/magic/arcane_barrage, /obj/item/projectile/magic/death)

/mob/living/simple_animal/hostile/carp/ranged/Initialize()
	projectiletype = pick(allowed_projectile_types)
	. = ..()

/mob/living/simple_animal/hostile/carp/ranged/chaos
	name = "chaos magicarp"
	desc = "50% carp, 100% magic, 150% horrible."
	color = "#00FFFF"
	maxHealth = 75
	health = 75
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/carp/ranged/chaos/Shoot()
	projectiletype = pick(allowed_projectile_types)
	..()

	// these are for the xenobio gold slime pool

/mob/living/simple_animal/hostile/carp/xenobiology/ranged
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
	maxHealth = 50
	health = 50
	gold_core_spawnable = HOSTILE_SPAWN
	var/xeno_projectile_types = list(/obj/item/projectile/magic/change, /obj/item/projectile/magic/animate, /obj/item/projectile/magic/resurrection,
	/obj/item/projectile/magic/teleport, /obj/item/projectile/magic/door, /obj/item/projectile/magic/aoe/fireball, /obj/item/projectile/magic/spellblade,
	/obj/item/projectile/magic/arcane_barrage) //and all this code just to remove a single bolt
	..()
	
/mob/living/simple_animal/hostile/carp/xenobiology/ranged/Initialize()
	projectiletype = pick(xeno_projectile_types)
	..()

/mob/living/simple_animal/hostile/carp/xenobiology/ranged/chaos/Shoot()
	projectiletype = pick(xeno_projectile_types)
	..()

/mob/living/simple_animal/hostile/carp/xenobiology/ranged/chaos
	name = "chaos magicarp"
	desc = "50% carp, 100% magic, 150% horrible."
	color = "#00FFFF"
	maxHealth = 75
	health = 75
	gold_core_spawnable = HOSTILE_SPAWN
	..()
