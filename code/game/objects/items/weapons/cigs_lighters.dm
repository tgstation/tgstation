/*
CONTAINS:
MATCHES
MATCHBOXES
CIGARETTES
CIG PACKET
ZIPPO
*/

///////////
//MATCHES//
///////////

/obj/item/weapon/match/process()
	while(src.lit == 1)
		src.smoketime--
		sleep(10)
		if(src.smoketime < 1)
			src.icon_state = "match_burnt"
			src.lit = -1
			return

/obj/item/weapon/match/dropped(mob/user as mob)
	if(src.lit == 1)
		src.lit = -1
		src.damtype = "brute"
		src.icon_state = "match_burnt"
		src.item_state = "cigoff"
		src.name = "Burnt match"
		src.desc = "A match that has been burnt"
		return ..()

//////////////
//MATCHBOXES//
//////////////
/obj/item/weapon/matchbox/attack_hand(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(src.matchcount <= 0)
			user << "\red You're out of matches. Shouldn't have wasted so many..."
			return
		else
			src.matchcount--
			var/obj/item/weapon/match/W = new /obj/item/weapon/match(user)
			if(user.hand)
				user.l_hand = W
			else
				user.r_hand = W
			W.layer = 20
	else
		return ..()
	if(src.matchcount <= 0)
		src.icon_state = "matchbox_empty"
	else if(src.matchcount <= 3)
		src.icon_state = "matchbox_almostempty"
	else if(src.matchcount <= 6)
		src.icon_state = "matchbox_almostfull"
	else
		src.icon_state = "matchbox"
	src.update_icon()
	return

obj/item/weapon/matchbox.attackby(obj/item/weapon/match/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match) && W.lit == 0)
		W.lit = 1
		W.icon_state = "match_lit"
		W.process()
	W.update_icon()
	return


///////////////////////
//CIGARETTES + CIGARS//
///////////////////////
/obj/item/clothing/mask/cigarette/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/weldingtool)  && W:welding)
		if(src.lit == 0)
			src.lit = 1
			src.damtype = "fire"
			src.icon_state = icon_on
			src.item_state = icon_on
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] casually lights the [] with [], what a badass.", user, src.name, W), 1)
			spawn() //start fires while it's lit
				src.process()
	else if(istype(W, /obj/item/weapon/zippo) && W:lit)
		if(src.lit == 0)
			src.lit = 1
			src.icon_state = icon_on
			src.item_state = icon_on
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red With a single flick of their wrist, [] smoothly lights their [] with their []. Damn they're cool.", user, src.name, W), 1)
			spawn() //start fires while it's lit
				src.process()
	else if(istype(W, /obj/item/weapon/match) && W:lit)
		if(src.lit == 0)
			src.lit = 1
			src.icon_state = icon_on
			src.item_state = icon_on
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] lights their [] with their []. How poor can you get?", user, src.name, W), 1)
			spawn() //start fires while it's lit
				src.process()



/obj/item/clothing/mask/cigarette/process()

	var/atom/lastHolder = null

	while(src.lit == 1)
		var/turf/location = src.loc
		var/atom/holder = loc
		var/isHeld = 0
		var/mob/M = null
		src.smoketime--

		if(istype(location, /mob/))
			M = location
			if(M.l_hand == src || M.r_hand == src || M.wear_mask == src)
				location = M.loc
		if(src.smoketime < 1)
			if (istype(src,/obj/item/clothing/mask/cigarette/cigar))
				var/obj/item/weapon/cigbutt/C = new /obj/item/weapon/cigarbutt
				C.loc = location
			else
				var/obj/item/weapon/cigbutt/C = new /obj/item/weapon/cigbutt
				C.loc = location
			if(M != null)
				M << "\red Your [src.name] goes out."
			del(src)
			return
		if (istype(location, /turf)) //start a fire if possible
			location.hotspot_expose(700, 5)
		if (ismob(holder))
			isHeld = 1
		else




			// note remove luminosity processing until can understand how to make this compatible
			// with the fire checks, etc.

			isHeld = 0
			if (lastHolder != null)
				//lastHolder.sd_SetLuminosity(0)
				lastHolder = null

		if (isHeld == 1)
			//if (holder != lastHolder && lastHolder != null)
				//lastHolder.sd_SetLuminosity(0)
			//holder.sd_SetLuminosity(1)
			lastHolder = holder

		//sd_SetLuminosity(1)
		sleep(10)

	if (lastHolder != null)
		//lastHolder.sd_SetLuminosity(0)
		lastHolder = null

	//sd_SetLuminosity(0)


/obj/item/clothing/mask/cigarette/dropped(mob/user as mob)
	if(src.lit == 1)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] calmly drops and treads on the lit [], putting it out instantly.", user,src.name), 1)
		src.lit = -1
		src.damtype = "brute"
		src.icon_state = icon_butt
		src.item_state = icon_off
		src.desc = "A [src.name] butt."
		src.name = "[src.name] butt"
		return ..()
	else
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] drops the []. Guess they've had enough for the day.", user, src), 1)
		return ..()

////////////
//CIG PACK//
////////////

/obj/item/weapon/cigpacket/update_icon()
	src.icon_state = text("cigpacket[]", src.cigcount)
	src.desc = text("There are [] cigs\s left!", src.cigcount)
	return

/obj/item/weapon/cigpacket/attack_hand(mob/user as mob)
	if(user.r_hand == src || user.l_hand == src)
		if(src.cigcount == 0)
			user << "\red You're out of cigs, shit! How you gonna get through the rest of the day..."
			return
		else
			src.cigcount--
			var/obj/item/clothing/mask/cigarette/W = new /obj/item/clothing/mask/cigarette(user)
			if(user.hand)
				user.l_hand = W
			else
				user.r_hand = W
			W.layer = 20
	else
		return ..()
	src.update_icon()
	return

/////////
//ZIPPO//
/////////
#define ZIPPO_LUM 2

/obj/item/weapon/zippo/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		if(!src.lit)
			src.lit = 1
			src.icon_state = "zippoon"
			src.item_state = "zippoon"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red Without even breaking stride, [] flips open and lights the [] in one smooth movement.", user, src), 1)

			user.sd_SetLuminosity(user.luminosity + ZIPPO_LUM)
			spawn(0)
				process()
		else
			src.lit = 0
			src.icon_state = "zippo"
			src.item_state = "zippo"
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red You hear a quiet click, as [] shuts off the [] without even looking what they're doing. Wow.", user, src), 1)

			user.sd_SetLuminosity(user.luminosity - ZIPPO_LUM)
	else
		return ..()
	return


/obj/item/weapon/zippo/process()

	while(src.lit)
		var/turf/location = src.loc

		if(istype(location, /mob/))
			var/mob/M = location
			if(M.l_hand == src || M.r_hand == src)
				location = M.loc
		if (istype(location, /turf))
			location.hotspot_expose(700, 5)
		sleep(10)


/obj/item/weapon/zippo/pickup(mob/user)
	if(lit)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + ZIPPO_LUM)



/obj/item/weapon/zippo/dropped(mob/user)
	if(lit)
		user.sd_SetLuminosity(user.luminosity - ZIPPO_LUM)
		src.sd_SetLuminosity(ZIPPO_LUM)