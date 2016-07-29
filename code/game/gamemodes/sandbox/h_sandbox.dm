<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/hsboxspawn = 1

/mob
	var/datum/hSB/sandbox = null
/mob/proc/CanBuild()
	if(master_mode == "sandbox")
		sandbox = new/datum/hSB
		sandbox.owner = src.ckey
		if(src.client.holder)
			sandbox.admin = 1
		verbs += new/mob/proc/sandbox_panel
/mob/proc/sandbox_panel()
	set name = "Sandbox Panel"
	if(sandbox)
		sandbox.update()

/datum/hSB
	var/owner = null
	var/admin = 0

	var/clothinfo = null
	var/reaginfo = null
	var/objinfo = null
	var/canisterinfo = null
	var/hsbinfo = null
	//items that shouldn't spawn on the floor because they would bug or act weird
	var/global/list/spawn_forbidden = list(
		/obj/item/tk_grab, /obj/item/weapon/implant, // not implanter, the actual thing that is inside you
		/obj/item/assembly,/obj/item/device/onetankbomb, /obj/item/radio, /obj/item/device/pda/ai,
		/obj/item/device/uplink, /obj/item/smallDelivery, /obj/item/missile,/obj/item/projectile,
		/obj/item/borg/sight,/obj/item/borg/stun,/obj/item/weapon/robot_module)

/datum/hSB/proc/update()
	var/global/list/hrefs = list(
			"Space Gear",
			"Suit Up (Space Travel Gear)"		= "hsbsuit",
			"Spawn Gas Mask"					= "hsbspawn&path=[/obj/item/clothing/mask/gas]",
			"Spawn Emergency Air Tank"			= "hsbspawn&path=[/obj/item/weapon/tank/internals/emergency_oxygen/double]",

			"Standard Tools",
			"Spawn Flashlight"					= "hsbspawn&path=[/obj/item/device/flashlight]",
			"Spawn Toolbox"						= "hsbspawn&path=[/obj/item/weapon/storage/toolbox/mechanical]",
			"Spawn Light Replacer"				= "hsbspawn&path=[/obj/item/device/lightreplacer]",
			"Spawn Medical Kit"					= "hsbspawn&path=[/obj/item/weapon/storage/firstaid/regular]",
			"Spawn All-Access ID"				= "hsbaaid",

			"Building Supplies",
			"Spawn 50 Wood"                     = "hsbwood",
			"Spawn 50 Metal"					= "hsbmetal",
			"Spawn 50 Plasteel"					= "hsbplasteel",
			"Spawn 50 Reinforced Glass"         = "hsbrglass",
			"Spawn 50 Glass"					= "hsbglass",
			"Spawn Full Cable Coil"				= "hsbspawn&path=[/obj/item/stack/cable_coil]",
			"Spawn Hyper Capacity Power Cell"	= "hsbspawn&path=[/obj/item/weapon/stock_parts/cell/hyper]",
			"Spawn Inf. Capacity Power Cell"	= "hsbspawn&path=[/obj/item/weapon/stock_parts/cell/infinite]",
			"Spawn Rapid Construction Device"	= "hsbrcd",
			"Spawn RCD Ammo"					= "hsb_safespawn&path=[/obj/item/weapon/rcd_ammo]",
			"Spawn Airlock"						= "hsbairlock",

			"Miscellaneous",
			"Spawn Air Scrubber"				= "hsbscrubber",
			"Spawn Welding Fuel Tank"			= "hsbspawn&path=[/obj/structure/reagent_dispensers/fueltank]",
			"Spawn Water Tank"					= "hsbspawn&path=[/obj/structure/reagent_dispensers/watertank]",

			"Bots",
			"Spawn Cleanbot"					= "hsbspawn&path=[/mob/living/simple_animal/bot/cleanbot]",
			"Spawn Floorbot"					= "hsbspawn&path=[/mob/living/simple_animal/bot/floorbot]",
			"Spawn Medbot"						= "hsbspawn&path=[/mob/living/simple_animal/bot/medbot]",

			"Canisters",
			"Spawn O2 Canister" 				= "hsbspawn&path=[/obj/machinery/portable_atmospherics/canister/oxygen]",
			"Spawn Air Canister"				= "hsbspawn&path=[/obj/machinery/portable_atmospherics/canister/air]")


	if(!hsbinfo)
		hsbinfo = "<center><b>Sandbox Panel</b></center><hr>"
		if(admin)
			hsbinfo += "<b>Administration</b><br>"
			hsbinfo += "- <a href='?src=\ref[src];hsb=hsbtobj'>Toggle Object Spawning</a><br>"
			hsbinfo += "- <a href='?src=\ref[src];hsb=hsbtac'>Toggle Item Spawn Panel Auto-close</a><br>"
			hsbinfo += "<b>Canister Spawning</b><br>"
			hsbinfo += "- <a href='?src=\ref[src];hsb=hsbspawn&path=[/obj/machinery/portable_atmospherics/canister/toxins]'>Spawn Plasma Canister</a><br>"
			hsbinfo += "- <a href='?src=\ref[src];hsb=hsbspawn&path=[/obj/machinery/portable_atmospherics/canister/carbon_dioxide]'>Spawn CO2 Canister</a><br>"
			hsbinfo += "- <a href='?src=\ref[src];hsb=hsbspawn&path=[/obj/machinery/portable_atmospherics/canister/nitrogen]'>Spawn Nitrogen Canister</a><br>"
			hsbinfo += "- <a href='?src=\ref[src];hsb=hsbspawn&path=[/obj/machinery/portable_atmospherics/canister/nitrous_oxide]'>Spawn N2O Canister</a><hr>"
		else
			hsbinfo += "<i>Some item spawning may be disabled by the administrators.</i><br>"
			hsbinfo += "<i>Only administrators may spawn dangerous canisters.</i><br>"
		for(var/T in hrefs)
			var/href = hrefs[T]
			if(href)
				hsbinfo += "- <a href='?\ref[src];hsb=[hrefs[T]]'>[T]</a><br>"
			else
				hsbinfo += "<br><b>[T]</b><br>"
		hsbinfo += "<hr>"
		hsbinfo += "- <a href='?\ref[src];hsb=hsbcloth'>Spawn Clothing...</a><br>"
		hsbinfo += "- <a href='?\ref[src];hsb=hsbreag'>Spawn Reagent Container...</a><br>"
		hsbinfo += "- <a href='?\ref[src];hsb=hsbobj'>Spawn Other Item...</a><br><br>"

	usr << browse(hsbinfo, "window=hsbpanel")

/datum/hSB/Topic(href, href_list)
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
					world << "<span class='boldannounce'>Sandbox:</span> <b>\black[usr.key] has disabled object spawning!</b>"
					hsboxspawn = 0
					return
				else
					world << "<span class='boldnotice'>Sandbox:</span> <b>\black[usr.key] has enabled object spawning!</b>"
					hsboxspawn = 1
					return
			//
			// Admin: Toggle auto-close
			//
			if("hsbtac")
				if(!admin) return
				if(config.sandbox_autoclose)
					world << "<span class='boldnotice'>Sandbox:</span> <b>\black [usr.key] has removed the object spawn limiter.</b>"
					config.sandbox_autoclose = 0
				else
					world << "<span class='danger'>Sandbox:</span> <b>\black [usr.key] has added a limiter to object spawning.  The window will now auto-close after use.</b>"
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
				P.wear_suit.layer = ABOVE_HUD_LAYER
				P.update_inv_wear_suit()
				if(P.head)
					P.head.loc = P.loc
					P.head.layer = initial(P.head.layer)
					P.head = null
				P.head = new/obj/item/clothing/head/helmet/space(P)
				P.head.layer = ABOVE_HUD_LAYER
				P.update_inv_head()
				if(P.wear_mask)
					P.wear_mask.loc = P.loc
					P.wear_mask.layer = initial(P.wear_mask.layer)
					P.wear_mask = null
				P.wear_mask = new/obj/item/clothing/mask/gas(P)
				P.wear_mask.layer = ABOVE_HUD_LAYER
				P.update_inv_wear_mask()
				if(P.back)
					P.back.loc = P.loc
					P.back.layer = initial(P.back.layer)
					P.back = null
				P.back = new/obj/item/weapon/tank/jetpack/oxygen(P)
				P.back.layer = ABOVE_HUD_LAYER
				P.update_inv_back()
				P.internal = P.back
				P.update_internals_hud_icon(1)

			if("hsbscrubber") // This is beyond its normal capability but this is sandbox and you spawned one, I assume you need it
				var/obj/hsb = new/obj/machinery/portable_atmospherics/scrubber{volume_rate=50*ONE_ATMOSPHERE;on=1}(usr.loc)
				hsb.update_icon() // hackish but it wasn't meant to be spawned I guess?

			//
			// Stacked Materials
			//

			if("hsbrglass")
				new/obj/item/stack/sheet/rglass{amount=50}(usr.loc)

			if("hsbmetal")
				new/obj/item/stack/sheet/metal{amount=50}(usr.loc)

			if("hsbplasteel")
				new/obj/item/stack/sheet/plasteel{amount=50}(usr.loc)

			if("hsbglass")
				new/obj/item/stack/sheet/glass{amount=50}(usr.loc)

			if("hsbwood")
				new/obj/item/stack/sheet/mineral/wood{amount=50}(usr.loc)

			//
			// All access ID
			//
			if("hsbaaid")
				var/obj/item/weapon/card/id/gold/ID = new(usr.loc)
				ID.registered_name = usr.real_name
				ID.assignment = "Sandbox"
				ID.access = get_all_accesses()
				ID.update_label()

			//
			// RCD - starts with full clip
			// Spawn check due to grief potential (destroying floors, walls, etc)
			//
			if("hsbrcd")
				if(!hsboxspawn) return

				new/obj/item/weapon/rcd/combat(usr.loc)

			//
			// New sandbox airlock maker
			//
			if("hsbairlock")
				new /datum/airlock_maker(usr.loc)

			//
			// Object spawn window
			//

			// Clothing
			if("hsbcloth")
				if(!hsboxspawn) return

				if(!clothinfo)
					clothinfo = "<b>Clothing</b> <a href='?\ref[src];hsb=hsbreag'>(Reagent Containers)</a> <a href='?\ref[src];hsb=hsbobj'>(Other Items)</a><hr><br>"
					var/list/all_items = subtypesof(/obj/item/clothing)
					for(var/typekey in spawn_forbidden)
						all_items -= typesof(typekey)
					for(var/O in reverseRange(all_items))
						clothinfo += "<a href='?src=\ref[src];hsb=hsb_safespawn&path=[O]'>[O]</a><br>"

				usr << browse(clothinfo,"window=sandbox")

			// Reagent containers
			if("hsbreag")
				if(!hsboxspawn) return

				if(!reaginfo)
					reaginfo = "<b>Reagent Containers</b> <a href='?\ref[src];hsb=hsbcloth'>(Clothing)</a> <a href='?\ref[src];hsb=hsbobj'>(Other Items)</a><hr><br>"
					var/list/all_items = subtypesof(/obj/item/weapon/reagent_containers)
					for(var/typekey in spawn_forbidden)
						all_items -= typesof(typekey)
					for(var/O in reverseRange(all_items))
						reaginfo += "<a href='?src=\ref[src];hsb=hsb_safespawn&path=[O]'>[O]</a><br>"

				usr << browse(reaginfo,"window=sandbox")

			// Other items
			if("hsbobj")
				if(!hsboxspawn) return

				if(!objinfo)
					objinfo = "<b>Other Items</b> <a href='?\ref[src];hsb=hsbcloth'>(Clothing)</a> <a href='?\ref[src];hsb=hsbreag'>(Reagent Containers)</a><hr><br>"
					var/list/all_items = subtypesof(/obj/item/) - typesof(/obj/item/clothing) - typesof(/obj/item/weapon/reagent_containers)
					for(var/typekey in spawn_forbidden)
						all_items -= typesof(typekey)

					for(var/O in reverseRange(all_items))
						objinfo += "<a href='?src=\ref[src];hsb=hsb_safespawn&path=[O]'>[O]</a><br>"

				usr << browse(objinfo,"window=sandbox")

			//
			// Safespawn checks to see if spawning is disabled.
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
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/hsboxspawn = 1
var/list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbplasma" = "Spawn 50 Plasma",
					"phazon" = "Spawn 50 Phazon",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit",
					"revive" = "Rejuvinate")

/mob/var/datum/hSB/sandbox = null
/mob/proc/CanBuild()
	if(ticker.mode.name == "sandbox")
		sandbox = new/datum/hSB
		sandbox.owner = src.ckey
		if(src.client.holder)
			sandbox.admin = 1
		verbs += /mob/proc/sandbox_panel
		verbs += /mob/proc/sandbox_spawn_atom

/mob/proc/sandbox_panel()
	set name = "Sandbox Panel"
	set category = "Sandbox"

	if(sandbox)
		sandbox.update()

var/global/list/banned_sandbox_types=list(
	// /obj/item/weapon/gun,
	// /obj/item/assembly,
	// /obj/item/device/camera,
	// /obj/item/weapon/cloaking_device,
	// /obj/item/weapon/dummy,
	// /obj/item/weapon/melee/energy/sword,
	/obj/item/weapon/veilrender,
	/obj/item/weapon/reagent_containers/glass/bottle/wizarditis,
	// /obj/item/weapon/spellbook,
	/obj/machinery/singularity,
	// /obj/item/weapon/gun/energy/staff
	)

proc/is_banned_type(typepath)
	for(var/btype in banned_sandbox_types)
		if(findtext("[typepath]", "[btype]")!=0)
			return 1
	return 0

/mob/proc/sandbox_spawn_atom(var/object as text)
	set category = "Sandbox"
	set desc = "Spawn any item or machine"
	set name = "Sandbox Spawn"

	var/list/types = typesof(/obj/item) + typesof(/obj/machinery)
	for(var/type in types)
		if(is_banned_type(type))
			types -= type
	var/list/matches = new()

	for(var/path in types)
		if(is_banned_type(path))
			continue
		if(findtext("[path]", object)!=0)
			matches += path

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return
	if(is_banned_type(chosen))
		to_chat(src, "<span class='warning'>Denied.</span>")
		return
	new chosen(usr.loc)

	message_admins("\[SANDBOX\] [key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	//send2adminirc("\[SANDBOX\] [key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")
	feedback_add_details("admin_verb","hSBSA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

datum/hSB
	var/owner = null
	var/admin = 0
	proc
		update()
			var/hsbpanel = "<center><b>h_Sandbox Panel</b></center><hr>"
			if(admin)

				hsbpanel += {"<b>Administration Tools:</b><br>
					- <a href=\"?\ref[src];hsb=hsbtobj\">Toggle Object Spawning</a><br><br>"}
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
				if("revive")
					if(istype(usr,/mob/living))
						var/mob/living/M = usr
						M.revive()
				if("hsbtobj")
					if(!admin) return
					if(hsboxspawn)
						to_chat(world, "<b>Sandbox:  [usr.key] has disabled object spawning!</b>")
						hsboxspawn = 0
						return
					if(!hsboxspawn)
						to_chat(world, "<b>Sandbox:  [usr.key] has enabled object spawning!</b>")
						hsboxspawn = 1
						return
				if("hsbsuit")
					var/mob/living/carbon/human/P = usr
					//There really should be a drop_old_and_equip_to_slot() proc.
					if(P.wear_suit)
						P.wear_suit.loc = P.loc
						P.wear_suit.layer = initial(P.wear_suit.layer)
						P.wear_suit = null
					P.wear_suit = new/obj/item/clothing/suit/space/nasavoid(P)
					P.wear_suit.layer = 20
					P.wear_suit.plane = PLANE_HUD
					if(P.head)
						P.head.loc = P.loc
						P.head.layer = initial(P.head.layer)
						P.head = null
					P.head = new/obj/item/clothing/head/helmet/space/nasavoid(P)
					P.head.layer = 20
					P.head.plane = PLANE_HUD
					if(P.wear_mask)
						P.wear_mask.loc = P.loc
						P.wear_mask.layer = initial(P.wear_mask.layer)
						P.wear_mask = null
					P.wear_mask = new/obj/item/clothing/mask/gas(P)
					P.wear_mask.layer = 20
					P.wear_mask.plane = PLANE_HUD
					if(P.back)
						P.back.loc = P.loc
						P.back.layer = initial(P.back.layer)
						P.back = null
					P.back = new/obj/item/weapon/tank/jetpack/void(P)
					P.back.layer = 20
					P.back.plane = PLANE_HUD

					P.regenerate_icons()
				if("hsbmetal")
					var/obj/item/stack/sheet/hsb = getFromPool(/obj/item/stack/sheet/metal,get_turf(usr))
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbglass")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/glass/glass
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbplasma")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/mineral/plasma
					hsb.amount = 50
					hsb.loc = usr.loc
				if("phazon")
					var/obj/item/stack/sheet/hsb = new/obj/item/stack/sheet/mineral/phazon
					hsb.amount = 50
					hsb.loc = usr.loc
				if("hsbcanister")
					var/list/hsbcanisters = typesof(/obj/machinery/portable_atmospherics/canister/) - /obj/machinery/portable_atmospherics/canister/
//					hsbcanisters -= /obj/machinery/portable_atmospherics/canister/sleeping
					var/hsbcanister = input(usr, "Choose a canister to spawn.", "Sandbox:") in hsbcanisters + "Cancel"
					if(!(hsbcanister == "Cancel"))
						new hsbcanister(usr.loc)
				if("hsbfueltank")
					new /obj/structure/reagent_dispensers/fueltank(usr.loc)
				if("hsbwatertank")
					new /obj/structure/reagent_dispensers/watertank(usr.loc)
				if("hsbtoolbox")
					var/obj/item/weapon/storage/hsb = new/obj/item/weapon/storage/toolbox/mechanical
					for(var/obj/item/device/radio/T in hsb)
						qdel(T)
					new/obj/item/weapon/crowbar (hsb)
					hsb.loc = usr.loc
				if("hsbmedkit")
					var/obj/item/weapon/storage/firstaid/hsb = new/obj/item/weapon/storage/firstaid/regular
					hsb.loc = usr.loc
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
