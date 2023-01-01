///////////////Base Mob////////////

/obj/effect/light_emitter/red_energy_sword //used so there's a combination of both their head light and light coming off the energy sword
	set_luminosity = 2
	set_cap = 2.5
	light_color = COLOR_SOFT_RED

/mob/living/basic/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 100
	health = 100
	basic_mob_flags = DEL_ON_DEATH
	speed = 1.1
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
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
	
	var/loot = list(/obj/effect/mob_spawn/corpse/human/syndicatesoldier)

/mob/living/basic/syndicate/Initialize(mapload)
	. = ..()
	if(LAZYLEN(loot))
		AddElement(/datum/element/death_drops, loot)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)

/mob/living/basic/syndicate/space
	icon_state = "syndicate_space"
	icon_living = "syndicate_space"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	loot = list(/obj/effect/gibspawner/human)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0

/mob/living/basic/syndicate/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/space/stormtrooper
	icon_state = "syndicate_stormtrooper"
	icon_living = "syndicate_stormtrooper"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/basic/syndicate/melee //dude with a knife and no shields
	melee_damage_lower = 15
	melee_damage_upper = 15
	icon_state = "syndicate_knife"
	icon_living = "syndicate_knife"
	loot = list(/obj/effect/gibspawner/human)
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	var/projectile_deflect_chance = 0

/mob/living/basic/syndicate/melee/bullet_act(obj/projectile/projectile)
	if(prob(projectile_deflect_chance))
		visible_message(span_danger("[src] blocks [projectile] with its shield!"))
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/basic/syndicate/melee/space
	icon_state = "syndicate_space_knife"
	icon_living = "syndicate_space_knife"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0

/mob/living/basic/syndicate/melee/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/melee/space/stormtrooper
	icon_state = "syndicate_stormtrooper_knife"
	icon_living = "syndicate_stormtrooper_knife"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/basic/syndicate/melee/sword
	melee_damage_lower = 30
	melee_damage_upper = 30
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	attack_sound = 'sound/weapons/blade1.ogg'
	armour_penetration = 35
	light_color = COLOR_SOFT_RED
	projectile_deflect_chance = 50

/mob/living/basic/syndicate/melee/sword/Initialize(mapload)
	. = ..()
	set_light(2)

/mob/living/basic/syndicate/melee/sword/space
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	projectile_deflect_chance = 50
	var/obj/effect/light_emitter/red_energy_sword/sord

/mob/living/basic/syndicate/melee/sword/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	sord = new(src)
	set_light(4)
/mob/living/basic/syndicate/melee/sword/space/Destroy()
	QDEL_NULL(sord)
	return ..()

/mob/living/basic/syndicate/melee/sword/space/stormtrooper
	icon_state = "syndicate_stormtrooper_sword"
	icon_living = "syndicate_stormtrooper_sword"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 50

///////////////Guns////////////

/mob/living/basic/syndicate/ranged
	icon_state = "syndicate_pistol"
	icon_living = "syndicate_pistol"
	var/casingtype = /obj/item/ammo_casing/c9mm
	var/projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	loot = list(/obj/effect/gibspawner/human)
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged

/mob/living/basic/syndicate/ranged/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ranged_attacks, casingtype, projectilesound)

/mob/living/basic/syndicate/ranged/infiltrator //shuttle loan event
	projectilesound = 'sound/weapons/gun/smg/shot_suppressed.ogg'
	loot = list(/obj/effect/mob_spawn/corpse/human/syndicatesoldier)

/mob/living/basic/syndicate/ranged/space
	icon_state = "syndicate_space_pistol"
	icon_living = "syndicate_space_pistol"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0

/mob/living/basic/syndicate/ranged/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/ranged/space/stormtrooper
	icon_state = "syndicate_stormtrooper_pistol"
	icon_living = "syndicate_stormtrooper_pistol"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/basic/syndicate/ranged/smg
	icon_state = "syndicate_smg"
	icon_living = "syndicate_smg"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged/burst

/mob/living/basic/syndicate/ranged/smg/pilot //caravan ambush ruin
	name = "Syndicate Salvage Pilot"
	loot = list(/obj/effect/mob_spawn/corpse/human/syndicatesoldier)

/mob/living/basic/syndicate/ranged/smg/space
	icon_state = "syndicate_space_smg"
	icon_living = "syndicate_space_smg"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0

/mob/living/basic/syndicate/ranged/smg/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/ranged/smg/space/stormtrooper
	icon_state = "syndicate_stormtrooper_smg"
	icon_living = "syndicate_stormtrooper_smg"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

/mob/living/basic/syndicate/ranged/shotgun
	icon_state = "syndicate_shotgun"
	icon_living = "syndicate_shotgun"
	casingtype = /obj/item/ammo_casing/shotgun/buckshot //buckshot (up to 72.5 brute) fired in a two-round burst
	ai_controller = /datum/ai_controller/basic_controller/syndicate/ranged/shotgunner

/mob/living/basic/syndicate/ranged/shotgun/space
	icon_state = "syndicate_space_shotgun"
	icon_living = "syndicate_space_shotgun"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	speed = 1

/mob/living/basic/syndicate/ranged/shotgun/space/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	set_light(4)

/mob/living/basic/syndicate/ranged/shotgun/space/stormtrooper
	icon_state = "syndicate_stormtrooper_shotgun"
	icon_living = "syndicate_stormtrooper_shotgun"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250

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
	ai_controller = /datum/ai_controller/basic_controller/viscerator

/mob/living/basic/viscerator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming)
