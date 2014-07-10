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

/obj/machinery/the_singularitygen/process()
	if (energy < 200)
		return

	var/prints
	if (fingerprintshidden && fingerprintshidden.len)

		for (var/i = 1, i < fingerprintshidden.len, i++)
			if (i > fingerprintshidden.len)
				break

			if (1 == i)
				prints += fingerprintshidden[i]
			else
				prints += ", [fingerprintshidden[i]]"

	log_admin("New singularity made, all touchers. [prints]. Last touched by [fingerprintslast].")
	message_admins("New singularity made, all touchers. [prints]. Last touched by [fingerprintslast].")
	new /obj/machinery/singularity/(get_turf(src), 50)
	qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet")
			src.add_hiddenprint(user)
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet")
		return
	return ..()
