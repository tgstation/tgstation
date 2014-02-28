/obj/item/key/janicart
	name = "janicart key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "jani_keys"

/obj/structure/stool/bed/chair/vehicle/janicart
	name = "janicart"
	icon_state = "pussywagon"
	nick = "pimpin' ride"
	keytype = /obj/item/key/janicart
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null

/obj/structure/stool/bed/chair/vehicle/janicart/New()
	..()

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

/obj/structure/stool/bed/chair/vehicle/janicart/examine()
	set src in usr
	usr << "\icon[src] This pimpin' ride contains [reagents.total_volume] unit\s of water!"
	if(in_range(src, usr) && reagents.has_reagent("lube"))
		usr << "<span class='warning'> Something is very off about this water.</span>"
	switch(health)
		if(75 to 99)
			usr << "\blue It appears slightly dented."
		if(40 to 74)
			usr << "\red It appears heavily dented."
		if(1 to 39)
			usr << "\red It appears severely dented."
		if((INFINITY * -1) to 0)
			usr << "It appears completely unsalvageable"
	if(mybag)
		usr << "\A [mybag] is hanging on the pimpin' ride."

/obj/structure/stool/bed/chair/vehicle/janicart/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/mop))
		if(reagents.total_volume >= 2)
			reagents.trans_to(W, 2)
			user << "<span class='notice'>You wet the mop in the pimpin' ride.</span>"
			playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
		if(reagents.total_volume < 1)
			user << "<span class='notice'>This pimpin' ride is out of water!</span>"
	else if(istype(W, /obj/item/weapon/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the pimpin' ride.</span>"
		user.drop_item()
		W.loc = src
		mybag = W


/obj/structure/stool/bed/chair/vehicle/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()