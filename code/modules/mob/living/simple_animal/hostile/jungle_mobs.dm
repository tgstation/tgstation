/mob/living/simple_animal/hostile/jungle
	vision_range = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("jungle")
	weather_immunities = list("acid")
	obj_damage = 30
	environment_smash = 2
	minbodytemp = 0
	maxbodytemp = 450
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = INTENT_HARM
	see_in_dark = 4
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE



//Mega arachnid

/mob/living/simple_animal/hostile/jungle/mega_arachnid
	name = "mega arachnid"
	desc = "Though physically imposing, it prefers to ambush its prey, and it will only engage with an already crippled opponent."
	melee_damage_lower = 30
	melee_damage_upper = 30
	maxHealth = 300
	health = 300
	speed = 1
	ranged = 1
	pixel_x = -16
	move_to_delay = 10
	aggro_vision_range = 9
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	ranged_cooldown_time = 60
	projectiletype = /obj/item/projectile/mega_arachnid
	projectilesound = 'sound/weapons/pierce.ogg'
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "arachnid"
	icon_living = "arachnid"
	icon_dead = "dead_purple"
	alpha = 50

/mob/living/simple_animal/hostile/jungle/mega_arachnid/Life()
	..()
	if(target && ranged_cooldown > world.time && iscarbon(target))
		var/mob/living/carbon/C = target
		if(!C.legcuffed && C.health < 50)
			retreat_distance = 9
			minimum_distance = 9
			alpha = 125
			return
	retreat_distance = 0
	minimum_distance = 0
	alpha = 255


/mob/living/simple_animal/hostile/jungle/mega_arachnid/Aggro()
	..()
	alpha = 255

/mob/living/simple_animal/hostile/jungle/mega_arachnid/LoseAggro()
	..()
	alpha = 50

/obj/item/projectile/mega_arachnid
	name = "flesh snare"
	nodamage = 1
	damage = 0
	icon_state = "tentacle_end"

/obj/item/projectile/mega_arachnid/on_hit(atom/target, blocked = 0)
	if(iscarbon(target) && blocked < 100)
		var/obj/item/weapon/restraints/legcuffs/beartrap/mega_arachnid/B = new /obj/item/weapon/restraints/legcuffs/beartrap/mega_arachnid(get_turf(target))
		B.Crossed(target)
	..()

/obj/item/weapon/restraints/legcuffs/beartrap/mega_arachnid
	name = "fleshy restraints"
	desc = "Used by mega arachnids to immobilize their prey."
	flags = DROPDEL
	icon_state = "tentacle_end"
	icon = 'icons/obj/projectiles.dmi'