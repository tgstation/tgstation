
#define DEF_PIPELAYER_SUPPLY 2
#define DEF_PIXELX_SUPPLY (DEF_PIPELAYER_SUPPLY - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define DEF_PIXELY_SUPPLY (DEF_PIPELAYER_SUPPLY - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

#define DEF_PIPELAYER_SCRUBBERS 4
#define DEF_PIXELX_SCRUBBERS (DEF_PIPELAYER_SCRUBBERS - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_X
#define DEF_PIXELY_SCRUBBERS (DEF_PIPELAYER_SCRUBBERS - PIPING_LAYER_DEFAULT) * PIPING_LAYER_P_Y

/obj/machinery/atmospherics/pipe/simple/scrubbers/visible/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/unary/vent_scrubber/layered
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	pixel_x=DEF_PIXELX_SCRUBBERS
	pixel_y=DEF_PIXELY_SCRUBBERS
/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers
	piping_layer=DEF_PIPELAYER_SCRUBBERS
	icon_state="adapter_4"
	name = "scrubbers pipe"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers/visible
	level = 2
/obj/machinery/atmospherics/pipe/layer_adapter/scrubbers/hidden
	level = 1
	alpha=128

/obj/machinery/atmospherics/pipe/simple/supply/visible/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/simple/supply/hidden/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold/supply/visible/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold/supply/hidden/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold4w/supply/visible/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden/layered
	piping_layer=DEF_PIPELAYER_SUPPLY
	pixel_x=DEF_PIXELX_SUPPLY
	pixel_y=DEF_PIXELY_SUPPLY
/obj/machinery/atmospherics/pipe/layer_adapter/supply
	piping_layer=DEF_PIPELAYER_SUPPLY
	icon_state="adapter_2"
	name = "\improper Air supply pipe"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/pipe/layer_adapter/supply/visible
	level = 2
/obj/machinery/atmospherics/pipe/layer_adapter/supply/hidden
	level = 1
	alpha=128