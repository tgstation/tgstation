/*
CONTAINS:
TOILET

/obj/item/weapon/storage/toilet
	name = "toilet"
	w_class = 4.0
	anchored = 1.0
	density = 0.0
	var/status = 0.0
	var/clogged = 0.0
	anchored = 1.0
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "toilet"
	item_state = "syringe_kit"

/obj/item/weapon/storage/toilet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (src.contents.len >= 7)
		user << "The toilet is clogged!"
		return
	if (istype(W, /obj/item/weapon/disk/nuclear))
		user << "This is far too important to flush!"
		return
	if (istype(W, /obj/item/weapon/storage/))
		return
	if (istype(W, /obj/item/weapon/grab))
		playsound(src.loc, 'slosh.ogg', 50, 1)
		for(var/mob/O in viewers(user, null))
			O << text("\blue [] gives [] a swirlie!", user, W)
		return
	var/t
	for(var/obj/item/weapon/O in src)
		t += O.w_class
	t += W.w_class
	if (t > 30)
		user << "You cannot fit the item inside."
		return
	user.u_equip(W)
	W.loc = src
	if ((user.client && user.s_active != src))
		user.client.screen -= W
	src.orient2hud(user)
	W.dropped(user)
	add_fingerprint(user)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\blue [] has put [] in []!", user, W, src), 1)
	return

/obj/item/weapon/storage/toilet/MouseDrop_T(mob/M as mob, mob/user as mob)
	if (!ticker)
		user << "You can't help relieve anyone before the game starts."
		return
	if ((!( istype(M, /mob) ) || get_dist(src, user) > 1 || M.loc != src.loc || user.restrained() || usr.stat))
		return
	if (M == usr)
		for(var/mob/O in viewers(user, null))
			if ((O.client && !( O.blinded )))
				O << text("\blue [] sits on the toilet.", user)
	else
		for(var/mob/O in viewers(user, null))
			if ((O.client && !( O.blinded )))
				O << text("\blue [] is seated on the toilet by []!", M, user)
	M.anchored = 1
	M.buckled = src
	M.loc = src.loc
	src.add_fingerprint(user)
	return

/obj/item/weapon/storage/toilet/attack_hand(mob/user as mob)
	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				for(var/mob/O in viewers(user, null))
					if ((O.client && !( O.blinded )))
						O << text("\blue [] is zipped up by [].", M, user)
			else
				for(var/mob/O in viewers(user, null))
					if ((O.client && !( O.blinded )))
						O << text("\blue [] zips up.", M)
//			world << "[M] is no longer buckled to [src]"
			M.anchored = 0
			M.buckled = null
			src.add_fingerprint(user)
	if((src.clogged < 1) || (src.contents.len < 7) || (user.loc != src.loc))
		for(var/mob/O in viewers(user, null))
			O << text("\blue [] flushes the toilet.", user)
			src.clogged = 0
			src.contents.len = 0
	else if((src.clogged >= 1) || (src.contents.len >= 7) || (user.buckled != src.loc))
		for(var/mob/O in viewers(user, null))
			O << text("\blue The toilet is clogged!")
	return


*/