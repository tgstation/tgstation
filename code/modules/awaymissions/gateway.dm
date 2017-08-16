GLOBAL_DATUM(the_gateway, /obj/machinery/gateway/centerstation)

/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/active = 0
	var/checkparts = TRUE
	var/list/obj/effect/landmark/randomspawns = list()
	var/calibrated = TRUE
	var/list/linked = list()
	var/can_link = FALSE	//Is this the centerpiece?

/obj/machinery/gateway/Initialize()
	randomspawns = GLOB.awaydestinations
	update_icon()
	if(!istype(src, /obj/machinery/gateway/centerstation) && !istype(src, /obj/machinery/gateway/centeraway))
		switch(dir)
			if(SOUTH,SOUTHEAST,SOUTHWEST)
				density = FALSE
	return ..()

/obj/machinery/gateway/proc/toggleoff()
	for(var/obj/machinery/gateway/G in linked)
		G.active = 0
		G.update_icon()
	active = 0
	update_icon()

/obj/machinery/gateway/proc/detect()
	if(!can_link)
		return FALSE
	linked = list()	//clear the list
	var/turf/T = loc
	var/ready = FALSE

	for(var/i in GLOB.alldirs)
		T = get_step(loc, i)
		var/obj/machinery/gateway/G = locate(/obj/machinery/gateway) in T
		if(G)
			linked.Add(G)
			continue

		//this is only done if we fail to find a part
		ready = FALSE
		toggleoff()
		break

	if((linked.len == 8) || !checkparts)
		ready = TRUE
	return ready

/obj/machinery/gateway/update_icon()
	if(active)
		icon_state = "on"
		return
	icon_state = "off"

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gateway/shuttleRotate()
	return

/obj/machinery/gateway/attack_hand(mob/user)
	if(!detect())
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

/obj/machinery/gateway/proc/toggleon(mob/user)
	return FALSE

/obj/machinery/gateway/centerstation/Initialize()
	. = ..()
	if(!GLOB.the_gateway)
		GLOB.the_gateway = src
	update_icon()
	wait = world.time + config.gateway_delay	//+ thirty minutes default
	awaygate = locate(/obj/machinery/gateway/centeraway)

/obj/machinery/gateway/centerstation/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	return ..()

//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = TRUE
	icon_state = "offcenter"
	use_power = IDLE_POWER_USE

	//warping vars
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null
	can_link = TRUE

/obj/machinery/gateway/centerstation/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

/obj/machinery/gateway/centerstation/process()
	if((stat & (NOPOWER)) && use_power)
		if(active)
			toggleoff()
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/centerstation/toggleon(mob/user)
	if(!detect())
		return
	if(!powered())
		return
	if(!awaygate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return
	if(world.time < wait)
		to_chat(user, "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [round(((wait - world.time) / 10) / 60)] minutes.</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/CollidedWith(atom/movable/AM)
	if(!active)
		return
	if(!detect())
		return
	if(!awaygate || QDELETED(awaygate))
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
		var/obj/effect/landmark/dest = pick(randomspawns)
		if(dest)
			AM.forceMove(get_turf(dest))
			AM.setDir(SOUTH)
			use_power(5000)
		return

/obj/machinery/gateway/centeraway/attackby(obj/item/device/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		if(calibrated)
			to_chat(user, "\black The gate is already calibrated, there is no work for you to do here.")
			return
		else
			to_chat(user, "<span class='boldnotice'>Recalibration successful!</span>: \black This gate's systems have been fine tuned.  Travel to this gate will now be on target.")
			calibrated = TRUE
			return

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = TRUE
	icon_state = "offcenter"
	use_power = NO_POWER_USE
	var/obj/machinery/gateway/centeraway/stationgate = null
	can_link = TRUE


/obj/machinery/gateway/centeraway/Initialize()
	. = ..()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation)


/obj/machinery/gateway/centeraway/update_icon()
	if(active)
		icon_state = "oncenter"
		return
	icon_state = "offcenter"

/obj/machinery/gateway/centeraway/toggleon(mob/user)
	if(!detect())
		return
	if(!stationgate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()

/obj/machinery/gateway/centeraway/proc/check_exile_implant(mob/living/carbon/C)
	for(var/obj/item/implant/exile/E in C.implants)//Checking that there is an exile implant
		to_chat(C, "\black The station gate has detected your exile implant and is blocking your entry.")
		return TRUE
	return FALSE

/obj/machinery/gateway/centeraway/CollidedWith(atom/movable/AM)
	if(!detect())
		return
	if(!active)
		return
	if(!stationgate || QDELETED(stationgate))
		return
	if(istype(AM, /mob/living/carbon))
		if(check_exile_implant(AM))
			return
	else
		for(var/mob/living/carbon/C in AM.contents)
			if(check_exile_implant(C))
				say("Rejecting [AM]: Exile implant detected in contained lifeform.")
				return
	if(AM.has_buckled_mobs())
		for(var/mob/living/carbon/C in AM.buckled_mobs)
			if(check_exile_implant(C))
				say("Rejecting [AM]: Exile implant detected in close proximity lifeform.")
				return
	AM.forceMove(get_step(stationgate.loc, SOUTH))
	AM.setDir(SOUTH)
	if (ismob(AM))
		var/mob/M = AM
		if (M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)


/obj/item/paper/fluff/gateway
	info = "Congratulations,<br><br>Your station has been selected to carry out the Gateway Project.<br><br>The equipment will be shipped to you at the start of the next quarter.<br> You are to prepare a secure location to house the equipment as outlined in the attached documents.<br><br>--Nanotrasen Blue Space Research"
	name = "Confidential Correspondence, Pg 1"