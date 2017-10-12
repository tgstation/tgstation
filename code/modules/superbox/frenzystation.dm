// Code for the very-low-pop FrenzyStation map

/obj/effect/mapping_helpers
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	layer = POINT_LAYER

// Helper which marks the entire station as parallax in the given dir
/obj/effect/mapping_helpers/station_parallax
    name = "station parallax"
    dir = 1

/obj/effect/mapping_helpers/station_parallax/Initialize()
    ..()
    return INITIALIZE_HINT_LATELOAD

/obj/effect/mapping_helpers/station_parallax/LateInitialize()
    var/turf/loc = get_turf(src)
    var/z = loc.z

    for (var/area/A in GLOB.sortedAreas)
        if (A.type == /area/space) // but nearstation is fine
            continue

        var/on_station = FALSE
        var/not_on_station = FALSE
        for (var/turf/T in A)
            if (T.z == z)
                on_station = TRUE
            else
                not_on_station = TRUE

        if (on_station == not_on_station)
            message_admins("[A] ([A.type]), on_station=[on_station], not_on_station=[not_on_station]")
        if (on_station)
            A.parallax_movedir = dir

    qdel(src)

// Cryo cell which also acts as arrivals
/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin
    var/occupant_is_latejoiner = FALSE

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/Initialize()
    . = ..()
    SSjob.latejoin_trackers += src

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/Destroy()
    ..()
    SSjob.latejoin_trackers -= src

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/open_machine()
    occupant_is_latejoiner = FALSE
    return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/process()
    if (occupant_is_latejoiner)
        return 1  // they'll be ejected by the timer, appear on until then
    else
        return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/proc/emplace(mob/living/target)
    if (occupant && !awaken(occupant) && !istype(target))
        return FALSE

    occupant_is_latejoiner = TRUE
    state_open = TRUE
    panel_open = FALSE
    on = TRUE
    close_machine(target)
    addtimer(CALLBACK(src, .proc/awaken, target), 10 SECONDS)
    return TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/proc/awaken(mob/living/target)
    if (occupant != target || !occupant_is_latejoiner)
        return FALSE

    var/turf/T = get_turf(src)
    playsound(T, 'sound/machines/cryo_warning.ogg', volume)
    open_machine()
    target.Knockdown(10)
    return TRUE

/datum/controller/subsystem/job/SendToAtom(mob/M, atom/A, buckle)
    var/obj/machinery/atmospherics/components/unary/cryo_cell/latejoin/C = A
    if (!istype(C) || !C.emplace(M))
        ..()
