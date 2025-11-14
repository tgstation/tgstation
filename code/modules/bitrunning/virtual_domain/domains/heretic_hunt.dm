/datum/lazy_template/virtual_domain/heretic_hunt
	name = "Heretical Hunt"
	cost = BITRUNNER_COST_LOW
	desc = "Betray your fellow man to achieve ultimate power."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	help_text = "Heretics require sacrifice to fuel their dark rituals - bring corpses back to the ritual site! \
		Corpses of higher ranking crew members are more valuable and may be holding useful equipment."
	forced_outfit = /datum/outfit/virtual_domain_heretic
	key = "heretic_hunt"
	map_name = "heretic_hunt"
	reward_points = BITRUNNER_REWARD_LOW

/datum/lazy_template/virtual_domain/heretic_hunt/setup_domain(list/created_atoms)
	for(var/mob/living/basic/fake_crewman/target in created_atoms)
		RegisterSignal(target, COMSIG_LIVING_DROPPED_LOOT, PROC_REF(on_body_spawned))

	for(var/mob/living/basic/heretic_summon/helper in created_atoms)
		helper.ai_controller = new /datum/ai_controller/basic_controller/simple/simple_hostile(helper)
		helper.ai_controller.blackboard[BB_BASIC_MOB_IDLE_WALK_CHANCE] = 0.1

	var/obj/effect/heretic_rune/big/rune = locate() in created_atoms
	rune.set_greyscale(pick(assoc_to_values(GLOB.heretic_path_to_color)))

/datum/lazy_template/virtual_domain/heretic_hunt/proc/on_body_spawned(mob/living/source, list/loot, gibbed)
	SIGNAL_HANDLER

	if(gibbed)
		return

	for(var/mob/living/carbon/human/body in loot)
		RegisterSignal(body, COMSIG_MOVABLE_MOVED, PROC_REF(check_loc))
		// let's be safe
		for(var/obj/item/modular_computer/pda/pda in body.get_all_gear())
			qdel(pda)

/datum/lazy_template/virtual_domain/heretic_hunt/proc/check_loc(mob/living/carbon/human/source, ...)
	SIGNAL_HANDLER

	var/obj/effect/heretic_rune/big/rune = locate() in source.loc
	if(isnull(rune))
		return

	var/datum/job/fake_job = SSjob.get_job(source.job) || SSjob.get_job_type(/datum/job/unassigned)
	// 10 points are needed
	if(fake_job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		add_points(3)
	else if(fake_job.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
		add_points(2)
	else
		add_points(1)
	// cleanup
	source.gib(ALL)

	// mimic a ritual effect
	if(locate(/obj/structure/closet/crate/secure/bitrunning/encrypted) in range(1, rune))
		rune.balloon_alert_to_viewers("ritual completed")
	else
		rune.balloon_alert_to_viewers("sacrifice accepted")
	flick("[rune.icon_state]_active", rune)
	playsound(rune, 'sound/effects/magic/castsummon.ogg', 50, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10, ignore_walls = FALSE)

/datum/outfit/virtual_domain_heretic
	name = "Virtual Domain Heretic"

	// this gear is just given to them in the safehouse
	// suit = /obj/item/clothing/suit/hooded/cultrobes/eldritch
	// suit_store = /obj/item/melee/sickly_blade

	// otherwise just thematically appropriate clothing
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	neck = /obj/item/clothing/neck/heretic_focus
	mask = /obj/item/clothing/mask/madness_mask

/datum/outfit/virtual_domain_heretic/pre_equip(mob/living/carbon/human/user, visuals_only)
	ADD_TRAIT(user, TRAIT_ACT_AS_HERETIC, INNATE_TRAIT)
	ADD_TRAIT(user, TRAIT_NO_TELEPORT, INNATE_TRAIT)
	user.AddElement(/datum/element/leeching_walk)
	user.faction |= FACTION_HERETIC

// All it does is stand there, only attacks if attacked (Manuel player)
/datum/ai_controller/basic_controller/fake_crewman
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_REINFORCEMENTS_SAY = "Help me!",
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path/trooper,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/fake_crewman/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path/trooper,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

// Immediately tries to attack the player (Terry player)
/datum/ai_controller/basic_controller/fake_crewman/instant_hostile
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/trooper,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/fake_crewman/instant_hostile/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/attack_obstacle_in_path/trooper,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

// The actual crewmate
/mob/living/basic/fake_crewman
	name = "crewmember"
	desc = "How do you do, fellow crewmen?"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_HOSTILE, "vdom_fake_crew")
	icon = 'icons/mob/simple/simple_human.dmi'
	gender = MALE
	basic_mob_flags = DEL_ON_DEATH

	ai_controller = /datum/ai_controller/basic_controller/fake_crewman

	maxHealth = 60
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	obj_damage = 20
	armour_penetration = 10

	attack_sound = null // autoset
	melee_damage_type = null // autoset

	var/death_spawner = /obj/effect/mob_spawn/corpse/human
	var/obj/item/weapon = /obj/item/storage/toolbox

/mob/living/basic/fake_crewman/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/death_drops, string_list(list(weapon, death_spawner)))
	var/lhand = prob(50) ? weapon : null
	var/rhand = lhand ? null : weapon
	apply_dynamic_human_appearance(src, mob_spawn_path = death_spawner, l_hand = lhand, r_hand = rhand)

	attack_sound ||= weapon::hitsound
	melee_damage_type ||= weapon::damtype
	sharpness = weapon::sharpness
	wound_bonus = weapon::wound_bonus * 0.5
	exposed_wound_bonus = weapon::exposed_wound_bonus * 0.5

/mob/living/basic/fake_crewman/md
	name = "medical doctor"
	death_spawner = /obj/effect/mob_spawn/corpse/human/doctor
	weapon = /obj/item/circular_saw

/mob/living/basic/fake_crewman/sec
	name = "security officer"
	ai_controller = /datum/ai_controller/basic_controller/fake_crewman/instant_hostile
	death_spawner = /obj/effect/mob_spawn/corpse/human/secoff
	weapon = /obj/item/knife/combat/survival
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 1, STAMINA = 1, OXY = 1)

/mob/living/basic/fake_crewman/engi
	name = "engineer"
	death_spawner = /obj/effect/mob_spawn/corpse/human/engineer
	weapon = /obj/item/weldingtool
	attack_sound = 'sound/items/tools/welder.ogg'
	melee_damage_type = BURN
	damage_coeff = list(BRUTE = 1, BURN = 0.9, TOX = 1, STAMINA = 1, OXY = 1)

/mob/living/basic/fake_crewman/engi/mod
	death_spawner = /obj/effect/mob_spawn/corpse/human/engineer/mod
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 1, STAMINA = 1, OXY = 1)

/mob/living/basic/fake_crewman/assistant
	name = "assistant"
	ai_controller = /datum/ai_controller/basic_controller/fake_crewman/instant_hostile
	death_spawner = /obj/effect/mob_spawn/corpse/human/assistant
	weapon = /obj/item/knife/shiv

/mob/living/basic/fake_crewman/assistant/alt
	weapon = /obj/item/storage/toolbox/mechanical

/mob/living/basic/fake_crewman/boss
	name = "senior crewmember"
	maxHealth = 120
	health = 120
	melee_damage_lower = 20
	melee_damage_upper = 25
	armour_penetration = 30

/mob/living/basic/fake_crewman/boss/cmo
	name = "chief medical officer"
	death_spawner = /obj/effect/mob_spawn/corpse/human/cmo
	weapon = /obj/item/surgicaldrill

/mob/living/basic/fake_crewman/boss/ce
	name = "chief engineer"
	ai_controller = /datum/ai_controller/basic_controller/fake_crewman/ranged
	death_spawner = /obj/effect/mob_spawn/corpse/human/ce
	weapon = /obj/item/gun/energy/plasmacutter/adv

/mob/living/basic/fake_crewman/boss/ce/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, /obj/item/ammo_casing/energy/plasma/adv, projectile_sound = 'sound/items/weapons/plasma_cutter.ogg', cooldown_time = 1.6 SECONDS)

/mob/living/basic/fake_crewman/boss/hos
	name = "head of security"
	ai_controller = /datum/ai_controller/basic_controller/fake_crewman/instant_hostile/ranged
	death_spawner = /obj/effect/mob_spawn/corpse/human/hos
	weapon = /obj/item/gun/energy/e_gun/hos
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 1, STAMINA = 1, OXY = 1)

/mob/living/basic/fake_crewman/boss/hos/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, /obj/item/ammo_casing/energy/laser, projectile_sound = 'sound/items/weapons/laser.ogg', cooldown_time = 1.2 SECONDS)
