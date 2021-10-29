//Structure as this doesn't need any power to work
/obj/structure/drain
	name = "drain"
	icon = 'modular_skyrat/modules/liquids/icons/obj/structures/drains.dmi'
	icon_state = "drain"
	desc = "Drainage inlet embedded in the floor to prevent flooding."
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = FALSE
	plane = FLOOR_PLANE
	layer = GAS_SCRUBBER_LAYER
	anchored = TRUE
	var/processing = FALSE
	var/drain_flat = 5
	var/drain_percent = 0.1
	var/welded = FALSE
	var/turf/my_turf //need to keep track of it for the signal, if in any bizarre cases something would be moving the drain

/obj/structure/drain/update_icon()
	. = ..()
	if(welded)
		icon_state = "[initial(icon_state)]_welded"
	else
		icon_state = "[initial(icon_state)]"

/obj/structure/drain/welder_act(mob/living/user, obj/item/I)
	..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE

	playsound(src, 'sound/items/welder2.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You start [welded ? "unwelding" : "welding"] [src]...</span>")
	if(I.use_tool(src, user, 20))
		to_chat(user, "<span class='notice'>You [welded ? "unweld" : "weld"] [src].</span>")
		welded = !welded
		update_icon()
		if(welded)
			if(processing)
				STOP_PROCESSING(SSobj, src)
				processing = FALSE
		else if (my_turf.liquids)
			START_PROCESSING(SSobj, src)
			processing = TRUE
	return TRUE

/obj/structure/drain/process()
	if(!my_turf.liquids || my_turf.liquids.immutable)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
		return
	my_turf.liquids.liquid_simple_delete_flat(drain_flat + (drain_percent * my_turf.liquids.total_reagents))

/obj/structure/drain/Initialize()
	. = ..()
	if(!isturf(loc))
		stack_trace("Drain structure initialized not on a turf")
	my_turf = loc
	RegisterSignal(my_turf, COMSIG_TURF_LIQUIDS_CREATION, .proc/liquids_signal)
	if(my_turf.liquids)
		START_PROCESSING(SSobj, src)
		processing = TRUE

/obj/structure/drain/proc/liquids_signal()
	SIGNAL_HANDLER
	if(processing || welded)
		return
	START_PROCESSING(SSobj, src)
	processing = TRUE

/obj/structure/drain/Destroy()
	if(processing)
		STOP_PROCESSING(SSobj, src)
	UnregisterSignal(my_turf, COMSIG_TURF_LIQUIDS_CREATION)
	my_turf = null
	return ..()

/obj/structure/drain/big
	desc = "Drainage inlet embedded in the floor to prevent flooding. This one seems large."
	icon_state = "bigdrain"
	drain_percent = 0.3
	drain_flat = 15
