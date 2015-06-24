//MINING CHARGE: Slap it in rocks to cause a controlled explosion. Can be emagged to slap on other things.
/obj/item/device/mining_charge
	name = "standard mining charge"
	desc = "A pyrotechnical device used to cause controlled explosions for digging tunnels without manual labor. It can only be attached to rocks and mineral deposits."
	w_class = 2
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_charge"
	item_state = "electronic"
	var/active_state = "mining_charge_active"
	throw_speed = 3
	throw_range = 5
	slot_flags = SLOT_BELT
	var/detonating = 0 //If the charge is currently primed
	var/safety = 1 //If the charge can be put on things other than rocks
	var/explosionPower = 2 //The power of the explosion; larger powers = bigger boom
	var/atom/movable/putOn = null //The atom the charge is on
	var/primedOverlay = null

/obj/item/device/mining_charge/emag_act(mob/user)
	if(!safety)
		return
	user << "<span class='warning'>You press the cryptographic sequencer onto [src], disabling its safeties.</span>"
	safety = 0

/obj/item/device/mining_charge/New()
	..()
	primedOverlay = image('icons/obj/mining.dmi', "mining_charge_active")

/obj/item/device/mining_charge/examine(mob/user)
	..()
	user << "A small LED is blinking [safety ? "green" : "red"]."
	if(detonating)
		user << "It appears to be primed."

/obj/item/device/mining_charge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver) && !safety)
		user << "<span class='notice'>You restore the safeties on [src].</span>"
		safety = 1
		return
	..()

/obj/item/device/mining_charge/attack_hand(mob/user)
	if(detonating)
		return
	..()

/obj/item/device/mining_charge/afterattack(atom/movable/target, mob/user, flag)
	if(!istype(target, /turf/simulated/mineral) && safety)
		return
	if(!in_range(user, target))
		return
	user.visible_message("<span class='notice'>[user] starts placing [src] onto [target].</span>", \
						 "<span class='notice'>You start placing the charge.</span>")
	if(do_after(user, 30, target = src) && in_range(user, target))
		user.visible_message("<span class='notice'>[user] places [src] onto [target].</span>", \
							 "<span class='warning'>You slap [src] onto [target]!</span>")
		user.drop_item()
		if(ismob(target))
			var/mob/living/M = target
			M << "<span class='boldannounce'>[src]'s clamps dig into you!</span>" //Fluff
		loc = target
		putOn = target
		anchored = 1
		icon_state = active_state
		target.overlays += primedOverlay
		Detonate()

/obj/item/device/mining_charge/proc/Detonate(var/timer = 5)
	icon_state = active_state
	update_icon()
	detonating = 1
	light_range = 2
	for(var/i = 0, i < timer, i++)
		sleep(10)
		playsound(get_turf(src), 'sound/machines/defib_saftyOff.ogg', 50, 1)
	sleep(10)
	playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 100, 1)
	sleep(20)
	if(putOn)
		loc = get_turf(putOn)
	src.visible_message("<span class='boldannounce'>[src] explodes!</span>")
	switch(explosionPower)
		if(-INFINITY to 0)
			explosion(src.loc,-1,0,3)
		if(1)
			explosion(src.loc,-1,1,3)
		if(2)
			explosion(src.loc,-1,2,6)
		if(3 to INFINITY)
			explosion(src.loc,-1,4,12)
	if(putOn)
		putOn.overlays -= primedOverlay
		putOn = null
	if(src) //In case it survived
		qdel(src)

/obj/item/device/mining_charge/small
	name = "compact mining charge"
	desc = "A smaller mining charge that weighs less at the cost of a less powerful explosion."
	icon_state = "mining_charges"
	active_state = "mining_charges_active"
	w_class = 1
	explosionPower = 1

/obj/item/weapon/storage/box/mining_charges
	name = "box of mining charges"
	desc = "A box shaped to hold mining charges."
	can_hold = list(/obj/item/device/mining_charge/)

/obj/item/weapon/storage/box/mining_charges/New()
	..()
	contents = list()
	new /obj/item/device/mining_charge(src)
	new /obj/item/device/mining_charge(src)
	new /obj/item/device/mining_charge/small(src)
	new /obj/item/device/mining_charge/small(src)
	new /obj/item/device/mining_charge/small(src)
	new /obj/item/device/mining_charge/small(src)
	new /obj/item/device/mining_charge/small(src)
	return
