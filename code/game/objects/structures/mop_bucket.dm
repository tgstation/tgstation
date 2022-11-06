/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mopbucket/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, span_warning("[src] is out of water!"))
		else
			reagents.trans_to(weapon, 5, transfered_by = user)
			to_chat(user, span_notice("You wet [weapon] in [src]."))
			playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)

	update_appearance()
	if(weapon.is_drainable() || istype(weapon, /obj/item/mop))
		return // skip attack animations

	return ..()


/obj/structure/mopbucket/update_overlays()
	. = ..()
	if(reagents.total_volume > 0)
		. += "mopbucket_water"
