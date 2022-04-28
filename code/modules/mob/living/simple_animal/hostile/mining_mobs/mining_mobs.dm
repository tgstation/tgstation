//the base mining mob
/mob/living/simple_animal/hostile/asteroid
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("mining")
	weather_immunities = list(TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE)
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	minbodytemp = 0
	maxbodytemp = INFINITY
	unsuitable_heat_damage = 20
	response_harm_continuous = "strikes"
	response_harm_simple = "strike"
	status_flags = 0
	combat_mode = TRUE
	var/crusher_loot
	var/throw_message = "bounces off of"
	var/fromtendril = FALSE
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE
	var/icon_aggro = null
	var/crusher_drop_mod = 25

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	if(vision_range == aggro_vision_range && icon_aggro)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	if(stat == DEAD)
		return
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(obj/projectile/P)//Reduces damage from most projectiles to curb off-screen kills
	if(!stat)
		Aggro()
	if(P.damage < 30 && P.damage_type != BRUTE)
		P.damage = (P.damage / 3)
		visible_message(span_danger("[P] has a reduced effect on [src]!"))
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //No floor tiling them to death, wiseguy
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 20)
			visible_message(span_notice("The [T.name] [throw_message] [src.name]!"))
			return
	..()

/mob/living/simple_animal/hostile/asteroid/death(gibbed)
	SSblackbox.record_feedback("tally", "mobs_killed_mining", 1, type)
	var/datum/status_effect/crusher_damage/C = has_status_effect(/datum/status_effect/crusher_damage)
	if(C && crusher_loot && prob((C.total_damage/maxHealth) * crusher_drop_mod)) //on average, you'll need to kill 4 creatures before getting the item
		spawn_crusher_loot()
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/proc/spawn_crusher_loot()
	butcher_results[crusher_loot] = 1
