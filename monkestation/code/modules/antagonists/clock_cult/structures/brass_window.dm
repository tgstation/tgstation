/obj/structure/window/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 80
	explosion_block = 2
	decon_speed = 4 SECONDS
	glass_type = /obj/item/stack/sheet/bronze
	glass_amount = 1

/obj/structure/window/reinforced/clockwork/Initialize(mapload, direct)
	if(on_reebe(src))
		decon_speed = 1 SECONDS
		max_integrity = round(max_integrity * 0.5) //I would like to make it take double damage instead but this about works for now
	. = ..()

/obj/structure/window/reinforced/clockwork/attackby_secondary(obj/item/tool, mob/user, params)
	if(state == RWINDOW_SECURE)
		if(tool.tool_behaviour == TOOL_WIRECUTTER && IS_CLOCK(user))
			user.visible_message(span_notice("[user] starts cutting the pane of \the [src] away..."),
								 span_notice("You start cutting away the pane of \the [src]."))
			if(tool.use_tool(src, user, 2 SECONDS, volume = 50))
				state = RWINDOW_BARS_CUT
				to_chat(user, span_notice("The window pane falls out of the way exposing the frame bolts."))
	return ..()

/obj/structure/window/reinforced/clockwork/examine(mob/user)
	. = ..()
	if(IS_CLOCK(user))
		if(state == RWINDOW_SECURE)
			. += span_brass("You see a way to <b>cut</b> the window pane away.")

/obj/structure/window/reinforced/clockwork/narsie_act()
	take_damage(rand(25, 75), BRUTE)
	if(!QDELETED(src))
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/obj/structure/window/reinforced/clockwork/ratvar_act()
	return FALSE

/obj/structure/window/reinforced/clockwork/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	return

/obj/structure/window/reinforced/clockwork/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/clockwork/fulltile
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE + SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	max_integrity = 100
	glass_amount = 2

/obj/structure/window/reinforced/clockwork/Initialize(mapload, direct)
	new /obj/effect/temp_visual/ratvar/window(get_turf(src))
	return ..()

/obj/structure/window/reinforced/clockwork/fulltile/unanchored
	anchored = FALSE
