/datum/emote/living/telepathy_reply
	key = "treply"
	key_third_person = "treply"
	cooldown = 4 SECONDS

/datum/emote/living/telepathy_reply/run_emote(mob/living/user, params, type_override, intentional)
	if (ishuman(user) && intentional)
		var/mob/living/carbon/human/human_user = user
		var/datum/mutation/human/telepathy/mutation = human_user.dna.get_mutation(/datum/mutation/human/telepathy)
		if (mutation)
			var/datum/action/cooldown/spell/pointed/telepathy/tele_action = locate() in user.actions
			// just straight up call the right-click action as is
			if (tele_action)
				tele_action.Trigger(TRIGGER_SECONDARY_ACTION)
				tele_action.blocked = FALSE

	return ..()
