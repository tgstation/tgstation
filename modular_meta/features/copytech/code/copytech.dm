/obj/machinery/copytech
	name = "copying machine"
	desc = "Creates anything in unlimited quantities. Consumes a lot of energy."
	icon = 'modular_meta/features/copytech/icons/something.dmi'
	circuit = /obj/item/circuitboard/machine/copytech
	icon_state = "apparatus"
	density = TRUE
	layer = MOB_LAYER
	var/timer
	var/scanned_type = null
	var/tier_rate = 1
	var/obj/machinery/copytech_platform/cp = null
	var/current_design = null
	var/working = FALSE
	var/atom/movable/active_item = null
	var/crystals = 0
	var/max_crystals = 4
	var/obj/structure/cable/attached_cable
	var/siphoned_power = 0
	var/siphon_max = 1e7

/obj/machinery/copytech/process()
	if(siphoned_power >= siphon_max)
		return
	update_cable()
	if(attached_cable)
		attempt_siphon()

/obj/machinery/copytech/proc/update_cable()
	var/turf/T = get_turf(src)
	attached_cable = locate(/obj/structure/cable) in T

/obj/machinery/copytech/proc/attempt_siphon()
	var/surpluspower = clamp(attached_cable.surplus(), 0, (siphon_max - siphoned_power))
	if(surpluspower)
		attached_cable.add_load(surpluspower)
		siphoned_power += surpluspower

/obj/machinery/copytech/examine(mob/user)
	. = ..()
	. += "<hr><span class='info'>Approximate time of creation of the object: [time2text(get_replication_speed(tier_rate), "mm:ss")].</span>\n"
	. += "<hr><span class='info'>Time remaining: [timeleft(timer)] секунд.</span>\n"
	. += "<hr><span class='info'>There is: <b>[crystals]/[max_crystals] bluespace crystalls inside/b>.</span>\n"
	. += span_info("Power accumulated: <b>[num2loadingbar((siphon_max-siphoned_power)/siphon_max, 10, reverse = TRUE)] [display_power(siphoned_power)]/[display_power(siphon_max)]</b>.")
	. += "<hr><span class='notice'>It looks like it needs to be connected to the power grid via a cable.</span>"

/obj/machinery/copytech/Initialize(mapload)
	. = ..()
	check_platform()

/obj/machinery/copytech/update_icon()
	. = ..()
	if(working)
		icon_state = "apparatus_on"
	else
		icon_state = "apparatus"

/obj/machinery/copytech/attacked_by(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/stack/ore/bluespace_crystal) || istype(I, /obj/item/stack/sheet/bluespace_crystal))
		if(crystals >= max_crystals)
			to_chat(user, span_warning("Doesn't fit more."))
			return
		var/obj/item/stack/BC = I
		if(!BC.amount)
			to_chat(user, span_warning("Я КОНЧАЛ В ЖОПУ ШУССА ОХХХХХХХХХ БЛЯДЬ!")) // Возникает при баге, удачи кодерам тг220 вырезать всё что оскорбляет их любимого ёбыря.
			return
		crystals++
		user.visible_message("[user] inserts [I.name] in [src.name].", span_notice("Insert [I.name] in [src.name]."))
		BC.use(1)
		return
	else
		return ..()

/obj/machinery/copytech/attack_hand(mob/living/user)
	. = ..()
	if(working)
		say(pick("I'm busy!", "Don't disturb me!", "Listen, I'm a little busy here.", "Copying an object."))
		return
	if(siphoned_power < siphon_max)
		say("Not enough energy.")
		return
	if(!cp)
		say("No disintegrating platform detected within 5 floors. Attempting synchronization...")
		check_platform()
		return
	if(!current_design)
		say("No design found. Disassemble something on the disintegrating platform first!")
		return
	if(!crystals)
		say("There are not enough bluespace crystals to get started!")
		return
	start_working()


/obj/machinery/copytech/proc/start_working()
	say("Starting the process of creating an object...")
	working = TRUE
	update_icon()

	var/atom/drop_loc = drop_location()

	if(ispath(current_design, /obj))
		var/obj/O = new current_design(drop_loc)
		O.set_anchored(TRUE)
		O.layer = ABOVE_MOB_LAYER
		O.alpha = 0
		var/mutable_appearance/result = mutable_appearance(O.icon, O.icon_state)
		var/mutable_appearance/scanline = mutable_appearance('icons/effects/effects.dmi',"transform_effect")
		O.transformation_animation(result, time = get_replication_speed(tier_rate), scanline.appearance)
		active_item = O
		crystals--
		siphoned_power = 0
		timer = addtimer(CALLBACK(src, PROC_REF(finish_work), O), get_replication_speed(tier_rate), TIMER_STOPPABLE)
		return TRUE

	if (ispath(current_design, /mob/living))
		if(tier_rate < 8)
			say("Upgrade micro-laser for further work.")
			return FALSE
		var/mob/living/M = new current_design(drop_loc)
		M.SetParalyzed(get_replication_speed(tier_rate) * 1.5)
		M.emote("agony")
		M.layer = ABOVE_MOB_LAYER
		var/mutable_appearance/result = mutable_appearance(M.icon, M.icon_state)
		var/mutable_appearance/scanline = mutable_appearance('icons/effects/effects.dmi',"transform_effect")
		M.transformation_animation(result, time = get_replication_speed(tier_rate), transform_overlay = scanline)
		active_item = M
		crystals--
		siphoned_power = 0
		timer = addtimer(CALLBACK(src, PROC_REF(finish_work), M), get_replication_speed(tier_rate), TIMER_STOPPABLE)
		return TRUE

	say("Unknown error! Please contact the engineering department.")
	return FALSE

/obj/machinery/copytech/proc/finish_work(obj/O)
	if(istype(O, /mob/living))
		var/mob/living/L = O
		L.adjust_jitter(40 SECONDS)
		L.adjust_confusion(20 SECONDS)
	O.set_anchored(FALSE)
	O.layer = initial(O.layer)
	O.alpha = initial(O.alpha)
	say("Completing work...")
	timer = null
	working = FALSE
	update_icon()



/obj/machinery/copytech/RefreshParts()
	. = ..()
	var/T = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	tier_rate = T

/proc/get_replication_speed(tier)
	return (60 SECONDS) / tier

/obj/machinery/copytech/proc/check_platform()
	if(!cp)
		for(var/obj/machinery/copytech_platform/M in range(5, src))
			cp = M
			return TRUE
	return FALSE

/obj/machinery/copytech_platform
	name = "disintegrating platform"
	desc = "Destroys everything on it if activated. Consumes a lot of energy."
	icon = 'modular_meta/features/copytech/icons/something.dmi'
	circuit = /obj/item/circuitboard/machine/copytech_platform
	icon_state = "platform"
	density = 0
	layer = MOB_LAYER
	var/timer
	var/tier_rate = 1
	var/obj/machinery/copytech/ct = null
	var/working = FALSE
	var/atom/movable/active_item = null
	var/list/blacklisted_items = list(
			/obj/item/card/id,
			/obj/item/stack/telecrystal,
			/obj/item/uplink,
			/obj/item/pen/uplink,
			/obj/item/multitool/uplink,
			/obj/item/storage/box/syndie_kit,
			/obj/item/sbeacondrop,
			/obj/item/storage/box/syndicate,
			/obj/item/spellbook
		)
	var/obj/structure/cable/attached_cable
	var/siphoned_power = 0
	var/siphon_max = 1e7


/obj/machinery/copytech_platform/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(movable_crossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/copytech_platform/process(delta_time)
	if(siphoned_power < siphon_max)
		update_cable()
		if(attached_cable)
			attempt_siphon()
	if(working)
		for(var/mob/living/L in get_turf(src))
			L.adjustFireLoss(10*delta_time)
			playsound(L, 'sound/machines/shower/shower_mid1.ogg', 90, TRUE)

/obj/machinery/copytech_platform/proc/update_cable()
	var/turf/T = get_turf(src)
	attached_cable = locate(/obj/structure/cable) in T

/obj/machinery/copytech_platform/proc/attempt_siphon()
	var/surpluspower = clamp(attached_cable.surplus(), 0, (siphon_max - siphoned_power))
	if(surpluspower)
		attached_cable.add_load(surpluspower)
		siphoned_power += surpluspower

/obj/machinery/copytech_platform/RefreshParts()
	. = ..()
	var/T = 0
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	tier_rate = T

/obj/machinery/copytech_platform/proc/movable_crossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!working)
		return
	if(isliving(AM))
		var/mob/living/L = AM
		L.adjustFireLoss(20)
		L.visible_message(span_danger("<b>[L]</b> fried!"))
		playsound(L, 'sound/machines/shower/shower_mid1.ogg', 90, TRUE)

/obj/machinery/copytech_platform/examine(mob/user)
	. = ..()
	. += "<hr><span class='info'>Estimated time to destroy the object: [time2text(get_replication_speed(tier_rate), "mm:ss")].</span>\n"
	. += "<hr><span class='info'>Time remaining: [time2text(timeleft(timer), "mm:ss")]</span>\n"
	. += span_info("Power accumulated: <b>[num2loadingbar((siphon_max-siphoned_power)/siphon_max, 10, reverse = TRUE)] [display_power(siphoned_power)]/[display_power(siphon_max)]</b>.")
	. += "<hr><span class='notice'>It looks like it needs to be connected to the power grid via a cable.</span>"
	. += "<hr><span class='notice'>There is a label at the bottom: \"ATTENTION: It is forbidden to copy ID cards, any crystals, uplinks, suspicious beacons, red and suspicious boxes, as well as books.\"</span>"

/obj/machinery/copytech_platform/Initialize(mapload)
	. = ..()
	check_copytech()

/obj/machinery/copytech_platform/update_icon()
	. = ..()
	if(working)
		icon_state = "platform_on"
	else
		icon_state = "platform"

/obj/machinery/copytech_platform/attack_hand(mob/living/user)
	. = ..()
	if(working)
		say(pick("I'm busy!", "Don't disturb me!", "Listen, I'm a little busy here.", "Copying an object."))
		return
	if(siphoned_power < siphon_max)
		say("Not enough energy.")
		return
	if(!ct)
		say("No copying machine found within 5 floors. Trying to synchronize...")
		check_copytech()
		return
	destroy_thing(user)


/obj/machinery/copytech_platform/proc/check_copytech()
	if(!ct)
		for(var/obj/machinery/copytech/M in range(5, src))
			ct = M
			return TRUE
	return FALSE

/obj/machinery/copytech_platform/proc/destroy_thing(mob/user)
	if(!ct )
		return FALSE
	var/turf/T = get_turf(src)
	var/atom/movable/D = null
	if(T?.contents)
		for(var/thing in T.contents)
			if(istype(thing, /obj))
				var/obj/O = thing
				if(O.anchored || (O.resistance_flags & INDESTRUCTIBLE) || O == src)
					continue
				D = thing
			if(istype(thing, /mob/living) && tier_rate >= 8)
				D = thing

	if(!D)
		return

	for(var/type in blacklisted_items)
		if(istype(D, type))
			if(user)
				message_admins("[key_name(user)] попытался скопировать запрещённый предмет [D.name] ([D.type])!")
			say("FORBIDDEN ITEMS DETECTED!")
			sleep(3 SECONDS)
			say("ACTIVATION OF THE \"DESTROYER\" PROTOCOL!")
			sleep(1 SECONDS)
			say("Beginning the process of ANNIHILATION OF THE ENVIRONMENT...")
			sleep(1 SECONDS)
			say("5...")
			sleep(1 SECONDS)
			say("4...")
			sleep(1 SECONDS)
			say("3...")
			sleep(1 SECONDS)
			say("2...")
			sleep(1 SECONDS)
			say("1...")
			sleep(1 SECONDS)
			qdel(src)
			if(!ct)
				qdel(ct)
			explosion(src, 5, 10, 20, 20)
			return

	say("Beginning the process of disintegrating the object...")
	working = TRUE
	update_icon()

	D.set_anchored(TRUE)
	if(isliving(D))
		var/mob/living/M = D
		M.SetParalyzed(get_replication_speed(tier_rate) * 2)
		M.emote("agony")
		M.layer = ABOVE_MOB_LAYER
	D.layer = ABOVE_MOB_LAYER
	var/mutable_appearance/result = mutable_appearance('icons/effects/effects.dmi',"nothing")
	var/mutable_appearance/scanline = mutable_appearance('icons/effects/effects.dmi',"transform_effect")
	D.transformation_animation(result, time = get_replication_speed(tier_rate), transform_overlay = scanline)
	active_item = D
	siphoned_power = 0
	timer = addtimer(CALLBACK(src, PROC_REF(finish_work), D), get_replication_speed(tier_rate), TIMER_STOPPABLE)
	return TRUE

/obj/machinery/copytech_platform/proc/finish_work(obj/D)
	if(!src)
		return
	if(get_turf(D) != get_turf(src))
		say("Error!")
		working = FALSE
		update_icon()
		return

	ct.current_design = D.type
	say("Completing work...")
	timer = null
	qdel(D)
	working = FALSE
	update_icon()

/obj/item/circuitboard/machine/copytech
	name = "copying machine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/copytech
	req_components = list(/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/copytech_platform
	name = "disintegrating platform"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/copytech_platform
	req_components = list(/obj/item/stock_parts/micro_laser = 1)
