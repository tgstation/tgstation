/mob/living/basic/raptor/baby_raptor
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

/mob/living/basic/raptor/baby_raptor/Initialize(mapload)
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

/mob/living/basic/raptor/baby_raptor/add_happiness_component()
	AddComponent(/datum/component/happiness, on_petted_change = 100)

/mob/living/basic/raptor/baby_raptor/proc/check_grow()
	return (stat != DEAD)

/mob/living/basic/raptor/baby_raptor/proc/ready_to_grow()
	var/mob/living/basic/raptor/grown_mob = new growth_path(get_turf(src))
	QDEL_NULL(grown_mob.inherited_stats)
	grown_mob.inherited_stats = inherited_stats
	inherited_stats = null
	grown_mob.inherit_properties()
	ADD_TRAIT(grown_mob, TRAIT_MOB_HATCHED, INNATE_TRAIT) //pass on the hatched trait
	qdel(src)

/mob/living/basic/raptor/baby_raptor/black
	name = "baby black raptor"
	icon_state = "baby_black"
	icon_living = "baby_black"
	icon_dead = "baby_black_dead"
	growth_path = /mob/living/basic/raptor/black
	roll_rate = 10

/mob/living/basic/raptor/baby_raptor/red
	name = "baby red raptor"
	icon_state = "baby_red"
	icon_living = "baby_red"
	icon_dead = "baby_red_dead"
	growth_path = /mob/living/basic/raptor/red

/mob/living/basic/raptor/baby_raptor/purple
	name = "baby purple raptor"
	icon_state = "baby_purple"
	icon_living = "baby_purple"
	icon_dead = "baby_purple_dead"
	growth_path = /mob/living/basic/raptor/purple

/mob/living/basic/raptor/baby_raptor/white
	name = "baby white raptor"
	icon_state = "baby_white"
	icon_living = "baby_white"
	icon_dead = "baby_white_dead"
	growth_path = /mob/living/basic/raptor/white

/mob/living/basic/raptor/baby_raptor/yellow
	name = "baby yellow raptor"
	icon_state = "baby_yellow"
	icon_living = "baby_yellow"
	icon_dead = "baby_yellow_dead"
	growth_path = /mob/living/basic/raptor/yellow

/mob/living/basic/raptor/baby_raptor/green
	name = "baby green raptor"
	icon_state = "baby_green"
	icon_living = "baby_green"
	icon_dead = "baby_green_dead"
	growth_path = /mob/living/basic/raptor/green

/mob/living/basic/raptor/baby_raptor/blue
	name = "baby blue raptor"
	icon_state = "baby_blue"
	icon_living = "baby_blue"
	icon_dead = "baby_blue_dead"
	growth_path = /mob/living/basic/raptor/blue
