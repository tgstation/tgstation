/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from human habitat"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	anchored = 1
	var/turf/teleport_target

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	target.Move(src.loc)

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = teleportlocs[pick(teleportlocs)]
	flick("alien-pad", src)
	for(var/mob/living/target in loc)
		target.forceMove(teleport_target)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	spawn(0)
		anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)
	Warp(target)

/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	new/obj/effect/overlay/temp/teleport_abductor(place)
	sleep(80)
	flick("alien-pad", src)
	target.forceMove(place)
	anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	new/obj/effect/overlay/temp/teleport_abductor(place)
	sleep(80)
	flick("alien-pad", src)
	for(var/mob/living/target in src.loc)
		target.forceMove(place)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)


/obj/effect/overlay/temp/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
	duration = 80

/obj/effect/overlay/temp/teleport_abductor/New()
	var/datum/effect_system/spark_spread/S = new
	S.set_up(10,0,loc)
	S.start()
	..()