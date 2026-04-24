/// A bunch of bad effects that can maim or kill you (for science!!!)
/datum/gizmodes/bad
	possible_active_modes = list(
		/datum/gizpulse/explode = 1,
		/datum/gizpulse/explode/fire = 1,
		/datum/gizpulse/dispense/robot_spider = 1,
		/datum/gizpulse/thrower = 1,
	)

	guaranteed_active_gizmodes = list(
		/datum/gizpulse/ominous, //it may warn you, it may immediately explode. Who knows!
	)

	min_modes = 1
	max_modes = 2

	cooldown_time = 20 SECONDS

/datum/gizpulse/explode
	var/range_heavy = 0
	var/range_medium = 1
	var/range_light = 3
	var/range_flame = 0

/datum/gizpulse/explode/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	explosion(holder, range_heavy, range_medium, range_light, range_flame)

/datum/gizpulse/explode/fire
	range_flame = 5

/datum/gizpulse/dispense/robot_spider
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

	explosion(src, 0, 1, 2)
	if(prob(80))
		qdel(src)

/mob/living/basic/spider/robot/emp_act(severity)
	. = ..()

	death() //very sensitive spider robot antennae makes it die fast to emp

/datum/gizpulse/thrower
	/// Weighted list of items we can throw
	var/list/throwables = list(
		/obj/item/knife/kitchen = 1,
		/obj/item/shard = 1,

	)
	/// Path of item to throw
	var/throwing_path

/datum/gizpulse/thrower/New()
	. = ..()
	throwing_path = pick_weight(throwables)

/datum/gizpulse/thrower/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/obj/item/item = new throwing_path (get_turf(holder))

	var/list/targets = list()
	for(var/mob/living/victims in oview(5, holder))
		targets += victims

	if(!targets.len)
		targets += get_edge_target_turf(holder, GLOB.alldirs)
	item.throw_at(pick(targets), 20, 3)

/datum/gizpulse/ominous/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.audible_message(span_hear("You hear an ominous hum."))
