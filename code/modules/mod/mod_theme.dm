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
	/// Extended description on examine_more
	var/extended_desc = "A third-generation, modular civilian class suit by Nakamura Engineering, \
		this suit is a staple across the galaxy for civilian applications. These suits are oxygenated, \
		spaceworthy, resistant to fire and chemical threats, and are immunized against everything between \
		a sneeze and a bioweapon. However, their combat applications are incredibly minimal due to the amount of \
		armor plating being installed by default, and their actuators only lead to slightly greater speed than industrial suits."
	/// Default skin of the MOD.
	var/default_skin = "standard"
	/// The slot this mod theme fits on
	var/slot_flags = ITEM_SLOT_BACK
	/// Armor shared across the MOD parts.
	var/datum/armor/armor_type = /datum/armor/mod_theme
	/// Resistance flags shared across the MOD parts.
	var/resistance_flags = NONE
	/// Atom flags shared across the MOD parts.
	var/atom_flags = NONE
	/// Max heat protection shared across the MOD parts.
	var/max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	/// Max cold protection shared across the MOD parts.
	var/min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	/// Siemens shared across the MOD parts.
	var/siemens_coefficient = 0.5
	/// How much modules can the MOD carry without malfunctioning.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much battery power the MOD uses by just being on
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// Theme used by the MOD TGUI.
	var/ui_theme = "ntos"
	/// List of inbuilt modules. These are different from the pre-equipped suits, you should mainly use these for unremovable modules with 0 complexity.
	var/list/inbuilt_modules = list()
	/// Allowed items in the chestplate's suit storage.
	var/list/allowed_suit_storage = list()
	/// List of skins with their appropriate clothing flags.
	var/list/skins = list(
		"standard" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				SEALED_INVISIBILITY =  HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"civilian" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme
	melee = 10
	bullet = 5
	laser = 5
	energy = 5
	bio = 100
	fire = 25
	acid  =25
	wound = 5

/datum/mod_theme/engineering
	name = "engineering"
	desc = "An engineer-fit suit with heat and shock resistance. Nakamura Engineering's classic."
	extended_desc = "A classic by Nakamura Engineering, and surely their claim to fame. This model is an \
		improvement upon the first-generation prototype models from before the Void War, boasting an array of features. \
		The modular flexibility of the base design has been combined with a blast-dampening insulated inner layer and \
		a shock-resistant outer layer, making the suit nigh-invulnerable against even the extremes of high-voltage electricity. \
		However, the capacity for modification remains the same as civilian-grade suits."
	default_skin = "engineering"
	armor_type = /datum/armor/mod_theme_engineering
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1.5
	slowdown_active = 1
	allowed_suit_storage = list(
		/obj/item/construction/rcd,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/storage/bag/construction,
	)
	skins = list(
		"engineering" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_engineering
	melee = 10
	bullet = 5
	laser = 20
	energy = 10
	bomb = 10
	bio = 100
	fire = 100
	acid = 25
	wound = 10

/datum/mod_theme/atmospheric
	name = "atmospheric"
	desc = "An atmospheric-resistant suit by Nakamura Engineering, offering extreme heat resistance compared to the engineer suit."
	extended_desc = "A modified version of the Nakamura Engineering industrial model. This one has been \
		augmented with the latest in heat-resistant alloys, paired with a series of advanced heatsinks. \
		Additionally, the materials used to construct this suit have rendered it extremely hardy against \
		corrosive gasses and liquids, useful in the world of pipes. \
		However, the capacity for modification remains the same as civilian-grade suits."
	default_skin = "atmospheric"
	armor_type = /datum/armor/mod_theme_atmospheric
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown_inactive = 1.5
	slowdown_active = 1
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/pipe_dispenser,
		/obj/item/t_scanner,
	)
	skins = list(
		"atmospheric" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_atmospheric
	melee = 10
	bullet = 5
	laser = 10
	energy = 15
	bomb = 10
	bio = 100
	fire = 100
	acid = 75
	wound = 10

/datum/mod_theme/advanced
	name = "advanced"
	desc = "An advanced version of Nakamura Engineering's classic suit, shining with a white, acid and fire resistant polish."
	extended_desc = "The flagship version of the Nakamura Engineering industrial model, and their latest product. \
		Combining all the features of their other industrial model suits inside, with blast resistance almost approaching \
		some EOD suits, the outside has been coated with a white polish rumored to be a corporate secret. \
		The paint used is almost entirely immune to corrosives, and certainly looks damn fine. \
		These come pre-installed with magnetic boots, using an advanced system to toggle them on or off as the user walks."
	default_skin = "advanced"
	armor_type = /datum/armor/mod_theme_advanced
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5
	inbuilt_modules = list(/obj/item/mod/module/magboot/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/construction/rcd,
		/obj/item/fireaxe/metal_h2_axe,
		/obj/item/melee/baton/telescopic,
		/obj/item/pipe_dispenser,
		/obj/item/storage/bag/construction,
		/obj/item/t_scanner,
	)
	skins = list(
		"advanced" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_advanced
	melee = 15
	bullet = 5
	laser = 20
	energy = 15
	bomb = 50
	bio = 100
	fire = 100
	acid = 90
	wound = 10

/datum/mod_theme/mining
	name = "mining"
	desc = "A Nanotrasen mining suit for on-site operations, fit with accreting ash armor and a sphere form."
	extended_desc = "A high-powered Nanotrasen-designed suit, based off the work of Nakamura Engineering. \
		While initial designs were built for the rigors of asteroid mining, given blast resistance through inbuilt ceramics, \
		mining teams have since heavily tweaked the suit themselves with assistance from devices crafted by \
		destructive analysis of unknown technologies discovered on the Indecipheres mining sites, patterned off \
		their typical non-EVA exploration suits. The visor has been expanded to a system of seven arachnid-like cameras, \
		offering full view of the land and its soon-to-be-dead inhabitants. The armor plating has been trimmed down to \
		the bare essentials, geared far more for environmental hazards than combat against fauna; however, \
		this gives way to incredible protection against corrosives and thermal protection good enough for \
		both casual backstroking through molten magma and romantic walks through arctic terrain. \
		Instead, the suit is capable of using its' anomalous properties to attract and \
		carefully distribute layers of ash or ice across the surface; these layers are ablative, but incredibly strong. \
		Lastly, the suit is capable of compressing and shrinking the mass of the wearer, as well as \
		rearranging its own constitution, to allow them to fit upright in a sphere form that can \
		roll around at half their original size; leaving high-powered mining ordinance in its wake. \
		However, all of this has proven to be straining on all Nanotrasen-approved cells, \
		so much so that it comes default fueled by equally-enigmatic plasma fuel rather than a simple recharge. \
		Additionally, the systems have been put to near their maximum load, allowing for far less customization than others."
	default_skin = "mining"
	armor_type = /datum/armor/mod_theme_mining
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	allowed_suit_storage = list(
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/pickaxe,
		/obj/item/kinetic_crusher,
		/obj/item/stack/ore/plasma,
		/obj/item/storage/bag/ore,
	)
	inbuilt_modules = list(/obj/item/mod/module/ash_accretion, /obj/item/mod/module/sphere_transform)
	skins = list(
		"mining" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"asteroid" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_mining
	melee = 15
	bullet = 5
	laser = 5
	energy = 5
	bomb = 30
	bio = 100
	fire = 100
	acid = 75
	wound = 15

/datum/mod_theme/loader
	name = "loader"
	desc = "An unsealed experimental motorized harness manufactured by Scarborough Arms for quick and efficient munition supplies."
	extended_desc = "This powered suit is an experimental spinoff of in-atmosphere Engineering suits. \
		This fully articulated titanium exoskeleton is Scarborough Arms' suit of choice for their munition delivery men, \
		and what it lacks in EVA protection, it makes up for in strength and flexibility. The primary feature of \
		this suit are the two manipulator arms, carefully synchronized with the user's thoughts and \
		duplicating their motions almost exactly. These are driven by myomer, an artificial analog of muscles, \
		requiring large amounts of voltage to function; occasionally sparking under load with the sheer power of a \
		suit capable of lifting 250 tons. Even the legs in the suit have been tuned to incredible capacity, \
		the user being able to run at greater speeds for much longer distances and times than an unsuited equivalent. \
		A lot of people would say loading cargo is a dull job. You could not disagree more."
	default_skin = "loader"
	armor_type = /datum/armor/mod_theme_loader
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	siemens_coefficient = 0.25
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/mail,
		/obj/item/delivery/small,
		/obj/item/paper,
		/obj/item/storage/bag/mail,
	)
	inbuilt_modules = list(/obj/item/mod/module/hydraulic, /obj/item/mod/module/clamp/loader, /obj/item/mod/module/magnet)
	skins = list(
		"loader" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
			),
			GAUNTLETS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_loader
	melee = 15
	bullet = 5
	laser = 5
	energy = 5
	bomb = 10
	bio = 10
	fire = 25
	acid = 25
	wound = 10

/datum/mod_theme/medical
	name = "medical"
	desc = "A lightweight suit by DeForest Medical Corporation, allows for easier movement."
	extended_desc = "A lightweight suit produced by the DeForest Medical Corporation, based off the work of \
		Nakamura Engineering. The latest in technology has been employed in this suit to render it immunized against \
		allergens, airborne toxins, and regular pathogens. The primary asset of this suit is the speed, \
		fusing high-powered servos and actuators with a carbon-fiber construction. While there's very little armor used, \
		it is incredibly acid-resistant. It is slightly more demanding of power than civilian-grade models, \
		and weak against fingers tapping the glass."
	default_skin = "medical"
	armor_type = /datum/armor/mod_theme_medical
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_inactive = 1
	slowdown_active = 0.5
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
	)
	skins = list(
		"medical" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"corpsman" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_medical
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 10
	bio = 100
	fire = 60
	acid = 75
	wound = 5

/datum/mod_theme/rescue
	name = "rescue"
	desc = "An advanced version of DeForest Medical Corporation's medical suit, designed for quick rescue of bodies from the most dangerous environments."
	extended_desc = "An upgraded, armor-plated version of DeForest Medical Corporation's medical suit, \
		designed for quick rescue of bodies from the most dangerous environments. The same advanced leg servos \
		as the base version are seen here, giving paramedics incredible speed, but the same servos are also in the arms. \
		Users are capable of quickly hauling even the heaviest crewmembers using this suit, \
		all while being entirely immune against chemical and thermal threats. \
		It is slightly more demanding of power than civilian-grade models, and weak against fingers tapping the glass."
	default_skin = "rescue"
	armor_type = /datum/armor/mod_theme_rescue
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	charge_drain = DEFAULT_CHARGE_DRAIN * 1.5
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	inbuilt_modules = list(/obj/item/mod/module/quick_carry/advanced)
	allowed_suit_storage = list(
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical,
		/obj/item/sensor_device,
		/obj/item/storage/pill_bottle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/melee/baton/telescopic,
	)
	skins = list(
		"rescue" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_rescue
	melee = 10
	bullet = 10
	laser = 5
	energy = 5
	bomb = 10
	bio = 100
	fire = 100
	acid = 100
	wound = 5

/datum/mod_theme/research
	name = "research"
	desc = "A private military EOD suit by Aussec Armory, intended for explosive research. Bulky, but expansive."
	extended_desc = "A private military EOD suit by Aussec Armory, based off the work of Nakamura Engineering. \
		This suit is intended for explosive research, built incredibly bulky and well-covering. \
		Featuring an inbuilt chemical scanning array, this suit uses two layers of plastitanium armor, \
		sandwiching an inert layer to dissipate kinetic energy into the suit and away from the user; \
		outperforming even the best conventional EOD suits. However, despite its immunity against even \
		missiles and artillery, all the explosive resistance is mostly working to keep the user intact, \
		not alive. The user will also find narrow doorframes nigh-impossible to surmount."
	default_skin = "research"
	armor_type = /datum/armor/mod_theme_research
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 1.75
	slowdown_active = 1.25
	inbuilt_modules = list(/obj/item/mod/module/reagent_scanner/advanced)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/dnainjector,
		/obj/item/biopsy_tool,
		/obj/item/experi_scanner,
		/obj/item/storage/bag/bio,
		/obj/item/melee/baton/telescopic,
	)
	skins = list(
		"research" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_research
	melee = 20
	bullet = 15
	laser = 5
	energy = 5
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	wound = 15

/datum/mod_theme/security
	name = "security"
	desc = "An Apadyne Technologies security suit, offering quicker speed at the cost of carrying capacity."
	extended_desc = "An Apadyne Technologies classic, this model of MODsuit has been designed for quick response to \
		hostile situations. These suits have been layered with plating worthy enough for fires or corrosive environments, \
		and come with composite cushioning and an advanced honeycomb structure underneath the hull to ensure protection \
		against broken bones or possible avulsions. The suit's legs have been given more rugged actuators, \
		allowing the suit to do more work in carrying the weight. However, the systems used in these suits are more than \
		a few years out of date, leading to an overall lower capacity for modules."
	default_skin = "security"
	armor_type = /datum/armor/mod_theme_security
	complexity_max = DEFAULT_MAX_COMPLEXITY - 3
	slowdown_inactive = 1
	slowdown_active = 0.5
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	skins = list(
		"security" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_security
	melee = 15
	bullet = 15
	laser = 15
	energy = 15
	bomb = 25
	bio = 100
	fire = 75
	acid = 75
	wound = 15

/datum/mod_theme/safeguard
	name = "safeguard"
	desc = "An Apadyne Technologies advanced security suit, offering greater speed and fire protection than the standard security model."
	extended_desc = "An Apadyne Technologies advanced security suit, and their latest model. This variant has \
		ditched the presence of a reinforced glass visor entirely, replacing it with a 'blast visor' utilizing a \
		small camera on the left side to display the outside to the user. The plating on the suit has been \
		dramatically increased, especially in the pauldrons, giving the wearer an imposing silhouette. \
		Heatsinks line the sides of the suit, and greater technology has been used in insulating it against \
		both corrosive environments and sudden impacts to the user's joints."
	default_skin = "safeguard"
	armor_type = /datum/armor/mod_theme_safeguard
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	skins = list(
		"safeguard" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_safeguard
	melee = 15
	bullet = 15
	laser = 15
	energy = 15
	bomb = 40
	bio = 100
	fire = 100
	acid = 95
	wound = 15

/datum/mod_theme/magnate
	name = "magnate"
	desc = "A fancy, very protective suit for Nanotrasen's captains. Shock, fire and acid-proof while also having a large capacity and high speed."
	extended_desc = "They say it costs four hundred thousand credits to run this MODsuit... for twelve seconds. \
		The Magnate suit is designed for protection, comfort, and luxury for Nanotrasen Captains. \
		The onboard air filters have been preprogrammed with an additional five hundred different fragrances that can \
		be pumped into the helmet, all of highly-endangered flowers. A bespoke Tralex mechanical clock has been placed \
		in the wrist, and the Magnate package comes with carbon-fibre cufflinks to wear underneath. \
		My God, it even has a granite trim. The double-classified paint that's been painstakingly applied to the hull \
		provides protection against shock, fire, and the strongest acids. Onboard systems employ meta-positronic learning \
		and bluespace processing to allow for a wide array of onboard modules to be supported, and only the best actuators \
		have been employed for speed. The resemblance to a Gorlex Marauder helmet is purely coincidental."
	default_skin = "magnate"
	armor_type = /datum/armor/mod_theme_magnate
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	skins = list(
		"magnate" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_magnate
	melee = 20
	bullet = 15
	laser = 15
	energy = 15
	bomb = 50
	bio = 100
	fire = 100
	acid = 100
	wound = 15

/datum/mod_theme/cosmohonk
	name = "cosmohonk"
	desc = "A suit by Honk Ltd. Protects against low humor environments. Most of the tech went to lower the power cost."
	extended_desc = "The Cosmohonk MODsuit was originally designed for interstellar comedy in low-humor environments. \
		It utilizes tungsten electro-ceramic casing and chromium bipolars, coated in zirconium-boron paint underneath \
		a dermatiraelian subspace alloy. Despite the glaringly obvious optronic vacuum drive pedals, \
		this particular model does not employ manganese bipolar capacitor cleaners, thank the Honkmother. \
		All you know is that this suit is mysteriously power-efficient, and far too colorful for the Mime to steal."
	default_skin = "cosmohonk"
	armor_type = /datum/armor/mod_theme_cosmohonk
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.25
	slowdown_inactive = 1.75
	slowdown_active = 1.25
	allowed_suit_storage = list(
		/obj/item/bikehorn,
		/obj/item/food/grown/banana,
		/obj/item/grown/bananapeel,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/instrument,
	)
	skins = list(
		"cosmohonk" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_cosmohonk
	melee = 5
	bullet = 5
	laser = 20
	energy = 20
	bomb = 10
	bio = 100
	fire = 60
	acid = 30
	wound = 5

/datum/mod_theme/syndicate
	name = "syndicate"
	desc = "A suit designed by Gorlex Marauders, offering armor ruled illegal in most of Spinward Stellar."
	extended_desc = "An advanced combat suit adorned in a sinister crimson red color scheme, produced and manufactured \
		for special mercenary operations. The build is a streamlined layering consisting of shaped Plasteel, \
		and composite ceramic, while the under suit is lined with a lightweight Kevlar and durathread hybrid weave \
		to provide ample protection to the user where the plating doesn't, with an illegal onboard electric powered \
		ablative shield module to provide resistance against conventional energy firearms. \
		A small tag hangs off of it reading; 'Property of the Gorlex Marauders, with assistance from Cybersun Industries. \
		All rights reserved, tampering with suit will void warranty."
	default_skin = "syndicate"
	armor_type = /datum/armor/mod_theme_syndicate
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)
	skins = list(
		"syndicate" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"honkerative" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_syndicate
	melee = 15
	bullet = 20
	laser = 15
	energy = 15
	bomb = 35
	bio = 100
	fire = 50
	acid = 90
	wound = 25

/datum/mod_theme/elite
	name = "elite"
	desc = "An elite suit upgraded by Cybersun Industries, offering upgraded armor values."
	extended_desc = "An evolution of the syndicate suit, featuring a bulkier build and a matte black color scheme, \
		this suit is only produced for high ranking Syndicate officers and elite strike teams. \
		It comes built with a secondary layering of ceramic and Kevlar into the plating providing it with \
		exceptionally better protection along with fire and acid proofing. A small tag hangs off of it reading; \
		'Property of the Gorlex Marauders, with assistance from Cybersun Industries. \
		All rights reserved, tampering with suit will void life expectancy.'"
	default_skin = "elite"
	armor_type = /datum/armor/mod_theme_elite
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 1
	slowdown_active = 0.5
	ui_theme = "syndicate"
	inbuilt_modules = list(/obj/item/mod/module/armor_booster)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)
	skins = list(
		"elite" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_elite
	melee = 35
	bullet = 30
	laser = 35
	energy = 35
	bomb = 55
	bio = 100
	fire = 100
	acid = 100
	wound = 25

/datum/mod_theme/infiltrator
	name = "infiltrator"
	desc = "A specialized infiltration suit, developed by the Roseus Galactic Actors Guild to strike fear and awe into the hearts of the public."
	extended_desc = "Several questions have been raised over the years in regards to the clandestine Infiltrator modular suit. \
		Why is the suit blood red despite being a sneaking suit? Why did a movie company of all things develop a stealth suit? \
		The simplest answer is that Roseus Galactic hire more than a few eccentric individuals who know more about \
		visual aesthetics and prop design than they do functional operative camouflage. But the true reason goes deeper. \
		The visual appearance of the suit exemplifies brazen displays of power, not true stealth. However, the suit's inbuilt stealth mechanisms\
		prevent anyone from fully recognizing the occupant, only the suit, creating perfect anonymity. This visual transformation is \
		backed by inbuilt psi-emitters, heightening stressors common amongst Nanotrasen staff, and clouding identifiable information. \
		Scrubbed statistical data presented a single correlation within documented psychological profiles. The fear of the Unknown."
	default_skin = "infiltrator"
	armor_type = /datum/armor/mod_theme_infiltrator
	resistance_flags = FIRE_PROOF | ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	siemens_coefficient = 0
	slowdown_inactive = 0
	slowdown_active = 0
	ui_theme = "syndicate"
	slot_flags = ITEM_SLOT_BELT
	inbuilt_modules = list(/obj/item/mod/module/infiltrator, /obj/item/mod/module/storage/belt, /obj/item/mod/module/demoralizer)
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)
	skins = list(
		"infiltrator" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
				CAN_OVERSLOT = TRUE,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				CAN_OVERSLOT = TRUE,
			),
			GAUNTLETS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_infiltrator
	melee = 50
	bullet = 50
	laser = 40
	energy = 50
	bomb = 40
	fire = 100
	acid = 100
	wound = 25

/datum/mod_theme/enchanted
	name = "enchanted"
	desc = "The Wizard Federation's relatively low-tech MODsuit. Is very protective, though."
	extended_desc = "The Wizard Federation's relatively low-tech MODsuit. This armor employs not \
		plasteel or carbon fibre, but space dragon scales for its protection. Recruits are expected to \
		gather these themselves, but the effort is well worth it, the suit being well-armored against threats \
		both mundane and mystic. Rather than wholly relying on a cell, which would surely perish \
		under the load, several naturally-occurring bluespace gemstones have been utilized as \
		default means of power. The hood and platform boots are of unknown usage, but it's speculated that \
		wizards trend towards the dramatic."
	default_skin = "enchanted"
	armor_type = /datum/armor/mod_theme_enchanted
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	slowdown_inactive = 0.75
	slowdown_active = 0.25
	ui_theme = "wizard"
	inbuilt_modules = list(/obj/item/mod/module/anti_magic/wizard)
	allowed_suit_storage = list(
		/obj/item/teleportation_scroll,
		/obj/item/highfrequencyblade/wizard,
		/obj/item/gun/magic,
	)
	skins = list(
		"enchanted" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL|CASTING_CLOTHES,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL|CASTING_CLOTHES,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_enchanted
	melee = 40
	bullet = 40
	laser = 50
	energy = 50
	bomb = 35
	bio = 100
	fire = 100
	acid = 100
	wound = 30

/datum/mod_theme/ninja
	name = "ninja"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	extended_desc = "A suit of nano-enhanced armor designed specifically for Spider Clan assassin-saboteurs. \
		This MODsuit employs the cutting edge of stealth and combat technology, built skin-tight but just as durable as \
		suits two or three times as thick. The nanomachines making up the outermost layer of armor \
		are capable of shifting their form into almost-microscopic radiating fins, rendering the suit itself \
		nigh-immune to even volcanic heat. It's entirely sealed against even the strongest acids, \
		and the myoelectric artifical muscles of the suit leave it light as a feather during movement."
	default_skin = "ninja"
	armor_type = /datum/armor/mod_theme_ninja
	resistance_flags = LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	ui_theme = "hackerman"
	inbuilt_modules = list(/obj/item/mod/module/welding/camera_vision, /obj/item/mod/module/hacker, /obj/item/mod/module/weapon_recall, /obj/item/mod/module/adrenaline_boost, /obj/item/mod/module/energy_net)
	allowed_suit_storage = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
	)
	skins = list(
		"ninja" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_ninja
	melee = 40
	bullet = 30
	laser = 20
	energy = 30
	bomb = 30
	bio = 100
	fire = 100
	acid = 100
	wound = 10

/datum/mod_theme/prototype
	name = "prototype"
	desc = "A prototype modular suit powered by locomotives. While it is comfortable and has a big capacity, it remains very bulky and power-inefficient."
	extended_desc = "This is a prototype powered exoskeleton, a design not seen in hundreds of years, the first \
		post-void war era modular suit to ever be safely utilized by an operator. This ancient clunker is still functional, \
		though it's missing several modern-day luxuries from updated Nakamura Engineering designs. \
		Primarily, the suit's myoelectric suit layer is entirely non-existant, and the servos do very little to \
		help distribute the weight evenly across the wearer's body, making it slow and bulky to move in. \
		The internal heads-up display is rendered in nearly unreadable cyan, as the visor suggests, \
		leaving the user unable to see long distances. However, the way the helmet retracts is pretty cool."
	default_skin = "prototype"
	armor_type = /datum/armor/mod_theme_prototype
	resistance_flags = FIRE_PROOF
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 5
	charge_drain = DEFAULT_CHARGE_DRAIN * 2
	slowdown_inactive = 2
	slowdown_active = 1.5
	ui_theme = "hackerman"
	inbuilt_modules = list(/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype)
	allowed_suit_storage = list(
		/obj/item/analyzer,
		/obj/item/t_scanner,
		/obj/item/pipe_dispenser,
		/obj/item/construction/rcd,
	)
	skins = list(
		"prototype" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_prototype
	melee = 20
	bullet = 5
	laser = 10
	energy = 10
	bomb = 50
	bio = 100
	fire = 100
	acid = 75
	wound = 5

/datum/mod_theme/responsory
	name = "responsory"
	desc = "A high-speed rescue suit by Nanotrasen, intended for its' emergency response teams."
	extended_desc = "A streamlined suit of Nanotrasen design, these sleek black suits are only worn by \
		elite emergency response personnel to help save the day. While the slim and nimble design of the suit \
		cuts the ceramics and ablatives in it down, dropping the protection, \
		it keeps the wearer safe from the harsh void of space while sacrificing no speed whatsoever. \
		While wearing it you feel an extreme deference to darkness. "
	default_skin = "responsory"
	armor_type = /datum/armor/mod_theme_responsory
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	skins = list(
		"responsory" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
		"inquisitory" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_responsory
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	bomb = 50
	bio = 100
	fire = 100
	acid = 90
	wound = 10

/datum/mod_theme/apocryphal
	name = "apocryphal"
	desc = "A high-tech, only technically legal, armored suit created by a collaboration effort between Nanotrasen and Apadyne Technologies."
	extended_desc = "A bulky and only legal by technicality suit, this ominous black and red MODsuit is only worn by \
		Nanotrasen Black Ops teams. If you can see this suit, you fucked up. A collaborative joint effort between \
		Apadyne and Nanotrasen the construction and modules gives the user robust protection against \
		anything that can be thrown at it, along with acute combat awareness tools for it's wearer. \
		Whether the wearer uses it or not is up to them. \
		There seems to be a little inscription on the wrist that reads; \'squiddie', d'aww."
	default_skin = "apocryphal"
	armor_type = /datum/armor/mod_theme_apocryphal
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	complexity_max = DEFAULT_MAX_COMPLEXITY + 10
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)
	skins = list(
		"apocryphal" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_apocryphal
	melee = 80
	bullet = 80
	laser = 50
	energy = 60
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	wound = 25

/datum/mod_theme/corporate
	name = "corporate"
	desc = "A fancy, high-tech suit for Nanotrasen's high ranking officers."
	extended_desc = "An even more costly version of the Magnate model, the corporate suit is a thermally insulated, \
		anti-corrosion coated suit for high-ranking CentCom Officers, deploying pristine protective armor and \
		advanced actuators, feeling practically weightless when turned on. Scraping the paint of this suit is \
		counted as a war-crime and reason for immediate execution in over fifty Nanotrasen space stations. \
		The resemblance to a Gorlex Marauder helmet is purely coincidental."
	default_skin = "corporate"
	armor_type = /datum/armor/mod_theme_corporate
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	skins = list(
		"corporate" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEYES|HIDEFACE,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_corporate
	melee = 50
	bullet = 40
	laser = 50
	energy = 50
	bomb = 50
	bio = 100
	fire = 100
	acid = 100
	wound = 15

/datum/mod_theme/chrono
	name = "chrono"
	desc = "A suit beyond our time, beyond time itself. Used to traverse timelines and \"correct their course\"."
	extended_desc = "A suit whose tech goes beyond this era's understanding. The internal mechanisms are all but \
		completely alien, but the purpose is quite simple. The suit protects the user from the many incredibly lethal \
		and sometimes hilariously painful side effects of jumping timelines, while providing inbuilt equipment for \
		making timeline adjustments to correct a bad course."
	default_skin = "chrono"
	armor_type = /datum/armor/mod_theme_chrono
	resistance_flags = FIRE_PROOF|ACID_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = DEFAULT_MAX_COMPLEXITY - 10
	slowdown_inactive = 0
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
	)
	skins = list(
		"chrono" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_chrono
	melee = 60
	bullet = 60
	laser = 60
	energy = 60
	bomb = 30
	bio = 100
	fire = 100
	acid = 100
	wound = 15

/datum/mod_theme/debug
	name = "debug"
	desc = "Strangely nostalgic."
	extended_desc = "An advanced suit that has dual ion engines powerful enough to grant a humanoid flight. \
		Contains an internal self-recharging high-current capacitor for short, powerful bo- \
		Oh wait, this is not actually a flight suit. Fuck."
	default_skin = "debug"
	armor_type = /datum/armor/mod_theme_debug
	resistance_flags = FIRE_PROOF|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	complexity_max = 50
	siemens_coefficient = 0
	slowdown_inactive = 0.5
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	skins = list(
		"debug" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH,
				SEALED_COVER = HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_debug
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/datum/mod_theme/administrative
	name = "administrative"
	desc = "A suit made of adminium. Who comes up with these stupid mineral names?"
	extended_desc = "Yeah, okay, I guess you can call that an event. What I consider an event is something actually \
		fun and engaging for the players- instead, most were sitting out, dead or gibbed, while the lucky few got to \
		have all the fun. If this continues to be a pattern for your \"events\" (Admin Abuse) \
		there will be an admin complaint. You have been warned."
	default_skin = "debug"
	armor_type = /datum/armor/mod_theme_administrative
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	complexity_max = 1000
	charge_drain = DEFAULT_CHARGE_DRAIN * 0
	siemens_coefficient = 0
	slowdown_inactive = 0
	slowdown_active = 0
	allowed_suit_storage = list(
		/obj/item/gun,
	)
	skins = list(
		"debug" = list(
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEEARS|HIDEHAIR|HIDESNOUT,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|BLOCKS_SHOVE_KNOCKDOWN,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
			),
		),
	)

/datum/armor/mod_theme_administrative
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	wound = 100
