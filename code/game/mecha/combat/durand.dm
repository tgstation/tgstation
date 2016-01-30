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
	wreckage = /obj/structure/mecha_wreckage/durand

/obj/mecha/combat/durand/GrantActions(var/mob/living/user, var/human_occupant = 0)
	..()
	defense_action.chassis = src
	defense_action.Grant(user)

/obj/mecha/combat/durand/RemoveActions(var/mob/living/user, var/human_occupant = 0)
	..()
	defense_action.Remove(user)

