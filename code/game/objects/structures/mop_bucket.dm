/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	anchored = 0
	var/lockedby = ""
	pressure_resistance = 5
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/New()
	create_reagents(100)

/obj/structure/mopbucket/examine()
	..()
	usr << "<span class='notice'>[src] contains [reagents.total_volume] units of reagents!"
	usr << "<span class='notice'>[src]'s wheels are [anchored? "locked" : "unlocked"]!"

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

/obj/structure/mopbucket/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/mop))
		if (src.reagents.total_volume >= 1)
			if(W.reagents.total_volume >= 5)
				return
			else
				src.reagents.trans_to(W, 1)
				user << "<span class='notice'>You wet [W]</span>"
				playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
		else
			user << "<span class='notice'>Nothing left to wet [W] with!</span>"
	return

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
