///all stuff used by RCD for construction
GLOBAL_LIST_INIT(rcd_designs, list(
	//1ST ROOT CATEGORY
	"Construction" = list( //Stuff you use to make & decorate areas
		//Walls & Windows
		"Structures" = list(
			list(RCD_DESIGN_MODE = RCD_TURF, RCD_DESIGN_PATH = /turf/open/floor/plating/rcd),
			list(RCD_DESIGN_MODE = RCD_WINDOWGRILLE, RCD_DESIGN_PATH = /obj/structure/window),
			list(RCD_DESIGN_MODE = RCD_WINDOWGRILLE, RCD_DESIGN_PATH = /obj/structure/window/reinforced),
			list(RCD_DESIGN_MODE = RCD_WINDOWGRILLE, RCD_DESIGN_PATH = /obj/structure/window/fulltile),
			list(RCD_DESIGN_MODE = RCD_WINDOWGRILLE, RCD_DESIGN_PATH = /obj/structure/window/reinforced/fulltile),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/reflector/wrenched),
			list(RCD_DESIGN_MODE = RCD_TURF, RCD_DESIGN_PATH = /obj/structure/lattice/catwalk),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/girder),
		),

		//Computers & Machine Frames
		"Machines" = list(
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/frame/machine/secured),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/frame/computer/rcd/north),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/frame/computer/rcd/south),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/frame/computer/rcd/east),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/frame/computer/rcd/west),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/floodlight_frame/completed),
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/item/wallframe/apc),
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/item/wallframe/airalarm),
			list(RCD_DESIGN_MODE = RCD_WALLFRAME, RCD_DESIGN_PATH = /obj/item/wallframe/firealarm),
		),

		//Interior Design[construction_mode = RCD_FURNISHING is implied]
		"Furniture" = list(
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/chair),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/chair/stool),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/chair/stool/bar),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/table),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/table/glass),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/rack),
			list(RCD_DESIGN_MODE = RCD_STRUCTURE, RCD_DESIGN_PATH = /obj/structure/bed),
		),
	),

	//2ND ROOT CATEGORY[construction_mode = RCD_AIRLOCK is implied,"icon=closed"]
	"Airlocks" = list( //used to seal/close areas
		//Window Doors[airlock_glass = TRUE is implied]
		"Windoors" = list(
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/window),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/window/brigdoor),
		),

		//Glass Airlocks[airlock_glass = TRUE is implied,do fill_closed overlay]
		"Glass Airlocks" = list(
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/public/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/engineering/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/atmos/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/security/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/command/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/medical/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/research/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/hydroponics/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/virology/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/mining/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/external/glass),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance/external/glass),
		),

		//Solid Airlocks[airlock_glass = FALSE is implied,no fill_closed overlay]
		"Solid Airlocks" = list(
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/public),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/engineering),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/atmos),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/security),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/command),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/medical),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/research),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/freezer),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/hydroponics),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/virology),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/mining),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/external),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance/external),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/hatch),
			list(RCD_DESIGN_MODE = RCD_AIRLOCK, RCD_DESIGN_PATH = /obj/machinery/door/airlock/maintenance_hatch),
		),
	),

	//3RD CATEGORY Airlock access,empty list cause airlock_electronics UI will be displayed  when this tab is selected
	"Airlock Access" = list()
))
