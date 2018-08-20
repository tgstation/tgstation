// Atmos helpers

/// Mapping helper which pre-attaches an atmos portable to a port.
/obj/effect/mapping_helpers/attach_portable_atmos
    name = "portable atmos pre-attach helper"
    late = TRUE

/obj/effect/mapping_helpers/attach_portable_atmos/LateInitialize()
    var/obj/machinery/portable_atmospherics/portable = locate() in loc
    var/obj/machinery/atmospherics/components/unary/portables_connector/port = locate() in loc
    if (portable && port)
        addtimer(CALLBACK(portable, /obj/machinery/portable_atmospherics.proc/connect, port), 1)
    qdel(src)

/// Allow meters to specify pixel offsets in the map.
/obj/machinery/meter/Initialize(mapload, new_piping_layer)
    var/old_pixel_x = pixel_x
    var/old_pixel_y = pixel_y
    . = ..()
    if (mapload && (old_pixel_x || old_pixel_y))
        pixel_x = old_pixel_x
        pixel_y = old_pixel_y
