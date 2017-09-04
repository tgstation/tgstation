/obj/item/circuitboard/machine/pressure
	name = "circuit board (Pressurized reaction vessel)"
	build_path = /obj/machinery/chem/pressure
	origin_tech = "materials=5;engineering=5;programming=2;plasmatech=3;biotech=2"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/capacitor = 2,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/scanning_module = 1,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/machine/centrifuge
	name = "circuit board (Centrifuge)"
	build_path = /obj/machinery/chem/centrifuge
	origin_tech = "materials=6;engineering=6;programming=5;plasmatech=2;biotech=4"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/capacitor = 1,
							/obj/item/stock_parts/manipulator = 3,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stock_parts/scanning_module = 2,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/machine/radioactive
	name = "circuit board (Radioactive molecular reassembler)"
	build_path = /obj/machinery/chem/radioactive
	origin_tech = "materials=6;engineering=6;programming=5;plasmatech=2;biotech=4"
	req_components = list(
							/obj/item/stock_parts/matter_bin/super = 1,
							/obj/item/stock_parts/capacitor = 5,
							/obj/item/stock_parts/manipulator/pico = 3,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/micro_laser/ultra = 3,
							/obj/item/stock_parts/scanning_module/phasic = 4,
							/obj/item/stock_parts/cell = 1)

/obj/item/circuitboard/machine/bluespace
	name = "circuit board (Bluespace recombobulator)"
	build_path = /obj/machinery/chem/bluespace
	origin_tech = "materials=6;engineering=6;programming=5;plasmatech=3;biotech=4,bluespace = 3"
	req_components = list(
							/obj/item/stock_parts/matter_bin/super = 3,
							/obj/item/stock_parts/capacitor/super = 10,
							/obj/item/stock_parts/manipulator/pico = 5,
							/obj/item/stock_parts/console_screen = 1,
							/obj/item/stock_parts/micro_laser/ultra = 5,
							/obj/item/stock_parts/scanning_module/phasic = 4,
							/obj/item/ore/bluespace_crystal/refined = 3,//this thing is an utter SHIT to make
							/obj/item/stock_parts/cell = 1)