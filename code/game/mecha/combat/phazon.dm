/obj/mecha/combat/phazon
	desc = "This is a Phazon exosuit. The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge bluespace technology and expensive materials."
	name = "\improper Phazon"
	icon_state = "phazon"
	step_in = 2
	dir_in = 2 //Facing South.
	step_energy_drain = 3
	health = 200
	deflect_chance = 30
	damage_absorption = list("brute"=0.7,"fire"=0.7,"bullet"=0.7,"laser"=0.7,"energy"=0.7,"bomb"=0.7)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/phazon
	add_req_access = 1
	internal_damage_threshold = 25
	force = 15
	var/phasing = 0
	var/phasing_energy_drain = 200
	max_equip = 3
	var/datum/action/mecha/mech_switch_damtype/switch_damtype_action = new
	var/datum/action/mecha/mech_toggle_phasing/phasing_action = new

/obj/mecha/combat/phazon/Bump(var/atom/obstacle)
	if(phasing && get_charge()>=phasing_energy_drain)
		spawn()
			if(can_move)
				can_move = 0
				flick("phazon-phase", src)
				loc = get_step(src, dir)
				use_power(phasing_energy_drain)
				sleep(step_in*3)
				can_move = 1
	else
		. = ..()
	return

/obj/mecha/combat/phazon/click_action(atom/target,mob/user)
	if(phasing)
		occupant_message("Unable to interact with objects while phasing")
		return
	else
		return ..()

/obj/mecha/combat/phazon/GrantActions(var/mob/living/user, var/human_occupant = 0)
	..()
	switch_damtype_action.chassis = src
	switch_damtype_action.Grant(user)

	phasing_action.chassis = src
	phasing_action.Grant(user)


/obj/mecha/combat/phazon/RemoveActions(var/mob/living/user, var/human_occupant = 0)
	..()
	switch_damtype_action.Remove(user)
	phasing_action.Remove(user)


/datum/action/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_switch_damtype"

/datum/action/mecha/mech_switch_damtype/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/phazon/P = chassis
	var/new_damtype
	switch(P.damtype)
		if("tox")
			new_damtype = "brute"
			P.occupant_message("Your exosuit's hands form into fists.")
		if("brute")
			new_damtype = "fire"
			P.occupant_message("A torch tip extends from your exosuit's hand, glowing red.")
		if("fire")
			new_damtype = "tox"
			P.occupant_message("A bone-chillingly thick plasteel needle protracts from the exosuit's palm.")
	P.damtype = new_damtype.
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, 1)


/datum/action/mecha/mech_toggle_phasing
	name = "Enable Phasing"
	button_icon_state = "mech_toggle_phasing"

/datum/action/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/phazon/P = chassis
	P.phasing = !P.phasing
	P.occupant_message("<font color=\"[P.phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")