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
	else
		reagents.trans_to(mop, 5)	//
		user << "<span class='notice'>You wet [mop] in [src].</span>"
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

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
			wet_mop(m, user)
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
		if(do_after(user, 30, target = src))
			usr << "<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>"
			reagents.reaction(src.loc)
			src.reagents.clear_reagents()

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
	overlays.Cut()
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


//old style PIMP-CART
/obj/structure/stool/bed/chair/janicart
	name = "janicart"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = 0
	density = 1
	var/obj/item/weapon/storage/bag/trash/mybag = null
	var/callme = "pimpin' ride"	//how do people refer to it?
	var/move_delay = 0
	var/floorbuffer = 0
	var/keytype = /obj/item/key/janitor

/obj/structure/stool/bed/chair/janicart/New()
	handle_rotation()

/obj/structure/stool/bed/chair/janicart/Move(a, b, flag)
	..()
	if(floorbuffer)
		var/turf/tile = loc
		if(isturf(tile))
			tile.clean_blood()
			if (istype(tile, /turf/simulated/floor))
				var/turf/simulated/floor/F = tile
				F.dirt = 0
			for(var/A in tile)
				if(istype(A, /obj/effect))
					if(is_cleanable(A))
						qdel(A)

/obj/structure/stool/bed/chair/janicart/examine(mob/user)
	..()
	if(floorbuffer)
		user << "It has been upgraded with a floor buffer."


/obj/structure/stool/bed/chair/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, keytype))
		user << "Hold [I] in one of your hands while you drive this [callme]."
	else if(istype(I, /obj/item/weapon/storage/bag/trash))
		if(keytype == /obj/item/key/janitor)
			if(!user.drop_item())
				return
			user << "<span class='notice'>You hook the trashbag onto the [callme].</span>"
			I.loc = src
			mybag = I
	else if(istype(I, /obj/item/janiupgrade))
		if(keytype == /obj/item/key/janitor)
			floorbuffer = 1
			qdel(I)
			user << "<span class='notice'>You upgrade the [callme] with the floor buffer.</span>"
	update_icon()

/obj/structure/stool/bed/chair/janicart/update_icon()
	overlays.Cut()
	if(mybag)
		overlays += "cart_garbage"
	if(floorbuffer)
		overlays += "cart_buffer"

/obj/structure/stool/bed/chair/janicart/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
		update_icon()
	else
		..()


/obj/structure/stool/bed/chair/janicart/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()
	if(istype(user.l_hand, keytype) || istype(user.r_hand, keytype))
		if(!Process_Spacemove(direction) || !has_gravity(src.loc) || move_delay)
			return
		step(src, direction)
		update_mob()
		handle_rotation()
		if(istype(src.loc, /turf/simulated))
			var/turf/simulated/T = src.loc
			if(T.wet == 2)	//Lube! Fall off!
				playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
				buckled_mob.Stun(7)
				buckled_mob.Weaken(7)
				unbuckle_mob()
				step(src, dir)
		move_delay = 1
		spawn(2)
			move_delay = 0
	else
		user << "<span class='notice'>You'll need the keys in one of your hands to drive this [callme].</span>"

/obj/structure/stool/bed/chair/janicart/user_buckle_mob(mob/living/M, mob/user)
	if(user.incapacitated()) //user can't move the mob on the janicart's turf if incapacitated
		return
	for(var/atom/movable/A in get_turf(src)) //we check for obstacles on the turf.
		if(A.density)
			if(A != src && A != M)
				return
	M.loc = loc //we move the mob on the janicart's turf before checking if we can buckle.
	..()
	update_mob()

/obj/structure/stool/bed/chair/janicart/unbuckle_mob()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()

/obj/structure/stool/bed/chair/janicart/handle_rotation()
	if((dir == SOUTH) || (dir == WEST) || (dir == EAST))
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
				buckled_mob.pixel_x = 12
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -12
				buckled_mob.pixel_y = 7


/obj/structure/stool/bed/chair/janicart/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		buckled_mob.bullet_act(Proj)

/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = 1

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/item/janiupgrade
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"

/obj/structure/stool/bed/chair/janicart/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "secway"
	callme = "secway"
	keytype = /obj/item/key/security

/obj/structure/stool/bed/chair/janicart/secway/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.pixel_y = 4