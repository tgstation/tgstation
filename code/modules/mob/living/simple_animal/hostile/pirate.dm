/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100

	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	unsuitable_atmos_damage = 15
	var/corpse = /obj/effect/landmark/mobcorpse/pirate
	var/weapon1 = /obj/item/weapon/melee/energy/sword/pirate

	faction = list("pirate")

/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "piratemelee_dead"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/beam
	corpse = /obj/effect/landmark/mobcorpse/pirate/ranged
	weapon1 = /obj/item/weapon/gun/energy/laser

/mob/living/simple_animal/hostile/russian/ranged/New()
	if(prob(50) && ispath(weapon1,/obj/item/weapon/gun/projectile/revolver/mateba)) //to preserve varedits
		weapon1 = /obj/item/weapon/gun/projectile/shotgun/boltaction
		casingtype = /obj/item/ammo_casing/a762
	..()


/mob/living/simple_animal/hostile/russian/death(gibbed)
	..(1)
	visible_message("[src] stops moving.")
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	ghostize()
	qdel(src)
	return
