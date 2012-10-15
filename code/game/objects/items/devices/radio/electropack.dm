/obj/item/device/radio/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	item_state = "electropack"
	frequency = 1449
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BACK
	w_class = 5.0
	g_amt = 2500
	m_amt = 10000
	var/code = 2

/obj/item/device/radio/electropack/attack_hand(mob/user as mob)
	if(src == user.back)
		user << "<span class='notice'>You need help taking this off!</span>"
		return
	..()

/obj/item/device/radio/electropack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/clothing/head/helmet))
		if(!b_stat)
			user << "<span class='notice'>[src] is not ready to be attached!</span>"
			return
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit( user )
		A.icon = 'icons/obj/assemblies.dmi'

		user.drop_from_inventory(W)
		W.loc = A
		W.master = A
		A.part1 = W

		user.drop_from_inventory(src)
		loc = A
		master = A
		A.part2 = src

		user.put_in_hands(A)
		A.add_fingerprint(user)

/obj/item/device/radio/electropack/Topic(href, href_list)
	//..()
	if(usr.stat || usr.restrained())
		return
	if(((istype(usr, /mob/living/carbon/human) && ((!( ticker ) || (ticker && ticker.mode != "monkey")) && usr.contents.Find(src))) || (usr.contents.Find(master) || (in_range(src, usr) && istype(loc, /turf)))))
		usr.machine = src
		if(href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			set_frequency(new_frequency)
		else
			if(href_list["code"])
				code += text2num(href_list["code"])
				code = round(code)
				code = min(100, code)
				code = max(1, code)
			else
				if(href_list["power"])
					on = !( on )
					icon_state = "electropack[on]"
		if(!( master ))
			if(istype(loc, /mob))
				attack_self(loc)
			else
				for(var/mob/M in viewers(1, src))
					if(M.client)
						attack_self(M)
		else
			if(istype(master.loc, /mob))
				attack_self(master.loc)
			else
				for(var/mob/M in viewers(1, master))
					if(M.client)
						attack_self(M)
	else
		usr << browse(null, "window=radio")
		return
	return

/obj/item/device/radio/electropack/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption != code)
		return

	if(ismob(loc) && on)
		var/mob/M = loc
		var/turf/T = M.loc
		if(istype(T, /turf))
			if(!M.moved_recently && M.last_move)
				M.moved_recently = 1
				step(M, M.last_move)
				sleep(50)
				if(M)
					M.moved_recently = 0
		M << "<span class='danger'>You feel a sharp shock!</span>"
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, M)
		s.start()

		M.Weaken(10)

	if(master && wires & 1)
		master.receive_signal()
	return

/obj/item/device/radio/electropack/attack_self(mob/user as mob, flag1)

	if(!istype(user, /mob/living/carbon/human))
		return
	user.machine = src
	var/dat = {"<TT>
<A href='?src=\ref[src];power=1'>Turn [on ? "Off" : "On"]</A><BR>
<B>Frequency/Code</B> for electropack:<BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

Code:
<A href='byond://?src=\ref[src];code=-5'>-</A>
<A href='byond://?src=\ref[src];code=-1'>-</A> [code]
<A href='byond://?src=\ref[src];code=1'>+</A>
<A href='byond://?src=\ref[src];code=5'>+</A><BR>
</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return
