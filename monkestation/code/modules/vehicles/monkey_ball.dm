/obj/vehicle/ridden/monkey_ball
	name = "Monkey Ball"
	desc = "An ominously monkey-sized ball."
	icon = 'monkestation/icons/obj/vehicles.dmi'
	icon_state = "monkey_ball"
	max_integrity = 100
	layer = ABOVE_MOB_LAYER
	movedelay = 1
	var/rotation = 0
	var/last_bump = 0
	var/animation_delay = 0

/obj/vehicle/ridden/monkey_ball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/monkey_ball)

/obj/vehicle/ridden/monkey_ball/Destroy()
	if(has_buckled_mobs())
		var/mob/living/carbon/driver = buckled_mobs[1]
		unbuckle_mob(driver)
		driver.throw_at(get_edge_target_turf(driver,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))
		driver.Knockdown(12 SECONDS)
	return ..()

/obj/vehicle/ridden/monkey_ball/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(world.time > animation_delay)
		rotation += (dir == NORTH || dir == WEST || dir == NORTHWEST) ? -30 : 30
		animate(src,transform = matrix(rotation, MATRIX_ROTATE), time = 2, easing = LINEAR_EASING)
		animation_delay = world.time + 1
	. = ..()

/obj/vehicle/ridden/monkey_ball/Bump(atom/movable/victim)
	. = ..()
	if(world.time < last_bump)
		return
	if(isliving(victim))
		var/atom/throw_target = get_edge_target_turf(victim, dir)
		var/mob/living/living_victim = victim
		living_victim.throw_at(throw_target, 4, 5)
		living_victim.Knockdown(4 SECONDS)
		living_victim.stamina.adjust(-20)
		playsound(src, 'sound/effects/bang.ogg', 50, 1, mixer_channel = CHANNEL_MOB_SOUNDS)
		last_bump = world.time + 1 SECONDS


/datum/component/riding/vehicle/monkey_ball
	ride_check_flags = RIDER_NEEDS_LEGS
