/turf/open/indestructible/reebe_void
	name = "void"
	desc = "A white, empty void, quite unlike anything you've seen before."
	icon_state = "reebemap"
	layer = SPACE_LAYER
	baseturfs = /turf/open/indestructible/reebe_void
	planetary_atmos = TRUE
	bullet_bounce_sound = null //forever falling
	tiled_dirt = FALSE


/turf/open/indestructible/reebe_void/Initialize(mapload)
	. = ..()
	icon_state = "reebegame"


/turf/open/indestructible/reebe_void/Enter(atom/movable/movable, atom/old_loc, walkable)
	if(walkable)
		return ..()

	if(!..())
		return FALSE
	else
		if(istype(movable, /obj/structure/window))
			return FALSE
		if(istype(movable, /obj/projectile))
			return TRUE
		return FALSE


/turf/open/indestructible/reebe_void/walkable
	icon_state = "reebespawn"

/turf/open/indestructible/reebe_void/walkable/Enter(atom/movable/movable, atom/old_loc, walkable = TRUE)
	. = ..()

/turf/open/indestructible/reebe_void/spawning
	icon_state = "reebespawn"


/turf/open/indestructible/reebe_void/spawning/Initialize(mapload)
	. = ..()
	if(mapload)
		if(prob(2))
			new /obj/structure/fluff/clockwork/alloy_shards/large(src)

		if(prob(4))
			new /obj/structure/fluff/clockwork/alloy_shards/medium(src)

		if(prob(6))
			new /obj/structure/fluff/clockwork/alloy_shards/small(src)

/turf/open/indestructible/reebe_void/spawning/lattices
	icon_state = "reebelattice"

/turf/open/indestructible/reebe_void/spawning/lattices/Initialize(mapload)
	. = ..()
	if(mapload)
		if(prob(40))
			new /obj/structure/lattice/clockwork(src)

//edge of the reebe map
/turf/open/indestructible/reebe_void/void_edge
	icon_state = "reebespawn"

/turf/open/indestructible/reebe_flooring //used on reebe
	name = "clockwork floor"
	desc = "You feel a faint warmth from below it."
	icon_state = "clockwork_floor"
	planetary_atmos = TRUE
	baseturfs = /turf/open/indestructible/reebe_flooring
	turf_flags = NOJAUNT

/turf/open/indestructible/reebe_flooring/ratvar_act()
	return FALSE

/turf/open/indestructible/reebe_flooring/flat
	icon_state = "reebe"

/turf/open/indestructible/reebe_flooring/filled
	icon_state = "clockwork_floor_filled"

/turf/closed/wall/clockwork //version created by clock cultists
	name = "clockwork wall"
	desc = "A forboding clump of gears that turn on their own. A faint glow emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	turf_flags = IS_SOLID
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = null
	sheet_type = /obj/item/stack/sheet/bronze
	sheet_amount = 2
	girder_type = /obj/structure/girder/bronze
	turf_flags = NOJAUNT
	hardness = 3 //very hard for hulks to break
	//for deconstruction
	var/d_state = INTACT
	wall_trim = null //monkestation edit

/turf/closed/wall/clockwork/hulk_recoil(obj/item/bodypart/arm, mob/living/carbon/human/hulkman, damage = 41)
	if(IS_CLOCK(hulkman)) //dont recoil for clock cultists
		damage = 0
	return ..()

/turf/closed/wall/clockwork/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return

/turf/closed/wall/clockwork/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			return IS_CLOCK(user) ? span_notice("You see a way to unwind the gears with a <i>wrench</i>.") : span_notice("You have no idea how this works! \
																											 You think you see a small cog that could be <i>cut</i> loose.")
		if(COVER_COG_REMOVED)
			return span_notice("The outer cog has been <i>cut</i> loose, and some inner transmission cogs secured by <b>screws</b> are visable.")
		if(TRANSMISSION_COGS_REMOVED)
			return span_notice("The transmission cogs have been <i>screwed</i> loose. It looks like you could <b>unbolt</b> the gears now.")
		if(GEARS_UNBOLTED)
			return span_notice("The main gears have been <i>unbolted</i> and have stopped turning. You see a support beam that looks like it might fall off if <i>heated</i>.")
		if(INNER_PANEL_REMOVED)
			return span_notice("The support beam has been <i>heated</i> off. It looks like you could <i>pry</i> the rest apart.")
		if(GEARS_UNWOUND)
			return span_notice("The gears have been unwound with a <i>wrench</i>. You could take the rest apart with a <i>crowbar</i>.")

/turf/closed/wall/clockwork/try_decon(obj/item/item_tool, mob/user)
	switch(d_state)
		if(INTACT)
			if(IS_CLOCK(user) && item_tool.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start to unwind the gears"))
				if(next_decon_state(item_tool, user, d_state, GEARS_UNWOUND, "You unwind the gears."))
					return TRUE
			if(item_tool.tool_behaviour == TOOL_WIRECUTTER)
				item_tool.play_tool_sound(src, 100)
				d_state = COVER_COG_REMOVED
				to_chat(user, span_notice("You cut the outer cog."))
				return TRUE

		if(COVER_COG_REMOVED)
			if(item_tool.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("You start to unscrew the transmission cogs."))
				if(next_decon_state(item_tool, user, d_state, TRANSMISSION_COGS_REMOVED, "You unscrew the transmission cogs.", 3 SECONDS))
					return TRUE
			else if(item_tool.tool_behaviour == TOOL_WIRECUTTER)
				item_tool.play_tool_sound(src, 100)
				d_state = INTACT
				to_chat(user, span_notice("You put the cover cog back in place."))
				return TRUE

		if(TRANSMISSION_COGS_REMOVED)
			if(item_tool.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start to unbolt the main gears."))
				if(next_decon_state(item_tool, user, d_state, GEARS_UNBOLTED, "You unbolt the main gears."))
					return TRUE
			if(item_tool.tool_behaviour == TOOL_SCREWDRIVER)
				to_chat(user, span_notice("You start to tighten thetransmission cogs."))
				if(next_decon_state(item_tool, user, d_state, COVER_COG_REMOVED, "You tighten the transmission cogs."))
					return TRUE

		if(GEARS_UNBOLTED)
			if(item_tool.tool_behaviour == TOOL_WELDER)
				if(!item_tool.tool_start_check(user, amount=0))
					return
				to_chat(user, span_notice("You start to weld the support beam loose."))
				if(next_decon_state(item_tool, user, d_state, INNER_PANEL_REMOVED, "You weld the support beam loose.", 6 SECONDS))
					return TRUE
			if(item_tool.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start to re-attach the main gears."))
				if(next_decon_state(item_tool, user, d_state, TRANSMISSION_COGS_REMOVED, "You re-attach the main gears."))
					return TRUE

		if(INNER_PANEL_REMOVED)
			if(item_tool.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("You start to pry apart the [src]."))
				if(next_decon_state(item_tool, user, d_state, sent_message = "You pry apart the [src].", use_time = 5 SECONDS))
					dismantle_wall()
				return TRUE
			if(item_tool.tool_behaviour == TOOL_WELDER)
				if(!item_tool.tool_start_check(user, amount=0))
					return
				to_chat(user, span_notice("You start to weld the support beam back into place."))
				if(next_decon_state(item_tool, user, d_state, GEARS_UNBOLTED, "You weld the support beam back into place.", 6 SECONDS))
					return TRUE

		if(GEARS_UNWOUND)
			if(item_tool.tool_behaviour == TOOL_CROWBAR)
				to_chat(user, span_notice("You tart to pry apart the [src]."))
				if(next_decon_state(item_tool, user, d_state, sent_message = "You pry apart the [src].", use_time = 5 SECONDS))
					dismantle_wall()
				return TRUE
			if(item_tool.tool_behaviour == TOOL_WRENCH)
				to_chat(user, span_notice("You start to re-wind the gears."))
				if(next_decon_state(item_tool, user, d_state, INTACT, "You re-wind the gears."))
					return TRUE
	return FALSE

//do the deconstruction stuff, this really should be a proc on Rwalls as well
/turf/closed/wall/clockwork/proc/next_decon_state(obj/item/used_tool, mob/user, current_state, set_state, sent_message, use_time = 4 SECONDS)
	if(on_reebe(src))
		use_time = round(use_time * 0.2, 0.1) //it takes much less time to deconstruct walls on reebe

	if(used_tool.use_tool(src, user, use_time, volume=100))
		if(!istype(src, /turf/closed/wall/clockwork) || d_state != current_state)
			return TRUE
		if(set_state)
			d_state = set_state
		to_chat(user, span_notice("[sent_message]"))
		return TRUE

/turf/closed/wall/clockwork/ratvar_act()
	return FALSE

/turf/closed/wall/clockwork/rust_heretic_act()
	visible_message(span_warning("\The [src] glows for a second, but is uneffected by the magic!"))
	return

/turf/closed/wall/clockwork/reebe //for mapping on reebe
	baseturfs = /turf/open/indestructible/reebe_flooring

/obj/structure/lattice/clockwork
	name = "cog lattice"
	desc = "A lightweight support lattice. These hold the Justicar's station together."
	icon = 'monkestation/icons/obj/clock_cult/lattice_clockwork.dmi'
	icon_state = "lattice_clockwork-0"
	base_icon_state = "lattice_clockwork"
	smoothing_groups = SMOOTH_GROUP_LATTICE
	canSmoothWith = SMOOTH_GROUP_LATTICE

/obj/structure/lattice/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(on_reebe(src))
		resistance_flags |= INDESTRUCTIBLE

/obj/structure/lattice/clockwork/ratvar_act()
	if(ISODD(x+y)) //this check looks to be broken
		icon = 'monkestation/icons/obj/clock_cult/lattice_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'monkestation/icons/obj/clock_cult/lattice_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

/obj/structure/lattice/catwalk/clockwork
	name = "clockwork catwalk"
	icon = 'monkestation/icons/obj/clock_cult/catwalk_clockwork.dmi'
	icon_state = "catwalk_clockwork-0"
	base_icon_state = "catwalk_clockwork"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_CATWALK + SMOOTH_GROUP_LATTICE + SMOOTH_GROUP_OPEN_FLOOR
	canSmoothWith = SMOOTH_GROUP_CATWALK

/obj/structure/lattice/catwalk/clockwork/Initialize(mapload)
	. = ..()
	if(!mapload)
		new /obj/effect/temp_visual/ratvar/floor/catwalk(loc)
		new /obj/effect/temp_visual/ratvar/beam/catwalk(loc)
	if(on_reebe(src))
		resistance_flags |= INDESTRUCTIBLE

/obj/structure/lattice/catwalk/clockwork/ratvar_act()
	if(ISODD(x+y))
		icon = 'monkestation/icons/obj/clock_cult/catwalk_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'monkestation/icons/obj/clock_cult/catwalk_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE
