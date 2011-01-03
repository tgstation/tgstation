/*
CONTAINS:
GETLINEEEEEEEEEEEEEEEEEEEEE
(well not really but it should)

*/
/obj/item/weapon/flamethrower
	name = "flamethrower"
	icon_state = "flamethrower"
	item_state = "flamethrower_0"
	desc = "You are a firestarter!"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	var/processing = 0
	var/operating = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/part1 = null
	var/obj/item/stack/rods/part2 = null
	var/obj/item/device/igniter/part3 = null
	var/obj/item/weapon/tank/plasma/part4 = null
	m_amt = 500

// PantsNote: Dumping this shit in here until I'm sure it works.

/obj/item/assembly/weld_rod/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/assembly/w_r_ignite/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/weapon/flamethrower/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	//src.part4 = null
	del(src.part4)
	..()
	return

/obj/item/assembly/weld_rod/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench) )
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null

		del(src)

	if (istype(W, /obj/item/device/igniter))
		var/obj/item/device/igniter/I = W
		if (!( I.status ))
			return
		var/obj/item/assembly/weld_rod/S = src
		var/obj/item/assembly/w_r_ignite/R = new /obj/item/assembly/w_r_ignite( user )
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
		I.master = R
		I.layer = initial(I.layer)
		user.u_equip(I)
		if (user.client)
			user.client.screen -= I
		I.loc = R
		src.loc = R
		R.part3 = I
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		//S = null
		del(S)

	src.add_fingerprint(user)
	return

/obj/item/assembly/w_r_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part3.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part3.master = null
		src.part1 = null
		src.part2 = null
		src.part3 = null

		del(src)
		return
	if (istype(W, /obj/item/weapon/screwdriver))
		src.status = !( src.status )
		if (src.status)
			user.show_message("\blue The igniter is now secured!", 1)
			src.icon_state = "flamethrower"
		else
			user.show_message("\blue The igniter is now unsecured!", 1)
			src.icon_state = "flamethrower"
		src.add_fingerprint(user)
		return

/obj/item/weapon/flamethrower/process()
	if(!lit)
		processing_items.Remove(src)
		return null

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc

	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)

/obj/item/weapon/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	if (istype(W,/obj/item/weapon/tank/plasma))
		if(src.part4)
			user << "\red There appears to already be a plasma tank loaded in the flamethrower!"
			return
		src.part4 = W
		W.loc = src
		if (user.client)
			user.client.screen -= W
		user.u_equip(W)
		lit = 0
		force = 3
		damtype = "brute"
		icon_state = "flamethrower0"
		item_state = "flamethrower_0"
	else if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1 && src.part4)
		var/obj/item/weapon/icon = src

		for (var/mob/O in viewers(user, null))
			O << "\red [user] has used the analyzer on \icon[icon]"

		var/pressure = src.part4.air_contents.return_pressure()

		var/total_moles = src.part4.air_contents.total_moles()

		user << "\blue Results of analysis of \icon[icon]"
		if (total_moles>0)
			var/o2_concentration = src.part4.air_contents.oxygen/total_moles
			var/n2_concentration = src.part4.air_contents.nitrogen/total_moles
			var/co2_concentration = src.part4.air_contents.carbon_dioxide/total_moles
			var/plasma_concentration = src.part4.air_contents.toxins/total_moles

			var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

			user << "\blue Pressure: [round(pressure,0.1)] kPa"
			user << "\blue Nitrogen: [round(n2_concentration*100)]%"
			user << "\blue Oxygen: [round(o2_concentration*100)]%"
			user << "\blue CO2: [round(co2_concentration*100)]%"
			user << "\blue Plasma: [round(plasma_concentration*100)]%"
			if(unknown_concentration>0.01)
				user << "\red Unknown: [round(unknown_concentration*100)]%"
			user << "\blue Temperature: [round(src.part4.air_contents.temperature-T0C)]&deg;C"
		else
			user << "\blue Tank is empty!"

// PantsNote: Flamethrower disassmbly.
	else if (istype(W, /obj/item/weapon/screwdriver))
		var/obj/item/weapon/flamethrower/S = src
		if (( S.part4 ))
			return
		var/obj/item/assembly/w_r_ignite/R = new /obj/item/assembly/w_r_ignite( user )
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
		R.layer = 20
		R.loc = user
		S.part1 = null
		S.part2 = null
		S.part3 = null
		//S = null
		del(S)
		user << "\blue The igniter is now unsecured!"


	else	return	..()
	return

/obj/item/weapon/flamethrower/Topic(href,href_list[])
	if (href_list["close"])
		usr.machine = null
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)
		return
	usr.machine = src
	if (href_list["light"])
		if(!src.part4)	return
		if(src.part4.air_contents.toxins < 1)	return
		lit = !(lit)
		if(lit)
			icon_state = "flamethrower1"
			item_state = "flamethrower_1"
			force = 17
			damtype = "fire"
			processing_items.Add(src)
		else
			icon_state = "flamethrower0"
			item_state = "flamethrower_0"
			force = 3
			damtype = "brute"
	if (href_list["amount"])
		src.throw_amount = src.throw_amount + text2num(href_list["amount"])
		src.throw_amount = max(50,min(5000,src.throw_amount))
	if (href_list["remove"])
		if(!src.part4)	return
		var/obj/item/weapon/tank/plasma/A = src.part4
		A.loc = get_turf(src)
		A.layer = initial(A.layer)
		src.part4 = null
		lit = 0
		force = 3
		damtype = "brute"
		icon_state = "flamethrower"
		item_state = "flamethrower_0"
		usr.machine = null
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, src.loc))
		if ((M.client && M.machine == src))
			src.attack_self(M)
	return


/obj/item/weapon/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)
		return
	user.machine = src
	if (!src.part4)
		user << "\red Attach a plasma tank first!"
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [src.part4.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [src.throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return


// gets this from turf.dm turf/dblclick
/obj/item/weapon/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)	return
	operating = 1
	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		if(previousturf && LinkBlocked(previousturf, T))
			break

		ignite_turf(T)

		sleep(1)
	previousturf = null
	operating = 0
	for(var/mob/M in viewers(1, src.loc))
		if ((M.client && M.machine == src))
			src.attack_self(M)
	return

/obj/item/weapon/flamethrower/proc/ignite_turf(turf/target)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...

	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = part4.air_contents.remove_ratio(0.05)
	air_transfer.toxins = air_transfer.toxins * 5 // This is me not comprehending the air system. I realize this is retarded and I could probably make it work without fucking it up like this, but there you have it. -- TLE
	target.assume_air(air_transfer)

	//Burn it based on transfered gas
	//target.hotspot_expose(part4.air_contents.temperature*2,300)
	target.hotspot_expose((part4.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	//location.hotspot_expose(1000,500,1)