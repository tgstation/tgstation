///Used to change name for apcs on away missions
/obj/machinery/power/apc/worn_out
	name = "Worn out APC"

/obj/machinery/power/apc/auto_name
	auto_name = TRUE

#define APC_DIRECTIONAL_HELPERS(path)\
##path/directional/north {\
	dir = SOUTH; \
	MAP_SWITCH(pixel_z, pixel_y) = -APC_PIXEL_OFFSET; \
} \
##path/directional/south {\
	dir = NORTH; \
	MAP_SWITCH(pixel_z, pixel_y) = APC_PIXEL_OFFSET; \
} \
##path/directional/east {\
	dir = WEST; \
	pixel_x = -APC_PIXEL_OFFSET; \
	MAP_SWITCH(pixel_z, pixel_y) = 16; \
} \
##path/directional/west {\
	dir = EAST; \
	pixel_x = APC_PIXEL_OFFSET; \
	MAP_SWITCH(pixel_z, pixel_y) = 16; \
}


APC_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/worn_out)
APC_DIRECTIONAL_HELPERS(/obj/machinery/power/apc/auto_name)

#undef APC_DIRECTIONAL_HELPERS
