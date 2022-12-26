/datum/action/cooldown/spell/vow_of_silence
	name = "Speech"
	desc = "Make (or break) a vow of silence."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "mime_speech"
	panel = "Mime"

	school = SCHOOL_MIME
	cooldown_time = 5 MINUTES

	spell_requirements = SPELL_REQUIRES_HUMAN
	spell_max_level = 1

/datum/action/cooldown/spell/vow_of_silence/cast(mob/living/carbon/human/cast_on)
	. = ..()
	var/obj/item/organ/internal/liver/liver = cast_on.getorganslot(ORGAN_SLOT_LIVER)
	//should never happen
	if(!liver)
		return
	if(TRAIT_BROKEN_VOW in liver.organ_traits)
		to_chat(cast_on, span_notice("You make a vow of silence."))
		liver.remove_organ_trait(TRAIT_BROKEN_VOW)
	else
		to_chat(cast_on, span_notice("You break your vow of silence."))
		liver.add_organ_trait(TRAIT_BROKEN_VOW)
	cast_on.update_mob_action_buttons()
