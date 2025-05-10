/// Wizard-looking guy who basically just shoots you
/mob/living/basic/dark_wizard
	name = "Dark Wizard"
	desc = "Killing amateurs since the dawn of times."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "dark_wizard"
	icon_living = "dark_wizard"
	maxHealth = 50
	health = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	obj_damage = 20
	basic_mob_flags = DEL_ON_DEATH
	attack_verb_continuous = "staves"
	attack_verb_simple = "stave"
	combat_mode = TRUE
	speak_emote = list("chants")
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	faction = list(ROLE_WIZARD)
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	ai_controller = /datum/ai_controller/basic_controller/dark_wizard

/mob/living/basic/dark_wizard/get_save_vars()
	return ..() - NAMEOF(src, icon_state) // icon_state is applied via apply_dynamic_human_appearance()

/mob/living/basic/dark_wizard/Initialize(mapload)
	. = ..()

	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/wizard/dark, r_hand = /obj/item/staff)
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)

	var/corpse = string_list(list(/obj/effect/decal/remains/human))
	AddElement(/datum/element/death_drops, corpse)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	AddElement(/datum/element/ai_retaliate)

	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/temp/earth_bolt,\
		projectile_sound = 'sound/effects/magic/ethereal_enter.ogg',\
		cooldown_time = 2 SECONDS,\
	)

	var/datum/action/cooldown/spell/teleport/radius_turf/blink/slow/escape_spell = new(src)
	escape_spell.Grant(src)
	AddComponent(\
		/datum/component/revenge_ability,\
		escape_spell,\
		max_range = 3,\
		target_self = TRUE,\
	)

	new /obj/item/clothing/head/wizard/hood(src) // Having this hat in our contents allows us to cast wizard spells

/datum/ai_controller/basic_controller/dark_wizard
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate, // If you get them to shoot each other it will start a wiz-war
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish/no_minimum,
	)

/// I don't know why an earth bolt freezes you but I guess it does
/obj/projectile/temp/earth_bolt
	name = "earth bolt"
	icon_state = "declone"
	damage = 4
	damage_type = BURN
	armor_flag = ENERGY
	temperature = -100
