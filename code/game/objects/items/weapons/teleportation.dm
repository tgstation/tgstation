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
	var/listening = 1.0
	flags = FPRINT
	siemens_coefficient = 1
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	starting_materials = list(MAT_IRON = 400)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"

/obj/item/weapon/locator/attack_self(mob/user as mob)
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
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if (href_list["refresh"])
			src.temp = "<B>Persistent Signal Locator</B><HR>"
			var/turf/sr = get_turf(src)

			if (sr)
				src.temp += "<B>Located Beacons:</B><BR>"

				for(var/obj/item/beacon/W in beacons)
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
				for (var/obj/item/weapon/implant/tracking/W in world)
					if (!W.implanted || !(istype(W.loc,/datum/organ/external) || ismob(W.loc)))
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
							src.temp += "[W.id]-[dir2text(get_dir(sr, tr))]-[direct]<BR>"

				src.temp += "<B>You are at \[[sr.x-WORLD_X_OFFSET[sr.z]],[sr.y-WORLD_Y_OFFSET[sr.z]],[sr.z]\]</B> in orbital coordinates.<BR><BR><A href='byond://?src=\ref[src];refresh=1'>Refresh</A><BR>"
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
 #define HANDTELE_MAX_CHARGE	45
 #define HANDTELE_PORTAL_COST	15
/obj/item/weapon/hand_tele
	name = "hand tele"
	desc = "A portable item using blue-space technology."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	throwforce = 5
	w_class = 2.0
	throw_speed = 3
	throw_range = 5
	starting_materials = list(MAT_IRON = 10000, MAT_GOLD = 500, MAT_PHAZON = 50)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1;bluespace=3"
	var/list/portals = list()
	var/charge = HANDTELE_MAX_CHARGE//how many pairs of portal can the hand-tele sustain at once. a new charge is added every 30 seconds until the maximum is reached..
	var/recharging = 0

/obj/item/weapon/hand_tele/attack_self(mob/user as mob)
	var/turf/current_location = get_turf(user)//What turf is the user on?
	if(!current_location||current_location.z==2||current_location.z>=7)//If turf was not found or they're on z level 2 or >7 which does not currently exist.
		to_chat(user, "<span class='notice'>\The [src] is malfunctioning.</span>")
		return
	var/list/L = list(  )
	for(var/obj/machinery/computer/teleporter/R in machines)
		for(var/obj/machinery/teleport/hub/com in locate(R.x + 2, R.y, R.z))
			if(R.locked && !R.one_time_use)
				if(com.engaged)
					L["[R.id] (Active)"] = R.locked
				else
					L["[R.id] (Inactive)"] = R.locked

	var/list/turfs = new/list()

	for (var/turf/T in trange(10, user))
		// putting them at the edge is dumb
		if (T.x > world.maxx - 8 || T.x < 8)
			continue

		if (T.y > world.maxy - 8 || T.y < 8)
			continue

		turfs += T

	if (turfs.len)
		L["None (Dangerous)"] = pick(turfs)

	turfs = null

	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") in L

	if((user.get_active_hand() != src || user.stat || user.restrained()))
		return
	if(charge < HANDTELE_PORTAL_COST)
		user.show_message("<span class='notice'>\The [src] is recharging!</span>")
		return
	var/T = L[t1]

	if((t1 == "None (Dangerous)") && prob(5))
		T = locate(rand(7, world.maxx - 7), rand(7, world.maxy -7), map.zTCommSat)

	var/turf/U = get_turf(src)
	U.visible_message("<span class='notice'>Locked In.</span>")
	var/obj/effect/portal/P1 = new (U)
	var/obj/effect/portal/P2 = new (get_turf(T))
	P1.target = P2
	P2.target = P1
	P2.icon_state = "portal1"
	P1.creator = src
	P2.creator = src
	P1.blend_icon(P2)
	P2.blend_icon(P1)
	portals += P1
	portals += P2
	src.add_fingerprint(user)

	charge = max(charge - HANDTELE_PORTAL_COST,0)
	if(!recharging)
		recharging = 1
		processing_objects.Add(src)

/obj/item/weapon/hand_tele/process()
	charge = min(HANDTELE_MAX_CHARGE,charge+1)
	if(charge >= HANDTELE_MAX_CHARGE)
		processing_objects.Remove(src)
		recharging = 0
	return 1

 #undef HANDTELE_MAX_CHARGE
 #undef HANDTELE_PORTAL_COST
