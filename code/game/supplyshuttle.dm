//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_POINTSPER 10      //Points per tick.
#define SUPPLY_POINTDELAY 3000 //Delay between ticks in milliseconds.
#define SUPPLY_MOVETIME 1800	//Time to station is milliseconds.
#define SUPPLY_POINTSPERCRATE 5	//Points per crate sent back.
#define SUPPLY_STATION_AREATYPE "/area/supply/station" //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE "/area/supply/dock"	//Type of the supply shuttle area for dock
#define SUPPLY_POINTSPERSLIP 2 //points per packing slip sent back stamped.

var/supply_shuttle_moving = 0
var/supply_shuttle_at_station = 0
var/list/supply_shuttle_shoppinglist = new/list()
var/list/supply_shuttle_requestlist = new/list()
var/supply_shuttle_can_send = 1
var/supply_shuttle_time = 0
var/supply_shuttle_timeleft = 0
var/supply_shuttle_points = 50
var/ordernum=0
var/list/supply_groups = new()

/area/supply/station //DO NOT TURN THE ul_Lighting STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	ul_Lighting = 0
	requires_power = 0

/area/supply/dock //DO NOT TURN THE ul_Lighting STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	ul_Lighting = 0
	requires_power = 0

//SUPPLY PACKS MOVED TO /code/defines/obj/supplypacks.dm

/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper Plastic flaps"
	desc = "Durable plastic flaps."
	icon = 'stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.pass_flags&PASSGLASS)
		return prob(60)
	else if(istype(A, /mob/living)) // You Shall Not Pass!
		var/mob/living/M = A
		if(!M.lying || istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/metroid))	// unless you're lying down, or a small creature
			return 0
	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			del(src)
		if (2)
			if (prob(50))
				del(src)
		if (3)
			if (prob(5))
				del(src)

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "\improper Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

	CanPass(atom/A, turf/T, height = 0, air_group = 0)
		if(!istype(A))
			return 0
		return ..()

/area/supplyshuttle
	name = "Supply Shuttle"
	icon_state = "supply"
	requires_power = 0

/obj/machinery/computer/supplycomp
	name = "Supply shuttle console"
	icon = 'computer.dmi'
	icon_state = "supply"
	req_access = list(ACCESS_CARGO)
	circuit = "/obj/item/weapon/circuitboard/supplycomp"
	var/temp = null
	var/hacked = 0
	var/can_order_contraband = 0

/obj/machinery/computer/supplycomp/New()
	// add the supply pack groups, if they haven't already been added
	if(supply_groups.len == 0)
		for(var/S in (typesof(/datum/supply_packs) - /datum/supply_packs - /datum/supply_packs/charge) )
			var/datum/supply_packs/N = new S()
			if(supply_groups.Find(N.group) == 0)
				supply_groups += N.group

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'computer.dmi'
	icon_state = "request"
	circuit = "/obj/item/weapon/circuitboard/ordercomp"
	var/temp = null
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
/obj/machinery/computer/ordercomp/New()
	// add the supply pack groups, if they haven't already been added
	if(supply_groups.len == 0)
		for(var/S in (typesof(/datum/supply_packs) - /datum/supply_packs - /datum/supply_packs/charge) )
			var/datum/supply_packs/N = new S()
			if(supply_groups.Find(N.group) == 0)
				supply_groups += N.group

/obj/effect/marker/supplymarker
	icon_state = "X"
	icon = 'mark.dmi'
	name = "X"
	invisibility = 101
	anchored = 1
	opacity = 0

/datum/supply_order
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/comment = null

/datum/supply_packs
	var/name = null
	var/list/contains = new/list()
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = "Miscellaneous"

/proc/supply_ticker()
	//world << "Supply ticker ticked : Adding [SUPPLY_POINTSPER] to [supply_shuttle_points]."
	supply_shuttle_points += SUPPLY_POINTSPER
	//world << "New SP total is [supply_shuttle_points]"
	spawn(SUPPLY_POINTDELAY) supply_ticker()

/proc/supply_process()
	while(supply_shuttle_time - world.timeofday > 0)
		var/ticksleft = supply_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			supply_shuttle_time = world.timeofday + 10	// midnight rollover


		supply_shuttle_timeleft = round( ((ticksleft / 10)/60) )
		sleep(10)
	supply_shuttle_moving = 0
	send_supply_shuttle()


/proc/supply_can_move()
	if(supply_shuttle_moving) return 0

//I know this is an absolutly horrendous way to do this, very inefficient, but it's the only reliable way I can think of.
	//Check for carbon mobs - Allows simple animals.
	for(var/mob/living/carbon/M in world)
		var/area/A = get_area(M)
		if(!A || !A.type) continue
		if(A.type == /area/supply/station)
			return 0
	//Check for silicon mobs - Allows simple animals.
	for(var/mob/living/silicon/M in world)
		var/area/A = get_area(M)
		if(!A || !A.type) continue
		if(A.type == /area/supply/station)
			return 0
	//Check for beacons
	for(var/obj/item/device/radio/beacon/B in world)
		var/area/A = get_area(B)
		if(!A || !A.type) continue
		if(A.type == /area/supply/station)
			return 0
	//Check for mechs. I think this was added because people were somehow on centcomm and bringing back centcomm mechs.
	for(var/obj/mecha/Mech in world)
		var/area/A = get_area(Mech)
		if(!A || !A.type) continue
		if(A.type == /area/supply/station)
			return 0
	//Check for nuke disk This also prevents multiple nuke disks from being made -Nodrak
	for(var/obj/item/weapon/disk/nuclear/N)
		var/area/A = get_area(N)
		if(!A || !A.type) continue
		if(A.type == /area/supply/station)
			return 0
	return 1
/*
Teleport beacon -> wrapping paper -> backpack -> bodybag -> crate -> wrapping paper -> loaded on a mulebot
That would be a teleport beacon inside of 6-layers deep in contents. Meaning you would have to add more loops or more checks.
This method wont take into account storage items developed in the future and doesn't take into account the storage items we have currently.
-Nodrak

	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	for(var/turf/T in get_area_turfs(shuttleat) )
		//if((locate(/mob/living) in T) && (!locate(/mob/living/carbon/monkey) in T)) return 0  //old check for living excluded monkeys
		if((locate(/mob/living) in T)) return 0
		if((locate(/obj/item/device/radio/beacon) in T)) return 0
		if((locate(/obj/mecha) in T)) return 0
		if((locate(/obj/structure/closet/body_bag) in T)) return 0
		for(var/atom/ATM in T)
			if((locate(/mob/living/carbon) in ATM)) return 0	// allow simple_animals to be transported in containers
			if((locate(/mob/living/silicon) in ATM)) return 0
			if((locate(/obj/item/device/radio/beacon) in ATM)) return 0
			if((locate(/obj/mecha ) in ATM)) return 0
			if((locate(/obj/structure/closet/body_bag) in ATM)) return 0
			for(var/atom/ATMM in ATM) // okay jesus christ how many recursive packaging options are we going to have guys come on - Quarxink
				if((locate(/mob/living) in ATMM)) return 0
				if((locate(/obj/item/device/radio/beacon) in ATMM)) return 0
				if((locate(/obj/mecha ) in ATMM)) return 0
				if((locate(/obj/structure/closet/body_bag) in ATMM)) return 0
	return 1
*/
/proc/sell_crates()
	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	for(var/turf/T in get_area_turfs(shuttleat) )
		var/crate = locate(/obj/structure/closet/crate) in T
		if (crate)
			del(crate)
			supply_shuttle_points += SUPPLY_POINTSPERCRATE

/obj/item/weapon/paper/manifest
	name = "Supply Manifest"

	New()
		..()
		overlays += "paper_words"

/proc/process_supply_order()
	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	var/list/markers = new/list()

	if(!supply_shuttle_shoppinglist.len) return

	for(var/turf/T in get_area_turfs(shuttleat))
		for(var/obj/effect/marker/supplymarker/D in T)
			markers += D

	for(var/S in supply_shuttle_shoppinglist)
		var/pickedloc = 0
		var/found = 0
		for(var/C in markers)
			if (locate(/obj/structure/closet) in get_turf(C)) continue
			found = 1
			pickedloc = get_turf(C)
		if (!found) pickedloc = get_turf(pick(markers))
		var/datum/supply_order/SO = S
		var/datum/supply_packs/SP = SO.object

		var/atom/A = new SP.containertype ( pickedloc )
		A.name = "[SP.containername] [SO.comment ? "([SO.comment])":"" ]"

		//supply manifest generation begin

		if(ordernum)
			ordernum++
		else
			ordernum = rand(500,5000) //pick a random number to start with

		var/obj/item/weapon/paper/manifest/slip = new /obj/item/weapon/paper/manifest (A)
		slip.info = ""
		slip.info +="<h3>[command_name()] Shipping Manifest</h3><hr><br>"
		slip.info +="Order #: [ordernum]<br>"
		slip.info +="Destination: [station_name]<br>"
		slip.info +="[supply_shuttle_shoppinglist.len] PACKAGES IN THIS SHIPMENT<br>"
		slip.info +="CONTENTS:<br><ul>"

		//spawn the stuff, finish generating the manifest while you're at it
		if(SP.access)
			A:req_access = new/list()
			A:req_access += text2num(SP.access)
		for(var/B in SP.contains)
			if(!B)	continue
			var/thepath = text2path(B)
			var/atom/B2 = new thepath (A)
			if(SP.amount && B2:amount) B2:amount = SP.amount
			slip.info += "<li>[B2.name]</li>" //add the item to the manifest

		//manifest finalisation
		slip.info += "</ul><br>"
		slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"

	return

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/ordercomp/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/supplycomp/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
	// TODO: Link this up with the supply depot if possible
	if(..())
		return
	user.machine = src
	var/dat
	if (src.temp)
		dat = src.temp
	else

		dat += {"<BR><B>Supply shuttle</B><HR>
		Location: [supply_shuttle_moving ? "Moving to station ([supply_shuttle_timeleft] Mins.)":supply_shuttle_at_station ? "Station":"Dock"]<BR>
		<HR>Supply points: [supply_shuttle_points]<BR>
		<BR>\n<A href='?src=\ref[src];order=1'>Request items</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>
		<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

	if (href_list["order"])
		src.temp = "Supply points: [supply_shuttle_points]<BR><HR><BR>Request what?<BR><BR>"
		for(var/G in supply_groups)
			src.temp += "<A href='?src=\ref[src];order_group=[G]'>[G]</A><br>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Back</A>"

	else if (href_list["order_group"])
		var/G = href_list["order_group"]
		src.temp = "Supply points: [supply_shuttle_points]<BR><HR><BR>Request what?<BR><BR>"
		for(var/S in (typesof(/datum/supply_packs) - /datum/supply_packs - /datum/supply_packs/charge) )
			var/datum/supply_packs/N = new S()
			if(N.hidden || N.contraband) continue																	//Have to send the type instead of a reference to
			if(N.group != G) continue																//correct group?
			src.temp += "<A href='?src=\ref[src];doorder=[N.type]'>[N.name]</A> Cost: [N.cost] "    //the obj because it would get caught by the garbage
			src.temp += "<A href='?src=\ref[src];printform=[N.type]'>Print Requisition</A><br>"     //collector. oh well.
		src.temp += "<BR><A href='?src=\ref[src];order=1'>Back</A>"

	else if (href_list["doorder"])
		var/datum/supply_order/O = new/datum/supply_order ()
		var/supplytype = href_list["doorder"]
		var/datum/supply_packs/P = new supplytype ()
		O.object = P
		O.orderedby = usr.name
		supply_shuttle_requestlist += O
		src.temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["printform"])
		if (!reqtime)
			var/supplytype = href_list["printform"]
			var/datum/supply_packs/P = new supplytype ()
			var/obj/item/weapon/paper/reqform = new /obj/item/weapon/paper(src.loc)
			var/idname = "Unknown"
			var/idrank = "Unknown"
			var/reason = copytext(sanitize(input(usr,"Reason:","Why do you require this item?","")),1,MAX_MESSAGE_LEN)
			if(!reason)
				reason = "Unknown"

			reqform.name = "Requisition Form - [P.name]"
			reqform.overlays += "paper_words"
			reqform.info += "<h3>[station_name] Supply Requisition Form</h3><hr>"

			if (istype(usr:wear_id, /obj/item/weapon/card/id))
				if(usr:wear_id.registered_name)
					idname = usr:wear_id.registered_name
				if(usr:wear_id.assignment)
					idrank = usr:wear_id.assignment
			if (istype(usr:wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = usr:wear_id
				if(pda.owner)
					idname = pda.owner
				if(pda.ownjob)
					idrank = pda.ownjob
			else
				idname = usr.name

			reqform.info += "REQUESTED BY: [idname]<br>"
			reqform.info += "RANK: [idrank]<br>"
			reqform.info += "REASON: [reason]<br>"
			reqform.info += "SUPPLY CRATE TYPE: [P.name]<br>"
			reqform.info += "Contents:<br><ul>"

			for(var/B in P.contains)
				var/thepath = text2path(B)
				var/atom/B2 = new thepath ()
				reqform.info += "<li>[B2.name]</li>"
			reqform.info += "</ul><hr>"
			reqform.info += "STAMP BELOW TO APPROVE THIS REQUISITION:<br>"

			reqtime = 5 //5 second cooldown initiated after each printed req, change the number to change the cooldown (in seconds) - Quarxink
			spawn(0)
				while(reqtime >=1 && src)
					sleep(10)
					reqtime --
				reqtime = 0

		else
			for (var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[reqtime] seconds remaining until another requisition form may be printed.\"")
	else if (href_list["vieworders"])
		src.temp = "Current approved orders: <BR><BR>"
		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			src.temp = "[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]<BR>" + src.temp
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["viewrequests"])
		src.temp = "Current requests: <BR><BR>"
		for(var/S in supply_shuttle_requestlist)
			var/datum/supply_order/SO = S
			src.temp = "[SO.object.name] requested by [SO.orderedby]<BR>" + src.temp
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		src.temp = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
	// TODO: Link this up with the supply depot if possible
	if(!src.allowed(user))
		user << "\red Access Denied."
		return

	if(..())
		return
	user.machine = src
	post_signal("supply")
	var/dat
	if (src.temp)
		dat = src.temp
	else
		dat += {"<BR><B>Supply shuttle</B><HR>
		\nLocation: [supply_shuttle_moving ? "Moving to station ([supply_shuttle_timeleft] Mins.)":supply_shuttle_at_station ? "Station":"Away"]<BR>
		<HR>\nSupply points: [supply_shuttle_points]<BR>\n<BR>
		[supply_shuttle_moving ? "\n*Must be away to order items*<BR>\n<BR>":supply_shuttle_at_station ? "\n*Must be away to order items*<BR>\n<BR>":"\n<A href='?src=\ref[src];order=1'>Order items</A><BR>\n<BR>"]
		[supply_shuttle_moving ? "\n*Shuttle already called*<BR>\n<BR>":supply_shuttle_at_station ? "\n<A href='?src=\ref[src];sendtodock=1'>Send away</A><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Send to station</A><BR>\n<BR>"]
		\n<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>\n<BR>
		\n<A href='?src=\ref[src];vieworders=1'>View orders</A><BR>\n<BR>
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/supplycomp/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag) && !hacked)
		var/obj/item/weapon/card/emag/E = I
		if(E.uses)
			E.uses--
		else
			return
		user << "\blue Special supplies unlocked."
		src.hacked = 1
		return
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/weapon/shard( src.loc )
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/supplycomp/M = new /obj/item/weapon/circuitboard/supplycomp( A )
				if(src.can_order_contraband)
					M.contraband_enabled = 1
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

	//From Station to Centcomm
	if (href_list["sendtodock"])
		if(!supply_shuttle_at_station || supply_shuttle_moving) return

		if (!supply_can_move())
			usr << "\red The supply shuttle can not transport station employees, exosuits, classified nuclear codes or homing beacons."
			return

		src.temp = "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.updateUsrDialog()
		post_signal("supply")

		supply_shuttle_shoppinglist = null
		supply_shuttle_shoppinglist = new/list()

		sell_crates()

		//Remove anything or anyone that was either left behind or that bypassed supply_can_move() -Nodrak
		for(var/area/supply/station/A in world)
			for(var/obj/item/I in A.contents)
				del(I)
			for(var/mob/living/M in A.contents)
				del(M)

		send_supply_shuttle()

	//From Centcomm to Station
	else if (href_list["sendtostation"])
		if(supply_shuttle_at_station || supply_shuttle_moving) return

		if (!supply_can_move())
			usr << "\red The supply shuttle can not transport station employees, exosuits, classified nuclear codes or homing beacons."
			return

		post_signal("supply")
		usr << "\blue The supply shuttle has been called and will arrive in [round(((SUPPLY_MOVETIME/10)/60))] minutes."

		src.temp = "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.updateUsrDialog()

		supply_shuttle_moving = 1

		process_supply_order()

		supply_shuttle_time = world.timeofday + SUPPLY_MOVETIME
		spawn(0)
			supply_process()

	if (href_list["order"])
		src.temp = "Supply points: [supply_shuttle_points]<BR><HR><BR>Request what?<BR><BR>"
		for(var/G in supply_groups)
			src.temp += "<A href='?src=\ref[src];order_group=[G]'>[G]</A><br>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>Back</A>"

	else if (href_list["order_group"])
		var/G = href_list["order_group"]
		if(supply_shuttle_moving) return
		src.temp = "Supply points: [supply_shuttle_points]<BR><HR><BR>Request what?<BR><BR>"
		for(var/S in (typesof(/datum/supply_packs) - /datum/supply_packs - /datum/supply_packs/charge) )
			var/datum/supply_packs/N = new S()
			if(N.hidden && !src.hacked) continue													//Have to send the type instead of a reference to
			if(N.contraband && !src.can_order_contraband){continue;} //Agouri -Kavalamarker
			if(N.group != G) continue																//correct group?
			src.temp += "<A href='?src=\ref[src];doorder=[N.type]'>[N.name]</A> Cost: [N.cost]<BR>" //the obj because it would get caught by the garbage
		src.temp += "<BR><A href='?src=\ref[src];order=1'>Back</A>"								//collector. oh well.

	else if (href_list["doorder"])

		if(locate(href_list["doorder"])) //Comes from the requestlist
			var/datum/supply_order/O = locate(href_list["doorder"])
			var/datum/supply_packs/P = O.object
			supply_shuttle_requestlist -= O

			if(supply_shuttle_points >= P.cost)
				supply_shuttle_points -= P.cost
				O.object = P
				O.orderedby = usr.name
				O.comment = copytext(sanitize(input(usr,"Comment:","Enter comment","")),1,MAX_MESSAGE_LEN)
				supply_shuttle_shoppinglist += O
				src.temp = "Thanks for your order.<BR>"
				src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			else
				src.temp = "Not enough supply points.<BR>"
				src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

		else							//Comes from the orderform
			var/datum/supply_order/O = new/datum/supply_order ()
			var/supplytype = href_list["doorder"]
			var/datum/supply_packs/P = new supplytype ()
			if(supply_shuttle_points >= P.cost)
				supply_shuttle_points -= P.cost
				O.object = P
				O.orderedby = usr.name
				O.comment = copytext(sanitize(input(usr,"Comment:","Enter comment","")),1,MAX_MESSAGE_LEN)
				supply_shuttle_shoppinglist += O
				src.temp = "Thanks for your order.<BR>"
				src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			else
				src.temp = "Not enough supply points.<BR>"
				src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["vieworders"])
		src.temp = "Current approved orders: <BR><BR>"
		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			src.temp = "[SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""]<BR>" + src.temp// <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
/*
	else if (href_list["cancelorder"])
		var/datum/supply_order/remove_supply = href_list["cancelorder"]
		supply_shuttle_shoppinglist -= remove_supply
		supply_shuttle_points += remove_supply.object.cost
		src.temp += "Canceled: [remove_supply.object.name]<BR><BR><BR>"

		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			src.temp += "[SO.object.name] approved by [SO.orderedby][SO.comment ? " ([SO.comment])":""] <A href='?src=\ref[src];cancelorder=[S]'>(Cancel)</A><BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
*/
	else if (href_list["viewrequests"])
		src.temp = "Current requests: <BR><BR>"
		for(var/S in supply_shuttle_requestlist)
			var/datum/supply_order/SO = S
			src.temp = "[SO.object.name] requested by [SO.orderedby]  [supply_shuttle_moving ? "":supply_shuttle_at_station ? "":"<A href='?src=\ref[src];doorder=\ref[SO]'>Approve</A> <A href='?src=\ref[src];rreq=\ref[SO]'>Remove</A>"]<BR>" + src.temp

		src.temp += "<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["rreq"])
		supply_shuttle_requestlist -= locate(href_list["rreq"])
		src.temp = "Request removed.<BR>"
		src.temp += "<BR><A href='?src=\ref[src];viewrequests=1'>OK</A>"

	else if (href_list["clearreq"])
		supply_shuttle_requestlist = null
		supply_shuttle_requestlist = new/list()
		src.temp = "List cleared.<BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		src.temp = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)



/proc/send_supply_shuttle()

	if (supply_shuttle_moving) return

	var/area/the_shuttles_way = locate(SUPPLY_STATION_AREATYPE)

	//Do I really need to explain this loop?
	for(var/mob/living/unlucky_person in the_shuttles_way)
		unlucky_person.gib()

	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE
	var/shuttleto = !supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	var/area/from = locate(shuttleat)
	var/area/dest = locate(shuttleto)

	if(!from || !dest) return

	from.move_contents_to(dest)
	supply_shuttle_at_station = !supply_shuttle_at_station

/*
*	Supply depot control console
*/
/obj/machinery/supply_depot_console
	name = "Supply Depot Console"
	icon = 'terminals.dmi'
	icon_state = "production_console"
	density = 0
	anchored = 1
	var/id = ""
	var/obj/machinery/supply_depot/machine = null
	var/machinedir = SOUTHWEST

/obj/machinery/supply_depot_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/supply_depot, get_step(src, machinedir))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/supply_depot_console/attack_hand(user as mob)
	// Not ID-locked for now. Maybe in a late update.

	var/dat

	dat += text("<h3>Raw Materials Storage</h3>")

	var/canrelease = 0
	if (machine.totalmaterial > 0)
		// Loop through the items in our inventory
		for (var/material in machine.inventory)
			var/temp = machine.inventory[material]
			if (temp["amt"] > 0)

				// Can we press the "release" button?
				if (temp["rel"] > 0)
					canrelease = 1

				// The things I do to make it look good...
				dat += text("<span style='text-transform:capitalize;'>[(temp["name"]) ? temp["name"] : material]:</span> <a href='?src=\ref[src];setrelease=[material]'>[temp["rel"]]</a> ([temp["amt"]] remaining)<br>")
	else
		dat += "No materials loaded."

	dat += text("<br>Storage space remaining: [(machine.MAX_MATERIAL - machine.totalmaterial < machine.MAX_MATERIAL/10) ? "<font color='#f00'><b>" : ""][machine.MAX_MATERIAL - machine.totalmaterial][(machine.MAX_MATERIAL - machine.totalmaterial < machine.MAX_MATERIAL/10) ? "</b></font>" : ""]<br>") // Warn the operator when we're at 90% capacity
	dat += text("Print manifest: <a href='?src=\ref[src];toggleprint=1>'>[machine.printmanifest ? "Yes" : "No"]</a><br><br>")

	dat += text("<a href='?src=\ref[src];load=1'>Load material</a><br>")
	if (canrelease)
		dat += text("<a href='?src=\ref[src];release=1'>Release materials</a><br>")

	user << browse("[dat]", "window=console_stacking_machine")

/obj/machinery/supply_depot_console/Topic(href, href_list)
	if (..())
		return
	usr.machine = src
	src.add_fingerprint(usr)

	if (href_list["setrelease"])
		if (machine.inventory[href_list["setrelease"]]["amt"] > 0)
			var/release = text2num(sanitize(input("Amount of [lowertext(machine.inventory[href_list["setrelease"]]["name"])] to release (max 500):", "Amount to release", num2text(machine.inventory[href_list["setrelease"]]["rel"]))))

			// For sanity's sake, we don't drop more than 10 stacks at a time.
			if (release > 500)
				release = 500
			else if (release < 0)
				release = 0

			machine.inventory[href_list["setrelease"]]["rel"] = release

	else if (href_list["toggleprint"])

		machine.printmanifest = !machine.printmanifest

	else if (href_list["load"])

		machine.load_materials(machine.output.loc)

	else if (href_list["release"])

		// Do it.
		machine.release_materials()

	src.updateUsrDialog()
	return

/*
*	Supply depot machine
*/
/obj/machinery/supply_depot
	name = "supply depot"
	icon_state = "supply_depot"
	density = 1
	anchored = 1
	var/id = ""
	var/machine = null
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/supply_depot_console/CONSOLE

	// TODO: This will eventually incorporate researchable material bins to expand the depot's capacity.
	// Until then, let's just give it a reasonably large starting capacity.
	// This will probably go down to 2,500 as soon as it can be upgraded to 5k, 7.5k or 10k.
	// Or infinite, if research feels like giving cargo a bag of holding, the miserly fucks.

	var/MAX_MATERIAL = 5000 // The upper limit of -all- materials in the machine (default 100 stacks of 50)
	var/totalmaterial = 0 // The total amount it's holding
	var/printmanifest = 1 // Print a manifest when releasing material?
	var/inventory[0] // See below.

/obj/machinery/supply_depot/New()
	..()

	// name is a display name if the item name isn't suitable
	// amt is how much is in the machine
	// rel is how much we're releasing in this shipment
	inventory["metal"] = list(name = "iron", "amt" = 0, "rel" = 50)
	inventory["plasteel"] = list("amt" = 0, "rel" = 50)
	inventory["glass"] = list("amt" = 0, "rel" = 50)
	inventory["rglass"] = list("name" = "reinforced glass", "amt" = 0, "rel" = 50)
	inventory["plasma"] = list("amt" = 0, "rel" = 50)
	inventory["gold"] = list("amt" = 0, "rel" = 50)
	inventory["silver"] = list("amt" = 0, "rel" = 50)
	inventory["uranium"] = list("amt" = 0, "rel" = 50)
	inventory["diamond"] = list("amt" = 0, "rel" = 50)
	inventory["clown"] = list("name" = "bananium", "amt" = 0, "rel" = 50) // HONK
	inventory["adamantine"] = list("amt" = 0, "rel" = 50)
	inventory["mythril"] = list("amt" = 0, "rel" = 50)

	spawn(5)
		// Find input
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if (src.input) break
		// Find output
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if (src.output) break
		// process_objects.Add(src)
		return
	return

// Suck up all processable matter from a given location, moving anything we can't
// process to an arbitrary location.
/obj/machinery/supply_depot/proc/load_materials(target, passthrough)
	// No overloading.
	if (totalmaterial >= MAX_MATERIAL)
		return

	if (target)
		var/obj/item/stack/sheet/O
		while (locate(/obj/item/stack/sheet, target))
			O = locate(/obj/item/stack/sheet, target)
			var/found = 0

			// Can we fit any more in?
			if (totalmaterial + O.amount < MAX_MATERIAL)
				for (var/material in inventory)
					if (istype(O, text2path("/obj/item/stack/sheet/[material]")))
						inventory[material]["amt"] += O.amount
						totalmaterial += O.amount
						del(O)
						found = 1
						break
			else
				// Nope. Max us out and edit the material's amount. We're not deleting it.
				for (var/material in inventory)
					if (istype(O, text2path("/obj/item/stack/sheet/[material]")))
						inventory[material]["amt"] += (MAX_MATERIAL - totalmaterial)
						totalmaterial = MAX_MATERIAL
						O.amount = MAX_MATERIAL - totalmaterial
						found = 1
						break

			if (found)
				continue
			else
				// Anything we don't want gets moved through
				if (passthrough)
					O.loc = passthrough

// Release a given batch of materials
/obj/machinery/supply_depot/proc/release_materials()

	// Can we actually release anything in the first place?
	var/canrelease = 0
	for (var/material in inventory)
		if (inventory[material]["amt"] > 0 && inventory[material]["rel"] > 0)
			canrelease = 1
	if (!canrelease) return

	// Get us a cargo manifest if applicable...
	if (ordernum)
		ordernum++
	else
		ordernum = rand(500,5000)

	var/obj/item/weapon/paper/manifest/slip
	if (printmanifest)
		slip = new /obj/item/weapon/paper/manifest(output.loc)
		slip.info = ""
		slip.info +="<h3>[command_name()] Internal Shipping Manifest</h3><hr><br>"
		slip.info +="Order #: [ordernum]<br>"
		slip.info +="CONTENTS:<br><ul>"

	// Now actually spawn the items we're releasing and add them to the manifest
	for (var/material in inventory)
		var/temp = inventory[material]
		if (temp["amt"] <= 0 || temp["rel"] <= 0)
			continue

		// If we're trying to draw more than we have, correct it.
		if (temp["rel"] > temp["amt"])
			temp["rel"] = temp["amt"]

		// Subtract material before we go any further
		inventory[material]["amt"] -= temp["rel"]
		totalmaterial -= temp["rel"]

		var/path = text2path("/obj/item/stack/sheet/[material]")
		if (path)
			// Need this outside of the ifs so we can get the name afterward.
			var obj/item/stack/sheet/G

			// Get our full stacks
			for (var/i = 1, i <= round(temp["rel"] / 50), i++)
				G = new path
				G.amount = 50
				G.loc = output.loc

			// Get our remainder
			if (temp["rel"] % 50)
				G = new path
				G.amount = temp["rel"] % 50
				G.loc = output.loc

			// Try to get the "official" object name if possible.
			if (printmanifest)
				slip.info += "<li>[temp["rel"]] units [(G.name) ? G.name : (temp["name"]) ? temp["name"] : material]</li>"

	// Close up the cargo manifest
	if (printmanifest)
		slip.info += "</ul><br>CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>"
		slip.loc = output.loc

/obj/machinery/supply_depot/process()
	if (src.input && src.output)
		load_materials(input.loc, output.loc)