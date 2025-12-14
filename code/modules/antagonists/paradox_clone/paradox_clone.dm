/datum/antagonist/paradox_clone
	name = "\improper Paradox Clone"
	roundend_category = "Paradox Clone"
	pref_flag = ROLE_PARADOX_CLONE
	antagpanel_category = ANTAG_GROUP_PARADOX
	antag_hud_name = "paradox_clone"
	show_to_ghosts = TRUE
	suicide_cry = "THERE CAN BE ONLY ONE!!"
	preview_outfit = /datum/outfit/paradox_clone

/datum/antagonist/paradox_clone/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_background_clone_icon(preview_outfit), ICON_UNDERLAY, -8, 0)
	final_icon.Scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/paradox_clone/proc/make_background_clone_icon(datum/outfit/clone_fit)
	var/mob/living/carbon/human/dummy/consistent/clone = new

	var/icon/clone_icon = render_preview_outfit(clone_fit, clone)
	clone_icon.ChangeOpacity(0.5)
	qdel(clone)

	return clone_icon

/datum/antagonist/paradox_clone/proc/setup_clone(datum/mind/original_mind)
	if(isnull(original_mind))
		CRASH("Tried to set up a paradox clone without an original mind!")

	var/datum/objective/accept_no_substitutes/kill = new()
	kill.owner = owner
	kill.set_target_name(original_mind.name || "Unknown")
	objectives += kill

	var/datum/objective/paradox_clone_replace/replace = new()
	replace.owner = owner
	replace.name_and_job = "[original_mind.name], the [original_mind.assigned_role.title]"
	replace.update_explanation_text()
	objectives += replace

	owner.set_assigned_role(SSjob.get_job_type(/datum/job/paradox_clone))

	//clone doesnt show up on message lists
	var/obj/item/modular_computer/pda/messenger = locate() in owner.current
	var/datum/computer_file/program/messenger/message_app = locate() in messenger?.stored_files
	message_app?.invisible = TRUE

	//dont want anyone noticing there's two now
	var/mob/living/carbon/human/clone_human = owner.current
	var/obj/item/clothing/under/sensor_clothes = clone_human.w_uniform
	if(istype(sensor_clothes))
		sensor_clothes.set_sensor_mode(SENSOR_OFF)

	// Perform a quick copy of existing memories.
	// This may result in some minutely imperfect memories, but it'll do
	original_mind.quick_copy_all_memories(owner)

/datum/antagonist/paradox_clone/roundend_report_header()
	return span_header("A paradox clone appeared on the station!<br>")

/datum/objective/paradox_clone_replace
	name = "clone replace"
	/// Name and job of the original to replace
	var/name_and_job

/datum/objective/paradox_clone_replace/update_explanation_text()
	explanation_text = "Take [name_and_job || "someone's"]'s place. Avoid collateral damage - remember, your mission is to blend in!"

/datum/objective/paradox_clone_replace/check_completion()
	return completed || considered_alive(owner)

/datum/outfit/paradox_clone
	name = "Paradox Clone (Preview only)"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft/purple

///Static bluespace stream used in its ghost poll icon.
/obj/effect/bluespace_stream
	name = "bluespace stream"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bluestream"
