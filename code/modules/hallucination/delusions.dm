/// A hallucination that makes us and (possibly) other people look like something else.
/datum/hallucination/delusion
	abstract_hallucination_parent = /datum/hallucination/delusion

	/// The duration of the delusions
	var/duration = 30 SECONDS

	/// If TRUE, this delusion affects us
	var/affects_us = TRUE
	/// If TRUE, this hallucination affects all humans in existence
	var/affects_others = FALSE
	/// If TRUE, people in view of our hallcuinator won't be affected (requires affects_others)
	var/skip_nearby = FALSE
	/// If TRUE, we will play the wabbajack sound effect to the hallucinator
	var/play_wabbajack = FALSE

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
	affects_us = TRUE,
	affects_others = FALSE,
	skip_nearby = TRUE,
	play_wabbajack = FALSE,
)

	src.duration = duration
	src.affects_us = affects_us
	src.affects_others = affects_others
	src.skip_nearby = skip_nearby
	src.play_wabbajack = play_wabbajack
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

	var/list/mob/living/carbon/human/funny_looking_mobs = list()

	// The delusion includes others - all humans
	if(affects_others)
		funny_looking_mobs |= GLOB.human_list.Copy()

	// The delusion includes us - we might be in it already, we might not
	if(affects_us)
		funny_looking_mobs |= hallucinator

	// The delusion should not inlude us
	else
		funny_looking_mobs -= hallucinator

	// The delusion shouldn not include anyone in view of us
	if(skip_nearby)
		for(var/mob/living/carbon/human/nearby_human in view(hallucinator))
			if(nearby_human == hallucinator)
				continue
			funny_looking_mobs -= nearby_human

	for(var/mob/living/carbon/human/found_human in funny_looking_mobs)
		var/image/funny_image = make_delusion_image(found_human)
		LAZYADD(delusions, funny_image)
		hallucinator.client.images |= funny_image

	if(play_wabbajack)
		to_chat(hallucinator, span_hear("...wabbajack...wabbajack..."))
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/magic/staff_change.ogg', 50, TRUE)

	if(duration > 0)
		QDEL_IN(src, duration)
	return TRUE

/datum/hallucination/delusion/proc/make_delusion_image(mob/over_who)
	var/image/funny_image = image(delusion_icon_file, over_who, delusion_icon_state)
	funny_image.name = delusion_name
	funny_image.override = TRUE
	return funny_image

/// Used for making custom delusions.
/datum/hallucination/delusion/custom
	abstract_hallucination_parent = /datum/hallucination/delusion/custom
	random_hallucination_weight = 0

/datum/hallucination/delusion/custom/New(
	mob/living/hallucinator,
	duration = 30 SECONDS,
	affects_us = TRUE,
	affects_others = FALSE,
	skip_nearby = FALSE,
	play_wabbajack = FALSE,
	custom_icon_file,
	custom_icon_state,
	custom_name,
)

	if(!custom_icon_file || !custom_icon_state)
		stack_trace("Custom delusion hallucination was created without any custom icon information passed.")

	src.delusion_icon_file = custom_icon_file
	src.delusion_icon_state = custom_icon_state
	src.delusion_name = custom_name

	return ..()

/datum/hallucination/delusion/preset
	abstract_hallucination_parent = /datum/hallucination/delusion/preset
	random_hallucination_weight = 2

/datum/hallucination/delusion/preset/nothing
	delusion_icon_file = 'icons/effects/effects.dmi'
	delusion_icon_state = "nothing"
	delusion_name = "..."

/datum/hallucination/delusion/preset/curse
	delusion_icon_file = 'icons/mob/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "curseblob"
	delusion_name = "???"

/datum/hallucination/delusion/preset/monkey
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/monkey/start()
	delusion_name += " ([rand(1,999)])"
	return ..()

/datum/hallucination/delusion/preset/corgi
	delusion_icon_file = 'icons/mob/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/preset/carp
	delusion_icon_file = 'icons/mob/carp.dmi'
	delusion_icon_state = "carp"
	delusion_name = "carp"

/datum/hallucination/delusion/preset/skeleton
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/preset/zombie
	delusion_icon_file = 'icons/mob/human.dmi'
	delusion_icon_state = "zombie"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/demon
	delusion_icon_file = 'icons/mob/mob.dmi'
	delusion_icon_state = "daemon"
	delusion_name = "demon"

/datum/hallucination/delusion/preset/cyborg
	play_wabbajack = TRUE
	delusion_icon_file = 'icons/mob/robots.dmi'
	delusion_icon_state = "robot"
	delusion_name = "cyborg"

/datum/hallucination/delusion/preset/cyborg/make_delusion_image(mob/over_who)
	. = ..()
	hallucinator.playsound_local(get_turf(over_who), 'sound/voice/liveagain.ogg', 75, TRUE)

/// Helper to give the passed mob the ability to create a delusion hallucination (even a custom one).
/// Returns a list of arguments - pass these to cause_hallucination to cause the desired hallucination (be sure to wrap in argslist)
/proc/create_delusion(mob/user)
	var/static/list/delusions
	if(!delusions)
		delusions = typesof(/datum/hallucination/delusion)
		for(var/datum/hallucination/delusion_type as anything in delusions)
			if(initial(delusion_type.abstract_hallucination_parent) == delusion_type)
				delusions -= delusion_type

	var/chosen = tgui_input_list(user, "Select a delusion type. Custom will allow for custom icon entry.", "Select Delusion", delusions)
	if(!chosen || !ispath(chosen, /datum/hallucination/delusion))
		return

	var/list/delusion_args = list()
	var/static/list/options = list("Yes", "No")
	var/duration = tgui_input_number(user, "How long should it last in deciseconds?", "Give Delusion", max_value = INFINITY, min_value = 1 SECONDS, default = 30 SECONDS)
	var/affects_us = (tgui_alert(user, "Should the mob see themselves as the delusion?", "Give Delusion", options) == "Yes")
	var/affects_others = (tgui_alert(user, "Should the mob see everyone else delusion?", "Give Delusion", options) == "Yes")
	var/skip_nearby = (tgui_alert(user, "Should the mob only see people outside of their view as the delusion?", "Give Delusion", options) == "Yes")
	var/play_wabbajack = (tgui_alert(user, "Play the wabbajack sound when it's done?", "Give Delusion", options) == "Yes")

	delusion_args = list(
		chosen,
		"forced delusion",
		duration,
		affects_us,
		affects_others,
		skip_nearby,
		play_wabbajack,
	)

	if(ispath(chosen, /datum/hallucination/delusion/custom))
		var/custom_file = input(user, "Pick file for custom delusion:", "File") as null|file
		if(!custom_file)
			return

		var/custom_icon_state = tgui_input_text(user, "What icon state do you wanna use from the file?", "Icon State")
		if(!custom_icon_state)
			return

		var/custom_name = tgui_input_text(user, "What name should it show up as?", "Name")

		delusion_args += list(
			custom_file,
			custom_icon_state,
			custom_name,
		)

	return delusion_args
