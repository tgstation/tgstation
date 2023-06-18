/turf/closed/wall
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/walls/icons/wall.dmi'
	canSmoothWith = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS

/turf/closed/wall/r_wall
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/walls/icons/reinforced_wall.dmi'

/turf/closed/wall/rust
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/walls/icons/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"

/turf/closed/wall/r_wall/rust
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/walls/icons/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"

/turf/closed/wall/rust/New(loc, ...)
	. = ..()
	var/mutable_appearance/rust = mutable_appearance(icon, "rust")
	add_overlay(rust)

/turf/closed/wall/r_wall/rust/New(loc, ...)
	. = ..()
	var/mutable_appearance/rust = mutable_appearance(icon, "rust")
	add_overlay(rust)

/obj/structure/falsewall/material
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/walls/icons/material_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"

/turf/closed/wall/material
	icon = 'modular_skyraptor/modules/aesthetics/inherited_skyrat/walls/icons/material_wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
