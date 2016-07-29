<<<<<<< HEAD
/obj/item/device/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon = 'icons/obj/radio.dmi'
	icon_state = "electropack0"
	item_state = "electropack"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	w_class = 5
	materials = list(MAT_METAL=10000, MAT_GLASS=2500)
	var/on = 1
	var/code = 2
	var/frequency = 1449
	var/shock_cooldown = 0

/obj/item/device/electropack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] hooks \himself to the electropack and spams the trigger! It looks like \he's trying to commit suicide..</span>")
	return (FIRELOSS)

/obj/item/device/electropack/initialize()
	if(SSradio)
		SSradio.add_object(src, frequency, RADIO_CHAT)

/obj/item/device/electropack/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	return ..()

/obj/item/device/electropack/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.back)
			user << "<span class='warning'>You need help taking this off!</span>"
			return
	..()

/obj/item/device/electropack/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/clothing/head/helmet))
		var/obj/item/assembly/shock_kit/A = new /obj/item/assembly/shock_kit( user )
		A.icon = 'icons/obj/assemblies.dmi'

		if(!user.unEquip(W))
			user << "<span class='warning'>\the [W] is stuck to your hand, you cannot attach it to \the [src]!</span>"
			return
		W.loc = A
		W.master = A
		A.part1 = W

		user.unEquip(src)
		loc = A
		master = A
		A.part2 = src

		user.put_in_hands(A)
		A.add_fingerprint(user)
		if(src.flags & NODROP)
			A.flags |= NODROP
	else
		return ..()

/obj/item/device/electropack/Topic(href, href_list)
	//..()
	var/mob/living/carbon/C = usr
	if(usr.stat || usr.restrained() || C.back == src)
		return
	if(((istype(usr, /mob/living/carbon/human) && ((!( ticker ) || (ticker && ticker.mode != "monkey")) && usr.contents.Find(src))) || (usr.contents.Find(master) || (in_range(src, usr) && istype(loc, /turf)))))
		usr.set_machine(src)
		if(href_list["freq"])
			SSradio.remove_object(src, frequency)
			frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			SSradio.add_object(src, frequency, RADIO_CHAT)
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

/obj/item/device/electropack/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption != code)
		return

	if(ismob(loc) && on)
		if(shock_cooldown != 0)
			return
		shock_cooldown = 1
		spawn(100)
			shock_cooldown = 0
		var/mob/M = loc
		step(M, pick(cardinal))

		M << "<span class='danger'>You feel a sharp shock!</span>"
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, M)
		s.start()

		M.Weaken(5)

	if(master)
		master.receive_signal()
	return

/obj/item/device/electropack/attack_self(mob/user)

	if(!istype(user, /mob/living/carbon/human))
		return
	user.set_machine(src)
	var/dat = {"<TT>Turned [on ? "On" : "Off"] -
<A href='?src=\ref[src];power=1'>Toggle</A><BR>
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
=======
/obj/item/device/radio/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon_state = "electropack0"
	item_state = "electropack"
	origin_tech = "materials=1;powerstorage=2"
	frequency = 1449
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	w_class = W_CLASS_HUGE
	starting_materials = list(MAT_IRON = 10000, MAT_GLASS = 2500)
	w_type = RECYK_ELECTRONIC
	var/code = 2
	var/datum/radio_frequency/radio_connection

/obj/item/device/radio/electropack/New()
	..()
	if(radio_controller)
		initialize()
	else
		spawn(50)
			if(radio_controller) initialize()

/obj/item/device/radio/electropack/initialize()
	if(frequency < MINIMUM_FREQUENCY || frequency > MAXIMUM_FREQUENCY)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/device/radio/electropack/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/item/device/radio/electropack/attack_hand(mob/user as mob)
	if(src == user.back)
		to_chat(user, "<span class='notice'>You need help taking this off!</span>")
		return
	..()

/obj/item/device/radio/electropack/Destroy()
	if(istype(src.loc, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/S = src.loc
		if(S.part1 == src)
			S.part1 = null
		else if(S.part2 == src)
			S.part2 = null
		master = null
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	..()

/obj/item/device/radio/electropack/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/clothing/head/helmet))
		if(!b_stat)
			to_chat(user, "<span class='notice'>[src] is not ready to be attached!</span>")
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
		usr.set_machine(src)
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

	if(istype(src.loc, /obj/mecha) && on)
		var/obj/mecha/R = src.loc //R is for GIANT ROBOT
		R.shock_n_boot()

	else if(istype(src.loc, /obj/item/assembly/shock_kit) && on)
		var/obj/item/assembly/shock_kit/SK = src.loc
		SK.receive_signal()

	else if(ismob(loc) && on)
		var/mob/M = loc
		var/turf/T = M.loc
		if(istype(T, /turf))
			if(!M.moved_recently && M.last_move)
				M.moved_recently = 1
				step(M, M.last_move)
				spawn(50)
					if(M)
						M.moved_recently = 0
		to_chat(M, "<span class='danger'>You feel a sharp shock!</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, M)
		s.start()

		M.Weaken(10)

	if(master && isWireCut(1))
		master.receive_signal()
	return

/obj/item/device/radio/electropack/attack_self(mob/user as mob, flag1)

	if(!istype(user, /mob/living/carbon/human))
		return
	user.set_machine(src)
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
