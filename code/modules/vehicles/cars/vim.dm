/**
 * ## VIM!!!!!!!
 *
 * It's a teenie minature mecha... for critters!
 * For the critters that cannot be understood, there is a sound creator in the mecha. It also has headlights.
 */
/obj/vehicle/sealed/car/vim
	name = "\improper Vim"
	desc = "An minature exosuit from Nanotrasen, developed to let the irreplacable station pets live a little longer."
	icon_state = "vim"
	max_integrity = 50
	armor = list(MELEE = 70, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 80, ACID = 80)
	enter_delay = 20
	movedelay = 0.6
	engine_sound_length = 0.3 SECONDS
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 2
	light_on = FALSE
	engine_sound = 'sound/effects/servostep.ogg'
	///TRUE while the vim is being welded
	var/being_repaired = FALSE
	COOLDOWN_DECLARE(sound_cooldown)

/obj/vehicle/sealed/car/vim/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be repaired with a welder.")

/obj/vehicle/sealed/car/vim/atom_destruction(damage_flag)
	new /obj/effect/decal/cleanable/oil(get_turf(src))
	do_sparks(5, TRUE, src)
	visible_message(span_boldannounce("[src] blows apart!"))
	return ..()

/obj/vehicle/sealed/car/vim/mob_try_enter(mob/entering)
	if(!isanimal_or_basicmob(entering))
		return FALSE
	var/mob/living/animal_or_basic = entering
	if(animal_or_basic.atom_size != MOB_SIZE_TINY)
		return FALSE
	return ..()

/obj/vehicle/sealed/car/vim/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	. = TRUE
	if(!tool.tool_start_check(user))
		return
	if(being_repaired)
		user.balloon_alert(user, "already being repaired!")
		return
	if(atom_integrity == max_integrity)
		user.balloon_alert(user, "already fully repaired!")
		return

	user.balloon_alert(user, "repairing [src]...")
	audible_message(span_hear("You hear welding."))
	being_repaired = TRUE
	if(!tool.use_tool(src, user, 3 SECONDS, volume=50))
		being_repaired = FALSE
		user.balloon_alert(user, "interrupted!")
		return
	being_repaired = FALSE

	atom_integrity = min(atom_integrity + VIM_HEAL_AMOUNT, max_integrity)
	user.balloon_alert(user, "[atom_integrity == max_integrity ? "fully " : ""]repaired [src]")

/obj/vehicle/sealed/car/vim/mob_enter(mob/newoccupant, silent = FALSE)
	. = ..()
	update_appearance()
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	if(atom_integrity == max_integrity)
		SEND_SOUND(newoccupant, sound('sound/mecha/nominal.ogg',volume=50))

/obj/vehicle/sealed/car/vim/generate_actions()
	initialize_controller_action_type(/datum/action/vehicle/sealed/climb_out/vim, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/chime, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/buzz, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights/vim, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/vim/update_overlays()
	. = ..()
	var/static/piloted_overlay
	var/static/headlights_overlay
	if(isnull(piloted_overlay))
		piloted_overlay = iconstate2appearance(icon, "vim_piloted")
		headlights_overlay = iconstate2appearance(icon, "vim_headlights")

	var/list/drivers = return_drivers()
	if(drivers.len)
		. += piloted_overlay
	if(headlights_toggle)
		. += headlights_overlay
