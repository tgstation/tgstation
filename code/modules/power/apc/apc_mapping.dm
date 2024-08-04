///Used to change name for apcs on away missions
/obj/machinery/power/apc/worn_out
	name = "Worn out APC"

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

#define APC_DIRECTIONAL_HELPERS(path) _WALL_MOUNT_DIRECTIONAL_HELPERS(path, -APC_PIXEL_OFFSET, APC_PIXEL_OFFSET, -APC_PIXEL_OFFSET, APC_PIXEL_OFFSET, 16)

APC_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/worn_out)
APC_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name)

#undef APC_DIRECTIONAL_HELPERS
