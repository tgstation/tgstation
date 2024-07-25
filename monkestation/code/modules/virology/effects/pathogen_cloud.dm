GLOBAL_LIST_INIT(pathogen_clouds, list())
GLOBAL_LIST_INIT(science_goggles_wearers, list())

/obj/effect/pathogen_cloud
	name = ""
	icon = 'monkestation/code/modules/virology/icons/96x96.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon_state = ""
	color = COLOR_GREEN
	pixel_x = -32
	pixel_y = -32
	opacity = 0
	anchored = 0
	density = 0
	var/mob/source = null
	var/sourceIsCarrier = TRUE
	var/list/viruses = list()
	var/lifetime = 10 SECONDS //how long until we naturally disappear, humans breath about every 8 seconds, so it has to survive at least this long to have a chance to infect
	var/turf/target = null //when created, we'll slowly move toward this turf
	var/core = FALSE
	var/modified = FALSE
	var/moving = TRUE
	var/list/id_list = list()
	var/death = 0

/obj/effect/pathogen_cloud/New(turf/loc, mob/sourcemob, list/virus, isCarrier = TRUE, isCore = TRUE)
	..()
	if (!loc || !virus || virus.len <= 0)
		qdel(src)
		return
	core = isCore
	sourceIsCarrier = isCarrier
	GLOB.pathogen_clouds += src

	viruses = virus

	for(var/datum/disease/advanced/D as anything in viruses)
		id_list += "[D.uniqueID]-[D.subID]"

	if(!core)
		var/obj/effect/pathogen_cloud/core/core = locate(/obj/effect/pathogen_cloud/core) in src.loc
		if(get_turf(core) == get_turf(src))
			for(var/datum/disease/advanced/V as anything in viruses)
				if("[V.uniqueID]-[V.subID]" in core.id_list)
					continue
				core.viruses |= V.Copy()
				core.modified = TRUE
			qdel(src)

	if(istype(src, /obj/effect/pathogen_cloud/core))
		SSpathogen_clouds.cores += src
	else
		SSpathogen_clouds.clouds += src

	pathogen = image('monkestation/code/modules/virology/icons/96x96.dmi',src,"pathogen_airborne")
	pathogen.plane = HUD_PLANE
	pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
	for (var/mob/living/L as anything in GLOB.science_goggles_wearers)
		if (L.client)
			L.client.images |= pathogen

	source = sourcemob

	death = world.time + lifetime

	START_PROCESSING(SSpathogen_processing, src)

/obj/effect/pathogen_cloud/process(seconds_per_tick)
	if(death <= world.time)
		qdel(src)
		return PROCESS_KILL

/obj/effect/pathogen_cloud/core
	core = TRUE

/obj/effect/pathogen_cloud/Destroy()
	. = ..()
	STOP_PROCESSING(SSpathogen_processing, src)

	if(istype(src, /obj/effect/pathogen_cloud/core))
		SSpathogen_clouds.cores -= src
		SSpathogen_clouds.current_run_cores -= src
	else
		SSpathogen_clouds.clouds -= src
		SSpathogen_clouds.current_run_clouds -= src

	if (pathogen)
		for (var/mob/living/L in GLOB.science_goggles_wearers)
			if (L.client)
				L.client.images -= pathogen
		pathogen = null
	GLOB.pathogen_clouds -= src
	source = null
	viruses = list()
	lifetime = 3
	target = null
	. = ..()

/obj/effect/pathogen_cloud/core/New(turf/loc, mob/sourcemob, list/virus)
	..()
	if (!loc || !virus || virus.len <= 0)
		return

	var/strength = 0
	for (var/datum/disease/advanced/V as anything in viruses)
		strength += V.infectionchance
	strength = round(strength/viruses.len)
	var/list/possible_turfs = list()
	for (var/turf/open/T in range(max(0,(strength/20)-1),loc))//stronger viruses can reach turfs further away.
		if(isclosedturf(T))
			continue
		possible_turfs += T
	target = pick(possible_turfs)


/obj/effect/pathogen_cloud/core/process(seconds_per_tick)
	. = ..()
	var/turf/open/turf = get_turf(src)
	if ((turf != target) && moving)
		if (prob(75))
			if(!step_towards(src,target)) // we hit a wall and our momentum is shattered
				moving = FALSE
		else
			step_rand(src)
		var/obj/effect/pathogen_cloud/C = new /obj/effect/pathogen_cloud(turf, source, viruses, sourceIsCarrier, FALSE)
		C.modified = modified
		C.moving = FALSE
