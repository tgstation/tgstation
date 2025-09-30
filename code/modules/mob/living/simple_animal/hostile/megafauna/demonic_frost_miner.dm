#define FROST_MINER_SHOULD_ENRAGE (health <= maxHealth*0.25 && !enraged)
GLOBAL_LIST_EMPTY(frost_miner_prisms)

/*

Difficulty: Extremely Hard

*/

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner
	name = "demonic-frost miner"
	desc = "An extremely well-geared miner, driven crazy or possessed by the demonic forces here, either way a terrifying enemy."
	health = 1500
	maxHealth = 1500
	icon_state = "demonic_miner"
	icon_living = "demonic_miner"
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	attack_verb_continuous = "pummels"
	attack_verb_simple = "pummel"
	attack_sound = 'sound/items/weapons/sonic_jackhammer.ogg'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_SPECIAL|MOB_MINING
	light_color = COLOR_LIGHT_GRAYISH_RED
	movement_type = GROUND
	weather_immunities = list(TRAIT_SNOWSTORM_IMMUNE)
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage_lower = 10
	melee_damage_upper = 10
	vision_range = 18 // large vision range so combat doesn't abruptly end when someone runs a bit away
	rapid_melee = 4
	speed = 20
	move_to_delay = 20
	gps_name = "Bloodchilling Signal"
	ranged = TRUE
	crusher_loot = /obj/item/crusher_trophy/ice_block_talisman
	loot = list(/obj/effect/decal/remains/plasma, /obj/item/ice_energy_crystal)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	achievement_type = /datum/award/achievement/boss/demonic_miner_kill
	crusher_achievement_type = /datum/award/achievement/boss/demonic_miner_crusher
	score_achievement_type = /datum/award/score/demonic_miner_score
	death_message = "falls to the ground, decaying into plasma particles."
	death_sound = SFX_BODYFALL
	footstep_type = FOOTSTEP_MOB_HEAVY
	summon_line = "I'M WIDE AWAKE! AND YOU'RE WIIIIIIIDE OPEN!"
	/// If the demonic frost miner is in its enraged state
	var/enraged = FALSE
	/// If the demonic frost miner is currently transforming to its enraged state
	var/enraging = FALSE
	/// Frost orbs ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/frost_orbs
	/// Hard version of frost orbs
	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/shrapnel/strong/hard_frost_orbs
	/// Snowball Machine gun Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/snowball_machine_gun
	/// Hard Snowball Machine gun Ability
	var/datum/action/cooldown/mob_cooldown/direct_and_aoe/hard_snowball_machine_gun
	/// Ice Shotgun Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/ice_shotgun
	/// Hard Ice Shotgun Ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/pattern/circular/hard_ice_shotgun

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Initialize(mapload)
	. = ..()
	frost_orbs = new(src)
	hard_frost_orbs = new(src)
	snowball_machine_gun = new(src)
	hard_snowball_machine_gun = new(src)
	ice_shotgun = new(src)
	hard_ice_shotgun = new(src)
	frost_orbs.Grant(src)
	hard_frost_orbs.Grant(src)
	snowball_machine_gun.Grant(src)
	hard_snowball_machine_gun.Grant(src)
	ice_shotgun.Grant(src)
	hard_ice_shotgun.Grant(src)
	for(var/obj/structure/frost_miner_prism/prism_to_set in GLOB.frost_miner_prisms)
		prism_to_set.set_prism_light(LIGHT_COLOR_BLUE, 5)
	RegisterSignal(src, COMSIG_MOB_ABILITY_STARTED, PROC_REF(start_attack))
	AddElement(/datum/element/knockback, 7, FALSE, TRUE)
	AddElement(/datum/element/lifesteal, 50)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	AddComponent(/datum/component/boss_music, 'sound/music/boss/bdm_boss.ogg', 167 SECONDS)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Destroy()
	frost_orbs = null
	hard_frost_orbs = null
	snowball_machine_gun = null
	hard_snowball_machine_gun = null
	ice_shotgun = null
	hard_ice_shotgun = null
	return ..()

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/OpenFire()
	if(client)
		return
	var/mob/living/living_target = target
	if(istype(living_target) && living_target.stat == DEAD) //don't go out of our way to fire our disintegrating attacks at corpses
		return

	var/easy_attack = prob(80 - enraged * 40)
	chosen_attack = rand(1, 3)
	switch(chosen_attack)
		if(1)
			if(easy_attack)
				frost_orbs.Trigger(target = target)
			else
				hard_frost_orbs.Trigger(target = target)
		if(2)
			if(easy_attack)
				snowball_machine_gun.Trigger(target = target)
			else
				hard_snowball_machine_gun.Trigger(target = target)
		if(3)
			if(easy_attack)
				ice_shotgun.Trigger(target = target)
			else
				hard_ice_shotgun.Trigger(target = target)

/// Pre-ability usage stuff
/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/start_attack(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if(enraging)
		return COMPONENT_BLOCK_ABILITY_START
	if(FROST_MINER_SHOULD_ENRAGE)
		INVOKE_ASYNC(src, PROC_REF(check_enraged))
		return COMPONENT_BLOCK_ABILITY_START
	var/projectile_speed_multiplier = 1 + enraged
	frost_orbs.projectile_speed_multiplier = projectile_speed_multiplier
	snowball_machine_gun.projectile_speed_multiplier = projectile_speed_multiplier
	ice_shotgun.projectile_speed_multiplier = projectile_speed_multiplier

/// Checks if the demonic frost miner is ready to be enraged
/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/proc/check_enraged()
	if(!FROST_MINER_SHOULD_ENRAGE)
		return
	update_cooldowns(list(COOLDOWN_UPDATE_SET_MELEE = 8 SECONDS, COOLDOWN_UPDATE_SET_RANGED = 8 SECONDS))
	frost_orbs.StartCooldown(8 SECONDS)
	adjustHealth(-maxHealth)
	enraged = TRUE
	enraging = TRUE
	animate(src, pixel_z = 96, time = 100, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE)
	spin(100, 10)
	SLEEP_CHECK_DEATH(60, src)
	playsound(src, 'sound/effects/explosion/explosion3.ogg', 100, TRUE)
	icon_state = "demonic_miner_phase2"
	animate(src, pixel_z = -96, time = 8, flags = ANIMATION_END_NOW, flags = ANIMATION_RELATIVE)
	spin(8, 2)
	for(var/obj/structure/frost_miner_prism/prism_to_set in GLOB.frost_miner_prisms)
		prism_to_set.set_prism_light(LIGHT_COLOR_PURPLE, 5)
	SLEEP_CHECK_DEATH(8, src)
	for(var/mob/living/L in viewers(src))
		shake_camera(L, 3, 2)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, FROSTMINER_ENRAGE_TRAIT)
	enraging = FALSE
	adjustHealth(-maxHealth)

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/ex_act(severity, target)
	adjustBruteLoss(-30 * severity)
	visible_message(span_danger("[src] absorbs the explosion!"), span_userdanger("You absorb the explosion!"))
	return TRUE

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Goto(target, delay, minimum_distance)
	if(enraging)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/MoveToTarget(list/possible_targets)
	if(enraging)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/Move()
	if(enraging)
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/death(gibbed)
	if(health > 0)
		return
	var/turf/T = get_turf(src)
	var/loot = rand(1, 3)
	for(var/obj/structure/frost_miner_prism/prism_to_set in GLOB.frost_miner_prisms)
		prism_to_set.set_prism_light(COLOR_GRAY, 1)
	switch(loot)
		if(1)
			new /obj/item/resurrection_crystal(T)
		if(2)
			new /obj/item/clothing/shoes/winterboots/ice_boots/ice_trail(T)
		if(3)
			new /obj/item/pickaxe/drill/jackhammer/demonic(T)
	return ..()

/obj/projectile/colossus/frost_orb
	name = "frost orb"
	icon_state = "ice_1"
	damage = 20
	armour_penetration = 100
	speed = 0.1
	range = 500
	homing_turn_speed = 3
	damage_type = BURN

/obj/projectile/colossus/frost_orb/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isturf(target) || isobj(target))
		EX_ACT(target, EXPLODE_HEAVY)

/obj/projectile/colossus/snowball
	name = "machine-gun snowball"
	icon_state = "nuclear_particle"
	damage = 5
	armour_penetration = 100
	speed = 0.33
	range = 150
	damage_type = BRUTE
	explode_hit_objects = FALSE

/obj/projectile/colossus/ice_blast
	name = "ice blast"
	icon_state = "ice_2"
	damage = 15
	armour_penetration = 100
	speed = 0.33
	range = 150
	damage_type = BRUTE

/obj/projectile/colossus/ice_blast/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isturf(target) || isobj(target))
		EX_ACT(target, EXPLODE_HEAVY)

/datum/status_effect/ice_block_talisman
	id = "ice_block_talisman"
	duration = 4 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/ice_block_talisman
	/// Stored icon overlay for the hit mob, removed when effect is removed
	var/icon/cube

/datum/status_effect/ice_block_talisman/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/atom/movable/screen/alert/status_effect/ice_block_talisman
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move!"
	icon_state = "frozen"

/datum/status_effect/ice_block_talisman/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(owner_moved))
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become frozen in a cube!"))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	var/list/icon_dimensions = get_icon_dimensions(owner.icon)
	cube.Scale(icon_dimensions["width"], icon_dimensions["height"])
	owner.add_overlay(cube)
	return ..()

/// Blocks movement from the status effect owner
/datum/status_effect/ice_block_talisman/proc/owner_moved()
	SIGNAL_HANDLER
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/status_effect/ice_block_talisman/be_replaced()
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	return ..()

/datum/status_effect/ice_block_talisman/on_remove()
	if(!owner.stat)
		to_chat(owner, span_notice("The cube melts!"))
	owner.cut_overlay(cube)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)

/obj/structure/frost_miner_prism
	name = "frost miner light prism"
	desc = "A magical crystal enhanced by a demonic presence."
	icon = 'icons/obj/science/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/structure/frost_miner_prism/Initialize(mapload)
	. = ..()
	GLOB.frost_miner_prisms |= src
	set_prism_light(LIGHT_COLOR_BLUE, 5)

/obj/structure/frost_miner_prism/Destroy()
	GLOB.frost_miner_prisms -= src
	return ..()

/obj/structure/frost_miner_prism/proc/set_prism_light(new_color, new_range)
	color = new_color
	set_light_color(new_color)
	set_light(new_range)

#undef FROST_MINER_SHOULD_ENRAGE
