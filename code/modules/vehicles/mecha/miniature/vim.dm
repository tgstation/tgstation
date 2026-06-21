/**
 * ## VIM!!!!!!!
 *
 * It's a teenie miniature mecha... for critters!
 * For the critters that cannot be understood, there is a sound creator in the mecha. It also has headlights.
 */
/obj/vehicle/sealed/mecha/vim
	name = "\improper Vim"
	desc = "A miniature exosuit from Nanotrasen, developed to let the irreplaceable station pets live a little longer."
	icon_state = "vim"
	base_icon_state = "vim"
	max_integrity = 50
	armor_type = /datum/armor/mecha_vim
	enter_delay = 2 SECONDS
	movedelay = 0.6
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 1.5
	light_on = FALSE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.55, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.7)
	stepsound = 'sound/effects/servostep.ogg'
	pivot_step = TRUE
	step_energy_drain = 4
	mecha_flags = CAN_STRAFE | HAS_LIGHTS | IS_ENCLOSED
	mech_type = EXOSUIT_MODULE_VIM
	interaction_flags_mouse_drop = NONE
	move_force = MOVE_FORCE_EXTREMELY_WEAK
	move_resist = MOVE_FORCE_VERY_WEAK
	density = FALSE
	pass_flags = PASSVEHICLE | PASSMOB | PASSTABLE
	pass_flags_self = PASSVEHICLE | PASSMOB | PASSTABLE
	inertia_force_weight = 0.5 // lighter than other mechs and people
	accesses = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	ui_theme = PDA_THEME_CAT // since the mech is for pets ~NYAAAA~
	equip_by_category = list(
		MECHA_L_ARM = null, // armless mech
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	max_equip_by_category = list(
		MECHA_L_ARM = 0, // armless mech
		MECHA_R_ARM = 0,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	///Maximum size of a mob trying to enter the mech
	var/maximum_mob_size = MOB_SIZE_SMALL
	COOLDOWN_DECLARE(sound_cooldown)

/datum/armor/mecha_vim
	melee = 70
	bullet = 40
	laser = 40
	bomb = 30
	fire = 80
	acid = 80

/obj/vehicle/sealed/mecha/vim/mob_try_enter(mob/entering)
	if(issilicon(entering))
		entering.balloon_alert(entering, "can't fit inside!")
		return FALSE

	var/mob/living/animal_or_basic = entering
	if(animal_or_basic.mob_size > maximum_mob_size)
		entering.balloon_alert(entering, "can't fit inside!")
		return FALSE

	mob_enter(entering)
	moved_inside(entering)

/obj/vehicle/sealed/mecha/vim/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/chime, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/buzz, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/mecha/vim/toggle_lights(forced_state = null, mob/user)
	. = ..()
	update_appearance()

/obj/vehicle/sealed/mecha/vim/update_overlays()
	. = ..()
	if(mecha_flags & LIGHTS_ON)
		. += mutable_appearance(icon, "vim_headlights")
