/obj/effect/bhole
	name = "black hole"
	icon = 'objects.dmi'
	desc = "FUCK FUCK FUCK AAAHHH"
	icon_state = "bhole2"
	opacity = 0
	unacidable = 1
	density = 0
	anchored = 1
	var/datum/effect/effect/system/harmless_smoke_spread/smoke


/obj/effect/bhole/New()
	src.smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	src.smoke.set_up(5, 0, src)
	src.smoke.attach(src)
	src:life()


/obj/effect/bhole/Bumped(atom/A)
	if (istype(A,/mob/living))
		del(A)
	else
		A:ex_act(1.0)


/obj/effect/bhole/proc/life() //Oh man , this will LAG

	if (prob(10))
		src.anchored = 0
		step(src,pick(alldirs))
		if (prob(30))
			step(src,pick(alldirs))
		src.anchored = 1

	for (var/atom/X in orange(9,src))
		if ((istype(X,/obj) || istype(X,/mob/living)) && prob(7))
			if (!X:anchored)
				step_towards(X,src)

	for (var/atom/B in orange(7,src))
		if (istype(B,/obj))
			if (!B:anchored && prob(50))
				step_towards(B,src)
				if(prob(10)) B:ex_act(3.0)
			else
				B:anchored = 0
				//step_towards(B,src)
				//B:anchored = 1
				if(prob(10)) B:ex_act(3.0)
		else if (istype(B,/turf))
			if (istype(B,/turf/simulated) && (prob(1) && prob(75)))
				src.smoke.start()
				B:ReplaceWithSpace()
		else if (istype(B,/mob/living))
			step_towards(B,src)


	for (var/atom/A in orange(4,src))
		if (istype(A,/obj))
			if (!A:anchored && prob(90))
				step_towards(A,src)
				if(prob(30)) A:ex_act(2.0)
			else
				A:anchored = 0
				//step_towards(A,src)
				//A:anchored = 1
				if(prob(30)) A:ex_act(2.0)
		else if (istype(A,/turf))
			if (istype(A,/turf/simulated) && prob(1))
				src.smoke.start()
				A:ReplaceWithSpace()
		else if (istype(A,/mob/living))
			step_towards(A,src)


	for (var/atom/D in orange(1,src))
		//if (hascall(D,"blackholed"))
		//	call(D,"blackholed")(null)
		//	continue
		if (istype(D,/mob/living))
			del(D)
		else
			D:ex_act(1.0)

	spawn(17)
		life()