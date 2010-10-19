//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_POINTSPER 10      //Points per tick.
#define SUPPLY_POINTDELAY 3000 //Delay between ticks in milliseconds.
#define SUPPLY_MOVETIME 1800	//Time to station is milliseconds.
#define SUPPLY_POINTSPERCRATE 5	//Points per crate sent back.
#define SUPPLY_STATION_AREATYPE "/area/supply/station" //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE "/area/supply/dock"	//Type of the supply shuttle area for dock

var/supply_shuttle_moving = 0
var/supply_shuttle_at_station = 0
var/list/supply_shuttle_shoppinglist = new/list()
var/list/supply_shuttle_requestlist = new/list()
var/supply_shuttle_can_send = 1
var/supply_shuttle_time = 0
var/supply_shuttle_timeleft = 0
var/supply_shuttle_points = 50

/area/supply/station //DO NOT TURN THE SD_LIGHTING STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	sd_lighting = 0
	requires_power = 0

/area/supply/dock //DO NOT TURN THE SD_LIGHTING STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "supply shuttle"
	icon_state = "shuttle3"
	luminosity = 1
	sd_lighting = 0
	requires_power = 0

//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.

/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list("/obj/item/weapon/storage/emp_kit",
					"/obj/item/weapon/smokebomb",
					"/obj/item/weapon/smokebomb",
					"/obj/item/weapon/smokebomb",
					"/obj/item/weapon/pen/sleepypen",
					"/obj/item/weapon/incendiarygrenade")
	cost = 20
	containertype = "/obj/crate"
	containername = "Special Ops crate"
	hidden = 1

/datum/supply_packs/wizard
	name = "Wizard costume"
	contains = list("/obj/item/weapon/staff",
					"/obj/item/clothing/suit/wizrobe",
					"/obj/item/clothing/shoes/sandal",
					"/obj/item/clothing/head/wizard")
	cost = 20
	containertype = "/obj/crate"
	containername = "Wizard costume crate"

/datum/supply_packs/metal50
	name = "50 Metal Sheets"
	contains = list("/obj/item/weapon/sheet/metal")
	amount = 50
	cost = 15
	containertype = "/obj/crate"
	containername = "Metal sheets crate"

/datum/supply_packs/glass50
	name = "50 Glass Sheets"
	contains = list("/obj/item/weapon/sheet/glass")
	amount = 50
	cost = 15
	containertype = "/obj/crate"
	containername = "Glass sheets crate"

/datum/supply_packs/internals
	name = "Internals crate"
	contains = list("/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/clothing/mask/gas",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air",
					"/obj/item/weapon/tank/air")
	cost = 10
	containertype = "/obj/crate/internals"
	containername = "Internals crate"

/datum/supply_packs/food
	name = "Food crate"
	contains = list("/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/flour",
					"/obj/item/weapon/reagent_containers/food/snacks/faggot",
					"/obj/item/weapon/reagent_containers/food/snacks/faggot",
					"/obj/item/weapon/reagent_containers/food/snacks/faggot",
					"/obj/item/kitchen/egg_box",
					"/obj/item/weapon/banana",
					"/obj/item/weapon/banana",
					"/obj/item/weapon/banana")
	cost = 5
	containertype = "/obj/crate/freezer"
	containername = "Food crate"

/datum/supply_packs/monkey
	name = "Monkey crate"
	contains = list("/mob/living/carbon/monkey",
					"/mob/living/carbon/monkey",
					"/mob/living/carbon/monkey",
					"/mob/living/carbon/monkey",
					"/mob/living/carbon/monkey")
	cost = 20
	containertype = "/obj/crate/freezer"
	containername = "Monkey crate"

/datum/supply_packs/engineering
	name = "Engineering crate"
	contains = list("/obj/item/weapon/storage/toolbox/electrical",
					"/obj/item/weapon/storage/toolbox/electrical",
					"/obj/item/clothing/head/helmet/welding",
					"/obj/item/clothing/head/helmet/welding",
					"/obj/item/weapon/cell", // -- TLE
					"/obj/item/weapon/cell",
					"/obj/item/clothing/gloves/yellow",
					"/obj/item/clothing/gloves/yellow")
	cost = 5
	containertype = "/obj/crate"
	containername = "Engineering crate"

/datum/supply_packs/medical
	name = "Medical crate"
	contains = list("/obj/item/weapon/storage/firstaid/regular",
					"/obj/item/weapon/storage/firstaid/fire",
					"/obj/item/weapon/storage/firstaid/toxin",
					"/obj/item/weapon/reagent_containers/glass/bottle/antitoxin",
					"/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline",
					"/obj/item/weapon/reagent_containers/glass/bottle/stoxin",
					"/obj/item/weapon/storage/firstaid/syringes")
	cost = 10
	containertype = "/obj/crate/medical"
	containername = "Medical crate"


/datum/supply_packs/virus
	name = "Virus crate"
	contains = list("/obj/item/weapon/reagent_containers/glass/bottle/flu_virion",
					"/obj/item/weapon/reagent_containers/glass/bottle/cold",
					"/obj/item/weapon/reagent_containers/glass/bottle/fake_gbs",
					"/obj/item/weapon/reagent_containers/glass/bottle/magnitis",
					"/obj/item/weapon/reagent_containers/glass/bottle/wizarditis",
//					"/obj/item/weapon/reagent_containers/glass/bottle/gbs", No. Just no.
					"/obj/item/weapon/reagent_containers/glass/bottle/brainrot",
					"/obj/item/weapon/storage/firstaid/syringes",
					"/obj/item/weapon/storage/beakerbox")
	cost = 20
	containertype = "/obj/crate/freezer"
	containername = "Virus crate"


/datum/supply_packs/janitor
	name = "Janitorial supplies"
	contains = list("/obj/item/weapon/reagent_containers/glass/bucket",
					"/obj/item/weapon/reagent_containers/glass/bucket",
					"/obj/item/weapon/reagent_containers/glass/bucket",
					"/obj/item/weapon/mop",
					"/obj/item/weapon/caution",
					"/obj/item/weapon/caution",
					"/obj/item/weapon/caution",
					"/obj/item/weapon/cleaner",
					"/obj/item/weapon/chem_grenade/cleaner",
					"/obj/item/weapon/chem_grenade/cleaner",
					"/obj/item/weapon/chem_grenade/cleaner",
					"/obj/mopbucket")
	cost = 10
	containertype = "/obj/crate"
	containername = "Janitorial supplies"

/datum/supply_packs/plasma
	name = "Plasma assembly crate"
	contains = list("/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/device/igniter",
					"/obj/item/device/igniter",
					"/obj/item/device/igniter",
					"/obj/item/device/prox_sensor",
					"/obj/item/device/prox_sensor",
					"/obj/item/device/prox_sensor",
					"/obj/item/device/timer",
					"/obj/item/device/timer",
					"/obj/item/device/timer")
	cost = 10
	containertype = "/obj/crate/secure/plasma"
	containername = "Plasma assembly crate"
	access = access_tox

/datum/supply_packs/weapons
	name = "Weapons crate"
	contains = list("/obj/item/weapon/baton",
					"/obj/item/weapon/baton",
					"/obj/item/weapon/gun/energy/laser_gun",
					"/obj/item/weapon/gun/energy/laser_gun",
					"/obj/item/weapon/gun/energy/taser_gun",
					"/obj/item/weapon/gun/energy/taser_gun",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/storage/flashbang_kit")
	cost = 20
	containertype = "/obj/crate/secure/weapon"
	containername = "Weapons crate"
	access = access_security

/datum/supply_packs/eweapons
	name = "Experimental weapons crate"
	contains = list("/obj/item/weapon/flamethrower",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/tank/plasma",
					"/obj/item/weapon/incendiarygrenade",
					"/obj/item/weapon/incendiarygrenade",
					"/obj/item/weapon/incendiarygrenade",
					"/obj/item/clothing/gloves/stungloves")
	cost = 25
	containertype = "/obj/crate/secure/weapon"
	containername = "Experimental weapons crate"
	access = access_heads

/datum/supply_packs/riot
	name = "Riot crate"
	contains = list("/obj/item/weapon/baton",
					"/obj/item/weapon/baton",
					"/obj/item/weapon/shield/riot",
					"/obj/item/weapon/shield/riot",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/storage/flashbang_kit",
					"/obj/item/weapon/handcuffs",
					"/obj/item/weapon/handcuffs")
	cost = 30
	containertype = "/obj/crate/secure/gear"
	containername = "Riot crate"
	access = access_security

/datum/supply_packs/evacuation
	name = "Emergency equipment"
	contains = list("/obj/machinery/bot/floorbot",
	"/obj/machinery/bot/floorbot",
	"/obj/machinery/bot/floorbot",
	"/obj/machinery/bot/floorbot",
	"/obj/item/weapon/tank/air",
	"/obj/item/weapon/tank/air",
	"/obj/item/weapon/tank/air",
	"/obj/item/weapon/tank/air",
	"/obj/item/weapon/tank/air",
	"/obj/item/clothing/mask/gas",
	"/obj/item/clothing/mask/gas",
	"/obj/item/clothing/mask/gas",
	"/obj/item/clothing/mask/gas",
	"/obj/item/clothing/mask/gas")
	cost = 35
	containertype = "/obj/crate/internals"
	containername = "Emergency Crate"

/datum/supply_packs/party
	name = "Party equipment"
	contains = list("/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer",
	"/obj/item/weapon/reagent_containers/food/drinks/beer")
	cost = 20
	containertype = "/obj/crate"
	containername = "Party equipment"
/*
/datum/supply_packs/hats
	name = "Clown Gear"
	contains = list("/obj/item/clothing/head/that",
	"/obj/item/clothing/under/psyche",
	"/obj/item/clothing/under/johnny",
	"/obj/item/clothing/under/mario",
	"/obj/item/clothing/under/luigi",
	"/obj/item/clothing/head/butt")
	cost = 20
	containertype = "/obj/crate"
	containername = "Clown Gear"
*/

/datum/supply_packs/mule
	name = "MULEbot Crate"
	contains = list("/obj/machinery/bot/mulebot")
	cost = 20
	containertype = "/obj/crate"
	containername = "MULEbot Crate"

/datum/supply_packs/robotics
	name = "Robotics Assembly Crate"
	contains = list("/obj/item/device/prox_sensor",
	"/obj/item/device/prox_sensor",
	"/obj/item/device/prox_sensor",
	"/obj/item/weapon/storage/toolbox/electrical",
	"/obj/item/device/flash",
	"/obj/item/device/flash",
	"/obj/item/device/flash",
	"/obj/item/device/flash",
	"/obj/item/weapon/cell/robotcrate",
	"/obj/item/weapon/cell/robotcrate")
	cost = 10
	containertype = /obj/crate/secure/gear
	containername = "Robotics Assembly"
	access = access_robotics

/datum/supply_packs/hydroponics // -- Skie
	name = "Hydroponics Supply Crate"
	contains = list("/obj/item/weapon/plantbgone",
	"/obj/item/weapon/plantbgone",
	"/obj/item/weapon/plantbgone",
	"/obj/item/weapon/weedspray",
	"/obj/item/weapon/weedspray",
	"/obj/item/weapon/weedspray",
	"/obj/item/weapon/pestspray",
	"/obj/item/weapon/pestspray",
	"/obj/item/weapon/pestspray",
	"/obj/item/clothing/gloves/latex",
	"/obj/item/clothing/gloves/latex") // For handling nettles etc
	cost = 10
	containertype = /obj/crate/hydroponics
	containername = "Hydroponics crate"
	access = access_hydroponics

//SUPPLY PACKS

/obj/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "Plastic flaps"
	desc = "I definitely cant get past those. no way."
	icon = 'stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4

/obj/plasticflaps/CanPass(atom/A, turf/T)
	if (istype(A, /mob/living)) // You Shall Not Pass!
		var/mob/living/M = A
		if(!M.lying)			// unless you're lying down
			return 0
	return ..()

/obj/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			del(src)
		if (2)
			if (prob(50))
				del(src)
		if (3)
			if (prob(5))
				del(src)

/area/supplyshuttle/
	name = "Supply Shuttle"
	icon_state = "supply"
	requires_power = 0

/obj/machinery/computer/supplycomp
	name = "Supply shuttle console"
	icon = 'computer.dmi'
	icon_state = "comm"
	req_access = list(access_cargo)
	var/temp = null
	var/hacked = 0

/obj/machinery/computer/ordercomp
	name = "Supply ordering console"
	icon = 'computer.dmi'
	icon_state = "comm"
	var/temp = null

/obj/marker/supplymarker
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

	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	for(var/turf/T in get_area_turfs(shuttleat) )
		if((locate(/mob/living) in T) && (!locate(/mob/living/carbon/monkey) in T)) return 0
		for(var/atom/ATM in T)
			if((locate(/mob/living) in ATM) && (!locate(/mob/living/carbon/monkey) in ATM)) return 0

	return 1

/proc/sell_crates()
	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	for(var/turf/T in get_area_turfs(shuttleat) )
		var/crate = locate(/obj/crate) in T
		if (crate)
			del(crate)
			supply_shuttle_points += SUPPLY_POINTSPERCRATE

/proc/process_supply_order()
	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	var/list/markers = new/list()

	if(!supply_shuttle_shoppinglist.len) return

	for(var/turf/T in get_area_turfs(shuttleat))
		for(var/obj/marker/supplymarker/D in T)
			markers += D

	for(var/S in supply_shuttle_shoppinglist)
		var/pickedloc = 0
		var/found = 0
		for(var/C in markers)
			if (locate(/obj/crate) in get_turf(C)) continue
			found = 1
			pickedloc = get_turf(C)
		if (!found) pickedloc = get_turf(pick(markers))
		var/datum/supply_order/SO = S
		var/datum/supply_packs/SP = SO.object

		var/atom/A = new SP.containertype ( pickedloc )
		A.name = "[SP.containername] [SO.comment ? "([SO.comment])":"" ]"
		if(SP.access)
			A:req_access = new/list()
			A:req_access += text2num(SP.access)
		for(var/B in SP.contains)
			var/thepath = text2path(B)
			var/atom/B2 = new thepath (A)
			if(SP.amount && B2:amount) B2:amount = SP.amount

	return

/obj/machinery/computer/ordercomp/attackby(I as obj, user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/ordercomp/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/ordercomp/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/supplycomp/attackby(I as obj, user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/supplycomp/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/supplycomp/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/supplycomp/attackby(I as obj, user as mob)
	if(istype(I,/obj/item/weapon/card/emag) && !hacked)
		user << "\blue Special supplies unlocked."
		src.hacked = 1
	else
		return src.attack_hand(user)

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user as mob)
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
		for(var/S in (typesof(/datum/supply_packs) - /datum/supply_packs) )
			var/datum/supply_packs/N = new S()
			if(N.hidden) continue																	//Have to send the type instead of a reference to
			src.temp += "<A href='?src=\ref[src];doorder=[N.type]'>[N.name]</A> Cost: [N.cost]<BR>" //the obj because it would get caught by the garbage
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"								//collector. oh well.

	else if (href_list["doorder"])
		var/datum/supply_order/O = new/datum/supply_order ()
		var/supplytype = href_list["doorder"]
		var/datum/supply_packs/P = new supplytype ()
		O.object = P
		O.orderedby = usr.name
		supply_shuttle_requestlist += O
		src.temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["vieworders"])
		src.temp = "Current approved orders: <BR><BR>"
		for(var/S in supply_shuttle_shoppinglist)
			var/datum/supply_order/SO = S
			src.temp += "[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]<BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["viewrequests"])
		src.temp = "Current requests: <BR><BR>"
		for(var/S in supply_shuttle_requestlist)
			var/datum/supply_order/SO = S
			src.temp += "[SO.object.name] requested by [SO.orderedby]<BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["mainmenu"])
		src.temp = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user as mob)
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
		\nLocation: [supply_shuttle_moving ? "Moving to station ([supply_shuttle_timeleft] Mins.)":supply_shuttle_at_station ? "Station":"Dock"]<BR>
		<HR>\nSupply points: [supply_shuttle_points]<BR>\n<BR>
		[supply_shuttle_moving ? "\n*Must be at dock to order items*<BR>\n<BR>":supply_shuttle_at_station ? "\n*Must be at dock to order items*<BR>\n<BR>":"\n<A href='?src=\ref[src];order=1'>Order items</A><BR>\n<BR>"]
		[supply_shuttle_moving ? "\n*Shuttle already called*<BR>\n<BR>":supply_shuttle_at_station ? "\n<A href='?src=\ref[src];sendtodock=1'>Send to Dock</A><BR>\n<BR>":"\n<A href='?src=\ref[src];sendtostation=1'>Send to station</A><BR>\n<BR>"]
		\n<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR>\n<BR>
		\n<A href='?src=\ref[src];vieworders=1'>View orders</A><BR>\n<BR>
		\n<A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src

	if (href_list["sendtodock"])
		if(!supply_shuttle_at_station || supply_shuttle_moving) return

		if (!supply_can_move())
			usr << "\red The supply shuttle can not transport station employees."
			return

		src.temp = "Shuttle sent.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		src.updateUsrDialog()
		post_signal("supply")

		supply_shuttle_shoppinglist = null
		supply_shuttle_shoppinglist = new/list()

		sell_crates()
		send_supply_shuttle()

	else if (href_list["sendtostation"])
		if(supply_shuttle_at_station || supply_shuttle_moving) return

		if (!supply_can_move())
			usr << "\red The supply shuttle can not transport station employees."
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
		if(supply_shuttle_moving) return
		src.temp = "Supply points: [supply_shuttle_points]<BR><HR><BR>Request what?<BR><BR>"
		for(var/S in (typesof(/datum/supply_packs) - /datum/supply_packs) )
			var/datum/supply_packs/N = new S()
			if(N.hidden && !src.hacked) continue													//Have to send the type instead of a reference to
			src.temp += "<A href='?src=\ref[src];doorder=[N.type]'>[N.name]</A> Cost: [N.cost]<BR>" //the obj because it would get caught by the garbage
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"								//collector. oh well.

	else if (href_list["doorder"])

		if(locate(href_list["doorder"])) //Comes from the requestlist
			var/datum/supply_order/O = locate(href_list["doorder"])
			var/datum/supply_packs/P = O.object
			supply_shuttle_requestlist -= O

			if(supply_shuttle_points >= P.cost)
				supply_shuttle_points -= P.cost
				O.object = P
				O.orderedby = usr.name
				O.comment = input(usr,"Comment:","Enter comment","")
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
				O.comment = input(usr,"Comment:","Enter comment","")
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
			src.temp += "[SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]<BR>"
		src.temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["viewrequests"])
		src.temp = "Current requests: <BR><BR>"
		for(var/S in supply_shuttle_requestlist)
			var/datum/supply_order/SO = S
			src.temp += "[SO.object.name] requested by [SO.orderedby]  [supply_shuttle_moving ? "":supply_shuttle_at_station ? "":"<A href='?src=\ref[src];doorder=\ref[SO]'>Approve</A> <A href='?src=\ref[src];rreq=\ref[SO]'>Remove</A>"]<BR>"

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

	var/datum/radio_frequency/frequency = radio_controller.return_frequency("1435")

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)



/proc/send_supply_shuttle()

	if (supply_shuttle_moving) return

	if (!supply_can_move())
		usr << "\red The supply shuttle can not transport station employees."
		return

	var/shuttleat = supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE
	var/shuttleto = !supply_shuttle_at_station ? SUPPLY_STATION_AREATYPE : SUPPLY_DOCK_AREATYPE

	var/area/from = locate(shuttleat)
	var/area/dest = locate(shuttleto)

	if(!from || !dest) return

	from.move_contents_to(dest)
	supply_shuttle_at_station = !supply_shuttle_at_station
