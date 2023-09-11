/obj/effect/knock_portal
	name = "crack in reality"
	desc = "A crack in space, impossibly deep and painful to the eyes. Definitely not safe."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "realitycrack"
	light_system = STATIC_LIGHT
	light_power = 1
	light_on = TRUE
	light_color = COLOR_GREEN
	light_range = 3
	opacity = TRUE
	density = FALSE //so we dont block doors closing
	layer = OBJ_LAYER //under doors
	var/obj/effect/knock_portal/destination
	var/obj/machinery/door/our_airlock

/obj/effect/knock_portal/Initialize(mapload, target)
	. = ..()
	if(target)
		our_airlock = target
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(delete_on_door_delete))
		
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/knock_portal/proc/delete_on_door_delete(datum/source)
	SIGNAL_HANDLER
	qdel(destination)
	qdel(src)

/obj/effect/knock_portal/proc/on_entered(datum/source, mob/living/loser, atom/old_loc)
	SIGNAL_HANDLER
	if(istype(loser) && !(locate(type) in old_loc))
		teleport(loser)

/obj/effect/knock_portal/Destroy()
	destination = null
	our_airlock = null
	return ..()

/obj/effect/knock_portal/proc/teleport(mob/living/teleportee)
	if(isnull(destination)) //dumbass
		qdel(src)

	var/list/turf/possible_destinations = list()
	for(var/obj/airlock as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(airlock.z != z)
			continue
		if(airlock.loc == loc)
			continue
		possible_destinations += airlock

	//get it?
	var/obj/machinery/door/doorstination = IS_HERETIC_OR_MONSTER(teleportee) ? destination.our_airlock : pick(possible_destinations)
	if(do_teleport(teleportee, get_turf(doorstination), channel = TELEPORT_CHANNEL_MAGIC))
		if(!IS_HERETIC_OR_MONSTER(teleportee))
			teleportee.adjustBruteLoss(20) //so they dont roll it like a jackpot machine to see if they can land in the armory
			to_chat(teleportee, span_userdanger("You stumble through [src], battered by forces beyond your comprehension, landing anywhere but where you thought you were going."))
		INVOKE_ASYNC(src, PROC_REF(async_opendoor), doorstination)

/obj/effect/knock_portal/proc/async_opendoor(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock)) //they can create portals on ANY door, but we should unlock airlocks so they can actually open
		var/obj/machinery/door/airlock/as_airlock = door
		as_airlock.unbolt()
	door.open()

/obj/item/card/id/advanced/heretic
	var/list/obj/item/card/id/fused_ids = list()
	var/obj/effect/knock_portal/portal_one
	var/obj/effect/knock_portal/portal_two
	var/link

/obj/item/card/id/advanced/heretic/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += span_hypnophrase("Enchanted by the Mansus!")
	. += span_hypnophrase("Using an ID on this will consume it and allow you to copy its accesses.")
	. += span_hypnophrase("<b>Using this in-hand</b> allows you to change its appearance.")
	. += span_hypnophrase("<b>Using this on a pair of doors</b>, allows you to link them together. Entering one door will transport you to the other, while heathens are instead teleported to a random airlock.")

/obj/item/card/id/advanced/heretic/attack_self(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	var/cardname = tgui_input_list(user, "Shapeshift into?", "Shapeshift", fused_ids)
	if(!cardname)
		balloon_alert(user, "no options!")
		return ..()
	var/obj/item/card/id/card = fused_ids[cardname]
	shapeshift(card)

/obj/item/card/id/advanced/heretic/proc/shapeshift(obj/item/card/id/advanced/card)
	trim = card.trim
	assignment = card.assignment
	registered_age = card.registered_age
	registered_name = card.registered_name
	icon_state = card.icon_state
	inhand_icon_state = card.inhand_icon_state
	assigned_icon_state = card.assigned_icon_state
	name = card.name //not update_label because of the captains spare moment
	update_icon()

/obj/item/card/id/advanced/heretic/proc/clear_portals()
	QDEL_NULL(portal_one)
	QDEL_NULL(portal_two)	

/obj/item/card/id/advanced/heretic/proc/make_portal(mob/user, obj/machinery/door/door1, obj/machinery/door/door2)
	var/message = "linked"
	if(portal_one || portal_two)
		clear_portals()
		message += ", previous cleared"
	
	portal_one = new(get_turf(door2), door2)
	portal_two = new(get_turf(door1), door1)
	portal_one.destination = portal_two
	portal_two.destination = portal_one
	balloon_alert(user, "[message]")

/obj/item/card/id/advanced/heretic/attackby(obj/item/thing, mob/user, params)
	if(!istype(thing, /obj/item/card/id/advanced) || !IS_HERETIC(user))
		return ..()
	var/obj/item/card/id/card = thing
	fused_ids[card.name] = card
	card.moveToNullspace()
	playsound(drop_location(),'sound/items/eatfood.ogg', rand(10,50), TRUE)
	access += card.access

/obj/item/card/id/advanced/heretic/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user) || target == link)
		return
	if(istype(target, /obj/effect/knock_portal))
		clear_portals()
		return

	if(!istype(target, /obj/machinery/door))
		return

	if(link)
		make_portal(user, link, target)
		to_chat(user, span_notice("You use [src], to link [link] and [target] together."))
		link = null
		balloon_alert(user, "link 2/2")
	else
		link = target
		balloon_alert(user, "link 1/2")

/obj/item/card/id/advanced/heretic/Destroy()
	QDEL_LIST_ASSOC(fused_ids)
	link = null
	clear_portals()
	return ..()
