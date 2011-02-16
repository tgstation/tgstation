/*
CONTAINS:
SYNDICATE UPLINK
*/

/obj/item/weapon/syndicate_uplink/proc/explode()
	var/turf/location = get_turf(src.loc)
	if(location)
		location.hotspot_expose(700,125)

		explosion(location, 0, 0, 2, 4)

	del(src.master)
	del(src)
	return

/obj/item/weapon/syndicate_uplink/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.selfdestruct)
		dat = "Self Destructing..."
	else
		if (src.temp)
			dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
		else
			dat = "<B>Syndicate Uplink Console:</B><BR>"
			dat += "Tele-Crystals left: [src.uses]<BR>"
			dat += "<HR>"
			dat += "<B>Request item:</B><BR>"
			dat += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><BR>"
			dat += "<A href='byond://?src=\ref[src];item_revolver=1'>Revolver</A> (7)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_revolver_ammo=1'>Ammo-357</A> for use with Revolver (2)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_xbow=1'>Energy Crossbow</A> (5)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_empbox=1'>5 EMP Grenades</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_voice=1'>Voice-Changer</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_jump=1'>Chameleon Jumpsuit</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_card=1'>Syndicate Card</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_emag=1'>Electromagnet Card</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_imp_freedom=1'>Freedom Implant (with injector)</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_sleepypen=1'>Sleepy Pen</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_cloak=1'>Cloaking Device</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_sword=1'>Energy Sword</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_bomb=1'>Syndicate Bomb</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_powersink=1'>Power Sink</A> (5)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_cartridge=1'>Detomatix Cartridge</A> (3)"
			dat += "<A href='byond://?src=\ref[src];item_space=1'>Syndicate-made Space Suit (inludes a helmet)</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];item_botchat=1'>Binary Translator</A> (1)<BR>"
			dat += "<HR>"
			if (src.origradio)
				dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</A><BR>"
				dat += "<HR>"
			dat += "<A href='byond://?src=\ref[src];selfdestruct=1'>Self-Destruct</A>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/syndicate_uplink/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["item_emag"])
			if (src.uses >= 3)
				src.uses -= 3
				new /obj/item/weapon/card/emag( H.loc )
		else if (href_list["item_empbox"])
			if (src.uses >= 4)
				src.uses -= 4
				new /obj/item/weapon/storage/emp_kit( H.loc )
		else if (href_list["item_sleepypen"])
			if (src.uses >= 4)
				src.uses -= 4
				new /obj/item/weapon/pen/sleepypen( H.loc )
		else if (href_list["item_cloak"])
			if (src.uses >= 4)
				src.uses -= 4
				new /obj/item/weapon/cloaking_device( H.loc )
		else if (href_list["item_revolver"])
			if (src.uses >= 7)
				src.uses -= 7
				var/obj/item/weapon/gun/revolver/O = new /obj/item/weapon/gun/revolver(H.loc)
				O.bullets = 7
		else if (href_list["item_xbow"])
			if (src.uses >= 5)
				src.uses -= 5
				new /obj/item/weapon/gun/energy/crossbow( H.loc )
		else if (href_list["item_revolver_ammo"])
			if (src.uses >= 2)
				src.uses -= 2
				new /obj/item/weapon/ammo/a357(H.loc)
		else if (href_list["item_voice"])
			if (src.uses >= 4)
				src.uses -= 4
				new /obj/item/clothing/mask/gas/voice(H.loc)
		else if (href_list["item_jump"])
			if (src.uses >= 3)
				src.uses -= 3
				new /obj/item/clothing/under/chameleon(H.loc)
		else if (href_list["item_imp_freedom"])
			if (src.uses >= 3)
				src.uses -= 3
				var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(H.loc)
				O.imp = new /obj/item/weapon/implant/freedom(O)
				src.temp = "The implant is triggered by an emote and has a random amount of uses."
		else if (href_list["item_bomb"])
			if (src.uses >= 4)
				src.uses -= 4
				new /obj/item/weapon/plastique(H.loc)
				new /obj/item/weapon/plastique(H.loc)
		else if (href_list["item_card"])
			if (src.uses >= 3)
				src.uses -= 3
				new /obj/item/weapon/card/id/syndicate(H.loc)
		else if (href_list["item_sword"])
			if (src.uses >= 4)
				src.uses -= 4
				new /obj/item/weapon/sword(H.loc)
		else if (href_list["item_cartridge"])
			if (src.uses >= 3)
				src.uses -= 3
				new /obj/item/weapon/cartridge/syndicate(H.loc)
		else if (href_list["item_powersink"])
			if (src.uses >= 5)
				src.uses -= 5
				new /obj/item/device/powersink(H.loc)
		else if(href_list["item_space"])
			if (src.uses >= 3)
				src.uses -= 3
				new /obj/item/clothing/suit/space/syndicate(H.loc)
				new /obj/item/clothing/head/helmet/space/syndicate(H.loc)
		else if(href_list["item_botchat"])
			if (src.uses >= 1)
				src.uses -= 1
				new /obj/item/device/radio/headset/traitor(H.loc)
		else if (href_list["lock"] && src.origradio)
			// presto chango, a regular radio again! (reset the freq too...)
			usr.machine = null
			usr << browse(null, "window=radio")
			var/obj/item/device/radio/T = src.origradio
			var/obj/item/weapon/syndicate_uplink/R = src
			R.loc = T
			T.loc = usr
			// R.layer = initial(R.layer)
			R.layer = 0
			if (usr.client)
				usr.client.screen -= R
			if (usr.r_hand == R)
				usr.u_equip(R)
				usr.r_hand = T
			else
				usr.u_equip(R)
				usr.l_hand = T
			R.loc = T
			T.layer = 20
			T.set_frequency(initial(T.frequency))
			T.attack_self(usr)
			return
		else if (href_list["selfdestruct"])
			src.temp = "<A href='byond://?src=\ref[src];selfdestruct2=1'>Self-Destruct</A>"
		else if (href_list["selfdestruct2"])
			src.selfdestruct = 1
			spawn (100)
				explode()
				return
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