/**
 * Deaconize
 * Makes a sentient, non-cult member of the station into a Holy person, able to use bibles & other chap gear.
 * Is a one-time use ability, given to all sects that don't have their own variation of it.
 */
/datum/religion_rites/deaconize
	name = "Посвящение в диакона"
	desc = "Обращает кого-то в вашу религию. Необходимо добровольное согласие, так как при первом использовании претенденту сначала предложат вступить. \
		Он обретёт те же святые силы, что и вы. Вы можете посвятить только одного человека, так что убедитесь, что он достоин!"
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"Хороший, благородный человек был приведен сюда верой ...",
		"С руками, готовыми служить ...",
		"С сердцем, готовым слушать ...",
		"И душой, готовой следовать ...",
		"Да предложим мы свою руку взамен ..."
	)
	invoke_msg = "И использовать их наилучшим образом."
	rite_flags = RITE_ALLOW_MULTIPLE_PERFORMS | RITE_ONE_TIME_USE

	///The person currently being deaconized.
	var/mob/living/carbon/human/potential_deacon

/datum/religion_rites/deaconize/Destroy()
	potential_deacon = null
	return ..()

/datum/religion_rites/deaconize/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("Для проведения обряда необходим священный алтарь, на котором участник может быть зафиксирован."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	var/mob/living/carbon/human/possible_deacon = locate() in movable_reltool.buckled_mobs
	if(!possible_deacon)
		to_chat(user, span_warning("Ничего не пристегнуто к [movable_reltool.declent_ru(DATIVE)]!"))
		return FALSE
	if(!is_valid_for_deacon(possible_deacon, user))
		return FALSE
	//no one invited or this is not the invited person
	if(!potential_deacon || (possible_deacon != potential_deacon))
		INVOKE_ASYNC(src, PROC_REF(invite_deacon), possible_deacon)
		to_chat(user, span_notice("Претенденту была предложена возможность вступить в наши ряды. Подождите, пока он решит, и попробуйте ещё раз."))
		return FALSE
	return ..()

/datum/religion_rites/deaconize/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	. = ..()
	if(!(potential_deacon in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("[potential_deacon.declent_ru(NOMINATIVE)] больше не находится на алтаре!"))
		return FALSE
	if(potential_deacon.stat != CONSCIOUS)
		to_chat(user, span_warning("[potential_deacon.declent_ru(NOMINATIVE)] должен быть в сознании, чтобы сработал ритуал!"))
		return FALSE
	if(!potential_deacon.mind)
		to_chat(user, span_warning("Разум [potential_deacon.declent_ru(GENITIVE)] находится в другом месте!"))
		return FALSE
	if(IS_CULTIST(potential_deacon))//what the fuck?!
		to_chat(user, span_warning("[GLOB.deity] увидел истинное, тёмное зло в сердце [potential_deacon.declent_ru(GENITIVE)], потому [potential_deacon.ru_p_they()] был[genderize_ru(potential_deacon, "", "а", "о", "и")] [genderize_ru(potential_deacon, "поражён", "поражена", "поражено", "поражены")]!"))
		playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
		potential_deacon.gib(DROP_ORGANS|DROP_BODYPARTS)
		return FALSE
	var/datum/brain_trauma/special/honorbound/honor = user.has_trauma_type(/datum/brain_trauma/special/honorbound)
	if(honor && (potential_deacon in honor.guilty))
		honor.guilty -= potential_deacon
	to_chat(user, span_notice("[GLOB.deity] связал [potential_deacon.declent_ru(ACCUSATIVE)] с кодексом! Теперь [potential_deacon.ru_p_they()] занимает святую роль (пусть и самого низшего ранга)!"))
	potential_deacon.mind.set_holy_role(HOLY_ROLE_DEACON)
	GLOB.religious_sect.on_conversion(potential_deacon)
	playsound(get_turf(religious_tool), 'sound/effects/pray.ogg', 50, TRUE)
	return TRUE

///Helper if the passed possible_deacon is valid to become a deacon or not.
/datum/religion_rites/deaconize/proc/is_valid_for_deacon(mob/living/carbon/human/possible_deacon, mob/living/user)
	if(possible_deacon.stat != CONSCIOUS)
		to_chat(user, span_warning("[possible_deacon.declent_ru(NOMINATIVE)] долж[genderize_ru(possible_deacon, "ен", "на", "но", "ны")] быть жив[genderize_ru(possible_deacon, "", "а", "о", "ы")] и в сознании, чтобы вступить!"))
		return FALSE
	if(possible_deacon.mind && possible_deacon.mind.holy_role)
		to_chat(user, span_warning("[possible_deacon.declent_ru(NOMINATIVE)] уже является членом этой религии!"))
		return FALSE
	return TRUE

/**
 * Async proc that waits for a response on joining the sect.
 * If they accept, the deaconize rite can now recruit them instead of just offering more invites.
 */
/datum/religion_rites/deaconize/proc/invite_deacon(mob/living/carbon/human/invited)
	var/ask = tgui_alert(invited, "Присоединиться к [GLOB.deity]? Ожидается, что вы будете следовать указам священника.", "Приглашение", list("Да", "Нет"), 60 SECONDS)
	if(ask != "Да")
		return
	potential_deacon = invited
