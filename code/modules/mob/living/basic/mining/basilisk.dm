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
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/hard_crit()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/hunt_for_food/basilisk, //Distracted by yummy bait maybe! Use this to your advantage!
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

///Watcher
/mob/living/basic/mining/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_dead = "watcher_dead"
	health_doll_icon = "watcher"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speed = 3
	maxHealth = 200
	health = 200
	pixel_x = -10
	base_pixel_x = -10
	throw_message = "bounces harmlessly off of"
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "impales"
	attack_verb_simple = "impale"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = null // doesn't bite unlike the parent type.
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/stack/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)
	ai_controller = /datum/ai_controller/basic_controller/basilisk
	var/ranged_attack_type = /obj/projectile/temp/basilisk

/mob/living/basic/mining/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ranged_attacks, projectilesound = 'sound/weapons/pierce.ogg', projectiletype = ranged_attack_type, fire_message = "stares")
	AddElement(/datum/element/simple_flying)


/mob/living/basic/mining/watcher/add_crusher_loot()
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/watcher_wing)


///Whoever made this originally, your moms a ho.
/mob/living/basic/mining/watcher/random/Initialize()
	. = ..()
	if(prob(1))
		if(prob(75))
			new/mob/living/basic/mining/watcher/magmawing(loc)
		else
			new /mob/living/basic/mining/watcher/icewing(loc)
		return INITIALIZE_HINT_QDEL

///Magmawing variant
/mob/living/basic/mining/watcher/magmawing
	name = "magmawing watcher"
	desc = "When raised very close to lava, some watchers adapt to the extreme heat and use lava as both a weapon and wings."
	icon_state = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 2.5
	light_color = LIGHT_COLOR_LAVA
	ranged_attack_type = /obj/projectile/temp/basilisk/magmawing

/mob/living/basic/mining/watcher/magmawing/add_crusher_loot()
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/blaster_tubes/magma_wing, 60)

/obj/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	icon_state = "lava"
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	temperature = 200 // Heats you up! per hit!

/obj/projectile/temp/basilisk/magmawing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if (istype(L))
			L.adjust_fire_stacks(0.1)
			L.IgniteMob()


///Icewing variant
/mob/living/basic/mining/watcher/icewing
	name = "icewing watcher"
	desc = "Very rarely, some watchers will eke out an existence far from heat sources. In the absence of warmth, they become icy and fragile but fire much stronger freezing blasts."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable
	ranged_attack_type = /obj/projectile/temp/basilisk/icewing


/mob/living/basic/mining/watcher/magmawing/add_crusher_loot()
	AddElement(/datum/element/crusher_loot, /obj/item/crusher_trophy/watcher_wing/ice_wing, 30)


/obj/projectile/temp/basilisk/icewing
	damage = 5
	damage_type = BURN
	nodamage = FALSE

/obj/projectile/temp/basilisk/icewing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.apply_status_effect(/datum/status_effect/freon/watcher)
