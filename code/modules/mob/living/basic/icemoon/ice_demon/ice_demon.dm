/mob/living/basic/mining/ice_demon
	name = "demonic watcher"
	desc = "A creature formed entirely out of ice, bluespace energy emanates from inside of it."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "ice_demon"
	icon_living = "ice_demon"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	basic_mob_flags = DEL_ON_DEATH
	speed = 2
	maxHealth = 150
	health = 150
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	crusher_loot = /obj/item/crusher_trophy/ice_demon_cube
	ai_controller = /datum/ai_controller/basic_controller/ice_demon
	death_message = "fades as the energies that tied it to this world dissipate."
	death_sound = 'sound/effects/magic/demon_dies.ogg'

/mob/living/basic/mining/ice_demon/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/slippery_ice_floors = BB_DEMON_SLIP_ABILITY,
		/datum/action/cooldown/mob_cooldown/ice_demon_teleport = BB_DEMON_TELEPORT_ABILITY,
		/datum/action/cooldown/spell/conjure/limit_summons/create_afterimages = BB_DEMON_CLONE_ABILITY,
	)
	grant_actions_by_list(innate_actions)

	AddComponent(\
		/datum/component/ranged_attacks,\
		projectile_type = /obj/projectile/temp/ice_demon,\
		projectile_sound = 'sound/items/weapons/pierce.ogg',\
	)
	var/static/list/death_loot = list(/obj/item/stack/ore/bluespace_crystal = 3)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/simple_flying)

/mob/living/basic/mining/ice_demon/death(gibbed)
	if(prob(5))
		new /obj/item/raw_anomaly_core/bluespace(loc)
	return ..()

/mob/living/basic/mining/demon_afterimage
	name = "afterimage demonic watcher"
	desc = "Is this some sort of illusion?"
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "ice_demon"
	icon_living = "ice_demon"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	basic_mob_flags = DEL_ON_DEATH
	speed = 5
	maxHealth = 20
	health = 20
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "slices"
	attack_verb_simple = "slice"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	alpha = 80
	ai_controller = /datum/ai_controller/basic_controller/ice_demon/afterimage
	///how long do we exist for
	var/existence_period = 15 SECONDS

/mob/living/basic/mining/demon_afterimage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/temporary_atom, life_time = existence_period)

///afterimage subtypes summoned by the crusher
/mob/living/basic/mining/demon_afterimage/crusher
	speed = 2
	health = 60
	maxHealth = 60
	melee_damage_lower = 10
	melee_damage_upper = 10
	existence_period = 7 SECONDS
