/datum/artifact_effect/surgery
	weight = ARTIFACT_VERYUNCOMMON
	type_name = "Surgery Object Effect"
	activation_message = "springs to life!"
	deactivation_message = "becomes silent."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon
	)
	COOLDOWN_DECLARE(surgery_cooldown)

	research_value = 1250

	examine_discovered = span_warning("It appears to be some sort of automated surgery device")

/datum/artifact_effect/surgery/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src, surgery_cooldown))
		our_artifact.holder.visible_message(span_notice("[our_artifact.holder] wheezes, shutting down."))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	human.bioscramble(our_artifact.holder.name)

	COOLDOWN_START(src,surgery_cooldown, 5 SECONDS)
