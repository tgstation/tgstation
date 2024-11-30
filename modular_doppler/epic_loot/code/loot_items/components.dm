/datum/export/epic_loot_components
	cost = PAYCHECK_COMMAND
	unit_name = "components"
	export_types = list(
		/obj/item/epic_loot/grenade_fuze,
		/obj/item/epic_loot/nail_box,
		/obj/item/epic_loot/cold_weld,
		/obj/item/epic_loot/signal_amp,
		/obj/item/epic_loot/fuel_conditioner,
		/obj/item/epic_loot/aramid,
		/obj/item/epic_loot/cordura,
		/obj/item/epic_loot/ripstop,
	)

/datum/export/epic_loot_components_super
	cost = PAYCHECK_COMMAND * 2
	unit_name = "valuable components"
	export_types = list(
		/obj/item/epic_loot/water_filter,
		/obj/item/epic_loot/thermometer,
		/obj/item/epic_loot/current_converter,
		/obj/item/epic_loot/electric_motor,
		/obj/item/epic_loot/thermal_camera,
		/obj/item/epic_loot/shuttle_gyro,
		/obj/item/epic_loot/phased_array,
		/obj/item/epic_loot/shuttle_battery,
	)

// Grenade fuze, an old design from an old time past. You can still make a pretty good grenade with it though
/obj/item/epic_loot/grenade_fuze
	name = "grenade fuze"
	desc = "The fuze of an older grenade type that used to see common use around known space."
	icon_state = "fuze"
	inhand_icon_state = "pen"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

/obj/item/epic_loot/grenade_fuze/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> plasma explosive can be traded for <b>2</b> offensive impact grenades.")
	. += span_notice("- <b>1</b> of these + <b>1</b> plasma explosive + <b>1</b> box of nails can be traded for <b>1</b> frag grenade.")
	. += span_notice("- <b>1</b> of these + <b>1</b> water filter cartridge can be traded for <b>2</b> improvised explosives.")

	return .


// The filter part of a water filter machine, though these machines are insanely rare due to modern synthesis technology
/obj/item/epic_loot/water_filter
	name = "water filter cartridge"
	desc = "A blue polymer tube filled with filter medium for use in an industrial water filtration unit."
	icon_state = "water_filter"
	inhand_icon_state = "miniFE"
	drop_sound = 'sound/items/handling/tools/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/weldingtool_pickup.ogg'

/obj/item/epic_loot/water_filter/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> suppressor.")
	. += span_notice("- <b>1</b> of these + <b>1</b> grenade fuze can be traded for <b>2</b> improvised explosives.")

	return .

// Analog thermometer, how to tell temperature before gas analyzers were cool
/obj/item/epic_loot/thermometer
	name = "analog thermometer"
	desc = "A highly outdated, and likely broken, analog thermometer."
	icon_state = "thermometer"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/tools/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/multitool_pickup.ogg'

/obj/item/epic_loot/thermometer/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>2</b> flashbangs.")
	. += span_notice("- <b>1</b> of these + <b>1</b> box of nails can be traded for <b>2</b> stingbangs.")

	return .

// A box of nails, impossible tech on a space station
/obj/item/epic_loot/nail_box
	name = "box of nails"
	desc = "A pristine box of nails, a method of keeping things together that happens to be insanely rare in space."
	icon_state = "nails"
	inhand_icon_state = "rubberducky"
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5,\
							/datum/material/cardboard = SHEET_MATERIAL_AMOUNT,)

/obj/item/epic_loot/nail_box/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> analog thermometer can be traded for <b>2</b> stingbangs.")
	. += span_notice("- <b>1</b> of these + <b>1</b> plasma explosive + <b>1</b> grenade fuze can be traded for <b>1</b> frag grenades.")

	return .

// Used for joining together plastics, ideally.
/obj/item/epic_loot/cold_weld
	name = "tube of cold weld"
	desc = "A tube of cold weld, used to join together plastics, usually for repair."
	icon_state = "cold_weld"
	inhand_icon_state = "razor"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

/obj/item/epic_loot/cold_weld/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> thermal camera module + <b>1</b> signal amplifier can be traded for <b>1</b> motion detector.")

	return .

// An electronic motor
/obj/item/epic_loot/electric_motor
	name = "electric motor"
	desc = "An electrically driven motor for industrial applications."
	icon_state = "motor"
	inhand_icon_state = "miniFE"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*8, \
						/datum/material/iron = SMALL_MATERIAL_AMOUNT*2, \
						/datum/material/silver = SMALL_MATERIAL_AMOUNT*1,)

/obj/item/epic_loot/electric_motor/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> type II 'Kastrol' helmet.")

	return .

// Current converters, these change one rating of current into another in a mostly safe manner
/obj/item/epic_loot/current_converter
	name = "current converter"
	desc = "A device for regulating electric current that passes through it."
	icon_state = "current_converter"
	inhand_icon_state = "miniFE"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/tools/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/tools/weldingtool_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT*2, \
						/datum/material/silver = SHEET_MATERIAL_AMOUNT, \
						/datum/material/gold = SHEET_MATERIAL_AMOUNT,)

/obj/item/epic_loot/current_converter/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> signal amplifier can be traded for <b>1</b> pair of night vision goggles.")

	return .

// Signal amplifiers, used to take a faint signal and return it stronger than before
/obj/item/epic_loot/signal_amp
	name = "signal amplifier"
	desc = "A device for taking weakened input signals and strengthening them for use or listening."
	icon_state = "signal_amp"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

/obj/item/epic_loot/signal_amp/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> current converter can be traded for <b>1</b> pair of night vision goggles.")
	. += span_notice("- <b>1</b> of these + <b>1</b> thermal camera module + <b>1</b> tube of cold weld can be traded for <b>1</b> motion detector")

	return .

// Thermal camera modules
/obj/item/epic_loot/thermal_camera
	name = "thermal camera module"
	desc = "An infrared sensing device used for the production of thermal camera systems."
	icon_state = "thermal"
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

/obj/item/epic_loot/thermal_camera/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> signal amplifier + <b>1</b> tube of cold weld can be traded for <b>1</b> motion detector.")

	return .

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

/obj/item/epic_loot/shuttle_gyro/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> implanted armblade.")
	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> type II 'Muur' vest.")

	return .

// Phased array elements, combine a bunch together to get god's strongest radar, or whatever else you can think of
/obj/item/epic_loot/phased_array
	name = "phased array element"
	desc = "An element of a larger phased array. These combine together to produce sensing and scanning devices used on most common space-faring vessels."
	icon_state = "phased_array"
	inhand_icon_state = "blankplaque"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT*2, \
						/datum/material/silver = SHEET_MATERIAL_AMOUNT, \
						/datum/material/gold = SHEET_MATERIAL_AMOUNT,)

/obj/item/epic_loot/phased_array/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> bowman headset.")

	return .

// Shuttle batteries, used to power electronics while the engines are off
/obj/item/epic_loot/shuttle_battery
	name = "shuttle battery"
	desc = "A massive shuttle-grade battery, used to keep the electronics of space-faring vessel powered while the main engines are de-activated."
	icon_state = "ship_battery"
	inhand_icon_state = "blankplaque"
	w_class = WEIGHT_CLASS_BULKY
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT*10, \
						/datum/material/silver = SHEET_MATERIAL_AMOUNT*4, \
						/datum/material/gold = SHEET_MATERIAL_AMOUNT*4,)

/obj/item/epic_loot/shuttle_battery/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/epic_loot/shuttle_battery/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Weapons Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> energy sword.")
	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> type II 'Muur' helmet.")

	return .

// Industrial fuel conditioner, used to keep most fuel-burning machines within regulations for waste emissions
/obj/item/epic_loot/fuel_conditioner
	name = "fuel conditioner"
	desc = "A polymer canister of advanced fuel conditioner, used to keep fuel burning vehicles and machines burning relatively clean."
	icon_state = "fuel_conditioner"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'
	pickup_sound = 'sound/items/handling/cardboard_box/cardboardbox_pickup.ogg'

/obj/item/epic_loot/fuel_conditioner/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> frontier headset.")

	return .

// Bullet and stab resistant fabric, use lots to make something stop bullets a bit better
/obj/item/epic_loot/aramid
	name = "high-resistance fabric"
	desc = "A yellow weaved fabric that has exceptional resistance to piercing and slashing, as well as a number of other common damage sources."
	icon_state = "aramid"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'

/obj/item/epic_loot/aramid/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these can be traded for <b>1</b> type I 'Kami' vest.")
	. += span_notice("- <b>1</b> of these + <b>1</b> appendix can be traded for <b>1</b> type II 'Koranda' vest.")

	return .

// You know they make your pouches and such out of this stuff?
/obj/item/epic_loot/cordura
	name = "polymer weave fabric"
	desc = "Common high-strength fabric used in the production of a large amount of equipment."
	icon_state = "cordura"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'

/obj/item/epic_loot/cordura/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> tear-resistant fabric can be traded for <b>1</b> type II 'Touvou' vest.")

	return .

// It's like the one above but for different stuff
/obj/item/epic_loot/ripstop
	name = "tear-resistant fabric"
	desc = "A reinforced fabric made to be highly resistant to tearing, and to have a limited ability to repair itself."
	icon_state = "ripstop"
	w_class = WEIGHT_CLASS_NORMAL
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'

/obj/item/epic_loot/ripstop/examine_more(mob/user)
	. = ..()

	. += span_notice("<b>Armor Trade Station:</b>")
	. += span_notice("- <b>1</b> of these + <b>1</b> polymer weave fabric can be traded for <b>1</b> type II 'Touvou' vest.")

	return .
