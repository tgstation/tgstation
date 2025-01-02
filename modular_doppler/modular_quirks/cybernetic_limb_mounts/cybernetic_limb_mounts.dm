/datum/quirk/robot_limb_detach
	name = "Cybernetic Limb Mounts"
	desc = "You are able to detach and reattach any installed robotic limbs with very little effort, as long as they're in good condition."
	gain_text = span_notice("Internal sensors report limb disengagement protocols are ready and waiting.")
	lose_text = span_notice("ERROR: LIMB DISENGAGEMENT PROTOCOLS OFFLINE.")
	medical_record_text = "Patient bears quick-attach and release limb joint cybernetics."
	value = 0
	mob_trait = TRAIT_ROBOTIC_LIMBATTACHMENT
	icon = FA_ICON_HANDSHAKE_SIMPLE_SLASH
	quirk_flags = QUIRK_HUMAN_ONLY
	/// The action we add with this quirk in add(), used for easy deletion later
	var/datum/action/cooldown/spell/added_action

/datum/quirk/robot_limb_detach/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/action/cooldown/spell/robot_self_amputation/limb_action = new /datum/action/cooldown/spell/robot_self_amputation()
	limb_action.Grant(human_holder)
	added_action = limb_action

/datum/quirk/robot_limb_detach/remove()
	QDEL_NULL(added_action)

/datum/action/cooldown/spell/robot_self_amputation
	name = "Detach a robotic limb"
	desc = "Disengage one of your robotic limbs from your cybernetic mounts. Requires you to not be restrained or otherwise under duress. Will not function on wounded limbs - tend to them first."
	button_icon_state = "autotomy"

	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_INCAPACITATED

/datum/action/cooldown/spell/robot_self_amputation/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/robot_self_amputation/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(HAS_TRAIT(cast_on, TRAIT_NODISMEMBER))
		to_chat(cast_on, span_warning("ERROR: LIMB DISENGAGEMENT PROTOCOLS OFFLINE. Seek out a maintenance technician."))
		return

	var/list/exclusions = list()
	exclusions += BODY_ZONE_CHEST
	exclusions += BODY_ZONE_HEAD
	// if we ever decide to move android's brains into their chest, add this below
	/*if (!isandroid(cast_on))
		exclusions += BODY_ZONE_HEAD
	*/

	var/list/robot_parts = list()
	for (var/obj/item/bodypart/possible_part as anything in cast_on.bodyparts)
		if ((possible_part.bodytype & BODYTYPE_ROBOTIC) && !(possible_part.body_zone in exclusions)) //only robot limbs and only if they're not crucial to our like, ongoing life, you know?
			robot_parts += possible_part

	if (!length(robot_parts))
		to_chat(cast_on, "ERROR: Limb disengagement protocols report no compatible cybernetics currently installed. Seek out a maintenance technician.")
		return

	var/obj/item/bodypart/limb_to_detach = tgui_input_list(cast_on, "Limb to detach", "Cybernetic Limb Detachment", sort_names(robot_parts))
	if (QDELETED(src) || QDELETED(cast_on) || QDELETED(limb_to_detach))
		return

	if (length(limb_to_detach.wounds) >= 1)
		cast_on.balloon_alert(cast_on, "can't detach wounded limbs!")
		playsound(cast_on, 'sound/machines/buzz/buzz-sigh.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return

	cast_on.balloon_alert(cast_on, "detaching limb...")
	playsound(cast_on, 'sound/items/tools/rped.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	cast_on.visible_message(span_notice("[cast_on] shuffles [cast_on.p_their()] [limb_to_detach.name] forward, actuators hissing and whirring as [cast_on.p_they()] disengage[cast_on.p_s()] the limb from its mount..."))

	if(do_after(cast_on, 5 SECONDS))
		cast_on.visible_message(span_notice("With a gentle twist, [cast_on] finally prises [cast_on.p_their()] [limb_to_detach.name] free from its socket."))
		limb_to_detach.drop_limb()
		cast_on.put_in_hands(limb_to_detach)
		cast_on.balloon_alert(cast_on, "limb detached!")
		if(prob(5))
			playsound(cast_on, 'sound/items/champagne_pop.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		else
			playsound(cast_on, 'sound/items/deconstruct.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else
		cast_on.balloon_alert(cast_on, "interrupted!")
		playsound(cast_on, 'sound/machines/buzz/buzz-sigh.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
