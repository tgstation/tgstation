
/obj/item/weapon/tank
	name = "tank"
	icon = 'tank.dmi'

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BACK

	pressure_resistance = ONE_ATMOSPHERE*5

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	var/volume = 70


/obj/item/weapon/tank/anesthetic
	name = "Gas Tank (Sleeping Agent)"
	desc = "A N2O/O2 gas mix"
	icon_state = "anesthetic"
	item_state = "an_tank"



/obj/item/weapon/tank/air
	name = "Gas Tank (Air Mix)"
	desc = "Mixed anyone?"
	icon_state = "oxygen"


	examine()
		set src in usr
		..()
		if(air_contents.oxygen < 1 && loc==usr)
			usr << "\red <B>The meter on the [src.name] indicates you are almost out of air!</B>"
			usr << sound('alert.ogg')


/obj/item/weapon/tank/plasma
	name = "Gas Tank (BIOHAZARD)"
	desc = "Contains dangerous plasma. Do not inhale."
	icon_state = "plasma"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = null	//they have no straps!

/obj/item/weapon/tank/blob_act()
	if(prob(50))
		var/turf/location = src.loc
		if (!( istype(location, /turf) ))
			del(src)

		if(src.air_contents)
			location.assume_air(air_contents)

		del(src)

/obj/item/weapon/tank/attack_self(mob/user as mob)
	if (!(src.air_contents))
		return
	user.machine = src

	var/using_internal
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal==src)
			using_internal = 1

	var/message = {"
<b>Tank</b><BR>
<FONT color='blue'><b>Tank Pressure:</b> [air_contents.return_pressure()]</FONT><BR>
<BR>
<b>Mask Release Pressure:</b> <A href='?src=\ref[src];dist_p=-10'>-</A> <A href='?src=\ref[src];dist_p=-1'>-</A> [distribute_pressure] <A href='?src=\ref[src];dist_p=1'>+</A> <A href='?src=\ref[src];dist_p=10'>+</A><BR>
<b>Mask Release Valve:</b> <A href='?src=\ref[src];stat=1'>[using_internal?("Open"):("Closed")]</A>
"}
	user << browse(message, "window=tank;size=600x300")
	onclose(user, "tank")
	return

/obj/item/weapon/tank/Topic(href, href_list)
	..()
	if (usr.stat|| usr.restrained())
		return
	if (src.loc == usr)
		usr.machine = src
		if (href_list["dist_p"])
			var/cp = text2num(href_list["dist_p"])
			src.distribute_pressure += cp
			src.distribute_pressure = min(max(round(src.distribute_pressure), 0), 3*ONE_ATMOSPHERE)
		if (href_list["stat"])
			if(istype(loc,/mob/living/carbon))
				var/mob/living/carbon/location = loc
				if(location.internal == src)
					location.internal = null
					location.internals.icon_state = "internal0"
					usr << "\blue You close the tank release valve."
					if (location.internals)
						location.internals.icon_state = "internal0"
				else
					if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
						location.internal = src
						usr << "\blue You open \the [src] valve."
						if (location.internals)
							location.internals.icon_state = "internal1"
					else
						usr << "\blue You need something to connect to \the [src]."

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

/obj/item/weapon/tank
	remove_air(amount)
		return air_contents.remove(amount)

	return_air()
		return air_contents

	assume_air(datum/gas_mixture/giver)
		air_contents.merge(giver)

		check_status()
		return 1

	proc/remove_air_volume(volume_to_return)
		if(!air_contents)
			return null

		var/tank_pressure = air_contents.return_pressure()
		if(tank_pressure < distribute_pressure)
			distribute_pressure = tank_pressure

		var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

		return remove_air(moles_needed)

	process()
		//Allow for reactions
		air_contents.react()

		check_status()

	var/integrity = 3
	proc/check_status()
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
			range = min(range, MAX_EXPLOSION_RANGE)		// was 8 - - - Changed to a configurable define -- TLE
			var/turf/epicenter = get_turf(loc)

			//world << "\blue Exploding Pressure: [pressure] kPa, intensity: [range]"

			explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
			del(src)

		else if(pressure > TANK_RUPTURE_PRESSURE)
			//world << "\blue[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]"
			if(integrity <= 0)
				loc.assume_air(air_contents)
				//TODO: make pop sound
				del(src)
			else
				integrity--

		else if(pressure > TANK_LEAK_PRESSURE)
			//world << "\blue[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]"
			if(integrity <= 0)
				var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
				loc.assume_air(leaked_gas)
			else
				integrity--

		else if(integrity < 3)
			integrity++


/obj/item/weapon/tank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	var/obj/icon = src
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if ((istype(W, /obj/item/device/analyzer) || (istype(W, /obj/item/device/pda))) && get_dist(user, src) <= 1)

		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used [W] on \icon[icon] [src]"

		var/pressure = air_contents.return_pressure()

		var/total_moles = air_contents.total_moles()

		user << "\blue Results of analysis of \icon[icon]"
		if (total_moles>0)
			var/o2_concentration = air_contents.oxygen/total_moles
			var/n2_concentration = air_contents.nitrogen/total_moles
			var/co2_concentration = air_contents.carbon_dioxide/total_moles
			var/plasma_concentration = air_contents.toxins/total_moles

			var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

			user << "\blue Pressure: [round(pressure,0.1)] kPa"
			user << "\blue Nitrogen: [round(n2_concentration*100)]%"
			user << "\blue Oxygen: [round(o2_concentration*100)]%"
			user << "\blue CO2: [round(co2_concentration*100)]%"
			user << "\blue Plasma: [round(plasma_concentration*100)]%"
			if(unknown_concentration>0.01)
				user << "\red Unknown: [round(unknown_concentration*100)]%"
			user << "\blue Temperature: [round(air_contents.temperature-T0C)]&deg;C"
		else
			user << "\blue Tank is empty!"
		src.add_fingerprint(user)
	else if (istype(W,/obj/item/latexballon))
		var/obj/item/latexballon/LB = W
		LB.blow(src)
		src.add_fingerprint(user)
	return

/obj/item/weapon/tank/New()
	..()

	src.air_contents = new /datum/gas_mixture()
	src.air_contents.volume = volume //liters
	src.air_contents.temperature = T20C

	processing_objects.Add(src)

	return

/obj/item/weapon/tank/Del()
	if(air_contents)
		del(air_contents)

	processing_objects.Remove(src)

	..()

/obj/item/weapon/tank/examine()
	var/obj/icon = src
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if (!in_range(src, usr))
		if (icon == src) usr << "\blue It's \a \icon[icon][src]! If you want any more information you'll need to get closer."
		return

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

	usr << "\blue \The \icon[icon][src] feels [descriptive]"

	return

/obj/item/weapon/tank/air/New()
	..()

	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	src.air_contents.nitrogen = (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return


/obj/item/weapon/tank/anesthetic/New()
	..()

	src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD

	var/datum/gas/sleeping_agent/trace_gas = new()
	trace_gas.moles = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD

	src.air_contents.trace_gases += trace_gas
	return

/obj/item/weapon/tank/plasma/New()
	..()

	src.air_contents.toxins = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return


/obj/item/weapon/tank/plasma/proc/release()
	var/datum/gas_mixture/removed = air_contents.remove(air_contents.total_moles())

	loc.assume_air(removed)

/obj/item/weapon/tank/plasma/proc/ignite()
	var/fuel_moles = air_contents.toxins + air_contents.oxygen/6
	var/strength = 1

	var/turf/ground_zero = get_turf(loc)
	loc = null

	if(air_contents.temperature > (T0C + 400))
		strength = fuel_moles/15

		explosion(ground_zero, strength, strength*2, strength*3, strength*4)

	else if(air_contents.temperature > (T0C + 250))
		strength = fuel_moles/20

		explosion(ground_zero, 0, strength, strength*2, strength*3)

	else if(air_contents.temperature > (T0C + 100))
		strength = fuel_moles/25

		explosion(ground_zero, 0, 0, strength, strength*3)

	else
		ground_zero.assume_air(air_contents)
		ground_zero.hotspot_expose(1000, 125)

	if(src.master)
		del(src.master)
	del(src)

/obj/item/weapon/tank/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)

	..()
// PantsNote: More flamethrower assembly code. WOO!
	if (istype(W, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = W
		if ((!F.status)||(F.ptank))	return
		src.master = F
		F.ptank = src
		user.before_take_item(src)
		src.loc = F
	return
