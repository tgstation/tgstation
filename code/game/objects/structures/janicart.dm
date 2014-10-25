/obj/item/key/janicart
	name = "janicart key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "jani_keys"

/obj/item/mecha_parts/janicart_upgrade
	name = "Janicart Cleaner Upgrade"
	desc = "This device upgrades the janicart to automatically clean surfaces when driving."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	origin_tech = "engineering=2;materials=2"
	materials = list("metal"=20000)

/obj/structure/stool/bed/chair/vehicle/janicart
	name = "janicart"
	icon_state = "pussywagon"
	nick = "pimpin' ride"
	keytype = /obj/item/key/janicart
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null

	var/upgraded = 0

/obj/structure/stool/bed/chair/vehicle/janicart/New()
	. = ..()
	create_reagents(100)

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
	if(istype(W, /obj/item/mecha_parts/janicart_upgrade) && !upgraded && !destroyed)
		user.drop_item()
		del(W)
		user << "<span class='notice'>You upgrade the Pussy Wagon.</span>"
		upgraded = 1
		name = "upgraded janicart"
		icon_state = "pussywagon_upgraded"
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

/obj/structure/stool/bed/chair/vehicle/janicart/Move()
	..()
	if(upgraded)
		var/turf/tile = loc
		if(isturf(tile))
			tile.clean_blood()
			for(var/A in tile)
				if(istype(A, /obj/effect))
					if(istype(A, /obj/effect/rune) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay))
						qdel(A)
				else if(istype(A, /obj/item))
					var/obj/item/cleaned_item = A
					cleaned_item.clean_blood()
				else if(istype(A, /mob/living/carbon/human))
					var/mob/living/carbon/human/cleaned_human = A
					if(cleaned_human.lying)
						if(cleaned_human.head)
							cleaned_human.head.clean_blood()
							cleaned_human.update_inv_head(0)
						if(cleaned_human.wear_suit)
							cleaned_human.wear_suit.clean_blood()
							cleaned_human.update_inv_wear_suit(0)
						else if(cleaned_human.w_uniform)
							cleaned_human.w_uniform.clean_blood()
							cleaned_human.update_inv_w_uniform(0)
						if(cleaned_human.shoes)
							cleaned_human.shoes.clean_blood()
							cleaned_human.update_inv_shoes(0)
						cleaned_human.clean_blood()
						cleaned_human << "\red [src] cleans your face!"
	return