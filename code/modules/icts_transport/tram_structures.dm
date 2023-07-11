/obj/structure/window/reinforced/tram_new
	name = "tram"
	desc = "A reinforced, air-locked modular tram structure with titanium silica windows."
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
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2
	rad_insulation = RAD_MEDIUM_INSULATION
	glass_material_datum = /datum/material/alloy/titaniumglass

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
	find_tram()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(set_spoiler))

/obj/structure/tram/spoiler/proc/find_tram()
	for(var/datum/lift_master/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(tram.specific_lift_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/structure/tram/spoiler/proc/set_spoiler(source, travelling, direction)
	SIGNAL_HANDLER

	if(!travelling)
		return
	switch(direction)
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
