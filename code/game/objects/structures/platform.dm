/// A raised platform you can stand on top of
/obj/structure/platform
	name = "platform"
	desc = "A raised platform which can make you slightly taller."
	icon = 'icons/obj/smooth_structures/platform/window_frame_normal.dmi'
	icon_state = "window_frame_normal-0"
	base_icon_state = "window_frame_normal"
	smoothing_flags = SMOOTH_BITMASK|SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_HALF_WALLS
	canSmoothWith = SMOOTH_GROUP_HALF_WALLS
	pass_flags_self = PASSTABLE | LETPASSTHROW | PASSGRILLE | PASSWINDOW
	opacity = FALSE
	density = TRUE
	rad_insulation = null
	max_integrity = 50
	anchored = TRUE
	armor_type = /datum/armor/half_wall
	/// Icon used for the frame
	var/frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_normal.dmi'
	/// Material used in our construction
	var/sheet_type = /obj/item/stack/sheet/iron
	/// Count of sheets used in our construction
	var/sheet_amount = 2
	/// Traits to give people who have clambered onto our tile
	var/static/list/turf_traits = list(TRAIT_TURF_IGNORE_SLOWDOWN, TRAIT_TURF_IGNORE_SLIPPERY, TRAIT_IMMERSE_STOPPED)

/datum/armor/half_wall
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10
	bio = 100
	fire = 0
	acid = 0

/obj/structure/platform/Initialize(mapload)
	. = ..()

	update_appearance(UPDATE_OVERLAYS)
	AddComponent(/datum/component/climb_walkable)
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)
	AddElement(/datum/element/give_turf_traits, turf_traits)
	AddElement(/datum/element/footstep_override, priority = STEP_SOUND_TABLE_PRIORITY)
	AddComponent(/datum/component/table_smash)

/obj/structure/platform/update_overlays()
	. = ..()
	if (frame_icon)
		. += mutable_appearance(frame_icon, "[base_icon_state]-[smoothing_junction]", appearance_flags = KEEP_APART)

/obj/structure/platform/set_smoothed_icon_state(new_junction)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/platform/pizza
	icon = 'icons/obj/smooth_structures/platform/window_frame_pizza.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_pizza.dmi'
	icon_state = "window_frame_pizza-0"
	base_icon_state = "window_frame_pizza"

/obj/structure/platform/stone
	icon = 'icons/obj/smooth_structures/platform/window_frame_sandstone.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_sandstone.dmi'
	icon_state = "window_frame_sandstone-0"
	base_icon_state = "window_frame_sandstone"

/obj/structure/platform/shuttle
	icon = 'icons/obj/smooth_structures/platform/window_frame_shuttle.dmi'
	frame_icon = 'icons/obj/smooth_structures/platform/frame_faces/window_frame_shuttle.dmi'
	icon_state = "window_frame_shuttle-0"
	base_icon_state = "window_frame_shuttle"
