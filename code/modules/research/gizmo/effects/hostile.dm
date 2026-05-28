/datum/gizmo_effect/dispense/robot_spider
	possible_objects = list(
		/mob/living/basic/spider/robot = 1,
	)

/mob/living/basic/spider/robot
	name = "robot spider"
	desc = "Beep boop, the robot spider said."
	icon_state = "robot"
	mob_biotypes = MOB_ROBOTIC|MOB_BUG

	speed = 5
	maxHealth = 50
	health = 50
	obj_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/giant_spider

/mob/living/basic/spider/robot/death(gibbed)
	. = ..()

	explosion(src, 0, 0, 2)
	if(prob(80))
		qdel(src)

/mob/living/basic/spider/robot/emp_act(severity)
	. = ..()

	death() //very sensitive spider robot antennae makes it die fast to emp
