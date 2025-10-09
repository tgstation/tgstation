/*
/mob/living/basic/raptor/baby
	name = "baby raptor"
	desc = "Will this grow into something useful?"
	icon = 'icons/mob/simple/lavaland/raptor_baby.dmi'
	speed = 5
	maxHealth = 25
	health = 25
	melee_damage_lower = 3
	melee_damage_upper = 5
	density = FALSE
	can_breed = FALSE
	move_resist = MOVE_RESIST_DEFAULT
	ai_controller = /datum/ai_controller/basic_controller/baby_raptor
	ridable_component = null
	change_offsets = FALSE
	dex_description = "A cute baby raptor, Having it near a parent or a birds-nest could encourage it to grow faster, \
		grooming it and feeding it could also ensure that it grows up quicker!"
	///what do we grow into
	var/growth_path
	///probability we are to be rolled
	var/roll_rate = 100

/mob/living/basic/raptor/baby/Initialize(mapload)
	. = ..()
	if(isnull(growth_path))
		return
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = null,\
		growth_path = growth_path,\
		growth_probability = 80,\
		lower_growth_value = 0.5,\
		upper_growth_value = 0.8,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(check_grow)),\
		optional_grow_behavior = CALLBACK(src, PROC_REF(ready_to_grow)),\
	)

/mob/living/basic/raptor/baby/add_happiness_component()
	AddComponent(/datum/component/happiness, on_petted_change = 100)

/mob/living/basic/raptor/baby/proc/check_grow()
	return (stat != DEAD)

/mob/living/basic/raptor/baby/proc/ready_to_grow()
	var/mob/living/basic/raptor/grown_mob = new growth_path(get_turf(src))
	QDEL_NULL(grown_mob.inherited_stats)
	grown_mob.inherited_stats = inherited_stats
	inherited_stats = null
	grown_mob.inherit_properties()
	ADD_TRAIT(grown_mob, TRAIT_MOB_HATCHED, INNATE_TRAIT) //pass on the hatched trait
	qdel(src)

*/
