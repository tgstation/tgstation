/*
/obj/item/weapon/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	flags = FPRINT
	siemens_coefficient = 1
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	starting_materials = list(MAT_IRON = 500)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "combat=1;plasmatech=1"
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/plasma/ptank = null


/obj/item/weapon/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
		weldtool = null
	if(igniter)
		qdel(igniter)
		igniter = null
	if(ptank)
		qdel(ptank)
		ptank = null
	..()
	return


/obj/item/weapon/flamethrower/process()
	if(!lit)
		processing_objects.Remove(src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2,surfaces=istype(loc,/turf))
	return


/obj/item/weapon/flamethrower/update_icon()
	overlays.len = 0
	if(igniter)
		overlays += "+igniter[status]"
	if(ptank)
		overlays += "+ptank"
	if(lit)
		overlays += "+lit"
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/weapon/flamethrower/afterattack(atom/target, mob/user, flag)
	// Make sure our user is still holding us
	user.delayNextAttack(8)
	if(user && user.get_active_hand() == src)
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			flame_turf(turflist)

/obj/item/weapon/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	if(iswrench(W) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.loc = T
			weldtool = null
		if(igniter)
			igniter.loc = T
			igniter = null
		if(ptank)
			ptank.loc = T
			ptank = null
		getFromPool(/obj/item/stack/rods, T)
		qdel(src)
		return

	if(isscrewdriver(W) && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	if(isigniter(W))
		var/obj/item/device/assembly/igniter/I = W
		if(I.secured)	return
		if(igniter)		return
		if(user.drop_item(I, src))
			igniter = I
			update_icon()
			return

	if(istype(W,/obj/item/weapon/tank/plasma))
		if(ptank)
			to_chat(user, "<span class='notice'>There appears to already be a plasma tank loaded in [src]!</span>")
			return
		if(user.drop_item(W, src))
			ptank = W
			update_icon()
			return

	if(istype(W, /obj/item/device/analyzer) && ptank)
		var/obj/item/device/analyzer/analyzer = W
		user.visible_message("<span class='notice'>[user] has used the analyzer on [bicon(icon)]</span>")
		user.show_message(analyzer.output_gas_scan(ptank.air_contents, src, 0), 1)
		return
	..()
	return


/obj/item/weapon/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return


/obj/item/weapon/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(ptank.air_contents.toxins < 1)	return
		if(!status)	return
		lit = !lit
		if(lit)
			processing_objects.Add(src)
	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = max(50, min(5000, throw_amount))
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
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
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/weapon/flamethrower/proc/ignite_turf(turf/target)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(0.02*(throw_amount/100))
	//air_transfer.toxins = air_transfer.toxins * 5 // This is me not comprehending the air system. I realize this is retarded and I could probably make it work without fucking it up like this, but there you have it. -- TLE
	var/plasma_moles = air_transfer.toxins
	getFromPool(/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel, target, plasma_moles*10, get_dir(loc, target))
	air_transfer.toxins = 0
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	//target.hotspot_expose(part4.air_contents.temperature*2,300)
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	//location.hotspot_expose(1000,500,1)
	return

/obj/item/weapon/flamethrower/full/New(var/loc)
	..()
	weldtool = new /obj/item/weapon/weldingtool(src)
	weldtool.status = 0
	igniter = new /obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()
	return
*/

/obj/item/weapon/gun/projectile/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	flags = FPRINT
	siemens_coefficient = 1
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	starting_materials = list(MAT_IRON = 500)
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = "combat=1;plasmatech=1"
	ejectshell = 0
	caliber = null
	ammo_type = null
	fire_sound = null
	conventional_firearm = 0
	silenced = 1
	var/status = 0
	var/throw_percent = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/plasma/ptank = null


/obj/item/weapon/gun/projectile/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
		weldtool = null
	if(igniter)
		qdel(igniter)
		igniter = null
	if(ptank)
		qdel(ptank)
		ptank = null
	..()
	return


/obj/item/weapon/gun/projectile/flamethrower/process()
	if(!lit)
		processing_objects.Remove(src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2,surfaces=istype(loc,/turf))
	return


/obj/item/weapon/gun/projectile/flamethrower/update_icon()
	overlays.len = 0
	if(igniter)
		overlays += "+igniter[status]"
	if(ptank)
		overlays += "+ptank"
	if(lit)
		overlays += "+lit"
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/weapon/gun/projectile/flamethrower/afterattack(atom/target, mob/user, flag)
	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (target.loc == user.loc)
		return

	else if (target.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	if(!lit)// || operating)
		return
	if(lit && !ptank)
		to_chat(user, "<span class='warning'>There's no tank attached.</span>")
		return

	user.delayNextAttack(8)
	var/obj/item/projectile/bullet/fire_plume/B = new(null)
	in_chamber = B

	var/datum/gas_mixture/tank_gas = ptank.air_contents

	if(!tank_gas)
		return
	tank_gas.update_values()
	var/pressure = tank_gas.return_pressure()
	var/total_moles = tank_gas.total_moles()
	if(total_moles)
		var/o2_concentration = tank_gas.oxygen/total_moles
		if(o2_concentration > 0.01)
			B.has_O2_in_mix = 1
	else
		qdel(B)
		in_chamber = null
		return

	if(pressure <= 101.3)
		to_chat(user, "\The [src] hisses.")
		to_chat(user, "<span class='warning'>It sounds like the tank is empty.</span>")
		qdel(B)
		in_chamber = null
		return
//		var/n2_concentration = tank_gas.nitrogen/total_moles
//		var/co2_concentration = tank_gas.carbon_dioxide/total_moles
//		var/plasma_concentration = tank_gas.toxins/total_moles

//		var/unknown_concentration =  1 - (o2_concentration + n2_concentration + co2_concentration + plasma_concentration)
	B.gas_jet = tank_gas.remove_ratio(throw_percent/100)

	Fire(target,user)

/obj/item/weapon/gun/projectile/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	if(iswrench(W) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.loc = T
			weldtool = null
		if(igniter)
			igniter.loc = T
			igniter = null
		if(ptank)
			ptank.loc = T
			ptank = null
		getFromPool(/obj/item/stack/rods, T)
		qdel(src)
		return

	if(isscrewdriver(W) && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	if(isigniter(W))
		var/obj/item/device/assembly/igniter/I = W
		if(I.secured)	return
		if(igniter)		return
		if(user.drop_item(I, src))
			igniter = I
			update_icon()
			return

	if(istype(W,/obj/item/weapon/tank/plasma))
		if(ptank)
			to_chat(user, "<span class='notice'>There appears to already be a plasma tank loaded in [src]!</span>")
			return
		if(user.drop_item(W, src))
			ptank = W
			update_icon()
			return

	if(istype(W, /obj/item/device/analyzer) && ptank)
		var/obj/item/device/analyzer/analyzer = W
		user.visible_message("<span class='notice'>[user] has used the analyzer on \icon[icon]</span>")
		user.show_message(analyzer.output_gas_scan(ptank.air_contents, src, 0), 1)
		return
	..()
	return


/obj/item/weapon/gun/projectile/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_percent] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return


/obj/item/weapon/gun/projectile/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(ptank.air_contents.toxins < 1)	return
		if(!status)	return
		lit = !lit
		if(lit)
			processing_objects.Add(src)
	if(href_list["amount"])
		throw_percent = throw_percent + text2num(href_list["amount"])
		throw_percent = max(20, min(100, throw_percent))
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	if(istype(loc, /mob/living/carbon))
		var/mob/living/carbon/C = loc
		C.update_inv_r_hand()
		C.update_inv_l_hand()
	return


//Called from turf.dm turf/dblclick
/obj/item/weapon/gun/projectile/flamethrower/proc/flame_turf(turflist)
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
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/weapon/gun/projectile/flamethrower/proc/ignite_turf(turf/target)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(0.02*(throw_percent/100))
	//air_transfer.toxins = air_transfer.toxins * 5 // This is me not comprehending the air system. I realize this is retarded and I could probably make it work without fucking it up like this, but there you have it. -- TLE
	var/plasma_moles = air_transfer.toxins
	getFromPool(/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel, target, plasma_moles*10, get_dir(loc, target))
	air_transfer.toxins = 0
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	//target.hotspot_expose(part4.air_contents.temperature*2,300)
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500) // -- More of my "how do I shot fire?" dickery. -- TLE
	//location.hotspot_expose(1000,500,1)
	return

/obj/item/weapon/gun/projectile/flamethrower/full/New(var/loc)
	..()
	weldtool = new /obj/item/weapon/weldingtool(src)
	weldtool.status = 0
	igniter = new /obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()
	return


/obj/item/weapon/flamethrower
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/plasma/ptank = null

/obj/item/weapon/flamethrower/full
