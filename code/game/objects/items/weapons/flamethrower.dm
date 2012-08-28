//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/flamethrower
	name = "flamethrower"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	desc = "You are a firestarter!"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 500
	origin_tech = "combat=1;plasmatech=1"
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/plasma/ptank = null


	Del()
		if(src.weldtool)
			del(src.weldtool)
		if(src.igniter)
			del(src.igniter)
		if(src.ptank)
			del(src.ptank)
		..()
		return


	process()
		if(!lit)
			processing_objects.Remove(src)
			return null
		var/turf/location = src.loc
		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = M.loc
		if(isturf(location)) //start a fire if possible
			location.hotspot_expose(700, 2)
		return


	update_icon()
		src.overlays = null
		if(igniter)
			src.overlays += "+igniter[src.status]"
		if(ptank)
			src.overlays += "+ptank"
		if(lit)
			src.overlays += "+lit"
			item_state = "flamethrower_1"
		else
			item_state = "flamethrower_0"
		return


	attackby(obj/item/W as obj, mob/user as mob)
		if(user.stat || user.restrained() || user.lying)	return
		if(iswrench(W) && (!src.status))//Taking this apart
			var/turf/T = src.loc
			if (ismob(T))
				T = T.loc
			if(weldtool)
				src.weldtool.loc = T
				src.weldtool = null
			if(igniter)
				src.igniter.loc = T
				src.igniter = null
			if(ptank)
				src.ptank.loc = T
				src.ptank = null
			new/obj/item/stack/rods(T,1)
			spawn(0)
				del(src)
			return

		if((isscrewdriver(W))&&(igniter)&&(!lit))
			src.status = (!src.status)
			if (src.status)
				user.show_message("\blue The igniter is now secured!", 1)
			else
				user.show_message("\blue The igniter is now unsecured!", 1)
			update_icon()
			return

		if(isigniter(W))
			var/obj/item/device/assembly/igniter/I = W
			if(I.secured)	return 0
			if(src.igniter)	 return
			user.remove_from_mob(I)
			I.loc = src
			igniter = I
			update_icon()
			return

		if(istype(W,/obj/item/weapon/tank/plasma))
			if(src.ptank)
				user << "\red There appears to already be a plasma tank loaded in the flamethrower!"
				return
			src.ptank = W
			W.loc = src
			if (user.client)
				user.client.screen -= W
			user.u_equip(W)
			lit = 0
			force = 3
			damtype = "brute"
			update_icon()
			return

		if((istype(W, /obj/item/device/analyzer)) && (get_dist(user, src) <= 1) && (src.ptank))
			var/obj/item/weapon/icon = src
			for (var/mob/O in viewers(user, null))
				O << "\red [user] has used the analyzer on \icon[icon]"
			var/pressure = src.ptank.air_contents.return_pressure()
			var/total_moles = src.ptank.air_contents.total_moles()

			user << "\blue Results of analysis of \icon[icon]"
			if (total_moles>0)
				var/o2_concentration = src.ptank.air_contents.oxygen/total_moles
				var/n2_concentration = src.ptank.air_contents.nitrogen/total_moles
				var/co2_concentration = src.ptank.air_contents.carbon_dioxide/total_moles
				var/plasma_concentration = src.ptank.air_contents.toxins/total_moles

				var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

				user << "\blue Pressure: [round(pressure,0.1)] kPa"
				user << "\blue Nitrogen: [round(n2_concentration*100)]%"
				user << "\blue Oxygen: [round(o2_concentration*100)]%"
				user << "\blue CO2: [round(co2_concentration*100)]%"
				user << "\blue Plasma: [round(plasma_concentration*100)]%"
				if(unknown_concentration>0.01)
					user << "\red Unknown: [round(unknown_concentration*100)]%"
				user << "\blue Temperature: [round(src.ptank.air_contents.temperature-T0C)]&deg;C"
			else
				user << "\blue Tank is empty!"
			return
		..()
		return


	attack_self(mob/user as mob)
		if(user.stat || user.restrained() || user.lying)	return
		user.machine = src
		if (!src.ptank)
			user << "\red Attach a plasma tank first!"
			return
		var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [src.ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [src.throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
		user << browse(dat, "window=flamethrower;size=600x300")
		onclose(user, "flamethrower")
		return


	Topic(href,href_list[])
		if (href_list["close"])
			usr.machine = null
			usr << browse(null, "window=flamethrower")
			return
		if(usr.stat || usr.restrained() || usr.lying)	return
		usr.machine = src
		if (href_list["light"])
			if(!src.ptank)	return
			if(src.ptank.air_contents.toxins < 1)	return
			if(!src.status)	return
			lit = !(lit)
			if(lit)
				force = 17
				damtype = "fire"
				processing_objects.Add(src)
			else
				force = 3
				damtype = "brute"
		if (href_list["amount"])
			src.throw_amount = src.throw_amount + text2num(href_list["amount"])
			src.throw_amount = max(50,min(5000,src.throw_amount))
		if (href_list["remove"])
			if(!src.ptank)	return
			var/obj/item/weapon/tank/plasma/A = src.ptank
			A.loc = get_turf(src)
			A.layer = initial(A.layer)
			src.ptank = null
			lit = 0
			force = 3
			damtype = "brute"
			usr.machine = null
			usr << browse(null, "window=flamethrower")
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
		update_icon()
		return


//Called from turf.dm turf/dblclick
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
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(0.05)
	air_transfer.toxins = air_transfer.toxins * 5 // This is me not comprehending the air system. I realize this is retarded and I could probably make it work without fucking it up like this, but there you have it. -- TLE
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	//target.hotspot_expose(part4.air_contents.temperature*2,300)
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	//location.hotspot_expose(1000,500,1)
	return


/obj/item/weapon/flamethrower/full/New(var/loc)
	..()
	weldtool = new/obj/item/weapon/weldingtool(src)
	weldtool.status = 0
	igniter = new/obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	src.status = 1
	update_icon()
	return