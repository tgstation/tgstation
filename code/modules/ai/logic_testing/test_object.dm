/obj/item/goof_ai_tester
	name = "goof AI tester"
	var/list/starting_world_state = list("crusading" = 0, "has_sword" = 0, "has_shield" = 0, "has_horse" = 0, "has_prayed" = 0, "at_holy_land" = 0, "has_boat" = 0)

/obj/item/goof_ai_tester/New()
	..()
	create_ai(subtypesof(/datum/goof_action/crusading))
	ai_holder.world_state = starting_world_state

/obj/item/goof_ai_tester/attack_self(mob/user)
	var/datum/goof_plan/P = ai_holder.create_plan(list("crusading" = 1, "has_sword" = 1, "has_shield" = 1, "has_horse" = 1, "has_prayed" = 1, "at_holy_land" = 1))
	if(!P)
		to_chat(world, "FUCK, NO PLAN CREATED HELP")
	else
		for(var/A in P.actions)
			var/datum/goof_action/ACT = A
			to_chat(world, "[ACT.name]")
		to_chat(world, P.current_cost)


/obj/item/goof_ai_tester/sailor
	name = "sailor AI tester"
	starting_world_state = list("crusading" = 0, "has_sword" = 0, "has_shield" = 0, "has_horse" = 0, "has_boat" = 1, "has_prayed" = 0, "at_holy_land" = 0)

/obj/item/goof_ai_tester/knight
	name = "knight AI tester"
	starting_world_state = list("crusading" = 0, "has_sword" = 1, "has_shield" = 1, "has_horse" = 1, "has_boat" = 0, "has_prayed" = 0, "at_holy_land" = 0)