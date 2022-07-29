/datum/hallucination/husks
	var/image/halbody

/datum/hallucination/husks/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/possible_points = list()
	for(var/turf/open/floor/F in view(target,world.view))
		possible_points += F
	if(possible_points.len)
		var/turf/open/floor/husk_point = pick(possible_points)
		switch(rand(1,4))
			if(1)
				var/image/body = image('icons/mob/human.dmi',husk_point,"husk",TURF_LAYER)
				var/matrix/M = matrix()
				M.Turn(90)
				body.transform = M
				halbody = body
			if(2,3)
				halbody = image('icons/mob/human.dmi',husk_point,"husk",TURF_LAYER)
			if(4)
				halbody = image('icons/mob/alien.dmi',husk_point,"alienother",TURF_LAYER)

		if(target.client)
			target.client.images += halbody
		QDEL_IN(src, rand(30,50)) //Only seen for a brief moment.

/datum/hallucination/husks/Destroy()
	target?.client?.images -= halbody
	QDEL_NULL(halbody)
	return ..()
