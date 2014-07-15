/obj/item/weapon/dart_cartridge
	name = "dart cartridge"
	desc = "A rack of hollow darts."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "darts-5"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	var/darts = 5
	w_class = 2

/obj/item/weapon/dart_cartridge/update_icon()
	if(!darts)
		icon_state = "darts-0"
	else if(darts > 5)
		icon_state = "darts-5"
	else
		icon_state = "darts-[darts]"
	return 1

/obj/item/weapon/gun/dartgun
	name = "dart gun"
	desc = "A small gas-powered dartgun, capable of delivering chemical cocktails swiftly across short distances."
	icon_state = "dartgun-empty"

	var/list/beakers = list() //All containers inside the gun.
	var/list/mixing = list() //Containers being used for mixing.
	var/obj/item/weapon/dart_cartridge/cartridge = null //Container of darts.
	var/max_beakers = 3
	var/dart_reagent_amount = 15
	var/container_type = /obj/item/weapon/reagent_containers/glass/beaker/vial
	var/list/starting_chems = null

/obj/item/weapon/gun/dartgun/update_icon()

	if(!cartridge)
		icon_state = "dartgun-empty"
		return 1

	if(!cartridge.darts)
		icon_state = "dartgun-0"
	else if(cartridge.darts > 5)
		icon_state = "dartgun-5"
	else
		icon_state = "dartgun-[cartridge.darts]"
	return 1

/obj/item/weapon/gun/dartgun/New()

	..()
	if(starting_chems)
		for(var/chem in starting_chems)
			var/obj/item/weapon/reagent_containers/glass/beaker/B = new(src)
			B.reagents.add_reagent(chem, 50)
			beakers += B
	cartridge = new /obj/item/weapon/dart_cartridge(src)
	update_icon()

/obj/item/weapon/gun/dartgun/examine()
	set src in view()
	update_icon()
	..()
	if (!(usr in view(2)) && usr!=src.loc)
		return
	if (beakers.len)
		usr << "\blue [src] contains:"
		for(var/obj/item/weapon/reagent_containers/glass/beaker/B in beakers)
			if(B.reagents && B.reagents.reagent_list.len)
				for(var/datum/reagent/R in B.reagents.reagent_list)
					usr << "\blue [R.volume] units of [R.name]"

/obj/item/weapon/gun/dartgun/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/dart_cartridge))

		var/obj/item/weapon/dart_cartridge/D = I

		if(!D.darts)
			user << "\blue [D] is empty."
			return 0

		if(cartridge)
			if(cartridge.darts <= 0)
				src.remove_cartridge()
			else
				user << "\blue There's already a cartridge in [src]."
				return 0

		user.drop_item()
		cartridge = D
		D.loc = src
		user << "\blue You slot [D] into [src]."
		update_icon()
		return
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(!istype(I, container_type))
			user << "\blue [I] doesn't seem to fit into [src]."
			return
		if(beakers.len >= max_beakers)
			user << "\blue [src] already has [max_beakers] vials in it - another one isn't going to fit!"
			return
		var/obj/item/weapon/reagent_containers/glass/beaker/B = I
		user.drop_item()
		B.loc = src
		beakers += B
		user << "\blue You slot [B] into [src]."
		src.updateUsrDialog()

/obj/item/weapon/gun/dartgun/can_fire()
	if(!cartridge)
		return 0
	else
		return cartridge.darts

/obj/item/weapon/gun/dartgun/proc/has_selected_beaker_reagents()
	return 0

/obj/item/weapon/gun/dartgun/proc/remove_cartridge()
	if(cartridge)
		usr << "\blue You pop the cartridge out of [src]."
		var/obj/item/weapon/dart_cartridge/C = cartridge
		C.loc = get_turf(src)
		C.update_icon()
		cartridge = null
		src.update_icon()

/obj/item/weapon/gun/dartgun/proc/get_mixed_syringe()
	if (!cartridge)
		return 0
	if(!cartridge.darts)
		return 0

	var/obj/item/weapon/reagent_containers/syringe/dart = new(src)

	if(mixing.len)
		var/mix_amount =  5 //dart_reagent_amount/mixing.len | 5 per mixed should be fine enough.
		for(var/obj/item/weapon/reagent_containers/glass/beaker/B in mixing)
			B.reagents.trans_to(dart,mix_amount)

	return dart

/obj/item/weapon/gun/dartgun/proc/fire_dart(atom/target, mob/user)
	if (locate (/obj/structure/table, src.loc))
		return
	else
		var/turf/trg = get_turf(target)
		var/obj/effect/syringe_gun_dummy/D = new/obj/effect/syringe_gun_dummy(get_turf(src))
		var/obj/item/weapon/reagent_containers/syringe/S = get_mixed_syringe()
		if(!S)
			user << "\red There are no darts in [src]!"
			return
		if(!S.reagents)
			user << "\red There are no reagents available!"
			return
		cartridge.darts--
		src.update_icon()
		S.reagents.trans_to(D, S.reagents.total_volume)
		del(S)
		D.icon_state = "syringeproj"
		D.name = "syringe"
		D.flags |= NOREACT
		playsound(user.loc, 'sound/weapons/dartgun.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if(!D) break
			if(D.loc == trg) break
			step_towards(D,trg)

			if(D)
				for(var/mob/living/carbon/M in D.loc)
					if(!istype(M,/mob/living/carbon)) continue
					if(M == user) continue
					//Syringe gun attack logging by Yvarov
					var/R
					if(D.reagents)
						for(var/datum/reagent/A in D.reagents.reagent_list)
							R += A.id + " ("
							R += num2text(A.volume) + "),"
					if (istype(M, /mob))
						M.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>dartgun</b> ([R])"
						user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>dartgun</b> ([R])"
						msg_admin_attack("[user] ([user.ckey]) shot [M] ([M.ckey]) with a dartgun ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
						if(!iscarbon(user))
							M.LAssailant = null
						else
							M.LAssailant = user

					else
						M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>dartgun</b> ([R])"
						msg_admin_attack("UNKNOWN shot [M] ([M.ckey]) with a <b>dartgun</b> ([R]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

					if(D.reagents)
						D.reagents.trans_to(M, 15)
					M << "<span class='danger'>You feel a slight prick.</span>"

					del(D)
					break
			if(D)
				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density) del(D)

			sleep(1)

		if (D) spawn(10) del(D)

		return

/obj/item/weapon/gun/dartgun/afterattack(obj/target, mob/user , flag)
	if(!isturf(target.loc) || target == user) return
	..()

/obj/item/weapon/gun/dartgun/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return 1

/obj/item/weapon/gun/dartgun/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		if ((usr.client && usr.machine == src && src.loc == usr))
			is_in_use = 1
			src.attack_self(usr)
		if (isMoMMI(usr))
			if ((usr.client && usr.machine == src && src.loc == usr)) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				is_in_use = 1
				src.attack_self(usr)

		// check for TK users
		in_use = is_in_use

/obj/item/weapon/gun/dartgun/attack_self(mob/user)
	user.set_machine(src)
	in_use = 1
	var/dat = "<b>[src] mixing control:</b><br><br>"

	if (beakers.len)
		var/i = 1
		for(var/obj/item/weapon/reagent_containers/glass/beaker/B in beakers)
			dat += "Beaker [i] contains: "
			if(B.reagents && B.reagents.reagent_list.len)
				for(var/datum/reagent/R in B.reagents.reagent_list)
					dat += "<br>    [R.volume] units of [R.name], "
				if (check_beaker_mixing(B))
					dat += text("<A href='?src=\ref[src];stop_mix=[i]'><font color='green'>Mixing</font></A> ")
				else
					dat += text("<A href='?src=\ref[src];mix=[i]'><font color='red'>Not mixing</font></A> ")
			else
				dat += "nothing."
			dat += " \[<A href='?src=\ref[src];eject=[i]'>Eject</A>\]<br>"
			i++
	else
		dat += "There are no beakers inserted!<br><br>"

	if(cartridge)
		if(cartridge.darts)
			dat += "The dart cartridge has [cartridge.darts] shots remaining."
		else
			dat += "<font color='red'>The dart cartridge is empty!</font>"
		dat += " \[<A href='?src=\ref[src];eject_cart=1'>Eject</A>\]"

	user << browse(dat, "window=dartgun")
	onclose(user, "dartgun", src)

/obj/item/weapon/gun/dartgun/proc/check_beaker_mixing(var/obj/item/B)
	if(!mixing || !beakers)
		return 0
	for(var/obj/item/M in mixing)
		if(M == B)
			return 1
	return 0

/obj/item/weapon/gun/dartgun/Topic(href, href_list)
	src.add_fingerprint(usr)
	if(href_list["stop_mix"])
		var/index = text2num(href_list["stop_mix"])
		if(index <= beakers.len)
			for(var/obj/item/M in mixing)
				if(M == beakers[index])
					mixing -= M
					break
	else if (href_list["mix"])
		var/index = text2num(href_list["mix"])
		if(index <= beakers.len)
			mixing += beakers[index]
	else if (href_list["eject"])
		var/index = text2num(href_list["eject"])
		if(index <= beakers.len)
			if(beakers[index])
				var/obj/item/weapon/reagent_containers/glass/beaker/B = beakers[index]
				usr << "You remove [B] from [src]."
				mixing -= B
				beakers -= B
				B.loc = get_turf(src)
	else if (href_list["eject_cart"])
		remove_cartridge()
	else if (href_list["close"])
		in_use = 0
		usr.unset_machine(src)
		return
	src.updateUsrDialog()
	return

/obj/item/weapon/gun/dartgun/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(cartridge)
		spawn(0) fire_dart(target,user)
	else
		usr << "\red [src] is empty."


/obj/item/weapon/gun/dartgun/vox
	name = "alien dart gun"
	desc = "A small gas-powered dartgun, fitted for nonhuman hands."

/obj/item/weapon/gun/dartgun/vox/medical
	starting_chems = list("kelotane","bicaridine","anti_toxin")

/obj/item/weapon/gun/dartgun/vox/raider
	starting_chems = list("stoxin","chloralhydrate")