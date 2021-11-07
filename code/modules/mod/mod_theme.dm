/// Global proc that sets up all MOD themes as singletons in a list and returns it.
/proc/setup_mod_themes()
	. = list()
	for(var/path in typesof(/datum/mod_theme))
		var/datum/mod_theme/new_theme = new path()
		.[path] = new_theme

/// MODsuit theme, instanced once and then used by MODsuits to grab various statistics.
/datum/mod_theme
	/// Theme name for the MOD.
	var/name = "standard"
	/// Description added to the MOD.
	var/desc = "A civilian class suit by Nakamura Engineering, doesn't offer much other than slightly quicker movement."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// Armor shared across the MOD pieces.
	var/armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 25, ACID = 25, WOUND = 10)
	/// Resistance flags shared across the MOD pieces.
	var/resistance_flags = NONE
	/// Max heat protection shared across the MOD pieces.
	var/max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	/// Max cold protection shared across the MOD pieces.
	var/min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	/// Permeability shared across the MOD pieces.
	var/permeability_coefficient = 0.01
	/// Siemens shared across the MOD pieces.
	var/siemens_coefficient = 0.5
	/// How much modules can the MOD carry without malfunctioning.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much battery power the MOD uses by just being on
	var/cell_drain = 5
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// Total list of selectable skins for the MOD.
	var/list/skins = list("standard", "civilian")
	/// List of inbuilt modules. These are different from the pre-equipped suits, you should mainly use these for unremovable modules with 0 complexity.
	var/list/inbuilt_modules = list()
	/// Modules blacklisted from the MOD.
	var/list/module_blacklist = list()

/datum/mod_theme/engineering
	name = "engineering"
	desc = "An engineer-fit suit with heat and shock resistance. Nakamura Engineering's classic."
	default_skin = "engineering"
	skins = list("engineering")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 100, FIRE = 100, ACID = 25, WOUND = 10)
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_inactive = 1.5
	slowdown_active = 1

/datum/mod_theme/atmospheric
	name = "atmospheric"
	desc = "An atmospheric-resistant suit by Nakamura Engineering, offering extreme heat resistance compared to the engineer suit."
	default_skin = "advanced"
	skins = list("atmospheric")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 100, FIRE = 100, ACID = 75, WOUND = 10)
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown_inactive = 1.5
	slowdown_active = 1

/datum/mod_theme/advanced
	name = "advanced"
	desc = "An advanced version of Nakamura Engineering's classic suit, shining with a white, acid and fire resistant polish."
	default_skin = "advanced"
	skins = list("advanced")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, FIRE = 100, ACID = 90, WOUND = 10)
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown_inactive = 1
	slowdown_active = 0.5
	inbuilt_modules = list(/obj/item/mod/module/magboot/advanced)

/datum/mod_theme/medical
	name = "medical"
	desc = "A lightweight suit by DeForest Medical Corporation, allows for easier movement."
	default_skin = "advanced"
	skins = list("medical")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 100, FIRE = 60, ACID = 75, WOUND = 10)
	cell_drain = 7
	slowdown_inactive = 1
	slowdown_active = 0.5

/datum/mod_theme/rescue
	name = "rescue"
	desc = "An advanced version of DeForest Medical Corporation's medical suit, designed for quick rescue of bodies from the most dangerous environments."
	default_skin = "advanced"
	skins = list("rescue")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 100, FIRE = 100, ACID = 100, WOUND = 10)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cell_drain = 7
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	inbuilt_modules = list(/obj/item/mod/module/quick_carry/advanced)

/datum/mod_theme/prototype
	name = "prototype"
	desc = "A private military EOD suit by Aussec Armory, intended for explosive research. Bulky, but expansive."
	default_skin = "prototype"
	skins = list("prototype")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100, WOUND = 15)
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 2
	slowdown_active = 1.5
	inbuilt_modules = list(/obj/item/mod/module/reagent_scanner/advanced)

/datum/mod_theme/syndicate
	name = "syndicate"
	desc = "A suit designed by Gorlex Marauders, offering armor ruled illegal in most of Spinward Stellar."
	default_skin = "advanced"
	skins = list("syndicate")
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 40, BOMB = 35, BIO = 100, FIRE = 50, ACID = 90, WOUND = 25)
	siemens_coefficient = 0
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_inactive = 1
	slowdown_active = 0
	ui_theme = "syndicate"
