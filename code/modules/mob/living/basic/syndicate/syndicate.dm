///////////////Base Mob////////////

/mob/living/basic/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon = 'icons/mob/simple/simple_human.dmi'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 100
	health = 100
	basic_mob_flags = DEL_ON_DEATH
	speed = 1.1
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	unsuitable_atmos_damage = 7.5
	unsuitable_cold_damage = 7.5
	unsuitable_heat_damage = 7.5
	faction = list(ROLE_SYNDICATE)
	ai_controller = /datum/ai_controller/basic_controller/syndicate
	/// Loot this mob drops on death.
	var/loot = list(/obj/effect/mob_spawn/corpse/human/syndicatesoldier)
	/// Path of the mob spawner we base the mob's visuals off of.
	var/mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatesoldier
	/// Path of the right hand held item we give to the mob's visuals.
	var/r_hand
	/// Path of the left hand held item we give to the mob's visuals.
	var/l_hand

/mob/living/basic/syndicate/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = mob_spawner, r_hand = r_hand, l_hand = l_hand)
	if(LAZYLEN(loot))
		AddElement(/datum/element/death_drops, loot)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)

/mob/living/basic/syndicate/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	loot = list(/obj/effect/gibspawner/human)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/syndicate/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/syndicate/melee //dude with a knife and no shields
	melee_damage_lower = 15
	melee_damage_upper = 15
	loot = list(/obj/effect/gibspawner/human)
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	r_hand = /obj/item/knife/combat/survival
	var/projectile_deflect_chance = 0

/mob/living/basic/syndicate/melee/bullet_act(obj/projectile/projectile)
	if(prob(projectile_deflect_chance))
		visible_message(span_danger("[src] blocks [projectile] with its shield!"))
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/basic/syndicate/melee/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/syndicate/melee/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/melee/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/syndicate/melee/sword
	melee_damage_lower = 30
	melee_damage_upper = 30
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	armour_penetration = 35
	projectile_deflect_chance = 50
	light_range = 2
	light_power = 2.5
	light_color = COLOR_SOFT_RED
	r_hand = /obj/item/melee/energy/sword/saber/red
	l_hand = /obj/item/shield/energy

/mob/living/basic/syndicate/melee/sword/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	projectile_deflect_chance = 50
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/syndicate/melee/sword/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

/mob/living/basic/syndicate/melee/sword/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 50
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

///////////////Guns////////////

/mob/living/basic/syndicate/ranged
	loot = list(/obj/effect/gibspawner/human)
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	var/casingtype = /obj/item/ammo_casing/c9mm
	var/projectilesound = 'sound/weapons/gun/pistol/shot.ogg'

/mob/living/basic/syndicate/ranged/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ranged_attacks, casingtype, projectilesound)

/mob/living/basic/syndicate/ranged/infiltrator //shuttle loan event
	projectilesound = 'sound/weapons/gun/smg/shot_suppressed.ogg'
	loot = list(/obj/effect/mob_spawn/corpse/human/syndicatesoldier)

/mob/living/basic/syndicate/ranged/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/syndicate/ranged/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/ranged/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/syndicate/ranged/smg
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged/burst
	r_hand = /obj/item/gun/ballistic/automatic/c20r

/mob/living/basic/syndicate/ranged/smg/pilot //caravan ambush ruin
	name = "Syndicate Salvage Pilot"
	loot = list(/obj/effect/mob_spawn/corpse/human/syndicatepilot)
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatepilot

/mob/living/basic/syndicate/ranged/smg/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/syndicate/ranged/smg/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/ranged/smg/space/stormtrooper
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatestormtrooper

/mob/living/basic/syndicate/ranged/shotgun
	casingtype = /obj/item/ammo_casing/shotgun/buckshot //buckshot (up to 72.5 brute) fired in a two-round burst
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged/shotgunner
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog

/mob/living/basic/syndicate/ranged/shotgun/space
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	speed = 1
	mob_spawner = /obj/effect/mob_spawn/corpse/human/syndicatecommando

/mob/living/basic/syndicate/ranged/shotgun/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/ranged/shotgun/space/stormtrooper
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
	bare_wound_bonus = 20
	sharpness = SHARP_EDGED
	obj_damage = 0
	attack_verb_continuous = "cuts"
	attack_verb_simple = "cut"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	faction = list(ROLE_SYNDICATE)
	mob_size = MOB_SIZE_TINY
	limb_destroyer = 1
	speak_emote = list("states")
	bubble_icon = "syndibot"
	gold_core_spawnable = HOSTILE_SPAWN
	death_message = "is smashed into pieces!"
	ai_controller = /datum/ai_controller/basic_controller/syndicate/viscerator

/mob/living/basic/viscerator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming)
