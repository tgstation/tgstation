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

/obj/structure/window/reinforced/tram/Initialize(mapload, direct)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/window/reinforced/tram
	name = "tram window"
	desc = "A lightweight titanium composite structure with a windscreen installed."
	icon = 'icons/obj/smooth_structures/tram_structure.dmi'
	icon_state = "tram-part-0"
	base_icon_state = "tram-part"
	max_integrity = 150
	wtype = "tram"
	reinf = TRUE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	heat_resistance = 1600
	armor_type = /datum/armor/tram_structure
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_INDUSTRIAL_LIFT
	canSmoothWith = SMOOTH_GROUP_INDUSTRIAL_LIFT
	can_be_unanchored = FALSE
	can_atmos_pass = ATMOS_PASS_DENSITY
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/titaniumglass

/obj/structure/window/reinforced/tram/solid
	name = "tram structure"
	desc = "A reinforced modular tram structure with tinted titanium glass accents."
	opacity = TRUE

/obj/structure/window/reinforced/tram/split
	base_icon_state = "tram-split"

/datum/armor/tram_structure
	melee = 80
	bullet = 5
	bomb = 45
	fire = 99
	acid = 100

/obj/structure/tram/spoiler
	name = "tram spoiler"
	icon = 'icons/obj/smooth_structures/tram_structure.dmi'
	desc = "Nanotrasen bought the luxury package under the impression titanium spoilers make the tram go faster. They're just for looks, or potentially stabbing anybody who gets in the way."
	icon_state = "tram-spoiler-retracted"
	opacity = TRUE
	///Position of the spoiler
	var/deployed = FALSE
	///Weakref to the tram piece we control
	var/datum/weakref/tram_ref
	///The tram we're attached to
	var/tram_id = TRAMSTATION_LINE_1

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
	greyscale_colors = "#00CCFF"

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
