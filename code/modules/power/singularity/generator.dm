/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	var/energy = 0

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/the_singularitygen/process()
	if (energy < 200)
		return

	var/prints=""
	if (fingerprintshidden)
		prints=", all touchers: "+fingerprintshidden

	log_admin("New singularity made[prints]. Last touched by [fingerprintslast].")
	message_admins("New singularity made[prints]. Last touched by [fingerprintslast].")
	new /obj/machinery/singularity(get_turf(src), 50)
	qdel(src)

/obj/machinery/the_singularitygen/wrenchAnchor(mob/user)
	src.add_hiddenprint(user)
	return ..()

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	return ..()
