/obj/vehicle/sealed/mecha/ripley
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper APLU MK-I \"Ripley\""
	icon_state = "ripley"
	base_icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	movedelay = 1.5 //Move speed, lower is faster.
	overclock_coeff = 1.25
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	armor_type = /datum/armor/mecha_ripley
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 4,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	mecha_flags = CAN_STRAFE | HAS_LIGHTS | MMI_COMPATIBLE
	wreckage = /obj/structure/mecha_wreckage/ripley
	mech_type = EXOSUIT_MODULE_RIPLEY
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	accesses = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	/// Custom Ripley step and turning sounds (from TGMC)
	stepsound = 'sound/mecha/powerloader_step.ogg'
	turnsound = 'sound/mecha/powerloader_turn2.ogg'
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	/// Amount of Goliath hides attached to the mech
	var/hides = 0
	/// Reference to the Cargo Hold equipment.
	var/obj/item/mecha_parts/mecha_equipment/ejector/cargo_hold
	/// How fast the mech is in low pressure
	var/fast_pressure_step_in = 1.5
	/// How fast the mech is in normal pressure
	var/slow_pressure_step_in = 2

/datum/armor/mecha_ripley
	melee = 40
	bullet = 20
	laser = 10
	energy = 20
	bomb = 40
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/ripley/Move()
	. = ..()
	update_pressure()

/obj/vehicle/sealed/mecha/ripley/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 3, /obj/item/stack/sheet/animalhide/goliath_hide, /datum/armor/armor_plate_ripley_goliath)

/datum/armor/armor_plate_ripley_goliath
	melee = 10
	bullet = 5
	laser = 5

/obj/vehicle/sealed/mecha/ripley/mk2
	desc = "Autonomous Power Loader Unit MK-II. This prototype Ripley is refitted with a pressurized cabin, trading its prior speed for atmospheric protection and armor."
	name = "\improper APLU MK-II \"Ripley\""
	icon_state = "ripleymkii"
	base_icon_state = "ripleymkii"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 4 //step_in while in normal pressure conditions
	movedelay = 4
	max_temperature = 30000
	max_integrity = 250
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_TEMP_CONTROL|MECHA_CABIN_AIR_BREACH|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	armor_type = /datum/armor/mecha_ripley_mk2
	wreckage = /obj/structure/mecha_wreckage/ripley/mk2
	enter_delay = 40
	silicon_icon_state = null

/datum/armor/mecha_ripley_mk2
	melee = 40
	bullet = 30
	laser = 30
	energy = 30
	bomb = 60
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/ripley/paddy
	desc = "Autonomous Power Loader Unit Subtype Paddy. A Modified MK-I Ripley design intended for light security use."
	name = "\improper APLU \"Paddy\""
	icon_state = "paddy"
	base_icon_state = "paddy"
	max_temperature = 20000
	max_integrity = 250
	mech_type = EXOSUIT_MODULE_PADDY
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	armor_type = /datum/armor/mecha_paddy
	wreckage = /obj/structure/mecha_wreckage/ripley/paddy
	silicon_icon_state = "paddy-empty"
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector/seccage),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	///Siren Lights/Sound State
	var/siren = FALSE
	///Overlay for Siren Lights
	var/mutable_appearance/sirenlights
	///Looping sound datum for the Siren audio
	var/datum/looping_sound/siren/weewooloop

/datum/armor/mecha_paddy
	melee = 40
	bullet = 20
	laser = 10
	energy = 20
	bomb = 40
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/ripley/paddy/Initialize(mapload)
	. = ..()
	weewooloop = new(src, FALSE, FALSE)
	weewooloop.volume = 100

/obj/vehicle/sealed/mecha/ripley/paddy/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/siren)

/obj/vehicle/sealed/mecha/ripley/paddy/mob_exit(mob/M, silent = FALSE, randomstep = FALSE, forced = FALSE)
	var/obj/item/mecha_parts/mecha_equipment/ejector/seccage/cargo_holder = locate(/obj/item/mecha_parts/mecha_equipment/ejector/seccage) in equip_by_category[MECHA_UTILITY]
	for(var/mob/contained in cargo_holder)
		cargo_holder.cheese_it(contained)
	togglesiren(force_off = TRUE)
	return ..()

/obj/vehicle/sealed/mecha/ripley/paddy/proc/togglesiren(force_off = FALSE)
	if(force_off || siren)
		weewooloop.stop()
		siren = FALSE
	else
		weewooloop.start()
		siren = TRUE
	for(var/mob/occupant as anything in occupants)
		balloon_alert(occupant, "siren [siren ? "activated" : "disabled"]")
		var/datum/action/act = locate(/datum/action/vehicle/sealed/mecha/siren) in occupant.actions
		act.button_icon_state = "mech_siren_[siren ? "on" : "off"]"
		act.build_all_button_icons()
	update_appearance(UPDATE_OVERLAYS)

/obj/vehicle/sealed/mecha/ripley/paddy/update_overlays()
	. = ..()
	if(!siren)
		return
	sirenlights = new()
	sirenlights.icon = icon
	sirenlights.icon_state = "paddy_sirens"
	SET_PLANE_EXPLICIT(sirenlights, ABOVE_LIGHTING_PLANE, src)
	. += sirenlights

/obj/vehicle/sealed/mecha/ripley/paddy/Destroy()
	QDEL_NULL(weewooloop)
	return ..()

/datum/action/vehicle/sealed/mecha/siren
	name = "Toggle External Siren and Lights"
	button_icon_state = "mech_siren_off"

/datum/action/vehicle/sealed/mecha/siren/New()
	. = ..()
	var/obj/vehicle/sealed/mecha/ripley/paddy/secmech = chassis
	button_icon_state = "mech_siren_[secmech?.siren ? "on" : "off"]"

/datum/action/vehicle/sealed/mecha/siren/Trigger(trigger_flags, forced_state = FALSE)
	var/obj/vehicle/sealed/mecha/ripley/paddy/secmech = chassis
	secmech.togglesiren()

/obj/vehicle/sealed/mecha/ripley/paddy/preset
	accesses = list(ACCESS_SECURITY)
	mecha_flags = CAN_STRAFE | HAS_LIGHTS | MMI_COMPATIBLE | ID_LOCK_ON
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/paddy_claw,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector/seccage),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	base_icon_state = "deathripley"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	movedelay = 4
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	enter_delay = 40
	silicon_icon_state = null
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/ripley/deathripley/real
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/vehicle/sealed/mecha/ripley/mining
	desc = "An old, dusty mining Ripley."
	name = "\improper APLU \"Miner\""

/obj/vehicle/sealed/mecha/ripley/mining/Initialize(mapload)
	. = ..()
	take_damage(125)
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src, TRUE)
	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

GLOBAL_DATUM(cargo_ripley, /obj/vehicle/sealed/mecha/ripley/cargo)

/obj/vehicle/sealed/mecha/ripley/cargo
	desc = "An ailing, old, repurposed cargo hauler. Most of its equipment wires are frayed or missing and its frame is rusted."
	name = "\improper APLU \"Big Bess\""
	icon_state = "hauler"
	base_icon_state = "hauler"
	max_integrity = 100 //Has half the health of a normal RIPLEY mech, so it's harder to use as a weapon.

/obj/vehicle/sealed/mecha/ripley/cargo/Initialize(mapload)
	. = ..()

	//Attach hydraulic clamp ONLY
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	take_damage(max_integrity * 0.5, sound_effect=FALSE) //Low starting health
	if(!GLOB.cargo_ripley && mapload)
		GLOB.cargo_ripley = src

/obj/vehicle/sealed/mecha/ripley/cargo/Destroy()
	if(GLOB.cargo_ripley == src)
		GLOB.cargo_ripley = null

	return ..()

/obj/vehicle/sealed/mecha/ripley/cargo/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/high(src)
	//No scanmod for Big Bess
	capacitor = new /obj/item/stock_parts/capacitor(src)
	servo = new /obj/item/stock_parts/servo(src)
	update_part_values()

/obj/item/mecha_parts/mecha_equipment/ejector
	name = "cargo compartment"
	desc = "Holds cargo loaded with a hydraulic clamp."
	icon_state = "mecha_bin"
	equipment_slot = MECHA_UTILITY
	detachable = FALSE
	///Number of atoms we can store
	var/cargo_capacity = 15

/obj/item/mecha_parts/mecha_equipment/ejector/attach()
	. = ..()
	var/obj/vehicle/sealed/mecha/ripley/workmech = chassis
	workmech.cargo_hold = src


/obj/item/mecha_parts/mecha_equipment/ejector/Destroy()
	for(var/atom/stored in contents)
		forceMove(stored, drop_location())
		step_rand(stored)
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/contents_explosion(severity, target)
	for(var/obj/stored in contents)
		if(prob(10 * severity))
			stored.forceMove(drop_location())
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/relay_container_resist_act(mob/living/user, obj/container)
	to_chat(user, span_notice("You lean on the back of [container] and start pushing so it falls out of [src]."))
	if(do_after(user, 30 SECONDS, target = container))
		if(!user || user.stat != CONSCIOUS || user.loc != src || container.loc != src )
			return
		to_chat(user, span_notice("You successfully pushed [container] out of [src]!"))
		container.forceMove(drop_location())
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to push [container] out of [src]!"))

/obj/item/mecha_parts/mecha_equipment/ejector/get_snowflake_data()
	var/list/data = list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_EJECTOR,
		"cargo_capacity" = cargo_capacity,
		"cargo" = list()
		)
	for(var/atom/entry in contents)
		data["cargo"] += list(list(
			"name" = entry.name,
			"ref" = REF(entry),
		))
	return data

/obj/item/mecha_parts/mecha_equipment/ejector/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE
	if(action == "eject")
		var/obj/crate = locate(params["cargoref"]) in contents
		if(!crate)
			return FALSE
		to_chat(chassis.occupants, "[icon2html(src,  chassis.occupants)][span_notice("You unload [crate].")]")
		crate.forceMove(drop_location())
		if(crate == chassis.ore_box)
			chassis.ore_box = null
		playsound(chassis, 'sound/weapons/tap.ogg', 50, TRUE)
		log_message("Unloaded [crate]. Cargo compartment capacity: [cargo_capacity - contents.len]", LOG_MECHA)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/ejector/seccage
	name = "holding cell"
	desc = "Holds suspects loaded with a hydraulic claw."
	cargo_capacity = 4

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOB_REMOVING_CUFFS, PROC_REF(stop_cuff_removal))

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/Destroy()
	UnregisterSignal(src, COMSIG_MOB_REMOVING_CUFFS)
	for(var/mob/freebird in contents) //Let's not qdel people iside the mech kthx
		cheese_it(freebird)
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	RegisterSignal(arrived, COMSIG_MOB_REMOVING_CUFFS, PROC_REF(stop_cuff_removal))
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/Exited(atom/movable/gone, direction)
	UnregisterSignal(gone, COMSIG_MOB_REMOVING_CUFFS)
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/proc/stop_cuff_removal(datum/source, obj/item/cuffs)
	SIGNAL_HANDLER
	to_chat(source, span_warning("You don't have the room to remove [cuffs]!"))
	return COMSIG_MOB_BLOCK_CUFF_REMOVAL

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action == "eject")
		var/mob/passenger = locate(params["cargoref"]) in contents
		if(!passenger)
			return FALSE
		to_chat(chassis.occupants, "[icon2html(src,  chassis.occupants)][span_notice("You unload [passenger].")]")
		passenger.forceMove(drop_location())
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), passenger, chassis.dir), 1) //That's right, one tick. Just enough to cause the tile move animation.
		playsound(chassis, 'sound/weapons/tap.ogg', 50, TRUE)
		log_message("Unloaded [passenger]. Cargo compartment capacity: [cargo_capacity - contents.len]", LOG_MECHA)
		return TRUE
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/container_resist_act(mob/living/user)
	var/breakout_time = 1 MINUTES

	if (user.mob_size > MOB_SIZE_HUMAN)
		breakout_time = 6 SECONDS

	to_chat(user, span_notice("You begin attempting a breakout. (This will take around [DisplayTimeText(breakout_time)] and [chassis] needs to remain stationary.)"))
	if(!do_after(user, breakout_time, target = chassis))
		return
	to_chat(user, span_notice("You break out of the [src]."))
	playsound(chassis, 'sound/items/crowbar.ogg', 100, TRUE)
	cheese_it(user)
	for(var/mob/freebird in contents)
		if(user != freebird)
			to_chat(freebird, span_warning("[user] has managed to open the hatch, and you fall out with him. You're free!"))
			cheese_it(freebird)

/obj/item/mecha_parts/mecha_equipment/ejector/seccage/proc/cheese_it(mob/living/escapee)
	var/range = rand(1, 3)
	var/variance = rand(-45, 45)
	var/angle = 180
	var/turf/current_turf = get_turf(src)
	switch (chassis?.dir)
		if(NORTH)
			angle = 270
		if(EAST)
			angle = 180
		if(SOUTH)
			angle = 90
		if(WEST)
			angle = 0
	var/target_x = round(range * cos(angle + variance), 1) + current_turf.x
	var/target_y = round(range * sin(angle + variance), 1) + current_turf.y
	escapee.Knockdown(1) //Otherwise everyone hits eachother while being thrown
	escapee.forceMove(drop_location())
	escapee.throw_at(locate(target_x, target_y, current_turf.z), range, 1)

/**
 * Makes the mecha go faster and halves the mecha drill cooldown if in Lavaland pressure.
 *
 * Checks for Lavaland pressure, if that works out the mech's speed is equal to fast_pressure_step_in and the cooldown for the mecha drill is halved. If not it uses slow_pressure_step_in and drill cooldown is normal.
 */
/obj/vehicle/sealed/mecha/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		movedelay = !overclock_mode ? fast_pressure_step_in : fast_pressure_step_in / overclock_coeff
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in flat_equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown) * 0.5

	else
		movedelay = !overclock_mode ? slow_pressure_step_in : slow_pressure_step_in / overclock_coeff
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in flat_equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)
