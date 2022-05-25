// Some various defines used in the heretic sacrifice map.

/// A global assoc list of all landmarks that denote a heretic sacrifice location. [string heretic path] = [landmark].
GLOBAL_LIST_EMPTY(heretic_sacrifice_landmarks)

/**
 * A map template loaded in when heretics are created.
 * Hereteic sacrifices are sent here when completed.
 */
/datum/map_template/heretic_sacrifice_level
	name = "Heretic Sacrifice Level"
	mappath = "_maps/templates/heretic_sacrifice_template.dmm"

/// Lardmarks meant to designate where heretic sacrifices are sent.
/obj/effect/landmark/heretic
	name = "default heretic sacrifice landmark"
	icon_state = "x"
	/// What path this landmark is intended for.
	var/for_heretic_path = PATH_START

/obj/effect/landmark/heretic/Initialize()
	. = ..()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = src

/obj/effect/landmark/heretic/Destroy()
	GLOB.heretic_sacrifice_landmarks[for_heretic_path] = null
	return ..()

/obj/effect/landmark/heretic/ash
	name = "ash heretic sacrifice landmark"
	for_heretic_path = PATH_ASH

/obj/effect/landmark/heretic/flesh
	name = "flesh heretic sacrifice landmark"
	for_heretic_path = PATH_FLESH

/obj/effect/landmark/heretic/void
	name = "void heretic sacrifice landmark"
	for_heretic_path = PATH_VOID

/obj/effect/landmark/heretic/rust
	name = "rust heretic sacrifice landmark"
	for_heretic_path = PATH_RUST

// A fluff signpost object that doesn't teleport you somewhere when you touch it.
/obj/structure/no_effect_signpost
	name = "signpost"
	desc = "Won't somebody give me a sign?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE

/obj/structure/no_effect_signpost/void
	name = "signpost at the edge of the universe"
	desc = "A direction in the directionless void."
	density = FALSE
	/// Brightness of the signpost.
	var/range = 2
	/// Light power of the signpost.
	var/power = 0.8

/obj/structure/no_effect_signpost/void/Initialize()
	. = ..()
	set_light(range, power)

// Some VERY dim lights, used for the void sacrifice realm.
/obj/machinery/light/very_dim
	nightshift_allowed = FALSE
	bulb_colour = "#d6b6a6ff"
	brightness = 3
	bulb_power = 0.5

/obj/machinery/light/very_dim/directional/north
	dir = NORTH

/obj/machinery/light/very_dim/directional/south
	dir = SOUTH

/obj/machinery/light/very_dim/directional/east
	dir = EAST

/obj/machinery/light/very_dim/directional/west
	dir = WEST

// Rooms for where heretic sacrifices send people.
/area/heretic_sacrifice
	name = "Mansus"
	icon = 'icons/area/areas_centcom.dmi'
	icon_state = "heretic"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = UNIQUE_AREA | NOTELEPORT | HIDDEN_AREA | BLOCK_SUICIDE

/area/heretic_sacrifice/Initialize(mapload)
	if(!ambientsounds)
		ambientsounds = GLOB.ambience_assoc[ambience_index]
		ambientsounds += 'sound/ambience/ambiatm1.ogg'
	return ..()

/area/heretic_sacrifice/ash //also, the default
	name = "Mansus Ash Gate"

/area/heretic_sacrifice/void
	name = "Mansus Void Gate"
	sound_environment = SOUND_ENVIRONMENT_UNDERWATER

/area/heretic_sacrifice/flesh
	name = "Mansus Flesh Gate"
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/heretic_sacrifice/rust
	name = "Mansus Rust Gate"
	ambience_index = AMBIENCE_REEBE
	sound_environment = SOUND_ENVIRONMENT_SEWER_PIPE
