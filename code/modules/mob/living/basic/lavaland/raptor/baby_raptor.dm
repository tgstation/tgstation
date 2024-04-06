/mob/living/basic/mining/raptor/baby_raptor
	name = "baby raptor"
	desc = "Will this grow into something useful?"
	speed = 5
	maxHealth = 25
	health = 25
	melee_damage_lower = 3
	melee_damage_upper = 5
	can_breed = FALSE
	move_resist = MOVE_RESIST_DEFAULT
	ridable_component = null
	dex_description = "A cute baby raptor, Having it near a parent or a birds-nest could encourage it to grow faster, \
		grooming it and feeding it could also ensure that it grows up quicker!"
	///what do we grow into
	var/growth_path
	///probability we are to be rolled
	var/roll_rate = 100

/mob/living/basic/mining/raptor/baby_raptor/Initialize(mapload)
	. = ..()
	if(isnull(growth_path))
		return
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = null,\
		growth_path = growth_path,\
		growth_probability = 100,\
		lower_growth_value = 0.5,\
		upper_growth_value = 20,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
	)

/mob/living/basic/mining/raptor/baby_raptor/proc/ready_to_grow()
	var/mob/living/basic/mining/raptor/grown_mob = new growth_path(get_turf(src))
	if(!isnull(grown_mob.inherited_stats))
		QDEL_NULL(grown_mob.inherited_stats)
	grown_mob.inherited_stats = inherited_stats
	inherited_stats = null
	grown_mob.inherit_properties()
	qdel(src)

/mob/living/basic/mining/raptor/baby_raptor/black
	icon_state = "baby_black"
	growth_path = /mob/living/basic/mining/raptor/black
	roll_rate = 10

/mob/living/basic/mining/raptor/baby_raptor/red
	icon_state = "baby_red"
	growth_path = /mob/living/basic/mining/raptor/red

/mob/living/basic/mining/raptor/baby_raptor/purple
	icon_state = "baby_purple"
	growth_path = /mob/living/basic/mining/raptor/purple

/mob/living/basic/mining/raptor/baby_raptor/white
	icon_state = "baby_white"
	growth_path = /mob/living/basic/mining/raptor/white

/mob/living/basic/mining/raptor/baby_raptor/yellow
	icon_state = "baby_yellow"
	growth_path = /mob/living/basic/mining/raptor/yellow

/mob/living/basic/mining/raptor/baby_raptor/green
	icon_state = "baby_green"
	growth_path = /mob/living/basic/mining/raptor/green
