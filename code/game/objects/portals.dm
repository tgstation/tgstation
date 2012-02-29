

/obj/effect/portal/Bumped(atom/M as mob|obj)
	spawn(0)
		src.teleport(M)
		return
	return

/obj/effect/portal/HasEntered(AM as mob|obj)
	spawn(0)
		src.teleport(AM)
		return
	return

/obj/effect/portal/New()
	spawn(300)
		del(src)
		return
	return

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
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
			do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), pick(3,4,5,6)), 0)
		else
			do_teleport(M, target, 1) ///You will appear adjacent to the beacon


//Adding in special portals to permit the use of trans-level disposals/mailing.
/obj/effect/portal/zlev
	failchance = 0
	target = null
	invisibility  = 101
	var/ID = 0

	New()

	CanPass(atom/A, turf/T)
		if(istype(A, /mob) || istype(A, /obj)) // You Shall Not Pass!
			teleport(A)
		return 1

	teleport(var/atom/movable/M as mob|obj)
		if(istype(M, /obj/effect)) //sparks don't teleport
			return
		if (!( target ))
			for(var/obj/effect/portal/zlev/dest/A in world)
				if(ID == A.ID)
					target = A
					break
			if(!target)
				del(src)
				return
		if (istype(M, /atom/movable))
			var/temp = get_dir(M,src)
			do_teleport(M, target) ///You will appear at the beacon
			var/turf/target2 = get_edge_target_turf(M, temp)
			M.throw_at(target2,100,2)

	dest	//Holy shit that was bad.
		HasEntered(AM as mob|obj)
			return

		Bumped(atom/M as mob|obj)
			return

		CanPass(atom/A, turf/T)
			return 1