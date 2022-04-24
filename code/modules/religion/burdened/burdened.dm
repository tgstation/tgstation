/datum/religion_sect/burden
	name = "Punished God"
	quote = "To feel the freedom, you must first understand captivity."
	desc = "Incapacitate yourself in any way possible. Bad mutations, lost limbs, traumas, \
	even addictions. You will learn the secrets of the universe from your defeated shell."
	tgui_icon = "user-injured"
	altar_icon_state = "convertaltar-burden"
	alignment = ALIGNMENT_NEUT
	candle_overlay = FALSE

/datum/religion_sect/burden/on_conversion(mob/living/carbon/human/new_convert)
	..()
	if(!ishuman(new_convert))
		to_chat(new_convert, span_warning("[GLOB.deity] needs higher level creatures to fully comprehend the suffering. You are not burdened."))
		return
	new_convert.gain_trauma(/datum/brain_trauma/special/burdened, TRAUMA_RESILIENCE_MAGIC)

/datum/religion_sect/burden/tool_examine(mob/living/carbon/human/burdened) //display burden level
	if(!ishuman(burdened))
		return FALSE
	var/datum/brain_trauma/special/burdened/burden = burdened.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(burden)
		return "You are at burden level [burden.burden_level]/6."
	return "You are not burdened."

