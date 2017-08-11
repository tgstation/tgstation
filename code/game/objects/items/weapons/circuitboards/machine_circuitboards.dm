/obj/item/weapon/circuitboard/machine/sleeper
	name = "Sleeper (Machine Board)"
	build_path = /obj/machinery/sleeperrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/weapon/circuitboard/machine/announcement_system
	name = "Announcement System (Machine Board)"
	build_path = /obj/machinery/announcement_systemrnd
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/autolathe
	name = "Autolathe (Machine Board)"
	build_path = /obj/machinery/autolathernd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 3,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/clonepod
	name = "Clone Pod (Machine Board)"
	build_path = /obj/machinery/clonepodrnd
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/weapon/circuitboard/machine/abductor
	name = "alien board (Report This)"
	icon_state = "abductor_mod"rnd

/obj/item/weapon/circuitboard/machine/clockwork
	name = "clockwork board (Report This)"
	icon_state = "clock_mod"

/obj/item/weapon/circuitboard/machine/clonescanner
	name = "Cloning Scanner (Machine Board)"
	build_path = /obj/machinery/dna_scannernewrnd
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/holopad
	name = "AI Holopad (Machine Board)"
	build_path = /obj/machinery/holopadrnd
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/launchpad
	name = "Bluespace Launchpad (Machine Board)"
	build_path = /obj/machinery/launchpadrnd
	req_components = list(
		/obj/item/weapon/ore/bluespace_crystal = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/item/weapon/circuitboard/machine/limbgrower
	name = "Limb Grower (Machine Board)"
	build_path = /obj/machinery/limbgrowerrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/reagent_containers/glass/beaker = 2,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/quantumpad
	name = "Quantum Pad (Machine Board)"
	build_path = /obj/machinery/quantumpadrnd
	req_components = list(
		/obj/item/weapon/ore/bluespace_crystal = 1,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/item/weapon/circuitboard/machine/recharger
	name = "Weapon Recharger (Machine Board)"
	build_path = /obj/machinery/rechargerrnd
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/cyborgrecharger
	name = "Cyborg Recharger (Machine Board)"
	build_path = /obj/machinery/recharge_stationrnd
	req_components = list(
		/obj/item/weapon/stock_parts/capacitor = 2,
		/obj/item/weapon/stock_parts/cell = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)
	def_components = list(/obj/item/weapon/stock_parts/cell = /obj/item/weapon/stock_parts/cell/high)

/obj/item/weapon/circuitboard/machine/recycler
	name = "Recycler (Machine Board)"
	build_path = /obj/machinery/recyclerrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/space_heater
	name = "Space Heater (Machine Board)"
	build_path = /obj/machinery/space_heaterrnd
	req_components = list(
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 3)

/obj/item/weapon/circuitboard/machine/telecomms/broadcaster
	name = "Subspace Broadcaster (Machine Board)"
	build_path = /obj/machinery/telecomms/broadcasterrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/subspace/filter = 1,
		/obj/item/weapon/stock_parts/subspace/crystal = 1,
		/obj/item/weapon/stock_parts/micro_laser = 2)

/obj/item/weapon/circuitboard/machine/telecomms/bus
	name = "Bus Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/busrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/machine/telecomms/hub
	name = "Hub Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/hubrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/machine/telecomms/processor
	name = "Processor Unit (Machine Board)"
	build_path = /obj/machinery/telecomms/processorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 3,
		/obj/item/weapon/stock_parts/subspace/filter = 1,
		/obj/item/weapon/stock_parts/subspace/treatment = 2,
		/obj/item/weapon/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/subspace/amplifier = 1)

/obj/item/weapon/circuitboard/machine/telecomms/receiver
	name = "Subspace Receiver (Machine Board)"
	build_path = /obj/machinery/telecomms/receiverrnd
	req_components = list(
		/obj/item/weapon/stock_parts/subspace/ansible = 1,
		/obj/item/weapon/stock_parts/subspace/filter = 1,
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/machine/telecomms/relay
	name = "Relay Mainframe (Machine Board)"
	build_path = /obj/machinery/telecomms/relayrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/subspace/filter = 2)

/obj/item/weapon/circuitboard/machine/telecomms/server
	name = "Telecommunication Server (Machine Board)"
	build_path = /obj/machinery/telecomms/serverrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/machine/teleporter_hub
	name = "Teleporter Hub (Machine Board)"
	build_path = /obj/machinery/teleport/hubrnd
	req_components = list(
		/obj/item/weapon/ore/bluespace_crystal = 3,
		/obj/item/weapon/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/item/weapon/circuitboard/machine/teleporter_station
	name = "Teleporter Station (Machine Board)"
	build_path = /obj/machinery/teleport/stationrnd
	req_components = list(
		/obj/item/weapon/ore/bluespace_crystal = 2,
		/obj/item/weapon/stock_parts/capacitor = 2,
		/obj/item/weapon/stock_parts/console_screen = 1)
	def_components = list(/obj/item/weapon/ore/bluespace_crystal = /obj/item/weapon/ore/bluespace_crystal/artificial)

/obj/item/weapon/circuitboard/machine/vendor
	name = "Booze-O-Mat Vendor (Machine Board)"
	build_path = /obj/machinery/vending/boozeomatrnd
	req_components = list(
							/obj/item/weapon/vending_refill/boozeomat = 3)

	var/static/list/vending_names_paths = list(/obj/machinery/vending/boozeomat = "Booze-O-Mat",
							/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
							/obj/machinery/vending/snack = "Getmore Chocolate Corp",
							/obj/machinery/vending/cola = "Robust Softdrinks",
							/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
							/obj/machinery/vending/autodrobe = "AutoDrobe",
							/obj/machinery/vending/clothing = "ClothesMate",
							/obj/machinery/vending/medical = "NanoMed Plus",
							/obj/machinery/vending/wallmed = "NanoMed")

/obj/item/weapon/circuitboard/machine/vendor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/position = vending_names_paths.Find(build_path)
		position = (position == vending_names_paths.len) ? 1 : (position + 1)
		var/typepath = vending_names_paths[position]

		to_chat(user, "<span class='notice'>You set the board to \"[vending_names_paths[typepath]]\".</span>")
		set_type(typepath)
	else
		return ..()

/obj/item/weapon/circuitboard/machine/vendor/proc/set_type(obj/machinery/vending/typepath)
	build_path = typepath
	name = "[vending_names_paths[build_path]] Vendor (Machine Board)"
	req_components = list(initial(typepath.refill_canister) = initial(typepath.refill_count))

/obj/item/weapon/circuitboard/machine/vendor/apply_default_parts(obj/machinery/M)
	for(var/typepath in vending_names_paths)
		if(istype(M, typepath))
			set_type(typepath)
			break
	return ..()

/obj/item/weapon/circuitboard/machine/mech_recharger
	name = "Mechbay Recharger (Machine Board)"
	build_path = /obj/machinery/mech_bay_recharge_portrnd
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/capacitor = 5)

/obj/item/weapon/circuitboard/machine/mechfab
	name = "Exosuit Fabricator (Machine Board)"
	build_path = /obj/machinery/mecha_part_fabricatorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/cryo_tube
	name = "Cryotube (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cellrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/weapon/circuitboard/machine/thermomachine
	name = "Thermomachine (Machine Board)"
	desc = "You can use a screwdriver to switch between heater and freezer."rnd
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 2,
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/thermomachine/Initialize()
	. = ..()
	if(prob(50))
		name = "Freezer (Machine Board)"
		build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer
	else
		name = "Heater (Machine Board)"
		build_path = /obj/machinery/atmospherics/components/unary/thermomachine/heater

#define FREEZER /obj/item/weapon/circuitboard/machine/thermomachine/freezer
#define HEATER /obj/item/weapon/circuitboard/machine/thermomachine/heater

/obj/item/weapon/circuitboard/machine/thermomachine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/obj/item/weapon/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(FREEZER)
				new_type = HEATER
				new_setting = "Heater"
			if(HEATER)
				new_type = FREEZER
				new_setting = "Freezer"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		playsound(user, I.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
	else
		return ..()

#undef FREEZER
#undef HEATER

/obj/item/weapon/circuitboard/machine/thermomachine/heater
	name = "Heater (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/heater

/obj/item/weapon/circuitboard/machine/thermomachine/freezer
	name = "Freezer (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer

/obj/item/weapon/circuitboard/machine/deep_fryer
	name = "circuit board (Deep Fryer)"
	build_path = /obj/machinery/deepfryerrnd
	req_components = list(/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/machine/gibber
	name = "Gibber (Machine Board)"
	build_path = /obj/machinery/gibberrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/monkey_recycler
	name = "Monkey Recycler (Machine Board)"
	build_path = /obj/machinery/monkey_recyclerrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/processor
	name = "Food Processor (Machine Board)"
	build_path = /obj/machinery/processorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/processor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
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

/obj/item/weapon/circuitboard/machine/processor/slime
	name = "Slime Processor (Machine Board)"
	build_path = /obj/machinery/processor/slime

/obj/item/weapon/circuitboard/machine/smartfridge
	name = "Smartfridge (Machine Board)"
	build_path = /obj/machinery/smartfridgernd
	req_components = list(/obj/item/weapon/stock_parts/matter_bin = 1)
	var/static/list/fridges_name_paths = list(/obj/machinery/smartfridge = "plant produce",
		/obj/machinery/smartfridge/food = "food",
		/obj/machinery/smartfridge/drinks = "drinks",
		/obj/machinery/smartfridge/extract = "slimes",
		/obj/machinery/smartfridge/chemistry = "chems",
		/obj/machinery/smartfridge/chemistry/virology = "viruses",
		/obj/machinery/smartfridge/disks = "disks")

/obj/item/weapon/circuitboard/machine/smartfridge/Initialize(mapload, new_type)
	if(new_type)
		build_path = new_type
	return ..()

/obj/item/weapon/circuitboard/machine/smartfridge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/position = fridges_name_paths.Find(build_path, fridges_name_paths)
		position = (position == fridges_name_paths.len) ? 1 : (position + 1)
		build_path = fridges_name_paths[position]
		to_chat(user, "<span class='notice'>You set the board to [fridges_name_paths[build_path]].</span>")
	else
		return ..()

/obj/item/weapon/circuitboard/machine/smartfridge/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[src] is set to [fridges_name_paths[build_path]]. You can use a screwdriver to reconfigure it.</span>")

/obj/item/weapon/circuitboard/machine/biogenerator
	name = "Biogenerator (Machine Board)"
	build_path = /obj/machinery/biogeneratorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/plantgenes
	name = "Plant DNA Manipulator (Machine Board)"
	build_path = /obj/machinery/plantgenesrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/item/weapon/circuitboard/machine/plantgenes/vault
	name = "alien board (Plant DNA Manipulator)"
	icon_state = "abductor_mod"rnd
	// It wasn't made by actual abductors race, so no abductor tech here.
	def_components = list(
		/obj/item/weapon/stock_parts/manipulator = /obj/item/weapon/stock_parts/manipulator/femto,
		/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/quadultra,
		/obj/item/weapon/stock_parts/scanning_module = /obj/item/weapon/stock_parts/scanning_module/triphasic)


/obj/item/weapon/circuitboard/machine/hydroponics
	name = "Hydroponics Tray (Machine Board)"
	build_path = /obj/machinery/hydroponics/constructablernd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/seed_extractor
	name = "Seed Extractor (Machine Board)"
	build_path = /obj/machinery/seed_extractorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/ore_redemption
	name = "Ore Redemption (Machine Board)"
	build_path = /obj/machinery/mineral/ore_redemptionrnd
	req_components = list(
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/device/assembly/igniter = 1)

/obj/item/weapon/circuitboard/machine/mining_equipment_vendor
	name = "Mining Equipment Vendor (Machine Board)"
	build_path = /obj/machinery/mineral/equipment_vendorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/stock_parts/matter_bin = 3)

/obj/item/weapon/circuitboard/machine/mining_equipment_vendor/golem
	name = "Golem Ship Equipment Vendor (Machine Board)"
	build_path = /obj/machinery/mineral/equipment_vendor/golem

/obj/item/weapon/circuitboard/machine/ntnet_relay
	name = "NTNet Relay (Machine Board)"
	build_path = /obj/machinery/ntnet_relayrnd
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/subspace/filter = 1)

/obj/item/weapon/circuitboard/machine/pacman
	name = "PACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacmanrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/pacman/super
	name = "SUPERPACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/superrnd

/obj/item/weapon/circuitboard/machine/pacman/mrs
	name = "MRSPACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/mrsrnd

/obj/item/weapon/circuitboard/machine/rtg
	name = "RTG (Machine Board)"
	build_path = /obj/machinery/power/rtgrnd
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10) // We have no Pu-238, and this is the closest thing to it.

/obj/item/weapon/circuitboard/machine/rtg/advanced
	name = "Advanced RTG (Machine Board)"
	build_path = /obj/machinery/power/rtg/advancedrnd
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5)

/obj/item/weapon/circuitboard/machine/abductor/core
	name = "alien board (Void Core)"
	build_path = /obj/machinery/power/rtg/abductorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/cell/infinite/abductor = 1)
	def_components = list(
		/obj/item/weapon/stock_parts/capacitor = /obj/item/weapon/stock_parts/capacitor/quadratic,
		/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/quadultra)

/obj/item/weapon/circuitboard/machine/emitter
	name = "Emitter (Machine Board)"
	build_path = /obj/machinery/power/emitterrnd
	req_components = list(
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/manipulator = 1)

/obj/item/weapon/circuitboard/machine/smes
	name = "SMES (Machine Board)"
	build_path = /obj/machinery/power/smesrnd
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/cell = 5,
		/obj/item/weapon/stock_parts/capacitor = 1)
	def_components = list(/obj/item/weapon/stock_parts/cell = /obj/item/weapon/stock_parts/cell/high/empty)

/obj/item/weapon/circuitboard/machine/tesla_coil
	name = "Tesla Coil (Machine Board)"
	build_path = /obj/machinery/power/tesla_coilrnd
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/grounding_rod
	name = "Grounding Rod (Machine Board)"
	build_path = /obj/machinery/power/grounding_rodrnd
	req_components = list(/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/power_compressor
	name = "Power Compressor (Machine Board)"
	build_path = /obj/machinery/power/compressorrnd
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/manipulator = 6)

/obj/item/weapon/circuitboard/machine/power_turbine
	name = "Power Turbine (Machine Board)"
	build_path = /obj/machinery/power/turbinernd
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/weapon/stock_parts/capacitor = 6)

/obj/item/weapon/circuitboard/machine/chem_dispenser
	name = "Portable Chem Dispenser (Machine Board)"
	build_path = /obj/machinery/chem_dispenser/constructablernd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/weapon/stock_parts/cell = 1)
	def_components = list(/obj/item/weapon/stock_parts/cell = /obj/item/weapon/stock_parts/cell/high)

/obj/item/weapon/circuitboard/machine/chem_heater
	name = "Chemical Heater (Machine Board)"
	build_path = /obj/machinery/chem_heaterrnd
	req_components = list(
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/chem_master
	name = "ChemMaster 3000 (Machine Board)"
	build_path = /obj/machinery/chem_masterrnd
	req_components = list(
		/obj/item/weapon/reagent_containers/glass/beaker = 2,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/chem_master/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
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

/obj/item/weapon/circuitboard/machine/chem_master/condi
	name = "CondiMaster 3000 (Machine Board)"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/weapon/circuitboard/machine/circuit_imprinter
	name = "Circuit Imprinter (Machine Board)"
	build_path = /obj/machinery/r_n_d/circuit_imprinterrnd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/reagent_containers/glass/beaker = 2)

/obj/item/weapon/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer (Machine Board)"
	build_path = /obj/machinery/r_n_d/destructive_analyzerrnd
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1)

/obj/item/weapon/circuitboard/machine/experimentor
	name = "E.X.P.E.R.I-MENTOR (Machine Board)"
	build_path = /obj/machinery/r_n_d/experimentorrnd
	req_components = list(
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/weapon/stock_parts/micro_laser = 2)

/obj/item/weapon/circuitboard/machine/protolathe
	name = "Protolathe (Machine Board)"
	build_path = /obj/machinery/r_n_d/protolathernd
	req_components = list(
		/obj/item/weapon/stock_parts/matter_bin = 2,
		/obj/item/weapon/stock_parts/manipulator = 2,
		/obj/item/weapon/reagent_containers/glass/beaker = 2)

/obj/item/weapon/circuitboard/machine/rdserver
	name = "R&D Server (Machine Board)"
	build_path = /obj/machinery/r_n_d/serverrnd
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/item/weapon/circuitboard/machine/bsa/back
	name = "Bluespace Artillery Generator (Machine Board)"
	build_path = /obj/machinery/bsa/backrnd //No freebies!
	req_components = list(
		/obj/item/weapon/stock_parts/capacitor/quadratic = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/bsa/middle
	name = "Bluespace Artillery Fusor (Machine Board)"
	build_path = /obj/machinery/bsa/middlernd
	req_components = list(
		/obj/item/weapon/ore/bluespace_crystal = 20,
		/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/bsa/front
	name = "Bluespace Artillery Bore (Machine Board)"
	build_path = /obj/machinery/bsa/frontrnd
	req_components = list(
		/obj/item/weapon/stock_parts/manipulator/femto = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/dna_vault
	name = "DNA Vault (Machine Board)"
	build_path = /obj/machinery/dna_vaultrnd //No freebies!
	req_components = list(
		/obj/item/weapon/stock_parts/capacitor/super = 5,
		/obj/item/weapon/stock_parts/manipulator/pico = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/weapon/circuitboard/machine/microwave
	name = "Microwave (Machine Board)"
	build_path = /obj/machinery/microwavernd
	req_components = list(
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/weapon/stock_parts/console_screen = 1,
		/obj/item/stack/sheet/glass = 1)