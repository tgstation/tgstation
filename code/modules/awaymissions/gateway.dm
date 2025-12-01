/// Station home gateway
GLOBAL_DATUM(the_gateway, /obj/machinery/gateway/centerstation)
/// List of possible gateway destinations.
GLOBAL_LIST_EMPTY(gateway_destinations)

/**
 * Corresponds to single entry in gateway control.
 *
 * Will NOT be added automatically to GLOB.gateway_destinations list.
 */
/datum/gateway_destination
	var/name = "Unknown Destination"
	var/wait = 0 /// How long after roundstart this destination becomes active
	var/enabled = TRUE /// If disabled, the destination won't be available
	var/hidden = FALSE /// Will not show on gateway controls at all.

/* Can a gateway link to this destination right now. */
/datum/gateway_destination/proc/is_available()
	return enabled && (world.time - SSticker.round_start_time >= wait)

/* Returns user-friendly description why you can't connect to this destination, displayed in UI */
/datum/gateway_destination/proc/get_available_reason()
	. = "Unreachable"
	if(world.time - SSticker.round_start_time < wait)
		playsound(src, 'sound/machines/gateway/gateway_calibrating.ogg', 80, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		. = "Connection desynchronized. Recalibration in progress."

/* Check if the movable is allowed to arrive at this destination (exile implants mostly) */
/datum/gateway_destination/proc/incoming_pass_check(atom/movable/AM)
	return TRUE

/* Get the actual turf we'll arrive at */
/datum/gateway_destination/proc/get_target_turf()
	CRASH("get target turf not implemented for this destination type")

/* Called after moving the movable to target turf */
/datum/gateway_destination/proc/post_transfer(atom/movable/AM)
	if (ismob(AM))
		var/mob/M = AM
		if (M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)

/* Called when gateway activates with this destination. */
/datum/gateway_destination/proc/activate(obj/machinery/gateway/activated)
	return

/* Called when gateway targeting this destination deactivates. */
/datum/gateway_destination/proc/deactivate(obj/machinery/gateway/deactivated)
	return

/* Returns data used by gateway controller ui */
/datum/gateway_destination/proc/get_ui_data()
	. = list()
	.["ref"] = REF(src)
	.["name"] = name
	.["available"] = is_available()
	.["reason"] = get_available_reason()
	if(wait)
		.["timeout"] = max(1 - (wait - (world.time - SSticker.round_start_time)) / wait, 0)

/* Destination is another gateway */
/datum/gateway_destination/gateway
	/// The gateway this destination points at
	var/obj/machinery/gateway/target_gateway

/* We set the target gateway target to activator gateway */
/datum/gateway_destination/gateway/activate(obj/machinery/gateway/activated)
	if(!target_gateway.target)
		target_gateway.activate(activated)

/* We turn off the target gateway if it's linked with us */
/datum/gateway_destination/gateway/deactivate(obj/machinery/gateway/deactivated)
	if(target_gateway.target == deactivated.destination)
		target_gateway.deactivate()

/datum/gateway_destination/gateway/is_available()
	return ..() && target_gateway.calibrated && !target_gateway.target && target_gateway.powered()

/datum/gateway_destination/gateway/get_available_reason()
	. = ..()
	if(!target_gateway.calibrated)
		. = "Exit gateway malfunction. Manual recalibration required."
	if(target_gateway.target)
		. = "Exit gateway in use."
	if(!target_gateway.powered())
		. = "Exit gateway unpowered."

/datum/gateway_destination/gateway/get_target_turf()
	return get_step(target_gateway.portal, target_gateway.dir)

/datum/gateway_destination/gateway/post_transfer(atom/movable/AM)
	. = ..()
	addtimer(CALLBACK(AM, TYPE_PROC_REF(/atom/movable, setDir), target_gateway.dir),0)

/* Special home destination, so we can check exile implants */
/datum/gateway_destination/gateway/home

/datum/gateway_destination/gateway/home/incoming_pass_check(atom/movable/AM)
	if(isliving(AM))
		if(check_exile_implant(AM))
			return FALSE
	else
		for(var/mob/living/L in AM.contents)
			if(check_exile_implant(L))
				target_gateway.say("Rejecting [AM]: Exile implant detected in contained lifeform.")
				return FALSE
	if(AM.has_buckled_mobs())
		for(var/mob/living/L in AM.buckled_mobs)
			if(check_exile_implant(L))
				target_gateway.say("Rejecting [AM]: Exile implant detected in close proximity lifeform.")
				return FALSE
	return TRUE

/datum/gateway_destination/gateway/home/proc/check_exile_implant(mob/living/L)
	for(var/obj/item/implant/exile/E in L.implants)//Checking that there is an exile implant
		to_chat(L, span_userdanger("The station gate has detected your exile implant and is blocking your entry."))
		return TRUE
	return FALSE


/* Destination is one ore more turfs - created by landmarks */
/datum/gateway_destination/point
	var/list/target_turfs = list()
	/// Used by away landmarks
	var/id

/datum/gateway_destination/point/get_target_turf()
	return pick(target_turfs)

/* Dense invisible object starting the teleportation. Created by gateways on activation. */
/obj/effect/gateway_portal_bumper
	var/obj/machinery/gateway/gateway
	density = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/gateway_portal_bumper/Bumped(atom/movable/AM)
	if(get_dir(src,AM) == gateway?.dir)
		playsound(src, 'sound/machines/gateway/gateway_travel.ogg', 70, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		gateway.Transfer(AM)

/obj/effect/gateway_portal_bumper/Destroy(force)
	. = ..()
	gateway = null

/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "portal_frame"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	// 3x2 offset by one row
	pixel_x = -32
	pixel_y = -32
	bound_height = 64
	bound_width = 96
	bound_x = -32
	bound_y = 0
	density = TRUE

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 5

	var/calibrated = TRUE
	/// Type of instanced gateway destination, needs to be subtype of /datum/gateway_destination/gateway
	var/destination_type = /datum/gateway_destination/gateway
	/// Name of the generated destination
	var/destination_name = "Unknown Gateway"
	/// This is our own destination, pointing at this gateway
	var/datum/gateway_destination/gateway/destination
	/// This is current active destination
	var/datum/gateway_destination/target
	/// bumper object, the thing that starts actual teleport
	var/obj/effect/gateway_portal_bumper/portal
	/// Visual object for handling the viscontents
	var/atom/movable/screen/map_view/gateway_port/portal_visuals
	var/teleportion_possible = FALSE
	var/transport_active = FALSE

/obj/machinery/gateway/Initialize(mapload)
	generate_destination()
	update_appearance()
	portal_visuals = new
	portal_visuals.generate_view("gateway_popup_[REF(src)]")
	portal_visuals.update_portal_filters()
	return ..()

/obj/machinery/gateway/Destroy()
	QDEL_NULL(portal_visuals)
	destination.target_gateway = null
	GLOB.gateway_destinations -= destination
	destination = null
	return ..()

/obj/machinery/gateway/proc/generate_destination()
	destination = new destination_type
	destination.name = destination_name
	destination.target_gateway = src
	GLOB.gateway_destinations += destination

/obj/machinery/gateway/proc/deactivate()
	var/datum/gateway_destination/dest = target
	target = null
	playsound(src, 'sound/machines/gateway/gateway_close.ogg', 140, TRUE, TRUE, SOUND_RANGE)
	dest.deactivate(src)
	QDEL_NULL(portal)
	update_use_power(IDLE_POWER_USE)
	transport_active = FALSE
	update_appearance()
	portal_visuals.reset_visuals()

/obj/machinery/gateway/process()
	if((machine_stat & (NOPOWER)) && use_power)
		teleportion_possible = FALSE
		if(target)
			deactivate()
		return
	if(teleportion_possible)
		return
	for(var/datum/gateway_destination/possible_destination as anything in GLOB.gateway_destinations)
		if(!valid_destination(possible_destination) || !possible_destination.is_available())
			continue
		teleportion_possible = TRUE
		update_appearance()
		break

/obj/machinery/gateway/proc/valid_destination(datum/gateway_destination/possible_destination)
	if(possible_destination == destination)
		return FALSE
	if(istype(possible_destination, /datum/gateway_destination/gateway))
		var/datum/gateway_destination/gateway/gateway_dest = possible_destination
		if(gateway_dest.target_gateway == src)
			return FALSE
	return TRUE

/obj/machinery/gateway/proc/show_light_overlays(light_state, toggle)
	if(!toggle)
		return list()

	var/list/image/to_animate = list()
	to_animate += image('icons/obj/machines/gateway.dmi', light_state)
	var/image/glowing_light = image('icons/obj/machines/gateway.dmi', light_state)
	glowing_light.color = GLOB.emissive_color
	SET_PLANE_EXPLICIT(glowing_light, EMISSIVE_PLANE, src)
	to_animate += glowing_light
	return to_animate

/obj/machinery/gateway/update_overlays()
	. = ..()
	. += show_light_overlays("portal_light", teleportion_possible)
	. += show_light_overlays("portal_effect", transport_active)

/obj/machinery/gateway/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE)
	return

/obj/machinery/gateway/proc/generate_bumper()
	portal = new(get_turf(src))
	portal.gateway = src

/obj/machinery/gateway/proc/activate(datum/gateway_destination/D)
	if(!powered() || target)
		return
	target = D
	target.activate(destination)
	portal_visuals.setup_visuals(target)
	transport_active = TRUE
	playsound(src, 'sound/machines/gateway/gateway_open.ogg', 140, TRUE, TRUE, SOUND_RANGE)
	generate_bumper()
	update_use_power(ACTIVE_POWER_USE)
	update_appearance()

/obj/machinery/gateway/proc/Transfer(atom/movable/AM)
	if(!target || !target.incoming_pass_check(AM))
		return
	AM.forceMove(target.get_target_turf())
	target.post_transfer(AM)

/obj/machinery/gateway/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	var/turf/tar_turf = target?.get_target_turf()
	if(isnull(tar_turf))
		to_chat(user, span_warning("There's no active destination for the gateway... or it's broken. Maybe try again later?"))
		return
	if(is_secret_level(tar_turf.z) && !user.client?.holder)
		to_chat(user, span_warning("The gateway destination is secret."))
		return
	Transfer(user)

/* Station's primary gateway */
/obj/machinery/gateway/centerstation
	destination_type = /datum/gateway_destination/gateway/home
	destination_name = "Home Gateway"

/obj/machinery/gateway/centerstation/Initialize(mapload)
	. = ..()
	if(!GLOB.the_gateway)
		GLOB.the_gateway = src

/obj/machinery/gateway/centerstation/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	return ..()

/obj/machinery/gateway/multitool_act(mob/living/user, obj/item/I)
	if(calibrated)
		to_chat(user, span_alert("The gate is already calibrated, there is no work for you to do here."))
	else
		playsound(src, 'sound/machines/gateway/gateway_calibrated.ogg', 80, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(user, "[span_boldnotice("Recalibration successful!")]: \black This gate's systems have been fine tuned. Travel to this gate will now be on target.")
		calibrated = TRUE
	return TRUE

/* Doesn't need control console or power, always links to home when interacting. */
/obj/machinery/gateway/away
	density = TRUE
	use_power = NO_POWER_USE

/obj/machinery/gateway/away/interact(mob/user)
	. = ..()
	if(!target)
		if(!GLOB.the_gateway)
			to_chat(user,span_warning("Home gateway is not responding!"))
		if(GLOB.the_gateway.target)
			GLOB.the_gateway.deactivate() //this will turn the home gateway off so that it's free for us to connect to
		activate(GLOB.the_gateway.destination)
	else
		deactivate()

/* Gateway control computer */
/obj/machinery/computer/gateway_control
	name = "Gateway Control"
	desc = "Human friendly interface to the mysterious gate next to it."
	var/obj/machinery/gateway/G

/obj/machinery/computer/gateway_control/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	try_to_linkup()

/obj/machinery/computer/gateway_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Gateway", name)
		G.portal_visuals.display_to(user, ui.window)
		ui.open()

/obj/machinery/computer/gateway_control/ui_data(mob/user)
	. = ..()
	.["gateway_present"] = G
	.["gateway_status"] = G ? G.powered() : FALSE
	.["current_target"] = G?.target?.get_ui_data()
	.["gateway_mapkey"] = G.portal_visuals.assigned_map
	var/list/destinations = list()
	if(G)
		for(var/datum/gateway_destination/possible_destination in GLOB.gateway_destinations)
			if(!G.valid_destination(possible_destination))
				continue
			destinations += list(possible_destination.get_ui_data())
	.["destinations"] = destinations

/obj/machinery/computer/gateway_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("linkup")
			try_to_linkup()
			return TRUE
		if("activate")
			var/datum/gateway_destination/D = locate(params["destination"]) in GLOB.gateway_destinations
			try_to_connect(D)
			return TRUE
		if("deactivate")
			if(G?.target)
				G.deactivate()
			return TRUE

/obj/machinery/computer/gateway_control/ui_close(mob/user)
	. = ..()
	G.portal_visuals.hide_from(user)

/obj/machinery/computer/gateway_control/proc/try_to_linkup()
	G = locate(/obj/machinery/gateway) in view(7,get_turf(src))

/obj/machinery/computer/gateway_control/proc/try_to_connect(datum/gateway_destination/D)
	if(!D || !G)
		return
	if(!D.is_available() || G.target)
		return
	G.activate(D)

/obj/item/paper/fluff/gateway
	default_raw_text = "Congratulations,<br><br>Your station has been selected to carry out the Gateway Project.<br><br>The equipment will be shipped to you at the start of the next quarter.<br> You are to prepare a secure location to house the equipment as outlined in the attached documents.<br><br>--Nanotrasen Bluespace Research"
	name = "Confidential Correspondence, Pg 1"

/atom/movable/screen/map_view/gateway_port
	var/datum/gateway_destination/our_destination
	/// Handles the background of the portal, ensures the effect well, works properly
	var/atom/movable/screen/background/cam_background

/atom/movable/screen/map_view/gateway_port/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	cam_background = new
	cam_background.del_on_map_removal = FALSE
	// Draw above everything
	cam_background.layer = 200
	cam_background.plane = HIGHEST_EVER_PLANE
	cam_background.blend_mode = BLEND_OVERLAY


/atom/movable/screen/map_view/gateway_port/generate_view(map_key)
	. = ..()
	cam_background.assigned_map = assigned_map
	cam_background.fill_rect(1, 1, 3, 3)

/atom/movable/screen/map_view/gateway_port/Destroy()
	QDEL_NULL(cam_background)
	return ..()

/atom/movable/screen/map_view/gateway_port/display_on_ui_visible(mob/show_to)
	. = ..()
	show_to.client.register_map_obj(cam_background)

/atom/movable/screen/map_view/gateway_port/proc/setup_visuals(datum/gateway_destination/D)
	our_destination = D
	update_portal_filters()

/atom/movable/screen/map_view/gateway_port/proc/reset_visuals()
	our_destination = null
	update_portal_filters()

/atom/movable/screen/map_view/gateway_port/proc/update_portal_filters()
	cam_background.clear_filters()
	// ok so what this used to do was render the tiles "on the other side" of the gateway onto the gateway mask
	// Unfortunately since I've removed the plane inheriting from /atom vis_flags, this no longer works
	// You could setup gateways to draw onto "lower then everything" z layers, but generating a whole stack of plane masters
	// Just for this one effect is kinda silly. Maybe next time
	// Rather then that, let's just render a little preview port to the console, because for reasons that's trivial
	vis_contents = null

	var/turf/center_turf = our_destination?.get_target_turf()
	if(!center_turf)
		// Draw static
		cam_background.icon_state = "scanline2"
		cam_background.color = null
		cam_background.alpha = 255
		return

	cam_background.add_filter("portal_blur", 1, list("type" = "blur", "size" = 0.5))

	vis_contents += TURF_NEIGHBORS(center_turf)
	cam_background.icon_state = "scanline4"
	cam_background.color = "#adadff"
	cam_background.alpha = 128
