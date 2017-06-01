/datum/round_event_control/turbulence
	name = "Turbulence"
	typepath = /datum/round_event/turbulence
	weight = 5

/datum/round_event/turbulence
	announceWhen	= 10
	startWhen		= 30
	endWhen			= 35

	var/flying_debris = list()
	var/weight_class_affected = 3

/datum/round_event/turbulence/announce()
	var/reasons = list(
		"The Titan-class starliner Whale is passing through a nearby \
			hyperspace expressway. Please brace for minor turbulence.",
		"A small coronal ejection has occured on our host star, there may \
			be some mild gravitational effects. For your safety, please \
			secure yourself and nearby equipment.",
		"Centcom are testing a new classified weapon in our star system \
			shortly. There will be mild gravitation waves produced.")
	priority_announce(pick(reasons), "Safety Alert")


/datum/round_event/turbulence/setup()
	world.log << "turbulence setup()"
	for(var/x in block(locate(1,1,1), locate(world.maxx, world.maxy, 1)))
		var/turf/T = x
		for(var/obj/item/I in T)
			if(I.w_class <= weight_class_affected)
				flying_debris += I

	shuffle(flying_debris)

/datum/round_event/turbulence/start()
	world.log << "turbulence start()"
	for(var/x in living_mob_list)
		var/mob/living/M = x

		var/turf/T = get_turf(M)

		if(!T || T.z != 1)
			continue

		if(M.client)
			if(M.buckled)
				shake_camera(M, 2, 1)
			else
				shake_camera(M, 7, 1)

		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/C = M
			if(!C.buckled)
				C.Weaken(3)

	var/max_range = 5
	for(var/x in flying_debris)
		if(!x)
			continue

		var/obj/item/I = x
		var/dist = rand(1, max_range)
		var/dir = pick(alldirs)

		var/turf/throw_at = get_ranged_target_turf(I, dir, dist)
		// Like explosions, turbulence increases embedding chance
		I.throw_speed = 4
		I.throw_at(throw_at, dist, 2)
