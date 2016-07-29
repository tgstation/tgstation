<<<<<<< HEAD
/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/obj/item/weapon/mop/mymop = null
	var/obj/item/weapon/reagent_containers/spray/cleaner/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/signs = 0
	var/const/max_signs = 4


/obj/structure/janitorialcart/New()
	create_reagents(100)


/obj/structure/janitorialcart/proc/wet_mop(obj/item/weapon/mop, mob/user)
	if(reagents.total_volume < 1)
		user << "<span class='warning'>[src] is out of water!</span>"
		return 0
	else
		reagents.trans_to(mop, 5)
		user << "<span class='notice'>You wet [mop] in [src].</span>"
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return 1

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	if(!user.drop_item())
		return
	I.loc = src
	updateUsrDialog()
	user << "<span class='notice'>You put [I] into [src].</span>"
	return


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='warning'>There is already one of those in [src]!</span>"

	if(istype(I, /obj/item/weapon/mop))
		var/obj/item/weapon/mop/m=I
		if(m.reagents.total_volume < m.reagents.maximum_volume)
			if (wet_mop(m, user))
				return
		if(!mymop)
			m.janicart_insert(user, src)
		else
			user << fail_msg

	else if(istype(I, /obj/item/weapon/storage/bag/trash))
		if(!mybag)
			var/obj/item/weapon/storage/bag/trash/t=I
			t.janicart_insert(user, src)
		else
			user <<  fail_msg
	else if(istype(I, /obj/item/weapon/reagent_containers/spray/cleaner))
		if(!myspray)
			put_in_cart(I, user)
			myspray=I
			update_icon()
		else
			user << fail_msg
	else if(istype(I, /obj/item/device/lightreplacer))
		if(!myreplacer)
			var/obj/item/device/lightreplacer/l=I
			l.janicart_insert(user,src)
		else
			user << fail_msg
	else if(istype(I, /obj/item/weapon/caution))
		if(signs < max_signs)
			put_in_cart(I, user)
			signs++
			update_icon()
		else
			user << "<span class='warning'>[src] can't hold any more signs!</span>"
	else if(mybag)
		mybag.attackby(I, user)
	else if(istype(I, /obj/item/weapon/crowbar))
		user.visible_message("[user] begins to empty the contents of [src].", "<span class='notice'>You begin to empty the contents of [src]...</span>")
		if(do_after(user, 30/I.toolspeed, target = src))
			usr << "<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>"
			reagents.reaction(src.loc)
			src.reagents.clear_reagents()
	else
		return ..()

/obj/structure/janitorialcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(mybag)
		dat += "<a href='?src=\ref[src];garbage=1'>[mybag.name]</a><br>"
	if(mymop)
		dat += "<a href='?src=\ref[src];mop=1'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='?src=\ref[src];spray=1'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='?src=\ref[src];replacer=1'>[myreplacer.name]</a><br>"
	if(signs)
		dat += "<a href='?src=\ref[src];sign=1'>[signs] sign\s</a><br>"
	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()


/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["garbage"])
		if(mybag)
			user.put_in_hands(mybag)
			user << "<span class='notice'>You take [mybag] from [src].</span>"
			mybag = null
	if(href_list["mop"])
		if(mymop)
			user.put_in_hands(mymop)
			user << "<span class='notice'>You take [mymop] from [src].</span>"
			mymop = null
	if(href_list["spray"])
		if(myspray)
			user.put_in_hands(myspray)
			user << "<span class='notice'>You take [myspray] from [src].</span>"
			myspray = null
	if(href_list["replacer"])
		if(myreplacer)
			user.put_in_hands(myreplacer)
			user << "<span class='notice'>You take [myreplacer] from [src].</span>"
			myreplacer = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/weapon/caution/Sign = locate() in src
			if(Sign)
				user.put_in_hands(Sign)
				user << "<span class='notice'>You take \a [Sign] from [src].</span>"
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/update_icon()
	cut_overlays()
	if(mybag)
		add_overlay("cart_garbage")
	if(mymop)
		add_overlay("cart_mop")
	if(myspray)
		add_overlay("cart_spray")
	if(myreplacer)
		add_overlay("cart_replacer")
	if(signs)
		add_overlay("cart_sign[signs]")

=======
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
	overrideghostspin = 0
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null

	var/upgraded = 0

/obj/structure/bed/chair/vehicle/janicart/New()
	. = ..()
	create_reagents(100)

/obj/structure/bed/chair/vehicle/janicart/examine(mob/user)
	..()
	if(in_range(src, user) && reagents.has_reagent(LUBE))
		to_chat(user, "<span class='warning'> Something is very off about this water.</span>")
	switch(health)
		if(75 to 99)
			to_chat(user, "<span class='info'>It appears slightly dented.</span>")
		if(40 to 74)
			to_chat(user, "<span class='warning'>It appears heavily dented.</span>")
		if(1 to 39)
			to_chat(user, "<span class='warning'>It appears severely dented.</span>")
		if((INFINITY * -1) to 0)
			to_chat(user, "<span class='danger'>It appears completely unsalvageable.</span>")
	if(mybag)
		to_chat(user, "\A [mybag] is hanging on \the [nick].")

/obj/structure/bed/chair/vehicle/janicart/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/mecha_parts/janicart_upgrade) && !upgraded && !destroyed)
		if(user.drop_item(W))
			qdel(W)
			to_chat(user, "<span class='notice'>You upgrade \the [nick].</span>")
			upgraded = 1
			name = "upgraded [name]"
			icon_state = "pussywagon_upgraded"
	else if(istype(W, /obj/item/weapon/storage/bag/trash))
		if(mybag)
			to_chat(user, "<span class='warning'>There's already a [W.name] on \the [nick]!</span>")
			return
		if(user.drop_item(W, src))
			to_chat(user, "<span class='notice'>You hook \the [W] onto \the [nick].</span>")
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

/obj/structure/bed/chair/vehicle/janicart/verb/remove_trashbag()
	set name = "Remove Trash Bag"
	set category = "Object"
	set src in oview(1)

	if(mybag && !usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
		mybag.forceMove(get_turf(usr))
		usr.put_in_hands(mybag)
		mybag = null

/obj/structure/bed/chair/vehicle/janicart/attack_hand(mob/user)
	if(occupant && occupant == user)
		return ..()
	if(mybag)
		remove_trashbag()
	else
		..()

/obj/structure/bed/chair/vehicle/janicart/AltClick()
	if(mybag)
		remove_trashbag()
		return
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
