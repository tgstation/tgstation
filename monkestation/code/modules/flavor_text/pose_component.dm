/// Called pose as it is inspired from "set pose" from other servers
/// Temporary examine text additions for mobs that is lost on death / incapacitation
/datum/component/pose
	/// Text shown on examine
	var/pose_text

	var/static/mutable_appearance/pose_overlay = mutable_appearance(
		'monkestation/icons/misc/temporary_flavor_text_indicator.dmi',
		"flavor",
		FLY_LAYER,
		appearance_flags = (APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART),
	)

/datum/component/pose/Initialize(pose_text)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.pose_text = pose_text

/datum/component/pose/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LATE_EXAMINE, PROC_REF(on_living_examine))
	RegisterSignals(parent, list(
		COMSIG_LIVING_DEATH,
		SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED),
		SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED),
	), PROC_REF(on_incapacitated))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

	var/mob/living/living_parent = parent
	living_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/pose/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_LIVING_LATE_EXAMINE,
		COMSIG_LIVING_DEATH,
		SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED),
		SIGNAL_REMOVETRAIT(TRAIT_INCAPACITATED),
	))
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)

	var/mob/living/living_parent = parent
	living_parent.update_appearance(UPDATE_OVERLAYS)

/datum/component/pose/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER

	overlays += pose_overlay

/datum/component/pose/proc/on_living_examine(datum/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_italics(span_notice(pose_text))

/datum/component/pose/proc/on_incapacitated(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/// Verb that lets you set temporary pose / examine text.
/mob/living/verb/set_examine()
	set category = "IC"
	set name = "Set Examine Text"
	set desc = "Sets temporary text shown to people on examine. Can be used to pose your character, describe an injury, or anything you can think of."

	if(stat == DEAD || HAS_TRAIT(src, TRAIT_INCAPACITATED))
		to_chat(usr, span_warning("You can't do this right now!"))
		return

	var/default_text = "[p_They()] [p_are()]..."
	var/pose_input = tgui_input_text(usr, "Set temporary examine text here. Can be used to pose your character, \
		describe an injury, or anything you can think of. Leave blank to clear.", "Set Examine Text", default = default_text, max_length = 85)
	if(QDELETED(src))
		return
	if(pose_input == default_text || !length(pose_input))
		qdel(GetComponent(/datum/component/pose)) // This is meh but I didn't want to make a signal just for "COMSIG_LIVING_POSE_SET"
		return
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_INCAPACITATED))
		to_chat(usr, span_warning("You can't do this right now!"))
		return

	AddComponent(/datum/component/pose, pose_input)
