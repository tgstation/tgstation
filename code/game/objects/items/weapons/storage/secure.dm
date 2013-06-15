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
	w_class = 3.0
	max_w_class = 2
	max_combined_w_class = 14
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/open_panel = 0
	var/datum/wires/secstorage/wires


/obj/item/weapon/storage/secure/New()
	wires = new(src)
	..()


/obj/item/weapon/storage/secure/examine()
	set src in oview(1)
	..()
	usr << "The service panel is [open_panel ? "open" : "closed"]."


/obj/item/weapon/storage/secure/attackby(obj/item/I, mob/user)
	if(locked)
		if(istype(I, /obj/item/weapon/screwdriver))
			open_panel = !open_panel
			user << "<span class='notice'>You [open_panel ? "open" : "close"] the service panel.</span>"
			if(open_panel)
				wires.Interact(user)
			return

		if(open_panel)
			if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler))
				wires.Interact(user)

		//it's still locked, chump
		return

	//-> storage/attackby() what with handle insertion, etc
	..()


/obj/item/weapon/storage/secure/attack_self(mob/user)
	user.set_machine(src)
	var/dat = {"<tt>
				<b>[src]</b>
				<br><br><br>
				Lock Status: [locked ? "LOCKED" : "UNLOCKED"]"}

	var/message = "Code"
	if(l_set == 0)
		dat += "<br><p><b>4-DIGIT PASSCODE NOT SET.<br>ENTER NEW PASSCODE.</b>"

	message = "[code]"
	if(!locked)
		message = "****"

	dat += {"<hr><br>>[message]<br><br>
			<a href='?src=\ref[src];type=1'>1</a>-
			<a href='?src=\ref[src];type=2'>2</a>-
			<a href='?src=\ref[src];type=3'>3</a><br><br>
			<a href='?src=\ref[src];type=4'>4</a>-
			<a href='?src=\ref[src];type=5'>5</a>-
			<a href='?src=\ref[src];type=6'>6</a><br><br>
			<a href='?src=\ref[src];type=7'>7</a>-
			<a href='?src=\ref[src];type=8'>8</a>-
			<a href='?src=\ref[src];type=9'>9</a><br><br>
			<a href='?src=\ref[src];type=R'>R</a>-
			<a href='?src=\ref[src];type=0'>0</a>-
			<a href='?src=\ref[src];type=E'>E</a><br><br>
			</TT>"}

	user << browse(dat, "window=caselock;size=300x280")

/obj/item/weapon/storage/secure/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()) || get_dist(src, usr) > 1)
		return

	if(href_list["type"])
		if(href_list["type"] == "E")
			if(l_set == 0 && length(code) == 4 && code != "ERROR")
				l_code = code
				l_set = 1
			else if(code == l_code && l_set == 1)
				locked = 0
				overlays = null
				overlays += image('icons/obj/storage.dmi', icon_opened)
				code = null
			else
				code = "ERROR"
		else
			if(href_list["type"] == "R")
				locked = 1
				overlays = null
				code = null
				close(usr)
			else
				code += "[href_list["type"]]"
				if(length(code) > 4)
					code = "ERROR"

		add_fingerprint(usr)
		for(var/mob/M in viewers(1, loc))
			if(M.client && M.machine == src)
				attack_self(M)

// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "sec-case"
	desc = "A large briefcase with a digital locking system."
	flags = FPRINT | TABLEPASS
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_combined_w_class = 21

	New()
		..()
		new /obj/item/weapon/paper(src)
		new /obj/item/weapon/pen(src)

	attack_hand(mob/user as mob)
		if((loc == user) && (locked == 1))
			usr << "\red [src] is locked and cannot be opened!"
		else if((loc == user) && (!locked))
			playsound(loc, "rustle", 50, 1, -5)
			if(user.s_active)
				user.s_active.close(user) //Close and re-open
			show_to(user)
		else
			..()
			for(var/mob/M in range(1))
				if(M.s_active == src)
					close(M)
			orient2hud(user)
		add_fingerprint(user)
		return

	//I consider this worthless but it isn't my code so whatever.  Remove or uncomment.
	/*attack(mob/M as mob, mob/living/user as mob)
		if((CLUMSY in user.mutations) && prob(50))
			user << "\red The [src] slips out of your hand and hits your head."
			user.take_organ_damage(10)
			user.Paralyse(2)
			return

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to attack [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)])</font>")

		var/t = user:zone_sel.selecting
		if(t == "head")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
					if(istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80))
						H << "\red The helmet protects you from being hit hard in the head!"
						return
					var/time = rand(2, 6)
					if(prob(75))
						H.Paralyse(time)
					else
						H.Stun(time)
					if(H.stat != 2)	H.stat = 1
					for(var/mob/O in viewers(H, null))
						O.show_message(text("\red <B>[] has been knocked unconscious!</B>", H), 1, "\red You hear someone fall.", 2)
				else
					H << text("\red [] tried to knock you unconcious!",user)
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
	flags = FPRINT | TABLEPASS
	force = 8.0
	w_class = 8.0
	max_w_class = 8
	anchored = 1.0
	density = 0
	cant_hold = list("/obj/item/weapon/storage/secure/briefcase")

	New()
		..()
		new /obj/item/weapon/paper(src)
		new /obj/item/weapon/pen(src)

	attack_hand(mob/user as mob)
		return attack_self(user)

/obj/item/weapon/storage/secure/safe/HoS/New()
	..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)