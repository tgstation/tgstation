//Colored pipes, use these for mapping

#define HELPER_PIPING_LAYER(Fulltype) \
	##Fulltype/layer1 { \
		piping_layer = 1; \
	} \
		##Fulltype/layer2 { \
		piping_layer = 2; \
	} \
		##Fulltype/layer4 { \
		piping_layer = 4; \
	} \
		##Fulltype/layer5 { \
		piping_layer = 5; \
	}

#define HELPER_PARTIAL(Fulltype, Iconbase, Color) \
	HELPER_PIPING_LAYER(Fulltype/visible) \
	HELPER_PIPING_LAYER(Fulltype/hidden) \
	##Fulltype { \
		pipe_color = Color; \
		color = Color; \
	} \
	##Fulltype/visible { \
		hide = FALSE; \
		layer = GAS_PIPE_VISIBLE_LAYER; \
	} \
	##Fulltype/visible/layer2 { \
		icon_state = Iconbase + "-2"; \
	} \
	##Fulltype/visible/layer4 { \
		icon_state = Iconbase + "-4"; \
	} \
	##Fulltype/visible/layer1 { \
		icon_state = Iconbase + "-1"; \
	} \
	##Fulltype/visible/layer5 { \
		icon_state = Iconbase + "-5"; \
	} \
	##Fulltype/hidden { \
		hide = TRUE; \
	} \
	##Fulltype/hidden/layer2 { \
		icon_state = Iconbase + "-2"; \
	} \
	##Fulltype/hidden/layer4 { \
		icon_state = Iconbase + "-4"; \
	} \
	##Fulltype/hidden/layer1 { \
		icon_state = Iconbase + "-1"; \
	} \
	##Fulltype/hidden/layer5 { \
		icon_state = Iconbase + "-5"; \
	}

#define HELPER_PARTIAL_NAMED(Fulltype, Iconbase, Name, Color) \
	HELPER_PARTIAL(Fulltype, Iconbase, Color) \
	##Fulltype { \
		name = Name; \
	}

#define HELPER(Type, Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/smart/simple/##Type, "pipe11", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/smart/manifold/##Type, "manifold", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/smart/manifold4w/##Type, "manifold4w", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/bridge_pipe/##Type, "bridge_map", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/layer_manifold/##Type, "manifoldlayer", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/components/binary/pump/off/##Type, "pump_map", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/components/binary/pump/on/##Type, "pump_on_map", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/multiz/##Type, "adapter", Color) \

#define HELPER_NAMED(Type, Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/smart/simple/##Type, "pipe11", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/smart/manifold/##Type, "manifold", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/smart/manifold4w/##Type, "manifold4w", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/bridge_pipe/##Type, "bridge_map", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/layer_manifold/##Type, "manifoldlayer", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/components/binary/pump/off/##Type, "pump_map", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/components/binary/pump/on/##Type, "pump_on_map", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/multiz/##Type, "adapter", Name, Color) \

HELPER(yellow, COLOR_YELLOW)
HELPER(general, COLOR_VERY_LIGHT_GRAY)
HELPER(cyan, COLOR_CYAN)
HELPER(green, COLOR_VIBRANT_LIME)
HELPER(orange, COLOR_ENGINEERING_ORANGE)
HELPER(purple, COLOR_PURPLE)
HELPER(dark, COLOR_DARK)
HELPER(brown, COLOR_BROWN)
HELPER(violet, COLOR_STRONG_VIOLET)
HELPER(pink, COLOR_LIGHT_PINK)

HELPER_NAMED(scrubbers, "scrubbers pipe", COLOR_RED)
HELPER_NAMED(supply, "air supply pipe", COLOR_BLUE)

#undef HELPER_NAMED
#undef HELPER
#undef HELPER_PARTIAL_NAMED
#undef HELPER_PARTIAL
#undef HELPER_PIPING_LAYER
