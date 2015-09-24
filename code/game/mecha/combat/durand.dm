/obj/mecha/combat/durand
	desc = "An aging combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "\improper Durand"
	icon_state = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	health = 400
	deflect_chance = 20
	damage_absorption = list("brute"=0.5,"fire"=1.1,"bullet"=0.65,"laser"=0.85,"energy"=0.9,"bomb"=0.8)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	var/defence = 0
	var/defence_deflect = 35
	wreckage = /obj/structure/mecha_wreckage/durand
	var/datum/action/mecha/mech_defence_mode/defense_action = new

/obj/mecha/combat/durand/relaymove(mob/user,direction)
	if(defence)
		if(world.time - last_message > 20)
			src.occupant_message("<span class='danger'>Unable to move while in defence mode</span>")
			last_message = world.time
		return 0
	. = ..()
	return

/obj/mecha/combat/durand/GrantActions(var/mob/living/user, var/human_occupant = 0)
	..()
	defense_action.chassis = src
	defense_action.Grant(user)

/obj/mecha/combat/durand/RemoveActions(var/mob/living/user, var/human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/get_stats_part()
	var/output = ..()
	output += "<b>Defence mode:</b> [defence?"on":"off"]"
	return output

/datum/action/mecha/mech_defence_mode
	name = "Toggle Defense Mode"
	button_icon_state = "mech_defense_mode_off"

/datum/action/mecha/mech_defence_mode/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/obj/mecha/combat/durand/D = chassis
	D.defence = !D.defence
	button_icon_state = "mech_defense_mode_[D.defence ? "on" : "off"]"
	if(D.defence)
		D.deflect_chance = D.defence_deflect
		D.occupant_message("<span class='notice'>You enable [D] defence mode.</span>")
	else
		D.deflect_chance = initial(D.deflect_chance)
		D.occupant_message("<span class='danger'>You disable [D] defence mode.</span>")
	D.log_message("Toggled defence mode.")