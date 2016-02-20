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
	recoil = 0
	var/status = 0
	var/throw_percent = 20
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/plasma/ptank = null
	var/window_open = 0


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

	if(!lit)
		return
	if(lit && !ptank)
		to_chat(user, "<span class='warning'>There's no tank attached.</span>")
		return

	if(!can_Fire(user, 1))
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

	if(pressure <= ONE_ATMOSPHERE)
		to_chat(user, "\The [src] hisses.")
		to_chat(user, "<span class='warning'>It sounds like the tank is empty.</span>")
		qdel(B)
		in_chamber = null
		return

	B.jet_pressure = pressure * (throw_percent/100)
	B.gas_jet = tank_gas.remove_ratio(throw_percent/100)

	if(Fire(target,user))
		user.visible_message("<span class='danger'>[user] shoots a jet of gas from \his [src.name]!</span>","<span class='danger'>You shoot a jet of gas from your [src.name]!</span>")
		playsound(user, 'sound/weapons/flamethrower.ogg', 50, 1)
		src.updateUsrDialog()
		flamethrower_window(user)

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
			src.updateUsrDialog()
			flamethrower_window(user)
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
	window_open = 1
	flamethrower_window(user)
	return

/obj/item/weapon/gun/projectile/flamethrower/proc/flamethrower_window(mob/user)
	if(window_open)
		user.set_machine(src)
		var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank ? "[ptank.air_contents.return_pressure()]" : "No tank loaded."]<BR>\nPercentage to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_percent] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
		user << browse(dat, "window=flamethrower;size=600x300")
		onclose(user, "flamethrower", src)

/obj/item/weapon/gun/projectile/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr << browse(null, "window=flamethrower")
		usr.unset_machine()
		window_open = 0
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!status)	return
		lit = !lit
		if(lit)
			processing_objects.Add(src)
	if(href_list["amount"])
		throw_percent = throw_percent + text2num(href_list["amount"])
		throw_percent = max(20, min(100, throw_percent))
	if(href_list["remove"])
		if(!ptank)
			to_chat(usr, "<span class='notice'>There's no tank loaded!</span>")
			return
		usr.put_in_hands(ptank)
		ptank = null
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	if(istype(loc, /mob/living/carbon))
		var/mob/living/carbon/C = loc
		C.update_inv_r_hand()
		C.update_inv_l_hand()
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

/obj/item/weapon/gun/projectile/flamethrower/full/tank/New(var/loc)
	..()
	ptank = new /obj/item/weapon/tank/plasma(src)
	var/datum/gas_mixture/gas_tank = ptank.air_contents
	gas_tank.toxins = 29.1
	gas_tank.update_values()
	update_icon()
	return