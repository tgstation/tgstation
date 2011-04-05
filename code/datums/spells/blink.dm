/obj/spell/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1 //can affect only the user by default, but with var editing can be a teleport other spell
	var/outer_teleport_radius = 6 //the radius of the area in which it picks turfs to teleport to
	var/inner_teleport_radius = 0 //so with var fuckery you can have it teleport in a ring, not in a circle
	var/smoke_spread = 1 //if set to 0, no smoke spreads when teleporting

/obj/spell/blink/Click()
	..()

	if(!cast_check())
		return

	var/mob/M

	if(range>=0)
		M = input("Choose whom to blink", "ABRAKADABRA") as mob in view(usr,range)
	else
		M = usr

	if(!M)
		return

	invocation()

	var/list/turfs = new/list()
	for(var/turf/T in orange(M,outer_teleport_radius))
		if(T in orange(M,inner_teleport_radius)) continue
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-outer_teleport_radius || T.x<outer_teleport_radius)	continue	//putting them at the edge is dumb
		if(T.y>world.maxy-outer_teleport_radius || T.y<outer_teleport_radius)	continue
		turfs += T
	if(!turfs.len)
		var/list/turfs_to_pick_from = list()
		for(var/turf/T in orange(M,outer_teleport_radius))
			if(!(T in orange(M,inner_teleport_radius)))
				turfs_to_pick_from += T
		turfs += pick(/turf in turfs_to_pick_from)
	if(smoke_spread)
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(10, 0, M.loc)
		smoke.start()
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return
	M.loc = picked