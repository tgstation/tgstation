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

/obj/item/goof_pathfinding_ai
	name = "goof pathfinding tester"

/obj/item/goof_pathfinding_ai/attack_self(mob/user)
	var/turf/my_loc = get_turf(user)
	for(var/mob/living/carbon/human/goap/G in world)
		G.ai_holder.override_idle = TRUE
		goto remake_plan
		remake_plan:
			G.ai_holder.world_state["target"] = my_loc
			G.ai_holder.world_state["has_target"] = 1
			if(!G.Adjacent(G.ai_holder.world_state["target"]))
				G.ai_holder.world_state["adjacent_to_target"] = 0
			var/datum/goof_plan/P = G.ai_holder.create_plan(list("adjacent_to_target" = 1))
			for(var/datum/goof_action/A in P.actions)
				if(A.perform_action(G))
					A.do_action(G.ai_holder.world_state)
					continue
				else
					goto remake_plan
		G.ai_holder.override_idle = FALSE
		G.ai_holder.ramblers_lets_get_rambling = null
