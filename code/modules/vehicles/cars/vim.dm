/**
 * ## VIM!!!!!!!
 *
 * It's a teenie minature mecha... for critters!
 * For the critters that cannot be understood, there is a sound creator in the mecha. It also has headlights.
 */
/obj/vehicle/sealed/car/vim
	name = "\improper Vim"
	desc = "An minature exosuit from Nanotrasen, developed to let the irreplacable station pets live a little longer."
	icon_state = "crittermecha_empty"
	max_integrity = 50
	armor = list(MELEE = 70, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 80)
	enter_delay = 20
	movedelay = 0.6
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 2
	light_on = FALSE
	engine_sound = 'sound/effects/servostep.ogg'
	COOLDOWN_DECLARE(sound_cooldown)

/obj/vehicle/sealed/car/vim/mob_try_enter(mob/entering)
	if(!isanimal(entering))
		return FALSE
	var/mob/living/simple_animal/animal = entering
	if(animal.mob_size != MOB_SIZE_TINY)
		return FALSE
	. = ..()

/obj/vehicle/sealed/car/vim/generate_actions()
	initialize_controller_action_type(/datum/action/vehicle/sealed/climb_out/vim, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/chime, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/buzz, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/vim/update_overlays()
	. = ..()
	var/static/piloted_overlay
	var/static/headlights_overlay
	if(isnull(piloted_overlay))
		piloted_overlay = iconstate2appearance(icon, "crittermecha_piloted")
		headlights_overlay = iconstate2appearance(icon, "crittermecha_headlights")

	var/list/drivers = return_drivers()
	if(drivers.len)
		. += piloted_overlay
	if(headlights_toggle)
		. += headlights_overlay
