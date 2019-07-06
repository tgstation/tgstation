/obj/item/sleepsack
	name = "sleep sack"
	desc = "A Pink Sleep Sack"
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybagpink_open"
	var/opened = TRUE
	var/victim = null
	var/sound = 'sound/items/zip.ogg'
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.

	//w_class = WEIGHT_CLASS_SMALL
	custom_price = 500
obj/item/sleepsack/AltClick(mob/living/user)
	if(opened) close()
	else if (user.loc != src)
		open()
	else
		to_chat(user, "<span class='notice'>You can't open it from inside...</span>")

obj/item/sleepsack/proc/open()
	icon_state = "bodybagpink_open"
	playsound(loc, sound, 15, 1, -3)
	opened = TRUE
	dump_contents()


obj/item/sleepsack/proc/close()
	icon_state = "bodybagpink"
	playsound(loc, sound, 15, 1, -3)
	opened = FALSE
	take_contents()

/obj/item/sleepsack/proc/dump_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/item/sleepsack/proc/take_contents()
	var/atom/L = drop_location()
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/item/sleepsack/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(AM))
		AM.forceMove(src)
		return TRUE
	else
		return FALSE

/obj/item/sleepsack/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on [src]!</span>")
			return
		var/t = stripped_input(user, "What would you like the label to be?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "sleep sack - [t]"
		else
			name = "sleep sack"

/obj/item/sleepsack/proc/insertion_allowed(atom/movable/AM)
	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
		L.stop_pulling()

	else if(istype(AM, /obj/item/sleepsack))
		return FALSE
	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects && !istype(AM, /obj/effect/dummy/chameleon))
			return FALSE
	else
		return FALSE

	return TRUE

/obj/item/sleepsack/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return 0
	return 1

/obj/item/sleepsack/relaymove(mob/user)
	return

/obj/item/sleepsack/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /obj/screen))
		return
	if(!istype(user) || user.incapacitated() || !(user.mobility_flags & MOBILITY_STAND))
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return
	add_fingerprint(user)
	return 1

/*
	if(victim && user.is_holding_item_of_type(/obj/item/card/girls))
		release()
	else if(!victim)
		user.dropItemToGround(src)
		capture(user)

/obj/item/sleepsack/proc/capture(mob/living/carbon/human/H)
	if(!victim)
		victim = H
		H.forceMove(src)
		add_fingerprint(H)
		icon_state = "bodybagpink"

/obj/item/sleepsack/proc/release()
	if(!victim)
		return
	var/atom/movable/mob_container
	mob_container = victim
	mob_container.forceMove(get_turf(src))
*/