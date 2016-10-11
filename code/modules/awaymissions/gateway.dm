var/obj/machinery/gateway/centerstation/the_gateway = null

/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = 1
	anchored = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/active = 0


/obj/machinery/gateway/centerstation/New()
	..()
	if(!the_gateway)
		the_gateway = src


/obj/machinery/gateway/centerstation/Destroy()
	if(the_gateway == src)
		the_gateway = null
	return ..()


/obj/machinery/gateway/initialize()
	update_icon()
	switch(dir)
		if(SOUTH,SOUTHEAST,SOUTHWEST)
			density = 0


/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
		return
	icon_state = "off"

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gateway/shuttleRotate()
	return

//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = 1
	icon_state = "offcenter"
	use_power = 1

	//warping vars
	var/list/linked = list()
	var/ready = 0				//have we got all the parts for a gateway?
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null

/obj/machinery/gateway/centerstation/initialize()
	update_icon()
	wait = world.time + config.gateway_delay	//+ thirty minutes default
	awaygate = locate(/obj/machinery/gateway/centeraway)


/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"



/obj/machinery/gateway/centerstation/process()
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


/obj/machinery/gateway/centerstation/proc/toggleon(mob/user)
	if(!ready)
		return
	if(linked.len != 8)
		return
	if(!powered())
		return
	if(!awaygate)
		user << "<span class='notice'>Error: No destination found.</span>"
		return
	if(world.time < wait)
		user << "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()


/obj/machinery/gateway/centerstation/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()


/obj/machinery/gateway/centerstation/attack_hand(mob/user)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/AM)
	if(!ready)
		return
	if(!active)
		return
	if(!awaygate || qdeleted(awaygate))
		return

	if(awaygate.calibrated)
		AM.forceMove(get_step(awaygate.loc, SOUTH))
		AM.setDir(SOUTH)
		if (ismob(AM))
			var/mob/M = AM
			if (M.client)
				M.client.move_delay = max(world.time + 5, M.client.move_delay)
		return
	else
		var/obj/effect/landmark/dest = pick(awaydestinations)
		if(dest)
			AM.forceMove(get_turf(dest))
			AM.setDir(SOUTH)
			use_power(5000)
		return


/obj/machinery/gateway/centerstation/attackby(obj/item/device/W, mob/user, params)
	if(istype(W,/obj/item/device/multitool))
		user << "\black The gate is already calibrated, there is no work for you to do here."
		return


/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = 1
	icon_state = "offcenter"
	use_power = 0
	var/calibrated = 1
	var/list/linked = list()	//a list of the connected gateway chunks
	var/ready = 0
	var/obj/machinery/gateway/centeraway/stationgate = null


/obj/machinery/gateway/centeraway/initialize()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation)


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


/obj/machinery/gateway/centeraway/proc/toggleon(mob/user)
	if(!ready)
		return
	if(linked.len != 8)
		return
	if(!stationgate)
		user << "<span class='notice'>Error: No destination found.</span>"
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()


/obj/machinery/gateway/centeraway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()


/obj/machinery/gateway/centeraway/attack_hand(mob/user)
	if(!ready)
		detect()
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()


/obj/machinery/gateway/centeraway/Bumped(atom/movable/AM)
	if(!ready)
		return
	if(!active)
		return
	if(!stationgate || qdeleted(stationgate))
		return
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/C = AM
		for(var/obj/item/weapon/implant/exile/E in C.implants)//Checking that there is an exile implant
			AM << "\black The station gate has detected your exile implant and is blocking your entry."
			return
	AM.forceMove(get_step(stationgate.loc, SOUTH))
	AM.setDir(SOUTH)
	if (ismob(AM))
		var/mob/M = AM
		if (M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)


/obj/machinery/gateway/centeraway/attackby(obj/item/device/W, mob/user, params)
	if(istype(W,/obj/item/device/multitool))
		if(calibrated)
			user << "\black The gate is already calibrated, there is no work for you to do here."
			return
		else
			user << "<span class='boldnotice'>Recalibration successful!</span>: \black This gate's systems have been fine tuned.  Travel to this gate will now be on target."
			calibrated = 1
			return
