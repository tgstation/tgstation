/obj/item/pressure_plate
	name = "pressure plate"
	desc = "An electronic device that triggers when stepped on."
	desc_controls = "Ctrl-Click to toggle the pressure plate off and on."
	icon = 'icons/obj/fluff/puzzle_small.dmi'
	inhand_icon_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	icon_state = "pressureplate"
	layer = LOW_OBJ_LAYER
	var/trigger_mob = TRUE
	var/trigger_item = FALSE
	var/specific_item = null
	var/trigger_silent = FALSE
	var/sound/trigger_sound = 'sound/effects/pressureplate.ogg'
	var/obj/item/assembly/signaler/sigdev = null
	var/roundstart_signaller = FALSE
	var/roundstart_signaller_freq = FREQ_PRESSURE_PLATE
	var/roundstart_signaller_code = 30
	var/roundstart_hide = FALSE
	var/removable_signaller = TRUE
	var/active = FALSE
	var/image/tile_overlay = null
	var/can_trigger = TRUE
	var/trigger_delay = 10
	var/protected = FALSE
	var/undertile_pressureplate = TRUE

/obj/item/pressure_plate/Initialize(mapload)
	. = ..()
	tile_overlay = image(icon = 'icons/turf/floors.dmi', icon_state = "pp_overlay")
	if(roundstart_signaller)
		sigdev = new
		sigdev.code = roundstart_signaller_code
		sigdev.set_frequency(roundstart_signaller_freq)

	if(undertile_pressureplate)
		AddElement(/datum/element/undertile, tile_overlay = tile_overlay, use_anchor = TRUE)
	RegisterSignal(src, COMSIG_OBJ_HIDE, PROC_REF(ToggleActive))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/pressure_plate/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!can_trigger || !active)
		return
	if(trigger_item && !istype(AM, specific_item))
		return
	if(trigger_mob && isliving(AM))
		var/mob/living/L = AM
		to_chat(L, span_warning("You feel something click beneath you!"))
	else if(!trigger_item)
		return
	can_trigger = FALSE
	addtimer(CALLBACK(src, PROC_REF(trigger)), trigger_delay)

/obj/item/pressure_plate/proc/trigger()
	can_trigger = TRUE
	if(istype(sigdev))
		sigdev.signal()

/obj/item/pressure_plate/attackby(obj/item/I, mob/living/L)
	if(issignaler(I) && !istype(sigdev) && removable_signaller && L.transferItemToLoc(I, src))
		sigdev = I
		to_chat(L, span_notice("You attach [I] to [src]!"))
	return ..()

/obj/item/pressure_plate/attack_self(mob/living/L)
	if(removable_signaller && istype(sigdev))
		to_chat(L, span_notice("You remove [sigdev] from [src]."))
		if(!L.put_in_hands(sigdev))
			sigdev.forceMove(get_turf(src))
		sigdev = null
	return ..()

/obj/item/pressure_plate/item_ctrl_click(mob/user)
	if(protected)
		to_chat(user, span_warning("You can't quite seem to turn this pressure plate off..."))
		return CLICK_ACTION_BLOCKING
	active = !active
	if (active)
		to_chat(user, span_notice("You turn [src] on."))
	else
		to_chat(user, span_notice("You turn [src] off."))
	return CLICK_ACTION_SUCCESS

///Called from COMSIG_OBJ_HIDE to toggle the active part, because yeah im not making a special exception on the element to support it
/obj/item/pressure_plate/proc/ToggleActive(datum/source, underfloor_accessibility)
	SIGNAL_HANDLER

	active = underfloor_accessibility < UNDERFLOOR_VISIBLE

/obj/item/pressure_plate/puzzle
	protected = TRUE
	anchored = TRUE //this prevents us from being picked up
	active = TRUE
	removable_signaller = FALSE
	/// puzzle id we send if stepped on
	var/puzzle_id
	/// queue size must match
	var/queue_size = 2

/obj/item/pressure_plate/puzzle/Initialize(mapload)
	. = ..()
	if(!isnull(puzzle_id))
		SSqueuelinks.add_to_queue(src, puzzle_id, queue_size)

/obj/item/pressure_plate/puzzle/trigger()
	can_trigger = FALSE
	SEND_SIGNAL(src, COMSIG_PUZZLE_COMPLETED)
