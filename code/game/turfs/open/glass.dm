/turf/open/floor/glass
	name = "Glass floor"
	desc = "Dont jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	baseturfs = /turf/open/openspace
	overfloor_placed = FALSE // We can't tear this up, with explosives or other means.
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_TRANSPARENT_GLASS)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	floor_tile = /obj/item/stack/sheet/glass
	/// Whether or not the screws on the sheet are currently welded.
	var/welded_screws = FALSE
	/// Used to stop maploaded tiles from being griefed. If people would prefer for the ability to open a hole in space anywhere a mapper put glass, just remove this.
	var/permanent_tile = FALSE

/turf/open/floor/glass/setup_broken_states()
	return list("glass-damaged1", "glass-damaged2", "glass-damaged3")

/turf/open/floor/glass/Initialize(mapload)
	if(mapload)
		welded_screws = TRUE
		permanent_tile = TRUE
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, TRUE)

/turf/open/floor/glass/examine(mob/user)
	. = ..()
	if(permanent_tile)
		. += span_notice("This glass has been Space-Glued in place! There's no way you're removing it.")
	else if(welded_screws)
		. += span_notice("Its screws are welded tightly in place!")
	else
		. += span_notice("It looks like it could be unscrewed from the lattice housing it.")

/turf/open/floor/glass/screwdriver_act(mob/living/user, obj/item/tool)
	..()
	if(!istype(src, /turf/open/floor/glass))
			return
	if(permanent_tile)
		to_chat(user, span_warning("There's nothing to unscrew!"))
		return
	if(welded_screws)
		to_chat(user, span_warning("The screws are welded in place!"))
		return
	to_chat(user, span_notice("You begin unscrewing the glass..."))
	if(tool.use_tool(src, user, 5 SECONDS, volume=80))
		if(floor_tile)
			new floor_tile(src, 1)
		ReplaceWithLattice()
	return TRUE

/turf/open/floor/glass/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(permanent_tile)
		to_chat(user, span_warning("There's nothing to weld!"))
		return
	if(welded_screws)
		user.visible_message(span_warning("[user] begins unwelding the glass floor screws!"), span_notice("You begin unwelding the screws on the glass floor..."))
		if(tool.use_tool(src, user, 10 SECONDS, volume=85))
			to_chat(user, span_notice("The screws are stripped of their welded reinforcements."))
			welded_screws = FALSE
			return TRUE
	else
		user.visible_message(span_notice("[user] begins welding the glass floor screws."), span_notice("You begin welding the screws on the glass floor..."))
		if(tool.use_tool(src, user, 5 SECONDS, volume=60))
			to_chat(user, span_notice("The screws are red-hot, melting to the frame of the glass."))
			welded_screws = TRUE
		return TRUE

/turf/open/floor/glass/reinforced
	name = "Reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"
	floor_tile = /obj/item/stack/sheet/rglass

/turf/open/floor/glass/reinforced/setup_broken_states()
	return list("reinf_glass-damaged1", "reinf_glass-damaged2", "reinf_glass-damaged3")
