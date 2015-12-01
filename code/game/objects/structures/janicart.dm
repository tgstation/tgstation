/obj/item/key/janicart
	name = "janicart key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "jani_keys"

/obj/item/mecha_parts/janicart_upgrade
	name = "Janicart Cleaner Upgrade"
	desc = "This device upgrades the janicart to automatically clean surfaces when driving."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"

/obj/structure/bed/chair/vehicle/janicart
	name = "janicart"
	icon_state = "pussywagon"
	nick = "pimpin' ride"
	keytype = /obj/item/key/janicart
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null

	var/upgraded = 0

/obj/structure/bed/chair/vehicle/janicart/New()
	. = ..()
	create_reagents(100)

/obj/structure/bed/chair/vehicle/janicart/examine(mob/user)
	..()
	if(in_range(src, user) && reagents.has_reagent("lube"))
		to_chat(user, "<span class='warning'> Something is very off about this water.</span>")
	switch(health)
		if(75 to 99)
			to_chat(user, "<span class='info'>It appears slightly dented.</span>")
		if(40 to 74)
			to_chat(user, "<span class='warning'>It appears heavily dented.</span>")
		if(1 to 39)
			to_chat(user, "<span class='warning'>It appears severely dented.</span>")
		if((INFINITY * -1) to 0)
			to_chat(user, "<span class='danger'>It appears completely unsalvageable</span>")
	if(mybag)
		to_chat(user, "\A [mybag] is hanging on \the [nick].")

/obj/structure/bed/chair/vehicle/janicart/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/mecha_parts/janicart_upgrade) && !upgraded && !destroyed)
		user.drop_item(W)
		qdel(W)
		to_chat(user, "<span class='notice'>You upgrade \the [nick].</span>")
		upgraded = 1
		name = "upgraded [name]"
		icon_state = "pussywagon_upgraded"
	else if(istype(W, /obj/item/weapon/storage/bag/trash))
		if(mybag)
			to_chat(user, "<span class='warning'>There's already a [W.name] on \the [nick]!</span>")
			return
		to_chat(user, "<span class='notice'>You hook \the [W] onto \the [nick].</span>")
		user.drop_item(W, src)
		mybag = W

/obj/structure/bed/chair/vehicle/janicart/mop_act(obj/item/weapon/mop/M, mob/user)
	if(istype(M))
		if(reagents.total_volume >= 2)
			reagents.trans_to(M, 3)
			to_chat(user, "<span class='notice'>You wet the mop in \the [nick].</span>")
			playsound(get_turf(src), 'sound/effects/slosh.ogg', 25, 1)
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>\The [nick] is out of water!</span>")
	return 1

/obj/structure/bed/chair/vehicle/janicart/attack_hand(mob/user)
	if(mybag)
		if(occupant && occupant == user)
			switch(alert("Choose an action.","Janicart","Get off the ride","Remove the bag","Cancel"))
				if("Get off the ride")
					return ..()

				if("Cancel")
					return

		mybag.forceMove(get_turf(user))
		user.put_in_hands(mybag)
		mybag = null
	else
		..()

/obj/structure/bed/chair/vehicle/janicart/Move()
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
						to_chat(cleaned_human, "<span class='warning'>[src] cleans your face!</span>")
	return