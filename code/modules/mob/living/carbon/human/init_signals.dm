/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN)), PROC_REF(on_unknown_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_DWARF), SIGNAL_REMOVETRAIT(TRAIT_DWARF)), PROC_REF(on_dwarf_trait))
	RegisterSignal(src, COMSIG_MOVABLE_MESSAGE_GET_NAME_PART, PROC_REF(get_name_part))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NOHUNGER), SIGNAL_REMOVETRAIT(TRAIT_NOHUNGER)), PROC_REF(on_nohunger))

/// Gaining or losing [TRAIT_UNKNOWN] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()

/// Gaining or losing [TRAIT_DWARF] updates our height
/mob/living/carbon/human/proc/on_dwarf_trait(datum/source)
	SIGNAL_HANDLER

	// We need to regenerate everything for height
	regenerate_icons()
	// Toggle passtable
	if(HAS_TRAIT(src, TRAIT_DWARF))
		passtable_on(src, TRAIT_DWARF)
	else
		passtable_off(src, TRAIT_DWARF)

///From compose_message(). Snowflake code converted into its own signal proc
/mob/living/carbon/human/proc/get_name_part(datum/source, list/stored_name, visible_name)
	SIGNAL_HANDLER
	/**
	 * For if the message can be seen but not heard, shows our visible identity (like when using sign language)
	 * Also used by hallucinations, so it doesn't give source's identity away.
	 */
	if(visible_name)
		stored_name[NAME_PART_INDEX] = get_visible_name()
		return
	var/voice_name = GetVoice()
	if(name != voice_name)
		voice_name += " (as [get_id_name("Unknown")])"
	stored_name[NAME_PART_INDEX] = voice_name

/mob/living/carbon/human/proc/on_fat(datum/source)
	SIGNAL_HANDLER
	hud_used?.hunger?.update_appearance()
	mob_mood?.update_nutrition_moodlets()

	if(HAS_TRAIT(src, TRAIT_FAT))
		add_movespeed_modifier(/datum/movespeed_modifier/obesity)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/obesity)

/mob/living/carbon/human/proc/on_nohunger(datum/source)
	SIGNAL_HANDLER
	// When gaining NOHUNGER, we restore nutrition to normal levels, since we no longer interact with the hunger system
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		set_nutrition(NUTRITION_LEVEL_FED, forced = TRUE)
		satiety = 0
		overeatduration = 0
		REMOVE_TRAIT(src, TRAIT_FAT, OBESITY)
	else
		hud_used?.hunger?.update_appearance()
		mob_mood?.update_nutrition_moodlets()
