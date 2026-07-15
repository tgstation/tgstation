/obj/vehicle/sealed/mecha/phazon
	name = "\improper Phazon"
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge anomalous technology and expensive materials."
	icon_state = "phazon"
	base_icon_state = "phazon"
	movedelay = 2
	step_energy_drain = 4
	max_integrity = 200
	armor_type = /datum/armor/mecha_phazon
	max_temperature = 25000
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	destruction_sleep_duration = 40
	exit_delay = 40
	wreckage = /obj/structure/mecha_wreckage/phazon
	mech_type = EXOSUIT_MODULE_PHAZON
	force = 15
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 3,
		MECHA_POWER = 1,
		MECHA_ARMOR = 2,
	)

	/// Are we currently phasing through walls?
	var/phasing = FALSE
	/// Power we use every time we phaze through something
	var/phasing_energy_drain = 0.2 * STANDARD_CELL_CHARGE
	/// Icon_state for flick() when phasing
	var/phase_state = "phazon-phase"

/datum/armor/mecha_phazon
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 30
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/phazon/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_phasing)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_switch_damtype)

/obj/vehicle/sealed/mecha/phazon/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	if(!phasing || get_charge() <= phasing_energy_drain || throwing)
		return ..()
	if(phase_state)
		flick(phase_state, src)
	var/turf/destination_turf = get_step(loc, movement_dir)
	if(!check_teleport_valid(src, destination_turf) || SSmapping.level_trait(destination_turf.z, ZTRAIT_NOPHASE))
		return FALSE
	return TRUE

/obj/vehicle/sealed/mecha/phazon/vehicle_move(direction, forcerotate)
	. = ..()
	if(. && phasing)
		use_energy(phasing_energy_drain)

/obj/vehicle/sealed/mecha/phazon/try_bumpsmash(atom/obstacle)
	if(phasing) // Theres only one cause for phasing canpass fails
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("A dull, universal force is preventing you from phasing here!")]")
		spark_system.start()
		return
	return ..()

/obj/vehicle/sealed/mecha/phazon/update_energy_drain()
	. = ..()
	if(capacitor)
		phasing_energy_drain = initial(phasing_energy_drain) / capacitor.rating
	else
		phasing_energy_drain = initial(phasing_energy_drain)

/obj/vehicle/sealed/mecha/phazon/can_interact_with(atom/target, mob/user, list/modifiers)
	. = ..()
	if (!. || !phasing)
		return
	balloon_alert(user, "not while phasing!")
	return FALSE

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			chassis.balloon_alert(owner, "your punches will now deal brute damage")
		if(BRUTE)
			new_damtype = BURN
			chassis.balloon_alert(owner, "your punches will now deal burn damage")
		if(BURN)
			new_damtype = TOX
			chassis.balloon_alert(owner,"your punches will now deal toxin damage")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(chassis, 'sound/vehicles/mecha/mechmove01.ogg', 50, TRUE)
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/phazon/phazon = chassis
	phazon.phasing = !phazon.phasing
	button_icon_state = "mech_phasing_[phazon.phasing ? "on" : "off"]"
	phazon.balloon_alert(owner, "[phazon.phasing ? "enabled" : "disabled"] phasing")
	build_all_button_icons()
