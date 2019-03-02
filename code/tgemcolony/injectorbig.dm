/obj/item/circuitboard/machine/geminjector
	name = "Injector (Machine Board)"
	build_path = /obj/machinery/geminjector
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1)
		//laser increases injection speed
		//scanner increases scan speed
		//manipulator increases cooldown

/datum/design/board/geminjector
	name = "Machine Design (Gem Injector)"
	desc = "Produce more gems for Homeworld."
	id = "geminjector"
	build_path = /obj/item/circuitboard/machine/geminjector
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/obj/machinery/geminjector
	name = "Injector"
	desc = "A big bulky machine that Bad gems use to make more Bad gems."
	icon = 'icons/obj/geminjector.dmi'
	icon_state = "injector"
	use_power = NO_POWER_USE
	obj_flags = CAN_BE_HIT
	layer = LARGE_MOB_LAYER
	circuit = /obj/item/circuitboard/machine/geminjector
	anchored = FALSE
	density = TRUE
	var/cooling = TRUE //No cheesing it by deconstructing and reconstructing.
	var/cooldown = 2600
	var/injectspeed = 600
	var/scanspeed = 600
	var/foundturfSCAN = FALSE
	var/foundturfINJECT = FALSE

/obj/machinery/geminjector/proc/cooldownfinish()
	src.visible_message("<span class='notice'>[src] lets out a burst of steam as it finishes.</span>")
	cooling = FALSE
	anchored = FALSE
	foundturfSCAN = FALSE
	foundturfINJECT = FALSE
	icon_state = "injector-ready"

/obj/machinery/geminjector/Initialize()
	. = ..()
	anchored = FALSE
	RefreshParts()
	spawn(5) //let the parts initialize
	src.visible_message("<span class='notice'>[src] clanks and clicks as it prepares it's software as well as hardware.</span>")
	spawn(cooldown)
	cooldownfinish()

/obj/machinery/geminjector/RefreshParts()
	for(var/obj/item/stock_parts/micro_laser/P in component_parts)
		var/partpower = P.rating*100
		injectspeed = 600-partpower
	for(var/obj/item/stock_parts/scanning_module/P in component_parts)
		var/partpower = P.rating*100
		scanspeed = 600-partpower
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		var/partpower = P.rating*400
		cooldown = 2600-partpower

/obj/machinery/geminjector/interact(mob/N)
	if(cooling == FALSE)
		add_fingerprint(N)
		cooling = TRUE
		anchored = TRUE
		to_chat(N, "<span class='notice'>You activate the [src].</span>")
		src.visible_message("<span class='notice'>[src] hums, ''Scanning soil.''</span>")
		spawn(scanspeed) //delay.
		scan()
	else
		to_chat(N, "<span class='notice'>Be Patient, it's not ready.</span>")

obj/machinery/geminjector/proc/scan()
	if(is_station_level(src.z))
		for(var/turf/A in range(1,src))
			if(istype(A, /turf/closed/mineral))
				foundturfSCAN = TRUE
				src.visible_message("<span class='notice'>[src] hums, ''Beginning injection.''</span>")
				spawn(injectspeed)
				inject()
		if(foundturfSCAN == FALSE)
			src.visible_message("<span class='notice'>[src] pings, ''No viable minerals nearby.''</span>")
			cooling = FALSE
			anchored = FALSE
			foundturfSCAN = FALSE
			foundturfINJECT = FALSE
			return
	else
		src.visible_message("<span class='notice'>[src] pings, ''No lifeforce detected.''</span>")
		return

obj/machinery/geminjector/proc/inject()
	for(var/turf/A in range(1,src))
		if(istype(A, /turf/closed/mineral) && foundturfINJECT == FALSE)
			var/turf/closed/mineral/M = A
			new/turf/open/floor/plating/kindergarden(locate(M.x,M.y,M.z))
			new/obj/kindergartengem(locate(M.x,M.y,M.z))
			foundturfINJECT = TRUE
			src.visible_message("<span class='userdanger'>[src] injects a seed into the ground and begins cooling down!</span>")
			src.visible_message("<span class='notice'>[src] pings, ''Operation Successful.''</span>")
			anchored = FALSE
			icon_state = "injector"
			spawn(cooldown)
			cooldownfinish()
	if(foundturfINJECT == FALSE)
		src.visible_message("<span class='notice'>[src] pings, ''Injection interrupted.''</span>")
		cooling = FALSE
		anchored = FALSE
		foundturfSCAN = FALSE
		foundturfINJECT = FALSE
		return
