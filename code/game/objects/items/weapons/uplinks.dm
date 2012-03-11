/*
CONTAINS:
SYNDICATE UPLINK
*/

/obj/item/weapon/syndicate_uplink/implanted
	uses = 5

/obj/item/weapon/syndicate_uplink/proc/explode()
	var/turf/location = get_turf(src.loc)
	if(location)
		location.hotspot_expose(700,125)

		explosion(location, 0, 0, 2, 4)

	del(src.master)
	del(src)
	return

/obj/item/weapon/syndicate_uplink/attack_self(mob/user as mob)
	currentUser = user
	user.machine = src
	var/dat
	if (src.selfdestruct)
		dat = "Self Destructing..."
	else
		if (src.temp)
			dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
		else
			dat = "<B>Syndicate Uplink Access:</B><BR>"
			dat += "Tele-Crystals left: [src.uses]<BR>"
			dat += "<HR>"
			dat += "<B>Request item:</B><BR>"
			dat += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=revolver'>Revolver</A> (6)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=revolver_ammo'>Ammo-357</A> for use with Revolver (2)<BR>"
//			dat += "<A href='byond://?src=\ref[src];buy_item=suffocation_revolver_ammo'>Ammo-418</A> for use with Revolver (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=xbow'>Energy Crossbow</A> (5)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=sword'>Energy Sword</A> (4)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=jump'>Chameleon Jumpsuit</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=shoes'>Syndicate Shoes</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=card'>Syndicate Card</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=voice'>Voice-Changer</A> (4)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=imp_freedom'>Freedom Implant (with injector)</A> (3)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=paralysispen'>Paralysis Pen</A> (3)<BR>" //Note that this goes to the updated sleepypen now.
//			dat += "<A href='byond://?src=\ref[src];buy_item=sleepypen'>Sleepy Pen</A> (5)<BR>" //Terrible -Pete.
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
			dat += "<A href='byond://?src=\ref[src];buy_item=teleport'>Teleporter Circuit Board</A> (10)<BR>"
			dat += "<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=toolbox'>Syndicate Toolbox</A> (Includes various tools) (1)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=soap'>Syndicate Soap</A> (1)<BR>"
			dat += "<A href='byond://?src=\ref[src];buy_item=balloon'>Syndicate Balloon</A> (Useless) (10)<BR>"
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
	if(!currentUser)
		return
	if (currentUser.stat || currentUser.restrained())
		return
	if (!( istype(currentUser, /mob/living/carbon/human)))
		return
	if ((currentUser.contents.Find(src) || (in_range(src, currentUser) && istype(src.loc, /turf))) || istype(src,/obj/item/weapon/syndicate_uplink/implanted))
		currentUser.machine = src
		if (href_list["buy_item"])
			switch(href_list["buy_item"])
				if("revolver")
					if (src.uses >= 6)
						src.uses -= 6
						new /obj/item/weapon/gun/projectile(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","RE")
				if("revolver_ammo")
					if (src.uses >= 2)
						src.uses -= 2
						new /obj/item/ammo_magazine/a357(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","RA")
				if("suffocation_revolver_ammo")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/ammo_magazine/a418(get_turf(src))
				if("xbow")
					if (src.uses >= 5)
						src.uses -= 5
						new /obj/item/weapon/gun/energy/crossbow(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","XB")
				if("empbox")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/weapon/storage/emp_kit(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","EM")
				if("voice")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/clothing/mask/gas/voice(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","VC")
				if("jump")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/clothing/under/chameleon(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","CJ")
				if("shoes")
					if (uses >= 3)
						uses -= 3
						new /obj/item/clothing/shoes/syndigaloshes(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","SH")
				if("card")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/weapon/card/id/syndicate(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","AC")
				if("emag")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/weapon/card/emag(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","EC")
				if("imp_freedom")
					if (src.uses >= 3)
						src.uses -= 3
						var/obj/item/weapon/implanter/O = new /obj/item/weapon/implanter(get_turf(src))
						O.imp = new /obj/item/weapon/implant/freedom(O)
						feedback_add_details("traitor_uplink_items_bought","FI")
				if("sleepypen")
					if (src.uses >= 5)
						src.uses -= 5
						new /obj/item/weapon/pen/sleepypen(get_turf(src))
				if("paralysispen")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/weapon/pen/paralysis(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","PP")
				if("projector")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/device/chameleon(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","CP")
				if("lawmod")
					if (src.uses >= 7)
						src.uses -= 7
						new /obj/item/weapon/aiModule/syndicate(get_turf(src))
				if("cloak")
					if (src.uses >= 4)
						if (ticker.mode.config_tag!="nuclear" || \
							(input(currentUser,"Spawning a cloak in nuke is generally regarded as entirely dumb, are you sure?") in list("Confirm", "Abort")) == "Confirm" \
						)
							if (src.uses >= 4)
								src.uses -= 4
								new /obj/item/weapon/cloaking_device(get_turf(src))
								feedback_add_details("traitor_uplink_items_bought","CD")
				if("sword")
					if (src.uses >= 4)
						src.uses -= 4
						new /obj/item/weapon/melee/energy/sword(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","ES")
				if("bomb")
					if (src.uses >= 2)
						src.uses -= 2
						new /obj/item/weapon/plastique(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","C4")
				if("powersink")
					if (src.uses >= 5)
						src.uses -= 5
						new /obj/item/device/powersink(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","PS")
				if("detomatix")
					if (src.uses >= 3)
					 src.uses -= 3
					 new /obj/item/weapon/cartridge/syndicate(get_turf(src))
					 feedback_add_details("traitor_uplink_items_bought","DC")
				if("space")
					if (src.uses >= 3)
					 src.uses -= 3
					 new /obj/item/clothing/suit/space/syndicate(get_turf(src))
					 new /obj/item/clothing/head/helmet/space/syndicate(get_turf(src))
					 feedback_add_details("traitor_uplink_items_bought","SS")
				if("botchat")
					if (src.uses >= 3)
						src.uses -= 3
						new /obj/item/device/radio/headset/binary(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","BT")
				if("toolbox")
					if(uses)
						uses--
						new /obj/item/weapon/storage/toolbox/syndicate(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","ST")
				if("soap")
					if(uses)
						uses--
						new /obj/item/weapon/soap/syndie(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","SP")
				if("balloon")
					if (src.uses >= 10)
						uses -= 10
						new /obj/item/toy/syndicateballoon(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","BS")
				if("teleport")
					if (src.uses >= 10)
						uses -= 10
						new /obj/item/weapon/circuitboard/teleporter(get_turf(src))
						feedback_add_details("traitor_uplink_items_bought","TP")
		else if (href_list["lock"] && src.origradio)
			// presto chango, a regular radio again! (reset the freq too...)
			shutdown_uplink()
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

/obj/item/weapon/syndicate_uplink/proc/shutdown_uplink()
	if (!src.origradio)
		return
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if (M.client && M.machine == src)
			M << browse(null, "window=radio")
			M.machine = null

	var/obj/item/device/radio/T = src.origradio
	var/obj/item/weapon/syndicate_uplink/R = src
	var/mob/L = src.loc
	R.loc = T
	T.loc = L
	// R.layer = initial(R.layer)
	R.layer = 0
	if (istype(L))
		if (L.client)
			L.client.screen -= R
		if (L.r_hand == R)
			L.u_equip(R)
			L.r_hand = T
		else
			L.u_equip(R)
			L.l_hand = T
		T.layer = 20
	T.set_frequency(initial(T.frequency))
	return
