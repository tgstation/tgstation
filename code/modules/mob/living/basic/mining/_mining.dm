/mob/living/basic/mining
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE

	innate_traits = list(TRAIT_NOMOBSWAP, TRAIT_LAVA_IMMUNE,TRAIT_ASHSTORM_IMMUNE)
	faction = list("mining")
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS | ENVIRONMENT_SMASH_STRUCTURES

	response_harm_continuous = "strikes"
	response_harm_simple = "strike"

	status_flags = NONE

	///Message shown when something is thrown against the mob and it does not do enough damage.
	var/throw_message = "bounces off of"

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/basic_body_temp_sensetive, 0, INFINITY, cold_damage = 20)
	add_crusher_loot()

/mob/living/basic/mining/proc/add_crusher_loot()
	return

/mob/living/basic/mining/bullet_act(obj/projectile/projectile)//Reduces damage from most projectilerojectiles to curb off-screen kills
	if(projectile.damage < 30 && projectile.damage_type != BRUTE)
		projectile.damage = (projectile.damage / 3) //lol piercing bullets would lose a ton of damage on this but lmao oldcoders be like
		visible_message(span_danger("[projectile] has a reduced effect on [src]!"))
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //No floor tiling them to death, wiseguy
	if(istype(AM, /obj/item))
		var/obj/item/thrown_item = AM
		if(thrown_item.throwforce <= 20)
			visible_message(span_notice("[thrown_item] [throw_message] [src]!"))
			return
	..()

/mob/living/simple_animal/hostile/asteroid/death(gibbed)
	. = ..()
	SSblackbox.record_feedback("tally", "mobs_killed_mining", 1, type)
