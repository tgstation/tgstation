#define RADIATION_CAPACITY 30000 //Radiation isn't particularly effective (TODO BALANCE)


/obj/machinery/atmospherics/unary/thermal_plate
//Based off Heat Reservoir and Space Heater
//Transfers heat between a pipe system and environment, based on which has a greater thermal energy concentration

	icon = 'icons/obj/atmospherics/cold_sink.dmi'
	icon_state = "off"
	level = 1

	name = "Thermal Transfer Plate"
	desc = "Transfers heat to and from an area"

	update_icon()
		var/prefix=""
		//var/suffix="_idle" // Also available: _heat, _cool
		if(level == 1 && istype(loc, /turf/simulated))
			prefix="h"
		icon_state = "[prefix]off"

	process()
		..()

		var/datum/gas_mixture/environment = loc.return_air()

		//Get processable air sample and thermal info from environment

		var/transfer_moles = 0.25 * environment.total_moles()
		var/datum/gas_mixture/external_removed = environment.remove(transfer_moles)

		if (!external_removed)
			return radiate()

		if (external_removed.total_moles() < 10)
			return radiate()

		//Get same info from connected gas

		var/internal_transfer_moles = 0.25 * air_contents.total_moles()
		var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

		if (!internal_removed)
			environment.merge(external_removed)
			return 1

		var/combined_heat_capacity = internal_removed.heat_capacity() + external_removed.heat_capacity()
		var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + external_removed.heat_capacity() * external_removed.temperature

		if(!combined_heat_capacity) combined_heat_capacity = 1
		var/final_temperature = combined_energy / combined_heat_capacity

		external_removed.temperature = final_temperature
		environment.merge(external_removed)

		internal_removed.temperature = final_temperature
		air_contents.merge(internal_removed)

		network.update = 1

		return 1

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		var/prefix=""
		//var/suffix="_idle" // Also available: _heat, _cool
		if(i == 1 && istype(loc, /turf/simulated))
			prefix="h"
		icon_state = "[prefix]off"
		return

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
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user << "\blue You begin to unfasten \the [src]..."
		if (do_after(user, 40))
			user.visible_message( \
				"[user] unfastens \the [src].", \
				"\blue You have unfastened \the [src].", \
				"You hear ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			del(src)

	proc/radiate()

		var/internal_transfer_moles = 0.25 * air_contents.total_moles()
		var/datum/gas_mixture/internal_removed = air_contents.remove(internal_transfer_moles)

		if (!internal_removed)
			return 1

		var/combined_heat_capacity = internal_removed.heat_capacity() + RADIATION_CAPACITY
		var/combined_energy = internal_removed.temperature * internal_removed.heat_capacity() + (RADIATION_CAPACITY * 6.4)

		var/final_temperature = combined_energy / combined_heat_capacity

		internal_removed.temperature = final_temperature
		air_contents.merge(internal_removed)

		if (network)
			network.update = 1

		return 1