/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with brawndo, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite


/obj/structure/mopbucket/New()
	create_reagents(100)

/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/mop))
		if(reagents.total_volume < 1)
			user << "[src] is out of brawndo!</span>"
		else
			reagents.trans_to(I, 5)
			user << "<span class='notice'>You wet [I] in [src].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)