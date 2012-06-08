//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

var/hsboxspawn = 1
var/list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbairlock" = "Spawn Airlock",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit")

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
			if(sandbox)
				sandbox.update()

datum/hSB
	var/owner = null
	var/admin = 0
	proc
		update()
			var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
			if(admin)
				hsbpanel += "<b>Administration Tools:</b><br>"
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"
			hsbpanel += "<b>Regular Tools:</b><br>"
			for(var/T in hrefs)
				hsbpanel += "- <a href=\"?\ref[src];hsb=[T]\">[hrefs[T]]</a><br>"
			if(hsboxspawn)
				hsbpanel += "- <a href=\"?\ref[src];hsb=hsbobj\">Spawn Object</a><br><br>"
			usr << browse(hsbpanel, "window=hsbpanel")
	Topic(href, href_list)
		if(!(src.owner == usr.ckey)) return
		if(!usr) return //I guess this is possible if they log out or die with the panel open? It happened.
		if(href_list["hsb"])
			switch(href_list["hsb"])
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						world << "<b>Sandbox:  [usr.key] has disabled object spawning!</b>"
						hsboxspawn = 0
						return
					if(!hsboxspawn)
						world << "<b>Sandbox:  [usr.key] has enabled object spawning!</b>"
						hsboxspawn = 1
						return
				if("hsbsuit")
					var/mob/living/carbon/human/P = usr
					if(P.wear_suit)
						P.wear_suit.loc = P.loc
						P.wear_suit.layer = initial(P.wear_suit.layer)
						P.wear_suit = null
					P.wear_suit = new/obj/item/clothing/suit/space(P)
					P.wear_suit.layer = 20
					if(P.head)
						P.head.loc = P.loc
						P.head.layer = initial(P.head.layer)
						P.head = null
					P.head = new/obj/item/clothing/head/helmet/space(P)
					P.head.layer = 20
					if(P.wear_mask)
						P.wear_mask.loc = P.loc
						P.wear_mask.layer = initial(P.wear_mask.layer)
						P.wear_mask = null
					P.wear_mask = new/obj/item/clothing/mask/gas(P)
					P.wear_mask.layer = 20
					if(P.back)
						P.back.loc = P.loc
						P.back.layer = initial(P.back.layer)
						P.back = null
					P.back = new/obj/item/weapon/tank/jetpack/oxygen(P)
					P.back.layer = 20
					P.internal = P.back
				if("hsbmetal")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/metal
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbglass")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/glass
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbairlock")
					var/obj/machinery/door/hsb = new/obj/machinery/door/airlock

					//TODO: DEFERRED make this better, with an HTML window or something instead of 15 popups
					hsb.req_access = list()
					var/accesses = get_all_accesses()
					for(var/A in accesses)
						if(alert(usr, "Will this airlock require [get_access_desc(A)] access?", "Sandbox:", "Yes", "No") == "Yes")
							hsb.req_access += A

					hsb.loc = usr.loc
					usr << "<b>Sandbox:  Created an airlock."
				if("hsbcanister")
					var/list/hsbcanisters = typesof(/obj/machinery/portable_atmospherics/canister/) - /obj/machinery/portable_atmospherics/canister/
					var/hsbcanister = input(usr, "Choose a canister to spawn.", "Sandbox:") in hsbcanisters + "Cancel"
					if(!(hsbcanister == "Cancel"))
						new hsbcanister(usr.loc)
				if("hsbfueltank")
					//var/obj/hsb = new/obj/weldfueltank
					//hsb.loc = usr.loc
				if("hsbwatertank")
					//var/obj/hsb = new/obj/watertank
					//hsb.loc = usr.loc
				if("hsbtoolbox")
					var/obj/item/weapon/storage/hsb = new/obj/item/weapon/storage/toolbox/mechanical
					for(var/obj/item/device/radio/T in hsb)
						del(T)
					new/obj/item/weapon/crowbar (hsb)
					hsb.loc = usr.loc
				if("hsbmedkit")
					var/obj/item/weapon/storage/firstaid/hsb = new/obj/item/weapon/storage/firstaid/regular
					hsb.loc = usr.loc
				if("hsbobj")
					if(!hsboxspawn) return

					var/list/selectable = list()
					for(var/O in typesof(/obj/item/))
					//Note, these istypes don't work
						if(istype(O, /obj/item/weapon/gun))
							continue
						if(istype(O, /obj/item/assembly))
							continue
						if(istype(O, /obj/item/weapon/camera))
							continue
						if(istype(O, /obj/item/weapon/cloaking_device))
							continue
						if(istype(O, /obj/item/weapon/dummy))
							continue
						if(istype(O, /obj/item/weapon/melee/energy/sword))
							continue
						if(istype(O, /obj/effect/critter))
							continue
						if(istype(O, /obj/structure))
							continue
						selectable += O

					var/hsbitem = input(usr, "Choose an object to spawn.", "Sandbox:") in selectable + "Cancel"
					if(hsbitem != "Cancel")
						new hsbitem(usr.loc)
