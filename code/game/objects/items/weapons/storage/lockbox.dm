//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"
	var/tracked_access = "It doesn't look like it's ever been used."
	health = 50



/obj/item/weapon/storage/lockbox/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = W
		if(src.broken)
			to_chat(user, "<span class='rose'>It appears to be broken.</span>")
			return
		if(src.allowed(user))
			src.locked = !( src.locked )
			if(src.locked)
				src.icon_state = src.icon_locked
				to_chat(user, "<span class='rose'>You lock the [src.name]!</span>")
				tracked_access = "The tracker reads: 'Last locked by [ID.registered_name].'"
				return
			else
				src.icon_state = src.icon_closed
				to_chat(user, "<span class='rose'>You unlock the [src.name]!</span>")
				tracked_access = "The tracker reads: 'Last unlocked by [ID.registered_name].'"
				return
		else
			to_chat(user, "<span class='warning'>Access Denied</span>")
	else if(istype(W, /obj/item/weapon/card/emag) && !src.broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = src.icon_broken
		for(var/mob/O in viewers(user, 3))
			O.show_message(text("<span class='notice'>The locker has been broken by [] with an electromagnetic card!</span>", user), 1, text("You hear a faint electrical spark."), 2)

	if(!locked)
		..()
	else
		to_chat(user, "<span class='warning'>Its locked!</span>")
	return


/obj/item/weapon/storage/lockbox/show_to(mob/user as mob)
	if(locked)
		to_chat(user, "<span class='warning'>Its locked!</span>")
	else
		..()
	return

/obj/item/weapon/storage/lockbox/bullet_act(var/obj/item/projectile/Proj)
	// WHY MUST WE DO THIS
	// WHY
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) && !Proj.nodamage)
			health -= Proj.damage
	..()
	if(health <= 0)
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)
	return

/obj/item/weapon/storage/lockbox/ex_act(severity)
	var/newsev = max(3,severity+1)
	for(var/atom/movable/A as mob|obj in src)//pulls everything out of the locker and hits it with an explosion
		A.loc = src.loc
		A.ex_act(newsev)
	newsev=4-severity
	if(prob(newsev*25)+25) // 1=100, 2=75, 3=50
		qdel(src)

/obj/item/weapon/storage/lockbox/emp_act(severity)
	..()
	if(!broken)
		switch(severity)
			if(1)
				if(prob(80))
					locked = !locked
					src.update_icon()
			if(2)
				if(prob(50))
					locked = !locked
					src.update_icon()
			if(3)
				if(prob(25))
					locked = !locked
					src.update_icon()

/obj/item/weapon/storage/lockbox/update_icon()
	..()
	if (broken)
		icon_state = src.icon_broken
	else if(locked)
		icon_state = src.icon_locked
	else
		icon_state = src.icon_closed
	return

/obj/item/weapon/storage/lockbox/loyalty
	name = "Lockbox (Loyalty Implants)"
	req_access = list(access_security)

/obj/item/weapon/storage/lockbox/loyalty/New()
	..()
	new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implanter/loyalty(src)

/obj/item/weapon/storage/lockbox/tracking
	name = "Lockbox (Tracking Implants)"
	req_access = list(access_security)

/obj/item/weapon/storage/lockbox/tracking/New()
	..()
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/lockbox/chem
	name = "Lockbox (Chemical Implants)"
	req_access = list(access_security)

/obj/item/weapon/storage/lockbox/chem/New()
	..()
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

/obj/item/weapon/storage/lockbox/clusterbang/New()
	..()
	new /obj/item/weapon/grenade/flashbang/clusterbang(src)

/obj/item/weapon/storage/lockbox/unlockable
	name = "semi-secure lockbox"
	desc = "A securable locked box. Can't lock anything, but can track whoever used it."
	req_access = list()

/obj/item/weapon/storage/lockbox/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[tracked_access]</span>")

/obj/item/weapon/storage/lockbox/unlockable/attackby(obj/O as obj, mob/user as mob)
	if (istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = O
		if(src.broken)
			to_chat(user, "<span class='rose'>It appears to be broken.</span>")
			return
		else
			src.locked = !( src.locked )
			if(src.locked)
				src.icon_state = src.icon_locked
				to_chat(user, "<span class='rose'>You lock the [src.name]!</span>")
				tracked_access = "The tracker reads: 'Last locked by [ID.registered_name]'."
				return
			else
				src.icon_state = src.icon_closed
				to_chat(user, "<span class='rose'>You unlock the [src.name]!</span>")
				tracked_access = "The tracker reads: 'Last unlocked by [ID.registered_name].'"
				return
	else
		..()

/obj/item/weapon/storage/lockbox/coinbox
	name = "coinbox"
	desc = "A secure container for the profits of a vending machine."
	icon_state = "coinbox+l"
	w_class = 2
	max_w_class = 1
	can_hold = list("/obj/item/voucher","/obj/item/weapon/coin")
	max_combined_w_class = 30
	force = 8
	throwforce = 10
	storage_slots = 20
	req_access = list(access_qm)
	locked = 1
	broken = 0
	icon_locked = "coinbox+l"
	icon_closed = "coinbox"
	icon_broken = "coinbox+b"
