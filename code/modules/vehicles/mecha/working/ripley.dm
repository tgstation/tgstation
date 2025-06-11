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
	mecha_flags = CAN_STRAFE | HAS_LIGHTS | BEACON_TRACKABLE
	wreckage = /obj/structure/mecha_wreckage/ripley
	mech_type = EXOSUIT_MODULE_RIPLEY
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_CONTROL_LOST|MECHA_INT_SHORT_CIRCUIT
	accesses = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	/// Custom Ripley step and turning sounds (from TGMC)
	stepsound = 'sound/vehicles/mecha/powerloader_step.ogg'
	turnsound = 'sound/vehicles/mecha/powerloader_turn2.ogg'
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
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | BEACON_TRACKABLE | AI_COMPATIBLE | BEACON_CONTROLLABLE
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
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | AI_COMPATIBLE
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
	name = "\improper APLU \"Big Bess\""
	desc = "An ailing, old, repurposed cargo hauler. Most of its equipment wires are frayed or missing and its frame is rusted."
	icon_state = "hauler"
	base_icon_state = "hauler"
	silicon_icon_state = "hauler-empty"
	max_integrity = 100 //Has half the health of a normal RIPLEY mech, so it's harder to use as a weapon.

/obj/vehicle/sealed/mecha/ripley/cargo/Initialize(mapload)
	. = ..()

	//Attach hydraulic clamp ONLY
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	take_damage(max_integrity * 0.5, sound_effect=FALSE) //Low starting health
	if(!GLOB.cargo_ripley && mapload)
		GLOB.cargo_ripley = src
	ADD_TRAIT(src, TRAIT_MECHA_DIAGNOSTIC_CREATED, REF(src)) //It was built *long* before the shift started.

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

/obj/item/mecha_parts/mecha_equipment/ejector/detach(atom/moveto)
	var/obj/vehicle/sealed/mecha/ripley/workmech = chassis
	workmech.cargo_hold = null
	drop_contents(isturf(moveto) ? moveto : moveto?.drop_location())
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/Destroy()
	// Failsafe so we don't delete players
	var/atom/droploc = drop_location() || get_turf(src)
	for(var/mob/stored in get_all_contents())
		if(stored.client)
			stack_trace("[stored] was in [src] when it was deleted! We skipped deconstruct(), or something.")
			stored.forceMove(droploc)
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/atom_deconstruct(damage_flag)
	drop_contents()
	return ..()

/obj/item/mecha_parts/mecha_equipment/ejector/contents_explosion(severity, target)
	drop_contents(drop_prob = 10 * severity)
	return ..()

/// Spit out everything in our storage
/obj/item/mecha_parts/mecha_equipment/ejector/proc/drop_contents(atom/drop_loc = drop_location(), drop_prob = 100)
	for(var/atom/movable/stored in src)
		if(prob(drop_prob))
			stored.forceMove(drop_loc || get_turf(src))
			step_rand(stored)

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
		playsound(chassis, 'sound/items/weapons/tap.ogg', 50, TRUE)
		log_message("Unloaded [crate]. Cargo compartment capacity: [cargo_capacity - contents.len]", LOG_MECHA)
		return TRUE

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
