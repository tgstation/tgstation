/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
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
/obj/machinery/gateway/centerstation
	density = 1
	icon_state = "offcenter"
	use_power = 1

	//warping vars
	var/list/linked = list()
	var/ready = 0				//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null //inb4 this doesnt work at all

/obj/machinery/gateway/centerstation/initialize()
	update_icon()
	returndestination = get_step(loc, SOUTH)
	wait = world.time + 18000	//+ thirty minutes
	awaygate = locate(/obj/machinery/gateway/centeraway, world)

/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"


obj/machinery/gateway/centerstation/process()
	if(stat & (NOPOWER))
		if(active) toggleoff()
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/centerstation/proc/detect()
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

/obj/machinery/gateway/centerstation/proc/toggleon(mob/user as mob)
	if(!ready) return
	if(linked.len != 8) return
	if(!powered()) return
	if(world.time < wait)
		user << "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>"
		return
	if(awaygate == null)
		user << "<span class='notice'>Error: No destination found.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()
	density = 0

/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()
	density = 1

/obj/machinery/gateway/centerstation/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()



//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/HasEntered(mob/user as mob)
	if(!ready) return
	if(!active) return
	if(awaygate == null) return
	if(awaygate.calibrated)
		calibrateddestination = get_step(awaygate.loc, SOUTH)
		user.loc = calibrateddestination
		return
	else
		var/obj/effect/landmark/dest = pick(awaydestinations)
		if(dest)
			user.loc = dest.loc
			user.dir = SOUTH
			use_power(5000)
		return





/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = 1
	icon_state = "offcenter"
	use_power = 0
	var/calibrated = 1
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0
	var/stationgate = null

/obj/machinery/gateway/centeraway/initialize()
	update_icon()
	calibrateddestination = get_step(loc, SOUTH)
	stationgate = locate(/obj/machinery/gateway/centerstation, world)


/obj/machinery/gateway/centeraway/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"


/obj/machinery/gateway/centeraway/proc/detect()
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



/obj/machinery/gateway/centeraway/proc/toggleon(mob/user as mob)
	if(!ready) return
	if(linked.len != 8) return
	if(stationgate == null)
		user << "<span class='notice'>Error: No destination found.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()
	density = 0

/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()
	density = 1



/obj/machinery/gateway/centeraway/attack_hand(mob/user as mob)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

/obj/machinery/gateway/centeraway/HasEntered(mob/user as mob)
	if(!ready) return
	if(!active) return
	user.loc = returndestination
	user.dir = SOUTH


/obj/machinery/gateway/centeraway/attackby(obj/item/device/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/multitool))
		if(calibrated == 1)
			user << "\black The gate is already calibrated, there is no work for you to do here."
			return
		else
			user << "\blue <b>Recalibration successful!</b>: \black The gates systems have been fine tuned, travel to the gate will now be on target."
			calibrated = 1
			return