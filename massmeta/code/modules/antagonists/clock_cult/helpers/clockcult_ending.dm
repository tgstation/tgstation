/proc/trigger_clockcult_victory(hostile)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clockcult_gg)), 700)
	sleep(50)
	if(SSsecurity_level != SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	priority_announce("Обнаружен огромный всплеск гравитационной энергии, исходящий от нейтронной звезды недалеко от сектора. Было определено, что событие можно выжить с 0% жизни. РАСЧЕТНОЕ ВРЕМЯ, КОГДА ЭНЕРГОИМПУЛЬС ДОЙДЁТ ДО [GLOB.station_name]: 56 СЕКУНД. Успехов и слава NanoTrasen! - Адмирал Телвиг.", "Отделение аномальных материалов Центрального командования", 'sound/misc/bloblarm.ogg')
	for(var/client/C in GLOB.clients)
		SEND_SOUND(C, sound('sound/misc/airraid.ogg', 1))
	sleep(500)
	priority_announce("Станция [GLOB.station_name] находится в во#новом %o[text2ratvar("ВЫ УВИДИТЕ СВЕТ")] неизбежном разрушении. Слава [text2ratvar(" ДВИГ'АТЕЛЮ")].","Отделение аномальных материалов Центрального командования", 'sound/machines/alarm.ogg')
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			M.client.color = COLOR_WHITE
			animate(M.client, color=LIGHT_COLOR_CLOCKWORK, time=135)
	sleep(135)
	SSshuttle.registerHostileEnvironment(hostile)
	SSshuttle.lockdown = TRUE
	for(var/mob/M in GLOB.mob_list)
		if(M.client)
			M.client.color = LIGHT_COLOR_CLOCKWORK
			animate(M.client, color=COLOR_WHITE, time=5)
			SEND_SOUND(M, sound(null))
			SEND_SOUND(M, sound('sound/magic/fireball.ogg'))
		if(!is_servant_of_ratvar(M) && isliving(M))
			var/mob/living/L = M
			L.fire_stacks = INFINITY
			L.ignite_mob()
			L.emote("agony")

/proc/clockcult_gg()
	SSticker.force_ending = TRUE


/obj/structure/lattice/catwalk/ratvar_act()
	new /obj/structure/lattice/catwalk/clockwork(loc)

/obj/structure/lattice/ratvar_act()
	new /obj/structure/lattice/clockwork(loc)

/obj/machinery/computer/ratvar_act()
	icon_screen = "ratvar1"
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer1"

/obj/structure/chair/ratvar_act()
	var/obj/structure/chair/bronze/B = new(get_turf(src))
	B.setDir(dir)
	qdel(src)

/obj/machinery/door/window/ratvar_act()
	var/obj/machinery/door/window/clockwork/C = new(loc, dir)
	C.name = name
	qdel(src)

/obj/machinery/door/window/clockwork/ratvar_act()
	return FALSE

/turf/closed/wall/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/clockwork)

/turf/open/floor/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/clockwork, flags = CHANGETURF_INHERIT_AIR)

/obj/structure/table/ratvar_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/bronze(A)
	canSmoothWith = list(/obj/structure/table/bronze)

/obj/structure/table/bronze/ratvar_act()
	return

/turf/ratvar_act(force, ignore_mobs, probability = 40)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.ratvar_act()

/obj/structure/grille/ratvar_act()
	if(broken)
		new /obj/structure/grille/ratvar/broken(src.loc)
	else
		new /obj/structure/grille/ratvar(src.loc)
	qdel(src)

/obj/structure/falsewall/ratvar_act()
	new /obj/structure/falsewall/bronze(loc)
	qdel(src)

/obj/item/stack/sheet/iron/ratvar_act()
	new /obj/item/stack/tile/bronze(loc, amount)
	qdel(src)

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/reinforced/clockwork/fulltile(get_turf(src))
	qdel(src)

/obj/machinery/door/airlock/ratvar_act() //Airlocks become pinion airlocks that only allow servants
	var/obj/machinery/door/airlock/clockwork/A
	if(glass)
		A = new/obj/machinery/door/airlock/clockwork/glass(get_turf(src))
	else
		A = new/obj/machinery/door/airlock/clockwork(get_turf(src))
	A.name = name
	qdel(src)
