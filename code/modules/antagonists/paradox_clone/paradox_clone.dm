/datum/antagonist/paradox_clone
	name = "\improper Paradox Clone"
	roundend_category = "Paradox Clone"
	pref_flag = ROLE_PARADOX_CLONE
	antagpanel_category = ANTAG_GROUP_PARADOX
	antag_hud_name = "paradox_clone"
	show_to_ghosts = TRUE
	suicide_cry = "THERE CAN BE ONLY ONE!!"
	preview_outfit = /datum/outfit/paradox_clone

	///Weakref to the mind of the original, the clone's target.
	var/datum/weakref/original_ref

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

/datum/antagonist/paradox_clone/Destroy()
	original_ref = null
	return ..()

/datum/antagonist/paradox_clone/proc/setup_clone()
	var/datum/mind/original_mind = original_ref?.resolve()

	var/datum/objective/assassinate/paradox_clone/kill = new
	kill.owner = owner
	kill.target = original_mind
	kill.update_explanation_text()
	objectives += kill

	owner.set_assigned_role(SSjob.get_job_type(/datum/job/paradox_clone))

	//clone doesnt show up on message lists
	var/obj/item/modular_computer/pda/messenger = locate() in owner.current
	if(messenger)
		var/datum/computer_file/program/messenger/message_app = locate() in messenger.stored_files
		if(message_app)
			message_app.invisible = TRUE

	//dont want anyone noticing there's two now
	var/mob/living/carbon/human/clone_human = owner.current
	var/obj/item/clothing/under/sensor_clothes = clone_human.w_uniform
	if(sensor_clothes)
		sensor_clothes.sensor_mode = SENSOR_OFF
		clone_human.update_suit_sensors()

	// Perform a quick copy of existing memories.
	// This may result in some minutely imperfect memories, but it'll do
	original_mind.quick_copy_all_memories(owner)

/datum/antagonist/paradox_clone/roundend_report_header()
	return span_header("A paradox clone appeared on the station!<br>")

/datum/outfit/paradox_clone
	name = "Paradox Clone (Preview only)"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft/purple

/**
 * Paradox clone assassinate objective
 * Similar to the original, but with a different flavortext.
 */
/datum/objective/assassinate/paradox_clone
	name = "clone assassinate"

/datum/objective/assassinate/paradox_clone/update_explanation_text()
	. = ..()
	if(!target?.current)
		explanation_text = "Free Objective"
		CRASH("WARNING! [ADMIN_LOOKUPFLW(owner)] paradox clone objectives forged without an original!")
	explanation_text = "Murder and replace [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())]. Remember, your mission is to blend in, do not kill anyone else unless you have to!"

///Static bluespace stream used in its ghost poll icon.
/obj/effect/bluespace_stream
	name = "bluespace stream"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bluestream"
