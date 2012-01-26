#define SPRINKLER_VOLUME_PER_SPLASH 3

/obj/machinery/water/unary/sprinkler
	name = "fire sprinkler"
	icon = 'water_fixtures.dmi'
	icon_state = "sprinkler0"
	layer = 5
	max_volume = 100
	max_pressure = ONE_ATMOSPHERE

	var/on = 0

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		on = temperature > T0C+200 ? 50 : 0
		update_icon()

	update_icon()
		icon_state = "sprinkler[(on || stat) > 0]"

	process()
		// make broken sprinkler stay on forever
		if((!stat && !on) || reagents.total_volume < SPRINKLER_VOLUME_PER_SPLASH)
			return

		if(on > 0)
			on--

		// from extinguisher
		/*var/direction = turn(dir, 180)

		var/turf/T = get_turf(loc)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))
		for(var/i = 1 to 5)
			T2 = get_step(T2,direction)

		var/list/the_targets = block(T1, T2)*/	// 3x3 grid in front of sprinkler

		var/list/the_targets = view(5, src.loc)
		if(the_targets.len == 0)
			return

		for(var/a=0, a<round(reagents.total_volume/SPRINKLER_VOLUME_PER_SPLASH), a++)
			spawn(0)
				var/obj/effect/effect/water/W = new /obj/effect/effect/water(get_turf(src))
				var/turf/my_target = get_turf(pick(the_targets))
				var/datum/reagents/R = new/datum/reagents(SPRINKLER_VOLUME_PER_SPLASH)
				if(!W) return
				W.reagents = R
				R.my_atom = W
				if(!W || !src) return
				reagents.trans_to(W,SPRINKLER_VOLUME_PER_SPLASH)
				for(var/b=0, b<7, b++)
					step_towards(W,my_target)
					if(!W) return
					W.reagents.reaction(get_turf(W))
					for(var/atom/atm in get_turf(W))
						if(!W) return
						W.reagents.reaction(atm)
					if(W.loc == my_target) break
		if(network)
			network.update = 1

	attack_paw(mob/user as mob)
		attack_hand(user)

	attack_hand(mob/user as mob)
		if(user.a_intent != "help" && (stat & BROKEN) == 0)
			stat |= BROKEN
			update_icon()
			user.visible_message("\red [user] smashes \the [src]!",
				"\red You smash \the [src]!",
				"You hear a clang sound.")

	attackby(obj/item/weapon/wrench/W, mob/user as mob)
		if(istype(W))
			if((stat & BROKEN) == BROKEN)
				stat &= ~BROKEN
				update_icon()
				user.visible_message("\blue [user] wrenches \the [src] back closed.", \
					"\blue You wrench \the [src] back closed.", \
					"You hear a wrenching sound.")
			else
				var/turf/T = src.loc
				if (level==1 && isturf(T) && T.intact)
					user << "\red You must remove the plating first."
					return 1
				var/datum/gas_mixture/env_air = loc.return_air()
				if ((return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
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
		else
			..()

#undef SPRINKLER_VOLUME_PER_SPLASH