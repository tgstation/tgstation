/// Boring ranged enemy from asteroid
/mob/living/basic/mining/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speed = 3
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attack_verb_continuous = "bites into"
	attack_verb_simple = "bite into"
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	gold_core_spawnable = HOSTILE_SPAWN

	throw_message = "does nothing against the hard shell of"

	ai_controller = /datum/ai_controller/basic_controller/basilisk

/mob/living/basic/mining/basilisk/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/aggro_icon, "Basilisk_alert")
	AddElement(/datum/element/ranged_attacks, projectilesound = 'sound/weapons/pierce.ogg', projectiletype = /obj/projectile/temp/basilisk, fire_message = "stares")
	AddElement(/datum/element/death_drops, list(/obj/item/stack/ore/diamond = 2))

/datum/ai_controller/basic_controller/basilisk
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/hunt_for_food, //Distracted by yummy bait maybe! Use this to your advantage!
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/basilisk, //If we are attacking someone, this will prevent us from hunting

	)

/datum/ai_planning_subtree/hunt_for_food/basilisk
	hunt_targets = list(/obj/item/pen/survival, /obj/item/stack/ore/diamond)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/basilisk
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/basilisk

/datum/ai_behavior/basic_ranged_attack/basilisk
	action_cooldown = 2.5 SECONDS

/obj/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 10
	damage_type = BURN
	nodamage = FALSE
	flag = ENERGY
	temperature = -50 // Cools you down! per hit!
	var/slowdown = TRUE //Determines if the projectile applies a slowdown status effect on carbons or not

/obj/projectile/temp/basilisk/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target) && slowdown)
		var/mob/living/carbon/carbon_target = target
		carbon_target.apply_status_effect(/datum/status_effect/freezing_blast)
