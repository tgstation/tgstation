#define POINT_TIME (2.5 SECONDS)

/**
 * Point at an atom
 *
 * Intended to enable and standardise the pointing animation for all atoms
 *
 * Not intended as a replacement for the mob verb
 */
/atom/movable/proc/point_at(atom/pointed_atom, intentional = FALSE)
	if(!isturf(loc))
		return FALSE

	if (pointed_atom in src)
		create_point_bubble(pointed_atom)
		return FALSE

	var/turf/tile = get_turf(pointed_atom)
	if (!tile)
		return FALSE

	var/turf/our_tile = get_turf(src)
	var/obj/visual = new /obj/effect/temp_visual/point(our_tile, invisibility)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POINTED, pointed_atom, visual, intentional)

	animate(visual, pixel_x = (tile.x - our_tile.x) * ICON_SIZE_X + pointed_atom.pixel_x, pixel_y = (tile.y - our_tile.y) * ICON_SIZE_Y + pointed_atom.pixel_y, time = 1.7, easing = EASE_OUT)
	return TRUE

/mob/point_at(atom/pointed_atom, intentional = FALSE)
	. = ..()
	if(.)
		face_atom(pointed_atom)

/atom/movable/proc/create_point_bubble(atom/pointed_atom)
	var/mutable_appearance/thought_bubble = mutable_appearance(
		'icons/effects/effects.dmi',
		"thought_bubble",
		offset_spokesman = src,
		plane = POINT_PLANE,
		appearance_flags = KEEP_APART,
	)

	var/mutable_appearance/pointed_atom_appearance = new(pointed_atom.appearance)
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.plane = FLOAT_PLANE
	pointed_atom_appearance.layer = FLOAT_LAYER
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0
	thought_bubble.overlays += pointed_atom_appearance

	var/hover_outline_index = pointed_atom.get_filter_index(HOVER_OUTLINE_FILTER)
	if (!isnull(hover_outline_index))
		pointed_atom_appearance.filters.Cut(hover_outline_index, hover_outline_index + 1)

	thought_bubble.pixel_x = 16
	thought_bubble.pixel_y = 32
	thought_bubble.alpha = 200

	var/mutable_appearance/point_visual = mutable_appearance(
		'icons/hud/screen_gen.dmi',
		"arrow"
	)

	thought_bubble.overlays += point_visual

	add_overlay(thought_bubble)
	LAZYADD(update_overlays_on_z, thought_bubble)
	addtimer(CALLBACK(src, PROC_REF(clear_point_bubble), thought_bubble), POINT_TIME)

/atom/movable/proc/clear_point_bubble(mutable_appearance/thought_bubble)
	LAZYREMOVE(update_overlays_on_z, thought_bubble)
	cut_overlay(thought_bubble)

/obj/effect/temp_visual/point
	name = "pointer"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "arrow"
	plane = POINT_PLANE
	duration = POINT_TIME

/obj/effect/temp_visual/point/Initialize(mapload, set_invis = 0)
	. = ..()
	var/atom/old_loc = loc
	abstract_move(get_turf(src))
	pixel_x = old_loc.pixel_x
	pixel_y = old_loc.pixel_y
	SetInvisibility(set_invis)

#undef POINT_TIME

/**
 * Point at an atom
 *
 * mob verbs are faster than object verbs. See
 * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
 * for why this isn't atom/verb/pointed()
 *
 * note: ghosts can point, this is intended
 *
 * visible_message will handle invisibility properly
 *
 * overridden here and in /mob/dead/observer for different point span classes and sanity checks
 */
/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(istype(A, /obj/effect/temp_visual/point))
		return FALSE

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(_pointed), A))

/// possibly delayed verb that finishes the pointing process starting in [/mob/verb/pointed()].
/// either called immediately or in the tick after pointed() was called, as per the [DEFAULT_QUEUE_OR_CALL_VERB()] macro
/mob/proc/_pointed(atom/pointing_at)
	if(client && !(pointing_at in view(client.view, src)))
		return FALSE

	point_at(pointing_at, TRUE)

	return TRUE
