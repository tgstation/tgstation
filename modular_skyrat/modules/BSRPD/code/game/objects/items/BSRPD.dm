/*
CONTAINS:
BSRPD
*/

#define ATMOS_CATEGORY 0
#define DISPOSALS_CATEGORY 1
#define TRANSIT_CATEGORY 2

#define BUILD_MODE (1<<0)
#define WRENCH_MODE (1<<1)
#define DESTROY_MODE (1<<2)
#define PAINT_MODE (1<<3)

GLOBAL_LIST_INIT(bsatmos_pipe_recipes, list(
	"Pipes" = list(
		new /datum/pipe_info/pipe("Pipe",				/obj/machinery/atmospherics/pipe/simple, TRUE),
		new /datum/pipe_info/pipe("Manifold",			/obj/machinery/atmospherics/pipe/manifold, TRUE),
		new /datum/pipe_info/pipe("4-Way Manifold",		/obj/machinery/atmospherics/pipe/manifold4w, TRUE),
		new /datum/pipe_info/pipe("Layer Adapter",		/obj/machinery/atmospherics/pipe/layer_manifold, TRUE),
		new /datum/pipe_info/pipe("Multi-Deck Adapter",	/obj/machinery/atmospherics/pipe/multiz, TRUE),
	),
	"Devices" = list(
		new /datum/pipe_info/pipe("Connector",			/obj/machinery/atmospherics/components/unary/portables_connector, TRUE),
		new /datum/pipe_info/pipe("Gas Pump",			/obj/machinery/atmospherics/components/binary/pump, TRUE),
		new /datum/pipe_info/pipe("Volume Pump",		/obj/machinery/atmospherics/components/binary/volume_pump, TRUE),
		new /datum/pipe_info/pipe("Gas Filter",			/obj/machinery/atmospherics/components/trinary/filter, TRUE),
		new /datum/pipe_info/pipe("Gas Mixer",			/obj/machinery/atmospherics/components/trinary/mixer, TRUE),
		new /datum/pipe_info/pipe("Passive Gate",		/obj/machinery/atmospherics/components/binary/passive_gate, TRUE),
		new /datum/pipe_info/pipe("Injector",			/obj/machinery/atmospherics/components/unary/outlet_injector, TRUE),
		new /datum/pipe_info/pipe("Scrubber",			/obj/machinery/atmospherics/components/unary/vent_scrubber, TRUE),
		new /datum/pipe_info/pipe("Unary Vent",			/obj/machinery/atmospherics/components/unary/vent_pump, TRUE),
		new /datum/pipe_info/pipe("Passive Vent",		/obj/machinery/atmospherics/components/unary/passive_vent, TRUE),
		new /datum/pipe_info/pipe("Manual Valve",		/obj/machinery/atmospherics/components/binary/valve, TRUE),
		new /datum/pipe_info/pipe("Digital Valve",		/obj/machinery/atmospherics/components/binary/valve/digital, TRUE),
		new /datum/pipe_info/pipe("Pressure Valve",		/obj/machinery/atmospherics/components/binary/pressure_valve, TRUE),
		new /datum/pipe_info/pipe("Temperature Gate",	/obj/machinery/atmospherics/components/binary/temperature_gate, TRUE),
		new /datum/pipe_info/pipe("Temperature Pump",	/obj/machinery/atmospherics/components/binary/temperature_pump, TRUE),
		new /datum/pipe_info/meter("Meter"),
	),
	"Heat Exchange" = list(
		new /datum/pipe_info/pipe("Pipe",				/obj/machinery/atmospherics/pipe/heat_exchanging/simple, FALSE),
		new /datum/pipe_info/pipe("Manifold",			/obj/machinery/atmospherics/pipe/heat_exchanging/manifold, FALSE),
		new /datum/pipe_info/pipe("4-Way Manifold",		/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w, FALSE),
		new /datum/pipe_info/pipe("Junction",			/obj/machinery/atmospherics/pipe/heat_exchanging/junction, FALSE),
		new /datum/pipe_info/pipe("Heat Exchanger",		/obj/machinery/atmospherics/components/unary/heat_exchanger, FALSE),
	)
))

// SKYRAT CHANGE: Made BSRPD into a subtype of RPD, additionally made it work at range.
/obj/item/pipe_dispenser/bluespace
	name = "Bluespace Rapid Piping Device (BSRPD)"
	desc = "A device used to rapidly pipe things at a distance."
	icon = 'modular_skyrat/modules/BSRPD/icons/obj/tools.dmi'
	icon_state = "bsrpd"
	lefthand_file = 'modular_skyrat/modules/BSRPD/icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/BSRPD/icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=75000, /datum/material/glass=37500, /datum/material/bluespace=1000)
	has_bluespace_pipe = TRUE

/obj/item/pipe_dispenser/bluespace/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		return // this will be handled in pre_attack in RPD.dm
	user.Beam(target, icon_state = "rped_upgrade", time = 5)
	playsound(src, 'sound/items/pshoom.ogg', 30, TRUE)
	dispense(target, user)

// End skyrat edit
#undef ATMOS_CATEGORY
#undef DISPOSALS_CATEGORY
#undef TRANSIT_CATEGORY

#undef BUILD_MODE
#undef DESTROY_MODE
#undef PAINT_MODE
#undef WRENCH_MODE
