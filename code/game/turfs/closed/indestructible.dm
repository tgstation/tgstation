/turf/closed/indestructible
	name = "wall"
	desc = "Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls/metal_wall.dmi'
	icon_state = "0-2"
	explosive_resistance = 50
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS
	rust_resistance = RUST_RESISTANCE_ABSOLUTE

/turf/closed/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/closed/indestructible/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/closed/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/closed/indestructible/singularity_act()
	return

/turf/closed/indestructible/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/poster) && Adjacent(user))
		return place_poster(attacking_item, user)

	return ..()

/turf/closed/indestructible/oldshuttle
	name = "strange shuttle wall"
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "block"
	use_splitvis = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

/turf/closed/indestructible/weeb
	name = "paper wall"
	desc = "Reinforced paper walling. Someone really doesn't want you to leave."
	icon = 'icons/turf/walls/paperframe_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_PAPERFRAME + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_PAPERFRAME + SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	baseturfs = /turf/closed/indestructible/sandstone
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/oldshuttle/corner
	icon_state = "corner"

/turf/closed/indestructible/splashscreen
	name = "Space Station 13"
	desc = null
	icon = 'icons/blanks/blank_title.png'
	icon_state = ""
	pixel_x = -64
	plane = SPLASHSCREEN_PLANE
	use_splitvis = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	bullet_bounce_sound = null

INITIALIZE_IMMEDIATE(/turf/closed/indestructible/splashscreen)

/turf/closed/indestructible/splashscreen/Initialize(mapload)
	. = ..()
	SStitle.splash_turf = src
	if(SStitle.icon)
		icon = SStitle.icon
		handle_generic_titlescreen_sizes()

///helper proc that will center the screen if the icon is changed to a generic width, to make admins have to fudge around with pixel_x less. returns null
/turf/closed/indestructible/splashscreen/proc/handle_generic_titlescreen_sizes()
	var/icon/size_check = icon(SStitle.icon, icon_state)
	var/width = size_check.Width()
	if(width == 480) // 480x480 is nonwidescreen
		pixel_x = 0
	else if(width == 608) // 608x480 is widescreen
		pixel_x = -64

/turf/closed/indestructible/splashscreen/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				SStitle.icon = icon
				handle_generic_titlescreen_sizes()

/turf/closed/indestructible/splashscreen/examine()
	desc = pick(strings(SPLASH_FILE, "splashes"))
	return ..()

/turf/closed/indestructible/start_area
	name = null
	desc = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	use_splitvis = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

/turf/closed/indestructible/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms. Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls/riveted_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS

/turf/closed/indestructible/reinforced/titanium
	name = "reinforced titanium imitation wall"
	desc = "A huge chunk of reinforced metal used to separate rooms. Naturally, to cut down on costs, this is just a really good paint job to resemble titanium. Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	base_icon_state = "shuttle_wall"

/turf/closed/indestructible/reinforced/titanium/nodiagonal
	icon_state = "12-2"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/indestructible/riveted
	icon = 'icons/turf/walls/riveted_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/syndicate
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_SYNDICATE_WALLS
	canSmoothWith = SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_SYNDICATE_WALLS

/turf/closed/indestructible/riveted/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'

/turf/closed/indestructible/riveted/plastinum
	name = "plastinum wall"
	desc = "A luxurious wall made out of a plasma-platinum alloy. Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls/plastinum_wall.dmi'
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = SMOOTH_GROUP_PLASTINUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_PLASTINUM_WALLS

// Wallening todo: remove
/turf/closed/indestructible/riveted/plastinum/nodiagonal

/turf/closed/indestructible/wood
	icon = 'icons/turf/walls/wood_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS


/turf/closed/indestructible/alien
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS

/turf/closed/indestructible/alien/nodiagonal
	icon_state = "12-2"
	smoothing_flags = SMOOTH_BITMASK

/turf/closed/indestructible/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound. Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls/cult_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS


/turf/closed/indestructible/abductor
	name = "alien wall"
	icon = 'icons/turf/walls/abductor_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS

/turf/closed/indestructible/opshuttle
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/fakeglass
	name = "window"
	icon = MAP_SWITCH('icons/obj/smooth_structures/windows/reinforced_window.dmi', 'icons/obj/smooth_structures/structure_variations.dmi')
	icon_state = MAP_SWITCH("0-lower", "plastitanium_window-0")
	layer = ABOVE_OBJ_LAYER
	opacity = FALSE
	use_splitvis = FALSE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE

/turf/closed/indestructible/fakeglass/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/window_smoothing, /turf/closed/indestructible/fakeglass)
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating", LOW_FLOOR_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)

/turf/closed/indestructible/fakeglass/smooth_icon()
	. = ..()
	update_appearance(~UPDATE_SMOOTHING)

/turf/closed/indestructible/fakeglass/update_overlays()
	. = ..()
	. += mutable_appearance('icons/obj/smooth_structures/window_grille_black.dmi', "window_grille_black-[smoothing_junction]", BELOW_OBJ_LAYER)
	. += mutable_appearance('icons/obj/smooth_structures/window_grille.dmi', "window_grille-[smoothing_junction]", BELOW_OBJ_LAYER)
	. += mutable_appearance('icons/obj/smooth_structures/window_frames/frame_faces/window_frame_normal.dmi', "window_frame_normal-[smoothing_junction]", BELOW_OBJ_LAYER, appearance_flags = KEEP_APART)

/turf/closed/indestructible/opsglass
	name = "window"
	icon = MAP_SWITCH('icons/obj/smooth_structures/windows/plastitanium_window.dmi', 'icons/obj/smooth_structures/plastitanium_window.dmi')
	icon_state = MAP_SWITCH("0-lower", "plastitanium_window-0")
	layer = ABOVE_OBJ_LAYER
	opacity = FALSE
	use_splitvis = FALSE
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM

/turf/closed/indestructible/opsglass/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/window_smoothing, /turf/closed/indestructible/opsglass)
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating", LOW_FLOOR_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)

/turf/closed/indestructible/opsglass/smooth_icon()
	. = ..()
	update_appearance(~UPDATE_SMOOTHING)

/turf/closed/indestructible/opsglass/update_overlays()
	. = ..()
	. += mutable_appearance('icons/obj/smooth_structures/window_grille_black.dmi', "window_grille_black-[smoothing_junction]", BELOW_OBJ_LAYER)
	. += mutable_appearance('icons/obj/smooth_structures/window_grille.dmi', "window_grille-[smoothing_junction]", BELOW_OBJ_LAYER)
	. += mutable_appearance('icons/obj/smooth_structures/window_frames/frame_faces/window_frame_plastitanium.dmi', "window_frame_plastitanium-[smoothing_junction]", BELOW_OBJ_LAYER, appearance_flags = KEEP_APART)

/turf/closed/indestructible/fakedoor
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/tall/centcom.dmi'
	icon_state = "fake_door"
	use_splitvis = FALSE
	smoothing_flags = NONE
	canSmoothWith = null
	smoothing_groups = null
	/// What kind of turf should be visually represented under this door?
	var/turf/floor_to_copy = /turf/open/floor/plating

/turf/closed/indestructible/fakedoor/Initialize(mapload)
	. = ..()
	underlays += mutable_appearance(initial(floor_to_copy.icon), initial(floor_to_copy.icon_state), initial(floor_to_copy.layer), offset_spokesman = src, plane = FLOOR_PLANE)

/turf/closed/indestructible/fakedoor/maintenance
	icon = 'icons/obj/doors/airlocks/tall/hatch/maintenance.dmi'
	icon_state = "closed" // Should probably be given it's own fake_door state too

/turf/closed/indestructible/fakedoor/glass_airlock
	icon = 'icons/obj/doors/airlocks/tall/external/external.dmi'
	icon_state = "closed" // Ditto
	opacity = FALSE

/// WALLENING TODO: Needs additional work; the base airlock it's meant to mimic is a GAGS-Generated sprite.
/turf/closed/indestructible/fakedoor/engineering
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	icon_state = "closed"

/turf/closed/indestructible/rock
	name = "dense rock"
	desc = "An extremely densely-packed rock, most mining tools or explosives would never get through this."
	icon = 'icons/turf/walls/rock_wall2.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/rock/snow
	name = "mountainside"
	desc = "An extremely densely-packed rock, sheeted over with centuries worth of ice and snow."
	icon = MAP_SWITCH('icons/turf/walls/mountain_wall.dmi', 'icons/turf/mining.dmi')
#ifdef MAP_EDITOR
	icon_state = "mountainrock"
#endif
	bullet_sizzle = TRUE
	bullet_bounce_sound = null

/turf/closed/indestructible/rock/snow/ice
	icon = 'icons/turf/walls/icerock_wall.dmi'
	name = "iced rock"
	icon_state = null
	desc = "Extremely densely-packed sheets of ice and rock, forged over the years of the harsh cold."
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

// Is it ok that this looks the same as its parent? why does it exist?
// Something is wrong here huh
// rock/snow used to have a unique state, do we need to put it back?
// also we need a sprite for /rock, I think? need to dig more
// wallening todo, replace with /turf/closed/indestructible/rock/snow/ice, it is essentially redundant since we didn't make a unique state for that one state in mining.dmi
/turf/closed/indestructible/rock/snow/ice/ore
/turf/closed/indestructible/paper
	name = "thick paper wall"
	desc = "A wall layered with impenetrable sheets of paper."
	icon = 'icons/turf/walls/paper_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/necropolis
	name = "necropolis wall"
	desc = "A seemingly impenetrable wall."
	icon = 'icons/turf/walls/necro_wall.dmi'
	explosive_resistance = 50
	baseturfs = /turf/closed/indestructible/necropolis
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_CLOSED_TURFS

/turf/closed/indestructible/necropolis/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "necro1"
	return TRUE

/turf/closed/indestructible/iron
	name = "impervious iron wall"
	desc = "A wall with tough iron plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS
	opacity = FALSE

/turf/closed/indestructible/riveted/boss
	name = "necropolis wall"
	desc = "A thick, seemingly indestructible stone wall."
	icon = 'icons/turf/walls/boss_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_BOSS_WALLS
	canSmoothWith = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_BOSS_WALLS
	explosive_resistance = 50
	baseturfs = /turf/closed/indestructible/riveted/boss

/// To avoid confusion; this is used as a bombable tile. It's justified; I checked.
/turf/closed/indestructible/riveted/boss/wasteland
	baseturfs = /turf/open/misc/asteroid/basalt/wasteland

/turf/closed/indestructible/riveted/boss/see_through
	opacity = FALSE

/turf/closed/indestructible/riveted/boss/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/closed/indestructible/riveted/hierophant
	name = "wall"
	desc = "A wall made out of a strange metal. The squares on it pulse in a predictable pattern."
	icon = 'icons/turf/walls/hierophant_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_HIERO_WALL + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_HIERO_WALL

/turf/closed/indestructible/resin
	name = "resin wall"
	icon = 'icons/obj/smooth_structures/alien/resin_wall_1.dmi'
	smoothing_groups = SMOOTH_GROUP_ALIEN_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_ALIEN_WALLS

/turf/closed/indestructible/resin/membrane
	name = "resin membrane"
	icon = 'icons/obj/smooth_structures/alien/resin_membrane.dmi'
	icon_state = "resin_membrane-0"
	base_icon_state = "resin_membrane"
	opacity = FALSE
	use_splitvis = FALSE
	smoothing_groups = SMOOTH_GROUP_ALIEN_WALLS
	canSmoothWith = SMOOTH_GROUP_ALIEN_WALLS

/turf/closed/indestructible/resin/membrane/Initialize(mapload)
	. = ..()
	underlays += mutable_appearance('icons/turf/floors.dmi', "engine") // add the reinforced floor underneath

/turf/closed/indestructible/grille
	name = "grille"
	desc = "A flimsy framework of iron rods."
	icon = 'icons/obj/smooth_structures/grille.dmi'
	icon_state = "grille-0"
	base_icon_state = "grille"
	use_splitvis = FALSE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_GRILLE
	canSmoothWith = SMOOTH_GROUP_GRILLE

/turf/closed/indestructible/grille/Initialize(mapload)
	. = ..()
	underlays += mutable_appearance('icons/turf/floors.dmi', "plating")

/turf/closed/indestructible/meat
	name = "dense meat wall"
	desc = "A huge chunk of dense, packed meat. Effectively impervious to conventional methods of destruction."
	icon = 'icons/turf/walls/meat_wall.dmi'
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_WALLS
