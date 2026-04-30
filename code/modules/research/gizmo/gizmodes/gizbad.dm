/// A bunch of bad effects that can maim or kill you (for science!!!)
/datum/gizmodes/bad
	possible_active_modes = list(
		/datum/gizpulse/explode = 1,
		/datum/gizpulse/explode/fire = 1,
		/datum/gizpulse/dispense/robot_spider = 1,
		/datum/gizpulse/thrower = 1,
		/datum/gizpulse/thrower/grenade = 1,
		/datum/gizpulse/radiation_pulse = 1,
		/datum/gizpulse/bone_breaker = 1,
	)

	guaranteed_active_gizmodes = list(
		/datum/gizpulse/ominous, //it may warn you, it may immediately explode. Who knows!
	)

	min_modes = 1
	max_modes = 2

	cooldown_time = 5 SECONDS

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

	explosion(src, 0, 0, 2)
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
	modify(item)

/// Do some extra modifications if need be
/datum/gizpulse/thrower/proc/modify(obj/item/item)
	return

/datum/gizpulse/ominous/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.audible_message(span_hear("You hear an ominous hum."))

/datum/gizpulse/thrower/grenade
	throwables = list(
		/obj/item/grenade/iedcasing = 3,
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/syndieminibomb/concussion = 1,
		/obj/item/grenade/frag = 1,
		/obj/item/grenade/chem_grenade/teargas = 1,
		/obj/item/grenade/chem_grenade/facid = 1,
		/obj/item/grenade/chem_grenade/clf3 = 1,
	)

/datum/gizpulse/thrower/grenade/modify(obj/item/item)
	var/obj/item/grenade/regret = item
	regret.arm_grenade()

/datum/gizpulse/bone_breaker/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/list/victims = list()
	for(var/mob/living/loser in orange(1, holder))
		victims += loser

	if(!victims.len)
		return

	var/mob/living/victim = pick(victims)
	holder.forceMove(get_turf(victim))
	playsound(victim, 'sound/effects/wounds/crack2.ogg', 70, TRUE)

	victim.apply_damage(60, BRUTE, wound_bonus = 100, sharpness = NONE)
	victim.Stun(2 SECONDS)
	victim.Knockdown(5 SECONDS)

	victim.emote("scream")
