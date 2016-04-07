/obj/item/weapon/blunderbuss
	name = "blunderbuss"
	desc = "A muzzle-loaded firearm powered by welding fuel. It might not be a good idea to use more than 10u of fuel in one shot."
	icon = 'icons/obj/gun.dmi'
	icon_state = "blunderbuss"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	item_state = null
	w_class = 4.0
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	origin_tech = "materials=1;engineering=1;combat=1"
	attack_verb = list("strikes", "hits", "bashes")
	mech_flags = MECH_SCAN_ILLEGAL
	var/damage_multiplier = 2	//To allow easy modifications to the damage this weapon deals. At a value of 1, a metal rod fired with 10u of fuel deals 16 damage.
	var/fuel_level = 0
	var/max_fuel = 30
	var/obj/item/loaded_item = null
	var/list/prohibited_items = list( //Certain common items that, due to a combination of their throwforce and w_class, are too powerful to be allowed as ammunition.
		/obj/item/weapon/shard,
		/obj/item/weapon/batteringram,
		/obj/item/weapon/hatchet,
		/obj/item/weapon/harpoon,
		/obj/item/weapon/gun,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/storage/pneumatic,
		/obj/item/device/detective_scanner,
		)
	var/flawless = 0
	var/dont_shoot = 0 //I couldn't get attack() to play nice with afterattack() for some reason, so I'm jury-rigging the melee stuff.

/obj/item/weapon/blunderbuss/Destroy()
	if(loaded_item)
		qdel(loaded_item)
		loaded_item = null
	..()

/obj/item/weapon/blunderbuss/proc/update_verbs()
	if(loaded_item)
		verbs += /obj/item/weapon/blunderbuss/verb/unload_item
	else
		verbs -= /obj/item/weapon/blunderbuss/verb/unload_item

	if(fuel_level > 0)
		verbs += /obj/item/weapon/blunderbuss/verb/empty_fuel
	else
		verbs -= /obj/item/weapon/blunderbuss/verb/empty_fuel

/obj/item/weapon/blunderbuss/pickup(mob/user as mob)
	..()
	update_verbs()

/obj/item/weapon/blunderbuss/dropped(mob/user as mob)
	..()
	update_verbs()

/obj/item/weapon/blunderbuss/verb/unload_item() //Remove the loaded item.
	set name = "Unload blunderbuss"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!loaded_item)
		return
	else
		loaded_item.forceMove(usr.loc)
		usr.put_in_hands(loaded_item)
		loaded_item = null
		to_chat(usr, "You remove \the [loaded_item] from \the [src].")
	update_verbs()

/obj/item/weapon/blunderbuss/verb/empty_fuel() //Empty the fuel reservoir.
	set name = "Empty blunderbuss fuel"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!fuel_level)
		return

	if(loaded_item)
		to_chat(usr, "<span class = 'warning'>You can't empty the fuel when there's an item in the muzzle.</span>")
	else
		fuel_level = 0
		to_chat(usr, "You pour the fuel out of \the [src].")
	update_verbs()

/obj/item/weapon/blunderbuss/attackby(obj/item/W as obj, mob/user as mob)
	var/item_prohibited = 0
	for(var/i=1, i<=prohibited_items.len, i++)
		if(istype(W,prohibited_items[i]))
			item_prohibited = 1
	if(!loaded_item && istype(W,/obj/item) && !istype(W,/obj/item/weapon/reagent_containers) && !item_prohibited)
		if(istype(W, /obj/item/stack))
			var/obj/item/stack/S = W
			S.use(1)
			var/Y = new W.type(src)
			loaded_item = Y
		else
			if(!user.drop_item(W, src))
				to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
				return 1
			loaded_item = W
		user.visible_message("[user] jams \the [W] into the muzzle of the [src].","You jam \the [W] into the muzzle of \the [src].")
		update_verbs()
	else if(!loaded_item && item_prohibited)
		to_chat(user, "<span class='warning'>That won't fit into the muzzle!</span>")
		return 1
	else if(loaded_item && istype(W,/obj/item/weapon/reagent_containers))
		to_chat(user, "<span class='warning'>You can't reach the fuel chamber when there's something stuck in the barrel!</span>")
		return 1
	else if(!loaded_item && istype(W,/obj/item/weapon/reagent_containers))
		transfer_fuel(W, user)
		return 1
	else if(loaded_item && istype(W,/obj/item))
		to_chat(user, "<span class='warning'>There's something in the barrel already!</span>")
		return 1
	else
		. = ..()

/obj/item/weapon/blunderbuss/proc/transfer_fuel(obj/item/weapon/reagent_containers/S, mob/user as mob)
	if(!S.is_open_container())
		return
	if(S.is_empty())
		to_chat(user, "<span class='warning'>\The [S] is empty.</span>")
		return
	if(fuel_level >= max_fuel)
		to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		return
	var/pure_fuel = 1
	for (var/datum/reagent/current_reagent in S.reagents.reagent_list)
		if (current_reagent.id != "fuel")
			pure_fuel = 0
	if(!pure_fuel)
		to_chat(user, "<span class='warning'>\The [src] won't fire if you fill it with anything but pure welding fuel!</span>")
		return
	var/transfer_amount = S.amount_per_transfer_from_this
	var/full = 0
	if((fuel_level + transfer_amount) >= max_fuel)
		transfer_amount = max_fuel-fuel_level
		full = 1
	S.reagents.remove_reagent("fuel", transfer_amount)
	fuel_level += transfer_amount
	if(full)
		to_chat(user, "<span class='notice'>You fill \the [src] to the brim with fuel from \the [S].</span>")
	else
		to_chat(user, "<span class='notice'>You pour [transfer_amount] units of fuel into \the [src].</span>")
	update_verbs()

/obj/item/weapon/blunderbuss/examine(mob/user)
	..()
	if(fuel_level)
		to_chat(user, "<span class='info'>It contains [fuel_level] units of fuel.</span>")
	if(loaded_item)
		to_chat(user, "<span class='info'>There [loaded_item.gender == PLURAL ? "are \a [loaded_item]s" : "is \a [loaded_item]"] jammed into the barrel.</span>")

/obj/item/weapon/blunderbuss/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (target.loc == user.loc)
		return

	else if (target.loc == user)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(dont_shoot)
		dont_shoot = 0
		return

	if(!fuel_level)
		user.visible_message("*click click*", "<span class='danger'>*click*</span>")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return 0
	else if(fuel_level && !loaded_item)
		playsound(user, 'sound/weapons/shotgun.ogg', 50, 1)
		fuel_level = 0
		user.visible_message("<span class='danger'>[user] fires \the [src]!</span>","<span class='danger'>You fire \the [src]!</span>")
		return 0
	else
		Fire(target,user,params)

/obj/item/weapon/blunderbuss/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	dont_shoot = 1
	if (loaded_item)
		if(user.a_intent == I_HURT)
			user.visible_message("<span class='danger'>[user] fires \the [src] point blank at [M]!</span>")
			Fire(M,user)
			return
		else
			return ..()
	else
		return ..()

/obj/item/weapon/blunderbuss/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if (!loaded_item)
		to_chat(user, "There's nothing in \the [src] to fire!")
		return 0

	if(!flawless)
		if(fuel_level > 10 && fuel_level <= 20)
			var/chance20 = rand(1,100)
			if(chance20 <= ((fuel_level - 10) * 3))		//with between 11 and 20 units of fuel inclusive, the gun has between a 3% and 30% chance to explode, scaling with fuel amount
				explode(user)
				return
		else if(fuel_level > 20 && fuel_level <= 30)
			var/chance30 = rand(1,100)
			if(chance30 <= (((fuel_level - 20) * 2) + 30))	//with between 21 and 30 units of fuel inclusive, the gun has between a 32% and 50% chance to explode, scaling with fuel amount
				explode(user)
				return

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/fire_force = fuel_level + (fuel_level * (1/(fuel_level/10)))

	var/speed
	if(loaded_item.w_class > 1)
		speed = ((fire_force*(4/loaded_item.w_class))/5) //projectile speed.
	else
		speed = ((fire_force*2)/5)

	speed = speed * damage_multiplier
	if(speed>80) speed = 80 //damage cap.

	var/distance = round((20/loaded_item.w_class)*(fuel_level/10))

	user.visible_message("<span class='danger'>[user] fires \the [src] and launches \the [loaded_item] at [target]!</span>","<span class='danger'>You fire \the [src] and launch \the [loaded_item] at [target]!</span>")
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[loaded_item.name]) at [target] [ismob(target) ? "([target:ckey])" : ""] ([target.x],[target.y],[target.z])" )

	loaded_item.forceMove(user.loc)
	loaded_item.throw_at(target,distance,speed)
	playsound(user, 'sound/weapons/shotgun.ogg', 50, 1)
	loaded_item = null
	fuel_level = 0

/obj/item/weapon/blunderbuss/proc/explode(mob/user)
	to_chat(user, "<span class='danger'>\The [src]'s firing mechanism fails!</span>")
	loaded_item.forceMove(user.loc)
	loaded_item = null
	explosion(user, -1, 0, 2)
	qdel(src)
	return

/obj/item/weapon/blunderbuss/flawless
	name = "flawless blunderbuss"
	desc = "A muzzle-loaded firearm powered by welding fuel. This one is of exceptionally high quality, and will never fail."

/obj/item/weapon/blunderbuss/flawless/New()
	..()
	flawless = 1
