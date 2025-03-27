GLOBAL_LIST_INIT(atmos_pipe_recipes, list(
	"Pipes" = list(
		new /datum/pipe_info/pipe("Pipe", /obj/machinery/atmospherics/pipe/smart, TRUE),
		new /datum/pipe_info/pipe("Layer Adapter", /obj/machinery/atmospherics/pipe/layer_manifold, TRUE),
		new /datum/pipe_info/pipe("Color Adapter", /obj/machinery/atmospherics/pipe/color_adapter, TRUE),
		new /datum/pipe_info/pipe("Bridge Pipe", /obj/machinery/atmospherics/pipe/bridge_pipe, TRUE),
		new /datum/pipe_info/pipe("Multi-Deck Adapter", /obj/machinery/atmospherics/pipe/multiz, FALSE),
	),
	"Binary" = list(
		new /datum/pipe_info/pipe("Manual Valve", /obj/machinery/atmospherics/components/binary/valve, TRUE),
		new /datum/pipe_info/pipe("Digital Valve", /obj/machinery/atmospherics/components/binary/valve/digital, TRUE),
		new /datum/pipe_info/pipe("Gas Pump", /obj/machinery/atmospherics/components/binary/pump, TRUE),
		new /datum/pipe_info/pipe("Volume Pump", /obj/machinery/atmospherics/components/binary/volume_pump, TRUE),
		new /datum/pipe_info/pipe("Passive Gate", /obj/machinery/atmospherics/components/binary/passive_gate, TRUE),
		new /datum/pipe_info/pipe("Pressure Valve", /obj/machinery/atmospherics/components/binary/pressure_valve, TRUE),
		new /datum/pipe_info/pipe("Temperature Gate", /obj/machinery/atmospherics/components/binary/temperature_gate, TRUE),
		new /datum/pipe_info/pipe("Temperature Pump", /obj/machinery/atmospherics/components/binary/temperature_pump, TRUE),
	),
	"Devices" = list(
		new /datum/pipe_info/pipe("Gas Filter", /obj/machinery/atmospherics/components/trinary/filter, TRUE),
		new /datum/pipe_info/pipe("Gas Mixer", /obj/machinery/atmospherics/components/trinary/mixer, TRUE),
		new /datum/pipe_info/pipe("Connector", /obj/machinery/atmospherics/components/unary/portables_connector, TRUE),
		new /datum/pipe_info/pipe("Injector", /obj/machinery/atmospherics/components/unary/outlet_injector, TRUE),
		new /datum/pipe_info/pipe("Scrubber", /obj/machinery/atmospherics/components/unary/vent_scrubber, TRUE),
		new /datum/pipe_info/pipe("Unary Vent", /obj/machinery/atmospherics/components/unary/vent_pump, TRUE),
		new /datum/pipe_info/pipe("Passive Vent", /obj/machinery/atmospherics/components/unary/passive_vent, TRUE),
		new /datum/pipe_info/meter("Meter"),
	),
	"Heat Exchange" = list(
		new /datum/pipe_info/pipe("Pipe", /obj/machinery/atmospherics/pipe/heat_exchanging/simple, FALSE),
		new /datum/pipe_info/pipe("Manifold", /obj/machinery/atmospherics/pipe/heat_exchanging/manifold, FALSE),
		new /datum/pipe_info/pipe("4-Way Manifold", /obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w, FALSE),
		new /datum/pipe_info/pipe("Junction", /obj/machinery/atmospherics/pipe/heat_exchanging/junction, FALSE),
		new /datum/pipe_info/pipe("Heat Exchanger", /obj/machinery/atmospherics/components/unary/heat_exchanger, FALSE),
	)
))

GLOBAL_LIST_INIT(disposal_pipe_recipes, list(
	"Disposal Pipes" = list(
		new /datum/pipe_info/disposal("Pipe", /obj/structure/disposalpipe/segment, PIPE_BENDABLE),
		new /datum/pipe_info/disposal("Junction", /obj/structure/disposalpipe/junction, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Y-Junction", /obj/structure/disposalpipe/junction/yjunction),
		new /datum/pipe_info/disposal("Sort Junction", /obj/structure/disposalpipe/sorting/mail, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Rotator", /obj/structure/disposalpipe/rotator, PIPE_ONEDIR_FLIPPABLE),
		new /datum/pipe_info/disposal("Trunk", /obj/structure/disposalpipe/trunk),
		new /datum/pipe_info/disposal("Down Turn", /obj/structure/disposalpipe/trunk/multiz/down),
		new /datum/pipe_info/disposal("Up Turn", /obj/structure/disposalpipe/trunk/multiz),
		new /datum/pipe_info/disposal("Bin", /obj/machinery/disposal/bin, PIPE_ONEDIR),
		new /datum/pipe_info/disposal("Outlet", /obj/structure/disposaloutlet),
		new /datum/pipe_info/disposal("Chute", /obj/machinery/disposal/delivery_chute),
	)
))

GLOBAL_LIST_INIT(transit_tube_recipes, list(
	"Transit Tubes" = list(
		new /datum/pipe_info/transit("Straight Tube", /obj/structure/c_transit_tube, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Straight Tube with Crossing", /obj/structure/c_transit_tube/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Curved Tube", /obj/structure/c_transit_tube/curved, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Diagonal Tube", /obj/structure/c_transit_tube/diagonal, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Diagonal Tube with Crossing", /obj/structure/c_transit_tube/diagonal/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Junction", /obj/structure/c_transit_tube/junction, PIPE_UNARY_FLIPPABLE),
	),
	"Station Equipment" = list(
		new /datum/pipe_info/transit("Through Tube Station", /obj/structure/c_transit_tube/station, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Station", /obj/structure/c_transit_tube/station/reverse, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Through Tube Dispenser Station", /obj/structure/c_transit_tube/station/dispenser, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Dispenser Station", /obj/structure/c_transit_tube/station/dispenser/reverse, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Transit Tube Pod", /obj/structure/c_transit_tube_pod, PIPE_ONEDIR),
	)
))
