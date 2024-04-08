/datum/corral_upgrade/human_docility_upgrade
	name = "Human Docility Upgrade"
	desc = "Makes the non rabid slimes docile to people with souls."
	cost = 2500

/datum/corral_upgrade/human_docility_upgrade/on_add(datum/corral_data/parent)
	for(var/mob/living/basic/slime/slime as anything in parent.managed_slimes)
		slime.ai_controller.set_blackboard_key(BB_WONT_TARGET_CLIENTS, TRUE)

/datum/corral_upgrade/human_docility_upgrade/on_slime_entered(mob/living/basic/slime/slime)
	slime.ai_controller.set_blackboard_key(BB_WONT_TARGET_CLIENTS, TRUE)

/datum/corral_upgrade/human_docility_upgrade/on_slime_exited(mob/living/basic/slime/slime)
	if(slime.has_slime_trait(/datum/slime_trait/docility))
		return
	slime.ai_controller.set_blackboard_key(BB_WONT_TARGET_CLIENTS, FALSE)
