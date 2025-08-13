/obj/machinery/byteforge
	name = "byteforge"

	circuit = /obj/item/circuitboard/machine/byteforge
	desc = "A machine used by the quantum server. Quantum code converges here, materializing decrypted assets from the virtual abyss."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "byteforge"
	base_icon_state = "byteforge"
	obj_flags = BLOCKS_CONSTRUCTION | CAN_BE_HIT
	/// Idle particles
	var/mutable_appearance/byteforge_particles

/obj/machinery/byteforge/Initialize(mapload)
	. = ..()

	register_context()

/obj/machinery/byteforge/post_machine_initialize()
	. = ..()

	setup_particles()

/obj/machinery/byteforge/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/byteforge/examine(mob/user)
	. = ..()

	. += span_notice("Make sure this is 4 tiles from the quantum server")

	. += span_notice("Its maintainance panel can be [EXAMINE_HINT("screwed")] [panel_open ? "close" : "open"].")
	if(panel_open)
		. += span_notice("It can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/byteforge/update_appearance(updates)
	. = ..()

	setup_particles()

/obj/machinery/byteforge/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ITEM_INTERACT_FAILURE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", base_icon_state, screwdriver))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/byteforge/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ITEM_INTERACT_FAILURE
	if(default_deconstruction_crowbar(crowbar))
		return ITEM_INTERACT_SUCCESS

/// Does some sparks after it's done
/obj/machinery/byteforge/proc/flash(atom/movable/thing)
	playsound(src, 'sound/effects/magic/blink.ogg', 50, TRUE)

	var/datum/effect_system/spark_spread/quantum/sparks = new()
	sparks.set_up(5, 1, loc)
	sparks.start()

	set_light(l_on = FALSE)

/// Forge begins to process
/obj/machinery/byteforge/proc/flicker(angry = FALSE)
	var/mutable_appearance/lighting = mutable_appearance(initial(icon), "on_overlay[angry ? "_angry" : ""]")
	flick_overlay_view(lighting, 1 SECONDS)

	set_light(l_range = 2, l_power = 1.5, l_color = angry ? LIGHT_COLOR_BUBBLEGUM : LIGHT_COLOR_BABY_BLUE, l_on = TRUE)

/// Adds the particle overlays to the byteforge
/obj/machinery/byteforge/proc/setup_particles(angry = FALSE)
	cut_overlay(byteforge_particles)

	byteforge_particles = mutable_appearance(initial(icon), "on_particles[angry ? "_angry" : ""]", ABOVE_MOB_LAYER)

	if(is_operational)
		add_overlay(byteforge_particles)

/// Forge is done processing
/obj/machinery/byteforge/proc/spawn_cache(obj/cache)
	if(QDELETED(cache))
		return

	flash()

	cache.forceMove(loc)

/// Timed flash
/obj/machinery/byteforge/proc/start_to_spawn(obj/cache)
	flicker()

	addtimer(CALLBACK(src, PROC_REF(spawn_cache), cache), 1 SECONDS)

