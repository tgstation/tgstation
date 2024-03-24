/mob/living/basic/alien/drone
	name = "alien drone"
	icon_state = "aliend"
	icon_living = "aliend"
	icon_dead = "aliend_dead"
	melee_damage_lower = 15
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/alien/drone

/mob/living/basic/alien/drone/del_on_death
	basic_mob_flags = parent_type::basic_mob_flags | DEL_ON_DEATH
