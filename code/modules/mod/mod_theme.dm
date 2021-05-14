/// MODsuit theme, instanced once and then used by MODsuits to grab various statistics.
/datum/mod_theme
	/// Theme name for the MOD.
	var/name = "standard"
	/// Description added to the MOD.
	var/desc = "This one is standard themed, offering no special protections."
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// Armor shared across the MOD pieces.
	var/armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 25, ACID = 25, WOUND = 10)
	/// Helmet for the MOD.
	var/helmet_path = /obj/item/clothing/head/helmet/space/mod //these 4 should probably later be replaced, they are just used for overriding helmet/suit flags
	/// Chestplate for the MOD.
	var/chestplate_path = /obj/item/clothing/suit/armor/mod
	/// Gauntlets for the MOD.
	var/gauntlets_path = /obj/item/clothing/gloves/mod
	/// Boots for the MOD.
	var/boots_path = /obj/item/clothing/shoes/mod
	/// Resistance flags shared across the MOD pieces.
	var/resistance_flags = NONE
	/// Max heat protection shared across the MOD pieces.
	var/max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	/// Max cold protection shared across the MOD pieces.
	var/min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	/// Gas transfer shared across the MOD pieces.
	var/gas_transfer_coefficient = 0.01
	/// Permeability shared across the MOD pieces.
	var/permeability_coefficient = 0.01
	/// Siemens shared across the MOD pieces.
	var/siemens_coefficient = 0.5
	/// How much modules can the MOD carry without malfunctioning.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much battery power the MOD uses by just being on
	var/cell_usage = 5
	/// Slowdown of the MOD when not active.
	var/slowdown_unactive = 2
	/// Slowdown of the MOD when active.
	var/slowdown_active = 1
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// Total list of selectable skins for the MOD.
	var/list/skins = list("standard", "civilian")
	/// Modules blacklisted from the MOD.
	var/list/module_blacklist = list()

/datum/mod_theme/engineering
	name = "engineering"
	desc = "This one is engineering themed, offering radiation and fire protection."
	default_skin = "engineering"
	skins = list("engineering")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 100, RAD = 75, FIRE = 100, ACID = 25, WOUND = 10)
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0

/datum/mod_theme/syndicate
	name = "syndicate"
	desc = "This one is manufactured by the Gorlex Marauders, offering illegal armor protections."
	ui_theme = "syndicate"
	default_skin = "syndicate"
	skins = list("syndicate")
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 40, BOMB = 35, BIO = 100, RAD = 50, FIRE = 50, ACID = 90, WOUND = 25)
	siemens_coefficient = 0

/// Global proc that sets up all MOD themes in a list and returns it.
/proc/setup_mod_themes()
	. = list()
	for(var/path in typesof(/datum/mod_theme))
		var/datum/mod_theme/new_theme = new path()
		.[path] = new_theme
