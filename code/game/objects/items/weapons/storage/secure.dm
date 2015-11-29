/*
 *	Absorbs /obj/item/weapon/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/weapon/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	w_class = 3.0
	max_w_class = 2
	max_combined_w_class = 14

/obj/item/weapon/storage/secure/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>The service panel is [src.open ? "open" : "closed"].</span>")

/obj/item/weapon/storage/secure/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
		if ( istype(W, /obj/item/weapon/card/emag) && (!src.emagged))
			emagged = 1
			src.overlays += image('icons/obj/storage.dmi', icon_sparking)
			sleep(6)
			src.overlays = null
			overlays += image('icons/obj/storage.dmi', icon_locking)
			locked = 0
			to_chat(user, "You short out the lock on [src].")
			return

		if (istype(W, /obj/item/weapon/screwdriver))
			if (do_after(user, src, 20))
				src.open =! src.open
				user.show_message(text("<span class='notice'>You [] the service panel.</span>", (src.open ? "open" : "close")))
			return
		if ((istype(W, /obj/item/device/multitool)) && (src.open == 1)&& (!src.l_hacking))
			user.show_message(text("<span class='warning'>Now attempting to reset internal memory, please hold.</span>"), 1)
			src.l_hacking = 1
			if (do_after(usr, src, 100))
				if (prob(40))
					src.l_setshort = 1
					src.l_set = 0
					user.show_message(text("<span class='warning'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>"), 1)
					sleep(80)
					src.l_setshort = 0
					src.l_hacking = 0
				else
					user.show_message(text("<span class='warning'>Unable to reset internal memory.</span>"), 1)
					src.l_hacking = 0
			else	src.l_hacking = 0
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	// -> storage/attackby() what with handle insertion, etc
	..()


/obj/item/weapon/storage/secure/MouseDrop(over_object, src_location, over_location)
	if (locked)
		src.add_fingerprint(usr)
		return
	..()


/obj/item/weapon/storage/secure/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = text("<TT><B>[]</B><BR>\n\nLock Status: []",src, (src.locked ? "LOCKED" : "UNLOCKED"))
	var/message = "Code"
	if ((src.l_set == 0) && (!src.emagged) && (!src.l_setshort))
		dat += text("<p>\n<b>5-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>")
	if (src.emagged)
		dat += text("<p>\n<font color=red><b>LOCKING SYSTEM ERROR - 1701</b></font>")
	if (src.l_setshort)
		dat += text("<p>\n<font color=red><b>ALERT: MEMORY SYSTEM ERROR - 6040 201</b></font>")
	message = text("[]", src.code)
	if (!src.locked)
		message = "*****"
	dat += text("<HR>\n>[]<BR>\n<A href='?src=\ref[];type=1'>1</A>-<A href='?src=\ref[];type=2'>2</A>-<A href='?src=\ref[];type=3'>3</A><BR>\n<A href='?src=\ref[];type=4'>4</A>-<A href='?src=\ref[];type=5'>5</A>-<A href='?src=\ref[];type=6'>6</A><BR>\n<A href='?src=\ref[];type=7'>7</A>-<A href='?src=\ref[];type=8'>8</A>-<A href='?src=\ref[];type=9'>9</A><BR>\n<A href='?src=\ref[];type=R'>R</A>-<A href='?src=\ref[];type=0'>0</A>-<A href='?src=\ref[];type=E'>E</A><BR>\n</TT>", message, src, src, src, src, src, src, src, src, src, src, src, src)
	user << browse(dat, "window=caselock;size=300x280")

/obj/item/weapon/storage/secure/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if (href_list["type"])
		if (href_list["type"] == "E")
			if ((src.l_set == 0) && (length(src.code) == 5) && (!src.l_setshort) && (src.code != "ERROR"))
				src.l_code = src.code
				src.l_set = 1
			else if ((src.code == src.l_code) && (src.emagged == 0) && (src.l_set == 1))
				src.locked = 0
				src.overlays = null
				overlays += image('icons/obj/storage.dmi', icon_opened)
				src.code = null
			else
				src.code = "ERROR"
		else
			if ((href_list["type"] == "R") && (src.emagged == 0) && (!src.l_setshort))
				src.locked = 1
				src.overlays = null
				src.code = null
				src.close(usr)
			else
				src.code += text("[]", href_list["type"])
				if (length(src.code) > 5)
					src.code = "ERROR"
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src.loc))
			if ((M.client && M.machine == src))
				src.attack_self(M)
			return
	return

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	flags = FPRINT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0

/obj/item/weapon/storage/secure/briefcase/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/briefcase/attack_hand(mob/user as mob)
	if ((src.loc == user) && (src.locked == 1))
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if ((src.loc == user) && (!src.locked))
		playsound(get_turf(src), "rustle", 50, 1, -5)
		if (user.s_active)
			user.s_active.close(user) //Close and re-open
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
		src.orient2hud(user)
	src.add_fingerprint(user)
	return

	//I consider this worthless but it isn't my code so whatever.  Remove or uncomment.
	/*attack(mob/M as mob, mob/living/user as mob)
		if ((M_CLUMSY in user.mutations) && prob(50))
			to_chat(user, "<span class='warning'>The [src] slips out of your hand and hits your head.</span>")
			user.take_organ_damage(10)
			user.Paralyse(2)
			return

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		var/t = user:zone_sel.selecting
		if (t == "head")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
					if (istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
						to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
						return
					var/time = rand(2, 6)
					if (prob(75))
						H.Paralyse(time)
					else
						H.Stun(time)
					if(H.stat != 2)	H.stat = 1
					for(var/mob/O in viewers(H, null))
						O.show_message(text("<span class='danger'>[] has been knocked unconscious!</span>", H), 1, "<span class='warning'>You hear someone fall.</span>", 2)
				else
					to_chat(H, text("<span class='warning'>[] tried to knock you unconcious!</span>",user))
					H.eye_blurry += 3

		return*/

// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/weapon/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	flags = FPRINT
	force = 8.0
	w_class = 8.0
	max_w_class = 8
	anchored = 1.0
	density = 0
	cant_hold = list("/obj/item/weapon/storage/secure/briefcase")

/obj/item/weapon/storage/secure/safe/New()
	..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/safe/attack_hand(mob/user as mob)
	return attack_self(user)

// Clown planet WMD storage
/obj/item/weapon/storage/secure/safe/clown
	name="WMD Storage"

/obj/item/weapon/storage/secure/safe/clown/New()
	for(var/i=0;i<10;i++)
		new /obj/item/weapon/reagent_containers/food/snacks/pie(src)

/obj/item/weapon/storage/secure/safe/HoS/New()
	..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)