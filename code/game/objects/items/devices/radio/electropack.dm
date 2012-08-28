/obj/item/device/radio/electropack
	name = "Electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	var/code = 2
	var/e_pads = 0.0
	g_amt = 2500
	m_amt = 10000
	frequency = 1449
	w_class = 5.0
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BACK
	item_state = "electropack"

/obj/item/device/radio/electropack/examine()
	set src in view()

	..()
	if ((in_range(src, usr) || src.loc == usr))
		if (src.e_pads)
			usr << "\blue The electric pads are exposed!"
	return

/obj/item/device/radio/electropack/attack_paw(mob/user as mob)

	return src.attack_hand(user)
	return

/obj/item/device/radio/electropack/attack_hand(mob/user as mob)

	if (src == user.back)
		user << "\blue You need help taking this off!"
		return
	else
		..()
	return

/obj/item/device/radio/electropack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/weapon/screwdriver))
		src.e_pads = !( src.e_pads )
		if (src.e_pads)
			user.show_message("\blue The electric pads have been exposed!")
		else
			user.show_message("\blue The electric pads have been reinserted!")
		src.add_fingerprint(user)
		return
	else
		if (istype(W, /obj/item/clothing/head/helmet))
			var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit( user )
			A.icon = 'icons/obj/assemblies.dmi'

			user.drop_from_inventory(W)
			W.loc = A
			W.master = A
			A.part1 = W

			user.drop_from_inventory(src)
			src.loc = A
			src.master = A
			A.part2 = src

			user.put_in_hands(A)
			A.add_fingerprint(user)
	return

/obj/item/device/radio/electropack/Topic(href, href_list)
	//..()
	if (usr.stat || usr.restrained())
		return
	if (((istype(usr, /mob/living/carbon/human) && ((!( ticker ) || (ticker && ticker.mode != "monkey")) && usr.contents.Find(src))) || (usr.contents.Find(src.master) || (in_range(src, usr) && istype(src.loc, /turf)))))
		usr.machine = src
		if (href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			set_frequency(new_frequency)
		else
			if (href_list["code"])
				src.code += text2num(href_list["code"])
				src.code = round(src.code)
				src.code = min(100, src.code)
				src.code = max(1, src.code)
			else
				if (href_list["power"])
					src.on = !( src.on )
					src.icon_state = text("electropack[]", src.on)
		if (!( src.master ))
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				for(var/mob/M in viewers(1, src))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(308)
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				for(var/mob/M in viewers(1, src.master))
					if (M.client)
						src.attack_self(M)
					//Foreach goto(384)
	else
		usr << browse(null, "window=radio")
		return
	return
/*
/obj/item/device/radio/electropack/accept_rad(obj/item/device/radio/signaler/R as obj, message)

	if ((istype(R, /obj/item/device/radio/signaler) && R.frequency == src.frequency && R.code == src.code))
		return 1
	else
		return null
	return*/

/obj/item/device/radio/electropack/receive_signal(datum/signal/signal)
	if(!signal || (signal.encryption != code))
		return

	if ((ismob(src.loc) && src.on))

		var/mob/M = src.loc
		var/turf/T = M.loc
		if ((istype(T, /turf)))
			if (!M.moved_recently && M.last_move)
				M.moved_recently = 1
				step(M, M.last_move)
				sleep 50
				if(M)
					M.moved_recently = 0
		M.show_message("\red <B>You feel a sharp shock!</B>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, M)
		s.start()

		M.Weaken(10)

	if ((src.master && src.wires & 1))
		src.master.receive_signal()
	return

/obj/item/device/radio/electropack/attack_self(mob/user as mob, flag1)

	if (!( istype(user, /mob/living/carbon/human) ))
		return
	user.machine = src
	var/dat = {"<TT>
<A href='?src=\ref[src];power=1'>Turn [src.on ? "Off" : "On"]</A><BR>
<B>Frequency/Code</B> for electropack:<BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

Code:
<A href='byond://?src=\ref[src];code=-5'>-</A>
<A href='byond://?src=\ref[src];code=-1'>-</A> [src.code]
<A href='byond://?src=\ref[src];code=1'>+</A>
<A href='byond://?src=\ref[src];code=5'>+</A><BR>
</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return
