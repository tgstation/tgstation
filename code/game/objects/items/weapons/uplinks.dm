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
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=revolver'>Revolver</A> (6)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=revolver_ammo'>Ammo-357</A> for use with Revolver (2)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=xbow'>Energy Crossbow</A> (5)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=sword'>Energy Sword</A> (4)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=jump'>Chameleon Jumpsuit</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=card'>Syndicate Card</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=voice'>Voice-Changer</A> (4)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=imp_freedom'>Freedom Implant (with injector)</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=paralysispen'>Paralysis Pen</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=sleepypen'>Sleepy Pen</A> (5)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=detomatix'>Detomatix Cartridge</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=bomb'>Plastic Explosives</A> (2)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=powersink'>Power Sink</A> (5)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=space'>Syndicate-made Space Suit (inludes a helmet)</A> (3)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=projector'>Chameleon-projector</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=cloak'>Cloaking Device</A> (4)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=emag'>Electromagnet Card</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=empbox'>5 EMP Grenades</A> (4)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=botchat'>Binary Translator</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=lawmod'>Hacked AI Module</A> (7)<BR>"

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
		if (href_list["buy_item"])
			switch(href_list["buy_item"])
				if("revolver")
					if (src.uses >= 6)
						src.uses -= 6
						var/obj/item/weapon/gun/revolver/O = new /obj/item/weapon/gun/revolver(get_turf(src))
						O.bullets = 7
				if("revolver_ammo")
					if (src.uses >= 2)
						src.uses -= 2
						new /obj/item/weapon/ammo/a357(get_turf(src))
				if("xbow")
					if (src.uses >= 5)
						src.uses -= 5
						new /obj/item/weapon/gun/energy/crossbow(get_turf(src))
				if("empbox")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/weapon/storage/emp_kit(get_turf(src))
				if("voice")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/clothing/mask/gas/voice(get_turf(src))
				if("jump")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/clothing/under/chameleon(get_turf(src))
				if("card")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/weapon/card/id/syndicate(get_turf(src))
				if("emag")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/weapon/card/emag(get_turf(src))
				if("imp_freedom")
					if (src.uses >= 3)
						src.uses -= 3
						var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(get_turf(src))
						O.imp = new /obj/item/weapon/implant/freedom(O)
				if("sleepypen")
					if (src.uses >= 5)
						src.uses -= 5
						new /obj/item/weapon/pen/sleepypen(get_turf(src))
				if("paralysispen")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/device/flashlight/pen/paralysis(get_turf(src))
				if("projector")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/device/chameleon(get_turf(src))
				if("cloak")
					if (src.uses >= 4)
						var/choice = input("Spawning a cloak in nuke is generally regarded as entirely dumb, are you sure?") in list("Confirm", "Abort")
						if(choice == "Confirm")
							if (src.uses >= 4)
								src.uses -= 4
								new /obj/item/weapon/cloaking_device(get_turf(src))
				if("sword")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/weapon/sword(get_turf(src))
				if("bomb")
					if (src.uses >= 2)
						src.uses -= 2
						new /obj/item/weapon/plastique(get_turf(src))
				if("powersink")
					if (src.uses >= 5)
						src.uses -= 5
						new /obj/item/device/powersink(get_turf(src))
				if("detomatix")
					if (src.uses >= 3)
					 src.uses -= 3
					 new /obj/item/weapon/cartridge/syndicate(get_turf(src))
				if("space")
					if (src.uses >= 3)
					 src.uses -= 3
					 new /obj/item/clothing/suit/space/syndicate(get_turf(src))
					 new /obj/item/clothing/head/helmet/space/syndicate(get_turf(src))
				if("lawmod")
					if (src.uses >= 7)
						src.uses -= 7
						new /obj/item/weapon/aiModule/syndicate(get_turf(src))
				if("botchat")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/device/radio/headset/traitor(get_turf(src))
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