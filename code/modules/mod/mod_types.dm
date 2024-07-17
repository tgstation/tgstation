/obj/item/mod/control/pre_equipped
	starting_frequency = MODLINK_FREQ_NANOTRASEN
	/// The skin we apply to the suit, defaults to the default_skin of the theme.
	var/applied_skin
	/// The MOD core we apply to the suit.
	var/applied_core = /obj/item/mod/core/standard
	/// The cell we apply to the core. Only applies to standard core suits.
	var/applied_cell = /obj/item/stock_parts/power_store/cell/super
	/// List of modules we spawn with.
	var/list/applied_modules = list()
	/// Modules that we pin when the suit is installed for the first time, for convenience, can be applied or theme inbuilt modules.
	var/list/default_pins = list()

/obj/item/mod/control/pre_equipped/Initialize(mapload, new_theme, new_skin, new_core)
	for(var/module_to_pin in default_pins)
		default_pins[module_to_pin] = list()
	new_skin = applied_skin
	new_core = new applied_core(src)
	if(istype(new_core, /obj/item/mod/core/standard))
		var/obj/item/mod/core/standard/cell_core = new_core
		cell_core.cell = new applied_cell()
	. = ..()
	for(var/obj/item/mod/module/module as anything in applied_modules)
		module = new module(src)
		install(module)

/obj/item/mod/control/pre_equipped/set_wearer(mob/living/carbon/human/user)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		if(!default_pins[module.type]) //this module isnt meant to be pinned by default
			continue
		if(REF(wearer) in default_pins[module.type]) //if we already had pinned once to this user, don care anymore
			continue
		default_pins[module.type] += REF(wearer)
		module.pin(wearer)

/obj/item/mod/control/pre_equipped/uninstall(obj/item/mod/module/old_module, deleting)
	. = ..()
	if(default_pins[old_module.type])
		default_pins -= old_module

/obj/item/mod/control/pre_equipped/standard
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/engineering
	theme = /datum/mod_theme/engineering
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/headprotector,
	)
	default_pins = list(
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
	)

/obj/item/mod/control/pre_equipped/atmospheric
	theme = /datum/mod_theme/atmospheric
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/t_ray,
		/obj/item/mod/module/quick_carry,
		/obj/item/mod/module/headprotector,
	)
	default_pins = list(
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/advanced
	theme = /datum/mod_theme/advanced
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/headprotector,
	)
	default_pins = list(
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/loader
	theme = /datum/mod_theme/loader
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/paper_dispenser,
		/obj/item/mod/module/stamp,
	)
	default_pins = list(
		/obj/item/mod/module/clamp/loader,
		/obj/item/mod/module/magnet,
		/obj/item/mod/module/hydraulic,
	)

/obj/item/mod/control/pre_equipped/mining
	theme = /datum/mod_theme/mining
	applied_core = /obj/item/mod/core/plasma
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/gps,
		/obj/item/mod/module/orebag,
		/obj/item/mod/module/clamp,
		/obj/item/mod/module/drill,
		/obj/item/mod/module/mouthhole,
	)
	default_pins = list(
		/obj/item/mod/module/gps,
		/obj/item/mod/module/drill,
		/obj/item/mod/module/sphere_transform,
	)

/obj/item/mod/control/pre_equipped/medical
	theme = /datum/mod_theme/medical
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/quick_carry,
	)

/obj/item/mod/control/pre_equipped/rescue
	theme = /datum/mod_theme/rescue
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/injector,
	)

/obj/item/mod/control/pre_equipped/research
	theme = /datum/mod_theme/research
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/circuit,
		/obj/item/mod/module/t_ray,
		/obj/item/mod/module/headprotector,
	)

/obj/item/mod/control/pre_equipped/security
	theme = /datum/mod_theme/security
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/pepper_shoulders,
		/obj/item/mod/module/criminalcapture,
		/obj/item/mod/module/quick_cuff,
		/obj/item/mod/module/headprotector,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/safeguard
	theme = /datum/mod_theme/safeguard
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/megaphone,
		/obj/item/mod/module/projectile_dampener,
		/obj/item/mod/module/pepper_shoulders,
		/obj/item/mod/module/quick_cuff,
		/obj/item/mod/module/headprotector,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/magnate
	theme = /datum/mod_theme/magnate
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/pathfinder,
		/obj/item/mod/module/quick_cuff,
		/obj/item/mod/module/headprotector,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/cosmohonk
	theme = /datum/mod_theme/cosmohonk
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/waddle,
		/obj/item/mod/module/bikehorn,
		/obj/item/mod/module/balloon/advanced,
	)

/obj/item/mod/control/pre_equipped/traitor
	theme = /datum/mod_theme/syndicate
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/pathfinder,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/traitor_elite
	theme = /datum/mod_theme/elite
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
	)

/obj/item/mod/control/pre_equipped/nuclear
	theme = /datum/mod_theme/syndicate
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	req_access = list(ACCESS_SYNDICATE)
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
	)

/obj/item/mod/control/pre_equipped/nuclear/no_jetpack

/obj/item/mod/control/pre_equipped/nuclear/no_jetpack/Initialize(mapload, new_theme, new_skin, new_core)
	applied_modules -= list(/obj/item/mod/module/jetpack, /obj/item/mod/module/jump_jet)
	return ..()

/obj/item/mod/control/pre_equipped/nuclear/plasmaman

/obj/item/mod/control/pre_equipped/nuclear/plasmaman/Initialize(mapload, new_theme, new_skin, new_core)
	applied_modules += /obj/item/mod/module/plasma_stabilizer
	return ..()

/obj/item/mod/control/pre_equipped/nuclear/unrestricted
	req_access = null

/obj/item/mod/control/pre_equipped/elite
	theme = /datum/mod_theme/elite
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	req_access = list(ACCESS_SYNDICATE)
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
	)

/obj/item/mod/control/pre_equipped/elite/flamethrower
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/shock_absorber,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/thermal_regulator,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/flamethrower,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flamethrower,
	)

/obj/item/mod/control/pre_equipped/infiltrator
	theme = /datum/mod_theme/infiltrator
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/quick_carry,
		/obj/item/mod/module/visor/diaghud,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/quick_cuff,
	)

/obj/item/mod/control/pre_equipped/infiltrator/Initialize(mapload, new_theme, new_skin, new_core)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/mod/control/pre_equipped/interdyne
	theme = /datum/mod_theme/interdyne
	starting_frequency = MODLINK_FREQ_SYNDICATE
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	applied_modules = list(
		/obj/item/mod/module/organizer,
		/obj/item/mod/module/defibrillator/combat,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/injector,
		/obj/item/mod/module/surgical_processor/preloaded,
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/hat_stabilizer/syndicate,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/quick_cuff,
	)

/obj/item/mod/control/pre_equipped/enchanted
	theme = /datum/mod_theme/enchanted
	starting_frequency = null
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/energy_shield/wizard,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/quick_cuff,
	)

/obj/item/mod/control/pre_equipped/ninja
	theme = /datum/mod_theme/ninja
	starting_frequency = null
	applied_cell = /obj/item/stock_parts/power_store/cell/ninja
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/status_readout/ninja,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/dispenser/ninja,
		/obj/item/mod/module/dna_lock/reinforced,
		/obj/item/mod/module/emp_shield/pulse,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/dispenser/ninja,
		/obj/item/mod/module/emp_shield/pulse,
		/obj/item/mod/module/weapon_recall,
		/obj/item/mod/module/adrenaline_boost,
		/obj/item/mod/module/energy_net,
	)

/obj/item/mod/control/pre_equipped/prototype
	theme = /datum/mod_theme/prototype
	starting_frequency = MODLINK_FREQ_CHARLIE
	req_access = list(ACCESS_AWAY_GENERAL)
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
	)
	default_pins = list(
		/obj/item/mod/module/tether,
		/obj/item/mod/module/anomaly_locked/kinesis/prototype,
	)

/obj/item/mod/control/pre_equipped/glitch
	theme = /datum/mod_theme/glitch
	starting_frequency = null
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
		/obj/item/mod/module/flashlight,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/jump_jet,
	)

/obj/item/mod/control/pre_equipped/responsory
	theme = /datum/mod_theme/responsory
	starting_frequency = MODLINK_FREQ_CENTCOM
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	req_access = list(ACCESS_CENT_GENERAL)
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_cuff,
	)
	/// The insignia type, insignias show what sort of member of the ERT you're dealing with.
	var/insignia_type = /obj/item/mod/module/insignia
	/// Additional module we add, as a treat.
	var/additional_module

/obj/item/mod/control/pre_equipped/responsory/Initialize(mapload, new_theme, new_skin, new_core)
	applied_modules.Insert(1, insignia_type)
	if(additional_module)
		applied_modules += additional_module
		default_pins += additional_module
	return ..()

/obj/item/mod/control/pre_equipped/responsory/commander
	insignia_type = /obj/item/mod/module/insignia/commander
	additional_module = /obj/item/mod/module/power_kick

/obj/item/mod/control/pre_equipped/responsory/security
	insignia_type = /obj/item/mod/module/insignia/security
	additional_module = /obj/item/mod/module/pepper_shoulders

/obj/item/mod/control/pre_equipped/responsory/engineer
	insignia_type = /obj/item/mod/module/insignia/engineer
	additional_module = /obj/item/mod/module/rad_protection

/obj/item/mod/control/pre_equipped/responsory/medic
	insignia_type = /obj/item/mod/module/insignia/medic
	additional_module = /obj/item/mod/module/quick_carry

/obj/item/mod/control/pre_equipped/responsory/janitor
	insignia_type = /obj/item/mod/module/insignia/janitor
	additional_module = /obj/item/mod/module/clamp

/obj/item/mod/control/pre_equipped/responsory/clown
	insignia_type = /obj/item/mod/module/insignia/clown
	additional_module = /obj/item/mod/module/bikehorn

/obj/item/mod/control/pre_equipped/responsory/chaplain
	insignia_type = /obj/item/mod/module/insignia/chaplain
	additional_module = /obj/item/mod/module/injector

/obj/item/mod/control/pre_equipped/responsory/inquisitory
	applied_skin = "inquisitory"
	applied_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/quick_cuff,
	)

/obj/item/mod/control/pre_equipped/responsory/inquisitory/syndie
	starting_frequency = MODLINK_FREQ_SYNDICATE
	req_access = null
	applied_cell = /obj/item/stock_parts/power_store/cell/super
	theme = /datum/mod_theme/responsory/traitor
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/pathfinder,
		/obj/item/mod/module/flashlight/darkness,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/quick_cuff,
		/obj/item/mod/module/visor/night,
		/obj/item/mod/module/shove_blocker,
		/obj/item/mod/module/noslip,
	)

/obj/item/mod/control/pre_equipped/responsory/inquisitory/commander
	insignia_type = /obj/item/mod/module/insignia/commander
	additional_module = /obj/item/mod/module/power_kick

/obj/item/mod/control/pre_equipped/responsory/inquisitory/security
	insignia_type = /obj/item/mod/module/insignia/security
	additional_module = /obj/item/mod/module/pepper_shoulders

/obj/item/mod/control/pre_equipped/responsory/inquisitory/medic
	insignia_type = /obj/item/mod/module/insignia/medic
	additional_module = /obj/item/mod/module/quick_carry

/obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	insignia_type = /obj/item/mod/module/insignia/chaplain
	additional_module = /obj/item/mod/module/injector

/obj/item/mod/control/pre_equipped/apocryphal
	theme = /datum/mod_theme/apocryphal
	starting_frequency = MODLINK_FREQ_CENTCOM
	applied_cell = /obj/item/stock_parts/power_store/cell/bluespace
	req_access = list(ACCESS_CENT_SPECOPS)
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/apocryphal/officer
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/quick_cuff,
	)

/obj/item/mod/control/pre_equipped/corporate
	theme = /datum/mod_theme/corporate
	starting_frequency = MODLINK_FREQ_CENTCOM
	applied_core = /obj/item/mod/core/infinite
	req_access = list(ACCESS_CENT_SPECOPS)
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/emp_shield/advanced,
	)

/obj/item/mod/control/pre_equipped/chrono
	theme = /datum/mod_theme/chrono
	starting_frequency = null
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/eradication_lock,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/timeline_jumper,
		/obj/item/mod/module/timestopper,
		/obj/item/mod/module/rewinder,
		/obj/item/mod/module/tem,
		/obj/item/mod/module/anomaly_locked/kinesis/plus,
	)
	default_pins = list(
		/obj/item/mod/module/timestopper,
		/obj/item/mod/module/timeline_jumper,
		/obj/item/mod/module/rewinder,
		/obj/item/mod/module/tem,
		/obj/item/mod/module/anomaly_locked/kinesis/plus,
	)

/obj/item/mod/control/pre_equipped/debug
	theme = /datum/mod_theme/debug
	starting_frequency = null
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list( //one of every type of module, for testing if they all work correctly
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/bikehorn,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/tether,
		/obj/item/mod/module/injector,
	)

/obj/item/mod/control/pre_equipped/administrative
	theme = /datum/mod_theme/administrative
	starting_frequency = MODLINK_FREQ_CENTCOM
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/quick_carry/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/anomaly_locked/kinesis/admin,
		/obj/item/mod/module/shove_blocker,
		/obj/item/mod/module/quick_cuff,
	)
	default_pins = list(
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/anomaly_locked/kinesis/admin,
	)

//these exist for the prefs menu
/obj/item/mod/control/pre_equipped/empty
	starting_frequency = null

/obj/item/mod/control/pre_equipped/empty/syndicate
	theme = /datum/mod_theme/syndicate

/obj/item/mod/control/pre_equipped/empty/syndicate/honkerative
	applied_skin = "honkerative"

/obj/item/mod/control/pre_equipped/empty/elite
	theme = /datum/mod_theme/elite

/obj/item/mod/control/pre_equipped/empty/ninja
	theme = /datum/mod_theme/ninja

INITIALIZE_IMMEDIATE(/obj/item/mod/control/pre_equipped/empty)
