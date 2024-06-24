
#define CM_COLOR_HUE 1
#define CM_COLOR_SATURATION 2
#define CM_COLOR_LUMINANCE 3

#define CM_COLOR_SAT_MAX 90 // 90% saturation is the default ceiling
#define CM_COLOR_LUM_MIN 40 // 40% luminosity is the default floor
#define CM_COLOR_LUM_MIN_GREY 35 // 35% luminosity for greys
#define CM_COLOR_LUM_MAX_DARK_RANGE 45 // 45% luminosity for dark blues/reds/violets

#define CM_COLOR_HUE_RANGE_LOWER 180
#define CM_COLOR_HUE_RANGE_UPPER 350
#define CM_COLOR_HUE_GREY 0

/**
 * Converts a given color to comply within a smaller subset of colors to be used in runechat.
 * If a color is outside the min/max saturation or lum, it will be set at the nearest
 * value that passes validation.
 *
 * Arguments:
 * * color - The color to process
 * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
 * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
 */
/proc/process_chat_color(color, sat_shift = 1, lum_shift = 1)
	if(isnull(color))
		return "#FFFFFF"

	// Convert color hex to HSL
	var/hsl_color = rgb2num(color, COLORSPACE_HSL)

	// Hue / saturation / luminance
	var/hue = hsl_color[CM_COLOR_HUE]
	var/saturation = hsl_color[CM_COLOR_SATURATION]
	var/luminance = hsl_color[CM_COLOR_LUMINANCE]

	// Cap the saturation at 90%
	saturation = min(saturation, CM_COLOR_SAT_MAX)

	// Now clamp the luminance according to the hue
	var/processed_luminance

	// There are special cases for greyscale and the red/blue/violet range
	if(hue == CM_COLOR_HUE_GREY)
		processed_luminance = max(luminance, CM_COLOR_LUM_MIN_GREY) // greys have a lower floor on the allowed luminance value than the default
	else if(CM_COLOR_HUE_RANGE_UPPER > hue > CM_COLOR_HUE_RANGE_LOWER)
		processed_luminance = min(luminance, CM_COLOR_LUM_MAX_DARK_RANGE) // colors in the deep reds/blues/violets range will have a slightly higher luminance floor than the default
	else
		processed_luminance = max(luminance, CM_COLOR_LUM_MIN) // everything else gets the default floor

	// Convert it back to a hex
	return rgb(hue, saturation*sat_shift, processed_luminance*lum_shift, space = COLORSPACE_HSL)

#undef CM_COLOR_HUE
#undef CM_COLOR_SATURATION
#undef CM_COLOR_LUMINANCE

#undef CM_COLOR_SAT_MAX
#undef CM_COLOR_LUM_MIN
#undef CM_COLOR_LUM_MIN_GREY
#undef CM_COLOR_LUM_MAX_DARK_RANGE

#undef CM_COLOR_HUE_RANGE_LOWER
#undef CM_COLOR_HUE_RANGE_UPPER
#undef CM_COLOR_HUE_GREY

// Yeah I'm using datums for this, because the code on a regular gun would suck huge
// Holds a lot of information that will be applied ot the gun, as well as info that the gun will read later
// This basetype is applies to the base 2 burst laser kill mode for the large laser gun
/datum/laser_weapon_mode
	/// What name does this weapon mode have? Will appear in the weapon's radial menu
	var/name = "Kill"
	/// What casing does this variant of weapon use?
	var/obj/item/ammo_casing/casing = /obj/item/ammo_casing/energy/cybersun_big_kill
	/// What icon_state does this weapon mode use?
	var/weapon_icon_state = "kill"
	/// How many charge sections does this variant of weapon have?
	var/charge_sections = 5
	/// What is the shot cooldown this variant applies to the weapon?
	var/shot_delay = 0.3 SECONDS
	/// What json string do we check for when making chat messages with this mode?
	var/json_speech_string = "kill"
	/// What do we change the gun's runetext color to when applied
	var/gun_runetext_color = "#cd4456"

/// Applies some of the universal stats from the variables above
/datum/laser_weapon_mode/proc/apply_stats(obj/item/gun/energy/applied_gun)
	if(length(applied_gun.ammo_type))
		for(var/found_casing as anything in applied_gun.ammo_type)
			applied_gun.ammo_type.Remove(found_casing)
			qdel(found_casing)
	applied_gun.ammo_type.Add(casing)
	applied_gun.update_ammo_types()
	applied_gun.charge_sections = charge_sections
	applied_gun.fire_delay = shot_delay
	var/new_icon_state = "[applied_gun.base_icon_state]_[weapon_icon_state]"
	applied_gun.icon_state = new_icon_state
	applied_gun.inhand_icon_state = new_icon_state
	applied_gun.worn_icon_state = new_icon_state
	applied_gun.update_appearance()
	applied_gun.chat_color = gun_runetext_color
	applied_gun.chat_color_darkened = process_chat_color(gun_runetext_color, sat_shift = 0.85, lum_shift = 0.85)

/// Stuff applied to the passed gun when the weapon mode is given to the gun
/datum/laser_weapon_mode/proc/apply_to_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.burst_size = 2

/// Stuff applied to the passed gun when the weapon mode is removed from the gun
/datum/laser_weapon_mode/proc/remove_from_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.burst_size = 1

// Marksman mode for the large laser, adds a scope, slower firing rate, and really quick projectiles
/datum/laser_weapon_mode/marksman
	name = "Marksman"
	casing = /obj/item/ammo_casing/energy/cybersun_big_sniper
	weapon_icon_state = "sniper"
	shot_delay = 2 SECONDS
	json_speech_string = "sniper"
	gun_runetext_color = "#f8d860"
	/// Keeps track of the scope component for deleting later
	var/datum/component/scope/scope_component

/datum/laser_weapon_mode/marksman/apply_to_weapon(obj/item/gun/energy/applied_gun)
	scope_component = applied_gun.AddComponent(/datum/component/scope, 3)

/datum/laser_weapon_mode/marksman/remove_from_weapon(obj/item/gun/energy/applied_gun)
	QDEL_NULL(scope_component)

// Windup autofire disabler mode for the large laser
/datum/laser_weapon_mode/disabler_machinegun
	name = "Disable"
	casing = /obj/item/ammo_casing/energy/cybersun_big_disabler
	weapon_icon_state = "disabler"
	charge_sections = 2
	shot_delay = 0.25 SECONDS
	json_speech_string = "disable"
	gun_runetext_color = "#47a1b3"
	/// Keeps track of the autofire component for deleting later
	var/datum/component/automatic_fire/autofire_component

/datum/laser_weapon_mode/disabler_machinegun/apply_to_weapon(obj/item/gun/energy/applied_gun)
	autofire_component = applied_gun.AddComponent(/datum/component/automatic_fire, shot_delay)

/datum/laser_weapon_mode/disabler_machinegun/remove_from_weapon(obj/item/gun/energy/applied_gun)
	QDEL_NULL(autofire_component)

// Grenade launching mode for the large laser
/datum/laser_weapon_mode/launcher
	name = "Launcher"
	casing = /obj/item/ammo_casing/energy/cybersun_big_launcher
	weapon_icon_state = "launcher"
	charge_sections = 3
	shot_delay = 2 SECONDS
	json_speech_string = "launcher"
	gun_runetext_color = "#77bd5d"

/datum/laser_weapon_mode/launcher/apply_to_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = 2

/datum/laser_weapon_mode/launcher/remove_from_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = initial(applied_gun.recoil)

// Shotgun mode for the large laser
/datum/laser_weapon_mode/shotgun
	name = "Shotgun"
	casing = /obj/item/ammo_casing/energy/cybersun_big_shotgun
	weapon_icon_state = "shot"
	charge_sections = 3
	shot_delay = 0.75 SECONDS
	json_speech_string = "shotgun"
	gun_runetext_color = "#7a0bb7"

/datum/laser_weapon_mode/shotgun/apply_to_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = 1

/datum/laser_weapon_mode/shotgun/remove_from_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = initial(applied_gun.recoil)

// Hellfire mode for the small laser
/datum/laser_weapon_mode/hellfire
	name = "Incinerate"
	casing = /obj/item/ammo_casing/energy/cybersun_small_hellfire
	weapon_icon_state = "kill"
	charge_sections = 3
	shot_delay = 0.4 SECONDS
	json_speech_string = "incinerate"
	gun_runetext_color = "#cd4456"

/datum/laser_weapon_mode/hellfire/apply_to_weapon(obj/item/gun/energy/applied_gun)
	return

/datum/laser_weapon_mode/hellfire/remove_from_weapon(obj/item/gun/energy/applied_gun)
	return

// Melee mode for the small laser, yeah this one will be weird
/datum/laser_weapon_mode/sword
	name = "Blade"
	// This mode doesn't actually shoot but we gotta have a casing regardless so it doesn't runtime times a million
	// And also so the visuals work :3
	casing = /obj/item/ammo_casing/energy/cybersun_small_blade
	weapon_icon_state = "blade"
	charge_sections = 2
	json_speech_string = "blade"
	gun_runetext_color = "#f8d860"

/datum/laser_weapon_mode/sword/apply_to_weapon(obj/item/gun/energy/modular_laser_rifle/applied_gun)
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE)
	applied_gun.force = 18
	applied_gun.sharpness = SHARP_EDGED
	applied_gun.bare_wound_bonus = 10
	applied_gun.disabled_for_other_reasons = TRUE
	applied_gun.attack_verb_continuous = list("slashes", "cuts")
	applied_gun.attack_verb_simple = list("slash", "cut")
	applied_gun.hitsound = 'sound/weapons/rapierhit.ogg'

/datum/laser_weapon_mode/sword/remove_from_weapon(obj/item/gun/energy/modular_laser_rifle/applied_gun)
	playsound(src, 'sound/items/sheath.ogg', 25, TRUE)
	applied_gun.force = initial(applied_gun.force)
	applied_gun.sharpness = initial(applied_gun.sharpness)
	applied_gun.bare_wound_bonus = initial(applied_gun.bare_wound_bonus)
	applied_gun.disabled_for_other_reasons = FALSE
	applied_gun.attack_verb_continuous = initial(applied_gun.attack_verb_continuous)
	applied_gun.attack_verb_simple = initial(applied_gun.attack_verb_simple)
	applied_gun.hitsound = initial(applied_gun.hitsound)

// Flare mode for the small laser
/datum/laser_weapon_mode/flare
	name = "Flare"
	casing = /obj/item/ammo_casing/energy/cybersun_small_launcher
	weapon_icon_state = "flare"
	charge_sections = 3
	shot_delay = 2 SECONDS
	json_speech_string = "flare"
	gun_runetext_color = "#77bd5d"

/datum/laser_weapon_mode/flare/apply_to_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = 2

/datum/laser_weapon_mode/flare/remove_from_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = initial(applied_gun.recoil)

// Shotgun mode for the small laser
/datum/laser_weapon_mode/shotgun_small
	name = "Shotgun"
	casing = /obj/item/ammo_casing/energy/cybersun_small_shotgun
	weapon_icon_state = "shot"
	charge_sections = 3
	shot_delay = 0.6 SECONDS
	json_speech_string = "shotgun"
	gun_runetext_color = "#7a0bb7"

/datum/laser_weapon_mode/shotgun_small/apply_to_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = 1

/datum/laser_weapon_mode/shotgun_small/remove_from_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.recoil = initial(applied_gun.recoil)

// Trickshot bounce disabler mode for the small laser
/datum/laser_weapon_mode/trickshot_disabler
	name = "Disable"
	casing = /obj/item/ammo_casing/energy/cybersun_small_disabler
	weapon_icon_state = "disable"
	charge_sections = 3
	shot_delay = 0.4 SECONDS
	json_speech_string = "disable"
	gun_runetext_color = "#47a1b3"

/datum/laser_weapon_mode/trickshot_disabler/apply_to_weapon(obj/item/gun/energy/applied_gun)
	return

/datum/laser_weapon_mode/trickshot_disabler/remove_from_weapon(obj/item/gun/energy/applied_gun)
	return
