/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon
	name = "cannon"
	desc = "A makeshift cannon. This primitive weapon uses centuries-old technology."
	icon = 'icons/obj/gun.dmi'
	icon_state = "cannon"
	flags = FPRINT
	var/fuel_level = 0
	var/max_fuel = 10
	var/loaded_item = null
	var/damage_multiplier = 2
	var/list/prohibited_items = list( //Certain common items that, due to a combination of their throwforce and w_class, are too powerful to be allowed as ammunition.
		/obj/item/weapon/shard,
		/obj/item/weapon/batteringram,
		/obj/item/weapon/hatchet,
		/obj/item/weapon/storage/pneumatic,
		/obj/item/device/detective_scanner,
		)

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/Destroy()
	if(loaded_item)
		qdel(loaded_item)
		loaded_item = null
	..()

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/proc/update_verbs()
	if(loaded_item)
		verbs += /obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/unload_item
	else
		verbs -= /obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/unload_item

	if(fuel_level > 0)
		verbs += /obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/empty_fuel
	else
		verbs -= /obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/empty_fuel

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/unload_item() //Remove the loaded item.
	set name = "Unload cannon"
	set category = "Object"
	set src in oview(1)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!loaded_item)
		return
	else
		var/obj/item/loaded = loaded_item
		loaded.forceMove(usr.loc)
		loaded_item = null
		to_chat(usr, "You remove \the [loaded] from \the [src].")


/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/empty_fuel() //Empty the fuel.
	set name = "Empty fuel"
	set category = "Object"
	set src in oview(1)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!fuel_level)
		return

	if(loaded_item)
		to_chat(usr, "<span class = 'warning'>You can't empty the fuel when there's an item in the barrel.</span>")
	else
		fuel_level = 0
		to_chat(usr, "You clean the fuel out of \the [src].")
	update_verbs()

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, -90)
	return 1

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	src.dir = turn(src.dir, 90)
	return 1

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/attackby(obj/item/W as obj, mob/user as mob)
	var/item_prohibited = 0
	for(var/i=1, i<=prohibited_items.len, i++)
		if(istype(W,prohibited_items[i]))
			item_prohibited = 1
	if(!loaded_item && istype(W,/obj/item) && !W.is_open_container() && !item_prohibited)
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		loaded_item = W
		user.visible_message("[user] inserts \the [W] into the barrel of the [src].","You insert \the [W] into the barrel of \the [src].")
		update_verbs()
	else if(!loaded_item && item_prohibited)
		to_chat(user, "<span class='warning'>That won't fit into the barrel!</span>")
		return 1
	else if(loaded_item && W.is_open_container())
		to_chat(user, "<span class='warning'>The fuel needs to be put in before the ammunition!</span>")
		return 1
	else if(!loaded_item && W.is_open_container())
		transfer_fuel(W, user)
		return 1
	else if(loaded_item && istype(W,/obj/item))
		to_chat(user, "<span class='warning'>There's something in the barrel already!</span>")
		return 1
	else
		. = ..()

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/proc/transfer_fuel(obj/item/weapon/reagent_containers/S, mob/user as mob)
	if(!S.is_open_container())
		return
	if(!istype(S))
		return
	if(S.is_empty())
		to_chat(user, "<span class='warning'>\The [S] is empty.</span>")
		return
	if(fuel_level >= max_fuel)
		to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		return
	var/pure_fuel = 1
	for (var/datum/reagent/current_reagent in S.reagents.reagent_list)
		if (current_reagent.id != FUEL)
			pure_fuel = 0
	if(!pure_fuel)
		to_chat(user, "<span class='warning'>\The [src] won't fire if you fill it with anything but pure welding fuel!</span>")
		return
	var/transfer_amount = S.amount_per_transfer_from_this
	var/full = 0
	if((fuel_level + transfer_amount) >= max_fuel)
		transfer_amount = max_fuel-fuel_level
		full = 1
	S.reagents.remove_reagent(FUEL, transfer_amount)
	fuel_level += transfer_amount
	if(full)
		to_chat(user, "<span class='notice'>You fill \the [src] to the brim with fuel from \the [S].</span>")
	else
		to_chat(user, "<span class='notice'>You pour [transfer_amount] units of fuel into \the [src].</span>")
	update_verbs()

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/examine(mob/user)
	..()
	if(fuel_level)
		to_chat(user, "<span class='info'>It contains [fuel_level] units of fuel.</span>")
	if(loaded_item)
		to_chat(user, "<span class='info'>There is \a [loaded_item] in the barrel.</span>")

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/attack_hand()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	if(fuel_level)
		if(!loaded_item)
			var/N = rand(1,3)
			switch(N)
				if(1)
					playsound(usr, 'sound/effects/Explosion_Small1.ogg', 100, 1)
				if(2)
					playsound(usr, 'sound/effects/Explosion_Small2.ogg', 100, 1)
				if(3)
					playsound(usr, 'sound/effects/Explosion_Small3.ogg', 100, 1)
			fuel_level = 0
			usr.visible_message("<span class='danger'>[usr] fires \the [src]!</span>","<span class='danger'>You fire \the [src]!</span>")
			return 0
		else
			Fire(usr)

/obj/structure/bed/chair/vehicle/wheelchair/wheelchair_assembly/cannon/proc/Fire(mob/living/user as mob|obj)
	add_fingerprint(user)
	var/target = null
	switch(dir)
		if(1)
			target = locate(x, y+40, z)
		if(2)
			target = locate(x, y-40, z)
		if(4)
			target = locate(x+40, y, z)
		if(8)
			target = locate(x-40, y, z)

	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	var/fire_force = fuel_level*2

	var/obj/item/object = loaded_item
	var/speed
	if(object.w_class > W_CLASS_TINY)
		speed = (((fire_force*(4/object.w_class))/5)*2) //projectile speed.
	else
		speed = (((fire_force*2)/5)*2)

	speed = speed * damage_multiplier

	var/distance = round(((20/object.w_class)*(fuel_level/10))*1.5)

	user.visible_message("<span class='danger'>[user] fires \the [object] from \the [src]!</span>","<span class='danger'>You fire \the [object] from \the [src]!</span>")
	log_attack("[user.name] ([user.ckey]) fired \the [src] (proj:[object.name]) at coordinates ([x],[y],[z])" )

	object.forceMove(src.loc)
	object.throw_at(target,distance,speed)
	var/N = rand(1,3)
	switch(N)
		if(1)
			playsound(user, 'sound/effects/Explosion_Small1.ogg', 50, 1)
		if(2)
			playsound(user, 'sound/effects/Explosion_Small2.ogg', 50, 1)
		if(3)
			playsound(user, 'sound/effects/Explosion_Small3.ogg', 50, 1)
	loaded_item = null
	fuel_level = 0
