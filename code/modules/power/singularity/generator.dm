/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	resistance_flags = FIRE_PROOF

	// You can buckle someone to the singularity generator, then start the engine. Fun!
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/attack_hand(mob/user)
	if(user.a_intent == INTENT_GRAB && user_buckle_mob(user.pulling, user, check_loc = 0))
		return
	..()

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, W, 0)
	else
		return ..()

/obj/machinery/the_singularitygen/process()
	if(energy > 0)
		if(energy >= 200)
			var/turf/T = get_turf(src)
			SSblackbox.add_details("engine_started","[src.type]")
			var/obj/singularity/S = new creation_type(T, 50)
			transfer_fingerprints_to(S)
			qdel(src)
		else
			energy -= 1
