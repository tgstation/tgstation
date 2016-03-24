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
	max_equip = 3
	phase_state = "phazon-phase"

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

