/datum/component/artifact/surgery
	associated_object = /obj/structure/artifact/surgery
	weight = ARTIFACT_VERYUNCOMMON
	type_name = "Surgery Object"
	activation_message = "springs to life!"
	deactivation_message = "becomes silent."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon
	)
	COOLDOWN_DECLARE(surgery_cooldown)


/datum/component/artifact/surgery/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src, surgery_cooldown))
		holder.visible_message(span_notice("[holder] wheezes, shutting down."))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	human.bioscramble(holder.name)

	COOLDOWN_START(src,surgery_cooldown, 5 SECONDS)
