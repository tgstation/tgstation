/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	anchored = 0
	var/lockedby = ""
	pressure_resistance = 5
	flags = FPRINT  | OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/New()
	..()
	create_reagents(100)

/obj/structure/mopbucket/attack_hand(mob/user as mob)
	..()
	if(!anchored)
		anchored = 1
		user.visible_message("<span class='notice'>[user] locks [src]'s wheels!</span>")
		lockedby += "\[[time_stamp()]\] [usr] ([usr.ckey]) - locked [src]"
	else
		anchored = 0
		user.visible_message("<span class='notice'>[user] unlocks [src]'s wheels!</span>")
		lockedby += "\[[time_stamp()]\] [usr] ([usr.ckey]) - unlocked [src]"

/obj/structure/mopbucket/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/mop))
		return 0
	return ..()
/obj/structure/mopbucket/mop_act(obj/item/weapon/mop/M, mob/user as mob)
	if (istype(M))
		if (src.reagents.total_volume >= 1)
			if(M.reagents.total_volume >= 25)
				return 1
			else
				src.reagents.trans_to(M, 3)
				to_chat(user, "<span class='notice'>You wet [M]</span>")
				playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
		else
			to_chat(user, "<span class='notice'>Nothing left to wet [M] with!</span>")
	return 1

/obj/structure/mopbucket/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
