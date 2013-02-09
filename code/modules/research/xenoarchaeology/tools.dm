//---- miscellaneous devices ----//

//also known as the x-ray diffractor
/obj/item/device/depth_scanner
	name = "depth analysis scanner"
	desc = "Used to check spatial depth and density of rock outcroppings."
	icon = 'pda.dmi'
	icon_state = "crap"
	item_state = "analyzer"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/list/positive_locations = list()
	var/datum/depth_scan/current

/datum/depth_scan
	var/time = ""
	var/coords = ""
	var/depth = 0
	var/clearance = 0
	var/record_index = 1
	var/dissonance_spread = 1

/obj/item/device/depth_scanner/proc/scan_turf(var/mob/user, var/turf/T)
	user.visible_message("\blue [user] scans [T], the air around them humming gently.")
	if(istype(T,/turf/simulated/mineral))
		var/turf/simulated/mineral/M = T
		if(M.excavation_minerals.len || M.finds.len)
			//create a new scanlog entry
			var/datum/depth_scan/D = new()
			D.coords = "[10 * T.x + rand(0,9)]:[10 * T.y + rand(0,9)]:[10 * T.z + rand(0,9)]"
			D.time = worldtime2text()
			D.record_index = positive_locations.len + 1

			//find whichever is closer: find or mineral
			if(M.finds.len)
				var/datum/find/F = M.finds[1]
				D.depth = F.excavation_required
				D.clearance = F.clearance_range
			if(M.excavation_minerals.len)
				if(M.excavation_minerals[1] < D.depth)
					D.depth = M.excavation_minerals[1]
					D.clearance = rand(2,6)
					D.dissonance_spread = rand(1,1000) / 100

			positive_locations.Add(D)

			for(var/mob/L in range(src, 1))
				L << "\blue \icon[src] [src] pings."

/obj/item/device/depth_scanner/attack_self(var/mob/user as mob)
	return src.interact(user)

/obj/item/device/depth_scanner/interact(var/mob/user as mob)
	var/dat = "<b>Co-ordinates with positive matches</b><br>"
	dat += "<A href='?src=\ref[src];clear=0'>== Clear all ==</a><br>"
	if(current)
		dat += "Time: [current.time]<br>"
		dat += "Coords: [current.coords]<br>"
		dat += "Anomaly depth: [current.depth]<br>"
		dat += "Clearance: [current.clearance]<br>"
		dat += "Dissonance spread: [current.dissonance_spread]<br>"
		dat += "<A href='?src=\ref[src];clear=[current.record_index]'>clear entry</a><br>"
	else
		dat += "Select an entry from the list<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
		dat += "<br>"
	dat += "<hr>"
	if(positive_locations.len)
		for(var/index=1, index<=positive_locations.len, index++)
			var/datum/depth_scan/D = positive_locations[index]
			dat += "<A href='?src=\ref[src];select=[index]'>[D.time], coords: [D.coords]</a><br>"
	else
		dat += "No entries recorded."
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</a><br>"
	dat += "<A href='?src=\ref[src];close=1'>Close</a><br>"
	user << browse(dat,"window=depth_scanner;size=300x500")
	onclose(user, "depth_scanner")

/obj/item/device/depth_scanner/Topic(href, href_list)
	..()
	usr.set_machine(src)

	if(href_list["select"])
		var/index = text2num(href_list["select"])
		if(index && index <= positive_locations.len)
			current = positive_locations[index]
	else if(href_list["clear"])
		var/index = text2num(href_list["clear"])
		if(index)
			if(index <= positive_locations.len)
				var/datum/depth_scan/D = positive_locations[index]
				positive_locations.Remove(D)
				del(D)
		else
			//GC will hopefully pick them up before too long
			positive_locations = list()
			del(current)
	else if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=depth_scanner")

	updateSelfDialog()

/obj/item/device/gps
	name = "relay positioning device"
	desc = "Triangulates the approximate co-ordinates using a nearby satellite network."
	icon = 'device.dmi'
	icon_state = "locator"
	item_state = "locator"

/obj/item/device/gps/attack_self(var/mob/user as mob)
	var/turf/T = get_turf(src)
	user << "\blue \icon[src] [src] flashes <i>[10 * T.x + rand(0,9)]:[10 * T.y + rand(0,9)]:[10 * T.z + rand(0,9)]</i>."

/obj/item/device/beacon_locator
	name = "locater device"
	desc = "Used to scan and locate signals on a particular frequency according ."
	icon = 'device.dmi'
	icon_state = "pinoff"	//pinonfar, pinonmedium, pinonclose, pinondirect, pinonnull
	item_state = "electronic"

/obj/item/device/core_sampler
	name = "core sampler"
	desc = "Used to extract cores from geological samples."
	icon = 'device.dmi'
	icon_state = "core_sampler"
	item_state = "screwdriver_brown"
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT

/obj/item/device/measuring_tape
	name = "measuring tape"
	desc = "A coiled metallic tape used to check dimensions and lengths."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "measuring"

//todo: dig site tape

//---- excavation devices devices ----//
//sorted in order of delicacy

/obj/item/weapon/pickaxe/brush
	name = "brush"
	//icon_state = "brush"
	//item_state = "minipick"
	digspeed = 50
	desc = "Featuring thick metallic wires for clearing away dust and loose scree."
	excavation_amount = 0.5
	drill_sound = 'sound/weapons/thudswoosh.ogg'
	drill_verb = "brushing"

/obj/item/weapon/pickaxe/one_pick
	name = "1/6 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging (1 centimetre excavation depth)."
	excavation_amount = 1
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/two_pick
	name = "1/3 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging (2 centimetre excavation depth)."
	excavation_amount = 2
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/three_pick
	name = "1/2 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging (3 centimetre excavation depth)."
	excavation_amount = 3
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/four_pick
	name = "2/3 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging (4 centimetre excavation depth)."
	excavation_amount = 4
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/five_pick
	name = "5/6 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging (5 centimetre excavation depth)."
	excavation_amount = 5
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/six_pick
	name = "1/1 pick"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A miniature excavation tool for precise digging (6 centimetre excavation depth)."
	excavation_amount = 6
	drill_sound = 'sound/items/Screwdriver.ogg'
	drill_verb = "delicately picking"

/obj/item/weapon/pickaxe/hand
	name = "hand pickaxe"
	//icon_state = "excavation"
	//item_state = "minipick"
	digspeed = 50
	desc = "A smaller, more precise version of the pickaxe (15 centimetre excavation depth)."
	excavation_amount = 15
	drill_sound = 'sound/items/Crowbar.ogg'
	drill_verb = "clearing"
