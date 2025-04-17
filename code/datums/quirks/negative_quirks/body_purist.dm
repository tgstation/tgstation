/datum/quirk/body_purist
	name = "Body Purist"
	desc = "You believe your body is a temple and its natural form is an embodiment of perfection. Accordingly, you despise the idea of ever augmenting it with unnatural parts, cybernetic, prosthetic, or anything like it."
	icon = FA_ICON_PERSON_RAYS
	value = -2
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	gain_text = span_danger("You now begin to hate the idea of having cybernetic implants.")
	lose_text = span_notice("Maybe cybernetics aren't so bad. You now feel okay with augmentations and prosthetics.")
	medical_record_text = "This patient has disclosed an extreme hatred for unnatural bodyparts and augmentations."
	hardcore_value = 3
	mail_goodies = list(/obj/item/paper/pamphlet/cybernetics)

/datum/quirk/body_purist/add(client/client_source)
	check_cybernetics()
	RegisterSignal(quirk_holder, COMSIG_CARBON_BODYTYPE_SYNCHRONIZED, PROC_REF(check_cybernetics))

/datum/quirk/body_purist/remove()
	UnregisterSignal(quirk_holder, COMSIG_CARBON_BODYTYPE_SYNCHRONIZED)
	quirk_holder.clear_mood_event("body_purist")

/datum/quirk/body_purist/proc/check_cybernetics(datum/source)
	SIGNAL_HANDLER
	var/cybernetics_level = 0
	var/mob/living/carbon/owner = quirk_holder
	if(!istype(owner))
		return
	for(var/obj/item/bodypart/limb as anything in owner.bodyparts)
		if(IS_ROBOTIC_LIMB(limb))
			cybernetics_level++
	for(var/obj/item/organ/organ as anything in owner.organs)
		if(IS_ROBOTIC_ORGAN(organ) && !(organ.organ_flags & ORGAN_HIDDEN))
			cybernetics_level++
	update_mood(cybernetics_level)

/datum/quirk/body_purist/proc/update_mood(cybernetics_level)
	if(cybernetics_level)
		quirk_holder.add_mood_event("body_purist", /datum/mood_event/body_purist, -cybernetics_level * 10)
		return
	quirk_holder.clear_mood_event("body_purist")
