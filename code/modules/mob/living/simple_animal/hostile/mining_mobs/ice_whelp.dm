/mob/living/simple_animal/hostile/asteroid/ice_whelp
	name = "ice whelp"
	desc = "The offspring of an ice drake, weak in comparison but still terrifying."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "ice_whelp"
	icon_living = "ice_whelp"
	icon_dead = "ice_whelp_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("roars")
	speed = 12
	move_to_delay = 12
	ranged = TRUE
	ranged_cooldown_time = 5 SECONDS
	maxHealth = 300
	health = 300
	obj_damage = 40
	armour_penetration = 20
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	ranged_message = "breathes fire at"
	vision_range = 9
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/stack/ore/diamond = 3, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 10, /obj/item/stack/sheet/animalhide/ashdrake = 1)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/tail_spike
	death_message = "collapses on its side."
	death_sound = 'sound/magic/demon_dies.ogg'
	stat_attack = HARD_CRIT
	robust_searching = TRUE
	footstep_type = FOOTSTEP_MOB_CLAW
	/// How far the whelps fire can go
	var/fire_range = 4

/mob/living/simple_animal/hostile/asteroid/ice_whelp/Shoot()
	var/turf/target_fire_turf = get_ranged_target_turf_direct(src, target, fire_range)
	var/list/burn_turfs = get_line(src, target_fire_turf) - get_turf(src)
	dragon_fire_line(src, burn_turfs, frozen = TRUE)

/mob/living/simple_animal/hostile/asteroid/ice_whelp/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	return ..()
