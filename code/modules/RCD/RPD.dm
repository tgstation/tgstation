/obj/item/device/rcd/rpd
	name				= "Rapid Piping Device (RPD)"
	desc				= "A device used to rapidly pipe things."
	icon_state			= "rpd"

	starting_materials	= list(MAT_IRON = 75000, MAT_GLASS = 37500)

	schematics	= list(

		/* Utilities */
		/datum/rcd_schematic/decon_pipes,
		/datum/rcd_schematic/paint_pipes,

		/* Regular pipes */
		/datum/rcd_schematic/pipe,
		/datum/rcd_schematic/pipe/bent,
		/datum/rcd_schematic/pipe/manifold,
		/datum/rcd_schematic/pipe/valve,
		/datum/rcd_schematic/pipe/dvalve,
		/datum/rcd_schematic/pipe/cap,
		/datum/rcd_schematic/pipe/manifold_4w,
		/datum/rcd_schematic/pipe/mtvalve,
		/datum/rcd_schematic/pipe/dtvalve,

		/* Devices */
		/datum/rcd_schematic/pipe/connector,
		/datum/rcd_schematic/pipe/unary_vent,
		/datum/rcd_schematic/pipe/passive_vent,
		/datum/rcd_schematic/pipe/pump,
		/datum/rcd_schematic/pipe/passive_gate,
		/datum/rcd_schematic/pipe/volume_pump,
		/datum/rcd_schematic/pipe/scrubber,
		/datum/rcd_schematic/pmeter,
		/datum/rcd_schematic/gsensor,
		/datum/rcd_schematic/pipe/filter,
		/datum/rcd_schematic/pipe/mixer,
		/datum/rcd_schematic/pipe/thermal_plate,
		/datum/rcd_schematic/pipe/injector,
		/datum/rcd_schematic/pipe/dp_vent,

		/* H/E Pipes */
		/datum/rcd_schematic/pipe/he,
		/datum/rcd_schematic/pipe/he_bent,
		/datum/rcd_schematic/pipe/juntion,
		/datum/rcd_schematic/pipe/heat_exchanger,

		/* Insulated Pipes */
		/datum/rcd_schematic/pipe/insulated,
		/datum/rcd_schematic/pipe/insulated_bent,
		/datum/rcd_schematic/pipe/insulated_manifold,
		/datum/rcd_schematic/pipe/insulated_4w_manifold,

		/* Disposal Pipes */
		/datum/rcd_schematic/pipe/disposal,
		/datum/rcd_schematic/pipe/disposal/bent,
		/datum/rcd_schematic/pipe/disposal/junction,
		/datum/rcd_schematic/pipe/disposal/y_junction,
		/datum/rcd_schematic/pipe/disposal/trunk,
		/datum/rcd_schematic/pipe/disposal/bin,
		/datum/rcd_schematic/pipe/disposal/outlet,
		/datum/rcd_schematic/pipe/disposal/chute,
		/datum/rcd_schematic/pipe/disposal/sort,
		/datum/rcd_schematic/pipe/disposal/sort_wrap
	)
