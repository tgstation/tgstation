/datum/slime_trait/visual/cat
	name = "Gooey Cat"
	desc = "A docile slime with cat ears!"

	trait_icon_state = "cat_ears"
	trait_icon = 'monkestation/code/modules/slimecore/icons/slimes.dmi'
	menu_buttons = list(FOOD_CHANGE, DOCILE_CHANGE, BEHAVIOUR_CHANGE)

/datum/slime_trait/visual/cat/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.replacement_trees += list(/datum/ai_planning_subtree/simple_find_target_no_trait/slime = /datum/ai_planning_subtree/simple_find_target_no_trait/slime_cat)
	parent.emotion_states[EMOTION_HAPPY] = "aslime-:33"
	SEND_SIGNAL(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, parent.emotion_states)
	parent.recompile_ai_tree()

/datum/slime_trait/visual/cat/on_remove (mob/living/basic/slime/parent)
	parent.replacement_trees -= list(/datum/ai_planning_subtree/simple_find_target_no_trait/slime = /datum/ai_planning_subtree/simple_find_target_no_trait/slime_cat)
	parent.emotion_states[EMOTION_HAPPY] = "aslime-happy"
	SEND_SIGNAL(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, parent.emotion_states)
	parent.recompile_ai_tree()
