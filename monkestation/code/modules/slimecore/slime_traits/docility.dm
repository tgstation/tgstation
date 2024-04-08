/datum/slime_trait/docility
	name = "Docility Mutation"
	desc = "Mutates a slime so they avoid people with souls"

/datum/slime_trait/docility/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.ai_controller.set_blackboard_key(BB_WONT_TARGET_CLIENTS, TRUE)

/datum/slime_trait/docility/on_remove(mob/living/basic/slime/parent)
	. = ..()
	parent.ai_controller.set_blackboard_key(BB_WONT_TARGET_CLIENTS, FALSE)
