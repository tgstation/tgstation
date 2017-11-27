/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	container_type = OPENCONTAINER_1
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite


/obj/structure/mopbucket/New()
	create_reagents(100)
	..()

/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop))
		if(reagents.total_volume < 1)
			to_chat(user, "[src] is out of water!</span>")
		else
			reagents.trans_to(I, 5)
			to_chat(user, "<span class='notice'>You wet [I] in [src].</span>")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
	else
		return ..()