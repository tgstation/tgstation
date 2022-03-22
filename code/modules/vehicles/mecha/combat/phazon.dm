/obj/vehicle/sealed/mecha/combat/phazon
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge bluespace technology and expensive materials."
	name = "\improper Phazon"
	icon_state = "phazon"
	base_icon_state = "phazon"
	movedelay = 2
	dir_in = 2 //Facing South.
	step_energy_drain = 3
	max_integrity = 200
	deflect_chance = 30
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 25000
	wreckage = /obj/structure/mecha_wreckage/phazon
	internal_damage_threshold = 25
	force = 15
	max_equip = 3
	phase_state = "phazon-phase"

/obj/vehicle/sealed/mecha/combat/phazon/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_phasing)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_switch_damtype)

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
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
	playsound(chassis, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "phasing"
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "enabled" : "disabled"] phasing")
	UpdateButtonIcon()
