/datum/armament_entry/company_import/microstar
	category = MICROSTAR_ENERGY_NAME
	company_bitflag = CARGO_COMPANY_MICROSTAR

// Basic lethal/disabler beam weapons, includes the base mcr

/datum/armament_entry/company_import/microstar/basic_energy_weapons
	subcategory = "Basic Energy Smallarms"

/datum/armament_entry/company_import/microstar/basic_energy_weapons/disabler
	item_type = /obj/item/gun/energy/disabler
	cost = PAYCHECK_CREW * 5

/datum/armament_entry/company_import/microstar/basic_energy_weapons/mini_egun
	item_type = /obj/item/gun/energy/e_gun/mini
	cost = PAYCHECK_CREW * 5

/datum/armament_entry/company_import/microstar/lethal_sidearm/energy_holster
	item_type = /obj/item/storage/belt/holster/energy/thermal
	cost = PAYCHECK_COMMAND * 6

/datum/armament_entry/company_import/microstar/basic_energy_long_weapons
	subcategory = "Basic Energy Longarms"

/datum/armament_entry/company_import/microstar/basic_energy_long_weapons/laser
	item_type = /obj/item/gun/energy/laser
	cost = PAYCHECK_CREW * 5

/datum/armament_entry/company_import/microstar/basic_energy_long_weapons/laser_carbine
	item_type = /obj/item/gun/energy/laser/carbine
	cost = PAYCHECK_CREW * 7 // slightly more expensive due to ease of use/full auto

/datum/armament_entry/company_import/microstar/basic_energy_long_weapons/egun
	item_type = /obj/item/gun/energy/e_gun
	cost = PAYCHECK_COMMAND * 4

/datum/armament_entry/company_import/microstar/basic_energy_long_weapons/mod_laser_small
	item_type = /obj/item/gun/energy/modular_laser_rifle/carbine
	cost = PAYCHECK_COMMAND * 5

/datum/armament_entry/company_import/microstar/basic_energy_long_weapons/mod_laser_large
	item_type = /obj/item/gun/energy/modular_laser_rifle
	cost = PAYCHECK_COMMAND * 8

// More expensive, unique energy weapons
/datum/armament_entry/company_import/microstar/experimental_energy
	subcategory = "Experimental Energy Weapons"
	cost = PAYCHECK_COMMAND * 6
	restricted = TRUE

/datum/armament_entry/company_import/microstar/experimental_energy/hellfire
	item_type = /obj/item/gun/energy/laser/hellgun

/datum/armament_entry/company_import/microstar/experimental_energy/ion_carbine
	item_type = /obj/item/gun/energy/ionrifle/carbine

/datum/armament_entry/company_import/microstar/experimental_energy/xray_gun
	item_type = /obj/item/gun/energy/xray

/datum/armament_entry/company_import/microstar/experimental_energy/tesla_cannon
	item_type = /obj/item/gun/energy/tesla_cannon
