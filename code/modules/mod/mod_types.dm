/obj/item/mod/control/pre_equipped
	/// The skin we apply to the suit, defaults to the default_skin of the theme.
	var/applied_skin
	/// The MOD core we apply to the suit.
	var/applied_core = /obj/item/mod/core/standard
	/// The cell we apply to the core. Only applies to standard core suits.
	var/applied_cell = /obj/item/stock_parts/cell/high

/obj/item/mod/control/pre_equipped/Initialize(mapload, new_theme, new_skin, new_core)
	new_skin = applied_skin
	new_core = new applied_core(src)
	if(istype(new_core, /obj/item/mod/core/standard))
		var/obj/item/mod/core/standard/cell_core = new_core
		cell_core.cell = new applied_cell()
	return ..()

/obj/item/mod/control/pre_equipped/standard
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/engineering
	theme = /datum/mod_theme/engineering
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magboot,
	)

/obj/item/mod/control/pre_equipped/atmospheric
	theme = /datum/mod_theme/atmospheric
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/t_ray,
	)

/obj/item/mod/control/pre_equipped/advanced
	theme = /datum/mod_theme/advanced
	applied_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/loader
	theme = /datum/mod_theme/loader
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/paper_dispenser,
		/obj/item/mod/module/stamp,
	)

/obj/item/mod/control/pre_equipped/mining
	theme = /datum/mod_theme/mining
	applied_core = /obj/item/mod/core/plasma
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/gps,
		/obj/item/mod/module/orebag,
		/obj/item/mod/module/clamp,
		/obj/item/mod/module/drill,
	)

/obj/item/mod/control/pre_equipped/medical
	theme = /datum/mod_theme/medical
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/quick_carry,
	)

/obj/item/mod/control/pre_equipped/rescue
	theme = /datum/mod_theme/rescue
	applied_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/injector,
	)

/obj/item/mod/control/pre_equipped/research
	theme = /datum/mod_theme/research
	applied_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/circuit,
		/obj/item/mod/module/t_ray,
	)

/obj/item/mod/control/pre_equipped/security
	theme = /datum/mod_theme/security
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/pepper_shoulders,
		/obj/item/mod/module/criminalcapture,
		/obj/item/mod/module/dispenser/mirage,
	)

/obj/item/mod/control/pre_equipped/safeguard
	theme = /datum/mod_theme/safeguard
	applied_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/megaphone,
		/obj/item/mod/module/projectile_dampener,
		/obj/item/mod/module/pepper_shoulders,
	)

/obj/item/mod/control/pre_equipped/magnate
	theme = /datum/mod_theme/magnate
	applied_cell = /obj/item/stock_parts/cell/hyper
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/pathfinder,
	)

/obj/item/mod/control/pre_equipped/cosmohonk
	theme = /datum/mod_theme/cosmohonk
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/waddle,
		/obj/item/mod/module/bikehorn,
	)

/obj/item/mod/control/pre_equipped/traitor
	theme = /datum/mod_theme/syndicate
	applied_cell = /obj/item/stock_parts/cell/super
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/pathfinder,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
	)

/obj/item/mod/control/pre_equipped/traitor_elite
	theme = /datum/mod_theme/elite
	applied_cell = /obj/item/stock_parts/cell/bluespace
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dna_lock,
	)

/obj/item/mod/control/pre_equipped/nuclear
	theme = /datum/mod_theme/syndicate
	applied_cell = /obj/item/stock_parts/cell/hyper
	req_access = list(ACCESS_SYNDICATE)
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/elite
	theme = /datum/mod_theme/elite
	applied_cell = /obj/item/stock_parts/cell/bluespace
	req_access = list(ACCESS_SYNDICATE)
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/elite/flamethrower
	initial_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/thermal_regulator,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/flamethrower,
	)

/obj/item/mod/control/pre_equipped/enchanted
	theme = /datum/mod_theme/enchanted
	applied_core = /obj/item/mod/core/infinite
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/energy_shield/wizard,
		/obj/item/mod/module/emp_shield/advanced,
	)

/obj/item/mod/control/pre_equipped/ninja
	theme = /datum/mod_theme/ninja
	applied_cell = /obj/item/stock_parts/cell/ninja
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/dispenser/ninja,
		/obj/item/mod/module/dna_lock/reinforced,
		/obj/item/mod/module/emp_shield/pulse,
	)

/obj/item/mod/control/pre_equipped/prototype
	theme = /datum/mod_theme/prototype
	req_access = list(ACCESS_AWAY_GENERAL)
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
	)

/obj/item/mod/control/pre_equipped/responsory
	theme = /datum/mod_theme/responsory
	applied_cell = /obj/item/stock_parts/cell/hyper
	req_access = list(ACCESS_CENT_GENERAL)
	initial_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
	)
	/// The insignia type, insignias show what sort of member of the ERT you're dealing with.
	var/insignia_type = /obj/item/mod/module/insignia
	/// Additional module we add, as a treat.
	var/additional_module = /obj/item/mod/module

/obj/item/mod/control/pre_equipped/responsory/Initialize(mapload, new_theme, new_skin, new_core)
	initial_modules.Insert(1, insignia_type)
	initial_modules.Add(additional_module)
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
	initial_modules = list(
		/obj/item/mod/module/anti_magic,
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
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
	applied_cell = /obj/item/stock_parts/cell/bluespace
	req_access = list(ACCESS_CENT_SPECOPS)
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/corporate
	theme = /datum/mod_theme/corporate
	applied_core = /obj/item/mod/core/infinite
	req_access = list(ACCESS_CENT_SPECOPS)
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/hat_stabilizer,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/emp_shield/advanced,
	)

/obj/item/mod/control/pre_equipped/chrono
	theme = /datum/mod_theme/chrono
	applied_core = /obj/item/mod/core/infinite
	initial_modules = list(
		/obj/item/mod/module/eradication_lock,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/timeline_jumper,
		/obj/item/mod/module/timestopper,
		/obj/item/mod/module/rewinder,
		/obj/item/mod/module/tem,
		/obj/item/mod/module/anomaly_locked/kinesis/plus,
	)

/obj/item/mod/control/pre_equipped/debug
	theme = /datum/mod_theme/debug
	applied_core = /obj/item/mod/core/infinite
	initial_modules = list( //one of every type of module, for testing if they all work correctly
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
	applied_core = /obj/item/mod/core/infinite
	initial_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/quick_carry/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/anomaly_locked/kinesis/plus,
	)

//these exist for the prefs menu
/obj/item/mod/control/pre_equipped/empty

/obj/item/mod/control/pre_equipped/empty/syndicate
	theme = /datum/mod_theme/syndicate

/obj/item/mod/control/pre_equipped/empty/syndicate/honkerative
	applied_skin = "honkerative"

/obj/item/mod/control/pre_equipped/empty/elite
	theme = /datum/mod_theme/elite

/obj/item/mod/control/pre_equipped/empty/ninja
	theme = /datum/mod_theme/ninja

INITIALIZE_IMMEDIATE(/obj/item/mod/control/pre_equipped/empty)
