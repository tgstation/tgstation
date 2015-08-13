#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE*O2STANDARD)

/obj/item/weapon/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BACK
	hitsound = 'sound/weapons/smash.ogg'

	pressure_resistance = ONE_ATMOSPHERE*5

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70

/obj/item/weapon/tank/New()
	..()

	src.air_contents = new /datum/gas_mixture()
	src.air_contents.volume = volume //liters
	src.air_contents.temperature = T20C

	SSobj.processing |= src

	return

/obj/item/weapon/tank/Destroy()
	if(air_contents)
		del(air_contents)

	SSobj.processing.Remove(src)

	..()

/obj/item/weapon/tank/examine(mob/user)
	var/obj/icon = src
	..()
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if (!in_range(src, user))
		if (icon == src) user << "<span class='notice'>If you want any more information you'll need to get closer.</span>"
		return

	user << "<span class='notice'>The pressure gauge reads [src.air_contents.return_pressure()] kPa.</span>"

	var/celsius_temperature = src.air_contents.temperature-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	user << "<span class='notice'>It feels [descriptive].</span>"

/obj/item/weapon/tank/blob_act()
	if(prob(50))
		var/turf/location = src.loc
		if (!( istype(location, /turf) ))
			qdel(src)

		if(src.air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/weapon/tank/attackby(obj/item/weapon/W, mob/user, params)
	..()

	src.add_fingerprint(user)
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc

	if ((istype(W, /obj/item/device/analyzer)) && get_dist(user, src) <= 1)
		atmosanalyzer_scan(air_contents, user)

	if(istype(W, /obj/item/device/assembly_holder))
		bomb_assemble(W,user)

/obj/item/weapon/tank/attack_self(mob/user)
	if (!(src.air_contents))
		return

	ui_interact(user)

/obj/item/weapon/tank/interact(mob/user, ui_key = "main")
	SSnano.try_update_ui(user, src, ui_key, null, src.get_ui_data())

/obj/item/weapon/tank/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "tanks.tmpl", "Tank", 500, 300, 0)

/obj/item/weapon/tank/get_ui_data()
	var/mob/living/carbon/location = null

	if(istype(loc, /mob/living/carbon))
		location = loc
	else if(istype(loc.loc, /mob/living/carbon))
		location = loc.loc

	var/data = list()
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = 0
	data["maskConnected"] = 0

	if(istype(location))
		var/mask_check = 0

		if(location.internal == src)	// if tank is current internal
			mask_check = 1
			data["valveOpen"] = 1
		else if(src in location)		// or if tank is in the mobs possession
			if(!location.internal)		// and they do not have any active internals
				mask_check = 1

		if(mask_check)
			if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
				data["maskConnected"] = 1
	return data

/obj/item/weapon/tank/Topic(href, href_list)
	..()
	if (usr.stat|| usr.restrained())
		return
	if (src.loc == usr)
		usr.set_machine(src)
		if (href_list["dist_p"])
			if (href_list["dist_p"] == "reset")
				src.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
			else if (href_list["dist_p"] == "max")
				src.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
			else
				var/cp = text2num(href_list["dist_p"])
				src.distribute_pressure += cp
			src.distribute_pressure = min(max(round(src.distribute_pressure), 0), 3*ONE_ATMOSPHERE)
		if (href_list["stat"])
			if(istype(loc,/mob/living/carbon))
				var/mob/living/carbon/location = loc
				if(location.internal == src)
					location.internal = null
					location.internals.icon_state = "internal0"
					usr << "<span class='notice'>You close the tank release valve.</span>"
					if (location.internals)
						location.internals.icon_state = "internal0"
				else
					if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
						location.internal = src
						usr << "<span class='notice'>You open \the [src] valve.</span>"
						if (location.internals)
							location.internals.icon_state = "internal1"
					else
						usr << "<span class='warning'>You need something to connect to \the [src]!</span>"

		src.add_fingerprint(usr)
/*
 * the following is needed for a tank lying on the floor. But currently we restrict players to use not weared tanks as intrals. --rastaf
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
*/
		src.attack_self(usr)
	else
		usr << browse(null, "window=tank")
		return
	return


/obj/item/weapon/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/weapon/tank/return_air()
	return air_contents

/obj/item/weapon/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/weapon/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	return remove_air(moles_needed)

/obj/item/weapon/tank/process()
	//Allow for reactions
	air_contents.react()
	check_status()


/obj/item/weapon/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc,/obj/item/device/transfer_valve))
			message_admins("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
			log_game("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
		//world << "\blue[x],[y] tank is exploding: [pressure] kPa"
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)

		//world << "\blue Exploding Pressure: [pressure] kPa, intensity: [range]"

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		if(istype(src.loc,/obj/item/device/transfer_valve))
			qdel(src.loc)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE)
		//world << "\blue[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]"
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			qdel(src)
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		//world << "\blue[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]"
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++
