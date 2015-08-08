/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from human habitat"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	anchored = 1
	var/area/teleport_target

/obj/machinery/abductor/proc/TeleportToArea(mob/living/target,area/thearea)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		return

	if(target && target.buckled)
		target.buckled.unbuckle_mob()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	while(tempL.len)
		attempt = pick(tempL)
		target.Move(attempt)
		if(get_turf(target) == attempt)
			success = 1
			break
		else
			tempL.Remove(attempt)
	if(!success)
		target.loc = pick(L)

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	target.Move(src.loc)

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = teleportlocs[pick(teleportlocs)]
	flick("alien-pad", src)
	for(var/mob/living/target in src.loc)
		TeleportToArea(target,teleport_target)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	spawn(0)
		anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)
	Warp(target)

/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	var/obj/effect/teleport_abductor/F = new(place)
	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(10,0,place)
	S.start()
	sleep(80)
	qdel(F)
	flick("alien-pad", src)
	target.forceMove(place)
	anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	var/obj/effect/teleport_abductor/F = new(place)
	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(10,0,place)
	S.start()
	sleep(80)
	qdel(F)
	flick("alien-pad", src)
	for(var/mob/living/target in src.loc)
		target.forceMove(place)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)


/obj/effect/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
