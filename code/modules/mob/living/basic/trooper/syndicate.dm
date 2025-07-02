/// Syndicate troopers
/mob/living/basic/trooper/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	faction = list(ROLE_SYNDICATE)
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatesoldier
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatesoldier

/mob/living/basic/trooper/syndicate/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	corpse = /obj/effect/gibspawner/human
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/trooper/syndicate/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/melee //dude with a knife and no shields
	melee_damage_lower = 15
	melee_damage_upper = 15
	corpse = /obj/effect/gibspawner/human
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	r_hand = /obj/item/knife/combat/survival
	var/projectile_deflect_chance = 0

/mob/living/basic/trooper/syndicate/melee/bullet_act(obj/projectile/projectile)
	if(prob(projectile_deflect_chance))
		visible_message(span_danger("[src] blocks [projectile] with its shield!"))
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/basic/trooper/syndicate/melee/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/melee/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/trooper/syndicate/melee/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/melee/sword
	melee_damage_lower = 30
	melee_damage_upper = 30
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/items/weapons/blade1.ogg'
	armour_penetration = 35
	projectile_deflect_chance = 50
	light_range = 2
	light_power = 2.5
	light_color = COLOR_SOFT_RED
	r_hand = /obj/item/melee/energy/sword/saber/red
	l_hand = /obj/item/shield/energy

/mob/living/basic/trooper/syndicate/melee/sword/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	projectile_deflect_chance = 50
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/melee/sword/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 50
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

///////////////Guns////////////

/mob/living/basic/trooper/syndicate/ranged
	corpse = /obj/effect/gibspawner/human
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	/// Type of bullet we use
	var/casingtype = /obj/item/ammo_casing/c9mm
	/// Sound to play when firing weapon
	var/projectilesound = 'sound/items/weapons/gun/pistol/shot.ogg'
	/// number of burst shots
	var/burst_shots
	/// Time between taking shots
	var/ranged_cooldown = 1 SECONDS

/mob/living/basic/trooper/syndicate/ranged/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/ranged_attacks,\
		casing_type = casingtype,\
		projectile_sound = projectilesound,\
		cooldown_time = ranged_cooldown,\
		burst_shots = burst_shots,\
	)
	if (ranged_cooldown <= 1 SECONDS)
		AddComponent(/datum/component/ranged_mob_full_auto)

/mob/living/basic/trooper/syndicate/ranged/infiltrator //shuttle loan event
	projectilesound = 'sound/items/weapons/gun/smg/shot_suppressed.ogg'
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatesoldier

/mob/living/basic/trooper/syndicate/ranged/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/ranged/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/trooper/syndicate/ranged/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/ranged/smg
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/items/weapons/gun/smg/shot.ogg'
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/burst
	burst_shots = 3
	ranged_cooldown = 3 SECONDS
	r_hand = /obj/item/gun/ballistic/automatic/c20r

///Spawns from an emagged orion trail machine set to kill the player.
/mob/living/basic/trooper/syndicate/ranged/smg/orion
	name = "spaceport security"
	desc = "Premier corporate security forces for all spaceports found along the Orion Trail."
	faction = list(FACTION_ORION)
	corpse = null

/mob/living/basic/trooper/syndicate/ranged/smg/pilot //caravan ambush ruin
	name = "Syndicate Salvage Pilot"
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatepilot
	corpse = /obj/effect/mob_spawn/corpse/human/syndicatepilot

/mob/living/basic/trooper/syndicate/ranged/smg/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/ranged/smg/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/trooper/syndicate/ranged/smg/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/trooper/syndicate/ranged/shotgun
	casingtype = /obj/item/ammo_casing/shotgun/buckshot //buckshot (up to 72.5 brute) fired in a two-round burst
	ai_controller = /datum/ai_controller/basic_controller/trooper/ranged/shotgunner
	ranged_cooldown = 3 SECONDS
	burst_shots = 2
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog

/mob/living/basic/trooper/syndicate/ranged/shotgun/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/trooper/syndicate/ranged/shotgun/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/trooper/syndicate/ranged/shotgun/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

///////////////Misc////////////

/mob/living/basic/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE | PASSMOB
	combat_mode = TRUE
	mob_biotypes = MOB_ROBOTIC
	basic_mob_flags = DEL_ON_DEATH
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 700
	unsuitable_cold_damage = 0
	health = 25
	maxHealth = 25
	melee_damage_lower = 15
	melee_damage_upper = 15
	wound_bonus = -10
	exposed_wound_bonus = 20
	sharpness = SHARP_EDGED
	obj_damage = 0
	attack_verb_continuous = "cuts"
	attack_verb_simple = "cut"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list(ROLE_SYNDICATE)
	mob_size = MOB_SIZE_TINY
	limb_destroyer = 1
	speak_emote = list("states")
	bubble_icon = "syndibot"
	gold_core_spawnable = HOSTILE_SPAWN
	death_message = "is smashed into pieces!"
	ai_controller = /datum/ai_controller/basic_controller/trooper/viscerator

/mob/living/basic/viscerator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming)
