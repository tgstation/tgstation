/datum/techweb_node/mech_assembly
	display_name = "Exosuit Assembly"
	description = "Development of mechanical exosuits designed to contend with artificial gravity while transporting cargo."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/board/mechapower,
		/datum/design/board/mech_recharger,
		/datum/design/ripley_chassis,
		/datum/design/ripley_torso,
		/datum/design/ripley_left_arm,
		/datum/design/ripley_right_arm,
		/datum/design/ripley_left_leg,
		/datum/design/ripley_right_leg,
		/datum/design/board/ripley_main,
		/datum/design/board/ripley_peri,
		/datum/design/mech_hydraulic_clamp,
	)

/datum/techweb_node/mech_equipment
	display_name = "Expedition Equipment"
	description = "Specialized exosuit gear tailored for navigating space and celestial bodies, ensuring durability and functionality in the harshest conditions."
	prerequisite_nodes = list(/datum/techweb_node/mech_assembly)
	unlocked_designs = list(
		/datum/design/board/mechacontrol,
		/datum/design/board/botpad,
		/datum/design/botpad_remote,
		/datum/design/ripleyupgrade,
		/datum/design/mech_air_tank,
		/datum/design/mech_thrusters,
		/datum/design/mech_extinguisher,
		/datum/design/mecha_camera,
		/datum/design/mecha_tracking,
		/datum/design/mech_radio,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_clown
	display_name = "Funny Robots"
	description = "Fueled by laughter."
	prerequisite_nodes = list(/datum/techweb_node/mech_assembly)
	unlocked_designs = list(
		/datum/design/honk_chassis,
		/datum/design/honk_torso,
		/datum/design/honk_head,
		/datum/design/honk_left_arm,
		/datum/design/honk_right_arm,
		/datum/design/honk_left_leg,
		/datum/design/honk_right_leg,
		/datum/design/board/honker_main,
		/datum/design/board/honker_peri,
		/datum/design/board/honker_targ,
		/datum/design/mech_banana_mortar,
		/datum/design/mech_honker,
		/datum/design/mech_mousetrap_mortar,
		/datum/design/mech_punching_glove,
		/datum/design/borg_transform_clown,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SECURITY) //The dread upon security when they hear this...

/datum/techweb_node/mech_medical
	display_name = "Medical Exosuit"
	description = "Advanced robotic unit equipped with syringe guns and healing beams, revolutionizing medical assistance in hazardous environments."
	prerequisite_nodes = list(/datum/techweb_node/mech_assembly, /datum/techweb_node/chem_synthesis)
	unlocked_designs = list(
		/datum/design/odysseus_chassis,
		/datum/design/odysseus_torso,
		/datum/design/odysseus_head,
		/datum/design/odysseus_left_arm,
		/datum/design/odysseus_right_arm,
		/datum/design/odysseus_left_leg,
		/datum/design/odysseus_right_leg,
		/datum/design/board/odysseus_main,
		/datum/design/board/odysseus_peri,
		/datum/design/mech_medical_beamgun,
		/datum/design/mech_syringe_gun,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/mech_mining
	display_name = "Mining Exosuit"
	description = "Robust exosuit engineered to withstand lava and storms for continuous off-station mining operations."
	prerequisite_nodes = list(/datum/techweb_node/mech_equipment, /datum/techweb_node/mining)
	unlocked_designs = list(
		/datum/design/clarke_chassis,
		/datum/design/clarke_torso,
		/datum/design/clarke_head,
		/datum/design/clarke_left_arm,
		/datum/design/clarke_right_arm,
		/datum/design/board/clarke_main,
		/datum/design/board/clarke_peri,
		/datum/design/mecha_kineticgun,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/mech_combat
	display_name = "Combat Exosuits"
	description = "Modular armor upgrades and specialized equipment for security exosuits."
	prerequisite_nodes = list(/datum/techweb_node/mech_equipment)
	unlocked_designs = list(
		/datum/design/mech_ccw_armor,
		/datum/design/mech_proj_armor,
		/datum/design/mech_emp_armor,
		/datum/design/paddyupgrade,
		/datum/design/mech_hydraulic_claw,
		/datum/design/mech_disabler,
		/datum/design/mech_repair_droid,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/mecha_equipped_scan)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_assault
	display_name = "Assault Exosuits"
	description = "Heavy battle exosuits boasting robust armor but sacrificing speed for enhanced durability."
	prerequisite_nodes = list(/datum/techweb_node/mech_combat)
	unlocked_designs = list(
		/datum/design/durand_armor,
		/datum/design/durand_chassis,
		/datum/design/durand_torso,
		/datum/design/durand_head,
		/datum/design/durand_left_arm,
		/datum/design/durand_right_arm,
		/datum/design/durand_left_leg,
		/datum/design/durand_right_leg,
		/datum/design/board/durand_main,
		/datum/design/board/durand_peri,
		/datum/design/board/durand_targ,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_light
	display_name = "Light Combat Exosuits"
	description = "Agile combat exosuits equipped with overclocking capabilities for temporary speed boosts, prioritizing speed over durability on the battlefield."
	prerequisite_nodes = list(/datum/techweb_node/mech_combat)
	unlocked_designs = list(
		/datum/design/gygax_armor,
		/datum/design/gygax_chassis,
		/datum/design/gygax_torso,
		/datum/design/gygax_head,
		/datum/design/gygax_left_arm,
		/datum/design/gygax_right_arm,
		/datum/design/gygax_left_leg,
		/datum/design/gygax_right_leg,
		/datum/design/board/gygax_main,
		/datum/design/board/gygax_peri,
		/datum/design/board/gygax_targ,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_heavy
	display_name = "Heavy Exosuits"
	description = "Advanced heavy mechanized unit with dual pilot capability, designed for robust battlefield performance and increased tactical versatility."
	prerequisite_nodes = list(/datum/techweb_node/mech_assault)
	unlocked_designs = list(
		/datum/design/savannah_ivanov_armor,
		/datum/design/savannah_ivanov_chassis,
		/datum/design/savannah_ivanov_torso,
		/datum/design/savannah_ivanov_head,
		/datum/design/savannah_ivanov_left_arm,
		/datum/design/savannah_ivanov_right_arm,
		/datum/design/savannah_ivanov_left_leg,
		/datum/design/savannah_ivanov_right_leg,
		/datum/design/board/savannah_ivanov_main,
		/datum/design/board/savannah_ivanov_peri,
		/datum/design/board/savannah_ivanov_targ,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_infiltrator
	display_name = "Infiltration Exosuits"
	description = "Advanced exosuit with phasing capabilities, allowing it to move through walls and obstacles, ideal for covert and special operations."
	prerequisite_nodes = list(/datum/techweb_node/mech_light, /datum/techweb_node/anomaly_research)
	unlocked_designs = list(
		/datum/design/phazon_armor,
		/datum/design/phazon_chassis,
		/datum/design/phazon_torso,
		/datum/design/phazon_head,
		/datum/design/phazon_left_arm,
		/datum/design/phazon_right_arm,
		/datum/design/phazon_left_leg,
		/datum/design/phazon_right_leg,
		/datum/design/board/phazon_main,
		/datum/design/board/phazon_peri,
		/datum/design/board/phazon_targ,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_energy_guns
	display_name = "Exosuit Energy Guns"
	description = "Scaled-up versions of electric weapons optimized for exosuit deployment."
	prerequisite_nodes = list(/datum/techweb_node/mech_combat, /datum/techweb_node/electric_weapons)
	unlocked_designs = list(
		/datum/design/mech_laser,
		/datum/design/mech_laser_heavy,
		/datum/design/mech_ion,
		/datum/design/mech_tesla,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/random/mecha_damage_scan = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_firearms
	display_name = "Exosuit Firearms"
	description = "Mounted ballistic weaponry, enhancing combat capabilities for mechanized units."
	prerequisite_nodes = list(/datum/techweb_node/mech_energy_guns, /datum/techweb_node/exotic_ammo)
	unlocked_designs = list(
		/datum/design/mech_lmg,
		/datum/design/mech_lmg_ammo,
		/datum/design/mech_scattershot,
		/datum/design/mech_scattershot_ammo,
		/datum/design/mech_carbine,
		/datum/design/mech_carbine_ammo,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_heavy_arms
	display_name = "Heavy Exosuit Firearms"
	description = "High-impact weaponry integrated into mechs, optimized for maximum firepower."
	prerequisite_nodes = list(/datum/techweb_node/mech_heavy, /datum/techweb_node/exotic_ammo)
	unlocked_designs = list(
		/datum/design/clusterbang_launcher,
		/datum/design/clusterbang_launcher_ammo,
		/datum/design/mech_grenade_launcher,
		/datum/design/mech_grenade_launcher_ammo,
		/datum/design/mech_missile_rack,
		/datum/design/mech_missile_rack_ammo,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mech_equip_bluespace
	display_name = "Bluespace Exosuit Equipment"
	description = "An array of equipment empowered by bluespace, providing unmatched mobility and utility."
	prerequisite_nodes = list(/datum/techweb_node/mech_infiltrator, /datum/techweb_node/bluespace_travel)
	unlocked_designs = list(
		/datum/design/mech_gravcatapult,
		/datum/design/mech_teleporter,
		/datum/design/mech_wormhole_gen,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)
