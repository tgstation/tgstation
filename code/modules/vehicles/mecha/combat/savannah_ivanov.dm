///how much time between charge_level going up by 1
#define SKYFALL_SINGLE_CHARGE_TIME (2 SECONDS)
///enough charge level to take off, basically done charging
#define SKYFALL_CHARGELEVEL_LAUNCH 5

///how much time you're in the air
#define TOTAL_SKYFALL_LEAP_TIME (3 SECONDS)

/**
 * ## Savannah-Ivanov!
 *
 * A two person mecha that delegates moving to the driver and shooting to the pilot.
 * ...Hilarious, right?
 */
/obj/vehicle/sealed/mecha/savannah_ivanov
	name = "\improper Savannah-Ivanov"
	desc = "An insanely overbulked mecha that handily crushes single-pilot opponents. The price is that you need two pilots to use it."
	icon = 'icons/mob/rideables/coop_mech.dmi'
	base_icon_state = "savannah_ivanov"
	icon_state = "savannah_ivanov_0_0"
	//does not include mmi compatibility
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | BEACON_TRACKABLE | BEACON_CONTROLLABLE
	mech_type = EXOSUIT_MODULE_SAVANNAH
	movedelay = 3
	max_integrity = 450 //really tanky, like damn
	armor_type = /datum/armor/mecha_savannah_ivanov
	max_temperature = 30000
	force = 30
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/savannah_ivanov
	max_occupants = 2
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	//no tax on flying, since the power cost is in the leap itself.
	phasing_energy_drain = 0

/datum/armor/mecha_savannah_ivanov
	melee = 45
	bullet = 40
	laser = 30
	energy = 30
	bomb = 40
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/savannah_ivanov/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	var/list/mob/drivers = return_drivers()
	var/leap_state
	if(length(drivers))
		var/datum/action/vehicle/sealed/mecha/skyfall/action = LAZYACCESSASSOC(occupant_actions, drivers[1], /datum/action/vehicle/sealed/mecha/skyfall)
		leap_state = action.skyfall_charge_level > 2 ? "leap_" : ""
	return "[base_icon_state]_[leap_state][gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/savannah_ivanov/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/savannah_ivanov/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/skyfall, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike, VEHICLE_CONTROL_EQUIPMENT)

///Savannah Skyfall
/datum/action/vehicle/sealed/mecha/skyfall
	name = "Savannah Skyfall"
	button_icon_state = "mech_savannah"
	///cooldown time between skyfall uses
	var/skyfall_cooldown_time = 1 MINUTES
	///skyfall builds up in charges every 2 seconds, when it reaches 5 charges the ability actually starts
	var/skyfall_charge_level = 0

/datum/action/vehicle/sealed/mecha/skyfall/Trigger(trigger_flags)
	if(!..())
		return
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(chassis.phasing)
		to_chat(owner, span_warning("You're already airborne!"))
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_MECHA_SKYFALL))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_SKYFALL)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before attempting to Skyfall."))
		return
	if(skyfall_charge_level)
		abort_skyfall()
		return
	chassis.balloon_alert(owner, "charging skyfall...")
	INVOKE_ASYNC(src, PROC_REF(skyfall_charge_loop))

/**
 * ## skyfall_charge_loop
 *
 * The actual skyfall loop itself. Repeatedly calls itself after a do_after, so any interruptions will call abort_skyfall and end the loop
 * the other way the loop ends is if charge level (var it's ticking up) gets to SKYFALL_CHARGELEVEL_LAUNCH, in which case it ends the loop and does the ability.
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/skyfall_charge_loop()
	if(!do_after(owner, SKYFALL_SINGLE_CHARGE_TIME, target = chassis))
		abort_skyfall()
		return
	skyfall_charge_level++
	switch(skyfall_charge_level)
		if(1)
			chassis.visible_message(span_warning("[chassis] clicks and whirrs for a moment, with a low hum emerging from the legs."))
			playsound(chassis, 'sound/items/tools/rped.ogg', 50, TRUE)
		if(2)
			chassis.visible_message(span_warning("[chassis] begins to shake, the sounds of electricity growing louder."))
			chassis.Shake(1, 1, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
		if(3)
			chassis.visible_message(span_warning("[chassis] assumes a pose as it rattles violently."))
			chassis.Shake(2, 2, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
			chassis.spark_system.start()
			chassis.update_appearance(UPDATE_ICON_STATE)
		if(4)
			chassis.visible_message(span_warning("[chassis] sparks and shutters as it finalizes preparation."))
			playsound(chassis, 'sound/vehicles/mecha/skyfall_power_up.ogg', 50, TRUE)
			chassis.Shake(3, 3, SKYFALL_SINGLE_CHARGE_TIME-1) // -1 gives space between the animates, so they don't interrupt eachother
			chassis.spark_system.start()
		if(SKYFALL_CHARGELEVEL_LAUNCH)
			chassis.visible_message(span_danger("[chassis] leaps into the air!"))
			playsound(chassis, 'sound/items/weapons/gun/general/rocket_launch.ogg', 50, TRUE)
	if(skyfall_charge_level != SKYFALL_CHARGELEVEL_LAUNCH)
		skyfall_charge_loop()
		return
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_SKYFALL, skyfall_cooldown_time)
	button_icon_state = "mech_savannah_cooldown"
	build_all_button_icons()
	addtimer(CALLBACK(src, PROC_REF(reset_button_icon)), skyfall_cooldown_time)
	for(var/mob/living/shaken in range(7, chassis))
		shake_camera(shaken, 3, 3)

	var/turf/launch_turf = get_turf(chassis)
	new /obj/effect/hotspot(launch_turf)
	launch_turf.hotspot_expose(700, 50, 1)
	new /obj/effect/skyfall_landingzone(launch_turf, chassis)
	chassis.resistance_flags |= INDESTRUCTIBLE //not while jumping at least
	chassis.mecha_flags |= QUIET_STEPS|QUIET_TURNS|CANNOT_INTERACT
	chassis.phasing = "flying"
	chassis.movedelay = 1
	chassis.set_density(FALSE)
	chassis.layer = ABOVE_ALL_MOB_LAYER
	animate(chassis, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(chassis, pixel_z = 400, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL) //Animate our rising mech (just like pods hehe)
	addtimer(CALLBACK(src, PROC_REF(begin_landing)), 2 SECONDS)

/**
 * ## begin_landing
 *
 * Called by skyfall_charge_loop after some time if it reaches full charge level.
 * it's just the animations of the mecha coming down + another timer for the final landing effect
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/begin_landing()
	animate(chassis, pixel_z = 0, time = 10, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(chassis, alpha = 255, time = 8, easing = QUAD_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(land)), 1 SECONDS)

/**
 * ## land
 *
 * Called by skyfall_charge_loop after some time if it reaches full charge level.
 * it's just the animations of the mecha coming down + another timer for the final landing effect
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/land()
	var/turf/landed_on = get_turf(chassis)
	chassis.visible_message(span_danger("[chassis] lands from above!"))
	playsound(chassis, 'sound/effects/explosion/explosion1.ogg', 50, 1)
	chassis.resistance_flags &= ~INDESTRUCTIBLE
	chassis.mecha_flags &= ~(QUIET_STEPS|QUIET_TURNS|CANNOT_INTERACT)
	chassis.phasing = initial(chassis.phasing)
	chassis.movedelay = initial(chassis.movedelay)
	chassis.set_density(TRUE)
	chassis.layer = initial(chassis.layer)
	SET_PLANE(chassis, initial(chassis.plane), landed_on)
	skyfall_charge_level = 0
	chassis.update_appearance(UPDATE_ICON_STATE)
	for(var/mob/living/shaken in range(7, chassis))
		shake_camera(shaken, 5, 5)
	for(var/thing in range(1, chassis))
		if(isopenturf(thing))
			var/turf/open/floor/crushed_tile = thing
			crushed_tile.break_tile()
			continue
		if(isclosedturf(thing) && thing == landed_on)
			var/turf/closed/crushed_wall = thing
			crushed_wall.ScrapeAway()
			continue
		if(isobj(thing))
			var/obj/crushed_object = thing
			if(crushed_object == chassis || crushed_object.loc == chassis)
				continue
			crushed_object.take_damage(150) //same as a hulk punch, makes sense to me
			continue
		if(isliving(thing))
			var/mob/living/crushed_victim = thing
			if(crushed_victim in chassis.occupants)
				continue
			if(!(crushed_victim in landed_on))
				to_chat(crushed_victim, span_userdanger("The tremors from [chassis] landing sends you flying!"))
				var/fly_away_direction = get_dir(chassis, crushed_victim)
				crushed_victim.throw_at(get_edge_target_turf(crushed_victim, fly_away_direction), 4, 3)
				crushed_victim.adjustBruteLoss(15)
				continue
			to_chat(crushed_victim, span_userdanger("[chassis] crashes down on you from above!"))
			if(crushed_victim.stat != CONSCIOUS)
				crushed_victim.investigate_log("has been gibbed by a falling Savannah Ivanov mech.", INVESTIGATE_DEATHS)
				crushed_victim.gib(DROP_ALL_REMAINS)
				continue
			crushed_victim.adjustBruteLoss(80)

/**
 * ## abort_skyfall
 *
 * Called by skyfall_charge_loop if the charging is interrupted.
 * Applies cooldown and resets charge level
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/abort_skyfall()
	chassis.balloon_alert(owner, "skyfall aborted")
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MISSILE_STRIKE, skyfall_charge_level * 10 SECONDS) //so aborting skyfall later in the process imposes a longer cooldown
	skyfall_charge_level = 0
	chassis.update_appearance(UPDATE_ICON_STATE)

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the skyfall, resets the icon
 */
/datum/action/vehicle/sealed/mecha/skyfall/proc/reset_button_icon()
	button_icon_state = "mech_savannah"
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/ivanov_strike
	name = "Ivanov Strike"
	button_icon_state = "mech_ivanov"
	///cooldown time between strike uses
	var/strike_cooldown_time = 40 SECONDS
	///how many rockets can we send with ivanov strike
	var/rockets_left = 0
	var/aiming_missile = FALSE

/datum/action/vehicle/sealed/mecha/ivanov_strike/Destroy()
	if(aiming_missile)
		end_missile_targeting()
	return ..()

/datum/action/vehicle/sealed/mecha/ivanov_strike/Trigger(trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	if(TIMER_COOLDOWN_RUNNING(chassis, COOLDOWN_MECHA_MISSILE_STRIKE))
		var/timeleft = S_TIMER_COOLDOWN_TIMELEFT(chassis, COOLDOWN_MECHA_MISSILE_STRIKE)
		to_chat(owner, span_warning("You need to wait [DisplayTimeText(timeleft, 1)] before firing another Ivanov Strike."))
		return
	if(aiming_missile)
		end_missile_targeting()
	else
		start_missile_targeting()

/**
 * ## reset_button_icon
 *
 * called after an addtimer when the cooldown is finished with the ivanov strike, resets the icon
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/reset_button_icon()
	button_icon_state = "mech_ivanov"
	build_all_button_icons()

/**
 * ## start_missile_targeting
 *
 * Called by the ivanov strike datum action, hooks signals into clicking to call drop_missile
 * Plus other flavor like the overlay
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/start_missile_targeting()
	chassis.balloon_alert(owner, "missile mode on (click to target)")
	aiming_missile = TRUE
	rockets_left = 3
	RegisterSignal(chassis, COMSIG_MECHA_MELEE_CLICK, PROC_REF(on_melee_click))
	RegisterSignal(chassis, COMSIG_MECHA_EQUIPMENT_CLICK, PROC_REF(on_equipment_click))
	owner.client.mouse_override_icon = 'icons/effects/mouse_pointers/supplypod_down_target.dmi'
	owner.update_mouse_pointer()
	owner.overlay_fullscreen("ivanov", /atom/movable/screen/fullscreen/ivanov_display, 1)
	SEND_SOUND(owner, 'sound/machines/terminal/terminal_on.ogg') //spammable so I don't want to make it audible to anyone else

/**
 * ## end_missile_targeting
 *
 * Called by the ivanov strike datum action or other actions that would end targeting
 * Unhooks signals into clicking to call drop_missile plus other flavor like the overlay
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/end_missile_targeting()
	aiming_missile = FALSE
	rockets_left = 0
	UnregisterSignal(chassis, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))
	owner.client.mouse_override_icon = null
	owner.update_mouse_pointer()
	owner.clear_fullscreen("ivanov")

///signal called from clicking with no equipment
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(get_turf(target))

///signal called from clicking with equipment
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(get_turf(target))

/**
 * ## drop_missile
 *
 * Called via intercepted clicks when the missile ability is active
 * Spawns a droppod and starts the cooldown of the missile strike ability
 * arguments:
 * * target_turf: turf of the atom that was clicked on
 */
/datum/action/vehicle/sealed/mecha/ivanov_strike/proc/drop_missile(turf/target_turf)
	rockets_left--
	if(rockets_left <= 0)
		end_missile_targeting()
	SEND_SOUND(owner, 'sound/machines/beep/triple_beep.ogg')
	S_TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MISSILE_STRIKE, strike_cooldown_time)
	podspawn(list(
		"target" = target_turf,
		"style" = /datum/pod_style/missile,
		"effectMissile" = TRUE,
		"explosionSize" = list(0,0,1,2)
	))
	button_icon_state = "mech_ivanov_cooldown"
	build_all_button_icons()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/vehicle/sealed/mecha/ivanov_strike, reset_button_icon)), strike_cooldown_time)

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
	var/obj/vehicle/sealed/mecha/mecha

/obj/effect/skyfall_landingzone/Initialize(mapload, obj/vehicle/sealed/mecha/mecha)
	. = ..()
	if(!mecha)
		stack_trace("Skyfall landing zone created without mecha")
		return INITIALIZE_HINT_QDEL
	src.mecha = mecha
	animate(src, alpha = 255, TOTAL_SKYFALL_LEAP_TIME/2, easing = CIRCULAR_EASING|EASE_OUT)
	RegisterSignal(mecha, COMSIG_MOVABLE_MOVED, PROC_REF(follow))
	QDEL_IN(src, TOTAL_SKYFALL_LEAP_TIME) //when the animations land

/obj/effect/skyfall_landingzone/Destroy(force)
	mecha = null
	return ..()

///called when the mecha moves
/obj/effect/skyfall_landingzone/proc/follow(datum/source_mecha)
	SIGNAL_HANDLER
	forceMove(get_turf(source_mecha))

#undef SKYFALL_SINGLE_CHARGE_TIME
#undef SKYFALL_CHARGELEVEL_LAUNCH

#undef TOTAL_SKYFALL_LEAP_TIME
