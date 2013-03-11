/obj/machinery/atmospherics/unary/heat_exchanger

	icon = 'icons/obj/atmospherics/heat_exchanger.dmi'
	icon_state = "intact"
	density = 1

	name = "Heat Exchanger"
	desc = "Exchanges heat between two input gases. Setup for fast heat transfer"

	var/obj/machinery/atmospherics/unary/heat_exchanger/partner = null
	var/update_cycle

	update_icon()
		if(node)
			icon_state = "intact"
		else
			icon_state = "exposed"

		return

	initialize()
		if(!partner)
			var/partner_connect = turn(dir,180)

			for(var/obj/machinery/atmospherics/unary/heat_exchanger/target in get_step(src,partner_connect))
				if(target.dir & get_dir(src,target))
					partner = target
					partner.partner = src
					break

		..()

	process()
		..()
		if(!partner)
			return 0

		if(!air_master || air_master.current_cycle <= update_cycle)
			return 0

		update_cycle = air_master.current_cycle
		partner.update_cycle = air_master.current_cycle

		var/air_heat_capacity = air_contents.heat_capacity()
		var/other_air_heat_capacity = partner.air_contents.heat_capacity()
		var/combined_heat_capacity = other_air_heat_capacity + air_heat_capacity

		var/old_temperature = air_contents.temperature
		var/other_old_temperature = partner.air_contents.temperature

		if(combined_heat_capacity > 0)
			var/combined_energy = partner.air_contents.temperature*other_air_heat_capacity + air_heat_capacity*air_contents.temperature

			var/new_temperature = combined_energy/combined_heat_capacity
			air_contents.temperature = new_temperature
			partner.air_contents.temperature = new_temperature

		if(network)
			if(abs(old_temperature-air_contents.temperature) > 1)
				network.update = 1

		if(partner.network)
			if(abs(other_old_temperature-partner.air_contents.temperature) > 1)
				partner.network.update = 1

		return 1

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if (!istype(W, /obj/item/weapon/wrench))
			return ..()
		var/turf/T = src.loc
		if (level==1 && isturf(T) && T.intact)
			user << "\red You must remove the plating first."
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
			add_fingerprint(user)
			return 1
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)