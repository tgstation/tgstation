///Used to change name for apcs on away missions
/obj/machinery/power/apc/worn_out
	name = "Worn out APC"

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

#define APC_DIRECTIONAL_HELPERS(path) _WALL_MOUNT_DIRECTIONAL_HELPERS(path, 35, 0, -8, 11, -11, 16)

APC_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/worn_out)
APC_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name)

#undef APC_DIRECTIONAL_HELPERS
