/obj/machinery/water/binary/fixture
	name = "water fixture connection"
	icon = 'water_fixtures.dmi'
	icon_state = "fixture"
	level = 1
	layer = 2.9

	var/obj/parent

	hide(var/i)
		if(level == 1 && istype(loc, /turf/simulated))
			invisibility = i ? 101 : 0
		update_icon()

	initialize()
		..()
		var/turf/T = src.loc	// hide if turf is not intact
		hide(T.intact)
		update_icon()

	process()
		..()

		// handle leaks
		if(!network1 && r1.total_volume > 0)
			mingle_dc1_with_turf()

		if(!network2 && r2.total_volume > 0)
			mingle_dc2_with_turf()

	proc/fill(amount)
		if(!parent || !parent.reagents || amount <= 0) return
		amount = min(amount, parent.reagents.maximum_volume-parent.reagents.total_volume)
		var/parent_pressure = parent.reagents.total_volume / parent.reagents.maximum_volume

		if(return_pressure1() > parent_pressure)
			r1.trans_to(parent, amount)
			if(network1)
				network1.update = 1
			return amount
		else
			return 0

	proc/drain(amount)
		if(!parent || !parent.reagents || amount <= 0) return
		amount = min(amount, r2.maximum_volume-r2.total_volume)
		var/parent_pressure = parent.reagents.total_volume / parent.reagents.maximum_volume

		if(return_pressure2() < parent_pressure)
			parent.reagents.trans_to(r2, amount)
			if(network2)
				network2.update = 1
			return amount
		else
			return 0

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((return_pressure1()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/water_pipe(loc, make_from=src)
			del(src)
