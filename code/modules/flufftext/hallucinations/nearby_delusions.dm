

/// A hallucination that makes every mob look like something else.
/datum/hallucination/delusion
	/// if TRUE, we will only make people out of view into a delusion
	var/skip_nearby = TRUE
	/// The duration of the delusions
	var/duration = 30 SECONDS

	/// The file the delusion image is made from
	var/delusion_icon_file
	/// The icon state of the delusion image
	var/delusion_icon_state
	/// The name of the delusion image
	var/delusion_name

	/// A list of all images we've made
	var/list/image/delusions

/datum/hallucination/delusion/New(
	mob/living/hallucinator,
	duration = 30 SECONDS,
	skip_nearby = TRUE,
)

	src.skip_nearby = skip_nearby
	src.duration = duration
	return ..()

/datum/hallucination/delusion/Destroy()
	if(!QDELETED(hallucinator))
		for(var/image/to_remove as anything in delusions)
			hallucinator.client?.images -= to_remove

	return ..()

/datum/hallucination/delusion/start()
	if(!hallucinator.client || !delusion_icon_file)
		return FALSE

	feedback_details += "Delusion: [delusion_name]"

	var/list/mob/living/carbon/human/mobs_to_trick_us = GLOB.human_list.Copy()
	if(ishuman(hallucinator))
		mobs_to_trick_us -= hallucinator

	if(skip_nearby)
		for(var/mob/living/carbon/human/nearby_human in view(hallucinator))
			mobs_to_trick_us -= nearby_human

	for(var/mob/living/carbon/human/alive_human in mobs_to_trick_us)
		var/image/fake_appearance = image(delusion_icon_file, alive_human, delusion_icon_state)
		fake_appearance.name = delusion_name
		fake_appearance.override = TRUE
		delusions |= fake_appearance
		hallucinator.client.images |= fake_appearance

	if(duration > 0)
		QDEL_IN(src, duration)
	return TRUE

/// Used for making custom delusions.
/datum/hallucination/delusion/custom

/datum/hallucination/delusion/custom/New(
	mob/living/hallucinator,
	duration = 30 SECONDS,
	skip_nearby = TRUE,
	custom_icon_file,
	custom_icon_state,
	custom_name,
)

	// If we weren't given any custom things, just use a random delusion type's settings
	if(!custom_icon_file || !custom_icon_state)
		var/datum/hallucination/delusion/replacement = pick(subtypesof(/datum/hallucination/delusion)) - type
		delusion_icon_file = initial(replacement.delusion_icon_file)
		delusion_icon_state = initial(replacement.delusion_icon_state)
		delusion_name = initial(replacement.delusion_name)

	else
		src.delusion_icon_file = custom_icon_file
		src.delusion_icon_state = custom_icon_state
		src.delusion_name = custom_name

	return ..()

/datum/hallucination/delusion/nothing
	delusion_icon_file = 'icons/effects/effects.dmi'
	delusion_icon_state = "nothing"
	delusion_name = "..."

/datum/hallucination/delusion/curse
	delusion_icon_file = 'icons/mob/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "curseblob"
	delusion_name = "???"

/datum/hallucination/delusion/monkey
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/monkey/New(mob/living/hallucinator, duration, skip_nearby)
	. = ..()
	delusion_name += " ([rand(1,999)])"

/datum/hallucination/delusion/corgi
	delusion_icon_file = 'icons/mob/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/carp
	delusion_icon_file = 'icons/mob/carp.dmi'
	delusion_icon_state = "carp"
	delusion_name = "carp"

/datum/hallucination/delusion/skeleton
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/zombie
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "zombie"
	delusion_name = "zombie"

/datum/hallucination/delusion/demon
	delusion_icon_file = 'icons/mob/mob.dmi'
	delusion_icon_state = "daemon"
	delusion_name = "demon"
