/obj/item/weapon/integrated_uplink
	name = "uplink module"
	desc = "An electronic uplink system of unknown origin."
	icon = 'module.dmi'
	icon_state = "power_mod"
	var/uses = 10
	var/obj/item/device/pda/hostpda = null
	var/orignote = null //Restore original notes when locked.
	var/active = 0 //Are we currently active??
	var/menu_message = ""
	var/lock_code = "password" //What's the password?

//Communicate with traitor through the PDA's note function.
/obj/item/weapon/integrated_uplink/proc/print_to_host(var/text)
	if (isnull(src.hostpda))
		return
	src.hostpda.note = text

	for (var/mob/M in viewers(1, src.hostpda.loc))
		if (M.client && M.machine == src.hostpda)
			src.hostpda.attack_self(M)

	return

//Let's build a menu!
/obj/item/weapon/integrated_uplink/proc/generate_menu()
	src.menu_message = "<B>Syndicate Uplink Console:</B><BR>"
	src.menu_message += "Tele-Crystals left: [src.uses]<BR>"
	src.menu_message += "<HR>"
	src.menu_message += "<B>Request item:</B><BR>"
	src.menu_message += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=projector'>Chameleon-projector</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=revolver'>Revolver</A> (7)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=revolver_ammo'>Ammo-357</A> for use with Revolver (2)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=xbow'>Energy Crossbow</A> (5)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=empbox'>5 EMP Grenades</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=voice'>Voice-Changer</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=jump'>Chameleon Jumpsuit</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=card'>Syndicate Card</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=emag'>Electromagnet Card</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=imp_freedom'>Freedom Implant (with injector)</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=sleepypen'>Sleepy Pen</A> (5)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=cloak'>Cloaking Device</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=sword'>Energy Sword</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=bomb'>Plastic Explosives</A> (4)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=powersink'>Power Sink</A> (5)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=detomatix'>Detomatix Cartridge</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=space'>Syndicate-made Space Suit (inludes a helmet)</A> (3)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_item=botchat'>Binary Translator</A> (4)<BR>"
	src.menu_message += "<HR>"
	return

/obj/item/weapon/integrated_uplink/proc/unlock()
	if ((isnull(src.hostpda)) || (src.active))
		return

	src.orignote = src.hostpda.note
	src.active = 1
	src.hostpda.mode = 5 //Switch right to the notes program

	src.generate_menu()
	src.print_to_host(src.menu_message)
	return

/obj/item/weapon/integrated_uplink/Topic(href, href_list)
	if ((isnull(src.hostpda)) || (!src.active))
		return

	if (usr.stat || usr.restrained() || !in_range(src.hostpda, usr))
		return

	if (href_list["buy_item"])
		switch(href_list["buy_item"])
			if("revolver")
				if (src.uses >= 7)
					src.uses -= 7
					var/obj/item/weapon/gun/revolver/O = new /obj/item/weapon/gun/revolver(get_turf(src.hostpda))
					O.bullets = 7
			if("revolver_ammo")
				if (src.uses >= 2)
					src.uses -= 2
					new /obj/item/weapon/ammo/a357(get_turf(src.hostpda))
			if("xbow")
				if (src.uses >= 5)
					src.uses -= 5
					new /obj/item/weapon/gun/energy/crossbow(get_turf(src.hostpda))
			if("empbox")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/storage/emp_kit(get_turf(src.hostpda))
			if("voice")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/clothing/mask/gas/voice(get_turf(src.hostpda))
			if("jump")
				if (src.uses >= 3)
					src.uses -= 3
					new /obj/item/clothing/under/chameleon(get_turf(src.hostpda))
			if("card")
				if (src.uses >= 3)
					src.uses -= 3
					new /obj/item/weapon/card/id/syndicate(get_turf(src.hostpda))
			if("emag")
				if (src.uses >= 3)
					src.uses -= 3
					new /obj/item/weapon/card/emag(get_turf(src.hostpda))
			if("imp_freedom")
				if (src.uses >= 3)
					src.uses -= 3
					var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(get_turf(src.hostpda))
					O.imp = new /obj/item/weapon/implant/freedom(O)
			if("sleepypen")
				if (src.uses >= 5)
					src.uses -= 5
					new /obj/item/weapon/pen/sleepypen(get_turf(src.hostpda))
			if("projector")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/device/chameleon(get_turf(src.hostpda))
			if("cloak")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/cloaking_device(get_turf(src.hostpda))
			if("sword")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/sword(get_turf(src.hostpda))
			if("bomb")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/weapon/plastique(get_turf(src.hostpda))
					new /obj/item/weapon/plastique(get_turf(src.hostpda))
			if("powersink")
				if (src.uses >= 5)
					src.uses -= 5
					new /obj/item/device/powersink(get_turf(src.hostpda))
			if("detomatix")
				if (src.uses >= 3)
				 src.uses -= 3
				 new /obj/item/weapon/cartridge/syndicate(get_turf(src.hostpda))
			if("space")
				if (src.uses >= 3)
				 src.uses -= 3
				 new /obj/item/clothing/suit/space/syndicate(get_turf(src.hostpda))
				 new /obj/item/clothing/head/helmet/space/syndicate(get_turf(src.hostpda))
			if("botchat")
				if (src.uses >= 4)
					src.uses -= 4
					new /obj/item/device/radio/headset/traitor(get_turf(src.hostpda))

		src.generate_menu()
		src.print_to_host(src.menu_message)
		return

	return