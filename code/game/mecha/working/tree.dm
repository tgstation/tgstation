/obj/mecha/working/tree
	desc = "This special exosuit is fuelled by living wood. This allows it to be a bit lighter and nimble, but it is weaker than metal."
	name = "\improper Murmuring Wood"
	icon_state = "murmuring_wood"
	silicon_icon_state = "murmuring_open"
	step_in = 1.5
	max_integrity = 150
	lights_power = 0
	deflect_chance = 0
	armor = list("melee" = 25, "bullet" = 20, "laser" = 0, "energy" = 0, "bomb" = 40, "bio" = 0, "rad" = 20, "fire" = 100, "acid" = 100)
	max_equip = 2
	wreckage = /obj/structure/mecha_wreckage/aquifer
	operation_req_access = list()
	internals_req_access = list()
	enclosed = FALSE//not spaceproof
	var/obj/item/seeds/seed

/obj/mecha/working/tree/Initialize(mapload, plantseed)
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)
	seed = plantseed
	if(!seed) //admin spawn?
		seed = new /obj/item/seeds/murmuring_wood()
	seed.forceMove(src)
	create_reagents(seed.potency*10)
	max_integrity = seed.potency*15
	obj_integrity = max_integrity
	if(seed.potency > 5)
		max_equip += 2

/obj/mecha/combat/gygax/GrantActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Grant(user, src)

/obj/mecha/combat/gygax/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Remove(user)
