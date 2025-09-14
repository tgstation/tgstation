/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN_APPEARANCE), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN_APPEARANCE)), PROC_REF(update_ID_card))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_DWARF), SIGNAL_REMOVETRAIT(TRAIT_DWARF)), PROC_REF(on_dwarf_trait))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_TOO_TALL), SIGNAL_REMOVETRAIT(TRAIT_TOO_TALL)), PROC_REF(on_tootall_trait))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NOHUNGER), SIGNAL_REMOVETRAIT(TRAIT_NOHUNGER)), PROC_REF(on_nohunger))

	RegisterSignal(src, COMSIG_ATOM_CONTENTS_WEIGHT_CLASS_CHANGED, PROC_REF(check_pocket_weght))

	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(clean_face))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_HUSK), SIGNAL_REMOVETRAIT(TRAIT_HUSK)), PROC_REF(refresh_obscured))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_INVISIBLE_MAN), SIGNAL_REMOVETRAIT(TRAIT_INVISIBLE_MAN)), PROC_REF(invisible_man_toggle))
	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_DISFIGURED), SIGNAL_REMOVETRAIT(TRAIT_DISFIGURED)), PROC_REF(update_visible_name))

/// Gaining or losing [TRAIT_DWARF] updates our height and grants passtable
/mob/living/carbon/human/proc/on_dwarf_trait(datum/source)
	SIGNAL_HANDLER

	update_mob_height()
	// Toggle passtable
	if(HAS_TRAIT(src, TRAIT_DWARF))
		passtable_on(src, TRAIT_DWARF)
	else
		passtable_off(src, TRAIT_DWARF)

/// Gaining or losing [TRAIT_TOO_TALL] updates our height
/mob/living/carbon/human/proc/on_tootall_trait(datum/source)
	SIGNAL_HANDLER
	update_mob_height()

/mob/living/carbon/human/proc/on_fat(datum/source)
	SIGNAL_HANDLER
	hud_used?.hunger?.update_hunger_bar()
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
		remove_traits(list(TRAIT_FAT, TRAIT_OFF_BALANCE_TACKLER), OBESITY)
	else
		hud_used?.hunger?.update_hunger_bar()
		mob_mood?.update_nutrition_moodlets()

/// Signal proc for [COMSIG_ATOM_CONTENTS_WEIGHT_CLASS_CHANGED] to check if an item is suddenly too heavy for our pockets
/mob/living/carbon/human/proc/check_pocket_weght(datum/source, obj/item/changed, old_w_class, new_w_class)
	SIGNAL_HANDLER
	if(changed != r_store && changed != l_store)
		return
	if(new_w_class <= POCKET_WEIGHT_CLASS)
		return
	if(!dropItemToGround(changed, force = TRUE))
		return
	visible_message(
		span_warning("[changed] falls out of [src]'s pockets!"),
		span_warning("[changed] falls out of your pockets!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	playsound(src, SFX_RUSTLE, 50, TRUE, -5, frequency = 0.8)

/// When [TRAIT_INVISIBLE_MAN] is added or removed we need to update a few things
/mob/living/carbon/human/proc/invisible_man_toggle(datum/source)
	SIGNAL_HANDLER
	refresh_obscured()
	update_visible_name()
