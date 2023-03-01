/mob/living/simple_animal/hostile/dark_wizard
	name = "Dark Wizard"
	desc = "Killing amateurs since the dawn of times."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "dark_wizard"
	icon_living = "dark_wizard"
	move_to_delay = 10
	projectiletype = /obj/projectile/temp/earth_bolt
	projectilesound = 'sound/magic/ethereal_enter.ogg'
	ranged = TRUE
	ranged_message = "earth bolts"
	ranged_cooldown_time = 20
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	obj_damage = 20
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "staves"
	combat_mode = TRUE
	speak_emote = list("chants")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	aggro_vision_range = 9
	turns_per_move = 5
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	faction = list(ROLE_WIZARD)
	footstep_type = FOOTSTEP_MOB_SHOE
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	loot = list(/obj/effect/decal/remains/human)
	del_on_death = TRUE

/mob/living/simple_animal/hostile/dark_wizard/Initialize(mapload)
	. = ..()
	apply_dynamic_human_appearance(src, mob_spawn_path = /obj/effect/mob_spawn/corpse/human/wizard/dark, r_hand = /obj/item/staff)

/obj/projectile/temp/earth_bolt
	name = "earth bolt"
	icon_state = "declone"
	damage = 4
	damage_type = BURN
	armor_flag = ENERGY
	temperature = -100 // closer to the old temp loss
