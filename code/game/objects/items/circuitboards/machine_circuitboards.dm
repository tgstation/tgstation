/obj/item/circuitboard/machine/sleeper
	name = "Sleeper (Machine Board)"
	build_path = /obj/machinery/sleeper
	origin_tech = "programming=3;biotech=2;engineering=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/announcement_system
	name = "Announcement System (Machine Board)"
	build_path = /obj/machinery/announcement_system
	origin_tech = "programming=3;bluespace=3;magnets=2"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/autolathe
	name = "Autolathe (Machine Board)"
	build_path = /obj/machinery/autolathe
	origin_tech = "engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/clonepod
	name = "Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepod
	origin_tech = "programming=2;biotech=2"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/abductor
	name = "alien board (Report This)"
	icon_state = "abductor_mod"
	origin_tech = "programming=5;abductor=3"

/obj/item/circuitboard/machine/clockwork
	name = "clockwork board (Report This)"
	icon_state = "clock_mod"

/obj/item/circuitboard/machine/clonescanner
	name = "Cloning Scanner (Machine Board)"
	build_path = /obj/machinery/dna_scannernew
	origin_tech = "programming=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/holopad
	name = "AI Holopad (Machine Board)"
	build_path = /obj/machinery/holopad
	origin_tech = "programming=1"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/launchpad
	name = "Bluespace Launchpad (Machine Board)"
	build_path = /obj/machinery/launchpad
	origin_tech = "programming=3;engineering=3;plasmatech=2;bluespace=3"
	req_components = list(
		/obj/item/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/manipulator = 1)
	def_components = list(/obj/item/ore/bluespace_crystal = /obj/item/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/limbgrower
	name = "Limb Grower (Machine Board)"
	build_path = /obj/machinery/limbgrower
	origin_tech = "programming=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/quantumpad
	name = "Quantum Pad (Machine Board)"
	build_path = /obj/machinery/quantumpad
	origin_tech = "programming=3;engineering=3;plasmatech=3;bluespace=4"
	req_components = list(
		/obj/item/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/ore/bluespace_crystal = /obj/item/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/recharger
	name = "Weapon Recharger (Machine Board)"
	build_path = /obj/machinery/recharger
	origin_tech = "powerstorage=4;engineering=3;materials=4"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/cyborgrecharger
	name = "Cyborg Recharger (Machine Board)"
	build_path = /obj/machinery/recharge_station
	origin_tech = "powerstorage=3;engineering=3"
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/manipulator = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)

/obj/item/circuitboard/machine/recycler
	name = "Recycler (Machine Board)"
	build_path = /obj/machinery/recycler
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/space_heater
	name = "Space Heater (Machine Board)"
	build_path = /obj/machinery/space_heater
	origin_tech = "programming=2;engineering=2;plasmatech=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 3)

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "Subspace Broadcaster (Machine Board)"
	build_path = /obj/machinery/telecomms/broadcaster
	origin_tech = "programming=2;engineering=2;bluespace=1"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/telecomms/bus
	name = "Bus Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/bus
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/telecomms/hub
	name = "Hub Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/hub
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/processor
	name = "Processor Unit (Machine Board)"
	build_path = /obj/machinery/telecomms/processor
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/treatment = 2,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/amplifier = 1)

/obj/item/circuitboard/machine/telecomms/receiver
	name = "Subspace Receiver (Machine Board)"
	build_path = /obj/machinery/telecomms/receiver
	origin_tech = "programming=2;engineering=2;bluespace=1"
	req_components = list(
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/telecomms/relay
	name = "Relay Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/relay
	origin_tech = "programming=2;engineering=2;bluespace=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/server
	name = "Telecommunication Server (Machine Board)"
	build_path = /obj/machinery/telecomms/server
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/teleporter_hub
	name = "Teleporter Hub (Machine Board)"
	build_path = /obj/machinery/teleport/hub
	origin_tech = "programming=3;engineering=4;bluespace=4;materials=4"
	req_components = list(
		/obj/item/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/ore/bluespace_crystal = /obj/item/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/teleporter_station
	name = "Teleporter Station (Machine Board)"
	build_path = /obj/machinery/teleport/station
	origin_tech = "programming=4;engineering=4;bluespace=4;plasmatech=3"
	req_components = list(
		/obj/item/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/console_screen = 1)
	def_components = list(/obj/item/ore/bluespace_crystal = /obj/item/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/vendor
	name = "Booze-O-Mat Vendor (Machine Board)"
	build_path = /obj/machinery/vending/boozeomat
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/vending_refill/boozeomat = 3)

	var/static/list/vending_names_paths = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp",
							/obj/machinery/vending/cola = "Robust Softdrinks",
							/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
							/obj/machinery/vending/autodrobe = "AutoDrobe",
							/obj/machinery/vending/clothing = "ClothesMate",
							/obj/machinery/vending/medical = "NanoMed Plus",
							/obj/machinery/vending/wallmed = "NanoMed")

/obj/item/circuitboard/machine/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		var/position = vending_names_paths.Find(build_path)
		position = (position == vending_names_paths.len) ? 1 : (position + 1)
		var/typepath = vending_names_paths[position]

		to_chat(user, "<span class='notice'>You set the board to \"[vending_names_paths[typepath]]\".</span>")
		set_type(typepath)
	else
		return ..()

/obj/item/circuitboard/machine/vendor/proc/set_type(obj/machinery/vending/typepath)
	build_path = typepath
	name = "[vending_names_paths[build_path]] Vendor (Machine Board)"
	req_components = list(initial(typepath.refill_canister) = initial(typepath.refill_count))

/obj/item/circuitboard/machine/vendor/apply_default_parts(obj/machinery/M)
	for(var/typepath in vending_names_paths)
		if(istype(M, typepath))
			set_type(typepath)
			break
	return ..()

/obj/item/circuitboard/machine/mech_recharger
	name = "Mechbay Recharger (Machine Board)"
	build_path = /obj/machinery/mech_bay_recharge_port
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/machine/mechfab
	name = "Exosuit Fabricator (Machine Board)"
	build_path = /obj/machinery/mecha_part_fabricator
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/cryo_tube
	name = "Cryotube (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/thermomachine
	name = "Thermomachine (Machine Board)"
	desc = "You can use a screwdriver to switch between heater and freezer."
	origin_tech = "programming=3;plasmatech=3"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 2,
							/obj/item/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/stock_parts/console_screen = 1)

#define PATH_FREEZER /obj/machinery/atmospherics/components/unary/thermomachine/freezer
#define PATH_HEATER  /obj/machinery/atmospherics/components/unary/thermomachine/heater

/obj/item/circuitboard/machine/thermomachine/Initialize()
	. = ..()
	if(!build_path)
		if(prob(50))
			name = "Freezer (Machine Board)"
			build_path = PATH_FREEZER
		else
			name = "Heater (Machine Board)"
			build_path = PATH_HEATER

/obj/item/circuitboard/machine/thermomachine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		var/obj/item/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(PATH_FREEZER)
				new_type = /obj/item/circuitboard/machine/thermomachine/heater
				new_setting = "Heater"
			if(PATH_HEATER)
				new_type = /obj/item/circuitboard/machine/thermomachine/freezer
				new_setting = "Freezer"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		playsound(user, I.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
	else
		return ..()

/obj/item/circuitboard/machine/thermomachine/heater
	name = "Heater (Machine Board)"
	build_path = PATH_HEATER

/obj/item/circuitboard/machine/thermomachine/freezer
	name = "Freezer (Machine Board)"
	build_path = PATH_FREEZER

#undef PATH_FREEZER
#undef PATH_HEATER

/obj/item/circuitboard/machine/deep_fryer
	name = "circuit board (Deep Fryer)"
	build_path = /obj/machinery/deepfryer
	origin_tech = "programming=1"
	req_components = list(/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/gibber
	name = "Gibber (Machine Board)"
	build_path = /obj/machinery/gibber
	origin_tech = "programming=2;engineering=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/monkey_recycler
	name = "Monkey Recycler (Machine Board)"
	build_path = /obj/machinery/monkey_recycler
	origin_tech = "programming=1;biotech=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/processor
	name = "Food Processor (Machine Board)"
	build_path = /obj/machinery/processor
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/processor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		if(build_path == /obj/machinery/processor)
			name = "Slime Processor (Machine Board)"
			build_path = /obj/machinery/processor/slime
			to_chat(user, "<span class='notice'>Name protocols successfully updated.</span>")
		else
			name = "Food Processor (Machine Board)"
			build_path = /obj/machinery/processor
			to_chat(user, "<span class='notice'>Defaulting name protocols.</span>")
	else
		return ..()

/obj/item/circuitboard/machine/processor/slime
	name = "Slime Processor (Machine Board)"
	build_path = /obj/machinery/processor/slime

/obj/item/circuitboard/machine/smartfridge
	name = "Smartfridge (Machine Board)"
	build_path = /obj/machinery/smartfridge
	origin_tech = "programming=1"
	req_components = list(/obj/item/stock_parts/matter_bin = 1)
	var/static/list/fridges_name_paths = list(/obj/machinery/smartfridge = "plant produce",
		/obj/machinery/smartfridge/food = "food",
		/obj/machinery/smartfridge/drinks = "drinks",
		/obj/machinery/smartfridge/extract = "slimes",
		/obj/machinery/smartfridge/chemistry = "chems",
		/obj/machinery/smartfridge/chemistry/virology = "viruses",
		/obj/machinery/smartfridge/disks = "disks")

/obj/item/circuitboard/machine/smartfridge/Initialize(mapload, new_type)
	if(new_type)
		build_path = new_type
	return ..()

/obj/item/circuitboard/machine/smartfridge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		var/position = fridges_name_paths.Find(build_path, fridges_name_paths)
		position = (position == fridges_name_paths.len) ? 1 : (position + 1)
		build_path = fridges_name_paths[position]
		to_chat(user, "<span class='notice'>You set the board to [fridges_name_paths[build_path]].</span>")
	else
		return ..()

/obj/item/circuitboard/machine/smartfridge/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[src] is set to [fridges_name_paths[build_path]]. You can use a screwdriver to reconfigure it.</span>")

/obj/item/circuitboard/machine/biogenerator
	name = "Biogenerator (Machine Board)"
	build_path = /obj/machinery/biogenerator
	origin_tech = "programming=2;biotech=3;materials=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/plantgenes
	name = "Plant DNA Manipulator (Machine Board)"
	build_path = /obj/machinery/plantgenes
	origin_tech = "programming=3;biotech=3"
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/plantgenes/vault
	name = "alien board (Plant DNA Manipulator)"
	icon_state = "abductor_mod"
	origin_tech = "programming=5;biotech=5"
	// It wasn't made by actual abductors race, so no abductor tech here.
	def_components = list(
		/obj/item/stock_parts/manipulator = /obj/item/stock_parts/manipulator/femto,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra,
		/obj/item/stock_parts/scanning_module = /obj/item/stock_parts/scanning_module/triphasic)


/obj/item/circuitboard/machine/hydroponics
	name = "Hydroponics Tray (Machine Board)"
	build_path = /obj/machinery/hydroponics/constructable
	origin_tech = "programming=1;biotech=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/seed_extractor
	name = "Seed Extractor (Machine Board)"
	build_path = /obj/machinery/seed_extractor
	origin_tech = "programming=1"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/ore_redemption
	name = "Ore Redemption (Machine Board)"
	build_path = /obj/machinery/mineral/ore_redemption
	origin_tech = "programming=1;engineering=2"
	req_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/device/assembly/igniter = 1)

/obj/item/circuitboard/machine/mining_equipment_vendor
	name = "Mining Equipment Vendor (Machine Board)"
	build_path = /obj/machinery/mineral/equipment_vendor
	origin_tech = "programming=1;engineering=3"
	req_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/machine/mining_equipment_vendor/golem
	name = "Golem Ship Equipment Vendor (Machine Board)"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/circuitboard/machine/ntnet_relay
	name = "NTNet Relay (Machine Board)"
	build_path = /obj/machinery/ntnet_relay
	origin_tech = "programming=3;bluespace=3;magnets=2"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/pacman
	name = "PACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman
	origin_tech = "programming=2;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/pacman/super
	name = "SUPERPACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/circuitboard/machine/pacman/mrs
	name = "MRSPACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/mrs
	origin_tech = "programming=3;powerstorage=4;engineering=4;plasmatech=4"

/obj/item/circuitboard/machine/rtg
	name = "RTG (Machine Board)"
	build_path = /obj/machinery/power/rtg
	origin_tech = "programming=2;materials=4;powerstorage=3;engineering=2"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10) // We have no Pu-238, and this is the closest thing to it.

/obj/item/circuitboard/machine/rtg/advanced
	name = "Advanced RTG (Machine Board)"
	build_path = /obj/machinery/power/rtg/advanced
	origin_tech = "programming=3;materials=5;powerstorage=4;engineering=3;plasmatech=3"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5)

/obj/item/circuitboard/machine/abductor/core
	name = "alien board (Void Core)"
	build_path = /obj/machinery/power/rtg/abductor
	origin_tech = "programming=5;abductor=5;powerstorage=8;engineering=8"
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/cell/infinite/abductor = 1)
	def_components = list(
		/obj/item/stock_parts/capacitor = /obj/item/stock_parts/capacitor/quadratic,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra)

/obj/item/circuitboard/machine/emitter
	name = "Emitter (Machine Board)"
	build_path = /obj/machinery/power/emitter
	origin_tech = "programming=3;powerstorage=4;engineering=4"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/smes
	name = "SMES (Machine Board)"
	build_path = /obj/machinery/power/smes
	origin_tech = "programming=3;powerstorage=3;engineering=3"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stock_parts/capacitor = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high/empty)

/obj/item/circuitboard/machine/tesla_coil
	name = "Tesla Coil (Machine Board)"
	build_path = /obj/machinery/power/tesla_coil
	origin_tech = "programming=3;magnets=3;powerstorage=3"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/grounding_rod
	name = "Grounding Rod (Machine Board)"
	build_path = /obj/machinery/power/grounding_rod
	origin_tech = "programming=3;powerstorage=3;magnets=3;plasmatech=2"
	req_components = list(/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/power_compressor
	name = "Power Compressor (Machine Board)"
	build_path = /obj/machinery/power/compressor
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/machine/power_turbine
	name = "Power Turbine (Machine Board)"
	build_path = /obj/machinery/power/turbine
	origin_tech = "programming=4;powerstorage=4;engineering=4"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/machine/chem_dispenser
	name = "Portable Chem Dispenser (Machine Board)"
	build_path = /obj/machinery/chem_dispenser/constructable
	origin_tech = "materials=4;programming=4;plasmatech=4;biotech=3"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/cell = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)

/obj/item/circuitboard/machine/chem_heater
	name = "Chemical Heater (Machine Board)"
	build_path = /obj/machinery/chem_heater
	origin_tech = "programming=2;engineering=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/chem_master
	name = "ChemMaster 3000 (Machine Board)"
	build_path = /obj/machinery/chem_master
	origin_tech = "materials=3;programming=2;biotech=3"
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/console_screen = 1)

/obj/item/circuitboard/machine/chem_master/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		var/new_name = "ChemMaster"
		var/new_path = /obj/machinery/chem_master

		if(build_path == /obj/machinery/chem_master)
			new_name = "CondiMaster"
			new_path = /obj/machinery/chem_master/condimaster

		build_path = new_path
		name = "[new_name] 3000 (Machine Board)"
		to_chat(user, "<span class='notice'>You change the circuit board setting to \"[new_name]\".</span>")
	else
		return ..()

/obj/item/circuitboard/machine/chem_master/condi
	name = "CondiMaster 3000 (Machine Board)"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/machine/circuit_imprinter
	name = "Circuit Imprinter (Machine Board)"
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	origin_tech = "engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer (Machine Board)"
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	origin_tech = "magnets=2;engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/experimentor
	name = "E.X.P.E.R.I-MENTOR (Machine Board)"
	build_path = /obj/machinery/r_n_d/experimentor
	origin_tech = "magnets=1;engineering=1;programming=1;biotech=1;bluespace=2"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/protolathe
	name = "Protolathe (Machine Board)"
	build_path = /obj/machinery/r_n_d/protolathe
	origin_tech = "engineering=2;programming=2"
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/rdserver
	name = "R&D Server (Machine Board)"
	build_path = /obj/machinery/r_n_d/server
	origin_tech = "programming=3"
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/bsa/back
	name = "Bluespace Artillery Generator (Machine Board)"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	name = "Bluespace Artillery Fusor (Machine Board)"
	build_path = /obj/machinery/bsa/middle
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
		/obj/item/ore/bluespace_crystal = 20,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	name = "Bluespace Artillery Bore (Machine Board)"
	build_path = /obj/machinery/bsa/front
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
		/obj/item/stock_parts/manipulator/femto = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/dna_vault
	name = "DNA Vault (Machine Board)"
	build_path = /obj/machinery/dna_vault
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/microwave
	name = "Microwave (Machine Board)"
	build_path = /obj/machinery/microwave
	origin_tech = "programming=2;magnets=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stack/sheet/glass = 1)