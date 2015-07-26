/obj/mecha/combat/gygax
	desc = "A lightweight, security exosuit. Popular among private and corporate security."
	name = "\improper Gygax"
	icon_state = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	health = 250
	deflect_chance = 5
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	var/overload = 0
	var/overload_coeff = 2
	wreckage = /obj/structure/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3
	step_energy_drain = 3
	var/datum/action/mecha/mech_overload_mode/overload_action = new

/obj/mecha/combat/gygax/dark
	desc = "A lightweight exosuit, painted in a dark scheme. This model appears to have some modifications."
	name = "\improper Dark Gygax"
	icon_state = "darkgygax"
	health = 300
	deflect_chance = 15
	damage_absorption = list("brute"=0.6,"fire"=0.8,"bullet"=0.6,"laser"=0.5,"energy"=0.65,"bomb"=0.8)
	max_temperature = 35000
	overload_coeff = 1
	operation_req_access = list(access_syndicate)
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	max_equip = 4

/obj/mecha/combat/gygax/dark/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	return

/obj/mecha/combat/gygax/dark/add_cell(obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 30000
	cell.maxcharge = 30000


/obj/mecha/combat/gygax/domove(direction)
	if(!..())
		return
	if(overload)
		health--
		if(health < initial(health) - initial(health)/3)
			overload = 0
			step_in = initial(step_in)
			step_energy_drain = initial(step_energy_drain)
			occupant_message("<span class='danger'>Leg actuators damage threshold exceded. Disabling overload.</span>")


/obj/mecha/combat/gygax/get_stats_part()
	var/output = ..()
	output += "<b>Leg actuators overload:</b> [overload?"on":"off"]"
	return output

/obj/mecha/combat/gygax/dark/get_stats_part()
	var/output = ..()
	output += "<br><b>Thrusters:</b> [thrusters?"on":"off"]"
	return output

/obj/mecha/combat/gygax/GrantActions(var/mob/living/user, var/human_occupant = 0)
	..()
	overload_action.chassis = src
	overload_action.Grant(user)

/obj/mecha/combat/gygax/dark/GrantActions(var/mob/living/user, var/human_occupant = 0)
	..()
	thrusters_action.chassis = src
	thrusters_action.Grant(user)


/obj/mecha/combat/gygax/RemoveActions(var/mob/living/user, var/human_occupant = 0)
	..()
	overload_action.Remove(user)

/obj/mecha/combat/gygax/dark/RemoveActions(var/mob/living/user, var/human_occupant = 0)
	..()
	thrusters_action.Remove(user)

/datum/action/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/mecha/mech_overload_mode/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/gygax/G = chassis
	G.overload = !G.overload
	button_icon_state = "mech_overload_[G.overload ? "on" : "off"]"
	G.log_message("Toggled leg actuators overload.")
	if(G.overload)
		G.overload = 1
		G.step_in = min(1, round(G.step_in/2))
		G.step_energy_drain = G.step_energy_drain*G.overload_coeff
		G.occupant_message("<span class='danger'>You enable leg actuators overload.</span>")
	else
		G.overload = 0
		G.step_in = initial(G.step_in)
		G.step_energy_drain = initial(G.step_energy_drain)
		G.occupant_message("<span class='notice'>You disable leg actuators overload.</span>")