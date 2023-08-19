/**
 * the tram has a few objects mapped onto it at roundstart, by default many of those objects have unwanted properties
 * for example grilles and windows have the atmos_sensitive element applied to them, which makes them register to
 * themselves moving to re register signals onto the turf via connect_loc. this is bad and dumb since it makes the tram
 * more expensive to move.
 *
 * if you map something on to the tram, make SURE if possible that it doesnt have anything reacting to its own movement
 * it will make the tram more expensive to move and we dont want that because we dont want to return to the days where
 * the tram took a third of the tick per movement when its just carrying its default mapped in objects
 */

/obj/structure/grille/tram/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	//atmos_sensitive applies connect_loc which 1. reacts to movement in order to 2. unregister and register signals to
	//the old and new locs. we dont want that, pretend these grilles and windows are plastic or something idk

/obj/structure/tram/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/tram
	name = "tram"
	desc = "A lightweight titanium composite structure with titanium silicate panels."
	icon = 'icons/obj/tram/tram_structure.dmi'
	icon_state = "tram-part-0"
	base_icon_state = "tram-part"
	max_integrity = 150
	layer = LOW_OBJ_LAYER
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	armor_type = /datum/armor/tram_structure
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TRAM_STRUCTURE
	canSmoothWith = SMOOTH_GROUP_TRAM_STRUCTURE
	can_be_unanchored = FALSE
	can_atmos_pass = ATMOS_PASS_DENSITY
	explosion_block = 3
	receive_ricochet_chance_mod = 1.2
	rad_insulation = RAD_MEDIUM_INSULATION
	var/state = TRAM_SCREWED_TO_FRAME
	var/mineral = /obj/item/stack/sheet/titaniumglass
	var/mineral_amount = 2
	var/tram_wall_type = /obj/structure/tram
	var/girder_type = /obj/structure/girder/tram
	var/break_sound = SFX_SHATTER
	var/knock_sound = 'sound/effects/glassknock.ogg'
	var/bash_sound = 'sound/effects/glassbash.ogg'
	var/hit_sound = 'sound/effects/glasshit.ogg'

/obj/structure/tram/solid
	desc = "A lightweight titanium composite structure with tinted titanium silicate panels."
	opacity = TRUE

/obj/structure/tram/split
	base_icon_state = "tram-split"

/datum/armor/tram_structure
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

/obj/structure/tram/Initialize(mapload)
	AddElement(/datum/element/blocks_explosives)
	. = ..()
	var/obj/item/stack/initialized_mineral = new mineral
	set_custom_materials(initialized_mineral.mats_per_unit, mineral_amount)
	qdel(initialized_mineral)
	air_update_turf(TRUE, TRUE)

/obj/structure/tram/examine(mob/user)
	. = ..()
	switch(state)
		if(WINDOW_SCREWED_TO_FRAME)
			. += span_notice("The panel is <b>screwed</b> to the frame.")
		if(WINDOW_IN_FRAME)
			. += span_notice("The panel is <i>unscrewed</i> but <b>pried</b> into the frame.")
		if(WINDOW_OUT_OF_FRAME)
			if (anchored)
				. += span_notice("The panel is <b>screwed</b> to the frame.")
			else
				. += span_notice("The panel is <i>unscrewed</i> from the frame, and could be deconstructed by <b>wrenching</b>.")

/obj/structure/tram/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	if(!user.combat_mode)
		user.visible_message(span_notice("[user] knocks on [src]."), \
			span_notice("You knock on [src]."))
		playsound(src, knock_sound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] bashes [src]!"), \
			span_warning("You bash [src]!"))
		playsound(src, bash_sound, 100, TRUE)

/obj/structure/tram/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 3 SECONDS, "cost" = 10)
	return FALSE

/obj/structure/tram/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/tram/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/tram/singularity_pull(singulo, current_size)
	..()

	if(current_size >= STAGE_FIVE)
		deconstruct(disassembled = FALSE)

/obj/structure/tram/welder_act(mob/living/user, obj/item/tool)
	if(atom_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(!tool.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, span_notice("You begin repairing [src]..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		atom_integrity = max_integrity
		to_chat(user, span_notice("You repair [src]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/tram/attackby_secondary(obj/item/tool, mob/user, params)
	switch(state)
		if(TRAM_SCREWED_TO_FRAME)
			if(tool.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] begins to unscrew the tram panel from the frame..."),
										span_notice("You begin to unscrew the tram panel from the frame..."))
				if(tool.use_tool(src, user, 50, volume = 50))
					state = TRAM_IN_FRAME
					to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the pane."))
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The security screws need to be removed first!"))

		if(TRAM_IN_FRAME)
			if(tool.tool_behaviour == TOOL_CROWBAR)
				user.visible_message(span_notice("[user] wedges \the [tool] into the tram panel's gap in the frame and starts prying..."),
										span_notice("You wedge \the [tool] into the tram panel's gap in the frame and start prying..."))
				if(tool.use_tool(src, user, 40, volume = 50))
					state = TRAM_OUT_OF_FRAME
					to_chat(user, span_notice("The panel pops out of the frame, exposing some cabling that look like they can be cut."))
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The panel to be pried first!"))

		if(TRAM_OUT_OF_FRAME)
			if(tool.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(span_notice("[user] starts cutting the connective cabling on \the [src]..."),
										span_notice("You start cutting the connective cabling on \the [src]"))
				if(tool.use_tool(src, user, 20, volume = 50))
					to_chat(user, span_notice("The panels falls out of the way exposing the frame backing."))
					deconstruct(disassembled = TRUE)
			else if (tool.tool_behaviour)
				to_chat(user, span_warning("The cabling need to be cut first!"))

	if (tool.tool_behaviour)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

/obj/structure/tram/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/*
 * Other misc tramwall types
 */

/obj/structure/tram/titanium
	name = "solid tram"
	desc = "A lightweight titanium composite structure. There is further solid plating where the panels usually attach to the frame."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle_wall-0"
	base_icon_state = "shuttle_wall"
	mineral = /obj/item/stack/sheet/mineral/titanium
	tram_wall_type = /obj/structure/tram/titanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_TITANIUM_WALLS

/obj/structure/tram/plastitanium
	name = "reinforced tram"
	desc = "An evil tram of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	tram_wall_type = /obj/structure/tram/plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_PLASTITANIUM_WALLS

/obj/structure/tram/gold
	name = "gold tram"
	desc = "A solid gold tram. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	mineral = /obj/item/stack/sheet/mineral/gold
	tram_wall_type = /obj/structure/tram/gold
	explosion_block = 0 //gold is a soft metal you dingus.
	smoothing_groups = SMOOTH_GROUP_GOLD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_GOLD_WALLS
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tram/silver
	name = "silver tram"
	desc = "A solid silver tram. Shiny!"
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	mineral = /obj/item/stack/sheet/mineral/silver
	tram_wall_type = /obj/structure/tram/silver
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SILVER_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_SILVER_WALLS
	custom_materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tram/diamond
	name = "diamond tram"
	desc = "A composite structure with diamond-plated panels. Looks awfully sharp..."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	mineral = /obj/item/stack/sheet/mineral/diamond
	tram_wall_type = /obj/structure/tram/diamond //diamond wall takes twice as much time to slice
	max_integrity = 800
	explosion_block = 3
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_DIAMOND_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_DIAMOND_WALLS
	custom_materials = list(/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tram/bananium
	name = "bananium tram"
	desc = "A composite structure with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	mineral = /obj/item/stack/sheet/mineral/bananium
	tram_wall_type = /obj/structure/tram/bananium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS
	custom_materials = list(/datum/material/bananium = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/sandstone
	name = "sandstone tram"
	desc = "A composite structure with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	tram_wall_type = /obj/structure/tram/sandstone
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS
	custom_materials = list(/datum/material/sandstone = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/uranium
	article = "a"
	name = "uranium tram"
	desc = "A composite structure with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	mineral = /obj/item/stack/sheet/mineral/uranium
	tram_wall_type = /obj/structure/tram/uranium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_URANIUM_WALLS
	custom_materials = list(/datum/material/uranium = SHEET_MATERIAL_AMOUNT*2)

	/// Mutex to prevent infinite recursion when propagating radiation pulses
	var/active = null

	/// The last time a radiation pulse was performed
	var/last_event = 0

/obj/structure/tram/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/tram/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	return ..()

/obj/structure/tram/uranium/proc/radiate()
	SIGNAL_HANDLER
	if(active)
		return
	if(world.time <= last_event + 1.5 SECONDS)
		return
	active = TRUE
	radiation_pulse(
		src,
		max_range = 3,
		threshold = RAD_LIGHT_INSULATION,
		chance = URANIUM_IRRADIATION_CHANCE,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)
	propagate_radiation_pulse()
	last_event = world.time
	active = FALSE

/obj/structure/tram/plasma
	name = "plasma tram"
	desc = "A composite structure with plasma plating. This is definitely a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/plasma
	tram_wall_type = /obj/structure/tram/plasma
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS
	custom_materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/wood
	name = "wooden tram"
	desc = "A tram with wooden framing. Flammable. There's a reason we use metal now."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	mineral = /obj/item/stack/sheet/mineral/wood
	tram_wall_type = /obj/structure/tram/wood
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/wood/attackby(obj/item/W, mob/user)
	if(W.get_sharpness() && W.force)
		var/duration = ((4.8 SECONDS) / W.force) * 2 //In seconds, for now.
		if(istype(W, /obj/item/hatchet) || istype(W, /obj/item/fireaxe))
			duration /= 4 //Much better with hatchets and axes.
		if(do_after(user, duration * (1 SECONDS), target=src)) //Into deciseconds.
			deconstruct(disassembled = FALSE)
			return
	return ..()

/obj/structure/tram/bamboo
	name = "bamboo tram"
	desc = "A tram with a bamboo framing."
	icon = 'icons/turf/walls/bamboo_wall.dmi'
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_BAMBOO_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_BAMBOO_WALLS
	mineral = /obj/item/stack/sheet/mineral/bamboo
	tram_wall_type = /obj/structure/tram/bamboo

/obj/structure/tram/iron
	name = "rough iron tram"
	desc = "A composite structure with rough iron plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	tram_wall_type = /obj/structure/tram/iron
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5)

/obj/structure/tram/abductor
	name = "alien tram"
	desc = "A composite structure made of some kind of alien alloy."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	tram_wall_type = /obj/structure/tram/abductor
	explosion_block = 3
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS
	custom_materials = list(/datum/material/alloy/alien = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/material
	name = "tram"
	desc = "A composite structure and attached panelling forming a tram."
	icon = 'icons/turf/walls/materialwall.dmi'
	icon_state = "materialwall-0"
	base_icon_state = "materialwall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MATERIAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MATERIAL_WALLS
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/tram/material/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new girder_type(loc)
		for(var/material in custom_materials)
			var/datum/material/material_datum = material
			new material_datum.sheet_type(loc, FLOOR(custom_materials[material_datum] / SHEET_MATERIAL_AMOUNT, 1))
	qdel(src)

/obj/structure/tram/material/mat_update_desc(mat)
	desc = "A [mat] structure with matching solid accent panels."

/obj/structure/tram/material/update_icon(updates)
	. = ..()
	for(var/datum/material/material in custom_materials)
		if(material.alpha < 255)
			update_transparency_underlays()
			return

/obj/structure/tram/material/proc/update_transparency_underlays()
	underlays.Cut()
	var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = LOW_OBJ_LAYER-0.01)
	girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
	underlays += girder_underlay

/obj/structure/tram/get_dumping_location()
	return null

/obj/structure/tram/spoiler
	name = "tram spoiler"
	icon = 'icons/obj/tram/tram_structure.dmi'
	desc = "Nanotrasen bought the luxury package under the impression titanium spoilers make the tram go faster. They're just for looks, or potentially stabbing anybody who gets in the way."
	icon_state = "tram-spoiler-retracted"
	opacity = TRUE
	///Position of the spoiler
	var/deployed = FALSE
	///Weakref to the tram piece we control
	var/datum/weakref/tram_ref
	///The tram we're attached to
	var/tram_id = TRAMSTATION_LINE_1
	mineral = /obj/item/stack/sheet/titaniumglass
	girder_type = /obj/structure/girder/tram/corner

/obj/structure/tram/spoiler/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/tram/spoiler/LateInitialize()
	. = ..()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(set_spoiler))

/obj/structure/tram/spoiler/proc/set_spoiler(source, controller, controller_active, controller_status, travel_direction)
	SIGNAL_HANDLER

	var/spoiler_direction = travel_direction
	if(obj_flags & EMAGGED || controller_status & SYSTEM_FAULT)
		do_sparks(3, cardinal_only = FALSE, source = src)
		if(!deployed)
			// Bring out the blades
			deploy_spoiler()
		return

	if(!controller_active)
		return

	switch(spoiler_direction)
		if(SOUTH, EAST)
			switch(dir)
				if(NORTH, EAST)
					retract_spoiler()
				if(SOUTH, WEST)
					deploy_spoiler()

		if(NORTH, WEST)
			switch(dir)
				if(NORTH, EAST)
					deploy_spoiler()
				if(SOUTH, WEST)
					retract_spoiler()
	return

/obj/structure/tram/spoiler/proc/deploy_spoiler()
	if(deployed)
		return
	flick("tram-spoiler-deploying", src)
	icon_state = "tram-spoiler-deployed"
	deployed = TRUE

/obj/structure/tram/spoiler/proc/retract_spoiler()
	if(!deployed)
		return
	flick("tram-spoiler-retracting", src)
	icon_state = "tram-spoiler-retracted"
	deployed = FALSE

/obj/structure/tram/spoiler/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_warning("You short-circuit the [src]'s locking mechanism!"), type = MESSAGE_TYPE_INFO)
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(5, cardinal_only = FALSE, source = src)
	obj_flags |= EMAGGED

/obj/structure/tram/spoiler/multitool_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE

	if(obj_flags & EMAGGED)
		balloon_alert(user, "electronics reset!")
		obj_flags &= ~EMAGGED
		return TRUE

	return FALSE

/obj/structure/chair/sofa/bench/tram
	name = "bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = "#6160a8"

/obj/structure/chair/sofa/bench/tram/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/tram/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/tram/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/tram/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo
