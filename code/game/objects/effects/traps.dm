/obj/effect/trap
	name = "trap"

	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	var/delete_on_trigger = 1
	var/activated = 0

/obj/effect/trap/proc/activate(atom/movable/AM)
	return

/obj/effect/trap/proc/can_activate(atom/movable/AM)
	return (istype(AM, /mob/living/carbon) || istype(AM, /mob/living/silicon))

/obj/effect/trap/Crossed(atom/movable/AM)
	..()
	if(activated) return

	if(can_activate(AM))
		activated = 1
		activate(AM)

		if(delete_on_trigger)
			qdel(src)

/obj/effect/trap/New()
	..()
	invisibility = 101
