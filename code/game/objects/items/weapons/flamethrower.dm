/obj/item/weapon/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	flags = CONDUCT
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=500)
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	resistance_flags = FIRE_PROOF
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/internals/plasma/ptank = null
	var/warned_admins = 0 //for the message_admins() when lit


/obj/item/weapon/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
	if(igniter)
		qdel(igniter)
	if(ptank)
		qdel(ptank)
	return ..()


/obj/item/weapon/flamethrower/process()
	if(!lit)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.is_holding(src))
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	return


/obj/item/weapon/flamethrower/update_icon()
	cut_overlays()
	if(igniter)
		add_overlay("+igniter[status]")
	if(ptank)
		add_overlay("+ptank")
	if(lit)
		add_overlay("+lit")
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/weapon/flamethrower/afterattack(atom/target, mob/user, flag)
	if(flag)
		return // too close
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
			return
		if(NOGUNS in H.dna.species.species_traits)
			to_chat(user, "<span class='warning'>Your fingers don't fit in the trigger guard!</span>")
			return
	if(user && user.get_active_held_item() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			add_logs(user, target, "flamethrowered", src)
			flame_turf(turflist)

/obj/item/weapon/flamethrower/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !status)//Taking this apart
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
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	else if(istype(W, /obj/item/weapon/screwdriver) && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	else if(isigniter(W))
		var/obj/item/device/assembly/igniter/I = W
		if(I.secured)
			return
		if(igniter)
			return
		if(!user.transferItemToLoc(W, src))
			return
		igniter = I
		update_icon()
		return

	else if(istype(W,/obj/item/weapon/tank/internals/plasma))
		if(ptank)
			to_chat(user, "<span class='notice'>There is already a plasma tank loaded in [src]!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		ptank = W
		update_icon()
		return

	else if(istype(W, /obj/item/device/analyzer) && ptank)
		atmosanalyzer_scan(ptank.air_contents, user)
	else
		return ..()


/obj/item/weapon/flamethrower/attack_self(mob/user)
	if(user.stat || user.restrained() || user.lying)
		return
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
	if(usr.stat || usr.restrained() || usr.lying)
		return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)
			return
		if(!status)
			return
		lit = !lit
		if(lit)
			START_PROCESSING(SSobj, src)
			if(!warned_admins)
				message_admins("[key_name_admin(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) has lit a flamethrower.")
				warned_admins = 1
	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = max(50, min(5000, throw_amount))
	if(href_list["remove"])
		if(!ptank)
			return
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

/obj/item/weapon/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weapon/weldingtool) in contents
	igniter = locate(/obj/item/device/assembly/igniter) in contents
	weldtool.status = 0
	igniter.secured = 0
	status = 1
	update_icon()

//Called from turf.dm turf/dblclick
/obj/item/weapon/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return
	operating = 1
	var/turf/previousturf = get_turf(src)
	for(var/turf/T in turflist)
		if(T == previousturf)
			continue	//so we don't burn the tile we be standin on
		if(!T.atmos_adjacent_turfs || !T.atmos_adjacent_turfs[previousturf])
			break
		ignite_turf(T)
		sleep(1)
		previousturf = T
	operating = 0
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return


/obj/item/weapon/flamethrower/proc/ignite_turf(turf/target, release_amount = 0.05)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(release_amount)
	if(air_transfer.gases["plasma"])
		air_transfer.gases["plasma"][MOLES] *= 5
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380,500)
	//location.hotspot_expose(1000,500,1)
	SSair.add_to_active(target, 0)
	return


/obj/item/weapon/flamethrower/full/New(var/loc)
	..()
	if(!weldtool)
		weldtool = new /obj/item/weapon/weldingtool(src)
	weldtool.status = 0
	if(!igniter)
		igniter = new /obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()

/obj/item/weapon/flamethrower/full/tank/New(var/loc)
	..()
	ptank = new /obj/item/weapon/tank/internals/plasma/full(src)
	update_icon()


/obj/item/weapon/flamethrower/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, damage, attack_type)
	if(ptank && damage && attack_type == PROJECTILE_ATTACK && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
		var/target_turf = get_turf(owner)
		ignite_turf(target_turf, 100)
		qdel(ptank)
		return 1 //It hit the flamethrower, not them
