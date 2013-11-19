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
	var/obj/item/weapon/reagent_containers/spray/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/signs = 0	//maximum capacity hardcoded below


/obj/structure/janitorialcart/New()
	create_reagents(100)


/obj/structure/janitorialcart/examine()
	set src in usr
	..()
	usr << "It contains [reagents.total_volume] unit\s of liquid!"
	//everything else is visible, so doesn't need to be mentioned


/obj/structure/janitorialcart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/storage/bag/trash) && !mybag)
		user.drop_item()
		mybag = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		user << "<span class='notice'>You put [I] into [src].</span>"

	else if(istype(I, /obj/item/weapon/mop))
		if(I.reagents.total_volume < I.reagents.maximum_volume)	//if it's not completely soaked we assume they want to wet it, otherwise store it
			if(reagents.total_volume < 1)
				user << "[src] is out of water!</span>"
			else
				reagents.trans_to(I, 5)	//
				user << "<span class='notice'>You wet [I] in [src].</span>"
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
				return
		if(!mymop)
			user.drop_item()
			mymop = I
			I.loc = src
			update_icon()
			updateUsrDialog()
			user << "<span class='notice'>You put [I] into [src].</span>"

	else if(istype(I, /obj/item/weapon/reagent_containers/spray) && !myspray)
		user.drop_item()
		myspray = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		user << "<span class='notice'>You put [I] into [src].</span>"

	else if(istype(I, /obj/item/device/lightreplacer) && !myreplacer)
		user.drop_item()
		myreplacer = I
		I.loc = src
		update_icon()
		updateUsrDialog()
		user << "<span class='notice'>You put [I] into [src].</span>"

	else if(istype(I, /obj/item/weapon/caution))
		if(signs < 4)
			user.drop_item()
			I.loc = src
			signs++
			update_icon()
			updateUsrDialog()
			user << "<span class='notice'>You put [I] into [src].</span>"
		else
			user << "<span class='notice'>[src] can't hold any more signs.</span>"

	else if(mybag)
		mybag.attackby(I, user)


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
				warning("[src] signs ([signs]) didn't match contents")
				signs = 0

	update_icon()
	updateUsrDialog()


/obj/structure/janitorialcart/update_icon()
	overlays = null
	if(mybag)
		overlays += "cart_garbage"
	if(mymop)
		overlays += "cart_mop"
	if(myspray)
		overlays += "cart_spray"
	if(myreplacer)
		overlays += "cart_replacer"
	if(signs)
		overlays += "cart_sign[signs]"


//old style retardo-cart
/obj/structure/stool/bed/chair/janicart
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = 1
	density = 1
	flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/callme = "pimpin' ride"	//how do people refer to it?


/obj/structure/stool/bed/chair/janicart/New()
	handle_rotation()
	create_reagents(100)


/obj/structure/stool/bed/chair/janicart/examine()
	set src in usr
	..()
	usr << "It contains [reagents.total_volume] unit\s of water!"
	if(mybag)
		usr << "\A [mybag] is hanging on the [callme]."


/obj/structure/stool/bed/chair/janicart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop))
		if(reagents.total_volume > 1)
			reagents.trans_to(I, 2)
			user << "<span class='notice'>You wet [I] in the [callme].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		else
			user << "<span class='notice'>This [callme] is out of water!</span>"
	else if(istype(I, /obj/item/key))
		user << "Hold [I] in one of your hands while you drive this [callme]."
	else if(istype(I, /obj/item/weapon/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the [callme].</span>"
		user.drop_item()
		I.loc = src
		mybag = I


/obj/structure/stool/bed/chair/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()


/obj/structure/stool/bed/chair/janicart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle()
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
		update_mob()
		handle_rotation()
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive this [callme].</span>"


/obj/structure/stool/bed/chair/janicart/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc


/obj/structure/stool/bed/chair/janicart/buckle_mob(mob/M, mob/user)
	if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon))
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs onto the [callme]!</span>",\
		"<span class='notice'>You climb onto the [callme]!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)


/obj/structure/stool/bed/chair/janicart/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()


/obj/structure/stool/bed/chair/janicart/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()


/obj/structure/stool/bed/chair/janicart/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7


/obj/structure/stool/bed/chair/janicart/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message("<span class='warning'>[Proj] ricochets off the [callme]!</span>")


/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1