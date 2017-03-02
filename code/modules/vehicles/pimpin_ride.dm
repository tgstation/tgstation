//PIMP-CART
/obj/vehicle/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"

	var/obj/item/weapon/storage/bag/trash/mybag = null
	var/floorbuffer = 0

/obj/vehicle/janicart/Destroy()
	if(mybag)
		qdel(mybag)
		mybag = null
	return ..()

/obj/vehicle/janicart/buckle_mob(mob/living/buckled_mob, force = 0, check_loc = 0)
	. = ..()
	riding_datum = new/datum/riding/janicart



/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"


/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"
	origin_tech = "materials=3;engineering=4"


/obj/vehicle/janicart/Moved(atom/OldLoc, Dir)
	if(floorbuffer)
		var/turf/tile = loc
		if(isturf(tile))
			tile.clean_blood()
			for(var/A in tile)
				if(is_cleanable(A))
					qdel(A)
	. = ..()


/obj/vehicle/janicart/examine(mob/user)
	..()
	if(floorbuffer)
		user << "It has been upgraded with a floor buffer."


/obj/vehicle/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/storage/bag/trash))
		if(mybag)
			user << "<span class='warning'>[src] already has a trashbag hooked!</span>"
			return
		if(!user.drop_item())
			return
		user << "<span class='notice'>You hook the trashbag onto \the [name].</span>"
		I.loc = src
		mybag = I
		update_icon()
	else if(istype(I, /obj/item/janiupgrade))
		floorbuffer = 1
		qdel(I)
		user << "<span class='notice'>You upgrade \the [name] with the floor buffer.</span>"
		update_icon()
	else
		return ..()


/obj/vehicle/janicart/update_icon()
	cut_overlays()
	if(mybag)
		add_overlay("cart_garbage")
	if(floorbuffer)
		add_overlay("cart_buffer")


/obj/vehicle/janicart/attack_hand(mob/user)
	if(..())
		return 1
	else if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
		update_icon()