/mob/living/simple_animal/chicken/robot
	icon_suffix = "robot"

	breed_name = "Robotic"

	maxHealth = 100 //Weaker because emp good
	obj_damage = 1
	melee_damage = 4
	ai_controller = /datum/ai_controller/chicken/retaliate

	egg_type = /obj/item/food/egg/robot

	book_desc = "I'm not even sure how this is possible. It's like 100% metal."

/mob/living/simple_animal/chicken/robot/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/emp_burst)

/mob/living/simple_animal/chicken/robot/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_HOSTILE_ATTACKINGTARGET)

/mob/living/simple_animal/chicken/robot/proc/emp_burst(target)
	var/turf/location = get_turf(target)
	empulse(location, 1, 2, 0)

/obj/item/food/egg/robot
	name = "Robotic Egg"
	icon_state = "robot"

	layer_hen_type = /mob/living/simple_animal/chicken/robot
