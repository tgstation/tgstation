/* Teleportation devices.
 * Contains:
 *		Locator
 *		Hand-tele
 */

/*
 * Locator
 */
/obj/item/weapon/locator
	name = "locator"
	desc = "Used to track those with locater implants."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/temp = null
	var/frequency = 1451
	var/broadcasting = null
	var/listening = 1
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;bluespace=2"

/obj/item/weapon/locator/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = {"
<B>Persistent Signal Locator</B><HR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

<A href='?src=\ref[src];refresh=1'>Refresh</A>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/locator/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/turf/current_location = get_turf(usr)//What turf is the user on?
	if(!current_location||current_location.z==2)//If turf was not found or they're on z level 2.
		to_chat(usr, "The [src] is malfunctioning.")
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)))
		usr.set_machine(src)
		if (href_list["refresh"])
			src.temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Beacons:</B><BR>"

				for(var/obj/item/device/radio/beacon/W in teleportbeacons)
					if (W.frequency == src.frequency)
						var/turf/tr = get_turf(W)
						if (tr.z == sr.z && tr)
							var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									if (direct < 20)
										direct = "weak"
									else
										direct = "very weak"
							src.temp += "[W.code]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>Extranneous Signals:</B><BR>"
				for (var/obj/item/weapon/implant/tracking/W in tracked_implants)
					if (!W.imp_in || !ismob(W.loc))
						continue
					else
						var/mob/M = W.loc
						if (M.stat == 2)
							if (M.timeofdeath + 6000 < world.time)
								continue

					var/turf/tr = get_turf(W)
					if (tr.z == sr.z && tr)
						var/direct = max(abs(tr.x - sr.x), abs(tr.y - sr.y))
						if (direct < 20)
							if (direct < 5)
								direct = "very strong"
							else
								if (direct < 10)
									direct = "strong"
								else
									direct = "weak"
							src.temp += "[W.imp_in.name]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>You are at \[[sr.x],[sr.y],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
			else
				src.temp += "<B><FONT color='red'>Processing Error:</FONT></B> Unable to locate orbital position.<BR>"
		else
			if (href_list["freq"])
				src.frequency += text2num(href_list["freq"])
				src.frequency = sanitize_frequency(src.frequency)
			else
				if (href_list["temp"])
					src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return


/*
 * Hand-tele
 */
/obj/item/weapon/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = "magnets=3;bluespace=4"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 30, bio = 0, rad = 0, fire = 100, acid = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/active_portals = 0

/obj/item/weapon/hand_tele/attack_self(mob/user)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	var/area/current_area = current_location.loc
	if(!current_location || current_area.noteleport || current_location.z > ZLEVEL_SPACEMAX || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	var/list/L = list(  )
	for(var/obj/machinery/computer/teleporter/com in machines)
		if(com.target)
			var/area/A = get_area(com.target)
			if(!A || A.noteleport)
				continue
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				L["[get_area(com.target)] (Active)"] = com.target
			else
				L["[get_area(com.target)] (Inactive)"] = com.target
	var/list/turfs = list(	)
	for(var/turf/T in urange(10, orange=1))
		if(T.x>world.maxx-8 || T.x<8)
			continue	//putting them at the edge is dumb
		if(T.y>world.maxy-8 || T.y<8)
			continue
		var/area/A = T.loc
		if(A.noteleport)
			continue
		turfs += T
	if(turfs.len)
		L["None (Dangerous)"] = pick(turfs)
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") as null|anything in L
	if (!t1 || user.get_active_held_item() != src || user.incapacitated())
		return
	if(active_portals >= 3)
		user.show_message("<span class='notice'>\The [src] is recharging!</span>")
		return
	var/atom/T = L[t1]
	var/area/A = get_area(T)
	if(A.noteleport)
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	user.show_message("<span class='notice'>Locked In.</span>", 2)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(src), T, src)
	try_move_adjacent(P)
	active_portals++
	add_fingerprint(user)
