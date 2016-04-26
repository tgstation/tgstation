/obj/machinery/kinetic_accelerator
	name = "\improper Kinetic Accelerator"
	desc = "Makes things go fast."

	density = 0
	anchored = 1

	icon = 'icons/obj/kinetic_accel.dmi'
	icon_state = "linacc1"

	var/power = 0.5
	var/maxspeed = 2

/obj/machinery/kinetic_accelerator/Crossed(var/atom/movable/A)
	if(!istype(A)) return
	if(A.throwing)
		A.throw_speed=min(maxspeed,A.throw_speed+power)