/obj/machinery/gateway
	name = "gateway"
	desc = "It's a Nanotrasen approved one-way experimental teleporter that will take you places. Still has the pricetag on it."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1
	anchored = 1
	var/active = 0

/obj/machinery/gateway/initialize()
	update_icon()
	if(dir == 2)
		density = 0

/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
		return
	icon_state = "off"



//this is da important part wot makes things go
/obj/machinery/gateway/center
	density = 1
	icon_state = "offcenter"
	use_power = 1

	//warping vars
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0				//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start

	//power vars
	var/obj/structure/cable/attached = null

/obj/machinery/gateway/center/initialize()
	update_icon()
	attemptAttach()

	if(src.z == 1)	//if it's the station gate
		returndestination = get_step(loc, SOUTH)
		wait = world.time + 18000	//+ thirty minutes

/obj/machinery/gateway/center/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

//stolen from syndie beacon code.
/obj/machinery/gateway/center/proc/checkWirePower()
	if(!attached)
		return 0
	var/datum/powernet/PN = attached.get_powernet()
	if(!PN)
		return 0
	if(PN.avail < 128000)
		return 0
	return 1

obj/machinery/gateway/center/process()
	if(stat & (NOPOWER))
		if(active) toggleoff()
		return

	if(active)
		use_power(128000)

/obj/machinery/gateway/center/proc/detect()
	linked = list()	//clear the list
	var/turf/T = loc

	for(var/i in alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = 0
		toggleoff()
		break

	if(linked.len == 8)
		ready = 1

/obj/machinery/gateway/center/proc/toggleon(mob/user as mob)
	if(!ready) return
	if(linked.len != 8) return
	if(!powered()) return
	if(world.time < wait)
		user << "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>"
		return
	if(!awaydestinations.len)
		user << "<span class='notice'>Error: No destination found.</span>"
		return
	if(!checkWirePower())
		user << "<span class='notice'>Error: Inadequate electricity reserve.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()
	density = 0

/obj/machinery/gateway/center/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()
	density = 1

/obj/machinery/gateway/center/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

/obj/machinery/gateway/center/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/screwdriver))
		attemptAttach(user, 1)

//this is kinda ugly i know, but i want the attach proc seperate so we can call it in initialize()
/obj/machinery/gateway/center/proc/attemptAttach(mob/user as mob, tilesafe = 0)
	var/turf/T = loc
	if(tilesafe && T.intact)
		return
	if(isturf(T))
		attached = locate() in T
	if(user)
		if(!attached)
			user << "<span class='notice'>There isn't a cable to connect to [src].</span>"
			return
		user << "<span class='notice'>You attach the cable to [src].</span>"

//okay, here's the good teleporting stuff
/obj/machinery/gateway/center/HasEntered(mob/user as mob)
	if(!ready) return
	if(!active) return

	if(src.z == 1)	//if it's the station gate
		var/obj/effect/landmark/dest = pick(awaydestinations)
		if(dest)
//i'm sorry did i say good?
			user.loc = dest.loc
			use_power(128000)
		return
	else			//they made it back to the station!
		user.loc = returndestination
		user.dir = SOUTH
		use_power(128000)