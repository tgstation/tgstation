/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c357
	caliber = CALIBER_357
	max_ammo = 7

///Here, we have to maintain the list size, to emulate a cylinder with several chambers, empty or otherwise.
/obj/item/ammo_box/magazine/internal/cylinder/remove_from_stored_ammo(atom/movable/gone)
	for(var/index in 1 to length(stored_ammo))
		var/obj/item/ammo_casing/bullet = stored_ammo[index]
		if(gone == bullet)
			stored_ammo[index] = null
			update_appearance()
			return

/obj/item/ammo_box/magazine/internal/cylinder/get_round()
	rotate()
	var/casing = stored_ammo[1]
	if (ispath(casing))
		casing = new casing(src)
		stored_ammo[1] = casing
	return casing

/obj/item/ammo_box/magazine/internal/cylinder/get_and_shuffle_round()
	return get_round()

/obj/item/ammo_box/magazine/internal/cylinder/proc/rotate()
	var/b = stored_ammo[1]
	stored_ammo.Cut(1,2)
	stored_ammo.Insert(0, b)

/obj/item/ammo_box/magazine/internal/cylinder/proc/spin()
	for(var/i in 1 to rand(0, max_ammo*2))
		rotate()

/obj/item/ammo_box/magazine/internal/cylinder/ammo_list()
	var/list/no_nulls_ammo = ..()
	list_clear_nulls(no_nulls_ammo)
	return no_nulls_ammo

/obj/item/ammo_box/magazine/internal/cylinder/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	if(!R || !(caliber ? (caliber == R.caliber) : (ammo_type == R.type)))
		return FALSE

	for(var/i in 1 to stored_ammo.len)
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(bullet && (!istype(bullet) || bullet.loaded_projectile))
			continue
		// empty or spent
		stored_ammo[i] = R
		R.forceMove(src)

		if(bullet)
			bullet.forceMove(drop_location())
		return TRUE
	return FALSE

/obj/item/ammo_box/magazine/internal/cylinder/top_off(load_type, starting=FALSE)
	if(starting) // nulls don't exist when we're starting off
		return ..()

	if(!load_type)
		load_type = ammo_type

	for(var/i in 1 to max_ammo)
		if(!give_round(new load_type(src)))
			break
	update_appearance()
