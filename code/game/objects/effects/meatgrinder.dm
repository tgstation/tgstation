/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "shadow_portal"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/meatgrinder/New()
	icon_state = "shadow_portal"

/obj/effect/meatgrinder/HasEntered(AM as mob|obj)
	Bumped(AM)

/obj/effect/meatgrinder/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]</font>"
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/meatgrinder/proc/triggerrad1(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 5000
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		del(src)

/obj/effect/mine/meatgrinder
	name = "Meat Grinder"
	icon_state = "shadow_portal"
	triggerproc = "triggerrad1"