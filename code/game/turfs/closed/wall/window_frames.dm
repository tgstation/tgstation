/turf/closed/wall/window_frame
	name = "window frame"
	desc = "A frame section to place a window on top."
	icon = 'icons/turf/walls/low_walls/low_wall_normal.dmi'
	icon_state = "low_wall_normal-0"
	base_icon_state = "low_wall_normal"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOWS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOWS)
	opacity = FALSE
	density = TRUE
	blocks_air = FALSE
	flags_1 = RAD_NO_CONTAMINATE_1
	rad_insulation = null
	frill_icon = 'icons/effects/frills/window_normal_frill.dmi'
	///Bitflag to hold state on what other objects we have
	var/window_state = NONE
	///Icon used by grilles for this window frame
	var/grille_icon = 'icons/turf/walls/window_grille.dmi'
	///Icon state used by grilles for this window frame
	var/grille_icon_state = "window_grille"
	///Icon used by windows for this window frame
	var/window_icon = 'icons/turf/walls/window_normal.dmi'
	///Icon state used by windows for this window frame
	var/window_icon_state = "window_normal"
	///Frill used for window frame


/turf/closed/wall/window_frame/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	update_icon()

///delightfully devilous seymour
/turf/closed/wall/window_frame/set_smoothed_icon_state(new_junction)
	. = ..()
	update_icon()

/turf/closed/wall/window_frame/update_appearance(updates)
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		AddElement(/datum/element/frill, frill_icon)
	else
		RemoveElement(/datum/element/frill)

/turf/closed/wall/window_frame/update_overlays()
	. = ..()
	if(window_state & WINDOW_FRAME_WITH_GRILLES)
		. += mutable_appearance(grille_icon, "[grille_icon_state]-[smoothing_junction]")
	if(window_state & WINDOW_FRAME_WITH_WINDOW)
		. += mutable_appearance(window_icon, "[window_icon_state]-[smoothing_junction]")

/turf/closed/wall/window_frame/grille
	window_state = WINDOW_FRAME_WITH_GRILLES

/turf/closed/wall/window_frame/grille_and_window
	window_state = WINDOW_FRAME_WITH_GRILLES | WINDOW_FRAME_WITH_WINDOW

/turf/closed/wall/window_frame/titanium
	name = "shuttle window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_shuttle.dmi'
	icon_state = "low_wall_shuttle-0"
	base_icon_state = "low_wall_shuttle"
	custom_materials = list(/datum/material/titanium = 2000)

/turf/closed/wall/window_frame/plastitanium
	name = "plastitanium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_plastitanium.dmi'
	icon_state = "low_wall_plastitanium-0"
	base_icon_state = "low_wall_plastitanium"
	custom_materials = list(/datum/material/alloy/plastitanium = 2000)

/turf/closed/wall/window_frame/wood
	name = "wooden platform"
	icon = 'icons/turf/walls/low_walls/low_wall_wood.dmi'
	icon_state = "low_wall_wood-0"
	base_icon_state = "low_wall_wood"
	custom_materials = list(/datum/material/wood = 2000)

/turf/closed/wall/window_frame/uranium
	name = "uranium window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_uranium.dmi'
	icon_state = "low_wall_uranium-0"
	base_icon_state = "low_wall_uranium"
	custom_materials = list(/datum/material/uranium = 2000)

/turf/closed/wall/window_frame/iron
	name = "rough iron window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_iron.dmi'
	icon_state = "low_wall_iron-0"
	base_icon_state = "low_wall_iron"
	custom_materials = list(/datum/material/iron = 2000)

/turf/closed/wall/window_frame/silver
	name = "silver window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_silver.dmi'
	icon_state = "low_wall_silver-0"
	base_icon_state = "low_wall_silver"
	custom_materials = list(/datum/material/silver = 2000)

/turf/closed/wall/window_frame/gold
	name = "gold window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_gold.dmi'
	icon_state = "low_wall_gold-0"
	base_icon_state = "low_wall_gold"
	custom_materials = list(/datum/material/gold = 2000)

/turf/closed/wall/window_frame/bronze
	name = "clockwork window mount"
	icon = 'icons/turf/walls/low_walls/low_wall_bronze.dmi'
	icon_state = "low_wall_bronze-0"
	base_icon_state = "low_wall_bronze"
	custom_materials = list(/datum/material/bronze = 2000)

/turf/closed/wall/window_frame/cult
	name = "rune-scarred window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_cult.dmi'
	icon_state = "low_wall_cult-0"
	base_icon_state = "low_wall_cult"
	custom_materials = list(/datum/material/runedmetal = 2000)

/turf/closed/wall/window_frame/hotel
	name = "hotel window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_hotel.dmi'
	icon_state = "low_wall_hotel-0"
	base_icon_state = "low_wall_hotel"
	custom_materials = list(/datum/material/wood = 2000)

/turf/closed/wall/window_frame/material
	name = "material window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_material.dmi'
	icon_state = "low_wall_material-0"
	base_icon_state = "low_wall_material"
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/closed/wall/window_frame/rusty
	name = "rusty window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_rusty.dmi'
	icon_state = "low_wall_rusty-0"
	base_icon_state = "low_wall_rusty"
	custom_materials = list(/datum/material/iron = 2000)

/turf/closed/wall/window_frame/sandstone
	name = "sandstone plinth"
	icon = 'icons/turf/walls/low_walls/low_wall_sandstone.dmi'
	icon_state = "low_wall_sandstone-0"
	base_icon_state = "low_wall_sandstone"
	custom_materials = list(/datum/material/sandstone = 2000)

/turf/closed/wall/window_frame/bamboo
	name = "bamboo platform"
	icon = 'icons/turf/walls/low_walls/low_wall_bamboo.dmi'
	icon_state = "low_wall_bamboo-0"
	base_icon_state = "low_wall_bamboo"
	custom_materials = list(/datum/material/bamboo = 2000)

/turf/closed/wall/window_frame/paperframe
	name = "japanese window frame"
	icon = 'icons/turf/walls/low_walls/low_wall_paperframe.dmi'
	icon_state = "low_wall_paperframe-0"
	base_icon_state = "low_wall_paperframe"
	custom_materials = list(/datum/material/paper = 2000)
