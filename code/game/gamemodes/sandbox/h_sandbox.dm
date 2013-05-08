//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/hsboxspawn = 1

mob
	var/datum/hSB/sandbox = null
	proc
		CanBuild()
			if(master_mode == "sandbox")
				sandbox = new/datum/hSB
				sandbox.owner = src.ckey
				if(src.client.holder)
					sandbox.admin = 1
				verbs += new/mob/proc/sandbox_panel
		sandbox_panel()
			set name = "Sandbox Panel"
			if(sandbox)
				sandbox.update()

datum/hSB
	var/owner = null
	var/admin = 0

	var/objinfo = null
	var/canisterinfo = null
	var/hsbinfo = null

	var/global/list/spawn_forbidden = list(/obj/item/weapon/grab, /obj/item/tk_grab, /obj/item/weapon/dummy, /obj/item/assembly,/obj/item/device/onetankbomb)

	proc
		update()
			var/global/list/hrefs = list(
					"Space Gear",
					"Suit Up (Space Travel Gear)"		= "hsbsuit",
					"Spawn Gas Mask"					= "hsbspawn&path=[/obj/item/clothing/mask/gas]",
					"Spawn Emergency Air Tank"			= "hsbspawn&path=[/obj/item/weapon/tank/emergency_oxygen/double]",

					"Standard Tools",
					"Spawn Flashlight"					= "hsbspawn&path=[/obj/item/device/flashlight]",
					"Spawn Toolbox"						= "hsbspawn&path=[/obj/item/weapon/storage/toolbox/mechanical]",
					"Spawn Light Replacer"				= "hsbspawn&path=[/obj/item/device/lightreplacer]",
					"Spawn Rapid Construction Device"	= "hsbrcd",
					"Spawn RCD Ammo"					= "hsbspawn&path=[/obj/item/weapon/rcd_ammo]",
					"Spawn Medical Kit"					= "hsbspawn&path=[/obj/item/weapon/storage/firstaid/regular]",
					"Spawn All-Access ID"				= "hsbaaid",

					"Building Supplies",
					"Spawn 50 Metal"					= "hsbmetal",
					"Spawn 50 Plasteel"					= "hsbplasteel",
					"Spawn 50 Glass"					= "hsbglass",
					"Spawn Full Cable Coil"				= "hsbspawn&path=[/obj/item/weapon/cable_coil]",
					"Spawn Hyper Capacity Power Cell"	= "hsbspawn&path=[/obj/item/weapon/cell/hyper]",
					"Spawn Airlock"						= "hsbairlock",

					"Miscellaneous",
					"Spawn Air Scrubber"				= "hsbscrubber",
					"Spawn Canister"					= "hsbcanister",
					"Spawn Welding Fuel Tank"			= "hsbspawn&path=[/obj/structure/reagent_dispensers/fueltank]",
					"Spawn Water Tank"					= "hsbspawn&path=[/obj/structure/reagent_dispensers/watertank]",

					"Bots",
					"Spawn Floorbot"					= "hsbspawn&path=[/obj/machinery/bot/floorbot]",
					"Spawn Medbot"						= "hsbspawn&path=[/obj/machinery/bot/medbot]")

			if(!hsbinfo)
				hsbinfo = "<center><b>Sandbox Panel</b></center><hr>"
				if(admin)
					hsbinfo += "<b>Administration</b><br>"
					hsbinfo += "- <a href='?src=\ref[src];hsb=hsbtobj'>Toggle Object Spawning</a><br>"
					hsbinfo += "- <a href='?src=\ref[src];hsb=hsbtac'>Toggle Item Spawn Panel Auto-close</a><hr>"
				for(var/T in hrefs)
					var/href = hrefs[T]
					if(href)
						hsbinfo += "- <a href=\"?\ref[src];hsb=[hrefs[T]]\">[T]</a><br>"
					else
						hsbinfo += "<br><b>[T]</b><br>"
				if(hsboxspawn)
					hsbinfo += "<hr>- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Other Item</a><br><br>"

			usr << browse(hsbinfo, "window=hsbpanel")

	Topic(href, href_list)
		if(!usr || !src || !(src.owner == usr.ckey))
			if(usr)
				usr << browse(null,"window=sandbox")
			return

		if(href_list["hsb"])
			switch(href_list["hsb"])
				//
				// Admin: toggle spawning
				//
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						world << "<b>\red Sandbox:  \black[usr.key] has disabled object spawning!</b>"
						hsboxspawn = 0
						return
					else
						world << "<b>\blue Sandbox:  \black[usr.key] has enabled object spawning!</b>"
						hsboxspawn = 1
						return
				//
				// Admin: Toggle auto-close
				//
				if("hsbtac")
					if(!admin) return
					if(config.sandbox_autoclose)
						world << "<b>\blue Sandbox:  \black [usr.key] has removed the object spawn limiter.</b>"
						config.sandbox_autoclose = 0
					else
						world << "<b>\red Sandbox:  \black [usr.key] has added a limiter to object spawning.  The window will now auto-close after use.</b>"
						config.sandbox_autoclose = 1
					return

				//
				// Spacesuit with full air jetpack set as internals
				//
				if("hsbsuit")
					var/mob/living/carbon/human/P = usr
					if(!istype(P)) return
					if(P.wear_suit)
						P.wear_suit.loc = P.loc
						P.wear_suit.layer = initial(P.wear_suit.layer)
						P.wear_suit = null
					P.wear_suit = new/obj/item/clothing/suit/space(P)
					P.wear_suit.layer = 20
					P.update_inv_wear_suit()
					if(P.head)
						P.head.loc = P.loc
						P.head.layer = initial(P.head.layer)
						P.head = null
					P.head = new/obj/item/clothing/head/helmet/space(P)
					P.head.layer = 20
					P.update_inv_head()
					if(P.wear_mask)
						P.wear_mask.loc = P.loc
						P.wear_mask.layer = initial(P.wear_mask.layer)
						P.wear_mask = null
					P.wear_mask = new/obj/item/clothing/mask/gas(P)
					P.wear_mask.layer = 20
					P.update_inv_wear_mask()
					if(P.back)
						P.back.loc = P.loc
						P.back.layer = initial(P.back.layer)
						P.back = null
					P.back = new/obj/item/weapon/tank/jetpack/oxygen(P)
					P.back.layer = 20
					P.update_inv_back()
					P.internal = P.back
					if(P.internals)
						P.internals.icon_state = "internal1"

				if("hsbscrubber") // This is beyond its normal capability but this is sandbox and you spawned one, I assume you need it
					var/obj/hsb = new/obj/machinery/portable_atmospherics/scrubber{volume_rate=50*ONE_ATMOSPHERE;on=1}(usr.loc)
					hsb.update_icon() // hackish but it wasn't meant to be spawned I guess?

				if("hsbmetal")
					new/obj/item/stack/sheet/metal{amount=50}(usr.loc)

				if("hsbplasteel")
					new/obj/item/stack/sheet/plasteel{amount=50}(usr.loc)

				if("hsbglass")
					new/obj/item/stack/sheet/glass{amount=50}(usr.loc)

				if("hsbaaid")
					var/obj/item/weapon/card/id/gold/ID = new(usr.loc)
					ID.registered_name = usr.real_name
					ID.assignment = "Sandbox"
					ID.access = get_all_accesses()
					ID.name = "[ID.registered_name]'s ID Card ([ID.assignment])"

				if("hsbrcd")
					new/obj/item/weapon/rcd{matter=30;canRwall=1}(usr.loc)

				//
				// New sandbox airlock maker
				//
				if("hsbairlock")
					new /datum/airlock_maker(usr.loc)

				//
				// Canister select window
				//
				if("hsbcanister")
					if(!canisterinfo)
						canisterinfo = "Choose a canister type:<hr>"
						for(var/O in (typesof(/obj/machinery/portable_atmospherics/canister/) - /obj/machinery/portable_atmospherics/canister/))
							canisterinfo += "<a href='?src=\ref[src];hsb=hsbspawn&path=[O]'>[O]</a><br>"
					usr << browse(canisterinfo,"window=sandbox")

				//
				// Object spawn window
				//
				if("hsbobj")
					if(!hsboxspawn) return

					if(!objinfo)
						objinfo = "Items:<hr><br>"
						for(var/O in reverselist(typesof(/obj/item/)))
							var/allow = 1
							for(var/typekey in spawn_forbidden)
								if(ispath(O,typekey))
									allow = 0
									break
							if(!allow)
								continue
							objinfo += "<a href='?src=\ref[src];hsb=hsb_safespawn&path=[O]'>[O]</a><br>"

					usr << browse(objinfo,"window=sandbox")

				//
				// For the object spawn specifically, checks to see if it is turned off
				//
				if("hsb_safespawn")
					if(!hsboxspawn)
						usr << browse(null,"window=sandbox")
						return

					var/typepath = text2path(href_list["path"])
					if(!typepath)
						usr << "Bad path: \"[href_list["path"]]\""
						return
					new typepath(usr.loc)

					if(config.sandbox_autoclose)
						usr << browse(null,"window=sandbox")
				//
				// For everything else in the href list
				//
				if("hsbspawn")
					var/typepath = text2path(href_list["path"])
					if(!typepath)
						usr << "Bad path: \"[href_list["path"]]\""
						return
					new typepath(usr.loc)

					if(config.sandbox_autoclose)
						usr << browse(null,"window=sandbox")
