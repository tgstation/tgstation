///how much time between charge_level going up by 1
#define SKYFALL_SINGLE_CHARGE_TIME 2 SECONDS
///enough charge level to take off, basically done charging
#define SKYFALL_CHARGELEVEL_LAUNCH 5

///the first half of the leap, where the mech is flying upwards.
#define SKYFALL_LEAP_ARCING_UP 1
///the second half of the leap, where the mech is flying downwards.
#define SKYFALL_LEAP_ARCING_DOWN 1
///how much time you're in the air
#define TOTAL_SKYFALL_LEAP_TIME 3 SECONDS

/**
 * ## Savannah-Ivanov!
 *
 * A two person mecha that delegates moving to the driver and shooting to the pilot.
 * ...Hilarious, right?
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov
	name = "\improper Savannah-Ivanov"
	desc = "An insanely overbulked mecha that handily crushes single-pilot opponents. The price is that you need two pilots to use it."
	icon = 'icons/mecha/coop_mech.dmi'
	base_icon_state = "savannah_ivanov"
	icon_state = "savannah_ivanov_0_0"
	//does not include mmi compatibility
	mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS
	movedelay = 3
	dir_in = 2 //Facing South.
	max_integrity = 450 //really tanky, like damn
	deflect_chance = 25
	armor = list(MELEE = 45, BULLET = 40, LASER = 30, ENERGY = 30, BOMB = 40, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 30000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/savannah_ivanov
	internal_damage_threshold = 25
	max_occupants = 2
	//no tax on flying, since the power cost is in the leap itself.
	phasing_energy_drain = 0
	///skyfall ability cooldown
	COOLDOWN_DECLARE(skyfall_cooldown)
	///cooldown time between skyfall uses
	var/skyfall_cooldown_time = 1 MINUTES
	///skyfall builds up in charges every 2 seconds, when it reaches 5 charges the ability actually starts
	var/skyfall_charge_level = 0

	///ivanov strike ability cooldown
	COOLDOWN_DECLARE(strike_cooldown)
	///cooldown time between strike uses
	var/strike_cooldown_time = 40 SECONDS
	///toggled by ivanov strike, TRUE when signals are hooked to intercept clicks.
	var/aiming_ivanov = FALSE
	///how many rockets can we send with ivanov strike
	var/rockets_left = 0

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	var/leap_state = skyfall_charge_level > 2 ? "leap_" : ""
	return "[base_icon_state]_[leap_state][gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/skyfall, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/remove_occupant(mob/getting_out)
	//gunner getting out ends any ivanov aiming
	if(aiming_ivanov && (getting_out in return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)))
		end_missile_targeting(getting_out)
	. = ..()

/**
 * ## begin_skyfall_charge
 *
 * Proc called by the mecha's ability that starts the skyfall loop
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/begin_skyfall_charge(mob/pilot)
	balloon_alert(pilot, "charging skyfall...")
	INVOKE_ASYNC(src, .proc/skyfall_charge_loop, pilot)

/**
 * ## skyfall_charge_loop
 *
 * The actual skyfall loop itself. Repeatedly calls itself after a do_after, so any interruptions will call abort_skyfall and end the loop
 * the other way the loop ends is if charge level (var it's ticking up) gets to SKYFALL_CHARGELEVEL_LAUNCH, in which case it ends the loop and does the ability.
 * arguments:
 * * pilot: mob that activated the skyfall ability
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/skyfall_charge_loop(mob/living/pilot)
	if(!pilot || !(pilot in return_drivers()) || !do_after(pilot, SKYFALL_SINGLE_CHARGE_TIME, target = src))
		abort_skyfall(pilot)
		return
	skyfall_charge_level++
	switch(skyfall_charge_level)
		if(1)
			visible_message(span_warning("[src] clicks and whirrs for a moment, with a low hum emerging from the legs."))
			playsound(src, 'sound/items/rped.ogg', 50, TRUE)
		if(2)
			visible_message(span_warning("[src] begins to shake, the sounds of electricity growing louder."))
			Shake(5, 5, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
		if(3)
			visible_message(span_warning("[src] assumes a pose as it rattles violently."))
			Shake(7, 7, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
			spark_system.start()
			update_icon_state()
		if(4)
			visible_message(span_warning("[src] sparks and shutters as it finalizes preparation."))
			playsound(src, 'sound/mecha/skyfall_power_up.ogg', 50, TRUE)
			Shake(10, 10, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
			spark_system.start()
		if(SKYFALL_CHARGELEVEL_LAUNCH)
			visible_message(span_danger("[src] leaps into the air!"))
			playsound(src, 'sound/weapons/gun/general/rocket_launch.ogg', 50, TRUE)
	if(skyfall_charge_level != SKYFALL_CHARGELEVEL_LAUNCH)
		INVOKE_ASYNC(src, .proc/skyfall_charge_loop, pilot)
		return
	COOLDOWN_START(src, skyfall_cooldown, skyfall_cooldown_time)
	var/datum/action/vehicle/sealed/mecha/savannah_action = occupant_actions[pilot][/datum/action/vehicle/sealed/mecha/skyfall]
	savannah_action.button_icon_state = "mech_savannah_cooldown"
	savannah_action.UpdateButtonIcon()
	addtimer(CALLBACK(savannah_action, /datum/action/vehicle/sealed/mecha/skyfall.proc/reset_button_icon), skyfall_cooldown_time)
	for(var/mob/living/shaken in range(7, src))
		shake_camera(shaken, 3, 3)

	var/turf/launch_turf = get_turf(src)
	new /obj/effect/hotspot(launch_turf)
	launch_turf.hotspot_expose(700, 50, 1)
	new /obj/effect/skyfall_landingzone(launch_turf, src)
	resistance_flags |= INDESTRUCTIBLE //not while jumping at least
	mecha_flags |= QUIET_STEPS|QUIET_TURNS|CANNOT_INTERACT
	phasing = "flying"
	movedelay = 1
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	animate(src, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(src, pixel_z = 400, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL) //Animate our rising mech (just like pods hehe)
	addtimer(CALLBACK(src, .proc/begin_landing, pilot), 2 SECONDS)

/**
 * ## begin_landing
 *
 * Called by skyfall_charge_loop after some time if it reaches full charge level.
 * it's just the animations of the mecha coming down + another timer for the final landing effect
 * arguments:
 * * pilot: mob that activated the skyfall ability
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/begin_landing(mob/living/pilot)
	animate(src, pixel_z = 0, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(src, alpha = 255, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, .proc/land, pilot), 10)

/**
 * ## begin_landing
 *
 * Called by skyfall_charge_loop after some time if it reaches full charge level.
 * it's just the animations of the mecha coming down + another timer for the final landing effect
 * arguments:
 * * pilot: mob that activated the skyfall ability
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/land(mob/living/pilot)
	visible_message(span_danger("[src] lands from above!"))
	playsound(src, 'sound/effects/explosion1.ogg', 50, 1)
	resistance_flags &= ~INDESTRUCTIBLE
	mecha_flags &= ~(QUIET_STEPS|QUIET_TURNS|CANNOT_INTERACT)
	phasing = initial(phasing)
	movedelay = initial(movedelay)
	density = TRUE
	layer = initial(layer)
	plane = initial(plane)
	skyfall_charge_level = 0
	update_icon_state()
	for(var/mob/living/shaken in range(7, src))
		shake_camera(shaken, 5, 5)
	var/turf/landed_on = get_turf(src)
	for(var/thing in range(1, src))
		if(isopenturf(thing))
			var/turf/open/floor/crushed_tile = thing
			crushed_tile.break_tile()
		if(isclosedturf(thing) && thing == landed_on)
			var/turf/closed/crushed_wall = thing
			crushed_wall.ScrapeAway()
		if(isobj(thing))
			var/obj/crushed_object = thing
			if(crushed_object == src || crushed_object.loc == src)
				continue
			crushed_object.take_damage(150) //same as a hulk punch, makes sense to me
		if(isliving(thing))
			var/mob/living/crushed_victim = thing
			if(crushed_victim in occupants)
				continue
			if(crushed_victim in landed_on)
				to_chat(crushed_victim, span_userdanger("[src] crashes down on you from above!"))
				if(crushed_victim.stat != CONSCIOUS)
					crushed_victim.gib(FALSE, FALSE, FALSE)
				else
					crushed_victim.adjustBruteLoss(80)
			else
				to_chat(crushed_victim, span_userdanger("The tremors from [src] landing sends you flying!"))
				var/fly_away_direction = get_dir(src, crushed_victim)
				crushed_victim.throw_at(get_edge_target_turf(crushed_victim, fly_away_direction), 4, 3)
				crushed_victim.adjustBruteLoss(15)

/**
 * ## abort_skyfall
 *
 * Called by skyfall_charge_loop if the charging is interrupted.
 * Applies cooldown and resets charge level
 * arguments:
 * * pilot: mob that failed the skyfall ability
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/abort_skyfall(mob/pilot)
	if(pilot)
		balloon_alert(pilot, "skyfall aborted")
	COOLDOWN_START(src, skyfall_cooldown, skyfall_charge_level * 10 SECONDS) //so aborting skyfall later in the process imposes a longer cooldown
	skyfall_charge_level = 0
	update_icon_state()

/**
 * ## start_missile_targeting
 *
 * Called by the ivanov strike datum action, hooks signals into clicking to call drop_missile
 * Plus other flavor like the overlay
 * arguments:
 * * gunner: mob that activated the ivanov strike
 * * silent: whether to send feedback messages.
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/start_missile_targeting(mob/gunner)
	balloon_alert(gunner, "missile mode on (click to target)")
	aiming_ivanov = TRUE
	rockets_left = 3
	RegisterSignal(src, COMSIG_MECHA_MELEE_CLICK, .proc/on_melee_click)
	RegisterSignal(src, COMSIG_MECHA_EQUIPMENT_CLICK, .proc/on_equipment_click)
	gunner.client.mouse_override_icon = 'icons/effects/mouse_pointers/supplypod_down_target.dmi'
	gunner.update_mouse_pointer()
	gunner.overlay_fullscreen("ivanov", /atom/movable/screen/fullscreen/ivanov_display, 1)
	SEND_SOUND(gunner, 'sound/machines/terminal_on.ogg') //spammable so I don't want to make it audible to anyone else

/**
 * ## end_missile_targeting
 *
 * Called by the ivanov strike datum action or other actions that would end targetting
 * Unhooks signals into clicking to call drop_missile plus other flavor like the overlay
 * arguments:
 * * gunner: mob that activated the ivanov strike
 * * silent: whether to send feedback messages.
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/end_missile_targeting(mob/gunner)
	aiming_ivanov = FALSE
	rockets_left = 0
	UnregisterSignal(src, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))
	gunner.client.mouse_override_icon = null
	gunner.update_mouse_pointer()
	gunner.clear_fullscreen("ivanov")

///signal called from clicking with no equipment
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(pilot, get_turf(target))

///signal called from clicking with equipment
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(pilot, get_turf(target))

/**
 * ## drop_missile
 *
 * Called via intercepted clicks when the missile ability is active
 * Spawns a droppod and starts the cooldown of the missile strike ability
 * arguments:
 * * gunner: mob that activated the ivanov strike
 * * target_turf: turf of the atom that was clicked on
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/drop_missile(mob/gunner, turf/target_turf)
	rockets_left -= 1
	if(rockets_left <= 0)
		end_missile_targeting(gunner)
	SEND_SOUND(gunner, 'sound/machines/triple_beep.ogg')
	COOLDOWN_START(src, strike_cooldown, strike_cooldown_time)
	podspawn(list(
		"target" = target_turf,
		"style" = STYLE_MISSILE,
		"effectMissile" = TRUE,
		"explosionSize" = list(0,0,1,2)
	))
	var/datum/action/vehicle/sealed/mecha/strike_action = occupant_actions[gunner][/datum/action/vehicle/sealed/mecha/ivanov_strike]
	strike_action.button_icon_state = "mech_ivanov_cooldown"
	strike_action.UpdateButtonIcon()
	addtimer(CALLBACK(strike_action, /datum/action/vehicle/sealed/mecha/ivanov_strike.proc/reset_button_icon), strike_cooldown_time)


///Savannah Skyfall
/datum/action/vehicle/sealed/mecha/skyfall
	name = "Savannah Skyfall"
	button_icon_state = "mech_savannah"

/datum/action/vehicle/sealed/mecha/skyfall/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/combat/savannah_ivanov/savannah_mecha = chassis
	if(savannah_mecha.phasing)
		to_chat(owner, span_warning("You're already airborne!"))
		return
	if(!COOLDOWN_FINISHED(savannah_mecha, skyfall_cooldown))
		var/timeleft = COOLDOWN_TIMELEFT(savannah_mecha, skyfall_cooldown)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before attempting to Skyfall."))
		return
	if(savannah_mecha.skyfall_charge_level)
		savannah_mecha.abort_skyfall(owner)
		return
	savannah_mecha.begin_skyfall_charge(owner)

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the skyfall, resets the icon
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/reset_button_icon()
	button_icon_state = "mech_savannah"
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/ivanov_strike
	name = "Ivanov Strike"
	button_icon_state = "mech_ivanov"

/datum/action/vehicle/sealed/mecha/ivanov_strike/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/combat/savannah_ivanov/ivanov_mecha = chassis
	if(!COOLDOWN_FINISHED(ivanov_mecha, strike_cooldown))
		var/timeleft = COOLDOWN_TIMELEFT(ivanov_mecha, strike_cooldown)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before firing another Ivanov Strike."))
		return
	if(ivanov_mecha.aiming_ivanov)
		ivanov_mecha.end_missile_targeting(owner)
	else
		ivanov_mecha.start_missile_targeting(owner)

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the ivanov strike, resets the icon
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/reset_button_icon()
	button_icon_state = "mech_ivanov"
	UpdateButtonIcon()

//misc effects

///a simple indicator of where the skyfall is going to land.
/obj/effect/skyfall_landingzone
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/telegraphing/telegraph_96x96.dmi'
	icon_state = "target_largebox"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	alpha = 0
	///reference to mecha following
	var/obj/vehicle/sealed/mecha/combat/mecha

/obj/effect/skyfall_landingzone/Initialize(mapload, obj/vehicle/sealed/mecha/combat/mecha)
	. = ..()
	if(!mecha)
		stack_trace("Skyfall landing zone created without mecha")
		return INITIALIZE_HINT_QDEL
	src.mecha = mecha
	animate(src, alpha = 255, TOTAL_SKYFALL_LEAP_TIME/2, easing = CIRCULAR_EASING|EASE_OUT)
	RegisterSignal(mecha, COMSIG_MOVABLE_MOVED, .proc/follow)
	QDEL_IN(src, TOTAL_SKYFALL_LEAP_TIME) //when the animations land

/obj/effect/skyfall_landingzone/Destroy(force)
	. = ..()
	UnregisterSignal(mecha, COMSIG_MOVABLE_MOVED)
	mecha = null

///called when the mecha moves
/obj/effect/skyfall_landingzone/proc/follow(datum/source_mecha)
	SIGNAL_HANDLER
	forceMove(get_turf(source_mecha))

#undef SKYFALL_SINGLE_CHARGE_TIME
#undef SKYFALL_CHARGELEVEL_LAUNCH

#undef SKYFALL_LEAP_ARCING_UP
#undef SKYFALL_LEAP_ARCING_DOWN
#undef TOTAL_SKYFALL_LEAP_TIME
