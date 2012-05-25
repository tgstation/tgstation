#define REGULATE_RATE 5

/obj/item/weapon/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	var/state = null
	var/det_time = 20.0
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | USEDELAY
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/bad_smoke_spread/smoke

/obj/item/weapon/mustardbomb
	desc = "It is set to detonate in 4 seconds."
	name = "mustard gas bomb"
	icon = 'grenade.dmi'
	icon_state = "flashbang"
	var/state = null
	var/det_time = 40.0
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/mustard_gas_spread/mustard_gas

/obj/item/weapon/smokebomb/New()
	..()
	src.smoke = new /datum/effect/effect/system/bad_smoke_spread/
	src.smoke.attach(src)
	src.smoke.set_up(10, 0, usr.loc)

/obj/item/weapon/mustardbomb/New()
	..()
	src.mustard_gas = new /datum/effect/effect/system/mustard_gas_spread/
	src.mustard_gas.attach(src)
	src.mustard_gas.set_up(5, 0, usr.loc)

/obj/item/weapon/smokebomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.det_time == 60)
			src.det_time = 20
			user.show_message("\blue You set the smoke bomb for a 2 second detonation time.")
			src.desc = "It is set to detonate in 2 seconds."
		else
			src.det_time = 60
			user.show_message("\blue You set the smoke bomb for a 6 second detonation time.")
			src.desc = "It is set to detonate in 6 seconds."
		src.add_fingerprint(user)
	return

/obj/item/weapon/smokebomb/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if (!( src.state ))
			user << "\red You prime the smoke bomb! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/smokebomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/smokebomb/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/smokebomb/proc/prime()
	playsound(src.loc, 'smoke.ogg', 50, 1, -3)
	spawn(0)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
		sleep(10)
		src.smoke.start()

	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update()
	sleep(80)
	del(src)
	return

/obj/item/weapon/smokebomb/attack_self(mob/user as mob)
	if (!src.state)
		user << "\red You prime the smoke bomb! [det_time/10] seconds!"
		src.state = 1
		src.icon_state = "flashbang1"
		add_fingerprint(user)
		spawn( src.det_time )
			prime()
			return
	return

/obj/item/weapon/mustardbomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.det_time == 80)
			src.det_time = 40
			user.show_message("\blue You set the mustard gas bomb for a 4 second detonation time.")
			src.desc = "It is set to detonate in 4 seconds."
		else
			src.det_time = 80
			user.show_message("\blue You set the mustard gas bomb for a 8 second detonation time.")
			src.desc = "It is set to detonate in 8 seconds."
		src.add_fingerprint(user)
	return

/obj/item/weapon/mustardbomb/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if (!( src.state ))
			user << "\red You prime the mustard gas bomb! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/mustardbomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/mustardbomb/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/mustardbomb/proc/prime()
	playsound(src.loc, 'smoke.ogg', 50, 1, -3)
	spawn(0)
		src.mustard_gas.start()
		sleep(10)
		src.mustard_gas.start()
		sleep(10)
		src.mustard_gas.start()
		sleep(10)
		src.mustard_gas.start()

	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update()
	sleep(100)
	del(src)
	return

/obj/item/weapon/mustardbomb/attack_self(mob/user as mob)
	if (!src.state)
		user << "\red You prime the mustard gas bomb! [det_time/10] seconds!"
		src.state = 1
		src.icon_state = "flashbang1"
		add_fingerprint(user)
		spawn( src.det_time )
			prime()
			return
	return

/obj/item/weapon/storage/beakerbox
	name = "Beaker Box"
	icon_state = "beaker"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/beakerbox/New()
	..()
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )
	new /obj/item/weapon/reagent_containers/glass/beaker( src )

/obj/item/weapon/paper/alchemy/
	name = "paper- 'Chemistry Information'"

/obj/item/weapon/storage/trashcan
	name = "disposal unit"
	w_class = 4.0
	anchored = 1.0
	density = 1.0
	var/processing = null
	var/locked = 1
	req_access = list(access_janitor)
	desc = "A compact incineration device, used to dispose of garbage."
	icon = 'stationobjs.dmi'
	icon_state = "trashcan"
	item_state = "syringe_kit"

/obj/item/weapon/storage/trashcan/attackby(obj/item/weapon/W as obj, mob/user as mob)
	//..()

	if (src.contents.len >= 7)
		user << "The trashcan is full!"
		return
	if (istype(W, /obj/item/weapon/disk/nuclear)||istype(W, /obj/item/weapon/melee/energy/blade))
		user << "This is far too important to throw away!"
		return
	if (istype(W, /obj/item/weapon/storage/))
		return
	if (istype(W, /obj/item/weapon/grab))
		user << "You cannot fit the person inside."
		return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O.w_class
		//Foreach goto(46)
	t += W.w_class
	if (t > 30)
		user << "You cannot fit the item inside. (Remove larger classed items)"
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	user.visible_message("\blue [user] has put [W] in [src]!")

	if (src.contents.len >= 7)
		src.locked = 1
		src.icon_state = "trashcan1"
	spawn (200)
		if (src.contents.len < 7)
			src.locked = 0
			src.icon_state = "trashcan"
	return

/obj/item/weapon/storage/trashcan/attack_hand(mob/user as mob)
	if(src.allowed(usr))
		locked = !locked
	else
		user << "\red Access denied."
		return
	if (src.processing)
		return
	if (src.contents.len >= 7)
		user << "\blue You begin the emptying procedure."
		var/area/A = src.loc.loc		// make sure it's in an area
		if(!A || !isarea(A))
			return
//		var/turf/T = src.loc
		A.use_power(250, EQUIP)
		src.processing = 1
		src.contents.len = 0
		src.icon_state = "trashmelt"
		if (istype(loc, /turf))
			loc:hotspot_expose(1000,10)
		sleep (60)
		src.icon_state = "trashcan"
		src.processing = 0
		return
	else
		src.icon_state = "trashcan"
		user << "\blue Due to conservation measures, the unit is unable to start until it is completely filled."
		return


