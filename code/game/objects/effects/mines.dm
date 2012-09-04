/obj/effect/mine
	name = "Mine"
	desc = "I Better stay away from that thing."
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/mine/New()
	icon_state = "uglyminearmed"

/obj/effect/mine/HasEntered(AM as mob|obj)
	Bumped(AM)

/obj/effect/mine/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]</font>"
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/mine/proc/triggerrad(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 50
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		del(src)

/obj/effect/mine/proc/triggerstun(obj)
	if(ismob(obj))
		var/mob/M = obj
		M.Stun(30)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		del(src)

/obj/effect/mine/proc/triggern2o(obj)
	//example: n2o triggerproc
	//note: im lazy

	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)
			//skytodo
			/*if(target.parent)
				target.parent.suspend_group_processing()*/

			var/datum/gas_mixture/payload = new
			var/datum/gas/sleeping_agent/trace_gas = new

			trace_gas.moles = 30
			payload += trace_gas

			target.air.merge(payload)

	spawn(0)
		del(src)

/obj/effect/mine/proc/triggerplasma(obj)
	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)
			//skytodo
			/*if(target.parent)
				target.parent.suspend_group_processing()*/

			var/datum/gas_mixture/payload = new

			payload.toxins = 30

			target.air.merge(payload)

			target.hotspot_expose(1000, CELL_VOLUME)

	spawn(0)
		del(src)

/obj/effect/mine/proc/triggerkick(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	del(obj:client)
	spawn(0)
		del(src)

/obj/effect/mine/proc/explode(obj)
	explosion(loc, 0, 1, 2, 3)
	spawn(0)
		del(src)




/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	icon_state = "uglymine"
	triggerproc = "triggerrad"

/obj/effect/mine/plasma
	name = "Plasma Mine"
	icon_state = "uglymine"
	triggerproc = "triggerplasma"

/obj/effect/mine/kick
	name = "Kick Mine"
	icon_state = "uglymine"
	triggerproc = "triggerkick"

/obj/effect/mine/n2o
	name = "N2O Mine"
	icon_state = "uglymine"
	triggerproc = "triggern2o"

/obj/effect/mine/stun
	name = "Stun Mine"
	icon_state = "uglymine"
	triggerproc = "triggerstun"
