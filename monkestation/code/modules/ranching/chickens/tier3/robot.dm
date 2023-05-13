/mob/living/basic/chicken/robot
	icon_suffix = "robot"

	breed_name = "Robotic"

	maxHealth = 100 //Weaker because emp good
	obj_damage = 1
	melee_damage_upper = 4
	melee_damage_lower = 4
	ai_controller = /datum/ai_controller/chicken/retaliate

	egg_type = /obj/item/food/egg/robot

	book_desc = "I'm not even sure how this is possible. It's like 100% metal."

/mob/living/basic/chicken/robot/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_ATTACKINGTARGET, PROC_REF(emp_burst))

/mob/living/basic/chicken/robot/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_HOSTILE_ATTACKINGTARGET)

/mob/living/basic/chicken/robot/proc/emp_burst(target)
	var/turf/location = get_turf(target)
	empulse(location, 1, 2, 0)

/obj/item/food/egg/robot
	name = "Robotic Egg"
	icon_state = "robot"

	layer_hen_type = /mob/living/basic/chicken/robot
