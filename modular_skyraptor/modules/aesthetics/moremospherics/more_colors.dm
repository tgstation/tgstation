#define HELPER_PARTIAL(Fulltype, Iconbase, Color) \
	##Fulltype { \
		pipe_color = Color; \
		color = Color; \
	} \
	##Fulltype/visible { \
		hide = FALSE; \
		layer = GAS_PIPE_VISIBLE_LAYER; \
	} \
	##Fulltype/visible/layer2 { \
		piping_layer = 2; \
		icon_state = Iconbase + "-2"; \
	} \
	##Fulltype/visible/layer4 { \
		piping_layer = 4; \
		icon_state = Iconbase + "-4"; \
	} \
	##Fulltype/visible/layer1 { \
		piping_layer = 1; \
		icon_state = Iconbase + "-1"; \
	} \
	##Fulltype/visible/layer5 { \
		piping_layer = 5; \
		icon_state = Iconbase + "-5"; \
	} \
	##Fulltype/hidden { \
		hide = TRUE; \
	} \
	##Fulltype/hidden/layer2 { \
		piping_layer = 2; \
		icon_state = Iconbase + "-2"; \
	} \
	##Fulltype/hidden/layer4 { \
		piping_layer = 4; \
		icon_state = Iconbase + "-4"; \
	} \
	##Fulltype/hidden/layer1 { \
		piping_layer = 1; \
		icon_state = Iconbase + "-1"; \
	} \
	##Fulltype/hidden/layer5 { \
		piping_layer = 5; \
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

/// this is a risky bit of modularization, but we roll with it
/datum/controller/global_vars/Initialize()
	. = ..()
	GLOB.pipe_paint_colors["r_chartreuse"] = "#AAFF00"
	GLOB.pipe_color_name["#AAFF00"] = "r_chartreuse"
	GLOB.pipe_colors_ordered["#AAFF00"] = 6
	GLOB.pipe_paint_colors["r_bldorng"] = "#FF6600"
	GLOB.pipe_color_name["#FF6600"] = "r_bldorng"
	GLOB.pipe_colors_ordered["#FF6600"] = 7
	GLOB.pipe_paint_colors["r_deepviolet"] = "#6600FF"
	GLOB.pipe_color_name["#6600FF"] = "r_deepviolet"
	GLOB.pipe_colors_ordered["#6600FF"] = 8
	GLOB.pipe_paint_colors["r_navy"] = "#0066FF"
	GLOB.pipe_color_name["#0066FF"] = "r_navy"
	GLOB.pipe_colors_ordered["#0066FF"] = 9
	GLOB.pipe_paint_colors["r_emerald"] = "#00FF66"
	GLOB.pipe_color_name["#00FF66"] = "r_emerald"
	GLOB.pipe_colors_ordered["#00FF66"] = 10

HELPER(r_chartreuse, "#AAFF00")
HELPER(r_bldorng, "#FF6600")
HELPER(r_deepviolet, "#6600FF")
HELPER(r_navy, "#0066FF")
HELPER(r_emerald, "#00FF66")

#undef HELPER_NAMED
#undef HELPER
#undef HELPER_PARTIAL_NAMED
#undef HELPER_PARTIAL
