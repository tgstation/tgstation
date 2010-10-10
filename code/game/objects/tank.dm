/obj/item/weapon/tank/blob_act()
	if(prob(50))
		var/turf/location = src.loc
		if (!( istype(location, /turf) ))
			del(src)

		if(src.air_contents)
			location.assume_air(air_contents)

		del(src)

/obj/item/weapon/tank/attack_self(mob/user as mob)
	user.machine = src
	if (!(src.air_contents))
		return

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
					usr << "\blue You close the tank release valve."
				else
					if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
						location.internal = src
						usr << "\blue You open the tank valve."
					else
						usr << "\blue The valve immediately closes."

		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
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

/obj/item/weapon/tank/attack(mob/M as mob, mob/user as mob)
	..()
	if ((prob(30) && M.stat < 2))
		var/mob/living/carbon/human/H = M

// ******* Check

		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(2, 6)
		if (prob(90))
			if (M.paralysis < time)
				M.paralysis = time
		else
			if (M.stunned < time)
				M.stunned = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if ((O.client && !( O.blinded )))
				O << text("\red <B>[] has been knocked unconscious!</B>", M)
	return

/obj/item/weapon/tank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/obj/item/weapon/icon = src
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
	return

/obj/item/weapon/tank/New()
	..()

	src.air_contents = new /datum/gas_mixture()
	src.air_contents.volume = 70 //liters
	src.air_contents.temperature = T20C

	processing_items.Add(src)

	return

/obj/item/weapon/tank/Del()
	if(air_contents)
		del(air_contents)

	processing_items.Remove(src)

	..()

/obj/item/weapon/tank/examine()
	var/obj/item/weapon/icon = src
	if (istype(src.loc, /obj/item/assembly))
		icon = src.loc
		if (!in_range(src, usr))
			if (icon == src) usr << "\blue It's a \icon[icon]! If you want any more information you'll need to get closer."
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

		usr << text("\blue The \icon[] feels []", icon, descriptive)

	return

/obj/item/weapon/tank/air/New()
	..()

	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD
	src.air_contents.nitrogen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD
	return

/obj/item/weapon/tank/oxygen/New()
	..()

	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/emergency_oxygen/New()
	..()

	src.air_contents.oxygen = (3*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/jetpack/New()
	..()
	src.ion_trail = new /datum/effects/system/ion_trail_follow()
	src.ion_trail.set_up(src)
	src.air_contents.oxygen = (6*ONE_ATMOSPHERE)*70/(R_IDEAL_GAS_EQUATION*T20C)
	return

/obj/item/weapon/tank/jetpack/verb/toggle()
	set name = "Toggle Jetpack"
	src.on = !( src.on )
	src.icon_state = text("jetpack[]", src.on)
	if(src.on)
		src.ion_trail.start()
	else
		src.ion_trail.stop()
	return

/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/user as mob)
	if (!( src.on ))
		return 0
	if ((num < 0.01 || src.air_contents.total_moles() < num))
		src.ion_trail.stop()
		return 0

	var/datum/gas_mixture/G = src.air_contents.remove(num)

	if (G.oxygen >= 0.01)
		return 1
	if (G.toxins > 0.001)
		if (user)
			var/d = G.toxins / 2
			d = min(abs(user.health + 100), d, 25)
			user.fireloss += d
			user.updatehealth()
		return (G.oxygen >= 0.0075 ? 0.5 : 0)
	else
		if (G.oxygen >= 0.0075)
			return 0.5
		else
			return 0
	//G = null
	del(G)
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

	if(src.master) del(src.master)
	del(src)

/obj/item/weapon/tank/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/assembly/rad_ignite))
		var/obj/item/assembly/rad_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/assembly/r_i_ptank/R = new /obj/item/assembly/r_i_ptank( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)
	if (istype(W, /obj/item/assembly/prox_ignite))
		var/obj/item/assembly/prox_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/assembly/m_i_ptank/R = new /obj/item/assembly/m_i_ptank( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)

	if (istype(W, /obj/item/assembly/time_ignite))
		var/obj/item/assembly/time_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/assembly/t_i_ptank/R = new /obj/item/assembly/t_i_ptank( user )
		R.part1 = S.part1
		if (S.part1)
			S.part1.loc = R
			S.part1.master = R
		R.part2 = S.part2
		if (S.part2)
			S.part2.loc = R
			S.part2.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)
	if (istype(W, /obj/item/assembly/a_i_a))
		var/obj/item/assembly/a_i_a/S = W
		if (!( S.status ))
			return
		var/obj/item/clothing/suit/armor/a_i_a_ptank/R = new /obj/item/clothing/suit/armor/a_i_a_ptank( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		R.part3 = S.part3
		S.part3.loc = R
		S.part3.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part4 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		S.part3 = null
		//S = null
		del(S)
// PantsNote: More flamethrower assembly code. WOO!
	if (istype(W, /obj/item/assembly/w_r_ignite))
		var/obj/item/assembly/w_r_ignite/S = W
		if (!( S.status ))
			return
		var/obj/item/weapon/flamethrower/R = new /obj/item/weapon/flamethrower( user )
		R.part1 = S.part1
		S.part1.loc = R
		S.part1.master = R
		R.part2 = S.part2
		S.part2.loc = R
		S.part2.master = R
		R.part3 = S.part3
		S.part3.loc = R
		S.part3.master = R
		S.layer = initial(S.layer)
		if (user.client)
			user.client.screen -= S
		if (user.r_hand == S)
			user.u_equip(S)
			user.r_hand = R
		else
			user.u_equip(S)
			user.l_hand = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part4 = src
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		S.part3 = null
		//S = null
		del(S)

	return