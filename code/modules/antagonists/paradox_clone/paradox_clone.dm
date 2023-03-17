/datum/antagonist/paradox_clone
	name = "\improper Paradox Clone"
	roundend_category = "Paradox Clone"
	job_rank = ROLE_PARADOX_CLONE
	antag_hud_name = "paradox_clone"
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

/datum/antagonist/paradox_clone/on_gain()
	owner.special_role = ROLE_PARADOX_CLONE
	return ..()

/datum/antagonist/paradox_clone/on_removal()
	//don't null it if we got a different one added on top, somehow.
	if(owner.special_role == ROLE_PARADOX_CLONE)
		owner.special_role = null
	original_ref = null
	return ..()

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

	var/mob/living/carbon/human/clone_human = owner.current
	var/mob/living/carbon/human/original_human = original_mind.current

	//equip them in the original's clothes
	if(!isplasmaman(original_human))
		clone_human.equipOutfit(original_human.mind.assigned_role.outfit)
	else
		clone_human.equipOutfit(original_human.mind.assigned_role.plasmaman_outfit)
		clone_human.internal = clone_human.get_item_for_held_index(2)

	//clone doesnt show up on message lists
	var/obj/item/modular_computer/pda/messenger = locate() in clone_human
	if(messenger)
		var/datum/computer_file/program/messenger/message_app = locate() in messenger.stored_files
		if(message_app)
			message_app.invisible = TRUE

	//dont want anyone noticing there's two now
	var/obj/item/clothing/under/sensor_clothes = clone_human.w_uniform
	if(sensor_clothes)
		sensor_clothes.sensor_mode = SENSOR_OFF
		clone_human.update_suit_sensors()

	// Perform a quick copy of existing memories.
	// This may result in some minutely imperfect memories, but it'll do
	original_mind.quick_copy_all_memories(owner)

/datum/antagonist/paradox_clone/roundend_report_header()
	return "<span class='header'>A paradox clone appeared on the station!</span><br>"

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
	explanation_text = "Murder and replace [target.name], the [!target_role_type ? target.assigned_role.title : target.special_role]. Remember, your mission is to blend in, do not kill anyone else unless you have to!"
