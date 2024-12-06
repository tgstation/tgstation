/datum/export/epic_loot_components
	cost = PAYCHECK_COMMAND
	unit_name = "low value salvage"
	export_types = list(
		/obj/item/epic_loot/grenade_fuze,
		/obj/item/epic_loot/nail_box,
		/obj/item/epic_loot/cold_weld,
		/obj/item/epic_loot/signal_amp,
		/obj/item/epic_loot/fuel_conditioner,
	)

/datum/export/epic_loot_components_super
	cost = PAYCHECK_COMMAND * 2
	unit_name = "salvage"
	export_types = list(
		/obj/item/epic_loot/water_filter,
		/obj/item/epic_loot/thermometer,
		/obj/item/epic_loot/current_converter,
		/obj/item/epic_loot/electric_motor,
	)

/datum/export/epic_loot_components_super_super
	cost = PAYCHECK_COMMAND * 3
	unit_name = "high value salvage"
	export_types = list(
		/obj/item/epic_loot/thermal_camera,
		/obj/item/epic_loot/shuttle_gyro,
		/obj/item/epic_loot/phased_array,
		/obj/item/epic_loot/shuttle_battery,
	)

// Grenade fuze, an old design from an old time past. You can still make a pretty good grenade with it though
/obj/item/epic_loot/grenade_fuze
	name = "grenade fuze"
	desc = "Just the fuze of a grenade, missing the explosive and arguably most important half of the grenade."
	icon_state = "fuze"
	inhand_icon_state = "pen"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
	)

// The filter part of a water filter machine, though these machines are insanely rare due to modern synthesis technology
/obj/item/epic_loot/water_filter
	name = "water filter cartridge"
	desc = "A blue polymer tube filled with filter medium for use in an industrial water filtration unit."
	icon_state = "water_filter"
	inhand_icon_state = "miniFE"
	drop_sound = 'sound/items/handling/tools/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/weldingtool_pickup.ogg'
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)

// Analog thermometer, how to tell temperature before gas analyzers were cool
/obj/item/epic_loot/thermometer
	name = "analog thermometer"
	desc = "An outdated, and likely broken, analog thermometer."
	icon_state = "thermometer"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/tools/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/multitool_pickup.ogg'
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)

// A box of nails, impossible tech on a space station
/obj/item/epic_loot/nail_box
	name = "box of nails"
	desc = "A pristine box of nails, a method of keeping things together that we... can't really use here, in a space station."
	icon_state = "nails"
	inhand_icon_state = "rubberducky"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/cardboard = SHEET_MATERIAL_AMOUNT,
	)

// Used for joining together plastics, ideally.
/obj/item/epic_loot/cold_weld
	name = "tube of cold weld"
	desc = "A tube of cold weld, used to join together plastics, usually for repair."
	icon_state = "cold_weld"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT,
	)

// An electronic motor
/obj/item/epic_loot/electric_motor
	name = "electric motor"
	desc = "An electrically driven motor for industrial applications."
	icon_state = "motor"
	inhand_icon_state = "miniFE"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
	)

// Current converters, these change one rating of current into another in a mostly safe manner
/obj/item/epic_loot/current_converter
	name = "current converter"
	desc = "A device for regulating electric current that passes through it."
	icon_state = "current_converter"
	inhand_icon_state = "miniFE"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/tools/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/weldingtool_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)

// Signal amplifiers, used to take a faint signal and return it stronger than before
/obj/item/epic_loot/signal_amp
	name = "signal amplifier"
	desc = "A device for taking weakened input signals and strengthening them for use or listening."
	icon_state = "signal_amp"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)

// Thermal camera modules
/obj/item/epic_loot/thermal_camera
	name = "thermal camera module"
	desc = "An infrared sensing device used for the production of thermal camera systems."
	icon_state = "thermal"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)

// Shuttle gyroscopes, AKA how a shuttle realizes which way it's pointing
/obj/item/epic_loot/shuttle_gyro
	name = "shuttle gyroscope"
	desc = "A bulky device used by shuttles and other space faring vessels to find the direction they are facing."
	icon_state = "shuttle_gyro"
	inhand_icon_state = "miniFE"
	w_class = WEIGHT_CLASS_BULKY
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 4
	)

/obj/item/epic_loot/shuttle_gyro/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

// Phased array elements, combine a bunch together to get god's strongest radar, or whatever else you can think of
/obj/item/epic_loot/phased_array
	name = "phased array element"
	desc = "An element of a larger phased array. These combine together to produce sensing and scanning devices used on most common space-faring vessels."
	icon_state = "phased_array"
	inhand_icon_state = "blankplaque"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)

// Shuttle batteries, used to power electronics while the engines are off
/obj/item/epic_loot/shuttle_battery
	name = "shuttle battery"
	desc = "A massive shuttle-grade battery, used to keep the electronics of space-faring vessel powered while the main engines are de-activated."
	icon_state = "ship_battery"
	inhand_icon_state = "blankplaque"
	w_class = WEIGHT_CLASS_BULKY
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	custom_materials = list(
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 10,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT * 4,
	)

/obj/item/epic_loot/shuttle_battery/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

// Industrial fuel conditioner, used to keep most fuel-burning machines within regulations for waste emissions
/obj/item/epic_loot/fuel_conditioner
	name = "fuel conditioner"
	desc = "A plastic container of fuel conditioner for industrial size plasma generators. \
		Any generator that would need this is either much too large or much too old to be seen around here."
	icon_state = "fuel_conditioner"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
