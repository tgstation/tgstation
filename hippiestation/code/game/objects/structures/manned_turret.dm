/obj/machinery/manned_turret
	rate_of_fire = 1.5
	number_of_shots = 20

/obj/machinery/manned_turret/attackby(obj/item/W, mob/user, params)
    if(istype(W, /obj/item/wrench))
        default_unfasten_wrench(user, W, 20)
    else
        return ..()


/obj/machinery/manned_turret/unbuckle_mob(mob/living/buckled_mob,force = FALSE)
	playsound(src,'sound/mecha/mechmove01.ogg', 50, 1)
	for(var/obj/item/I in buckled_mob.held_items)
		if(istype(I, /obj/item/gun_control))
			qdel(I)
	if(istype(buckled_mob))
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
		if(buckled_mob.client)
			buckled_mob.client.change_view(world.view)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/obj/machinery/manned_turret/user_buckle_mob(mob/living/M, mob/living/carbon/user)
	if(user.incapacitated() || !istype(user))
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>The [src] needs to be safely secured before you can mount it!</span>")
		return
	M.forceMove(get_turf(src))
	. = ..()
	if(!.)
		return
	for(var/V in M.held_items)
		var/obj/item/I = V
		if(istype(I))
			if(M.dropItemToGround(I))
				var/obj/item/gun_control/TC = new(src)
				M.put_in_hands(TC)
		else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
			var/obj/item/gun_control/TC = new(src)
			M.put_in_hands(TC)
	M.pixel_y = 14
	layer = ABOVE_MOB_LAYER
	setDir(SOUTH)
	playsound(src,'sound/mecha/mechmove01.ogg', 50, 1)
	if(M.client)
		M.client.change_view(view_range)
	START_PROCESSING(SSfastprocess, src)