GLOBAL_LIST_EMPTY(perseus_supplypacks)
/obj/machinery/computer/perseussupply
	name = "Perseus Supply Pad"
	desc = null
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "pad-idle_blue"
	density = 1
	anchored = 1
	layer = 2.6
	var/teleporting = 0
	var/supply_points = 15
	var/supply_cap = 250
	var/supply_window = 0
	var/point_interval = 60
	var/last_supply_point = 0
	var/list/supply_packs = list()
	var/list/perseus_supply_packs = list()
	var/datum/supply_pack/chosen = null
	var/datum/perseus_supply_packs/chosen2 = null
	var/list/supplied = list()
	var/list/spawned_crates = list()
	var/list/black_list = list(
	/datum/supply_pack/emergency/droneshells,
	/datum/supply_pack/medical/virus,
	/datum/supply_pack/science/robotics/mecha_odysseus,
	/datum/supply_pack/science/robotics/mecha_ripley,
	/datum/supply_pack/science/shieldwalls,
	/datum/supply_pack/science/transfer_valves,
	/datum/supply_pack/security,
	/datum/supply_pack/emergency/spacesuit,
	/datum/supply_pack/engineering/engine,
	/datum/supply_pack/engineering/grounding_rods,
	/datum/supply_pack/organic/hydroponics/beekeeping_fullkit,
	/datum/supply_pack/misc/mule
	)
	var/list/white_list = list( //Things in this list will be allowed even if in the black_list. Use this to add a specific child of a blacklisted item.
	/datum/supply_pack/security/armory/mindshield,
	/datum/supply_pack/security/wall_flash,
	/datum/supply_pack/security/securitybarriers,
	/datum/supply_pack/security/forensics
	)

/obj/machinery/computer/perseussupply/New()
	var/image/implantimage = new(src)
	implantimage.loc = src
	implantimage.icon = 'icons/oldschool/perseus.dmi'
	implantimage.icon_state = "percsupplyimplanted"
	implantimage.layer = 5.1
	perseus_client_imaged_machines[src] = implantimage
	var/image/I = new()
	I.icon = 'icons/oldschool/perseus.dmi'
	I.icon_state = "percsupplyoverlay"
	I.layer = 5
	var/list/overlaytemp = list(I)
	overlays = overlaytemp
	spawn(0)
		while(!SSticker || !SSshuttle)
			sleep(1)
		while(SSticker.current_state != GAME_STATE_PLAYING)
			sleep(10)
		for(var/N in SSshuttle.supply_packs)
			var/datum/supply_pack/S = SSshuttle.supply_packs[N]
			var/white_listed = 0
			for(var/T in white_list)
				if(S.type == T)
					white_listed = 1
					break
			if(!white_listed)
				var/black_listed = 0
				for(var/T in black_list)
					if(istype(S,T))
						black_listed = 1
						break
				if(black_listed)
					continue
			if(S.contraband || S.hidden || S.special || S.special_enabled || S.DropPodOnly || S.dangerous)
				continue
			if(convert_supply_cost(S.cost) > supply_cap)
				continue
			var/supply_name = "[S.type]"
			var/firsthalf = "/datum/supply_pack/"
			var/lasthalf = copytext(supply_name, length(firsthalf)+1, length(supply_name)+1)
			var/slashposition = findtext(lasthalf,"/",1,length(lasthalf)+1)
			var/categoryname = copytext(lasthalf,1,slashposition)
			if(categoryname && !(categoryname in supply_packs))
				supply_packs[categoryname] = list()
			supply_packs[categoryname][S.name] = S
		if(!GLOB.perseus_supplypacks.len)
			for(var/path in (typesof(/datum/perseus_supply_packs) - /datum/perseus_supply_packs))
				var/datum/perseus_supply_packs/P = new path()
				GLOB.perseus_supplypacks += P
		for(var/datum/perseus_supply_packs/P in GLOB.perseus_supplypacks)
			perseus_supply_packs[P.name] = P
	..()

/obj/machinery/computer/perseussupply/update_icon()

/obj/machinery/computer/perseussupply/proc/convert_supply_cost(number)
	if(isnum(number))
		return round(number/100,1)
	return 0

/obj/machinery/computer/perseussupply/process()
	if(last_supply_point < world.time && supply_points < supply_cap && SSticker.current_state == GAME_STATE_PLAYING)
		supply_points++
		last_supply_point = world.time+(point_interval*10)

/obj/machinery/computer/perseussupply/attack_hand(mob/living/user)
	if(!istype(user,/mob/living))
		return
	if(!user.Adjacent(src))
		return
	if(!check_perseus(user))
		to_chat(user,"All you see are strange green numbers falling down the screen from top to bottom like rain.")
		return
	var/dat = ""
	if(chosen && !chosen2)
		dat += "<B>Crate Selection:</B> [chosen.name]<BR>"
		dat += "<B>Cost:</B> [convert_supply_cost(chosen.cost)]<BR>"
		/*if(chosen.contains.len)
			dat += "<BR><B>Crate Contains:</B><BR>"
			dat += "[chosen.manifest]"*/
		dat += "<BR>"
		dat += "Supply Points available: [supply_points]<BR>"
		dat += "<a href='byond://?src=\ref[src];order=1'>Request Crate</a>"
		dat += "<a href='byond://?src=\ref[src];cancelorder=1'>Cancel</a>"
	else if(chosen2 && !chosen)
		dat += "<B>Crate Selection:</B> [chosen2.name]<BR>"
		dat += "<B>Cost:</B> [chosen2.cost]<BR>"
		if(chosen2.contains.len)
			dat += "<BR><B>Crate Contains:</B><BR>"
			dat += "[chosen2.manifest]"
		dat += "<BR>"
		dat += "Supply Points available: [supply_points]<BR>"
		dat += "<a href='byond://?src=\ref[src];percorder=1'>Request Crate</a>"
		dat += "<a href='byond://?src=\ref[src];cancelorder=1'>Cancel</a>"
	else if(!supply_window)
		dat += "<B>Supply Points:</B> "
		dat += "[supply_points]"
		dat += "<BR><BR>"
		dat += "<a href='byond://?src=\ref[src];placeorder=1'>Request Supply Crate</a><BR>"
		var/obj/structure/closet/crate = null
		for(var/obj/structure/closet/C in loc)
			crate = C
			break
		if(crate)
			dat += "<a href='byond://?src=\ref[src];returncrate=1'>Return Crate</a><BR>Returning the crate will yield extra supply points."
		else
			dat += "<BR>Place a crate on the pad to return for extra supply points. Be sure to stamp the supply manifest report with your PDA."
	else if(supply_window)
		dat += "<B>Supply Points:</B> "
		dat += "[supply_points]"
		dat += "<BR><BR>"
		dat += "Select a crate to request from Headquarters.<BR><BR>"
		dat += "Perseus Supplies<BR>"
		for(var/U in perseus_supply_packs)
			var/datum/perseus_supply_packs/S = perseus_supply_packs[U]
			dat += "<a href='byond://?src=\ref[src];perseussupplypack=\ref[S]'>[S.name]</a> Cost: [S.cost]<BR>"
		for(var/U in supply_packs)
			if(!U || !istype(supply_packs[U],/list))
				continue
			dat += "[capitalize(U)] Supplies<BR>"
			for(var/text in supply_packs[U])
				if(text && istype(supply_packs[U][text],/datum/supply_pack))
					var/datum/supply_pack/S = supply_packs[U][text]
					dat += "<a href='byond://?src=\ref[src];supplypack=\ref[S]'>[S.name]</a> Cost: [convert_supply_cost(S.cost)]<BR>"
		dat += "<BR><a href='byond://?src=\ref[src];placeorder=1'>Return</a>"
	var/datum/browser/popup = new(user, "perseussupply", "Perseus Headquarters Supply Pad", 500, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/perseussupply/Topic(href,href_list)
	if(..())
		return
	if(!istype(usr,/mob/living))
		return
	if(!usr.Adjacent(src))
		return
	if(teleporting)
		return
	var/mob/living/H = usr
	if(!check_perseus(H))
		return
	if(href_list["supplypack"])
		var/datum/supply_pack/S = locate(href_list["supplypack"])
		if(!istype(S))
			return
		chosen = S
		chosen2 = null
		attack_hand(usr)
		return
	if(href_list["perseussupplypack"])
		var/datum/perseus_supply_packs/S = locate(href_list["perseussupplypack"])
		if(!istype(S))
			return
		chosen2 = S
		chosen = null
		attack_hand(usr)
		return
	if(href_list["order"])
		if(chosen2)
			chosen = null
			chosen2 = null
			attack_hand(usr)
			return
		if(!chosen)
			attack_hand(usr)
			return
		if(convert_supply_cost(chosen.cost) > supply_points)
			to_chat(usr,"\red Insufficient Supply Points.")
			return
		supply_points -= convert_supply_cost(chosen.cost)
		var/obj/structure/closet/C = null
		var/obj/item/paper/perseussupply/P
		var/username = usr.name
		perseusAlert("Supply Notice","[chosen.name] delivered to the Mycenae at the cost of [convert_supply_cost(chosen.cost)] supply points. Ordered by [username].")
		P = new()
		P.name = "[chosen.name] manifest"
		P.info = "Supply request approved by Perseus Headquarters.<BR>A [chosen.crate_name] has been delivered to the Mycenae III.<BR>"
		if(chosen.contains.len)
			C = new /obj/structure/closet/crate/perc()
			var/list/spawned_items = ""
			for(var/T in chosen.contains)
				var/obj/O = new T(C)
				if(GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
					for(var/obj/machinery/computer/percsecuritysystem/percsec in GLOB.Perseus_Data["Perseus_Security_Systems"])
						percsec.gather_equipment(O)
				supplied += O
				spawned_items += "[O.name]<BR>"
			for(var/obj/item/stack/S in C)
				S.amount = S.max_amount
			P.info += "[chosen.name] Manifest<BR><BR>[spawned_items]<BR>"
		else
			C = new chosen.crate_type()
		if(C)
			spawned_crates += C
		P.info += "Cost: [convert_supply_cost(chosen.cost)]."
		P.update_icon()
		P.loc = C
		C.name = chosen.crate_name
		teleporting = 1
		attack_hand(usr)
		playsound(loc, 'sound/weapons/flash.ogg', 25, 1)
		flick("pad-beam_blue", src)
		sleep(30)
		playsound(loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
		flick("pad-beam_blue", src)
		C.loc = loc
		chosen = null
		teleporting = 0
		spawn(0)
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()
		attack_hand(usr)
		return
	if(href_list["percorder"])
		if(chosen)
			chosen = null
			chosen2 = null
			attack_hand(usr)
			return
		if(!chosen2)
			attack_hand(usr)
			return
		if(chosen2.cost > supply_points)
			to_chat(usr,"\red Insufficient Supply Points.")
			return
		supply_points -= chosen2.cost
		var/obj/structure/closet/C = null
		var/obj/item/paper/perseussupply/P
		var/username = usr.name
		perseusAlert("Supply Notice","[chosen2.name] delivered to the Mycenae at the cost of [chosen2.cost] supply points. Ordered by [username].")
		P = new()
		P.name = "[chosen2.name] manifest"
		P.info = "Supply request approved by Perseus Headquarters.<BR>A [chosen2.containername] has been delivered to the Mycenae III.<BR>"
		if(chosen2.contains.len)
			C = new chosen2.containertype()
			for(var/T in chosen2.contains)
				var/obj/O = new T(C)
				if(GLOB.Perseus_Data["Perseus_Security_Systems"] && istype(GLOB.Perseus_Data["Perseus_Security_Systems"],/list))
					for(var/obj/machinery/computer/percsecuritysystem/percsec in GLOB.Perseus_Data["Perseus_Security_Systems"])
						percsec.gather_equipment(O)
			if(chosen2.amount)
				for(var/obj/item/stack/S in C)
					S.amount = chosen2.amount
			P.info += "[chosen2.name] Manifest<BR><BR>[chosen2.manifest]<BR>"
		else
			C = new chosen2.containertype()
		if(C)
			spawned_crates += C
		P.info += "Cost: [chosen2.cost]."
		P.update_icon()
		P.loc = C
		if(istype(C,/obj/structure/closet/crate/secure))
			C.req_access = list()
			C.req_access += text2num("[chosen2.access]")
		C.name = chosen2.containername
		teleporting = 1
		attack_hand(usr)
		playsound(loc, 'sound/weapons/flash.ogg', 25, 1)
		flick("pad-beam_blue", src)
		sleep(30)
		playsound(loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
		flick("pad-beam_blue", src)
		C.loc = loc
		chosen2 = null
		teleporting = 0
		spawn(0)
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()
		attack_hand(usr)
		return
	if(href_list["cancelorder"])
		chosen = null
		chosen2 = null
		attack_hand(usr)
	if(href_list["placeorder"])
		supply_window = !supply_window
		attack_hand(usr)
	if(href_list["returncrate"])
		for(var/obj/structure/closet/C in loc)
			if(!(C in spawned_crates))
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
				visible_message("\red Unacceptable crate: \"[C.name]\"")
				continue
			var/atom/Cturf = C.loc
			teleporting = 1
			playsound(loc, 'sound/weapons/flash.ogg', 25, 1)
			flick("pad-beam_blue", src)
			sleep(30)
			if(C.loc != Cturf)
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
				teleporting = 0
				return
			playsound(loc, 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			flick("pad-beam_blue", src)
			var/addpoints = 5
			for(var/atom/movable/A in C)
				addpoints += sell_object(A)
			addpoints = min(addpoints,10)
			supply_points = min(supply_points+addpoints,supply_cap)
			spawn(0)
				var/datum/effect_system/spark_spread/system = new()
				system.set_up(3, 0, get_turf(src))
				system.start()
			for(var/mob/living/M in view(7,loc))
				if(M.stat == (UNCONSCIOUS||DEAD))
					continue
				if(check_perseus(M))
					to_chat(M,"\blue <I>[addpoints] supply points returned for the [C.name].</I>")
			C.moveToNullspace()
			qdel(C)
			teleporting = 0
			break
		attack_hand(usr)

/obj/machinery/computer/perseussupply/proc/sell_object(atom/movable/AM)
	. = 0
	if(istype(AM,/mob))
		var/mob/M = AM
		M.forceMove(loc)
		M.reset_perspective(null)
		return
	else if(istype(AM,/obj/item/paper/perseussupply))
		var/obj/item/paper/perseussupply/paper = AM
		if(paper.percstamped)
			. += 2
	else if(istype(AM,/obj/item/storage))
		for(var/atom/movable/AMinstorage in AM)
			. += sell_object(AMinstorage)
	if(AM in supplied)
		supplied -= AM
		if(istype(AM,/obj/item/stack))
			var/obj/item/stack/stack = AM
			if(stack.amount >= stack.max_amount)
				.++
		else if(istype(AM,/obj/item))
			var/obj/item/I = AM
			if(I.w_class > 1)
				if(prob(40))
					.++
		else if(AM.density)
			.++
	AM.moveToNullspace()
	qdel(AM)

/obj/machinery/computer/perseussupply/CollidedWith(atom/movable/AM)
	if(istype(AM,/obj/structure/closet))
		var/alreadyacrate = 0
		for(var/obj/structure/closet/C in loc)
			alreadyacrate = 1
			break
		if(!alreadyacrate)
			AM.loc = loc
	return ..()

/obj/machinery/computer/perseussupply/examine()
	..()
	if(!istype(usr,/mob/living))
		to_chat(usr,"All you see on its screen are strange green numbers falling down from top to bottom like rain.")
	else
		if(!check_perseus(usr))
			to_chat(usr,"All you see on its screen are strange green numbers falling down from top to bottom like rain.")

//**************
//Perseus Crates
//**************

/obj/structure/closet/crate/perc
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "perccrate"
	update_icon()
		icon_state = "[initial(icon_state)][opened ? "open" : ""]"
		cut_overlays()
		var/oldicon = 'icons/obj/crates.dmi'
		if(manifest)
			var/image/I = new()
			I.icon = oldicon
			I.icon_state = "manifest"
			overlays += I

/obj/structure/closet/crate/secure/perc
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "secureperccrate"
	update_icon()
		icon_state = "[initial(icon_state)][opened ? "open" : ""]"
		cut_overlays()
		var/oldicon = 'icons/obj/crates.dmi'
		if(manifest)
			var/image/I = new()
			I.icon = oldicon
			I.icon_state = "manifest"
			overlays += I
		if(broken)
			var/image/I = new()
			I.icon = oldicon
			I.icon_state = "securecrateemag"
			overlays += I
		else if(locked)
			var/image/I = new()
			I.icon = oldicon
			I.icon_state = "securecrater"
			overlays += I
		else
			var/image/I = new()
			I.icon = oldicon
			I.icon_state = "securecrateg"
			overlays += I

//**********************
//Special Manifest paper
//**********************

/obj/item/paper/perseussupply
	var/percstamped = 0
	attackby(obj/item/P, mob/living/user)
		if(istype(user) && istype(P,/obj/item/device/pda/perseus))
			var/obj/item/device/pda/perseus/pda = P
			if(check_perseus(user) && !percstamped)
				if(!in_range(src, usr) && loc != user && !istype(loc, /obj/item/clipboard) && loc.loc != user && user.get_active_held_item() != P)
					return
				percstamped = 1
				var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
				stampoverlay.pixel_x = rand(-2, 2)
				stampoverlay.pixel_y = rand(-3, 2)
				stampoverlay.icon_state = "paper_stamp-ok"
				overlays += stampoverlay
				//to_chat(user,"\blue You stamp the supply manifest report with your PDA.")
				info += "<BR><BR><B>Stamped by [pda.owner].</B>"
				for(var/mob/M in view(7,get_turf(user)))
					if(M == user)
						to_chat(M,"You add your stamp to the [name].")
						continue
					if(M.stat == 1)
						return
					to_chat(M,"[user.name] stamps the [name].")
				return

//********************
//Perseus Supply Packs
//********************

/datum/perseus_supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/cost = null
	var/containertype = /obj/structure/closet/crate/secure/perc
	var/containername = null
	var/access = ACCESS_PERSEUS_ENFORCER
	var/amount = 0

/datum/perseus_supply_packs/New()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)	continue
		var/atom/movable/AM = new path()
		manifest += "<li>[AM.name]</li>"
		qdel(AM)
	manifest += "</ul>"

/datum/perseus_supply_packs/five_seven_ammo
	name = "Five-Seven Ammunition Crate"
	contains = list(/obj/item/ammo_box/magazine/fiveseven,
					/obj/item/ammo_box/magazine/fiveseven,
					/obj/item/ammo_box/magazine/fiveseven)
	containername = "perseus five-seven ammunition crate"
	cost = 40

/*/datum/perseus_supply_packs/perc_barrier
	name = "Security Barrier Crate"
	contains = list(/obj/machinery/deployable/barrier/perseus)
	containername = "perseus Security Barrier crate"
	cost = 50*/

/datum/perseus_supply_packs/perc_ids
	name = "Identification Crate"
	contains = list(/obj/item/card/id/perseus,
					/obj/item/card/id/perseus,
					/obj/item/card/id/perseus,
					/obj/item/device/pda/perseus,
					/obj/item/device/pda/perseus,
					/obj/item/device/pda/perseus)
	containername = "perseus identificiation crate"
	cost = 15

/datum/perseus_supply_packs/breach_charges
	name = "Explosives Crate"
	contains = list(/obj/item/c4_ex/breach,
					/obj/item/c4_ex/breach,
					/obj/item/c4_ex/breach)
	containername = "perseus explosives crate"
	cost = 50

/datum/perseus_supply_packs/leisure
	name = "Leisure Crate"
	contains = list(/obj/item/storage/fancy/cigarettes/perc,
					/obj/item/storage/fancy/cigarettes/perc,
					/obj/item/storage/box/matches,
					/obj/item/storage/box/matches,
					/obj/item/storage/fancy/donut_box,
					/obj/item/clothing/mask/cigarette/cigar/victory,
					/obj/item/clothing/mask/cigarette/cigar/victory,
					/obj/item/clothing/mask/cigarette/cigar/victory
					)
					/*/obj/item/toy/percballoon,
					/obj/item/toy/percballoon,
					/obj/item/toy/percbottoy,
					/obj/item/toy/percbottoy)*/
	containername = "perseus leisure crate"
	cost = 10

/datum/perseus_supply_packs/prisoner_gear
	name = "Prisoner Gear Crate"
	contains = list(/obj/item/clothing/under/color/orange,
					/obj/item/clothing/under/color/orange,
					/obj/item/clothing/under/color/orange,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/shoes/sneakers/orange,
					/obj/item/clothing/mask/muzzle,
					/obj/item/clothing/suit/straight_jacket,
					/obj/item/clothing/glasses/sunglasses/blindfold,
					/obj/item/clothing/ears/earmuffs)
	containername = "prisoner gear crate"
	cost = 15

/datum/perseus_supply_packs/general_supplies
	name = "General Supplies"
	contains = list(/obj/item/stimpack/perseus,
					/obj/item/stimpack/perseus,
					/obj/item/stimpack/perseus,
					/obj/item/storage/box/handcuffs,
					/obj/item/storage/box/flashes,
					/obj/item/storage/box/flashbangs,
					/obj/item/storage/box/flashbangs,
					/obj/item/tank/perseus,
					/obj/item/tank/perseus,
					/obj/item/tank/perseus)
	containername = "perseus general gear crate"
	cost = 20

/datum/perseus_supply_packs/mixed_clothing
	name = "Mixed Clothing Crate"
	contains = list(/obj/item/clothing/suit/wintercoat/perseus,
					/obj/item/clothing/suit/wintercoat/perseus,
					/obj/item/clothing/suit/wintercoat/perseus,
					/obj/item/clothing/suit/blackjacket,
					/obj/item/clothing/suit/blackjacket,
					/obj/item/clothing/suit/blackjacket,
					/obj/item/clothing/under/perseus_uniform,
					/obj/item/clothing/under/perseus_uniform,
					/obj/item/clothing/under/perseus_uniform,
					/obj/item/storage/backpack/blackpack,
					/obj/item/storage/backpack/blackpack,
					/obj/item/storage/backpack/blackpack)
					/*/obj/item/storage/backpack/blacksatchel,
					/obj/item/storage/backpack/blacksatchel)*/
	containername = "perseus mixed clothing crate"
	cost = 15

/datum/perseus_supply_packs/skin_suit
	name = "Skin Suit Crate"
	contains = list(/obj/item/clothing/under/space/skinsuit)
	containername = "perseus skin suit crate"
	cost = 60

/datum/perseus_supply_packs/combat_gear
	name = "Combat Gear Crate"
	contains = list(/obj/item/clothing/shoes/combat,
					/obj/item/clothing/shoes/combat,
					/obj/item/clothing/mask/gas/perseus_voice,
					/obj/item/clothing/mask/gas/perseus_voice,
					/obj/item/clothing/gloves/specops,
					/obj/item/clothing/gloves/specops,
					/obj/item/clothing/suit/armor/lightarmor,
					/obj/item/clothing/suit/armor/lightarmor,
					/obj/item/device/radio/headset/perseus,
					/obj/item/device/radio/headset/perseus,
					/obj/item/clothing/head/helmet/space/pershelmet,
					/obj/item/clothing/head/helmet/space/pershelmet,
					/obj/item/storage/belt/security/perseus,
					/obj/item/storage/belt/security/perseus,
					/obj/item/shield/riot/perc,
					/obj/item/shield/riot/perc)
	containername = "perseus combat gear crate"
	cost = 60

/*/datum/perseus_supply_packs/percchefsupply
	name = "Automated Chef Restocking Crate"
	contains = list(/obj/item/vending_refill/percchef,
					/obj/item/vending_refill/percchef,
					/obj/item/vending_refill/percchef)
	containername = "automated chef restocking crate"
	cost = 15

/datum/perseus_supply_packs/percboozeomat
	name = "Perctech Booze-O-Mat Restocking Crate"
	contains = list(/obj/item/vending_refill/boozeomat/perc,
					/obj/item/vending_refill/boozeomat/perc,
					/obj/item/vending_refill/boozeomat/perc)
	containername = "perctech booze-o-mat restocking crate"
	cost = 15*/

/datum/perseus_supply_packs/prisonerimplants
	name = "Prisoner Implants Crate"
	contains = list(/obj/item/storage/box/trackimp,
					/obj/item/storage/box/chemimp)
	containername = "prisoner implants crate"
	cost = 15

/*/datum/perseus_supply_packs/creeperunit
	name = "Creeper Unit"
	contains = list(/obj/machinery/perseussecuritron)
	containername = "creeper unit crate"
	cost = 100*/

/datum/perseus_supply_packs/medkits
	name = "Perseus Medical Kits"
	contains = list(/obj/item/storage/firstaid/perseus,
					/obj/item/storage/firstaid/perseus,
					/obj/item/storage/firstaid/perseus)
	containername = "perseus medical kits crate"
	cost = 20