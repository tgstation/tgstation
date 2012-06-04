//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

SYNDICATE UPLINKS

TO-DO:
	Once wizard is fixed, make sure the uplinks work correctly for it. wizard.dm is right now uncompiled and with broken code in it.

	Clean the code up and comment it. Part of it is right now copy-pasted, with the general Topic() and modifications by Abi79.

		I should take a more in-depth look at both the copy-pasted code for the individual uplinks below, and at each gamemode's code
		to see how uplinks are assigned and if there are any bugs with those.


A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message.

*/

/obj/item/device/uplink
	var/welcome 					// Welcoming menu message
	var/menu_message = "" 			// The actual menu text
	var/items						// List of items
	var/item_data					// raw item text
	var/list/ItemList				// Parsed list of items
	var/uses 						// Numbers of crystals
	// List of items not to shove in their hands.
	var/list/NotInHand = list(/obj/machinery/singularity_beacon/syndicate)

	New()
		welcome = ticker.mode.uplink_welcome
		if(!item_data)
			items = dd_replacetext(ticker.mode.uplink_items, "\n", "")	// Getting the text string of items
		else
			items = dd_replacetext(item_data)
		ItemList = dd_text2list(src.items, ";")	// Parsing the items text string
		uses = ticker.mode.uplink_uses

//Let's build a menu!
	proc/generate_menu()
		src.menu_message = "<B>[src.welcome]</B><BR>"
		src.menu_message += "Tele-Crystals left: [src.uses]<BR>"
		src.menu_message += "<HR>"
		src.menu_message += "<B>Request item:</B><BR>"
		src.menu_message += "<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"

		var/cost
		var/item
		var/name
		var/path_obj
		var/path_text
		var/category_items = 1 //To prevent stupid :P

		for(var/D in ItemList)
			var/list/O = stringsplit(D, ":")
			if(O.len != 3)	//If it is not an actual item, make a break in the menu.
				if(O.len == 1)	//If there is one item, it's probably a title
					src.menu_message += "<b>[O[1]]</b><br>"
					category_items = 0
				else	//Else, it's a white space.
					if(category_items < 1)	//If there were no itens in the last category...
						src.menu_message += "<i>We apologize, as you could not afford anything from this category.</i><br>"
					src.menu_message += "<br>"
				continue

			path_text = O[1]
			cost = text2num(O[2])

			if(cost>uses)
				continue

			path_obj = text2path(path_text)
			item = new path_obj()
			name = O[3]
			del item

			src.menu_message += "<A href='byond://?src=\ref[src];buy_item=[path_text];cost=[cost]'>[name]</A> ([cost])<BR>"
			category_items++

		src.menu_message += "<A href='byond://?src=\ref[src];buy_item=random'>Random Item (??)</A><br>"
		src.menu_message += "<HR>"
		return

//If 'random' was selected
	proc/chooseRandomItem()
		var/list/randomItems = list()

		//Sorry for all the ifs, but it makes it 1000 times easier for other people/servers to add or remove items from this list
		//Add only items the player can afford:
		if(uses > 19)
			randomItems.Add("/obj/item/weapon/circuitboard/teleporter") //Teleporter Circuit Board (costs 20, for nuke ops)

		if(uses > 9)
			randomItems.Add("/obj/item/toy/syndicateballoon")//Syndicate Balloon
			randomItems.Add("/obj/item/weapon/storage/syndie_kit/imp_uplink") //Uplink Implanter
			randomItems.Add("/obj/item/weapon/storage/box/syndicate") //Syndicate bundle

		//if(uses > 8)	//Nothing... yet.
		//if(uses > 7)	//Nothing... yet.

		if(uses > 6)
			randomItems.Add("/obj/item/weapon/aiModule/syndicate") //Hacked AI Upload Module
			randomItems.Add("/obj/item/device/radio/beacon/syndicate") //Singularity Beacon

		if(uses > 5)
			randomItems.Add("/obj/item/weapon/gun/projectile") //Revolver

		if(uses > 4)
			randomItems.Add("/obj/item/weapon/gun/energy/crossbow") //Energy Crossbow
			randomItems.Add("/obj/item/device/powersink") //Powersink

		if(uses > 3)
			randomItems.Add("/obj/item/weapon/melee/energy/sword") //Energy Sword
			randomItems.Add("/obj/item/clothing/mask/gas/voice") //Voice Changer
			randomItems.Add("/obj/item/device/chameleon") //Chameleon Projector

		if(uses > 2)
			randomItems.Add("/obj/item/weapon/storage/emp_kit") //EMP Grenades
			randomItems.Add("/obj/item/weapon/pen/paralysis") //Paralysis Pen
			randomItems.Add("/obj/item/weapon/cartridge/syndicate") //Detomatix Cartridge
			randomItems.Add("/obj/item/clothing/under/chameleon") //Chameleon Jumpsuit
			randomItems.Add("/obj/item/weapon/card/id/syndicate") //Agent ID Card
			randomItems.Add("/obj/item/weapon/card/emag") //Cryptographic Sequencer
			randomItems.Add("/obj/item/weapon/storage/syndie_kit/space") //Syndicate Space Suit
			randomItems.Add("/obj/item/device/encryptionkey/binary") //Binary Translator Key
			randomItems.Add("/obj/item/weapon/storage/syndie_kit/imp_freedom") //Freedom Implant
			randomItems.Add("/obj/item/clothing/glasses/thermal") //Thermal Imaging Goggles

		if(uses > 1)
/*
			var/list/usrItems = usr.get_contents() //Checks to see if the user has a revolver before giving ammo
			var/hasRevolver = 0
			for(var/obj/I in usrItems) //Only add revolver ammo if the user has a gun that can shoot it
				if(istype(I,/obj/item/weapon/gun/projectile))
					hasRevolver = 1

			if(hasRevolver) randomItems.Add("/obj/item/ammo_magazine/a357") //Revolver ammo
*/
			randomItems.Add("/obj/item/ammo_magazine/a357") //Revolver ammo
			randomItems.Add("/obj/item/clothing/shoes/syndigaloshes") //No-Slip Syndicate Shoes
			randomItems.Add("/obj/item/weapon/plastique") //C4

		if(uses > 0)
			randomItems.Add("/obj/item/weapon/soap/syndie") //Syndicate Soap
			randomItems.Add("/obj/item/weapon/storage/toolbox/syndicate") //Syndicate Toolbox

		if(!randomItems)
			del(randomItems)
			return 0
		else
			var/buyItem = pick(randomItems)

			switch(buyItem) //Ok, this gets a little messy, sorry.
				if("/obj/item/weapon/circuitboard/teleporter")
					uses -= 20
				if("/obj/item/toy/syndicateballoon" , "/obj/item/weapon/storage/syndie_kit/imp_uplink" , "/obj/item/weapon/storage/box/syndicate")
					uses -= 10
				if("/obj/item/weapon/aiModule/syndicate" , "/obj/item/device/radio/beacon/syndicate")
					uses -= 7
				if("/obj/item/weapon/gun/projectile")
					uses -= 6
				if("/obj/item/weapon/gun/energy/crossbow" , "/obj/item/device/powersink")
					uses -= 5
				if("/obj/item/weapon/melee/energy/sword" , "/obj/item/clothing/mask/gas/voice" , "/obj/item/device/chameleon")
					uses -= 4
				if("/obj/item/weapon/storage/emp_kit" , "/obj/item/weapon/pen/paralysis" , "/obj/item/weapon/cartridge/syndicate" , "/obj/item/clothing/under/chameleon" , \
				"/obj/item/weapon/card/id/syndicate" , "/obj/item/weapon/card/emag" , "/obj/item/weapon/storage/syndie_kit/space" , "/obj/item/device/encryptionkey/binary" , \
				"/obj/item/weapon/storage/syndie_kit/imp_freedom" , "/obj/item/clothing/glasses/thermal")
					uses -= 3
				if("/obj/item/ammo_magazine/a357" , "/obj/item/clothing/shoes/syndigaloshes" , "/obj/item/weapon/plastique")
					uses -= 2
				if("/obj/item/weapon/soap/syndie" , "/obj/item/weapon/storage/toolbox/syndicate")
					uses -= 1
			del(randomItems)
			return buyItem

	proc/handleStatTracking(var/boughtItem)
	//For stat tracking, sorry for making it so ugly
		if(!boughtItem) return

		switch(boughtItem)
			if("/obj/item/weapon/circuitboard/teleporter")
				feedback_add_details("traitor_uplink_items_bought","TP")
			if("/obj/item/toy/syndicateballoon")
				feedback_add_details("traitor_uplink_items_bought","BS")
			if("/obj/item/weapon/storage/syndie_kit/imp_uplink")
				feedback_add_details("traitor_uplink_items_bought","UI")
			if("/obj/item/weapon/storage/box/syndicate")
				feedback_add_details("traitor_uplink_items_bought","BU")
			if("/obj/item/weapon/aiModule/syndicate")
				feedback_add_details("traitor_uplink_items_bought","AI")
			if("/obj/item/device/radio/beacon/syndicate")
				feedback_add_details("traitor_uplink_items_bought","SB")
			if("/obj/item/weapon/gun/projectile")
				feedback_add_details("traitor_uplink_items_bought","RE")
			if("/obj/item/weapon/gun/energy/crossbow")
				feedback_add_details("traitor_uplink_items_bought","XB")
			if("/obj/item/device/powersink")
				feedback_add_details("traitor_uplink_items_bought","PS")
			if("/obj/item/weapon/melee/energy/sword")
				feedback_add_details("traitor_uplink_items_bought","ES")
			if("/obj/item/clothing/mask/gas/voice")
				feedback_add_details("traitor_uplink_items_bought","VC")
			if("/obj/item/device/chameleon")
				feedback_add_details("traitor_uplink_items_bought","CP")
			if("/obj/item/weapon/storage/emp_kit")
				feedback_add_details("traitor_uplink_items_bought","EM")
			if("/obj/item/weapon/pen/paralysis")
				feedback_add_details("traitor_uplink_items_bought","PP")
			if("/obj/item/weapon/cartridge/syndicate")
				feedback_add_details("traitor_uplink_items_bought","DC")
			if("/obj/item/clothing/under/chameleon")
				feedback_add_details("traitor_uplink_items_bought","CJ")
			if("/obj/item/weapon/card/id/syndicate")
				feedback_add_details("traitor_uplink_items_bought","AC")
			if("/obj/item/weapon/card/emag")
				feedback_add_details("traitor_uplink_items_bought","EC")
			if("/obj/item/weapon/storage/syndie_kit/space")
				feedback_add_details("traitor_uplink_items_bought","SS")
			if("/obj/item/device/encryptionkey/binary")
				feedback_add_details("traitor_uplink_items_bought","BT")
			if("/obj/item/weapon/storage/syndie_kit/imp_freedom")
				feedback_add_details("traitor_uplink_items_bought","FI")
			if("/obj/item/clothing/glasses/thermal")
				feedback_add_details("traitor_uplink_items_bought","TM")
			if("/obj/item/ammo_magazine/a357")
				feedback_add_details("traitor_uplink_items_bought","RA")
			if("/obj/item/clothing/shoes/syndigaloshes")
				feedback_add_details("traitor_uplink_items_bought","SH")
			if("/obj/item/weapon/plastique")
				feedback_add_details("traitor_uplink_items_bought","C4")
			if("/obj/item/weapon/soap/syndie")
				feedback_add_details("traitor_uplink_items_bought","SP")
			if("/obj/item/weapon/storage/toolbox/syndicate")
				feedback_add_details("traitor_uplink_items_bought","ST")

	Topic(href, href_list)
		if (href_list["buy_item"])
			if(href_list["buy_item"] == "random")
				var/boughtItem = chooseRandomItem()
				if(boughtItem)
					href_list["buy_item"] = boughtItem
					feedback_add_details("traitor_uplink_items_bought","RN")
					return 1
				else
					return 0

			else
				if(text2num(href_list["cost"]) > uses) // Not enough crystals for the item
					return 0

				//if(usr:mind && ticker.mode.traitors[usr:mind])
					//var/datum/traitorinfo/info = ticker.mode.traitors[usr:mind]
					//info.spawnlist += href_list["buy_item"]

				uses -= text2num(href_list["cost"])
				handleStatTracking(href_list["buy_item"]) //Note: chooseRandomItem handles it's own stat tracking. This proc is not meant for 'random'.
			return 1


/*
 *PDA uplink
 */

//Syndicate uplink hidden inside a traitor PDA
//Communicate with traitor through the PDA's note function.

/obj/item/device/uplink/pda
	name = "uplink module"
	desc = "An electronic uplink system of unknown origin."
	icon = 'module.dmi'
	icon_state = "power_mod"
	var/obj/item/device/pda/hostpda = null

	var/orignote = null 		//Restore original notes when locked.
	var/active = 0 				//Are we currently active?
	var/lock_code = "" 	//The unlocking password.

	proc
		unlock()
			if ((isnull(src.hostpda)) || (src.active))
				return

			src.orignote = src.hostpda.note
			src.active = 1
			src.hostpda.mode = 1 //Switch right to the notes program

			src.generate_menu()
			print_to_host(menu_message)

			for (var/mob/M in viewers(1, src.hostpda.loc))
				if (M.client && M.machine == src.hostpda)
					src.hostpda.attack_self(M)

			return

		print_to_host(var/text)
			if (isnull(hostpda))
				return
			hostpda.note = text

			for (var/mob/M in viewers(1, hostpda.loc))
				if (M.client && M.machine == hostpda)
					hostpda.attack_self(M)
			return

		shutdown_uplink()
			if (isnull(src.hostpda))
				return
			active = 0
			hostpda.note = orignote
			if (hostpda.mode==1)
				hostpda.mode = 0
				hostpda.updateDialog()
			return

	attack_self(mob/user as mob)
		src.generate_menu()
		src.hostpda.note = src.menu_message


	Topic(href, href_list)
		if ((isnull(src.hostpda)) || (!src.active))
			return

		if (usr.stat || usr.restrained() || !in_range(src.hostpda, usr))
			return

		if(..() == 1) // We can afford the item
			var/path_obj = text2path(href_list["buy_item"])
			var/mob/A = src.hostpda.loc
			var/item = new path_obj(get_turf(src.hostpda))
			if(ismob(A) && !(locate(item) in NotInHand)) //&& !istype(item, /obj/spawner))
				if(!A.r_hand)
					item:loc = A
					A.r_hand = item
					item:layer = 20
				else if(!A.l_hand)
					item:loc = A
					A.l_hand = item
					item:layer = 20
			else
				item:loc = get_turf(A)
			usr.update_clothing()
	//		usr.client.onBought("[item:name]")	When we have the stats again, uncomment.
	/*		if(istype(item, /obj/spawner)) // Spawners need to have del called on them to avoid leaving a marker behind
				del item*/
	//HEADFINDBACK
		src.attack_self(usr)
		src.hostpda.attack_self(usr)
		return


/*
 *Portable radio uplink
 */

//A Syndicate uplink disguised as a portable radio
/obj/item/device/uplink/radio/implanted
	New()
		..()
		uses = 5
		return

	explode()
		var/obj/item/weapon/implant/uplink/U = src.loc
		var/mob/living/A = U.imp_in
		A.gib()
		..()
//		var/turf/location = get_turf(src.loc)
//		if(location)
//			location.hotspot_expose(700,125)
//			explosion(location, 0, 0, 2, 4, 1)

//		var/obj/item/weapon/implant/uplink/U = src.loc
//		var/mob/living/A = U.imp_in
//		var/datum/organ/external/head = A:organs["head"]
//		head.destroyed = 1
//		spawn(2)
//			head.droplimb()
//			del(src.master)
//			del(src)
//		return


/obj/item/device/uplink/radio
	name = "ship bounced radio"
	icon = 'radio.dmi'
	icon_state = "radio"
	var/temp = null 			//Temporary storage area for a message offering the option to destroy the radio
	var/selfdestruct = 0		//Set to 1 while the radio is self destructing itself.
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	item_state = "radio"
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 100

	attack_self(mob/user as mob)
		var/dat

		if (src.selfdestruct)
			dat = "Self Destructing..."
		else
			if (src.temp)
				dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];clear_selfdestruct=1'>Clear</A>"
			else
				src.generate_menu()
				dat = src.menu_message
				if (src.origradio) // Checking because sometimes the radio uplink may be spawned by itself, not as a normal unlockable radio
					dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</A><BR>"
					dat += "<HR>"
				dat += "<A href='byond://?src=\ref[src];selfdestruct=1'>Self-Destruct</A>"

		user << browse(dat, "window=radio")
		onclose(user, "radio")
		return

	Topic(href, href_list)
		if (usr.stat || usr.restrained())
			return

		if (!( istype(usr, /mob/living/carbon/human)))
			return 1

		if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf)) || istype(src.loc,/obj/item/weapon/implant/uplink)))
			usr.machine = src

			if(href_list["buy_item"])
				if(..() == 1) // We can afford the item
					var/path_obj = text2path(href_list["buy_item"])
					var/item = new path_obj(get_turf(src.loc))
					var/mob/A = src.loc
					if(istype(src.loc,/obj/item/weapon/implant/uplink))
						var/obj/item/weapon/implant/uplink/U = src.loc
						A = U.imp_in
					if(ismob(A) && !(locate(item) in NotInHand)) //&& !istype(item, /obj/spawner))
						if(!A.r_hand)
							item:loc = A
							A.r_hand = item
							item:layer = 20
						else if(!A.l_hand)
							item:loc = A
							A.l_hand = item
							item:layer = 20
					else
						item:loc = get_turf(A)
	/*				if(istype(item, /obj/spawner)) // Spawners need to have del called on them to avoid leaving a marker behind
						del item*/
	//				usr.client.onBought("[item:name]")	When we have the stats again, uncomment.
				src.attack_self(usr)
				return

			else if (href_list["lock"] && src.origradio)
				// presto chango, a regular radio again! (reset the freq too...)
				usr.machine = null
				usr << browse(null, "window=radio")
				var/obj/item/device/radio/T = src.origradio
				var/obj/item/device/uplink/radio/R = src
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

			else if (href_list["clear_selfdestruct"])
				src.temp = null

			attack_self(usr)
//			if (istype(src.loc, /mob))
//				attack_self(src.loc)
//			else
//				for(var/mob/M in viewers(1, src))
//					if (M.client)
//						src.attack_self(M)
		return

	proc/explode()
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(700,125)
			explosion(location, 0, 0, 2, 4, 1)

		del(src.master)
		del(src)
		return

	proc/shutdown_uplink()
		if (!src.origradio)
			return
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if (M.client && M.machine == src)
				M << browse(null, "window=radio")
				M.machine = null

		var/obj/item/device/radio/T = src.origradio
		var/obj/item/device/uplink/radio/R = src
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