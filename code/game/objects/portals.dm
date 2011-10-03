

/obj/effects/portal/Bumped(mob/M as mob|obj)
	spawn(0)
		src.teleport(M)
		return
	return

/obj/effects/portal/HasEntered(AM as mob|obj)
	spawn(0)
		src.teleport(AM)
		return
	return

/obj/effects/portal/New()
	spawn(300)
		del(src)
		return
	return

/obj/effects/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effects)) //sparks don't teleport
		return
	if (M.anchored&&istype(M, /obj/mecha))
		return
	if (icon_state == "portal1")
		return
	if (!( target ))
		del(src)
		return
	if (istype(M, /atom/movable))
		if(prob(failchance)) //oh dear a problem, put em in deep space
			src.icon_state = "portal1"
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0)
		else
			do_teleport(M, target, 1) ///You will appear adjacent to the beacon

