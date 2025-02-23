/// Abductor troopers
/mob/living/basic/trooper/abductor
	name = "Abductor Agent"
	desc = "Mezaflorp?"
	faction = list(ROLE_SYNDICATE)
	loot = list(/obj/effect/mob_spawn/corpse/human/abductor)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/abductor

/mob/living/basic/trooper/abductor/melee
	melee_damage_lower = 15
	melee_damage_upper = 15
	loot = list(/obj/effect/gibspawner/human)
	attack_verb_continuous = "beats"
	attack_verb_simple = "beat"
	attack_sound = 'sound/items/weapons/egloves.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	r_hand = /obj/item/melee/baton/abductor
	var/projectile_deflect_chance = 0

/mob/living/basic/trooper/abductor/ranged
	loot = list(/obj/effect/gibspawner/human)
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	r_hand = /obj/item/gun/energy/alien
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/energy/lasergun
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/items/weapons/laser2.ogg'
	/// number of burst shots
	var/burst_shots = 1
	/// Time between taking shots
	var/ranged_cooldown = 5 SECONDS

/mob/living/basic/trooper/abductor/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = casingtype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)
