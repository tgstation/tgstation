//Command

/obj/item/circuitboard/machine/bsa/back
	name = "Bluespace Artillery Generator"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/bsa/back //No freebies!
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/capacitor/tier4 = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	name = "Bluespace Artillery Bore"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/bsa/front
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/servo/tier4 = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	name = "Bluespace Artillery Fusor"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/bsa/middle
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 20,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/dna_vault
	name = "DNA Vault"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/dna_vault //No freebies!
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/capacitor/tier3 = 5,
		/datum/stock_part/servo/tier3 = 5,
		/obj/item/stack/cable_coil = 2)

//Engineering

/obj/item/circuitboard/machine/announcement_system
	name = "Announcement System"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/announcement_system
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/suit_storage_unit
	name = "Suit Storage Unit"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/suit_storage_unit
	req_components = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/capacitor = 1,
		/obj/item/electronics/airlock = 1)

/obj/item/circuitboard/machine/mass_driver
	name = "Mass Driver"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/mass_driver
	req_components = list(
		/datum/stock_part/servo = 1,)

/obj/item/circuitboard/machine/autolathe
	name = "Autolathe"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/autolathe
	req_components = list(
		/datum/stock_part/matter_bin = 3,
		/datum/stock_part/servo = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/grounding_rod
	name = "Grounding Rod"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/energy_accumulator/grounding_rod
	req_components = list(/datum/stock_part/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "Subspace Broadcaster"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/broadcaster
	req_components = list(
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/datum/stock_part/filter = 1,
		/datum/stock_part/crystal = 1,
		/datum/stock_part/micro_laser = 2,
	)

/obj/item/circuitboard/machine/telecomms/bus
	name = "Bus Mainframe"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/bus
	req_components = list(
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/datum/stock_part/filter = 1,
	)

/obj/item/circuitboard/machine/telecomms/hub
	name = "Hub Mainframe"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/hub
	req_components = list(
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/filter = 2,
	)

/obj/item/circuitboard/machine/telecomms/message_server
	name = "Messaging Server"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/message_server
	req_components = list(
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/datum/stock_part/filter = 3,
	)

/obj/item/circuitboard/machine/telecomms/processor
	name = "Processor Unit"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/processor
	req_components = list(
		/datum/stock_part/servo = 3,
		/datum/stock_part/filter = 1,
		/datum/stock_part/treatment = 2,
		/datum/stock_part/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/amplifier = 1,
	)

/obj/item/circuitboard/machine/telecomms/receiver
	name = "Subspace Receiver"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/receiver
	req_components = list(
		/datum/stock_part/ansible = 1,
		/datum/stock_part/filter = 1,
		/datum/stock_part/servo = 2,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/telecomms/relay
	name = "Relay Mainframe"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/relay
	req_components = list(
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/filter = 2,
	)

/obj/item/circuitboard/machine/telecomms/server
	name = "Telecommunication Server"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/telecomms/server
	req_components = list(
		/datum/stock_part/servo = 2,
		/obj/item/stack/cable_coil = 1,
		/datum/stock_part/filter = 1,
	)

/obj/item/circuitboard/machine/tesla_coil
	name = "Tesla Controller"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	desc = "Does not let you shoot lightning from your hands."
	build_path = /obj/machinery/power/energy_accumulator/tesla_coil
	req_components = list(/datum/stock_part/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/modular_shield_generator/gate
	name = "Modular Shield Gate"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield_generator/gate
	req_components = list(
		/datum/stock_part/servo = 1,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/capacitor = 1,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/modular_shield_generator
	name = "Modular Shield Generator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield_generator
	req_components = list(
		/datum/stock_part/servo = 1,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/capacitor = 1,
		/obj/item/stack/sheet/plasteel = 3,
	)

/obj/item/circuitboard/machine/modular_shield_node
	name = "Modular Shield Node"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield/module/node
	req_components = list(
		/obj/item/stack/cable_coil = 15,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/modular_shield_cable
	name = "Modular Shield Cable"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield/module/node/cable
	req_components = list(
		/obj/item/stack/sheet/plasteel = 1,
	)

/obj/item/circuitboard/machine/modular_shield_well
	name = "Modular Shield Well"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield/module/well
	req_components = list(
		/datum/stock_part/capacitor = 3,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/modular_shield_relay
	name = "Modular Shield Relay"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield/module/relay
	req_components = list(
		/datum/stock_part/micro_laser = 3,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/modular_shield_charger
	name = "Modular Shield Charger"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/modular_shield/module/charger
	req_components = list(
		/datum/stock_part/servo = 3,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/cell_charger
	name = "Cell Charger"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/cell_charger
	req_components = list(/datum/stock_part/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/circulator
	name = "Circulator/Heat Exchanger"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/binary/circulator
	req_components = list()

/obj/item/circuitboard/machine/emitter
	name = "Emitter"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/emitter
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/thermoelectric_generator
	name = "Thermo-Electric Generator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/thermoelectric_generator
	req_components = list()

/obj/item/circuitboard/machine/ntnet_relay
	name = "NTNet Relay"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/ntnet_relay
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/filter = 1,
	)

/obj/item/circuitboard/machine/pacman
	name = "PACMAN-type Generator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/port_gen/pacman
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5
	)
	needs_anchored = FALSE
	var/high_production_profile = FALSE

/obj/item/circuitboard/machine/pacman/examine(mob/user)
	. = ..()
	var/message = high_production_profile ? "high-power uranium mode" : "medium-power plasma mode"
	. += span_notice("It's set to [message].")
	. += span_notice("You can switch the mode by using a screwdriver on [src].")

/obj/item/circuitboard/machine/pacman/screwdriver_act(mob/living/user, obj/item/tool)
	high_production_profile = !high_production_profile
	var/message = high_production_profile ? "high-power uranium mode" : "medium-power plasma mode"
	to_chat(user, span_notice("You set the board for [message]"))

/obj/item/circuitboard/machine/turbine_compressor
	name = "Turbine - Inlet Compressor"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/turbine/inlet_compressor
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5)

/obj/item/circuitboard/machine/turbine_rotor
	name = "Turbine - Core Rotor"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/turbine/core_rotor
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5)

/obj/item/circuitboard/machine/turbine_stator
	name = "Turbine - Turbine Outlet"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/turbine/turbine_outlet
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5)

/obj/item/circuitboard/machine/protolathe/department/engineering
	name = "Departmental Protolathe - Engineering"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/rnd/production/protolathe/department/engineering

/obj/item/circuitboard/machine/rtg
	name = "RTG"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/rtg
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10) // We have no Pu-238, and this is the closest thing to it.

/obj/item/circuitboard/machine/rtg/advanced
	name = "Advanced RTG"
	build_path = /obj/machinery/power/rtg/advanced
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5)

/obj/item/circuitboard/machine/scanner_gate
	name = "Scanner Gate"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/scanner_gate
	req_components = list(
		/datum/stock_part/scanning_module = 3)

/obj/item/circuitboard/machine/smes
	name = "SMES"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/smes
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/power_store/battery = 5,
		/datum/stock_part/capacitor = 1)
	def_components = list(/obj/item/stock_parts/power_store/battery = /obj/item/stock_parts/power_store/battery/high/empty)

/obj/item/circuitboard/machine/smes/connector
	name = "power connector"
	build_path = /obj/machinery/power/smes/connector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/capacitor = 1,)

/obj/item/circuitboard/machine/smesbank
	name = "portable SMES"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	needs_anchored = FALSE
	build_path = /obj/machinery/smesbank
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/power_store/battery = 5,)
	def_components = list(/obj/item/stock_parts/power_store/battery = /obj/item/stock_parts/power_store/battery/high/empty)

/obj/item/circuitboard/machine/techfab/department/engineering
	name = "\improper Departmental Techfab - Engineering"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/rnd/production/techfab/department/engineering

/obj/item/circuitboard/machine/smes/super
	def_components = list(/obj/item/stock_parts/power_store/battery = /obj/item/stock_parts/power_store/battery/super/empty)

/obj/item/circuitboard/machine/smesbank/super
	def_components = list(/obj/item/stock_parts/power_store/battery = /obj/item/stock_parts/power_store/battery/super/empty)

/obj/item/circuitboard/machine/thermomachine
	name = "Thermomachine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer
	var/pipe_layer = PIPING_LAYER_DEFAULT
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/micro_laser = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/thermomachine/multitool_act(mob/living/user, obj/item/multitool/multitool)
	. = ..()
	pipe_layer = (pipe_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (pipe_layer + 1)
	to_chat(user, span_notice("You change the circuitboard to layer [pipe_layer]."))

/obj/item/circuitboard/machine/thermomachine/examine()
	. = ..()
	. += span_notice("It is set to layer [pipe_layer].")

/obj/item/circuitboard/machine/HFR_fuel_input
	name = "HFR Fuel Input"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_waste_output
	name = "HFR Waste Output"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/waste_output
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_moderator_input
	name = "HFR Moderator Input"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/moderator_input
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_core
	name = "HFR core"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/core
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 10)

/obj/item/circuitboard/machine/HFR_corner
	name = "HFR Corner"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/hypertorus/corner
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_interface
	name = "HFR Interface"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/hypertorus/interface
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/crystallizer
	name = "Crystallizer"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmospherics/components/binary/crystallizer
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 5)

//Generic
/obj/item/circuitboard/machine/component_printer
	name = "\improper Component Printer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/component_printer
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
	)

/obj/item/circuitboard/machine/module_duplicator
	name = "\improper Module Duplicator"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/module_duplicator
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
	)

/obj/item/circuitboard/machine/circuit_imprinter
	name = "Circuit Imprinter"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/rnd/production/circuit_imprinter
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1,
		)

/obj/item/circuitboard/machine/circuit_imprinter/offstation
	name = "Ancient Circuit Imprinter"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/offstation

/obj/item/circuitboard/machine/circuit_imprinter/department
	name = "Departmental Circuit Imprinter"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department

/obj/item/circuitboard/machine/holopad
	name = "AI Holopad"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/holopad
	req_components = list(/datum/stock_part/capacitor = 1)
	needs_anchored = FALSE //wew lad
	var/secure = FALSE

/obj/item/circuitboard/machine/holopad/multitool_act(mob/living/user, obj/item/tool)
	if(secure)
		build_path = /obj/machinery/holopad
		secure = FALSE
	else
		build_path = /obj/machinery/holopad/secure
		secure = TRUE
	to_chat(user, span_notice("You [secure? "en" : "dis"]able the security on [src]"))
	return TRUE

/obj/item/circuitboard/machine/holopad/examine(mob/user)
	. = ..()
	. += "There is a connection port on this board that could be <b>pulsed</b>"
	if(secure)
		. += "There is a red light flashing next to the word \"secure\""

/obj/item/circuitboard/machine/launchpad
	name = "Bluespace Launchpad"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/launchpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/datum/stock_part/servo = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/protolathe
	name = "Protolathe"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/rnd/production/protolathe
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
		)

/obj/item/circuitboard/machine/protolathe/offstation
	name = "Ancient Protolathe"
	build_path = /obj/machinery/rnd/production/protolathe/offstation

/obj/item/circuitboard/machine/protolathe/department
	name = "Departmental Protolathe"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/rnd/production/protolathe/department

/obj/item/circuitboard/machine/reagentgrinder
	name = "All-In-One Grinder"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/reagentgrinder
	req_components = list(
		/datum/stock_part/servo = 1,
		/datum/stock_part/matter_bin = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/smartfridge
	name = "Smartfridge"
	build_path = /obj/machinery/smartfridge
	req_components = list(/datum/stock_part/matter_bin = 1)
	var/static/list/fridges_name_paths = list(/obj/machinery/smartfridge = "plant produce",
		/obj/machinery/smartfridge/food = "food",
		/obj/machinery/smartfridge/drinks = "drinks",
		/obj/machinery/smartfridge/extract = "slimes",
		/obj/machinery/smartfridge/petri = "petri",
		/obj/machinery/smartfridge/organ = "organs",
		/obj/machinery/smartfridge/chemistry = "chems",
		/obj/machinery/smartfridge/chemistry/virology = "viruses",
		/obj/machinery/smartfridge/disks = "disks")
	needs_anchored = FALSE
	var/is_special_type = FALSE

/obj/item/circuitboard/machine/smartfridge/apply_default_parts(obj/machinery/smartfridge/smartfridge)
	build_path = smartfridge.base_build_path
	if(!fridges_name_paths.Find(build_path))
		name = "[initial(smartfridge.name)]" //if it's a unique type, give it a unique name.
		is_special_type = TRUE
	return ..()

/obj/item/circuitboard/machine/smartfridge/screwdriver_act(mob/living/user, obj/item/tool)
	if (is_special_type)
		return FALSE
	var/position = fridges_name_paths.Find(build_path, fridges_name_paths)
	position = (position == length(fridges_name_paths)) ? 1 : (position + 1)
	build_path = fridges_name_paths[position]
	to_chat(user, span_notice("You set the board to [fridges_name_paths[build_path]]."))
	return TRUE

/obj/item/circuitboard/machine/smartfridge/examine(mob/user)
	. = ..()
	if(is_special_type)
		return
	. += span_info("[src] is set to [fridges_name_paths[build_path]]. You can use a screwdriver to reconfigure it.")

/obj/item/circuitboard/machine/dehydrator
	name = "Dehydrator"
	build_path = /obj/machinery/smartfridge/drying
	req_components = list(/datum/stock_part/matter_bin = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/space_heater
	name = "Space Heater"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/space_heater
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/capacitor = 1,
		/obj/item/stack/cable_coil = 3)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/electrolyzer
	name = "Electrolyzer"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/electrolyzer
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/capacitor = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/glass = 1)

	needs_anchored = FALSE


/obj/item/circuitboard/machine/techfab
	name = "\improper Techfab"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/rnd/production/techfab
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 2,
		)

/obj/item/circuitboard/machine/techfab/department
	name = "\improper Departmental Techfab"
	build_path = /obj/machinery/rnd/production/techfab/department

/obj/item/circuitboard/machine/vendor
	name = "Custom Vendor"
	desc = "You can turn the \"brand selection\" dial using a screwdriver."
	custom_premium_price = PAYCHECK_CREW * 1.5
	build_path = /obj/machinery/vending/custom
	req_components = list(/obj/item/vending_refill/custom = 1)

	///Assoc list (machine name = machine typepath) of all vendors that can be chosen when the circuit is screwdrivered
	var/static/list/valid_vendor_names_paths

/obj/item/circuitboard/machine/vendor/Initialize(mapload)
	. = ..()
	if(!valid_vendor_names_paths)
		valid_vendor_names_paths = list()
		for(var/obj/machinery/vending/vendor_type as anything in subtypesof(/obj/machinery/vending))
			if(vendor_type::allow_custom)
				valid_vendor_names_paths[vendor_type::name] = vendor_type

/obj/item/circuitboard/machine/vendor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_FAILURE
	var/choice = tgui_input_list(user, "Choose a new brand", "Select an Item", sort_list(valid_vendor_names_paths))
	if(isnull(choice))
		return
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	set_type(valid_vendor_names_paths[choice])
	return ITEM_INTERACT_SUCCESS

/**
 * Sets circuitboard details based on the vending machine type to create
 *
 * Arguments
 * * obj/machinery/vending/typepath - the vending machine type to create
*/
/obj/item/circuitboard/machine/vendor/proc/set_type(obj/machinery/vending/typepath)
	build_path = typepath
	name = "[typepath::name] Vendor"
	req_components = list(initial(typepath.refill_canister) = 1)
	flatpack_components = list(initial(typepath.refill_canister))

/obj/item/circuitboard/machine/vendor/apply_default_parts(obj/machinery/machine)
	set_type(machine.type)
	return ..()

/obj/item/circuitboard/machine/vending/donksofttoyvendor
	name = "Donksoft Toy Vendor"
	build_path = /obj/machinery/vending/donksofttoyvendor
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1)

/obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	name = "Syndicate Donksoft Toy Vendor"
	build_path = /obj/machinery/vending/toyliberationstation
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1)

/obj/item/circuitboard/machine/vending/donksnackvendor
	name = "Donk Co Snack Vendor"
	build_path = /obj/machinery/vending/donksnack
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksnackvendor = 1)

/obj/item/circuitboard/machine/bountypad
	name = "Civilian Bounty Pad"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/piratepad/civilian
	req_components = list(
		/datum/stock_part/card_reader = 1,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/micro_laser = 1
	)

/obj/item/circuitboard/machine/fax
	name = "Fax Machine"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/fax
	req_components = list(
		/datum/stock_part/crystal = 1,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/servo = 1,)

/obj/item/circuitboard/machine/bookbinder
	name = "Book Binder"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/bookbinder
	req_components = list(
		/datum/stock_part/servo = 1,
	)

/obj/item/circuitboard/machine/libraryscanner
	name = "Book Scanner"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/libraryscanner
	req_components = list(
		/datum/stock_part/scanning_module = 1,
	)

/obj/item/circuitboard/machine/photocopier
	name = "Photocopier"
	greyscale_colors = CIRCUIT_COLOR_GENERIC
	build_path = /obj/machinery/photocopier
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/matter_bin = 1
	)

//Medical

/obj/item/circuitboard/machine/chem_dispenser
	name = "Chem Dispenser"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/chem_dispenser
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/servo = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/power_store/cell = 1)
	def_components = list(/obj/item/stock_parts/power_store/cell = /obj/item/stock_parts/power_store/cell/high)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_dispenser/fullupgrade
	build_path = /obj/machinery/chem_dispenser/fullupgrade
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 2,
		/datum/stock_part/capacitor/tier4 = 2,
		/datum/stock_part/servo/tier4 = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/power_store/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/mutagensaltpeter
	build_path = /obj/machinery/chem_dispenser/mutagensaltpeter
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 2,
		/datum/stock_part/capacitor/tier4 = 2,
		/datum/stock_part/servo/tier4 = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/power_store/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/abductor
	name = "Reagent Synthesizer"
	name_extension = "(Abductor Machine Board)"
	icon_state = "abductor_mod"
	build_path = /obj/machinery/chem_dispenser/abductor
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 2,
		/datum/stock_part/capacitor/tier4 = 2,
		/datum/stock_part/servo/tier4 = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/power_store/cell/bluespace = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_heater
	name = "Chemical Heater"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/chem_heater
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/chem_mass_spec
	name = "High-Performance Liquid Chromatography Machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/chem_mass_spec
	req_components = list(
	/datum/stock_part/micro_laser = 1,
	/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/machine/chem_master
	name = "ChemMaster 3000"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/chem_master
	desc = "You can turn the \"mode selection\" dial using a screwdriver."
	req_components = list(
		/obj/item/reagent_containers/cup/beaker = 2,
		/datum/stock_part/servo = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_master/screwdriver_act(mob/living/user, obj/item/tool)
	var/new_name = "ChemMaster"
	var/new_path = /obj/machinery/chem_master

	if(build_path == /obj/machinery/chem_master)
		new_name = "CondiMaster"
		new_path = /obj/machinery/chem_master/condimaster

	build_path = new_path
	name = "[new_name] 3000"
	to_chat(user, span_notice("You change the circuit board setting to \"[new_name]\"."))
	return TRUE

/obj/item/circuitboard/machine/cryo_tube
	name = "Cryotube"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/cryo_cell
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 4)

/obj/item/circuitboard/machine/fat_sucker
	name = "Lipid Extractor"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/fat_sucker
	req_components = list(/datum/stock_part/micro_laser = 1,
		/obj/item/kitchen/fork = 1)

/obj/item/circuitboard/machine/harvester
	name = "Harvester"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/harvester
	req_components = list(/datum/stock_part/micro_laser = 4)

/obj/item/circuitboard/machine/medical_kiosk
	name = "Medical Kiosk"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/medical_kiosk
	var/custom_cost = 10
	req_components = list(
		/obj/item/healthanalyzer = 1,
		/datum/stock_part/scanning_module = 1)

/obj/item/circuitboard/machine/medical_kiosk/multitool_act(mob/living/user)
	. = ..()
	var/new_cost = tgui_input_number(user, "New cost for using this medical kiosk", "Pricing", custom_cost, 1000, 10)
	if(!new_cost || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if(loc != user)
		to_chat(user, span_warning("You must hold the circuitboard to change its cost!"))
		return
	custom_cost = new_cost
	to_chat(user, span_notice("The cost is now set to [custom_cost]."))

/obj/item/circuitboard/machine/medical_kiosk/examine(mob/user)
	. = ..()
	. += "The cost to use this kiosk is set to [custom_cost]."

/obj/item/circuitboard/machine/limbgrower
	name = "Limb Grower"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/limbgrower
	req_components = list(
		/datum/stock_part/servo = 1,
		/obj/item/reagent_containers/cup/beaker = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/limbgrower/fullupgrade
	name = "Limb Grower"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/limbgrower
	req_components = list(
		/datum/stock_part/servo/tier4  = 1,
		/obj/item/reagent_containers/cup/beaker/bluespace = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/protolathe/department/medical
	name = "Departmental Protolathe - Medical"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/rnd/production/protolathe/department/medical

/obj/item/circuitboard/machine/sleeper
	name = "Sleeper"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/sleeper
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/sleeper/syndie
	build_path = /obj/machinery/sleeper/syndie

/obj/item/circuitboard/machine/sleeper/fullupgrade
	build_path = /obj/machinery/sleeper/syndie/fullupgrade
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 1,
		/datum/stock_part/servo/tier4 = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/sleeper/party
	name = "Party Pod"
	build_path = /obj/machinery/sleeper/party

/obj/item/circuitboard/machine/smoke_machine
	name = "Smoke Machine"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/smoke_machine
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/servo = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/stasis
	name = "\improper Lifeform Stasis Unit"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/stasis
	req_components = list(
		/obj/item/stack/cable_coil = 3,
		/datum/stock_part/servo = 1,
		/datum/stock_part/capacitor = 1)

/obj/item/circuitboard/machine/medipen_refiller
	name = "Medipen Refiller"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/medipen_refiller
	req_components = list(
		/datum/stock_part/matter_bin = 1)

/obj/item/circuitboard/machine/techfab/department/medical
	name = "\improper Departmental Techfab - Medical"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/rnd/production/techfab/department/medical

//Science

/obj/item/circuitboard/machine/circuit_imprinter/department/science
	name = "Departmental Circuit Imprinter - Science"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department/science

/obj/item/circuitboard/machine/cyborgrecharger
	name = "Cyborg Recharger"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/recharge_station
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/obj/item/stock_parts/power_store/cell = 1,
		/datum/stock_part/servo = 1)
	def_components = list(/obj/item/stock_parts/power_store/cell = /obj/item/stock_parts/power_store/cell/high)

/obj/item/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/servo = 1,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/rnd/experimentor
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/servo = 2,
		/datum/stock_part/micro_laser = 2)

/obj/item/circuitboard/machine/mech_recharger
	name = "Mechbay Recharger"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/mech_bay_recharge_port
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/capacitor = 5)

/obj/item/circuitboard/machine/mechfab
	name = "Exosuit Fabricator"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/mecha_part_fabricator
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/vatgrower
	name = "Growing Vat"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/vatgrower

/obj/item/circuitboard/machine/monkey_recycler
	name = "Monkey Recycler"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/monkey_recycler
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/processor/slime
	name = "Slime Processor"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/processor/slime

/obj/item/circuitboard/machine/processor/slime/fullupgrade
	build_path = /obj/machinery/processor/slime/fullupgrade
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 1,
		/datum/stock_part/servo/tier4 = 1,
	)

/obj/item/circuitboard/machine/protolathe/department/science
	name = "Departmental Protolathe - Science"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/rnd/production/protolathe/department/science

/obj/item/circuitboard/machine/quantumpad
	name = "Quantum Pad"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/quantumpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/servo = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/rdserver
	name = "R&D Server"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/rnd/server
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/datum/stock_part/scanning_module = 1,
	)

/obj/item/circuitboard/machine/rdserver/oldstation
	name = "Ancient R&D Server"
	build_path = /obj/machinery/rnd/server/oldstation

/obj/item/circuitboard/machine/techfab/department/science
	name = "\improper Departmental Techfab - Science"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/rnd/production/techfab/department/science

/obj/item/circuitboard/machine/teleporter_hub
	name = "Teleporter Hub"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/teleport/hub
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/datum/stock_part/matter_bin = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/teleporter_station
	name = "Teleporter Station"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/teleport/station
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/datum/stock_part/capacitor = 2,
		/obj/item/stack/sheet/glass = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/dnascanner
	name = "DNA Scanner"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)


/obj/item/circuitboard/machine/dna_infuser
	name = "DNA Infuser"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/dna_infuser
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/machine/experimental_cloner_scanner
	name = "Experimental Cloning Scanner"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/experimental_cloner_scanner
	req_components = list(
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2
	)

/obj/item/circuitboard/machine/experimental_cloner
	name = "Experimental Cloning Pod"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/experimental_cloner
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 4
	)

/obj/item/circuitboard/machine/mechpad
	name = "Mecha Orbital Pad"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/mechpad
	req_components = list()

/obj/item/circuitboard/machine/botpad
	name = "Bot launchpad"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/botpad
	req_components = list()

//Security

/obj/item/circuitboard/machine/protolathe/department/security
	name = "Departmental Protolathe - Security"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/rnd/production/protolathe/department/security

/obj/item/circuitboard/machine/recharger
	name = "Weapon Recharger"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/recharger
	req_components = list(/datum/stock_part/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/security
	name = "\improper Departmental Techfab - Security"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/rnd/production/techfab/department/security

//Service
/obj/item/circuitboard/machine/photobooth
	name = "Photobooth"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/photobooth
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1,
	)

/obj/item/circuitboard/machine/photobooth/security
	name = "Security Photobooth"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/photobooth/security

/obj/item/circuitboard/machine/biogenerator
	name = "Biogenerator"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/biogenerator
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/chem_dispenser/drinks
	name = "Soda Dispenser"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_dispenser/drinks

/obj/item/circuitboard/machine/chem_dispenser/drinks/fullupgrade
	build_path = /obj/machinery/chem_dispenser/drinks/fullupgrade
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 2,
		/datum/stock_part/capacitor/tier4 = 2,
		/datum/stock_part/servo/tier4 = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/power_store/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	name = "Booze Dispenser"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_dispenser/drinks/beer

/obj/item/circuitboard/machine/chem_dispenser/drinks/beer/fullupgrade
	build_path = /obj/machinery/chem_dispenser/drinks/beer/fullupgrade
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 2,
		/datum/stock_part/capacitor/tier4 = 2,
		/datum/stock_part/servo/tier4 = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/power_store/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_master/condi
	name = "CondiMaster 3000"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/machine/deep_fryer
	name = "Deep Fryer"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/deepfryer
	req_components = list(/datum/stock_part/micro_laser = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/griddle
	name = "Griddle"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/griddle
	req_components = list(/datum/stock_part/micro_laser = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/oven
	name = "Oven"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/oven
	req_components = list(/datum/stock_part/micro_laser = 1)
	needs_anchored = TRUE

/obj/item/circuitboard/machine/stove
	name = "Stove"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/stove
	req_components = list(/datum/stock_part/micro_laser = 1)
	needs_anchored = TRUE

/obj/item/circuitboard/machine/range
	name = "Range (Oven & Stove)"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/oven/range
	req_components = list(/datum/stock_part/micro_laser = 2)
	needs_anchored = TRUE

/obj/item/circuitboard/machine/dish_drive
	name = "Dish Drive"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/dish_drive
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/datum/stock_part/servo = 1,
		/datum/stock_part/matter_bin = 2)
	var/suction = TRUE
	var/transmit = TRUE
	needs_anchored = FALSE

/obj/item/circuitboard/machine/dish_drive/examine(mob/user)
	. = ..()
	. += span_notice("Its suction function is [suction ? "enabled" : "disabled"]. Use it in-hand to switch.")
	. += span_notice("Its disposal auto-transmit function is [transmit ? "enabled" : "disabled"]. Alt-click it to switch.")

/obj/item/circuitboard/machine/dish_drive/attack_self(mob/living/user)
	suction = !suction
	to_chat(user, span_notice("You [suction ? "enable" : "disable"] the board's suction function."))

/obj/item/circuitboard/machine/dish_drive/click_alt(mob/living/user)
	transmit = !transmit
	to_chat(user, span_notice("You [transmit ? "enable" : "disable"] the board's automatic disposal transmission."))
	return CLICK_ACTION_SUCCESS

/obj/item/circuitboard/machine/gibber
	name = "Gibber"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/gibber
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/hydroponics
	name = "Hydroponics Tray"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/hydroponics/constructable
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/servo = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/hydroponics/fullupgrade
	build_path = /obj/machinery/hydroponics/constructable/fullupgrade
	specific_parts = TRUE
	req_components = list(
		/datum/stock_part/matter_bin/tier4 = 2,
		/datum/stock_part/servo/tier4 = 1,
		/obj/item/stack/sheet/glass = 1
	)

/obj/item/circuitboard/machine/microwave
	name = "Microwave"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/microwave
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/capacitor = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/microwave/engineering
	name = "Wireless Microwave Oven"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/microwave/engineering
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/capacitor/tier2 = 1,
		/obj/item/stack/cable_coil = 4,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/processor
	name = "Food Processor"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/processor
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/processor/screwdriver_act(mob/living/user, obj/item/tool)
	if(build_path == /obj/machinery/processor)
		name = "Slime Processor"
		build_path = /obj/machinery/processor/slime
		to_chat(user, span_notice("Name protocols successfully updated."))
	else
		name = "Food Processor"
		build_path = /obj/machinery/processor
		to_chat(user, span_notice("Defaulting name protocols."))
	return TRUE

/obj/item/circuitboard/machine/protolathe/department/service
	name = "Departmental Protolathe - Service"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/rnd/production/protolathe/department/service

/obj/item/circuitboard/machine/recycler
	name = "Recycler"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/recycler
	req_components = list(
		/datum/stock_part/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/seed_extractor
	name = "Seed Extractor"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/seed_extractor
	req_components = list(
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/service
	name = "\improper Departmental Techfab - Service"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/rnd/production/techfab/department/service

/obj/item/circuitboard/machine/vendatray
	name = "Vend-A-Tray"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/structure/displaycase/forsale
	req_components = list(
		/datum/stock_part/card_reader = 1)

/obj/item/circuitboard/machine/fishing_portal_generator
	name = "Fishing Portal Generator"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/fishing_portal_generator
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/fishing_portal_generator/emagged
	name = "Emagged Fishing Portal Generator"
	build_path = /obj/machinery/fishing_portal_generator/emagged

//Supply
/obj/item/circuitboard/machine/ore_redemption
	name = "Ore Redemption"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/mineral/ore_redemption
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/servo = 1,
		/obj/item/assembly/igniter = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ore_redemption/offstation
	build_path = /obj/machinery/mineral/ore_redemption/offstation

/obj/item/circuitboard/machine/ore_silo
	name = "Ore Silo"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/ore_silo
	req_components = list()

/obj/item/circuitboard/machine/protolathe/department/cargo
	name = "Departmental Protolathe - Cargo"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/rnd/production/protolathe/department/cargo

/obj/item/circuitboard/machine/stacking_machine
	name = "Stacking Machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/mineral/stacking_machine
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/matter_bin = 2)

/obj/item/circuitboard/machine/stacking_unit_console
	name = "Stacking Machine Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/mineral/stacking_unit_console
	req_components = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/machine/techfab/department/cargo
	name = "\improper Departmental Techfab - Cargo"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/rnd/production/techfab/department/cargo

/obj/item/circuitboard/machine/materials_market
	name = "Galactic Materials Market"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/materials_market
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/card_reader = 1)

/obj/item/circuitboard/machine/mailsorter
	name = "Mail Sorter"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/mailsorter
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/scanning_module = 1)
	needs_anchored = TRUE

//Tram
/obj/item/circuitboard/machine/crossing_signal
	name = "Crossing Signal"
	build_path = /obj/machinery/transport/crossing_signal
	req_components = list(
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/guideway_sensor
	name = "Guideway Sensor"
	build_path = /obj/machinery/transport/guideway_sensor
	req_components = list(
		/obj/item/assembly/prox_sensor = 1,
	)

//Misc
/obj/item/circuitboard/machine/sheetifier
	name = "Sheet-meister 2000"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/sheetifier
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/matter_bin = 2)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/restaurant_portal
	name = "Restaurant Portal"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/restaurant_portal
	req_components = list(
		/datum/stock_part/scanning_module = 2,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = TRUE
	/// Type of the venue that we're linked to
	var/venue_type = /datum/venue/restaurant

/obj/item/circuitboard/machine/restaurant_portal/multitool_act(mob/living/user)
	var/list/radial_items = list()
	var/list/radial_results = list()

	for(var/type_key in SSrestaurant.all_venues)
		var/datum/venue/venue = SSrestaurant.all_venues[type_key]
		radial_items[venue.name] = image('icons/obj/machines/restaurant_portal.dmi', venue.name)
		radial_results[venue.name] = type_key

	var/choice = show_radial_menu(user, src, radial_items, null, require_near = TRUE)

	if(!choice)
		return ITEM_INTERACT_BLOCKING

	venue_type = radial_results[choice]
	to_chat(user, span_notice("You change [src]'s linked venue."))
	return ITEM_INTERACT_SUCCESS

/obj/item/circuitboard/machine/restaurant_portal/examine(mob/user)
	. = ..()
	if (venue_type)
		var/datum/venue/as_venue = venue_type
		. += span_notice("[src] is linked to \a [initial(as_venue.name)] venue.")

/obj/item/circuitboard/machine/restaurant_portal/configure_machine(obj/machinery/restaurant_portal/machine)
	if(!istype(machine))
		CRASH("Cargo board attempted to configure incorrect machine type: [machine] ([machine?.type])")
	machine.linked_venue = SSrestaurant.all_venues[venue_type]
	machine.linked_venue.restaurant_portals += machine

/obj/item/circuitboard/machine/abductor
	name = "alien board (Report This)"
	icon_state = "abductor_mod"

/obj/item/circuitboard/machine/abductor/core
	name = "alien board"
	name_extension = "(Void Core)"
	build_path = /obj/machinery/power/rtg/abductor
	req_components = list(
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/micro_laser = 1,
		/obj/item/stock_parts/power_store/cell/infinite/abductor = 1)
	def_components = list(
		/datum/stock_part/capacitor = /datum/stock_part/capacitor/tier4,
		/datum/stock_part/micro_laser = /datum/stock_part/micro_laser/tier4)

/obj/item/circuitboard/machine/hypnochair
	name = "Enhanced Interrogation Chamber"
	greyscale_colors = CIRCUIT_COLOR_SECURITY
	build_path = /obj/machinery/hypnochair
	req_components = list(
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/scanning_module = 2
	)

/obj/item/circuitboard/machine/plumbing_receiver
	name = "Chemical Recipient"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/plumbing/receiver
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/datum/stock_part/capacitor = 2,
		/obj/item/stack/sheet/glass = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/skill_station
	name = "Skill Station"
	build_path = /obj/machinery/skill_station
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/scanning_module = 2
	)

/obj/item/circuitboard/machine/destructive_scanner
	name = "Experimental Destructive Scanner"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/destructive_scanner
	req_components = list(
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/servo = 2)

/obj/item/circuitboard/machine/doppler_array
	name = "Tachyon-Doppler Research Array"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/doppler_array
	req_components = list(
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/scanning_module = 4)

/obj/item/circuitboard/machine/exoscanner
	name = "Exoscanner"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/exoscanner
	req_components = list(
		/datum/stock_part/micro_laser = 4,
		/datum/stock_part/scanning_module = 4)

/obj/item/circuitboard/machine/exodrone_launcher
	name = "Exploration Drone Launcher"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/exodrone_launcher
	req_components = list(
		/datum/stock_part/micro_laser = 4,
		/datum/stock_part/scanning_module = 4)

/obj/item/circuitboard/machine/ecto_sniffer
	name = "Ectoscopic Sniffer"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/ecto_sniffer
	req_components = list(
		/datum/stock_part/scanning_module = 1)

/obj/item/circuitboard/machine/anomaly_refinery
	name = "Anomaly Refinery"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/research/anomaly_refinery
	req_components = list(
		/obj/item/stack/sheet/plasteel = 15,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/servo = 1,
		)

/obj/item/circuitboard/machine/tank_compressor
	name = "Tank Compressor"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/atmospherics/components/binary/tank_compressor
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5,
		/datum/stock_part/scanning_module = 4,
		)

/obj/item/circuitboard/machine/coffeemaker
	name = "Coffeemaker"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/coffeemaker
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/cup/beaker = 2,
		/datum/stock_part/water_recycler = 1,
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/coffeemaker/impressa
	name = "Impressa Coffeemaker"
	greyscale_colors = CIRCUIT_COLOR_SERVICE
	build_path = /obj/machinery/coffeemaker/impressa
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/cup/beaker = 2,
		/datum/stock_part/water_recycler = 1,
		/datum/stock_part/capacitor/tier2 = 1,
		/datum/stock_part/micro_laser/tier2 = 2,
	)

/obj/item/circuitboard/machine/navbeacon
	name = "Bot Navigational Beacon"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/navbeacon
	req_components = list()

/obj/item/circuitboard/machine/radioactive_nebula_shielding
	name = "Radioactive Nebula Shielding"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/nebula_shielding/radiation
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/obj/item/mod/module/rad_protection = 1,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/brm
	name = "Boulder Retrieval Matrix"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/brm
	req_components = list(
		/datum/stock_part/capacitor = 1,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/refinery
	name = "Boulder Refinery"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/bouldertech/refinery
	req_components = list(
		/obj/item/assembly/igniter/condenser = 1,
		/datum/stock_part/servo = 2,
		/datum/stock_part/matter_bin = 2,
	)

/obj/item/circuitboard/machine/smelter
	name = "Boulder Smelter"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/bouldertech/refinery/smelter
	req_components = list(
		/obj/item/assembly/igniter = 1,
		/datum/stock_part/servo = 2,
		/datum/stock_part/matter_bin = 2,
	)

/obj/item/circuitboard/machine/shieldwallgen
	name = "Shield Wall Generator"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/power/shieldwallgen
	req_components = list(
		/datum/stock_part/capacitor/tier2 = 2,
		/datum/stock_part/micro_laser/tier2 = 2,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/flatpacker
	name = "Flatpacker"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/flatpacker
	req_components = list(
		/datum/stock_part/matter_bin = 2,
		/datum/stock_part/micro_laser = 2,
		/datum/stock_part/servo = 1,
		/obj/item/stack/sheet/plasteel = 5,
	)

/obj/item/circuitboard/machine/scrubber
	name = "Portable Air Scrubber"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/portable_atmospherics/scrubber
	needs_anchored = FALSE
	req_components = list(
		/obj/item/pipe/directional/scrubber = 1,
	)

/obj/item/circuitboard/machine/pump
	name = "Portable Air Pump"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/portable_atmospherics/pump
	needs_anchored = FALSE
	req_components = list(
		/obj/item/pipe/directional/vent = 1,
	)

/obj/item/circuitboard/machine/pipe_scrubber
	name = "Portable Pipe Scrubber"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/portable_atmospherics/pipe_scrubber
	needs_anchored = FALSE
	req_components = list(
		/obj/item/pipe/trinary/flippable/filter = 1,
	)

/obj/item/circuitboard/machine/portagrav
	name = "Portable Gravity Unit"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/portagrav
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/datum/stock_part/micro_laser = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/big_manipulator
	name = "Big Manipulator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/big_manipulator
	req_components = list(
		/datum/stock_part/servo = 1,
		)

/obj/item/circuitboard/machine/manucrafter
	name = /obj/machinery/power/manufacturing/crafter::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/crafter
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
		/datum/stock_part/servo = 1,
	)

/obj/item/circuitboard/machine/manulathe
	name = /obj/machinery/power/manufacturing/lathe::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/lathe
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
		/datum/stock_part/matter_bin = 1,
	)

/obj/item/circuitboard/machine/manucrusher
	name = /obj/machinery/power/manufacturing/crusher::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/crusher
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
		/datum/stock_part/servo = 1,
	)

/obj/item/circuitboard/machine/manuunloader
	name = /obj/machinery/power/manufacturing/unloader::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/unloader
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
		/datum/stock_part/servo = 1,
	)

/obj/item/circuitboard/machine/manusorter
	name = /obj/machinery/power/manufacturing/sorter::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/sorter
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
		/datum/stock_part/scanning_module = 1,
	)

/obj/item/circuitboard/machine/manusmelter
	name = /obj/machinery/power/manufacturing/smelter::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/smelter
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
		/datum/stock_part/micro_laser = 1,
	)

/obj/item/circuitboard/machine/manurouter
	name = /obj/machinery/power/manufacturing/router::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/manufacturing/router
	req_components = list(
		/obj/item/stack/sheet/iron = 5,
	)

/obj/item/circuitboard/machine/atmos_shield_gen
	name = /obj/machinery/atmos_shield_gen::name
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/atmos_shield_gen
	req_components = list(
		/datum/stock_part/micro_laser = 1,
		/datum/stock_part/capacitor = 1,
	)

/obj/item/circuitboard/machine/engine
	name = "Shuttle Engine"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/shuttle_engine
	needs_anchored = FALSE
	req_components = list(
		/datum/stock_part/capacitor = 2,
		/datum/stock_part/micro_laser = 2,
	)

/obj/item/circuitboard/machine/engine/heater
	name = "Shuttle Engine Heater"
	build_path = /obj/machinery/power/shuttle_engine/heater

/obj/item/circuitboard/machine/engine/propulsion
	name = "Shuttle Engine Propulsion"
	build_path = /obj/machinery/power/shuttle_engine/propulsion

/obj/item/circuitboard/machine/quantum_server
	name = "Quantum Server"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/quantum_server
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/scanning_module = 1,
		/datum/stock_part/capacitor = 1,
	)

/obj/item/circuitboard/machine/netpod
	name = "Netpod"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/netpod
	req_components = list(
		/datum/stock_part/servo = 1,
		/datum/stock_part/matter_bin = 2,
	)

/obj/item/circuitboard/computer/quantum_console
	name = "Quantum Console"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/quantum_console

/obj/item/circuitboard/machine/byteforge
	name = "Byteforge"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/byteforge
	req_components = list(
		/datum/stock_part/micro_laser = 1,
	)
