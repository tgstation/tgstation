/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An Odd Device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	resistance_flags = FIRE_PROOF
	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(src.energy >= 200)
		feedback_add_details("engine_started","[src.type]")
		var/obj/singularity/S = new creation_type(T, 50)
		transfer_fingerprints_to(S)
		qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, W, 0)
	else
		return ..()
