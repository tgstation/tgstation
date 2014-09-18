/obj/structure/displaycase_frame
	name = "display case frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state="box_glass"
	var/obj/item/weapon/circuitboard/airlock/circuit=null
	var/state=0

/obj/structure/displaycase_frame/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/pstate=state
	var/turf/T=get_turf(src)
	switch(state)
		if(0)
			if(istype(W, /obj/item/weapon/circuitboard/airlock) && W:icon_state != "door_electronics_smoked")
				user.drop_item()
				circuit=W
				circuit.loc=src
				state++
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			if(istype(W, /obj/item/weapon/crowbar))
				new /obj/machinery/constructable_frame/machine_frame(T)
				new /obj/item/stack/sheet/glass(T)
				del(src)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				return

		if(1)
			if(isscrewdriver(W))
				var/obj/structure/displaycase/C=new(T)
				if(circuit.one_access)
					C.req_access = null
					C.req_one_access = circuit.conf_access
				else
					C.req_access = circuit.conf_access
					C.req_one_access = null
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				del(src)
				return
			if(istype(W, /obj/item/weapon/crowbar))
				circuit.loc=T
				circuit=null
				state--
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
	if(pstate!=state)
		pstate=state
		update_icon()

/obj/structure/displaycase_frame/update_icon()
	switch(state)
		if(1)
			icon_state="box_glass_circuit"
		else
			icon_state="box_glass"


/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox20"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/obj/item/occupant = null
	var/destroyed = 0
	var/locked = 0
	var/ue=null
	var/image/occupant_overlay=null

	var/obj/item/weapon/circuitboard/airlock/circuit

/obj/structure/displaycase/captains_laser/New()
	occupant=new /obj/item/weapon/gun/energy/laser/captain(src)
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/gooncode/New()
	occupant=new /obj/item/toy/gooncode(src)
	locked=1
	req_access=list(access_captain)
	update_icon()

/obj/structure/displaycase/lamarr/New()
	occupant=new /obj/item/clothing/mask/facehugger/lamarr(src)
	locked=1
	req_access=list(access_rd)
	update_icon()

/obj/structure/displaycase/examine()
	..()
	usr << "\blue Peering through the glass, you see that it contains:"
	if(occupant)
		usr << "\icon[occupant] \blue \A [occupant]"
	else:
		usr << "Nothing."

/obj/structure/displaycase/proc/dump()
	if(occupant)
		occupant.loc=get_turf(src)
		occupant=null
	occupant_overlay=null

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			getFromPool(/obj/item/weapon/shard, loc)
			if (occupant)
				dump()
			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/displaycase/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/displaycase/blob_act()
	if (prob(75))
		getFromPool(/obj/item/weapon/shard, loc)
		if(occupant) dump()
		del(src)


/obj/structure/displaycase/meteorhit(obj/O as obj)
		getFromPool(/obj/item/weapon/shard, loc)
		if(occupant) dump()
		del(src)


/obj/structure/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			getFromPool(/obj/item/weapon/shard, loc)
			playsound(get_turf(src), "shatter", 70, 1)
			update_icon()
	else
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassbox2b"
	else
		src.icon_state = "glassbox2[locked]"
	overlays = 0
	if(occupant)
		var/icon/occupant_icon=getFlatIcon(occupant)
		occupant_icon.Scale(16,16)
		occupant_overlay = image(occupant_icon)
		occupant_overlay.pixel_x=8
		occupant_overlay.pixel_y=8
		if(locked)
			occupant_overlay.alpha=128//ChangeOpacity(0.5)
		//underlays += occupant_overlay
		overlays += occupant_overlay
	return


/obj/structure/displaycase/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card))
		var/obj/item/weapon/card/id/I=W
		if(!check_access(I))
			user << "\red Access denied."
			return
		locked = !locked
		if(!locked)
			user << "\icon[src] \blue \The [src] clicks as locks release, and it slowly opens for you."
		else
			user << "\icon[src] \blue You close \the [src] and swipe your card, locking it."
		update_icon()
		return
	if(istype(W,/obj/item/weapon/crowbar) && (!locked || destroyed))
		user.visible_message("[user.name] pries \the [src] apart.", \
			"You pry \the [src] apart.", \
			"You hear something pop.")
		var/turf/T=get_turf(src)
		playsound(T, 'sound/items/Crowbar.ogg', 50, 1)
		dump()
		var/obj/item/weapon/circuitboard/airlock/C=circuit
		if(!C)
			C=new (src)
		C.one_access=!(req_access && req_access.len>0)
		if(!C.one_access)
			C.conf_access=req_access
		else
			C.conf_access=req_one_access
		if(!destroyed)
			var/obj/structure/displaycase_frame/F=new(T)
			F.state=1
			F.circuit=C
			F.circuit.loc=F
			F.update_icon()
		else
			C.loc=T
			circuit=null
			new /obj/machinery/constructable_frame/machine_frame(T)
		del(src)
	if(user.a_intent == "hurt")
		user.changeNext_move(10)
		src.health -= W.force
		src.healthcheck()
		..()
	else
		if(locked)
			user << "\red It's locked, you can't put anything into it."
			return
		if(!occupant)
			user << "\blue You insert \the [W] into \the [src], and it floats as the hoverfield activates."
			user.drop_item()
			W.loc=src
			occupant=W
			update_icon()

/obj/structure/displaycase/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/displaycase/proc/getPrint(mob/user as mob)
	return md5(user:dna:uni_identity)

/obj/structure/displaycase/attack_hand(mob/user as mob)
	if (destroyed)
		if(occupant)
			dump()
			user << "\red You smash your fist into the delicate electronics at the bottom of the case, and deactivate the hover field permanently."
			src.add_fingerprint(user)
			update_icon()
	else
		if(user.a_intent == "hurt")
			user.changeNext_move(10)
			user.visible_message("\red [user.name] kicks \the [src]!", \
				"\red You kick \the [src]!", \
				"You hear glass crack.")
			src.health -= 2
			healthcheck()
		else if(!locked)
			if(ishuman(user))
				if(!ue)
					user << "\blue Your press your thumb against the fingerprint scanner, registering your identity with the case."
					ue = getPrint(user)
					return
				if(ue!=getPrint(user))
					user << "\red Access denied."
					return

				user << "\blue Your press your thumb against the fingerprint scanner, and deactivate the hover field built into the case."
				if(occupant)
					dump()
					update_icon()
				else
					src << "\icon[src] \red \The [src] is empty!"
		else
			user.visible_message("[user.name] gently runs his hands over \the [src] in appreciation of its contents.", \
				"You gently run your hands over \the [src] in appreciation of its contents.", \
				"You hear someone streaking glass with their greasy hands.")

