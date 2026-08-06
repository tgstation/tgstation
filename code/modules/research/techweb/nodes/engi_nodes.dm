// Parts root node
/datum/techweb_node/parts
	display_name = "Essential Stock Parts"
	description = "Foundational components that form the backbone of station operations, encompassing a range of essential equipment necessary for day-to-day functionality."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/micro_servo,
		/datum/design/basic_battery,
		/datum/design/basic_capacitor,
		/datum/design/basic_cell,
		/datum/design/basic_matter_bin,
		/datum/design/basic_micro_laser,
		/datum/design/basic_scanning,
		/datum/design/high_battery,
		/datum/design/high_cell,
		/datum/design/miniature_power_cell,
		/datum/design/condenser,
		/datum/design/igniter,
		/datum/design/infrared_emitter,
		/datum/design/prox_sensor,
		/datum/design/signaler,
		/datum/design/timer,
		/datum/design/voice_analyzer,
		/datum/design/health_sensor,
		/datum/design/synthetic_flash,
	)

/datum/techweb_node/parts_upg
	display_name = "Upgraded Parts"
	description = "Offering enhanced capabilities beyond their basic counterparts."
	prerequisite_nodes = list(/datum/techweb_node/parts, /datum/techweb_node/energy_manipulation)
	unlocked_designs = list(
		/datum/design/rped,
		/datum/design/high_micro_laser,
		/datum/design/adv_capacitor,
		/datum/design/nano_servo,
		/datum/design/adv_matter_bin,
		/datum/design/adv_scanning,
		/datum/design/super_battery,
		/datum/design/super_cell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/parts_adv
	display_name = "Advanced Parts"
	description = "The most finely tuned and accurate stock parts."
	prerequisite_nodes = list(/datum/techweb_node/parts_upg)
	unlocked_designs = list(
		/datum/design/ultra_micro_laser,
		/datum/design/super_capacitor,
		/datum/design/pico_servo,
		/datum/design/super_matter_bin,
		/datum/design/phasic_scanning,
		/datum/design/hyper_battery,
		/datum/design/hyper_cell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier2_any = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)


/datum/techweb_node/parts_bluespace
	display_name = "Bluespace Parts"
	description = "Integrating the latest in bluespace technology, these advanced components not only enhance functionality but also open up new possibilities for the station's technological capabilities."
	prerequisite_nodes = list(/datum/techweb_node/parts_adv, /datum/techweb_node/bluespace_travel)
	unlocked_designs = list(
		/datum/design/bs_rped,
		/datum/design/quadultra_micro_laser,
		/datum/design/quadratic_capacitor,
		/datum/design/femto_servo,
		/datum/design/bluespace_matter_bin,
		/datum/design/triphasic_scanning,
		/datum/design/bluespace_battery,
		/datum/design/bluespace_cell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/machinery_tiered_scan/tier3_any = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/telecomms
	display_name = "Telecommunications Technology"
	description = "A comprehensive suite of machinery for station-wide communication setups, ensuring seamless connectivity and operational coordination."
	prerequisite_nodes = list(/datum/techweb_node/parts_bluespace)
	unlocked_designs = list(
		/datum/design/board/comm_monitor,
		/datum/design/board/comm_server,
		/datum/design/board/message_monitor,
		/datum/design/board/ntnet_relay,
		/datum/design/board/telecomms_hub,
		/datum/design/board/telecomms_messaging,
		/datum/design/board/telecomms_server,
		/datum/design/board/telecomms_processor,
		/datum/design/board/telecomms_relay,
		/datum/design/board/telecomms_bus,
		/datum/design/board/subspace_broadcaster,
		/datum/design/board/subspace_receiver,
		/datum/design/subspace_amplifier,
		/datum/design/subspace_analyzer,
		/datum/design/subspace_ansible,
		/datum/design/subspace_crystal,
		/datum/design/hyperwave_filter,
		/datum/design/subspace_transmitter,
		/datum/design/subspace_treatment,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

// Engineering root node
/datum/techweb_node/construction
	display_name = "Construction"
	description = "Tools and essential machinery used for station maintenance and expansion."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/circuit_imprinter/offstation,
		/datum/design/board/circuit_imprinter,
		/datum/design/board/solarcontrol,
		/datum/design/solar,
		/datum/design/tracker_electronics,
		/datum/design/apc_board,
		/datum/design/airalarm_electronics,
		/datum/design/airlock_board,
		/datum/design/firealarm_electronics,
		/datum/design/firelock_board,
		/datum/design/trapdoor_electronics,
		/datum/design/control,
		/datum/design/ignition_control,
		/datum/design/board/big_manipulator,
		/datum/design/airlock_painter,
		/datum/design/airlock_painter/decal,
		/datum/design/rwd,
		/datum/design/cable_coil,
		/datum/design/welding_helmet,
		/datum/design/weldingtool,
		/datum/design/mini_weldingtool,
		/datum/design/tscanner,
		/datum/design/multitool,
		/datum/design/wrench,
		/datum/design/crowbar,
		/datum/design/screwdriver,
		/datum/design/wirecutters,
		/datum/design/light_bulb,
		/datum/design/light_tube,
		/datum/design/board/crossing_signal,
		/datum/design/board/guideway_sensor,
		/datum/design/board/manuunloader,
		/datum/design/board/manusmelter,
		/datum/design/board/manucrusher,
		/datum/design/board/manucrafter,
		/datum/design/board/manulathe,
		/datum/design/board/manusorter,
		/datum/design/board/manurouter,
		/datum/design/board/mailsorter,
	)

/datum/techweb_node/energy_manipulation
	display_name = "Energy Manipulation"
	description = "Harnessing the raw power of lightning arcs through sophisticated energy control methods."
	prerequisite_nodes = list(/datum/techweb_node/construction)
	unlocked_designs = list(
		/datum/design/board/apc_control,
		/datum/design/board/powermonitor,
		/datum/design/board/smes,
		/datum/design/board/smesbank,
		/datum/design/board/power_connector,
		/datum/design/board/emitter,
		/datum/design/board/grounding_rod,
		/datum/design/board/tesla_coil,
		/datum/design/board/cell_charger,
		/datum/design/board/recharger,
		/datum/design/inducer,
		/datum/design/inducerengi,
		/datum/design/welding_goggles,
		/datum/design/tray_goggles,
		/datum/design/geiger,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/shuttle_engineering
	display_name = "Shuttle Engineering"
	description = "Materials and equipment for constructing shuttles"
	prerequisite_nodes = list(/datum/techweb_node/energy_manipulation, /datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/borg_upgrade_shuttle_blueprints,
		/datum/design/board/propulsion_engine,
		/datum/design/shuttle_blueprints,
		/datum/design/board/shuttle/flight_control,
		/datum/design/board/shuttle/shuttle_docker,
		/datum/design/shuttle_rods,
		/datum/design/shuttle_remote,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/holographics
	display_name = "Holographics"
	description = "Use of holographic technology for signage and barriers."
	prerequisite_nodes = list(/datum/techweb_node/energy_manipulation)
	unlocked_designs = list(
		/datum/design/board/atmosshieldgen,
		/datum/design/forcefield_projector,
		/datum/design/holosign,
		/datum/design/holosignsec,
		/datum/design/holosignengi,
		/datum/design/holosignatmos,
		/datum/design/holosign/restaurant,
		/datum/design/holosign/bar,
		/datum/design/holobarrier_jani,
		/datum/design/holobarrier_med,
		/datum/design/board/holopad,
		/datum/design/holodisk,
		/datum/design/board/modular_shield_gate,
		/datum/design/board/modular_shield_generator,
		/datum/design/board/modular_shield_node,
		/datum/design/board/modular_shield_cable,
		/datum/design/board/modular_shield_relay,
		/datum/design/board/modular_shield_charger,
		/datum/design/board/modular_shield_well,
		/datum/design/board/modular_shield_console,
		/datum/design/diode_disk_magnetic,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/hud
	display_name = "Integrated HUDs"
	description = "Initially developed for assistants to learn the nuances of different professions through augmented reality."
	prerequisite_nodes = list(/datum/techweb_node/holographics, /datum/techweb_node/cyber/cyber_implants)
	unlocked_designs = list(
		/datum/design/health_hud,
		/datum/design/diagnostic_hud,
		/datum/design/security_hud,
		/datum/design/module/mod_visor_medhud,
		/datum/design/module/mod_visor_diaghud,
		/datum/design/module/mod_visor_sechud,
		/datum/design/cyberimp_medical_hud,
		/datum/design/cyberimp_diagnostic_hud,
		/datum/design/cyberimp_security_hud,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/night_vision
	display_name = "Night Vision Technology"
	description = "There are whispers that Nanotrasen pushed for this technology to extend shift durations, ensuring productivity around the clock."
	prerequisite_nodes = list(/datum/techweb_node/hud)
	unlocked_designs = list(
		/datum/design/diagnostic_hud_night,
		/datum/design/health_hud_night,
		/datum/design/night_vision_goggles,
		/datum/design/nvgmesons,
		/datum/design/nv_sci_goggles,
		/datum/design/security_hud_night,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)
